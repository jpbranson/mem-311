"""Run the full pipeline: extract from the Memphis 311 API into BigQuery, then build and test the dbt project.

Usage:
    uv run python scripts/run_pipeline.py                 # incremental extract + dbt build
    uv run python scripts/run_pipeline.py --full          # full snapshot (weekly; detects deletions, D07)
    uv run python scripts/run_pipeline.py --skip-extract  # dbt only

Requires GOOGLE_APPLICATION_CREDENTIALS to point at a service-account key with BigQuery access to mem-311.
Every run, successful or not, writes status/status.json for the project tracker (D31, docs/decisions/D31-tracker-status-file.md).
"""
import argparse
import datetime as dt
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STATUS = ROOT / "status" / "status.json"
BATCH = ROOT / "logs" / "last_batch.json"  # left by ingestion/extract_311.py
STALE_SOURCE = dt.timedelta(days=2)  # the source is edited daily, weekends included


def run(cmd: list[str], cwd: Path = ROOT) -> None:
    print(f"\n$ {' '.join(cmd)}", flush=True)
    subprocess.run(cmd, cwd=cwd, check=True)


def status_document(failed_stage: str | None, batch: dict | None, now: dt.datetime) -> dict:
    """The tracker's status contract: fail when a stage failed, warn when the run succeeded but the source's
    newest edit is older than STALE_SOURCE, ok otherwise. A 0-row batch is not a failure."""
    if failed_stage:
        message = batch.get("message") if batch and failed_stage == "extract" else None
        return {"status": "fail", "last_success_at": None, "expect_every": "1d",
                "detail": f"failed at {failed_stage}" + (f": {message[:120]}" if message else "")}
    status, notes = "ok", []
    if batch:
        notes.append(f"{batch['extract_mode']} extract: {batch['loaded_count']:,} rows loaded")
        edited = batch.get("max_last_edited")
        if edited:
            newest = dt.datetime.fromisoformat(edited)
            newest = newest if newest.tzinfo else newest.replace(tzinfo=dt.timezone.utc)
            stale = now - newest > STALE_SOURCE
            status = "warn" if stale else status
            notes.append(f"source {'not edited since' if stale else 'edited through'} {newest:%Y-%m-%d %H:%M} UTC")
    else:
        notes.append("dbt only (no extract)")
    return {"status": status, "last_success_at": now.strftime("%Y-%m-%dT%H:%M:%SZ"), "expect_every": "1d",
            "detail": "; ".join(notes)}


def write_status(failed_stage: str | None) -> None:
    batch = json.loads(BATCH.read_text(encoding="utf-8")) if BATCH.exists() else None
    STATUS.parent.mkdir(exist_ok=True)
    doc = status_document(failed_stage, batch, dt.datetime.now(dt.timezone.utc))
    STATUS.write_text(json.dumps(doc, indent=1) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--full", action="store_true", help="full snapshot instead of incremental extract")
    ap.add_argument("--skip-extract", action="store_true", help="only run dbt")
    args = ap.parse_args()

    if not os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        sys.exit("GOOGLE_APPLICATION_CREDENTIALS is not set")

    BATCH.unlink(missing_ok=True)  # only this run's extract may leave one
    stage = "extract"
    try:
        if not args.skip_extract:
            run([sys.executable, "ingestion/extract_311.py", "--mode", "full" if args.full else "incremental"])
        dbt = ["dbt", "--no-use-colors"]
        stage = "dbt build"
        run([*dbt, "deps", "--profiles-dir", "."], cwd=ROOT / "dbt")
        run([*dbt, "build", "--profiles-dir", "."], cwd=ROOT / "dbt")
        stage = "dbt docs"
        run([*dbt, "docs", "generate", "--profiles-dir", "."], cwd=ROOT / "dbt")
        stage = "knowledge bundle"
        run([sys.executable, "scripts/build_knowledge.py"])
    except subprocess.CalledProcessError:
        write_status(stage)
        raise
    write_status(None)
    return 0


if __name__ == "__main__":
    sys.exit(main())
