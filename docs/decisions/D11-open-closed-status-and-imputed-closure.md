---
type: Decision
id: D11
title: "D11 — Open/closed status and imputed closure time"
description: "Status is authoritative for open/closed; closure time falls back through RESOLVED_DATE then last_edited_date"
tags: [status]
area: Status
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

**Decision.**
* `Closed`, `closed` and `Resolved` → closed. `Open`, `In Progress`, `In Progress – Part of Ongoing Case`,
  `Back to Department`, `Back to MCSC` and `Pending Litigation` → open. A null status is closed if a close
  date exists, otherwise open.
* `closed_at = coalesce(Closed_Date, RESOLVED_DATE)` for closed records. If both are missing,
  `last_edited_date` is used as an **imputed** closure time (`closed_at_is_imputed = true`).
* Imputed closures count for backlog exit but are **excluded from resolution-time metrics**.
* A record whose status is open is open, even if it carries a `Closed_Date` (it was reopened).

**Evidence.** 16,883 `Closed` records have no `Closed_Date` (4.1%). They cluster in 2025-08/09 and
2025-11 through 2026-01, and again in 2026-04/05, mostly Solid Waste. Many of the Dec-2025/Jan-2026 records
also lack `DEPARTMENT`, which suggests a system change. Their `last_edited_date` values spread over days and
weeks after reporting, consistent with real closure edits. The exception is 994 closed in one sweep on
2025-09-19. `DAYS_OLD` is null on 92% of closed records and inconsistent with close dates where present, so it
is unused. 287 `Open` and ~3,700 in-progress records carry a `Closed_Date`, consistent with reopening.

**Alternatives.** Dropping the 16,883 records from the backlog would leave them open forever and inflate the
old backlog by ~17k. Keeping them open was rejected for the same reason.
