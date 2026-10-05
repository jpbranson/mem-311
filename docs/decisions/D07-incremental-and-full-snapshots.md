---
type: Decision
id: D07
title: "D07 — Incremental strategy: watermark + periodic full snapshot"
description: "Full snapshot plus watermark-based incremental; deletes inferred from snapshots"
tags: [warehouse]
area: Warehouse
status: stable
logged_at: 2026-09-23T07:47:49Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T21:58:00Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (406,902 records)
    title: Evidence counts, unless the entry states otherwise
  - resource: ../../.github/workflows/refresh.yml
---

**Decision.** `--mode incremental` pulls `last_edited_date >= high_water_mark − 48h`. `--mode full`
re-snapshots everything. Staging treats a record as live if it appears in the latest full snapshot, or in any
incremental batch loaded after that snapshot.

**Evidence.** Records are edited long after creation. 260,510 of 373,272 closed records were edited more than
a day after closure. There were city-wide bulk edits: over 24k records were touched in single minutes on
2025-09-22, 2025-09-23 and 2025-09-30. Deletions cannot be seen by a watermark query. Full extraction takes
about 2 minutes, so a weekly full snapshot is cheap.

**Schedule.** `.github/workflows/refresh.yml` runs incremental Monday to Saturday and full on Sunday, at
11:00 UTC, each followed by `dbt build`. The 48 h lookback comfortably covers a missed day.
