---
type: BigQuery Table
title: agg_backlog_daily_total
description: "Same measures as agg_backlog_daily across all categories (grain snapshot_date); medians over the whole open population."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=agg_backlog_daily_total
tags: [analytics, performance]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/performance/agg_backlog_daily_total.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.agg_backlog_daily_total
materialized: table
row_count: 1091
---

Same measures as agg_backlog_daily across all categories (grain snapshot_date); medians over the whole open population.

# Schema

| Column | Type | Description |
|---|---|---|
| `snapshot_date` | DATE |  |
| `requests_opened` | INT64 |  |
| `requests_closed` | INT64 |  |
| `net_backlog_change` | INT64 |  |
| `open_requests` | INT64 |  |
| `median_age_days` | INT64 |  |
| `p90_age_days` | INT64 |  |
| `open_under_7d` | INT64 |  |
| `open_7_30d` | INT64 |  |
| `open_31_90d` | INT64 |  |
| `open_91_180d` | INT64 |  |
| `open_over_180d` | INT64 |  |
| `pct_open_over_30d` | FLOAT64 |  |
| `pct_open_over_90d` | FLOAT64 |  |
| `is_burn_in_period` | BOOL |  |

# Lineage

Built from:

* [int_backlog_daily_open](../intermediate/int_backlog_daily_open.md)
* [dim_date](dim_date.md)
* [fact_service_requests](fact_service_requests.md)

Not used by another model.

# Tests

* `not_null` on `snapshot_date`
* `unique` on `snapshot_date`
* [`assert_backlog_conserves_flow`](../../../dbt/tests/assert_backlog_conserves_flow.sql)
