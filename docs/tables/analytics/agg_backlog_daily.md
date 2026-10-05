---
type: BigQuery Table
title: agg_backlog_daily
description: "End-of-day backlog size, age distribution and flow per category (D25)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=agg_backlog_daily
tags: [analytics, performance]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/performance/agg_backlog_daily.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.agg_backlog_daily
materialized: table
row_count: 26184
---

End-of-day backlog size, age distribution and flow per category ([D25](../../decisions/D25-backlog-reconstruction.md)). Grain snapshot_date x service_category.

# Schema

| Column | Type | Description |
|---|---|---|
| `snapshot_date` | DATE | Local date; values are end-of-day. |
| `service_category` | STRING |  |
| `requests_opened` | INT64 | Requests reported that day. |
| `requests_closed` | INT64 | Requests closed that day (valid closures). |
| `net_backlog_change` | INT64 | opened - closed. |
| `open_requests` | INT64 | Requests open at end of day. |
| `median_age_days` | INT64 | Median age of open requests (approximate quantile, 1% resolution). |
| `p90_age_days` | INT64 | 90th-percentile age of open requests. |
| `open_under_7d` | INT64 | Open requests aged under 7 days. |
| `open_7_30d` | INT64 | Aged 7-30 days. |
| `open_31_90d` | INT64 | Aged 31-90 days. |
| `open_91_180d` | INT64 | Aged 91-180 days. |
| `open_over_180d` | INT64 | Aged over 180 days. |
| `pct_open_over_30d` | FLOAT64 | Share of the backlog older than 30 days. |
| `pct_open_over_90d` | FLOAT64 | Share of the backlog older than 90 days. |
| `is_burn_in_period` | BOOL | Before 2024-04-15 - backlog still accumulating from the Oct 2023 go-live; exclude from trend statements. |

# Lineage

Built from:

* [int_backlog_daily_open](../intermediate/int_backlog_daily_open.md)
* [dim_date](dim_date.md)
* [fact_service_requests](fact_service_requests.md)

Used by:

* [agg_monthly_service_performance](agg_monthly_service_performance.md)

# Tests

* `unique_combination_of_columns` on `snapshot_date`, `service_category`
