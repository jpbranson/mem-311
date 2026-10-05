---
type: BigQuery Table
title: dim_census_tract
description: "Shelby County Census tracts (221) with simplified WKT geometry and centroid (D18)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=dim_census_tract
tags: [analytics, core]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/core/dim_census_tract.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.dim_census_tract
materialized: table
row_count: 221
---

Shelby County Census tracts (221) with simplified WKT geometry and centroid ([D18](../../decisions/D18-geography.md)).

# Schema

| Column | Type | Description |
|---|---|---|
| `census_tract_geoid` | STRING | 11-digit GEOID; primary key. |
| `tract_name` | STRING |  |
| `tract_label` | STRING | e.g. "Census Tract 12.01". |
| `land_area_km2` | FLOAT64 |  |
| `centroid_latitude` | FLOAT64 |  |
| `centroid_longitude` | FLOAT64 |  |
| `tract_wkt` | STRING | Tract polygon simplified to 10 m, WKT (for the Icon Map visual). |

# Lineage

Built from:

* `bigquery-public-data.geo_census_tracts.census_tracts_tennessee` ([source](../../sources/census-tracts-tennessee.md))

Used by:

* [agg_geography_performance](agg_geography_performance.md)

# Tests

* `not_null` on `census_tract_geoid`
* `unique` on `census_tract_geoid`
