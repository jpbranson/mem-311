---
type: BigQuery Table
title: int_request_locations
description: "Location attributes per request - normalized address, matching key, coordinate validity, Census tract, location entity (D17, D18, D23)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=intermediate&t=int_request_locations
tags: [intermediate]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/intermediate/int_request_locations.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/intermediate/_intermediate.yml
    title: dbt descriptions and tests
table_id: mem-311.intermediate.int_request_locations
materialized: table
row_count: 408385
---

Location attributes per request - normalized address, matching key, coordinate validity, Census tract, location entity ([D17](../../decisions/D17-valid-coordinates.md), [D18](../../decisions/D18-geography.md), [D23](../../decisions/D23-location-entity.md)).

# Schema

| Column | Type | Description |
|---|---|---|
| `request_id` | INT64 |  |
| `source_address` | STRING |  |
| `address_normalized` | STRING | Phase A standardized address (uppercase, no city/state/ZIP/unit, abbreviated street types). |
| `address_key` | STRING | Matching key - normalized address without trailing street type; null without a non-zero house number. |
| `longitude` | FLOAT64 |  |
| `latitude` | FLOAT64 |  |
| `geo_point` | GEOGRAPHY |  |
| `is_in_shelby_county` | BOOL |  |
| `is_default_geocode_point` | BOOL | Coordinate shared by 50+ requests with mostly missing or 10+ distinct addresses. |
| `is_street_level_geocode` | BOOL |  |
| `has_valid_coordinates` | BOOL | Point inside Shelby County and not a geocoder default point ([D17](../../decisions/D17-valid-coordinates.md)). |
| `match_point` | GEOGRAPHY |  |
| `census_tract_geoid` | STRING | 11-digit Census tract GEOID from point-in-polygon. |
| `location_key` | STRING | 'A/<address_key>' or 'G/<geohash8>' ([D23](../../decisions/D23-location-entity.md)). |

# Lineage

Built from:

* [stg_311_requests](../staging/stg_311_requests.md)
* `bigquery-public-data.geo_census_tracts.census_tracts_tennessee` ([source](../../sources/census-tracts-tennessee.md))
* `bigquery-public-data.geo_us_boundaries.counties` ([source](../../sources/us-counties.md))

Used by:

* [int_requests_enriched](int_requests_enriched.md)

# Tests

* `not_null` on `request_id`
* `unique` on `request_id`
