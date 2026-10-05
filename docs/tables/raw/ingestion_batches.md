---
type: BigQuery Table
title: ingestion_batches
description: "One row per extraction run with validation counts and the last_edited_date high-water mark."
resource: https://console.cloud.google.com/bigquery?p=mem-311&d=raw&t=ingestion_batches
tags: [raw, source]
generated: { by: build_knowledge/1, at: 2026-09-27T01:31:58Z }
sources:
  - id: dbt-source
    resource: ../../../dbt/models/staging/_sources.yml
    title: dbt source definition
  - id: extractor
    resource: ../../../ingestion/extract_311.py
    title: Extractor that writes the table
table_id: mem-311.raw.ingestion_batches
materialized: table
row_count: 6
---

One row per extraction run with validation counts and the last_edited_date high-water mark. Memphis 311 data loaded by ingestion/extract_311.py (append-only; PII excluded, see [D02](../../decisions/D02-drop-personal-fields-at-extraction.md)).

# Schema

| Column | Type | Description |
|---|---|---|
| `batch_id` | STRING |  |
| `extract_mode` | STRING |  |
| `started_at` | TIMESTAMP |  |
| `finished_at` | TIMESTAMP |  |
| `where_clause` | STRING |  |
| `expected_count` | INT64 |  |
| `extracted_count` | INT64 |  |
| `loaded_count` | INT64 |  |
| `max_last_edited` | TIMESTAMP |  |
| `status` | STRING |  |
| `message` | STRING |  |

# Lineage

Built from:

* [`ingestion/extract_311.py`](../../../ingestion/extract_311.py), which reads the [Memphis 311 FeatureServer](../../sources/memphis-311-featureserver.md)

Used by:

* [stg_311_requests](../staging/stg_311_requests.md)

# Tests

* `accepted_values` on `status`: `success`, `failed`
* `not_null` on `batch_id`
* `unique` on `batch_id`
