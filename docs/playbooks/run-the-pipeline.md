---
type: Playbook
title: Run the pipeline
description: Extract from the 311 API, build and test the dbt project, and regenerate the table concepts with one command.
tags: [pipeline, operations]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: runner
    resource: ../../scripts/run_pipeline.py
    title: Pipeline runner
---

# Prerequisites

* Python 3.12 with [uv](https://docs.astral.sh/uv/); run `uv sync` once. On Windows use `uv run python`, not a
  bare `python` (that is the Microsoft Store stub).
* A Google Cloud service account that can create datasets and run queries in the BigQuery project, with
  `GOOGLE_APPLICATION_CREDENTIALS` pointing at its key. Keep keys in `.secrets/` (gitignored). The dbt profile
  (`dbt/profiles.yml`) targets project `mem-311` and reads the key from that variable ([D20](../decisions/D20-tooling.md)).

# Steps

```bash
uv run python scripts/run_pipeline.py --full          # first run, then weekly: full snapshot (detects deletions)
uv run python scripts/run_pipeline.py                 # daily: incremental extract (48 h lookback) + dbt build
uv run python scripts/run_pipeline.py --skip-extract  # rebuild models only
```

The runner runs these stages and stops at the first failure:[^runner]

1. **extract**: [`ingestion/extract_311.py`](../../ingestion/extract_311.py) appends a batch to
   [`raw.memphis_311_requests`](../tables/raw/memphis_311_requests.md) and records it in
   [`raw.ingestion_batches`](../tables/raw/ingestion_batches.md) ([D06](../decisions/D06-append-only-raw-table.md), [D07](../decisions/D07-incremental-and-full-snapshots.md)).
2. **dbt build**: `dbt deps` and `dbt build` (models, seed and tests).
3. **dbt docs**: `dbt docs generate` writes the manifest and catalog.
4. **knowledge bundle**: [`scripts/build_knowledge.py`](../../scripts/build_knowledge.py) regenerates
   [tables](../tables/index.md), the validation SQL and the index files.

Every run, successful or not, writes `status/status.json` ([D31](../decisions/D31-tracker-status-file.md)). A full extraction takes about two minutes;
`dbt build` a few minutes.

# After a run

* Commit regenerated `docs/tables/` if schemas or descriptions changed (row counts change every run).
* Refresh Power BI ([Build the Power BI dashboard](build-the-power-bi-dashboard.md), section 6).
* If a new request type appeared, the `assert_all_request_types_mapped` test warns: follow
  [Map a new request type](map-a-new-request-type.md).

[^runner]: Pipeline runner
