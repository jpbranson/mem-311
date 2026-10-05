---
type: Metric
title: Requests opened and closed
description: Requests reported in a period, requests closed in a period by closure date, and the net change between them.
tags: [responsiveness]
status: stable
dax_measures: ["Requests Opened", "Requests Closed", "Net Change (Opened - Closed)"]
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

* **Requests Opened**: rows of [`fact_service_requests`](../tables/analytics/fact_service_requests.md) whose
  local report date (`opened_date`) is in the period.
* **Requests Closed**: closed requests whose `closed_date` is in the period, excluding closures dated before the
  report ([D12](../decisions/D12-negative-resolution-times.md)). Counted in the month of closure, not of opening ([D26](../decisions/D26-responsiveness-counting-rules.md)). In DAX this uses the inactive
  `closed_date` relationship through `USERELATIONSHIP`.
* **Net Change (Opened - Closed)**: positive when the backlog grew.

# Sanctioned computation

Sanctioned SQL: [Volume and resolution time](../computations/volume-and-resolution.md).

# Value

All dates and categories, data through 2026-09-22: 405,398 opened, 383,369 closed.[^build-guide]

See also [Responsiveness](../methodology/responsiveness.md) and the
[System Health](../dashboard/system-health.md) page.

[^build-guide]: Power BI build guide, section 5
