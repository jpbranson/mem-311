---
type: Attested Computation
title: Persistent and chronic location counts
description: Number of Persistent-or-Chronic locations and of Chronic locations among places with three or more condition reports.
tags: [persistence]
status: stable
runtime: bigquery
parameters: []
executor:
  resource: ../references/bigquery/run.py
  receipt: [job_id, location, executed_sql, parameters, result]
attester:
  resource: ../references/bigquery/attest.py
dax_measures: ["Persistent Locations", "Chronic Locations"]
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T08:30:42Z }
sources:
  - id: validation-queries
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/powerbi/validation_queries.sql
    title: Validation queries before the OKF conversion
  - id: build-guide
    resource: ../../powerbi/build_guide.md
    title: Power BI build guide, section 5 (expected values, data through 2026-09-22)
---

# Computation

```sql
select countif(is_persistent) as persistent_locations, countif(persistence_tier = '1. Chronic') as chronic_locations
from `mem-311.analytics.agg_persistent_locations`
```

`is_persistent` covers the Chronic and Persistent tiers ([D27](../decisions/D27-persistent-location-tiers.md)).

# Expected values

Data through 2026-09-22:[^build-guide] 8,630 persistent, 1,972 chronic.

Used by [Persistent locations](../metrics/persistent-locations.md).

[^build-guide]: Power BI build guide, section 5
