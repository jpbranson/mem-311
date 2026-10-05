---
type: BigQuery Table
title: memphis_311_requests
description: "One row per source record per extraction batch."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=raw&t=memphis_311_requests
tags: [raw, source]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-source
    resource: ../../../dbt/models/staging/_sources.yml
    title: dbt source definition
  - id: extractor
    resource: ../../../ingestion/extract_311.py
    title: Extractor that writes the table
table_id: mem-311.raw.memphis_311_requests
materialized: table
row_count: 419971
---

One row per source record per extraction batch. Memphis 311 data loaded by ingestion/extract_311.py (append-only; PII excluded, see [D02](../../decisions/D02-drop-personal-fields-at-extraction.md)).

# Schema

| Column | Type | Description |
|---|---|---|
| `OBJECTID` | INT64 |  |
| `GlobalID` | STRING |  |
| `INCIDENT_ID` | INT64 |  |
| `INCIDENT_NUMBER` | STRING |  |
| `INCIDENT_TYPE_ID` | INT64 |  |
| `DIVISION` | STRING |  |
| `DEPARTMENT` | STRING |  |
| `CATEGORY` | STRING |  |
| `REQUEST_TYPE` | STRING |  |
| `REQUEST_STATUS` | STRING |  |
| `Request_Sub_Status` | STRING |  |
| `REQUEST_PRIORITY` | STRING |  |
| `REPORTED_DATE` | TIMESTAMP |  |
| `DAYS_OLD` | INT64 |  |
| `FOLLOWUP_DATE` | TIMESTAMP |  |
| `ASSIGNED_DATE` | TIMESTAMP |  |
| `QAQC_YESNO` | STRING |  |
| `QAQC_RATING` | INT64 |  |
| `SUPERVISOR_APPROVAL` | STRING |  |
| `RESOLVED_DATE` | TIMESTAMP |  |
| `Closed_Date` | TIMESTAMP |  |
| `RESOLUTION_CODE` | STRING |  |
| `RESOLUTION_SUMMARY` | STRING |  |
| `GROUP_NAME` | STRING |  |
| `Location_Address` | STRING |  |
| `Unit_Address` | STRING |  |
| `CITY` | STRING |  |
| `STATE` | STRING |  |
| `ZipCode` | STRING |  |
| `PARCEL_ID` | STRING |  |
| `ASSET_ID` | STRING |  |
| `MAP_PG` | STRING |  |
| `MAP_BLK` | STRING |  |
| `CODE_DISTRICT` | INT64 |  |
| `CODE_SUBDISTRICT` | STRING |  |
| `TARGET_BLOCK` | STRING |  |
| `DRAIN_ZONE` | STRING |  |
| `DRAIN_GRID` | STRING |  |
| `STREET_ZONE` | STRING |  |
| `STREET_GRID` | STRING |  |
| `TRAFFIC_ZONE` | STRING |  |
| `SWM_AREA` | STRING |  |
| `SWM_ZONE` | STRING |  |
| `SWM_CollectionDay` | STRING |  |
| `SWM_ROUTE` | STRING |  |
| `LINKED_SR` | STRING |  |
| `cd_name` | INT64 |  |
| `cd_desc` | STRING |  |
| `sccd_name` | INT64 |  |
| `sccd_desc` | STRING |  |
| `scd_name` | INT64 |  |
| `scd_desc` | STRING |  |
| `neigh_desc` | STRING |  |
| `created_date` | TIMESTAMP |  |
| `last_edited_date` | TIMESTAMP |  |
| `Transfer` | STRING |  |
| `Transfer_Dept` | STRING |  |
| `Anonymous` | STRING |  |
| `Transfer_Status` | STRING |  |
| `SYSREVSTATUS` | STRING |  |
| `ext_system_no` | STRING |  |
| `longitude` | FLOAT64 |  |
| `latitude` | FLOAT64 |  |
| `is_ai_detected` | BOOL |  |
| `is_seeclickfix` | BOOL |  |
| `_batch_id` | STRING |  |
| `_ingested_at` | TIMESTAMP |  |
| `_source` | STRING |  |
| `_extract_mode` | STRING |  |

# Lineage

Built from:

* [`ingestion/extract_311.py`](../../../ingestion/extract_311.py), which reads the [Memphis 311 FeatureServer](../../sources/memphis-311-featureserver.md)

Used by:

* [stg_311_requests](../staging/stg_311_requests.md)

# Tests

* `not_null` on `OBJECTID`
* `not_null` on `_batch_id`
