---
type: Finding
id: F5
title: "F5 — Recurrence varies more within the city than between districts"
description: Council districts differ by 5 points in 90-day recurrence, while Census tracts with 500+ eligible closures range from 12.8% to 35.9%.
tags: [geography, recurrence]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: findings
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/findings.md
    title: Findings as one file, before the OKF conversion
  - id: geography-mart
    resource: ../tables/analytics/agg_geography_performance.md
    title: agg_geography_performance, data through 2026-09-22
---

| Council district | Requests | Median resolution | 90-day recurrence | Open > 90 days |
|---|---:|---:|---:|---:|
| 1 | 40,618 | 5.3 days | 24.4% | 48.5% |
| 2 | 47,109 | 6.5 days | 23.3% | 37.5% |
| 3 | 45,863 | 6.5 days | 21.9% | 38.0% |
| 4 | 64,911 | 7.6 days | 20.1% | 40.3% |
| 5 | 55,387 | 6.8 days | 21.5% | 41.3% |
| 6 | 63,821 | 9.0 days | 19.6% | 40.2% |
| 7 | 52,950 | 4.5 days | 24.3% | 45.8% |

The district pattern repeats [F1](F1-fast-is-not-durable.md). Districts 7 and 1 have the two fastest median
closures and the two highest recurrence rates. District 6 is the slowest and recurs least. Council districts
differ by only 5 points in recurrence, but the 162 Census tracts with ≥500 eligible closures range from
**12.8% to 35.9%**.[^geography-mart] Tract-level maps are therefore where durability differences become
visible.

Volume differences between areas are not interpreted as differences in need. 311 volume depends on who
reports (see [Limitations](../methodology/limitations.md)).

[^geography-mart]: agg_geography_performance, data through 2026-09-22
