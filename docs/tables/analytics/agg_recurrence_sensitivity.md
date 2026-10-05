---
type: BigQuery Table
title: agg_recurrence_sensitivity
description: "Phase E sensitivity grid - recurrence rate by location rule x match level x window, per category and overall."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=agg_recurrence_sensitivity
tags: [analytics, recurrence]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/recurrence/agg_recurrence_sensitivity.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.agg_recurrence_sensitivity
materialized: table
row_count: 819
---

Phase E sensitivity grid - recurrence rate by location rule x match level x window, per category and overall.

# Schema

| Column | Type | Description |
|---|---|---|
| `scope` | STRING | Service category, or 'All condition reports'. |
| `location_rule` | STRING | Same address only / Address or within 25/50/100 m / Primary (hybrid). |
| `radius_m` | INT64 |  |
| `match_level` | STRING | request type / category / family. |
| `window_days` | INT64 | 30 / 90 / 180. |
| `eligible_originals` | INT64 |  |
| `recurred` | INT64 |  |
| `recurrence_rate` | FLOAT64 |  |
| `is_headline_definition` | BOOL | The single definition used for headline numbers (primary, 90 days). |

# Lineage

Built from:

* [int_recurrence_candidates](../intermediate/int_recurrence_candidates.md)
* [int_recurrence_originals](../intermediate/int_recurrence_originals.md)

Not used by another model.

# Tests

* `accepted_range` on `recurrence_rate`: 0 to 1
* [`assert_sensitivity_is_monotonic`](../../../dbt/tests/assert_sensitivity_is_monotonic.sql)
