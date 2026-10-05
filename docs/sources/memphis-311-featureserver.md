---
type: API Endpoint
title: Memphis 311 ArcGIS FeatureServer, layer 0
description: The City of Memphis 311 request map service - the only source of request data, read with query calls only, personal fields dropped at extraction.
resource: https://311.memphistn.gov/server/rest/services/311/311_Request_Map_PROD/FeatureServer/0
tags: [source, arcgis, ingestion]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: extractor
    resource: ../../ingestion/extract_311.py
    title: Extractor (KEEP_FIELDS, DERIVE_ONLY_FIELDS, paging and validation)
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (406,902 records)
    title: Field profile and record counts
---

Layer 0, "311 Requests", described by the city as "all 311 requests created by 311 Support center staff and
citizens". Layers 2–4 are filtered views of the same records and are ignored; table 1 (`CoM_311_Notes`) is not
ingested ([D01](../decisions/D01-source-featureserver-layer-0.md)). The endpoint is public and advertises editing capabilities to anonymous callers; this project
only issues `query` requests, with an identifying User-Agent.

# How it is read

* Keyset pagination on `OBJECTID`, 3,000 records per page (the service `maxRecordCount`) ([D05](../decisions/D05-keyset-pagination.md)).
* Geometry requested with `outSR=4326`; the `X`/`Y` attributes mix degrees and State Plane feet and are ignored ([D04](../decisions/D04-coordinates-from-geometry.md)).
* Full snapshot weekly, watermark-based incremental (`last_edited_date` − 48 h) daily ([D07](../decisions/D07-incremental-and-full-snapshots.md)); a full run that
  returns 0 rows fails ([D32](../decisions/D32-empty-full-extract-fails.md)).
* A run fails if a retained field disappears, an `OBJECTID` repeats, or the extracted count falls short of
  `returnCountOnly`.[^extractor]

# What is kept and dropped

* Kept: the fields in `KEEP_FIELDS` of [`ingestion/extract_311.py`](../../ingestion/extract_311.py), plus
  `_batch_id`, `_ingested_at`, `_source` and `_extract_mode`. They land in
  [`raw.memphis_311_requests`](../tables/raw/memphis_311_requests.md).
* Dropped before anything is written: resident contact, owner and utility-customer fields, free-text
  narratives, staff identities and the notes table ([D02](../decisions/D02-drop-personal-fields-at-extraction.md)). `RESOLUTION_SUMMARY` is kept with phone numbers and
  emails redacted ([D03](../decisions/D03-redact-resolution-summary.md)). `is_ai_detected` and `is_seeclickfix` are derived from `REQUEST_SUMMARY` and `SCF_URL`
  first, then those fields are discarded.

# Known quirks

| Quirk | Handling |
|---|---|
| 16.8% of `REPORTED_DATE` values are a local date stored as midnight UTC (mostly SeeClickFix) | Treated as date-only ([D10](../decisions/D10-time-zones-and-date-only-timestamps.md)) |
| 16,883 `Closed` records have no `Closed_Date` | Closure imputed from `last_edited_date`, excluded from resolution metrics ([D11](../decisions/D11-open-closed-status-and-imputed-closure.md)) |
| `DEPARTMENT` is null or contradicts the type prefix from late 2025 | Categories from `REQUEST_TYPE` via a seed ([D13](../decisions/D13-request-type-categories-seed.md)) |
| `CATEGORY`, `LINKED_SR` and `neigh_desc` are (almost) always null | Not used ([D08](../decisions/D08-record-and-business-keys.md), [D13](../decisions/D13-request-type-categories-seed.md), [D18](../decisions/D18-geography.md)) |
| Geocoder fallbacks: 1,088 records at one point in Arkansas, shared default points in Memphis | Invalid for matching ([D17](../decisions/D17-valid-coordinates.md)) |
| City-wide bulk edits, e.g. 24k records in single minutes in late September 2025 | Weekly full snapshot; the 2025-09-22 mass closure is detected by rule ([D07](../decisions/D07-incremental-and-full-snapshots.md), [D28](../decisions/D28-mass-closure-2025-09-22.md)) |
| `created_user` is masked in feature queries | Intake channel cannot be recovered ([D02](../decisions/D02-drop-personal-fields-at-extraction.md), [D15](../decisions/D15-pothole-analysis-omitted.md)) |
