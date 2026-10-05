---
type: BigQuery Table
title: agg_geography_performance
description: "Geographic comparison across all categories."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=agg_geography_performance
tags: [analytics, performance]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/performance/agg_geography_performance.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.agg_geography_performance
materialized: table
row_count: 281
---

Geographic comparison across all categories. Grain geography_type x geography_id. No per-capita rates.

# Schema

| Column | Type | Description |
|---|---|---|
| `geography_type` | STRING | census_tract / council_district / zip_code. |
| `geography_id` | STRING |  |
| `geography_name` | STRING |  |
| `requests_opened` | INT64 |  |
| `condition_requests` | INT64 |  |
| `median_resolution_days` | FLOAT64 |  |
| `pct_resolved_within_30d` | FLOAT64 |  |
| `open_requests` | INT64 |  |
| `median_open_age_days` | FLOAT64 |  |
| `pct_open_over_90d` | FLOAT64 |  |
| `recurrence_eligible_90d` | INT64 |  |
| `recurred_90d` | INT64 |  |
| `recurrence_rate_90d` | FLOAT64 | Primary-definition 90-day recurrence rate of originals in the geography. |
| `persistent_locations` | INT64 | Locations with is_persistent in the geography. |

# Lineage

Built from:

* [agg_persistent_locations](agg_persistent_locations.md)
* [dim_census_tract](dim_census_tract.md)
* [fact_service_requests](fact_service_requests.md)
* [meta_data_as_of](meta_data_as_of.md)

Not used by another model.

# Tests

* `unique_combination_of_columns` on `geography_type`, `geography_id`
