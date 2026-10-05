---
type: BigQuery Table
title: agg_persistent_locations
description: "Locations with 3+ condition reports, with persistence metrics and tier (D27)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=agg_persistent_locations
tags: [analytics, recurrence]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/recurrence/agg_persistent_locations.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.agg_persistent_locations
materialized: table
row_count: 45021
---

Locations with 3+ condition reports, with persistence metrics and tier ([D27](../../decisions/D27-persistent-location-tiers.md)). Grain location_id.

# Schema

| Column | Type | Description |
|---|---|---|
| `location_id` | INT64 |  |
| `display_address` | STRING |  |
| `location_type` | STRING |  |
| `latitude` | FLOAT64 |  |
| `longitude` | FLOAT64 |  |
| `census_tract_geoid` | STRING |  |
| `council_district` | INT64 |  |
| `zip_code` | STRING |  |
| `total_requests` | INT64 | All requests at the location, including administrative ones. |
| `condition_requests` | INT64 | Condition-report requests at the location. |
| `distinct_categories` | INT64 |  |
| `first_request_date` | DATE |  |
| `latest_request_date` | DATE |  |
| `active_months` | INT64 | Distinct months with at least one condition report. |
| `active_years` | INT64 | Distinct calendar years with at least one condition report. |
| `recurrence_cycles` | INT64 | Close-then-return events (originals with a 90-day recurrence). |
| `recurrence_cycles_band` | STRING | 0 / 1 / 2-3 / 4-9 / 10+ for the cycle distribution chart; sort by recurrence_cycles_band_order. |
| `recurrence_cycles_band_order` | INT64 | 0-4 in band order; use as the sort-by column for recurrence_cycles_band. |
| `recurrence_eligible_closures` | INT64 |  |
| `dominant_category` | STRING | Most frequent service category. |
| `dominant_category_requests` | INT64 |  |
| `dominant_category_share` | FLOAT64 | Share of condition reports in the dominant category. |
| `median_resolution_days` | FLOAT64 |  |
| `avg_resolution_days` | FLOAT64 |  |
| `unresolved_requests` | INT64 | Currently open condition reports. |
| `avg_days_between_requests` | FLOAT64 | (latest - first) / (requests - 1). |
| `is_spatially_inconsistent` | BOOL |  |
| `persistence_tier` | STRING | 1. Chronic (10+ requests, 6+ months, 4+ cycles) / 2. Persistent (5+, 3+, 2+) / 3. Repeat / Excluded. |
| `is_persistent` | BOOL | Tier 1 or 2. |
| `persistence_rank` | INT64 | Rank by recurrence cycles then requests (1 = most persistent). |

# Lineage

Built from:

* [dim_location](dim_location.md)
* [fact_service_requests](fact_service_requests.md)

Used by:

* [agg_geography_performance](agg_geography_performance.md)

# Tests

* `accepted_values` on `recurrence_cycles_band_order`: `0`, `1`, `2`, `3`, `4`
* `not_null` on `location_id`
* `not_null` on `recurrence_cycles_band_order`
* `relationships` on `location_id` → [dim_location](dim_location.md).`location_id`
* `unique` on `location_id`
