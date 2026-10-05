---
type: Decision
id: D32
title: "D32 — An empty full extraction fails"
description: "A full extraction that returns 0 rows fails instead of recording an empty snapshot"
tags: [ingestion]
area: Ingestion
status: stable
logged_at: 2026-09-27T20:56:38Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-27T20:56:38Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
---

**Decision.** A full extraction that returns 0 rows raises, so its batch is recorded as `failed` and the run
stops at the extract. An incremental batch with 0 rows is still a success ([D31](D31-tracker-status-file.md)).

**Evidence.** If the API ever answered the Sunday count with 0 matches, the count check would pass (0 of 0)
and the empty batch would be recorded as a success. `stg_311_requests` treats the newest successful full batch
as the snapshot of live requests ([D06](D06-append-only-raw-table.md), [D07](D07-incremental-and-full-snapshots.md)), so staging would hold only rows from later incremental batches
until the next successful full run. The source has held over 400,000 requests, so an empty full layer means
an outage or a permission change, not a real state of the data.
