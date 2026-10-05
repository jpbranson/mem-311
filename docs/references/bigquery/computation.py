"""Load an OKF Attested Computation whose runtime is bigquery, and bind its declared parameters.

Shared by run.py (the executor) and attest.py (the attester). Deterministic; needs PyYAML and
google-cloud-bigquery. The SQL is the concept's `computation` file, else the first fenced block under
`# Computation`, used exactly as written: callers may supply parameter values, never SQL.
"""
from __future__ import annotations

import datetime as dt
import decimal
import json
import re
from dataclasses import dataclass
from pathlib import Path

import yaml
from google.cloud import bigquery

FRONTMATTER = re.compile(r"\A---\r?\n(.*?)\r?\n---[ \t]*(?:\r?\n|\Z)", re.S)
FENCE = re.compile(r"(?ms)^# Computation[ \t]*$.*?^```[\w-]*\n(.*?)^```")
BQ_TYPES = {"integer": "INT64", "int": "INT64", "number": "FLOAT64", "float": "FLOAT64", "string": "STRING",
            "boolean": "BOOL", "bool": "BOOL", "date": "DATE", "datetime": "DATETIME", "timestamp": "TIMESTAMP"}


@dataclass
class Computation:
    path: Path
    meta: dict
    sql: str

    @property
    def declared(self) -> dict[str, dict]:
        return {p["name"]: p for p in self.meta.get("parameters") or []}

    def stale(self, now: dt.datetime | None = None) -> bool:
        stale_after = self.meta.get("stale_after")
        if not stale_after:
            return False
        if isinstance(stale_after, str):
            stale_after = dt.datetime.fromisoformat(stale_after)
        if stale_after.tzinfo is None:  # OKF requires an offset; read a missing one as UTC
            stale_after = stale_after.replace(tzinfo=dt.timezone.utc)
        return (now or dt.datetime.now(dt.timezone.utc)) >= stale_after


def load(path: str | Path) -> Computation:
    path = Path(path)
    text = path.read_text(encoding="utf-8")
    m = FRONTMATTER.match(text)
    meta = (yaml.safe_load(m.group(1)) if m else None) or {}
    if meta.get("type") != "Attested Computation" or meta.get("runtime") != "bigquery":
        raise ValueError(f"{path}: not an Attested Computation with runtime bigquery")
    if meta.get("computation"):
        sql = (path.parent / meta["computation"]).read_text(encoding="utf-8")
    else:
        fence = FENCE.search(text[m.end():])
        if not fence:
            raise ValueError(f"{path}: no fenced block under # Computation")
        sql = fence.group(1)
    return Computation(path, meta, sql.strip().rstrip(";").rstrip())


def query_parameters(c: Computation, values: dict[str, str]) -> list[bigquery.ScalarQueryParameter]:
    """Typed BigQuery parameters for the supplied values; only declared parameters may be bound."""
    unknown = sorted(set(values) - set(c.declared))
    if unknown:
        raise ValueError(f"undeclared parameters: {', '.join(unknown)}")
    missing = [name for name, p in c.declared.items() if p.get("required") and name not in values]
    if missing:
        raise ValueError(f"missing required parameters: {', '.join(missing)}")
    return [bigquery.ScalarQueryParameter(name, BQ_TYPES[str(c.declared[name].get("type", "string")).lower()], value)
            for name, value in sorted(values.items())]


def normalize_sql(sql: str) -> str:
    return " ".join(sql.strip().rstrip(";").split())


def json_default(value):
    if isinstance(value, (dt.date, dt.datetime, dt.time)):
        return value.isoformat()
    if isinstance(value, decimal.Decimal):
        return str(value)
    raise TypeError(f"not JSON serializable: {type(value).__name__}")


def rows_as_json(rows) -> list[dict]:
    """Query rows as plain JSON values, so a receipt and a re-read compare equal."""
    return json.loads(json.dumps([dict(r.items()) for r in rows], default=json_default))
