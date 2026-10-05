---
type: BigQuery Table
title: US county boundaries (BigQuery public data)
description: County polygons; the Shelby County boundary decides whether a request's coordinate is valid.
resource: https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=geo_us_boundaries&t=counties
tags: [source, geography, public-data]
status: stable
table_id: bigquery-public-data.geo_us_boundaries.counties
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
---

Only Shelby County, Tennessee is read (`geo_id = '47157'`), in
[`int_request_locations`](../tables/intermediate/int_request_locations.md). A coordinate is valid only inside
this polygon and away from geocoder default points ([D17](../decisions/D17-valid-coordinates.md)).
