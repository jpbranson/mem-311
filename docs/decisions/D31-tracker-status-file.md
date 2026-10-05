---
type: Decision
id: D31
title: "D31 — A status file for the project tracker"
description: "Every refresh publishes a status file for the project tracker: fail, warn when the source is stale, ok otherwise"
tags: [monitoring]
area: Monitoring
status: stable
logged_at: 2026-09-27T20:56:38Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-27T20:56:38Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
---

**Decision.** Every refresh writes `status/status.json` in the status contract of the project tracker
(github-project-tracker, DESIGN.md §2). The workflow's `publish-status` job uploads it as `status.json` on the
fixed-tag prerelease `status`, a stable URL. The status is:
* `fail` when a stage fails. `detail` names the stage, plus the extract's message when the extract failed.
* `warn` when the run succeeded but the source's newest edit (`max_last_edited`) is more than two days old.
* `ok` otherwise. A 0-row incremental batch is still `ok` (decided 2026-09-27).

A successful run's `last_success_at` is when it finished, and the tracker judges its age against a daily
cadence, so a refresh that stops running reads as stale.

**Evidence.** `raw.ingestion_batches` records `success` for 0-row and stale-upstream extractions, and covers
the extract only. The `run_results.json` artifact comes from `dbt docs generate`, so it never holds test
results. Neither shows a bad day. Only `publish-status` has `contents: write`; it checks out no code, so the
pipeline and its dbt packages keep read-only access.
