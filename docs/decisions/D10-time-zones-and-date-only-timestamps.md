---
type: Decision
id: D10
title: "D10 — Time zones and date-only reported timestamps"
description: "Convert timestamps to America/Chicago; treat midnight-UTC reported dates as date-only"
tags: [time]
area: Time
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

**Decision.** All timestamps are stored UTC in raw and converted to `America/Chicago` in staging. When
`REPORTED_DATE` is exactly 00:00:00 UTC it is treated as **date-only**: the local opened date is the UTC
calendar date, and the opened timestamp is local midnight of that date. These rows get
`opened_is_date_only = true`.

**Evidence.** 68,253 records (16.8%) have `REPORTED_DATE` at exactly midnight UTC; 67,795 of them are
SeeClickFix intake. For those, `created_date` falls 13–25 hours after `REPORTED_DATE` (deciles 812–1,500
minutes). That pattern fits a local calendar date stored as UTC midnight. A naive conversion would move them
to 18:00/19:00 on the *previous* local day.

**Consequence.** Hour-level resolution times for date-only requests are overstated by up to one day. The
dashboard's resolution metrics are reported in days, and medians are robust to this. `opened_is_date_only` is
carried to the fact table so hour-level analysis can exclude these rows.
