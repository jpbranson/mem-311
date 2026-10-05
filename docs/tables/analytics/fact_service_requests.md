---
type: BigQuery Table
title: fact_service_requests
description: "One row per 311 service request reported on or after 2023-10-01, excluding the bulk-load artifact (D09, D16)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=fact_service_requests
tags: [analytics, core]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/core/fact_service_requests.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.fact_service_requests
materialized: table
row_count: 406881
---

One row per 311 service request reported on or after 2023-10-01, excluding the bulk-load artifact ([D09](../../decisions/D09-analysis-window-start.md), [D16](../../decisions/D16-bulk-load-artifact.md)). Carries responsiveness, backlog and recurrence attributes so Power BI measures can slice by any dimension.

# Schema

| Column | Type | Description |
|---|---|---|
| `request_id` | INT64 | Primary key (source OBJECTID). |
| `request_number` | STRING | City service request number. |
| `request_type_id` | INT64 | FK to dim_request_type. |
| `service_category` | STRING | FK to dim_service_category. |
| `location_id` | INT64 | FK to dim_location; null when there is neither an address key nor valid coordinates. |
| `census_tract_geoid` | STRING | FK to dim_census_tract. |
| `council_district` | INT64 | Council district 1-7 as recorded at intake. |
| `zip_code` | STRING |  |
| `opened_date` | DATE | Local date reported; FK to dim_date. |
| `opened_at` | DATETIME | Local reported datetime (midnight when date-only, [D10](../../decisions/D10-time-zones-and-date-only-timestamps.md)). |
| `opened_month` | DATE |  |
| `opened_is_date_only` | BOOL |  |
| `closed_date` | DATE | Local closure date; null while open. |
| `closed_at` | DATETIME |  |
| `closed_month` | DATE |  |
| `closed_at_source` | STRING |  |
| `closed_at_is_imputed` | BOOL | Closure time imputed from last_edited_date ([D11](../../decisions/D11-open-closed-status-and-imputed-closure.md)). |
| `is_mass_closure` | BOOL | Closed in the 2025-09-22 administrative mass closure ([D28](../../decisions/D28-mass-closure-2025-09-22.md)). |
| `status_group` | STRING | open / closed. |
| `is_open` | BOOL | Currently open. |
| `source_status` | STRING | City status label. |
| `source_sub_status` | STRING |  |
| `priority` | STRING |  |
| `closure_outcome` | STRING | duplicate / referred / no_issue_found / misrouted / needs_info / completed_or_unspecified / administrative_mass_closure ([D19](../../decisions/D19-closure-outcomes.md), [D28](../../decisions/D28-mass-closure-2025-09-22.md)). |
| `resolution_hours` | FLOAT64 | resolution_days x 24. |
| `days_open_to_close` | INT64 | Calendar days from report date to closure date (includes imputed and mass closures); used for "resolved within N days". |
| `resolution_days` | FLOAT64 | Days from report to closure; null for open, imputed, invalid and mass closures. |
| `has_invalid_resolution_time` | BOOL | Closure date before report date ([D12](../../decisions/D12-negative-resolution-times.md)); never counted in the backlog. |
| `has_same_day_time_conflict` | BOOL |  |
| `resolution_band` | STRING | 0-1 / 1-7 / 7-30 / 30-90 / 90+ days. |
| `current_age_days` | INT64 | For open requests, days since reported as of data_through_date. |
| `current_age_band` | STRING | Backlog age band for open requests. |
| `is_condition_report` | BOOL | Request type reports a problem at a place ([D14](../../decisions/D14-administrative-types-not-recurrence-eligible.md)). |
| `has_valid_coordinates` | BOOL | [D17](../../decisions/D17-valid-coordinates.md). |
| `latitude` | FLOAT64 | Valid latitude only. |
| `longitude` | FLOAT64 | Valid longitude only. |
| `address_normalized` | STRING |  |
| `is_ai_detected` | BOOL | Google AI Detection pilot record ([D15](../../decisions/D15-pothole-analysis-omitted.md)). |
| `is_seeclickfix` | BOOL | SeeClickFix intake. |
| `was_transferred` | BOOL |  |
| `is_recurrence_original` | BOOL | Eligible to be the original in the recurrence analysis ([D21](../../decisions/D21-recurrence-original-eligibility.md)). |
| `recurrence_follow_up_days` | INT64 | Days observed after closure before the data cut-off. |
| `days_to_first_recurrence` | FLOAT64 | Days from closure to the first related request (primary definition, within 180 days). |
| `is_recurrence_eligible_30d` | BOOL | Original observed for at least 30 days after closure (denominator of the 30-day rate). |
| `has_recurrence_30d` | BOOL | Related request within 30 days of closure (numerator). |
| `is_recurrence_eligible_90d` | BOOL | Denominator of the 90-day rate. |
| `has_recurrence_90d` | BOOL | Numerator of the 90-day rate. |
| `is_recurrence_eligible_180d` | BOOL | Denominator of the 180-day rate. |
| `has_recurrence_180d` | BOOL | Numerator of the 180-day rate. |
| `recurrences_within_180d` | INT64 | Number of related requests within 180 days of closure. |

# Lineage

Built from:

* [int_recurrence_outcomes](../intermediate/int_recurrence_outcomes.md)
* [int_requests_enriched](../intermediate/int_requests_enriched.md)
* [meta_data_as_of](meta_data_as_of.md)

Used by:

* [int_backlog_daily_open](../intermediate/int_backlog_daily_open.md)
* [agg_backlog_cohorts](agg_backlog_cohorts.md)
* [agg_backlog_daily](agg_backlog_daily.md)
* [agg_backlog_daily_total](agg_backlog_daily_total.md)
* [agg_geography_performance](agg_geography_performance.md)
* [agg_monthly_service_performance](agg_monthly_service_performance.md)
* [agg_persistent_locations](agg_persistent_locations.md)

# Tests

* `accepted_range` on `resolution_days`: 0 to …
* `not_null` on `opened_date`
* `not_null` on `request_id`
* `not_null` on `request_type_id`
* `not_null` on `service_category`
* `relationships` on `census_tract_geoid` → [dim_census_tract](dim_census_tract.md).`census_tract_geoid`
* `relationships` on `location_id` → [dim_location](dim_location.md).`location_id`
* `relationships` on `request_type_id` → [dim_request_type](dim_request_type.md).`request_type_id`
* `relationships` on `service_category` → [dim_service_category](dim_service_category.md).`service_category`
* `unique` on `request_id`
* [`assert_backlog_conserves_flow`](../../../dbt/tests/assert_backlog_conserves_flow.sql)
* [`assert_fact_reconciles_to_staging`](../../../dbt/tests/assert_fact_reconciles_to_staging.sql)
