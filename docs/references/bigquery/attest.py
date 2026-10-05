"""Attester for OKF Attested Computations with runtime bigquery. Deterministic; no LLM.

Usage:
    uv run python docs/references/bigquery/attest.py <concept.md> <receipt.json>

Re-reads the BigQuery job named in the receipt, by id, rather than trusting the receipt, and checks:
  * provenance: the SQL the job ran is the concept's computation (whitespace-normalized), and the job's
    query parameters are exactly the receipt's values for declared parameters, with the declared types;
  * integrity: the job is a finished, error-free query that only read data (statement type SELECT);
  * fidelity: the receipt's result equals the job's own result, re-read from BigQuery.
Prints a JSON verdict and exits 0 on pass, 1 on fail. Query results are kept for about 24 hours, so attest
soon after running.
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
    ap.add_argument("receipt", help="receipt JSON written by run.py")
    args = ap.parse_args()

    c = computation.load(args.concept)
    receipt = json.loads(Path(args.receipt).read_text(encoding="utf-8"))
    client = bigquery.Client(project=receipt.get("project"))
    job = client.get_job(receipt["job_id"], project=receipt.get("project"), location=receipt.get("location"))
    checks = []

    def check(name: str, ok: bool, detail: str = "") -> None:
        checks.append({"check": name, "pass": bool(ok), **({"detail": detail} if detail and not ok else {})})

    check("job is a finished query without errors",
          job.job_type == "query" and job.state == "DONE" and job.error_result is None, str(job.error_result))
    check("job only read data", job.statement_type == "SELECT", f"statement type {job.statement_type}")
    check("job ran the sanctioned computation", computation.normalize_sql(job.query) == computation.normalize_sql(c.sql),
          "the executed SQL differs from the concept's computation")
    check("receipt SQL is what the job ran",
          computation.normalize_sql(receipt.get("executed_sql", "")) == computation.normalize_sql(job.query))
    try:
        claimed = {(p.name, p.type_, str(p.value))
                   for p in computation.query_parameters(c, receipt.get("parameters") or {})}
        actual = {(p.name, p.type_, str(p.value)) for p in job.query_parameters}
        check("parameters are declared and match the job", claimed == actual, f"job ran with {sorted(actual)}")
    except ValueError as e:
        check("parameters are declared and match the job", False, str(e))
    try:
        check("result matches the job's own output",
              computation.rows_as_json(job.result()) == receipt.get("result"), "receipt result differs")
    except Exception as e:  # results expired or unreadable
        check("result matches the job's own output", False, f"could not re-read results: {e}")

    verdict = {
        "verdict": "pass" if all(ch["pass"] for ch in checks) else "fail",
        "concept": c.path.as_posix(),
        "job_id": job.job_id,
        "job_url": f"https://console.cloud.google.com/bigquery?project={job.project}"
                   f"&j=bq:{job.location}:{job.job_id}&page=queryresults",
        "stale": c.stale(),
        "checks": checks,
    }
    print(json.dumps(verdict, indent=1))
    return 0 if verdict["verdict"] == "pass" else 1


if __name__ == "__main__":
    sys.exit(main())
