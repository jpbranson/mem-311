---
type: BigQuery Table
title: dim_request_type
description: "One row per source request type with its standardized classification (D13, D14)."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=analytics&t=dim_request_type
tags: [analytics, core]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/marts/core/dim_request_type.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/marts/_marts.yml
    title: dbt descriptions and tests
table_id: mem-311.analytics.dim_request_type
materialized: table
row_count: 166
---

One row per source request type with its standardized classification ([D13](../../decisions/D13-request-type-categories-seed.md), [D14](../../decisions/D14-administrative-types-not-recurrence-eligible.md)).

# Schema

| Column | Type | Description |
|---|---|---|
| `request_type_id` | INT64 | farm_fingerprint(request_type); joins to fact_service_requests. |
| `request_type` | STRING | Source REQUEST_TYPE. |
| `request_type_label` | STRING | Request type without the department prefix. |
| `owning_unit` | STRING | Department implied by the type prefix (SWM, CE, PW (SM), ...). |
| `service_category` | STRING | Standardized category (24 values). |
| `service_group` | STRING | Higher-level service group (8 values). |
| `recurrence_family` | STRING | Related-category group used for the broadest recurrence matching level. |
| `is_condition_report` | BOOL | Reports a problem at a place (eligible for recurrence) rather than an administrative transaction ([D14](../../decisions/D14-administrative-types-not-recurrence-eligible.md)). |
| `request_count` | INT64 | Requests of this type in staging. |
| `first_seen_date` | DATE |  |
| `last_seen_date` | DATE |  |

# Lineage

Built from:

* [request_type_map](../reference/request_type_map.md)
* [int_requests_enriched](../intermediate/int_requests_enriched.md)

Used by:

* [dim_service_category](dim_service_category.md)

# Tests

* `not_null` on `request_type_id`
* `relationships` on `service_category` → [dim_service_category](dim_service_category.md).`service_category`
* `unique` on `request_type_id`
* `unique` on `request_type`
