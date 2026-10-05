---
type: Decision
id: D05
title: "D05 — Ingestion: keyset pagination on OBJECTID"
description: "Keyset pagination on OBJECTID"
tags: [ingestion]
area: Ingestion
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

**Decision.** Page with `OBJECTID > last ORDER BY OBJECTID`, 3,000 per page (the service `maxRecordCount`),
rather than `resultOffset`.

**Reason.** Offset paging over a table that is being edited during the run can skip or duplicate records.
Keyset paging cannot. The run also fails if an OBJECTID repeats across pages, or if the extracted count falls
below the server's `returnCountOnly`. For full runs it also fails if the count exceeds that value by more than
1%.
