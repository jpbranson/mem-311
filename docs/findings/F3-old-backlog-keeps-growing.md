---
type: Finding
id: F3
title: "F3 — Old backlog keeps accumulating whatever the total does"
description: After the 2025-09-22 mass closure cut the backlog by two thirds, requests older than 180 days grew by about 190 a month whether the total fell or rose.
tags: [backlog]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: findings
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/findings.md
    title: Findings as one file, before the OKF conversion
  - id: backlog-total
    resource: ../tables/analytics/agg_backlog_daily_total.md
    title: agg_backlog_daily_total, data through 2026-09-22
  - id: monthly-performance
    resource: ../tables/analytics/agg_monthly_service_performance.md
    title: agg_monthly_service_performance, data through 2026-09-22
---

The total backlog has swung widely. It grew from 14,751 open requests (2024-08-01) to 35,860 (2025-09-01).
On 2025-09-22 the city closed 24,632 mostly aged requests in a single day ([D28](../decisions/D28-mass-closure-2025-09-22.md)), which brought the total down
to 10,438 on 2025-10-01. It has since doubled again, to 21,181.

The oldest band moved differently:[^backlog-total]

| Date | Total open | Open > 180 days |
|---|---:|---:|
| 2024-08-01 | 14,751 | 886 |
| 2025-09-01 | 35,860 | 14,343 |
| 2025-10-01 | 10,438 | 2,704 |
| 2026-03-01 | 8,644 | 4,107 |
| 2026-09-22 | 21,181 | 4,994 |

Before the mass closure, requests older than 180 days grew sixteen-fold in 13 months, to 40% of the backlog.
After it, the > 180-day band rose in ten of the eleven months to 2026-09-01, by about 190 requests a month.
That happened while the total first fell (to 8,644 in March 2026) and then rose. The spring 2026 dip came
entirely from the younger bands. At that point 61% of what remained was more than 90 days old.

Excluding the mass closure, the city closed fewer requests than it received in both of the last two years:
123,607 closed against 141,257 opened in Sep 2024–Aug 2025, and about 138,000 against 148,420 from
September 2025 to the cut-off.[^monthly-performance] The administrative closure reset the count. It did not
change the rate at which old work accumulates.

Shown on [Backlog Aging](../dashboard/backlog-aging.md).

[^backlog-total]: agg_backlog_daily_total, data through 2026-09-22
[^monthly-performance]: agg_monthly_service_performance, data through 2026-09-22
