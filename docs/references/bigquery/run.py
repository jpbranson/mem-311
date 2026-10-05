"""Executor for OKF Attested Computations with runtime bigquery.

Usage:
    uv run python docs/references/bigquery/run.py <concept.md> [name=value ...] > receipt.json

Binds only the declared parameters, runs the concept's computation unchanged and prints the receipt that
executor.receipt declares: job_id, location, executed_sql, parameters and result. Warns on stderr when the
concept is past its stale_after. Verify the receipt with attest.py.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from google.cloud import bigquery

sys.path.insert(0, str(Path(__file__).resolve().parent))
import computation  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("concept", help="path to the Attested Computation concept")
    ap.add_argument("params", nargs="*", metavar="name=value", help="values for declared parameters")
    ap.add_argument("--project", help="billing project (default: the credentials' project)")
    args = ap.parse_args()

    c = computation.load(args.concept)
    values = dict(p.split("=", 1) for p in args.params)
    if c.stale():
        print(f"warning: {c.path} is stale since {c.meta['stale_after']}", file=sys.stderr)
    client = bigquery.Client(project=args.project)
    config = bigquery.QueryJobConfig(query_parameters=computation.query_parameters(c, values))
    job = client.query(c.sql, job_config=config)
    receipt = {
        "concept": c.path.as_posix(),
        "job_id": job.job_id,
        "project": job.project,
        "location": job.location,
        "executed_sql": job.query,
        "parameters": values,
        "result": computation.rows_as_json(job.result()),
    }
    print(json.dumps(receipt, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
