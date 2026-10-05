---
type: BigQuery Table
title: agg_monthly_service_performance
description: "Monthly responsiveness by service category (D26)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=agg_monthly_service_performance
tags: [analytics, performance]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/performance/agg_monthly_service_performance.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.agg_monthly_service_performance
materialized: table
row_count: 864
---

Monthly responsiveness by service category ([D26](../../decisions/D26-responsiveness-counting-rules.md)). Grain month_start x service_category.

# Schema

| Column | Type | Description |
|---|---|---|
| `month_start` | DATE |  |
| `service_category` | STRING |  |
| `requests_opened` | INT64 | Requests reported in the month. |
| `requests_closed` | INT64 | Requests closed in the month (including imputed and mass closures). |
| `net_change` | INT64 | opened - closed. |
| `closed_with_resolution_time` | INT64 |  |
| `median_resolution_days` | FLOAT64 | Median resolution of requests closed in the month with a recorded closure time. |
| `p90_resolution_days` | FLOAT64 | 90th percentile of the same. |
| `pct_resolved_within_7d` | FLOAT64 | Share of the month's intake closed within 7 days; null until observable. |
| `pct_resolved_within_30d` | FLOAT64 | Share of the month's intake closed within 30 days; null until observable. |
| `open_at_month_end` | INT64 | Reconstructed backlog on the month's last observed day. |
| `is_partial_month` | BOOL | Go-live month (Oct 2023) or the current month. |

# Lineage

Built from:

* [agg_backlog_daily](agg_backlog_daily.md)
* [dim_date](dim_date.md)
* [fact_service_requests](fact_service_requests.md)
* [meta_data_as_of](meta_data_as_of.md)

Not used by another model.

# Tests

* `unique_combination_of_columns` on `month_start`, `service_category`
