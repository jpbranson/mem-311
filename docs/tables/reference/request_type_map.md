---
type: BigQuery Table
title: request_type_map
description: "Hand-reviewed classification of every source REQUEST_TYPE (D13, D14, D22)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=reference&t=request_type_map
tags: [reference, seed]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-seed
    resource: ../../../dbt/seeds/request_type_map.csv
    title: Seed CSV
  - id: dbt-schema
    resource: ../../../dbt/seeds/_seeds.yml
    title: dbt descriptions and tests
table_id: mem-311.reference.request_type_map
materialized: seed
row_count: 166
---

Hand-reviewed classification of every source REQUEST_TYPE ([D13](../../decisions/D13-request-type-categories-seed.md), [D14](../../decisions/D14-administrative-types-not-recurrence-eligible.md), [D22](../../decisions/D22-primary-recurrence-definition.md)). Add a row when a new type appears.

# Schema

| Column | Type | Description |
|---|---|---|
| `request_type` | STRING | Source REQUEST_TYPE ('(none)' for blank). |
| `request_type_label` | STRING | Type without the department prefix. |
| `owning_unit` | STRING | Department implied by the prefix. |
| `service_category` | STRING | Standardized category (24 values). |
| `service_group` | STRING | Higher-level group (8 values). |
| `recurrence_family` | STRING | Related categories for the broadest recurrence match level. |
| `is_condition_report` | BOOL | true = a problem at a place (recurrence-eligible); false = administrative transaction. |
| `location_match_basis` | STRING | property = match recurrence on the same address; public_space = same address or within 25 m ([D22](../../decisions/D22-primary-recurrence-definition.md)). |

# Lineage

Used by:

* [int_requests_enriched](../intermediate/int_requests_enriched.md)
* [dim_request_type](../analytics/dim_request_type.md)

# Tests

* `accepted_values` on `location_match_basis`: `property`, `public_space`
* `not_null` on `request_type`
* `not_null` on `service_category`
* `unique` on `request_type`
