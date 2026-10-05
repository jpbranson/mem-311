---
type: Decision
id: D18
title: "D18 — Geography"
description: "Use Census tracts (spatial join), council district (source field) and ZIP; no neighborhoods"
tags: [geography]
area: Geography
status: stable
logged_at: 2026-09-23T07:47:49Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T07:47:49Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (406,902 records)
    title: Evidence counts, unless the entry states otherwise
---

**Decision.** Assign each request to:
* **Census tract.** Point-in-polygon against `bigquery-public-data.geo_census_tracts.census_tracts_tennessee`
  (Shelby County, 221 tracts).
* **City council district.** The source `cd_name` (1–7), as recorded at intake.
* **ZIP code.** The source `ZipCode`, trimmed to 5 digits.

No neighborhood geography is used.

**Evidence.** `neigh_desc` is populated on only 456 records, and no defensible neighborhood boundary file is
available in the warehouse. `cd_name` is populated on 91%; its companion `cd_desc` is almost always null and
sometimes contradicts `cd_name`, so `cd_desc` is ignored.

**Caveat.** Per-capita rates are not computed (see [methodology: reporting bias](../methodology/limitations.md)).
