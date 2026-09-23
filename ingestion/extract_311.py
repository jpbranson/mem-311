"""Extract Memphis 311 service requests from the city's ArcGIS FeatureServer and load them to BigQuery.

Usage:
    uv run python ingestion/extract_311.py --mode full
    uv run python ingestion/extract_311.py --mode incremental [--lookback-hours 48]

Design (see docs/decisions.md):
  * The raw table is append-only. Every run writes a batch tagged with _batch_id / _ingested_at / _source.
    Staging picks the latest version of each OBJECTID, so re-running is idempotent downstream.
  * A full run snapshots every live record; incremental runs pull records whose last_edited_date is
    at or after (previous high-water mark - lookback). Records missing from the newest full snapshot and
    not seen in a later incremental batch are treated as deleted at source.
  * Personal contact fields and free-text narrative fields are dropped before anything is written.
    Flags that need them (AI detection, SeeClickFix intake) are derived first.
  * Coordinates come from the feature geometry reprojected to WGS84 (outSR=4326); the X/Y attribute
    columns mix State Plane feet and degrees and are not used.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import logging
import re
import sys
import time
import uuid
from pathlib import Path

import requests
from google.cloud import bigquery

PROJECT = "mem-311"
LOCATION = "US"
RAW_DATASET = "raw"
RAW_TABLE = "memphis_311_requests"
BATCH_TABLE = "ingestion_batches"

SOURCE_URL = "https://311.memphistn.gov/server/rest/services/311/311_Request_Map_PROD/FeatureServer/0"
PAGE_SIZE = 3000  # service maxRecordCount
TIMEOUT_S = 120
MAX_RETRIES = 5

# Source fields retained in the raw layer. Everything else is dropped at extraction:
#   - resident / owner / utility-customer contact fields (names, phones, emails, owner addresses)
#   - free-text narrative typed by residents or staff (REQUEST_SUMMARY, REQUEST_NOTES, JOB_NOTES,
#     SCF_Description, Transfer_Notes, Supervisor_Notes) - these contain phone numbers and names
#   - staff user names (created_user, last_edited_user, ASSIGNED_TO, SUPERVISOR)
#   - X / Y attributes (mixed coordinate systems; geometry is used instead)
KEEP_FIELDS = [
    "OBJECTID", "GlobalID", "INCIDENT_ID", "INCIDENT_NUMBER", "INCIDENT_TYPE_ID",
    "DIVISION", "DEPARTMENT", "CATEGORY", "REQUEST_TYPE", "REQUEST_STATUS", "Request_Sub_Status",
    "REQUEST_PRIORITY", "REPORTED_DATE", "DAYS_OLD", "FOLLOWUP_DATE", "ASSIGNED_DATE",
    "QAQC_YESNO", "QAQC_RATING", "SUPERVISOR_APPROVAL",
    "RESOLVED_DATE", "Closed_Date", "RESOLUTION_CODE", "RESOLUTION_SUMMARY",
    "GROUP_NAME", "Location_Address", "Unit_Address", "CITY", "STATE", "ZipCode", "PARCEL_ID", "ASSET_ID",
    "MAP_PG", "MAP_BLK", "CODE_DISTRICT", "CODE_SUBDISTRICT", "TARGET_BLOCK", "DRAIN_ZONE", "DRAIN_GRID",
    "STREET_ZONE", "STREET_GRID", "TRAFFIC_ZONE", "SWM_AREA", "SWM_ZONE", "SWM_CollectionDay", "SWM_ROUTE",
    "LINKED_SR", "cd_name", "cd_desc", "sccd_name", "sccd_desc", "scd_name", "scd_desc", "neigh_desc",
    "created_date", "last_edited_date",
    "Transfer", "Transfer_Dept", "Anonymous", "Transfer_Status", "SYSREVSTATUS", "ext_system_no",
]
# Fields read only to derive flags, then discarded.
DERIVE_ONLY_FIELDS = ["REQUEST_SUMMARY", "SCF_URL"]

ESRI_TO_BQ = {
    "esriFieldTypeOID": "INT64",
    "esriFieldTypeInteger": "INT64",
    "esriFieldTypeSmallInteger": "INT64",
    "esriFieldTypeDouble": "FLOAT64",
    "esriFieldTypeSingle": "FLOAT64",
    "esriFieldTypeDate": "TIMESTAMP",
    "esriFieldTypeString": "STRING",
    "esriFieldTypeGlobalID": "STRING",
    "esriFieldTypeGUID": "STRING",
}

DERIVED_SCHEMA = [
    bigquery.SchemaField("longitude", "FLOAT64", description="WGS84 longitude from feature geometry"),
    bigquery.SchemaField("latitude", "FLOAT64", description="WGS84 latitude from feature geometry"),
    bigquery.SchemaField("is_ai_detected", "BOOL",
                         description="Created by the Google AI Detection pilot (summary text or egen.ai image link)"),
    bigquery.SchemaField("is_seeclickfix", "BOOL", description="Linked to a SeeClickFix issue (resident app intake)"),
    bigquery.SchemaField("_batch_id", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("_ingested_at", "TIMESTAMP", mode="REQUIRED"),
    bigquery.SchemaField("_source", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("_extract_mode", "STRING", mode="REQUIRED"),
]

BATCH_SCHEMA = [
    bigquery.SchemaField("batch_id", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("extract_mode", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("started_at", "TIMESTAMP", mode="REQUIRED"),
    bigquery.SchemaField("finished_at", "TIMESTAMP"),
    bigquery.SchemaField("where_clause", "STRING"),
    bigquery.SchemaField("expected_count", "INT64"),
    bigquery.SchemaField("extracted_count", "INT64"),
    bigquery.SchemaField("loaded_count", "INT64"),
    bigquery.SchemaField("max_last_edited", "TIMESTAMP"),
    bigquery.SchemaField("status", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("message", "STRING"),
]

PHONE_RE = re.compile(r"\(?\b\d{3}\)?[\s.\-]?\d{3}[\s.\-]?\d{4}\b")
EMAIL_RE = re.compile(r"[\w.+\-]+@[\w\-]+\.[\w.\-]+")

EPOCH = dt.datetime(1970, 1, 1, tzinfo=dt.timezone.utc)

log = logging.getLogger("extract_311")


def setup_logging(log_dir: Path, batch_id: str) -> None:
    log_dir.mkdir(parents=True, exist_ok=True)
    fmt = logging.Formatter("%(asctime)s %(levelname)s %(message)s")
    for h in (logging.StreamHandler(sys.stdout), logging.FileHandler(log_dir / f"extract_{batch_id}.log")):
        h.setFormatter(fmt)
        log.addHandler(h)
    log.setLevel(logging.INFO)


def arcgis_get(session: requests.Session, url: str, params: dict) -> dict:
    """GET with retry/backoff. ArcGIS returns HTTP 200 with an 'error' body on failure, so check both."""
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            r = session.get(url, params=params, timeout=TIMEOUT_S)
            r.raise_for_status()
            body = r.json()
            if "error" in body:
                raise RuntimeError(f"ArcGIS error: {body['error']}")
            return body
        except (requests.RequestException, RuntimeError, ValueError) as exc:
            if attempt == MAX_RETRIES:
                raise
            wait = 2 ** attempt
            log.warning("request failed (attempt %d/%d): %s; retrying in %ds", attempt, MAX_RETRIES, exc, wait)
            time.sleep(wait)
    raise AssertionError("unreachable")


def raw_schema(session: requests.Session) -> list[bigquery.SchemaField]:
    meta = arcgis_get(session, SOURCE_URL, {"f": "json"})
    by_name = {f["name"]: f for f in meta["fields"]}
    missing = [f for f in KEEP_FIELDS + DERIVE_ONLY_FIELDS if f not in by_name]
    if missing:
        raise RuntimeError(f"source schema changed; missing fields: {missing}")
    return [
        bigquery.SchemaField(name, ESRI_TO_BQ[by_name[name]["type"]], description=by_name[name].get("alias"))
        for name in KEEP_FIELDS
    ] + DERIVED_SCHEMA


def count(session: requests.Session, where: str) -> int:
    return arcgis_get(session, f"{SOURCE_URL}/query", {"where": where, "returnCountOnly": "true", "f": "json"})["count"]


def extract(session: requests.Session, where: str):
    """Keyset pagination on OBJECTID (stable under concurrent inserts, unlike resultOffset)."""
    last_oid = -1
    out_fields = ",".join(KEEP_FIELDS + DERIVE_ONLY_FIELDS)
    while True:
        body = arcgis_get(session, f"{SOURCE_URL}/query", {
            "where": f"({where}) AND OBJECTID > {last_oid}",
            "outFields": out_fields,
            "orderByFields": "OBJECTID ASC",
            "resultRecordCount": PAGE_SIZE,
            "returnGeometry": "true",
            "outSR": 4326,
            "f": "json",
        })
        feats = body.get("features", [])
        if not feats:
            return
        yield feats
        last_oid = feats[-1]["attributes"]["OBJECTID"]
        if not body.get("exceededTransferLimit") and len(feats) < PAGE_SIZE:
            return


def redact(text):
    if not text:
        return text
    return EMAIL_RE.sub("[email]", PHONE_RE.sub("[phone]", text))


def to_row(feat: dict, schema_types: dict, batch_meta: dict) -> dict:
    a = feat["attributes"]
    summary = a.get("REQUEST_SUMMARY") or ""
    link = a.get("SCF_URL") or ""
    row = {}
    for name in KEEP_FIELDS:
        v = a.get(name)
        if v is not None and schema_types[name] == "TIMESTAMP":
            # epoch + timedelta: Windows fromtimestamp() rejects pre-1970 values, which occur in the source
            v = (EPOCH + dt.timedelta(milliseconds=v)).isoformat()
        elif isinstance(v, str):
            v = v.strip() or None
        row[name] = v
    row["RESOLUTION_SUMMARY"] = redact(row["RESOLUTION_SUMMARY"])
    geom = feat.get("geometry") or {}
    x, y = geom.get("x"), geom.get("y")
    ok = isinstance(x, (int, float)) and isinstance(y, (int, float)) and x == x and y == y  # NaN check
    row["longitude"] = x if ok else None
    row["latitude"] = y if ok else None
    row["is_ai_detected"] = "google ai detection" in summary.lower() or "egen.ai" in link.lower()
    row["is_seeclickfix"] = "seeclickfix.com" in link.lower()
    row.update(batch_meta)
    return row


def ensure_tables(bq: bigquery.Client, schema: list[bigquery.SchemaField]) -> None:
    ds = bigquery.Dataset(f"{PROJECT}.{RAW_DATASET}")
    ds.location = LOCATION
    ds.description = "Memphis 311 source data as extracted (PII fields excluded)."
    bq.create_dataset(ds, exists_ok=True)

    t = bigquery.Table(f"{PROJECT}.{RAW_DATASET}.{RAW_TABLE}", schema=schema)
    t.time_partitioning = bigquery.TimePartitioning(field="_ingested_at", type_=bigquery.TimePartitioningType.DAY)
    t.clustering_fields = ["OBJECTID"]
    t.description = "Append-only extraction batches of the Memphis 311 ArcGIS layer. One row per record per batch."
    bq.create_table(t, exists_ok=True)
    existing = bq.get_table(t.reference)
    new_cols = [f for f in schema if f.name not in {c.name for c in existing.schema}]
    if new_cols:  # additive schema evolution only
        existing.schema = list(existing.schema) + new_cols
        bq.update_table(existing, ["schema"])

    b = bigquery.Table(f"{PROJECT}.{RAW_DATASET}.{BATCH_TABLE}", schema=BATCH_SCHEMA)
    b.description = "One row per extraction run with validation counts."
    bq.create_table(b, exists_ok=True)


def high_water_mark(bq: bigquery.Client):
    sql = f"""select max(max_last_edited) as hwm from `{PROJECT}.{RAW_DATASET}.{BATCH_TABLE}`
              where status = 'success'"""
    return next(iter(bq.query(sql).result())).hwm


def record_batch(bq: bigquery.Client, rec: dict) -> None:
    job = bq.load_table_from_json([rec], f"{PROJECT}.{RAW_DATASET}.{BATCH_TABLE}",
                                  job_config=bigquery.LoadJobConfig(schema=BATCH_SCHEMA,
                                                                    write_disposition="WRITE_APPEND"))
    job.result()


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--mode", choices=["full", "incremental"], required=True)
    ap.add_argument("--lookback-hours", type=int, default=48,
                    help="incremental overlap before the previous high-water mark (absorbs late edits)")
    ap.add_argument("--dump", type=Path, help="also write extracted rows to this NDJSON file")
    args = ap.parse_args()

    started = dt.datetime.now(dt.timezone.utc)
    batch_id = f"{started:%Y%m%dT%H%M%SZ}_{args.mode}_{uuid.uuid4().hex[:6]}"
    setup_logging(Path(__file__).resolve().parent.parent / "logs", batch_id)
    bq = bigquery.Client(project=PROJECT, location=LOCATION)
    session = requests.Session()
    session.headers["User-Agent"] = "mem-311-analytics/1.0 (read-only portfolio project)"

    schema = raw_schema(session)
    ensure_tables(bq, schema)
    schema_types = {f.name: f.field_type for f in schema}

    where = "1=1"
    if args.mode == "incremental":
        hwm = high_water_mark(bq)
        if hwm is None:
            log.error("no successful prior batch; run --mode full first")
            return 2
        since = hwm - dt.timedelta(hours=args.lookback_hours)
        where = f"last_edited_date >= TIMESTAMP '{since:%Y-%m-%d %H:%M:%S}'"

    batch = {"batch_id": batch_id, "extract_mode": args.mode, "started_at": started.isoformat(),
             "where_clause": where}
    try:
        expected = count(session, where)
        log.info("batch %s: %d records match %r", batch_id, expected, where)
        meta = {"_batch_id": batch_id, "_ingested_at": started.isoformat(), "_source": SOURCE_URL,
                "_extract_mode": args.mode}
        rows, seen = [], set()
        for page in extract(session, where):
            for feat in page:
                row = to_row(feat, schema_types, meta)
                if row["OBJECTID"] in seen:
                    raise RuntimeError(f"duplicate OBJECTID {row['OBJECTID']} across pages")
                seen.add(row["OBJECTID"])
                rows.append(row)
            log.info("  extracted %d / %d", len(rows), expected)

        # Validation: incremental windows can gain records mid-run, so allow growth but never shrinkage.
        if len(rows) < expected or (args.mode == "full" and len(rows) > expected * 1.01):
            raise RuntimeError(f"record count mismatch: expected {expected}, extracted {len(rows)}")
        max_edit = max((r["last_edited_date"] for r in rows if r["last_edited_date"]), default=None)

        if args.dump:
            args.dump.parent.mkdir(parents=True, exist_ok=True)
            with args.dump.open("w", encoding="utf-8") as fh:
                for r in rows:
                    fh.write(json.dumps(r) + "\n")

        loaded = 0
        if rows:
            job = bq.load_table_from_json(
                rows, f"{PROJECT}.{RAW_DATASET}.{RAW_TABLE}",
                job_config=bigquery.LoadJobConfig(schema=schema, write_disposition="WRITE_APPEND"),
            )
            job.result()
            loaded = job.output_rows
        if loaded != len(rows):
            raise RuntimeError(f"BigQuery loaded {loaded} rows, expected {len(rows)}")

        batch.update(expected_count=expected, extracted_count=len(rows), loaded_count=loaded,
                     max_last_edited=max_edit, status="success",
                     finished_at=dt.datetime.now(dt.timezone.utc).isoformat())
        record_batch(bq, batch)
        log.info("batch %s succeeded: %d rows loaded", batch_id, loaded)
        return 0
    except Exception as exc:  # record the failure, then re-raise for a non-zero exit
        log.exception("batch %s failed", batch_id)
        batch.update(status="failed", message=str(exc)[:1000],
                     finished_at=dt.datetime.now(dt.timezone.utc).isoformat())
        record_batch(bq, batch)
        raise


if __name__ == "__main__":
    sys.exit(main())
