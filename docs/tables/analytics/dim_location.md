---
type: BigQuery Table
title: dim_location
description: "Derived location entity (D23) - one row per address key or ~38 m x 19 m geohash cell."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=dim_location
tags: [analytics, core]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/core/dim_location.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.dim_location
materialized: table
row_count: 152932
---

Derived location entity ([D23](../../decisions/D23-location-entity.md)) - one row per address key or ~38 m x 19 m geohash cell.

# Schema

| Column | Type | Description |
|---|---|---|
| `location_id` | INT64 | farm_fingerprint(location_key); primary key. |
| `location_key` | STRING | 'A/<address_key>' or 'G/<geohash8>'. |
| `location_type` | STRING | address or grid_cell. |
| `display_address` | STRING | Most frequent normalized address among the location's requests. |
| `latitude` | FLOAT64 | Centroid of valid request points. |
| `longitude` | FLOAT64 | Centroid of valid request points. |
| `point_spread_m` | FLOAT64 | Largest distance between two request points at the location. |
| `is_spatially_inconsistent` | BOOL | Points more than 250 m apart - the address key likely merges different places; excluded from persistence ranking. |
| `census_tract_geoid` | STRING | Most frequent tract among the location's requests. |
| `council_district` | INT64 |  |
| `zip_code` | STRING |  |
| `request_count` | INT64 | Requests in the analysis window. |

# Lineage

Built from:

* [int_requests_enriched](../intermediate/int_requests_enriched.md)

Used by:

* [agg_persistent_locations](agg_persistent_locations.md)

# Tests

* `not_null` on `location_id`
* `unique` on `location_id`
