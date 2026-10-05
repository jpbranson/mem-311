---
type: Metric
title: Backlog age
description: Median and 90th-percentile age in days of the requests open on the snapshot date, precomputed per category and for all categories.
tags: [backlog]
status: stable
dax_measures: ["Median Backlog Age (days)", "P90 Backlog Age (days)"]
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

Age = snapshot date − opened date for each open request ([D25](../decisions/D25-backlog-reconstruction.md)). Medians cannot be added up across categories,
so they are precomputed: `median_age_days` / `p90_age_days` on
[`agg_backlog_daily`](../tables/analytics/agg_backlog_daily.md) when exactly one category is in context, and on
[`agg_backlog_daily_total`](../tables/analytics/agg_backlog_daily_total.md) when no category is filtered out.
Any other multi-category selection returns blank, by design.

# Sanctioned computation

Sanctioned SQL: [Backlog at the data cut-off](../computations/backlog-snapshot.md).

# Value

All categories, data through 2026-09-22: median 75 days (±1; approximate quantile).[^build-guide]

See also [Open backlog](open-backlog.md).

[^build-guide]: Power BI build guide, section 5
