---
type: BigQuery Table
title: int_recurrence_originals
description: "Requests eligible to be the original in a recurrence relationship, with observed follow-up days (D21, D22)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=intermediate&t=int_recurrence_originals
tags: [intermediate]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/intermediate/int_recurrence_originals.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/intermediate/_intermediate.yml
    title: dbt descriptions and tests
table_id: mem-311.intermediate.int_recurrence_originals
materialized: table
row_count: 301628
---

Requests eligible to be the original in a recurrence relationship, with observed follow-up days ([D21](../../decisions/D21-recurrence-original-eligibility.md), [D22](../../decisions/D22-primary-recurrence-definition.md)).

# Schema

| Column | Type | Description |
|---|---|---|
| `request_id` | INT64 |  |
| `request_type` | STRING |  |
| `service_category` | STRING |  |
| `recurrence_family` | STRING |  |
| `location_match_basis` | STRING |  |
| `location_id` | INT64 |  |
| `census_tract_geoid` | STRING |  |
| `council_district` | INT64 |  |
| `opened_at` | DATETIME |  |
| `closed_at` | DATETIME |  |
| `closed_date` | DATE |  |
| `resolution_days` | FLOAT64 |  |
| `closure_outcome` | STRING |  |
| `address_key` | STRING |  |
| `match_point` | GEOGRAPHY |  |
| `follow_up_days` | INT64 |  |

# Lineage

Built from:

* [int_requests_enriched](int_requests_enriched.md)
* [meta_data_as_of](../analytics/meta_data_as_of.md)

Used by:

* [int_recurrence_candidates](int_recurrence_candidates.md)
* [int_recurrence_outcomes](int_recurrence_outcomes.md)
* [agg_recurrence_sensitivity](../analytics/agg_recurrence_sensitivity.md)

# Tests

* `accepted_range` on `follow_up_days`: 0 to …
* `not_null` on `request_id`
* `unique` on `request_id`
