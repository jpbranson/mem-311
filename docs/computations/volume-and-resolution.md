---
type: Attested Computation
title: Volume and resolution time
description: Requests opened and closed, and median and P90 resolution time in days, over all dates and categories.
tags: [responsiveness]
status: stable
runtime: bigquery
parameters: []
executor:
  resource: ../references/bigquery/run.py
  receipt: [job_id, location, executed_sql, parameters, result]
attester:
  resource: ../references/bigquery/attest.py
dax_measures: ["Requests Opened", "Requests Closed", "Median Resolution (days)", "P90 Resolution (days)"]
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
select
    count(*)                                                                         as requests_opened,
    countif(status_group = 'closed' and not has_invalid_resolution_time)             as requests_closed,
    (select percentile_cont(resolution_days, 0.5) over () from `mem-311.analytics.fact_service_requests`
      where resolution_days is not null limit 1)                                     as median_resolution_days,
    (select percentile_cont(resolution_days, 0.9) over () from `mem-311.analytics.fact_service_requests`
      where resolution_days is not null limit 1)                                     as p90_resolution_days
from `mem-311.analytics.fact_service_requests`
```

Mirrors the DAX measures with no slicers applied. Resolution time is blank for imputed, invalid and mass
closures ([D11](../decisions/D11-open-closed-status-and-imputed-closure.md), [D12](../decisions/D12-negative-resolution-times.md), [D28](../decisions/D28-mass-closure-2025-09-22.md)), so the percentiles skip them.

# Expected values

Data through 2026-09-22:[^build-guide] 405,398 opened, 383,369 closed, median 6.6 days, P90 46.6 days.
Re-run after a refresh rather than trusting these numbers.

Used by [Requests opened and closed](../metrics/request-volume.md) and
[Resolution time](../metrics/resolution-time.md).

[^build-guide]: Power BI build guide, section 5
