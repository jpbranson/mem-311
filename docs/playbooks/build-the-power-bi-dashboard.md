---
type: Playbook
title: Build the Power BI dashboard
description: Assemble the four-page report in Power BI Desktop from the analytics marts, load the DAX measures and validate every headline card against SQL.
resource: ../../powerbi/build_guide.md
tags: [power-bi, dashboard]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: build-guide
    resource: ../../powerbi/build_guide.md
    title: Power BI build guide (step-by-step, with implementation notes)
---

The step-by-step guide is [`powerbi/build_guide.md`](../../powerbi/build_guide.md); it sits next to the files it
uses and is the authority for every click.[^build-guide] This concept is the map. Allow about 3–4 hours.

# Files

| File | Purpose |
|---|---|
| [`measures.dax`](../../powerbi/measures.dax) | All DAX measures as a DAX-query-view script with a validation `EVALUATE` |
| [`set_measure_properties.csx`](../../powerbi/set_measure_properties.csx) | Optional Tabular Editor script: format strings and display folders |
| [`mem311_theme.json`](../../powerbi/mem311_theme.json) | Report theme (colour-blind-validated palette) |
| [`shelby_tracts.topo.json`](../../powerbi/shelby_tracts.topo.json) | Census tract shapes for the Shape Map (key `GEOID`) |
| [`validation_queries.sql`](../../powerbi/validation_queries.sql) | Generated from the [Attested Computations](../computations/index.md) |

# Steps

1. **Connect and load**: Google BigQuery connector, project `mem-311`, dataset `analytics`, Import mode. The
   guide lists the 14 tables and which columns to drop.
2. **Model**: relationships (the `closed_date` relationship is inactive, used through `USERELATIONSHIP`;
   `agg_persistent_locations` ↔ `dim_location` is one-to-one, both directions), sort-by columns, data
   categories, hidden keys.
3. **Measures and theme**: create `_Measures`, run `measures.dax` in DAX query view, compare the `EVALUATE` row
   with the expected values, then add the measures; apply the theme.
4. **Report conventions**: 1280 × 720 canvas, header with `[Data Through Label]`, synced date and category
   slicers, fixed colour roles, no dual-axis charts, a footnote per page.
5. **Pages**: [System Health](../dashboard/system-health.md), [Backlog Aging](../dashboard/backlog-aging.md),
   [Service Durability](../dashboard/service-durability.md),
   [Persistent Locations](../dashboard/persistent-locations.md). Page 5 is not built ([D15](../decisions/D15-pothole-analysis-omitted.md)).
6. **Validate**: run each [computation](../computations/index.md) and compare with the cards; then spot-check
   *Potholes & Pavement* against `agg_service_recurrence` (90-day rate 15.7%, median 1.6 days at data through
   2026-09-22).
7. **Refresh**: Power BI Desktop Refresh, or a scheduled refresh at 12:00 UTC or later
   ([Scheduled refresh](scheduled-refresh.md)). The service-account credential needs no gateway.

Never commit a `.pbix` next to the service-account key; Power BI does not store the key in the file.

[^build-guide]: Power BI build guide
