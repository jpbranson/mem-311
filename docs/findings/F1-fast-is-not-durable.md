---
type: Finding
id: F1
title: "F1 — Closing fast and staying fixed are different things"
description: Sewer backups close in half a day but 21% return within 90 days; across categories speed barely predicts durability (rank correlation −0.25).
tags: [responsiveness, recurrence]
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
---

Median resolution time and 90-day recurrence, by service category (categories with ≥2,000 eligible
closures):[^service-recurrence]

| Category | Median resolution | 90-day recurrence |
|---|---:|---:|
| Sewer | 0.5 days | 21.3% |
| Street Cleaning | 1.4 days | 23.4% |
| Potholes & Pavement | 1.6 days | 15.7% |
| Trees | 1.7 days | 8.0% |
| Dead Animal Collection | 2.6 days | 8.6% |
| Drainage & Flooding | 3.1 days | 13.8% |
| Missed Collection | 6.4 days | 31.3% |
| Illegal Dumping & Litter | 6.8 days | 13.1% |
| Cart Repair & Replacement | 8.4 days | 15.0% |
| Traffic Signs, Signals & Markings | 13.8 days | 23.0% |
| Property Code Violations | 16.2 days | 18.6% |
| Vehicle Violations | 17.2 days | 15.2% |
| Weeds & Overgrowth | 19.4 days | 16.7% |
| Cave-ins & Street Sinking | 23.5 days | 9.4% |

Sewer backups are closed in about half a day, the fastest of any category. Yet one in five returns to the same
address within 90 days, a median of 17 days after closure. Street cleaning behaves the same way. Trees and
dead-animal pickups are about as fast, but only 8–9% of them return. Cave-ins take more than three weeks to close and
recur least of all.

Across the 18 categories with ≥500 eligible closures, the rank correlation between speed and durability is
−0.25. Faster categories recur slightly *more*, and speed alone tells very little about whether a problem
stays fixed. A dashboard that shows only resolution time would rank sewer as the best-performing service.

Shown on [Service Durability](../dashboard/service-durability.md) as the speed vs durability table and scatter.

[^service-recurrence]: agg_service_recurrence, data through 2026-09-22
