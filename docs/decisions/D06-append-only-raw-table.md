---
type: Decision
id: D06
title: "D06 — Warehouse: append-only raw table; staging picks latest version"
description: "Append-only raw table with batch metadata; dedupe in staging"
tags: [warehouse]
area: Warehouse
status: stable
logged_at: 2026-09-23T07:47:49Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T07:47:49Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (406,902 records)
    title: Evidence counts, unless the entry states otherwise
---

**Decision.** `raw.memphis_311_requests` is append-only, partitioned on `_ingested_at` and clustered on
`OBJECTID`. Each run adds `_batch_id`, `_ingested_at`, `_source` and `_extract_mode`. `raw.ingestion_batches`
records expected/extracted/loaded counts and the `last_edited_date` high-water mark. Staging takes the latest
row per OBJECTID.

**Alternatives.** MERGE into a current-state raw table would be smaller, but it loses the history of edits,
which [D07](D07-incremental-and-full-snapshots.md)'s deletion logic and any audit of status changes need. At ~400k rows (~250 MB) per full snapshot,
storage cost is negligible.
