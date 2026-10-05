---
type: Decision
id: D25
title: "D25 — Backlog reconstruction and burn-in"
description: "Reconstruct the daily backlog from open/close dates; flag a 181-day burn-in after go-live"
tags: [backlog]
area: Backlog
status: stable
logged_at: 2026-09-23T12:41:15Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (406,902 records)
    title: Evidence counts, unless the entry states otherwise
---

**Decision.** The source publishes no status history. A request is therefore assumed open at the end of every
local day from its opened date to the day before its final closure (or to the data cut-off). Imputed closures
([D11](D11-open-closed-status-and-imputed-closure.md)) are used as exit dates. Backlog age = snapshot date − opened date. Snapshots before
**2024-04-15** (181 days after the 2023-10-16 go-live) are flagged `is_burn_in_period`. Before that date the
>180-day band cannot yet contain anything and the total is still filling up from zero.

**Consequence.** Reopen/close cycles are invisible: a request closed, reopened and closed again is treated as
open for the whole span. A dbt test (`assert_backlog_conserves_flow`) checks that the day-over-day change in
open requests equals opened − closed.
