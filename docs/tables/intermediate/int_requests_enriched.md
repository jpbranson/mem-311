---
type: BigQuery Table
title: int_requests_enriched
description: "One row per request with classification, closure outcome, resolution time, data-quality flags and location entity."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=intermediate&t=int_requests_enriched
tags: [intermediate]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/intermediate/int_requests_enriched.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/intermediate/_intermediate.yml
    title: dbt descriptions and tests
table_id: mem-311.intermediate.int_requests_enriched
materialized: table
row_count: 408385
---

One row per request with classification, closure outcome, resolution time, data-quality flags and location entity.

# Schema

| Column | Type | Description |
|---|---|---|
| `request_id` | INT64 |  |
| `request_number` | STRING |  |
| `global_id` | STRING |  |
| `request_type_code` | INT64 |  |
| `request_type` | STRING |  |
| `source_department` | STRING |  |
| `source_division` | STRING |  |
| `source_status` | STRING |  |
| `source_sub_status` | STRING |  |
| `status_group` | STRING |  |
| `is_open` | BOOL |  |
| `priority` | STRING |  |
| `reported_at_utc` | TIMESTAMP |  |
| `opened_at` | DATETIME |  |
| `opened_date` | DATE |  |
| `opened_is_date_only` | BOOL |  |
| `closed_at_utc` | TIMESTAMP |  |
| `closed_at` | DATETIME |  |
| `closed_date` | DATE |  |
| `closed_at_source` | STRING |  |
| `closed_at_is_imputed` | BOOL |  |
| `source_closed_at_utc` | TIMESTAMP |  |
| `created_at_utc` | TIMESTAMP |  |
| `last_edited_at_utc` | TIMESTAMP |  |
| `resolution_code` | STRING |  |
| `resolution_summary` | STRING |  |
| `source_address` | STRING |  |
| `zip_code` | STRING |  |
| `parcel_id` | STRING |  |
| `council_district` | INT64 |  |
| `longitude` | FLOAT64 |  |
| `latitude` | FLOAT64 |  |
| `is_ai_detected` | BOOL |  |
| `is_seeclickfix` | BOOL |  |
| `was_transferred` | BOOL |  |
| `transfer_department` | STRING |  |
| `opened_year` | INT64 |  |
| `opened_month` | DATE |  |
| `_batch_id` | STRING |  |
| `_ingested_at` | TIMESTAMP |  |
| `address_normalized` | STRING |  |
| `address_key` | STRING |  |
| `geo_point` | GEOGRAPHY |  |
| `match_point` | GEOGRAPHY |  |
| `is_street_level_geocode` | BOOL |  |
| `is_in_shelby_county` | BOOL |  |
| `is_default_geocode_point` | BOOL |  |
| `has_valid_coordinates` | BOOL |  |
| `census_tract_geoid` | STRING |  |
| `location_key` | STRING |  |
| `request_type_label` | STRING |  |
| `owning_unit` | STRING |  |
| `service_category` | STRING | Standardized category from the request_type_map seed; 'Unmapped' for new source types ([D13](../../decisions/D13-request-type-categories-seed.md)). |
| `service_group` | STRING |  |
| `recurrence_family` | STRING |  |
| `is_condition_report` | BOOL |  |
| `location_match_basis` | STRING |  |
| `is_bulk_artifact` | BOOL | Part of a group of 100+ requests with the same place, type and day ([D16](../../decisions/D16-bulk-load-artifact.md)). |
| `is_mass_closure` | BOOL | Closed on a day of mass administrative closure ([D28](../../decisions/D28-mass-closure-2025-09-22.md)). |
| `closure_outcome` | STRING | Heuristic outcome from resolution text ([D19](../../decisions/D19-closure-outcomes.md)) or administrative_mass_closure ([D28](../../decisions/D28-mass-closure-2025-09-22.md)). |
| `closed_before_opened` | BOOL |  |
| `has_same_day_time_conflict` | BOOL |  |
| `has_invalid_resolution_time` | BOOL |  |
| `resolution_hours` | FLOAT64 |  |
| `resolution_days` | FLOAT64 | Days from opened_at to closed_at; null for imputed, invalid or mass closures ([D11](../../decisions/D11-open-closed-status-and-imputed-closure.md), [D12](../../decisions/D12-negative-resolution-times.md), [D28](../../decisions/D28-mass-closure-2025-09-22.md)). |
| `is_in_analysis_window` | BOOL |  |
| `location_id` | INT64 |  |

# Lineage

Built from:

* [request_type_map](../reference/request_type_map.md)
* [stg_311_requests](../staging/stg_311_requests.md)
* [int_request_locations](int_request_locations.md)

Used by:

* [int_recurrence_candidates](int_recurrence_candidates.md)
* [int_recurrence_originals](int_recurrence_originals.md)
* [agg_service_recurrence](../analytics/agg_service_recurrence.md)
* [dim_location](../analytics/dim_location.md)
* [dim_request_type](../analytics/dim_request_type.md)
* [fact_service_requests](../analytics/fact_service_requests.md)

# Tests

* `accepted_range` on `resolution_days`: 0 to …
* `accepted_values` on `closure_outcome`: `duplicate`, `referred`, `no_issue_found`, `misrouted`, `needs_info`, `completed_or_unspecified`, `administrative_mass_closure`
* `not_null` on `request_id`
* `not_null` on `service_category`
* `unique` on `request_id`
* [`assert_all_request_types_mapped`](../../../dbt/tests/assert_all_request_types_mapped.sql)
* [`assert_fact_reconciles_to_staging`](../../../dbt/tests/assert_fact_reconciles_to_staging.sql)
