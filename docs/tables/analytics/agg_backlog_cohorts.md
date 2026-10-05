---
type: BigQuery Table
title: agg_backlog_cohorts
description: "Monthly intake cohorts - how fast each month's requests closed and how many remain open."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=agg_backlog_cohorts
tags: [analytics, performance]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/performance/agg_backlog_cohorts.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.agg_backlog_cohorts
materialized: table
row_count: 849
---

Monthly intake cohorts - how fast each month's requests closed and how many remain open.

# Schema

| Column | Type | Description |
|---|---|---|
| `cohort_month` | DATE | Month reported. |
| `service_category` | STRING |  |
| `requests_opened` | INT64 |  |
| `closed_within_7d` | INT64 | Closed within 7 days of report; null if the cohort is younger than 7 days. |
| `closed_within_30d` | INT64 |  |
| `closed_within_90d` | INT64 |  |
| `closed_within_180d` | INT64 |  |
| `still_open` | INT64 | Still open at the data cut-off. |
| `cohort_observed_days` | INT64 | Days between the cohort month's last day and the data cut-off. |

# Lineage

Built from:

* [fact_service_requests](fact_service_requests.md)
* [meta_data_as_of](meta_data_as_of.md)

Not used by another model.
