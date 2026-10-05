---
type: Methodology
title: Responsiveness
description: How resolution time and the share resolved within 7 and 30 days are defined, and which requests each counts.
tags: [responsiveness]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
---

* **Resolution time** = closed_at − opened_at, in local time (America/Chicago, [D10](../decisions/D10-time-zones-and-date-only-timestamps.md)). It is null when the
  closure time is imputed ([D11](../decisions/D11-open-closed-status-and-imputed-closure.md)), negative ([D12](../decisions/D12-negative-resolution-times.md)) or part of the 2025-09-22 mass closure ([D28](../decisions/D28-mass-closure-2025-09-22.md)).
* **Median / P90 resolution** are reported for requests *closed* in a period ([D26](../decisions/D26-responsiveness-counting-rules.md)).
* **% resolved within 7 / 30 days** are reported for the cohort *opened* in a period, and only once the whole
  cohort has been observable that long ([D26](../decisions/D26-responsiveness-counting-rules.md)).
* About 17% of requests (mostly SeeClickFix intake) have a date-only opened timestamp, so hour-level
  resolution is overstated by up to a day for them. All reporting is in days, and medians are robust to this
  ([D10](../decisions/D10-time-zones-and-date-only-timestamps.md)).

The measures built on these definitions are [Resolution time](../metrics/resolution-time.md),
[Resolved within 7 and 30 days](../metrics/resolved-within-days.md) and
[Requests opened and closed](../metrics/request-volume.md). The monthly series is
[`agg_monthly_service_performance`](../tables/analytics/agg_monthly_service_performance.md).
