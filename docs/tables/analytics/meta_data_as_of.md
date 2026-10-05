---
type: BigQuery Table
title: meta_data_as_of
description: "One-row table with the extraction time and the last complete local day covered."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=meta_data_as_of
tags: [analytics, core]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/core/meta_data_as_of.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.meta_data_as_of
materialized: table
row_count: 1
---

One-row table with the extraction time and the last complete local day covered. Drives the "data through" card.

# Schema

| Column | Type | Description |
|---|---|---|
| `extracted_at_utc` | TIMESTAMP | Time of the latest ingestion batch. |
| `data_through_date` | DATE | Last complete America/Chicago day in the data (extraction date minus one). |
| `analysis_start_date` | DATE | First day of the analysis window ([D09](../../decisions/D09-analysis-window-start.md)). |
| `live_request_count` | INT64 | Requests in staging. |

# Lineage

Built from:

* [stg_311_requests](../staging/stg_311_requests.md)

Used by:

* [int_backlog_daily_open](../intermediate/int_backlog_daily_open.md)
* [int_recurrence_originals](../intermediate/int_recurrence_originals.md)
* [agg_backlog_cohorts](agg_backlog_cohorts.md)
* [agg_geography_performance](agg_geography_performance.md)
* [agg_monthly_service_performance](agg_monthly_service_performance.md)
* [dim_date](dim_date.md)
* [fact_service_requests](fact_service_requests.md)
