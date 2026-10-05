---
type: Decision
id: D14
title: "D14 — Administrative request types are not recurrence-eligible"
description: "Flag administrative request types as not eligible for recurrence"
tags: [categories]
area: Categories
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

**Decision.** `is_condition_report = false` for request types that are transactions, not reports of a
problem at a place. These are *Cart & Account Requests*, *Traffic Engineering Requests* (new signs, speed-hump
requests), *Damage Claims*, *General / Miscellaneous*, Drain Maintenance "PREVENTATIVE MAINTENANCE" and
"SITE CHECK" (proactive work orders), and "Bulk Trash Validation". These requests appear in responsiveness and
backlog metrics but never as the original or the recurring request in recurrence analysis.

**Reason.** A resident who applies for a second cart or a fee waiver has not had a problem "recur". Counting
these would inflate Solid Waste recurrence.
