---
type: Metric
title: Open backlog
description: Requests open at the end of a day, split by age band, with shares older than 30 and 90 days and year-over-year change.
tags: [backlog]
status: stable
dax_measures: ["Backlog Snapshot Date", "Open Requests (Backlog)", "Current Backlog", "Backlog Over 30 Days", "Backlog Over 90 Days", "Backlog Over 180 Days", "% Backlog Over 30 Days", "% Backlog Over 90 Days", "Open Requests by Age Band", "Backlog YoY Change %", "Backlog Over 90 Days YoY Change %"]
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: dax
    resource: ../../powerbi/measures.dax
    title: DAX measures
  - id: build-guide
    resource: ../../powerbi/build_guide.md
    title: Power BI build guide, section 5 (expected values, data through 2026-09-22)
---

# Definition

The backlog is a **stock**, reconstructed from open and close dates ([D25](../decisions/D25-backlog-reconstruction.md)). Every measure reads one day,
`[Backlog Snapshot Date]`: the last visible date, capped at the data cut-off. On a monthly axis that is the
month-end backlog.

* **Open Requests (Backlog)**: `open_requests` of [`agg_backlog_daily`](../tables/analytics/agg_backlog_daily.md)
  on the snapshot date. **Current Backlog** ignores the date slicer and always reads the latest complete day.
* **Backlog Over 30 / 90 / 180 Days** add the age-band columns above the threshold; the **%** measures divide by
  open requests. Age = snapshot date − opened date (bands in [Backlog reconstruction](../methodology/backlog.md)).
* **Open Requests by Age Band** reads [`agg_backlog_age`](../tables/analytics/agg_backlog_age.md) for the
  stacked age chart.
* **YoY Change %** compares the snapshot date with the same date 12 months earlier; the over-90-day variant asks
  whether old backlog grows faster than the total.

Dates before 2024-04-15 are burn-in (the > 180-day band cannot fill yet) and the 2025-09-22 mass closure is a
real exit ([D28](../decisions/D28-mass-closure-2025-09-22.md)); annotate comparisons across either.

# Sanctioned computation

Sanctioned SQL: [Backlog at the data cut-off](../computations/backlog-snapshot.md).

# Value

Data through 2026-09-22: 21,181 open; 72.8% older than 30 days; 43.8% older than 90 days.[^build-guide]

Shown on [System Health](../dashboard/system-health.md) and [Backlog Aging](../dashboard/backlog-aging.md).

[^build-guide]: Power BI build guide, section 5
