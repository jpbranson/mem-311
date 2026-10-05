---
type: Methodology
title: Geography
description: Census tract, council district and ZIP assignment, why no neighborhoods and no per-capita rates, and the minimum area size for comparisons.
tags: [geography]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
---

Requests are assigned to Census tracts by point-in-polygon (221 Shelby County tracts, from
[Census tracts](../sources/census-tracts-tennessee.md)), to council districts from the source field, and to ZIP
codes ([D18](../decisions/D18-geography.md)). No neighborhood geography is used, because no defensible boundary source is available.

Per-capita rates are **not** computed. 311 volume reflects who reports as well as what is broken, so volume is
not treated as a measure of need. Geographic comparisons use rates *within* reported requests: resolution time,
backlog age, and recurrence rate. Comparisons in the findings use only areas with ≥500 eligible originals,
to avoid small-sample noise (see [Durability varies within the city](../findings/F5-durability-varies-within-the-city.md)).

The mart is [`agg_geography_performance`](../tables/analytics/agg_geography_performance.md); tract shapes for
the dashboard map come from [`dim_census_tract`](../tables/analytics/dim_census_tract.md) and
[`scripts/export_tract_shapes.py`](../../scripts/export_tract_shapes.py).
