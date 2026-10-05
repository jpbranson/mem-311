---
type: Decision
id: D27
title: "D27 — Persistent-location tiers"
description: "Chronic / Persistent / Repeat tiers from request count, active months and recurrence cycles"
tags: [persistence]
area: Persistence
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

**Decision.** Among locations with 3+ condition reports:
* **Chronic**: ≥10 condition reports, active in ≥6 distinct months, ≥4 recurrence cycles
* **Persistent**: ≥5 condition reports, ≥3 active months, ≥2 recurrence cycles
* **Repeat**: everything else with 3+ reports

A recurrence cycle is a closure at the location followed within 90 days by a primary-definition recurrence.
`is_persistent` covers Chronic and Persistent.

**Evidence.** 44,818 locations have 3+ condition reports: 1,972 Chronic, 6,658 Persistent, 35,729 Repeat
and 459 excluded as spatially inconsistent. The thresholds separate "busy address" from "problem keeps
coming back". A location with 20 unrelated one-off reports and no recurrence cycles stays in Repeat.
