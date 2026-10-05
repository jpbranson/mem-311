---
type: BigQuery Table
title: dim_date
description: "Calendar dimension from the analysis start through one year past the data cut-off."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=dim_date
tags: [analytics, core]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/core/dim_date.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.dim_date
materialized: table
row_count: 1456
---

Calendar dimension from the analysis start through one year past the data cut-off.

# Schema

| Column | Type | Description |
|---|---|---|
| `date_day` | DATE | Calendar date (primary key). |
| `year` | INT64 |  |
| `quarter` | INT64 |  |
| `year_quarter` | STRING |  |
| `month_start` | DATE | First day of the month. |
| `year_month` | STRING | YYYY-MM label. |
| `month_label` | STRING | 'Mon YYYY' label; sort by month_start. |
| `month_number` | INT64 |  |
| `month_name` | STRING |  |
| `week_start` | DATE | Monday of the ISO week. |
| `day_of_week_number` | INT64 |  |
| `day_name` | STRING |  |
| `is_weekend` | BOOL |  |
| `fiscal_year` | INT64 | City of Memphis fiscal year (July-June); FY2026 = Jul 2025 - Jun 2026. |
| `is_observed` | BOOL | Date is on or before data_through_date. |
| `is_backlog_burn_in` | BOOL | Before 2024-04-15; backlog still building up from the Oct 2023 go-live ([D25](../../decisions/D25-backlog-reconstruction.md)). |
| `is_current_month` | BOOL | Month containing data_through_date (partial). |

# Lineage

Built from:

* [meta_data_as_of](meta_data_as_of.md)

Used by:

* [agg_backlog_daily](agg_backlog_daily.md)
* [agg_backlog_daily_total](agg_backlog_daily_total.md)
* [agg_monthly_service_performance](agg_monthly_service_performance.md)

# Tests

* `not_null` on `date_day`
* `unique` on `date_day`
