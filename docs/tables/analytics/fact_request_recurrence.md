---
type: BigQuery Table
title: fact_request_recurrence
description: "One row per recurrence relationship under the primary definition (D22), up to 180 days after closure."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=fact_request_recurrence
tags: [analytics, recurrence]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/recurrence/fact_request_recurrence.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.fact_request_recurrence
materialized: table
row_count: 161544
---

One row per recurrence relationship under the primary definition ([D22](../../decisions/D22-primary-recurrence-definition.md)), up to 180 days after closure.

# Schema

| Column | Type | Description |
|---|---|---|
| `original_request_id` | INT64 | FK to fact_service_requests (the closed request). |
| `recurring_request_id` | INT64 | FK to fact_service_requests (the later related request). |
| `location_id` | INT64 | Location of the original. |
| `service_category` | STRING |  |
| `original_closed_date` | DATE |  |
| `recurring_opened_date` | DATE |  |
| `days_between` | FLOAT64 | Days from original closure to the recurring request's report. |
| `distance_m` | FLOAT64 | Distance between the two points (null when matched by address without coordinates). |
| `is_same_address` | BOOL | Matched on the same address key. |
| `is_same_request_type` | BOOL | Same source request type (all rows share the service category). |
| `recurrence_window` | STRING | 0-30 / 31-90 / 91-180 days. |
| `recurrence_sequence` | INT64 | Order of this recurrence among the original's recurrences (1 = first). |

# Lineage

Built from:

* [int_recurrence_candidates](../intermediate/int_recurrence_candidates.md)

Not used by another model.

# Tests

* `relationships` on `original_request_id` → [fact_service_requests](fact_service_requests.md).`request_id`
* `unique_combination_of_columns` on `original_request_id`, `recurring_request_id`
* [`assert_recurrence_follows_closure`](../../../dbt/tests/assert_recurrence_follows_closure.sql)
