---
type: BigQuery Table
title: agg_backlog_age
description: "Long-format backlog by age band for stacked charts."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=agg_backlog_age
tags: [analytics, performance]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/performance/agg_backlog_age.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.agg_backlog_age
materialized: table
row_count: 108601
---

Long-format backlog by age band for stacked charts. Grain snapshot_date x service_category x age_band.

# Schema

| Column | Type | Description |
|---|---|---|
| `snapshot_date` | DATE |  |
| `service_category` | STRING |  |
| `age_band` | STRING | '1. Under 7 days' ... '5. Over 180 days'. |
| `open_requests` | INT64 | Open requests at end of day in the band. |

# Lineage

Built from:

* [int_backlog_daily_open](../intermediate/int_backlog_daily_open.md)

Not used by another model.
