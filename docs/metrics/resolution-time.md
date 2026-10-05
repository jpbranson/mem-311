---
type: Metric
title: Resolution time
description: Median and 90th-percentile days from report to closure, for requests closed in the period, excluding imputed, invalid and mass closures.
tags: [responsiveness]
status: stable
dax_measures: ["Median Resolution (days)", "P90 Resolution (days)"]
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

`resolution_days` on [`fact_service_requests`](../tables/analytics/fact_service_requests.md) = closed_at −
opened_at in local time ([D10](../decisions/D10-time-zones-and-date-only-timestamps.md)), in days. It is blank when the closure time is imputed ([D11](../decisions/D11-open-closed-status-and-imputed-closure.md)), negative ([D12](../decisions/D12-negative-resolution-times.md)) or
part of the 2025-09-22 mass closure ([D28](../decisions/D28-mass-closure-2025-09-22.md)), so the median and P90 skip those rows.

Both measures describe requests **closed** in the period ([D26](../decisions/D26-responsiveness-counting-rules.md)): DAX filters through the inactive `closed_date`
relationship. Measuring by opening month would make recent months look faster than they are.

# Sanctioned computation

Sanctioned SQL: [Volume and resolution time](../computations/volume-and-resolution.md).

# Value

All dates and categories, data through 2026-09-22: median 6.6 days, P90 46.6 days.[^build-guide]

See also [Responsiveness](../methodology/responsiveness.md).

[^build-guide]: Power BI build guide, section 5
