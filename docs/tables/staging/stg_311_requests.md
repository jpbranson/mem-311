---
type: BigQuery View
title: stg_311_requests
description: "One row per live Memphis 311 request, latest extracted version."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=staging&t=stg_311_requests
tags: [staging]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-model
    resource: ../../../dbt/models/staging/stg_311_requests.sql
    title: dbt model SQL
  - id: dbt-schema
    resource: ../../../dbt/models/staging/_staging.yml
    title: dbt descriptions and tests
table_id: mem-311.staging.stg_311_requests
materialized: view
---

One row per live Memphis 311 request, latest extracted version. Live means present in the most recent successful full snapshot or a later successful incremental batch ([D06](../../decisions/D06-append-only-raw-table.md), [D07](../../decisions/D07-incremental-and-full-snapshots.md)). Statuses, timestamps and codes are standardized; business classification happens in intermediate models.

# Schema

| Column | Type | Description |
|---|---|---|
| `request_id` | INT64 | Source OBJECTID; record key ([D08](../../decisions/D08-record-and-business-keys.md)). |
| `request_number` | STRING | City service request number (INCIDENT_NUMBER); business key. |
| `global_id` | STRING |  |
| `request_type_code` | INT64 |  |
| `request_type` | STRING | Source REQUEST_TYPE, '(none)' when blank. |
| `source_department` | STRING |  |
| `source_division` | STRING |  |
| `source_status` | STRING | Source REQUEST_STATUS with the mangled en dash repaired. |
| `source_sub_status` | STRING |  |
| `status_group` | STRING | open / closed, derived from status ([D11](../../decisions/D11-open-closed-status-and-imputed-closure.md)). |
| `is_open` | BOOL |  |
| `priority` | STRING |  |
| `reported_at_utc` | TIMESTAMP |  |
| `opened_at` | DATETIME | Reported time in America/Chicago; local midnight when the source value is date-only ([D10](../../decisions/D10-time-zones-and-date-only-timestamps.md)). |
| `opened_date` | DATE | Local calendar date the request was reported. |
| `opened_is_date_only` | BOOL | True when REPORTED_DATE carried no time of day (stored as 00:00:00 UTC), mostly SeeClickFix intake. |
| `closed_at_utc` | TIMESTAMP |  |
| `closed_at` | DATETIME | Local closure time, coalesce(Closed_Date, RESOLVED_DATE, last_edited_date) for closed requests ([D11](../../decisions/D11-open-closed-status-and-imputed-closure.md)). |
| `closed_date` | DATE |  |
| `closed_at_source` | STRING | Which source field supplied closed_at. |
| `closed_at_is_imputed` | BOOL | True when closed_at fell back to last_edited_date; such closures are excluded from resolution metrics. |
| `source_closed_at_utc` | TIMESTAMP |  |
| `created_at_utc` | TIMESTAMP |  |
| `last_edited_at_utc` | TIMESTAMP |  |
| `resolution_code` | STRING |  |
| `resolution_summary` | STRING |  |
| `source_address` | STRING |  |
| `zip_code` | STRING | First five digits of the source ZIP code. |
| `parcel_id` | STRING |  |
| `council_district` | INT64 | City council district 1-7 from the source (cd_name); null when missing or out of range. |
| `longitude` | FLOAT64 | WGS84 longitude from the feature geometry ([D04](../../decisions/D04-coordinates-from-geometry.md)). |
| `latitude` | FLOAT64 | WGS84 latitude from the feature geometry ([D04](../../decisions/D04-coordinates-from-geometry.md)). |
| `is_ai_detected` | BOOL | Created by the Google AI Detection pilot ([D15](../../decisions/D15-pothole-analysis-omitted.md)). |
| `is_seeclickfix` | BOOL | Linked to a SeeClickFix issue (resident app intake). |
| `was_transferred` | BOOL |  |
| `transfer_department` | STRING |  |
| `opened_year` | INT64 |  |
| `opened_month` | DATE |  |
| `_batch_id` | STRING |  |
| `_ingested_at` | TIMESTAMP |  |

# Lineage

Built from:

* [ingestion_batches](../raw/ingestion_batches.md)
* [memphis_311_requests](../raw/memphis_311_requests.md)

Used by:

* [int_request_locations](../intermediate/int_request_locations.md)
* [int_requests_enriched](../intermediate/int_requests_enriched.md)
* [meta_data_as_of](../analytics/meta_data_as_of.md)

# Tests

* `accepted_values` on `closed_at_source`: `closed_date`, `resolved_date`, `last_edited_date`
* `accepted_values` on `status_group`: `open`, `closed`
* `not_null` on `opened_at`
* `not_null` on `opened_date`
* `not_null` on `request_id`
* `not_null` on `request_number`
* `not_null` on `request_type`
* `not_null` on `status_group`
* `relationships` on `request_type` → [request_type_map](../reference/request_type_map.md).`request_type` (warn)
* `unique` on `request_id`
* `unique` on `request_number`
* [`assert_fact_reconciles_to_staging`](../../../dbt/tests/assert_fact_reconciles_to_staging.sql)
