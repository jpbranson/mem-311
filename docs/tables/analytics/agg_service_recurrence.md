---
type: BigQuery Table
title: agg_service_recurrence
description: "Durability by service category under the primary definition, with median resolution for the speed vs durability comparison."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=agg_service_recurrence
tags: [analytics, recurrence]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/recurrence/agg_service_recurrence.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.agg_service_recurrence
materialized: table
row_count: 20
---

Durability by service category under the primary definition, with median resolution for the speed vs durability comparison.

# Schema

| Column | Type | Description |
|---|---|---|
| `service_category` | STRING |  |
| `recurrence_originals` | INT64 | Eligible originals (closed condition reports with a usable location). |
| `eligible_30d` | INT64 |  |
| `recurred_30d` | INT64 |  |
| `recurrence_rate_30d` | FLOAT64 |  |
| `eligible_90d` | INT64 | Originals observed for 90+ days after closure. |
| `recurred_90d` | INT64 | Of those, followed by a related request within 90 days. |
| `recurrence_rate_90d` | FLOAT64 | recurred_90d / eligible_90d (same pattern for 30d and 180d). |
| `eligible_180d` | INT64 |  |
| `recurred_180d` | INT64 |  |
| `recurrence_rate_180d` | FLOAT64 |  |
| `median_days_to_recurrence` | FLOAT64 | Median days to first recurrence among originals that recurred within 180 days. |
| `median_resolution_days` | FLOAT64 | Median resolution time of the category's originals. |

# Lineage

Built from:

* [int_recurrence_outcomes](../intermediate/int_recurrence_outcomes.md)
* [int_requests_enriched](../intermediate/int_requests_enriched.md)

Not used by another model.

# Tests

* `accepted_range` on `recurrence_rate_90d`: 0 to 1
* `not_null` on `service_category`
* `unique` on `service_category`
