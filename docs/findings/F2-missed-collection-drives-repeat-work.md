---
type: Finding
id: F2
title: "F2 — Missed collection is the single largest source of repeat work"
description: Missed garbage, recycling and bulk pickups produce 58% of 90-day recurrences and 73% of chronic locations; without them the recurrence rate falls from 22.1% to 15.7%.
tags: [recurrence, persistence, solid-waste]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: findings
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/findings.md
    title: Findings as one file, before the OKF conversion
  - id: service-recurrence
    resource: ../tables/analytics/agg_service_recurrence.md
    title: agg_service_recurrence, data through 2026-09-22
  - id: persistent-mart
    resource: ../tables/analytics/agg_persistent_locations.md
    title: agg_persistent_locations, data through 2026-09-22
---

*Missed Collection* (missed garbage, recycling and bulk-trash pickups) accounts for:

* **41%** of closures eligible for the 90-day rate, and **58%** of 90-day recurrences[^service-recurrence]
* a **31.3%** 90-day recurrence rate, the highest of any major category
* **73%** of Chronic locations (1,449 of 1,972) and **67%** of all Persistent-or-Chronic locations[^persistent-mart]
* 8 of the 10 top-ranked persistent locations. The top address had 89 requests and 74 recurrence cycles in
  three years.

Without it, the system-wide 90-day recurrence rate falls from 22.1% to 15.7%.

The category combines three collection streams, so some "recurrences" are a different stream missed at the
same household ([D30](../decisions/D30-recurrence-match-validation.md)). Even so, the pattern is the clearest case of a service that is closed within a week and
comes back at the same address.

[^service-recurrence]: agg_service_recurrence, data through 2026-09-22
[^persistent-mart]: agg_persistent_locations, data through 2026-09-22
