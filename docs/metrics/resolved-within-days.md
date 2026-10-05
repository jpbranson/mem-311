---
type: Metric
title: Resolved within 7 and 30 days
description: Share of requests reported in a period that closed within 7 or 30 calendar days, over cohorts old enough to have been observed that long.
tags: [responsiveness]
status: stable
dax_measures: ["% Resolved Within 7 Days", "% Resolved Within 30 Days"]
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

Numerator: requests with `days_open_to_close` ≤ N. Denominator: all requests reported in the period. Both
leave out requests reported less than N days before the data cut-off
([`meta_data_as_of`](../tables/analytics/meta_data_as_of.md)), so the latest weeks are not understated ([D26](../decisions/D26-responsiveness-counting-rules.md)).
The monthly mart stores the same shares as `pct_resolved_within_7d/30d`, null until the cohort is mature.

# Sanctioned computation

Sanctioned SQL: [Resolved within 7 and 30 days](../computations/resolved-within-days.md).

# Value

All dates and categories, data through 2026-09-22: 46.7% within 7 days, 75.6% within 30 days.[^build-guide]

See also [Responsiveness](../methodology/responsiveness.md).

[^build-guide]: Power BI build guide, section 5
