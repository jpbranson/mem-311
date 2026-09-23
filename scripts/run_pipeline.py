"""Run the full pipeline: extract from the Memphis 311 API into BigQuery, then build and test the dbt project.

Usage:
    uv run python scripts/run_pipeline.py                 # incremental extract + dbt build
    uv run python scripts/run_pipeline.py --full          # full snapshot (weekly; detects deletions, D07)
    uv run python scripts/run_pipeline.py --skip-extract  # dbt only

Requires GOOGLE_APPLICATION_CREDENTIALS to point at a service-account key with BigQuery access to mem-311.
"""
import argparse
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def run(cmd: list[str], cwd: Path = ROOT) -> None:
    print(f"\n$ {' '.join(cmd)}", flush=True)
    subprocess.run(cmd, cwd=cwd, check=True)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--full", action="store_true", help="full snapshot instead of incremental extract")
    ap.add_argument("--skip-extract", action="store_true", help="only run dbt")
    args = ap.parse_args()

    if not os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        sys.exit("GOOGLE_APPLICATION_CREDENTIALS is not set")

    if not args.skip_extract:
        run([sys.executable, "ingestion/extract_311.py", "--mode", "full" if args.full else "incremental"])
    dbt = ["dbt", "--no-use-colors"]
    run([*dbt, "deps", "--profiles-dir", "."], cwd=ROOT / "dbt")
    run([*dbt, "build", "--profiles-dir", "."], cwd=ROOT / "dbt")
    run([*dbt, "docs", "generate", "--profiles-dir", "."], cwd=ROOT / "dbt")
    run([sys.executable, "scripts/build_data_dictionary.py"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
