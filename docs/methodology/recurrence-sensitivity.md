---
type: Methodology
title: Recurrence sensitivity (Phase E)
description: The 90-day recurrence rate under every combination of location rule, match level and window; the headline sits at the strict end of the grid.
tags: [recurrence, sensitivity]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
  - id: sensitivity-mart
    resource: ../tables/analytics/agg_recurrence_sensitivity.md
    title: agg_recurrence_sensitivity, data through 2026-09-22
---

[`agg_recurrence_sensitivity`](../tables/analytics/agg_recurrence_sensitivity.md) recomputes the rate for
every combination of rule, level and window. The 90-day results for all condition reports:[^sensitivity-mart]

| Location rule | Request type | **Category** | Family |
|---|---:|---:|---:|
| Same address only | 16.7% | 20.9% | 24.1% |
| Address or within 25 m | 19.7% | 25.2% | 30.0% |
| Address or within 50 m | 25.2% | 33.9% | 42.4% |
| Address or within 100 m | 38.3% | 52.6% | 65.3% |
| **Primary (hybrid)** | — | **22.1%** | — |

At the category level the rate is fairly stable at the strict end of the grid: 21–25% for same address or
25 m. It more than doubles at 100 m, where the match starts to capture neighbouring properties and busy
corridors. The headline sits deliberately at the strict end ([D22](../decisions/D22-primary-recurrence-definition.md)). A dbt test
([`assert_sensitivity_is_monotonic`](../../dbt/tests/assert_sensitivity_is_monotonic.sql)) checks that a
wider radius or a broader match level never finds fewer recurrences.

On the dashboard this grid is the definition-sensitivity matrix on
[Service Durability](../dashboard/service-durability.md).

[^sensitivity-mart]: agg_recurrence_sensitivity, data through 2026-09-22
