---
type: Playbook
title: Scheduled refresh and its status file
description: The daily GitHub Actions refresh - schedule, secret, the status file the project tracker reads, and how to triage a failed or stale run.
tags: [pipeline, operations, monitoring]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: workflow
    resource: ../../.github/workflows/refresh.yml
    title: Refresh workflow
  - id: runner
    resource: ../../scripts/run_pipeline.py
    title: Pipeline runner (status document)
---

# Schedule

[`.github/workflows/refresh.yml`](../../.github/workflows/refresh.yml) runs
[the pipeline](run-the-pipeline.md) at 11:00 UTC (06:00 CDT / 05:00 CST): incremental Monday to Saturday, a
full snapshot on Sunday ([D07](../decisions/D07-incremental-and-full-snapshots.md)). It can be started by hand from the Actions tab with mode `incremental`, `full`
or `skip-extract`. Runs never overlap (concurrency group `refresh`).[^workflow]

The repo secret `GCP_SA_KEY` holds the JSON key of a service account with BigQuery Data Editor and Job User on
`mem-311`. The refresh job has read-only repository access.

# Status file

Every run writes `status/status.json` in the project tracker's status contract ([D31](../decisions/D31-tracker-status-file.md)):[^runner]

| Status | When |
|---|---|
| `fail` | A stage failed; `detail` names it (and the extract's message) |
| `warn` | The run succeeded but the source's newest edit is more than two days old |
| `ok` | Otherwise, including a 0-row incremental batch |

The `publish-status` job, the only one with `contents: write`, uploads it as `status.json` on the fixed-tag
prerelease `status`. If the refresh ended before writing a status, it publishes a `fail` instead.

# Triage

1. Read `detail` in the published status to find the failed stage.
2. Download the `refresh-logs-<run id>` artifact (14 days): extractor logs, dbt logs and `run_results.json`.
3. **extract** failures: the API is down, a retained field disappeared, the count check failed, or a full
   extraction returned 0 rows ([D32](../decisions/D32-empty-full-extract-fails.md)). Re-run from the Actions tab once the source is back.
4. **dbt build** failures: a test failed; run `dbt build` locally against the same data.
5. `warn`: the city has not edited any record for two days, so check the source before trusting freshness.

Power BI scheduled refresh should run at 12:00 UTC or later, after the pipeline (usually done within 5
minutes).

[^workflow]: Refresh workflow
[^runner]: Pipeline runner (status document)
