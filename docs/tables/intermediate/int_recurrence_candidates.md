---
type: BigQuery Table
title: int_recurrence_candidates
description: "All original/follower pairs under the loosest definition (family, 100 m or same address, 180 days)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=intermediate&t=int_recurrence_candidates
tags: [intermediate]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/intermediate/int_recurrence_candidates.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/intermediate/_intermediate.yml
    title: dbt descriptions and tests
table_id: mem-311.intermediate.int_recurrence_candidates
materialized: table
row_count: 1087939
---

All original/follower pairs under the loosest definition (family, 100 m or same address, 180 days).

# Schema

| Column | Type | Description |
|---|---|---|
| `original_request_id` | INT64 |  |
| `follower_request_id` | INT64 |  |
| `original_location_id` | INT64 |  |
| `original_service_category` | STRING |  |
| `follower_service_category` | STRING |  |
| `recurrence_family` | STRING |  |
| `original_closed_at` | DATETIME |  |
| `follower_opened_at` | DATETIME |  |
| `days_after_closure` | FLOAT64 |  |
| `distance_m` | FLOAT64 |  |
| `is_same_address` | BOOL |  |
| `is_same_request_type` | BOOL |  |
| `is_same_category` | BOOL |  |
| `original_location_match_basis` | STRING |  |
| `both_have_address_key` | BOOL |  |
| `is_primary_match` | BOOL | Pair satisfies the primary recurrence definition ([D22](../../decisions/D22-primary-recurrence-definition.md)). |

# Lineage

Built from:

* [int_recurrence_originals](int_recurrence_originals.md)
* [int_requests_enriched](int_requests_enriched.md)

Used by:

* [int_recurrence_outcomes](int_recurrence_outcomes.md)
* [agg_recurrence_sensitivity](../analytics/agg_recurrence_sensitivity.md)
* [fact_request_recurrence](../analytics/fact_request_recurrence.md)

# Tests

* `accepted_range` on `days_after_closure`: 0 to 180
* `unique_combination_of_columns` on `original_request_id`, `follower_request_id`
