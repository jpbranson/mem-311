---
type: Decision
id: D26
title: "D26 — Responsiveness counting rules"
description: "Count events in the month they happen; resolution percentiles by closure month"
tags: [responsiveness]
area: Responsiveness
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

**Decision.** In the monthly mart, `requests_opened` counts the month of opening and `requests_closed` the month
of closure. Median and P90 resolution time describe requests **closed** in the month, using only recorded,
valid, non-mass closures. `pct_resolved_within_7d/30d` describe the **opening cohort** and stay null until the
month's last day is at least 7 or 30 days before the cut-off.

**Reason.** Measuring resolution time for requests *opened* in a month makes recent months look faster than
they are, because only the quickly closed requests have closed yet.
