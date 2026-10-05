---
type: BigQuery Table
title: int_backlog_daily_open
description: "One row per request per local day it was open at end of day (D25)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=intermediate&t=int_backlog_daily_open
tags: [intermediate]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/intermediate/int_backlog_daily_open.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/intermediate/_intermediate.yml
    title: dbt descriptions and tests
table_id: mem-311.intermediate.int_backlog_daily_open
materialized: table
row_count: 17719320
---

One row per request per local day it was open at end of day ([D25](../../decisions/D25-backlog-reconstruction.md)).

# Schema

| Column | Type | Description |
|---|---|---|
| `snapshot_date` | DATE |  |
| `request_id` | INT64 |  |
| `service_category` | STRING |  |
| `age_days` | INT64 |  |

# Lineage

Built from:

* [fact_service_requests](../analytics/fact_service_requests.md)
* [meta_data_as_of](../analytics/meta_data_as_of.md)

Used by:

* [agg_backlog_age](../analytics/agg_backlog_age.md)
* [agg_backlog_daily](../analytics/agg_backlog_daily.md)
* [agg_backlog_daily_total](../analytics/agg_backlog_daily_total.md)

# Tests

* `accepted_range` on `age_days`: 0 to …
* `unique_combination_of_columns` on `snapshot_date`, `request_id`
