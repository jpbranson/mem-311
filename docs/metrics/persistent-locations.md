---
type: Metric
title: Persistent locations
description: Counts of Persistent and Chronic locations, recurrence cycles, and the share of cycles that happen at persistent locations.
tags: [persistence]
status: stable
dax_measures: ["Persistent Locations", "Chronic Locations", "Locations With Repeat Requests", "Recurrence Cycles", "% of Recurrence Cycles at Persistent Locations", "Unresolved at Location"]
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

Rows of [`agg_persistent_locations`](../tables/analytics/agg_persistent_locations.md): locations with 3+
condition reports, tiered Chronic, Persistent or Repeat ([D27](../decisions/D27-persistent-location-tiers.md)).

* **Persistent Locations**: `is_persistent` (Chronic or Persistent). **Chronic Locations**: tier `1. Chronic`.
* **Locations With Repeat Requests**: all rows. **Recurrence Cycles**: sum of `recurrence_cycles`, a closure
  followed within 90 days by a primary-definition recurrence.
* **% of Recurrence Cycles at Persistent Locations**: cycles at persistent locations ÷ all 90-day recurrences,
  ignoring date, category and location filters.
* **Unresolved at Location**: open requests in context, for the selected location's history.

# Sanctioned computation

Sanctioned SQL: [Persistent and chronic location counts](../computations/persistent-location-counts.md).

# Value

Data through 2026-09-22: 8,630 persistent, of which 1,972 chronic.[^build-guide]

Method: [Persistent locations](../methodology/persistent-locations.md). Shown on
[Persistent Locations](../dashboard/persistent-locations.md).

[^build-guide]: Power BI build guide, section 5
