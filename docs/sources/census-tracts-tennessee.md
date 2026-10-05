---
type: BigQuery Table
title: Census tracts, Tennessee (BigQuery public data)
description: Census tract polygons used to assign each request to one of 221 Shelby County tracts and to draw the tract map.
resource: https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=geo_census_tracts&t=census_tracts_tennessee
tags: [source, geography, public-data]
status: stable
table_id: bigquery-public-data.geo_census_tracts.census_tracts_tennessee
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
---

Filtered to Shelby County (`county_fips_code = '157'`, 221 tracts). Used three ways ([D18](../decisions/D18-geography.md)):

* Point-in-polygon tract assignment in
  [`int_request_locations`](../tables/intermediate/int_request_locations.md).
* [`dim_census_tract`](../tables/analytics/dim_census_tract.md): simplified WKT geometry and centroids.
* [`scripts/export_tract_shapes.py`](../../scripts/export_tract_shapes.py) writes
  `powerbi/shelby_tracts.geojson` and `shelby_tracts.topo.json` for the Shape Map visual (key `GEOID`, which
  matches `fact_service_requests.census_tract_geoid`).

Tracts give geography but not need: no per-capita rates are computed ([Geography](../methodology/geography.md)).
