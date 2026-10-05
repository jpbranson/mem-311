---
type: BigQuery Table
title: dim_service_category
description: "One row per standardized service category - the shared slicer dimension for fact and aggregate tables."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=dim_service_category
tags: [analytics, core]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/core/dim_service_category.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.dim_service_category
materialized: table
row_count: 24
---

One row per standardized service category - the shared slicer dimension for fact and aggregate tables.

# Schema

| Column | Type | Description |
|---|---|---|
| `service_category` | STRING | Primary key. |
| `service_group` | STRING | Higher-level service group. |
| `has_condition_reports` | BOOL |  |
| `is_recurrence_eligible` | BOOL | All request types in the category are condition reports. |
| `request_type_count` | INT64 |  |
| `request_count` | INT64 |  |
| `volume_rank` | INT64 | Rank by total request volume (1 = largest); use as a sort-by column. |

# Lineage

Built from:

* [dim_request_type](dim_request_type.md)

Not used by another model.

# Tests

* `not_null` on `service_category`
* `unique` on `service_category`
