---
type: BigQuery Table
title: int_recurrence_outcomes
description: "One row per recurrence original with first-recurrence timing and censoring-aware window flags."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=intermediate&t=int_recurrence_outcomes
tags: [intermediate]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/intermediate/int_recurrence_outcomes.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/intermediate/_intermediate.yml
    title: dbt descriptions and tests
table_id: mem-311.intermediate.int_recurrence_outcomes
materialized: table
row_count: 301628
---

One row per recurrence original with first-recurrence timing and censoring-aware window flags.

# Schema

| Column | Type | Description |
|---|---|---|
| `request_id` | INT64 |  |
| `service_category` | STRING |  |
| `location_id` | INT64 |  |
| `follow_up_days` | INT64 |  |
| `days_to_first_recurrence` | FLOAT64 |  |
| `recurrences_within_30d` | INT64 |  |
| `recurrences_within_90d` | INT64 |  |
| `recurrences_within_180d` | INT64 |  |
| `is_eligible_30d` | BOOL |  |
| `has_recurrence_30d` | BOOL |  |
| `is_eligible_90d` | BOOL |  |
| `has_recurrence_90d` | BOOL |  |
| `is_eligible_180d` | BOOL |  |
| `has_recurrence_180d` | BOOL |  |

# Lineage

Built from:

* [int_recurrence_candidates](int_recurrence_candidates.md)
* [int_recurrence_originals](int_recurrence_originals.md)

Used by:

* [agg_service_recurrence](../analytics/agg_service_recurrence.md)
* [fact_service_requests](../analytics/fact_service_requests.md)

# Tests

* `not_null` on `request_id`
* `unique` on `request_id`
