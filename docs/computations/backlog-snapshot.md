---
type: Attested Computation
title: Backlog at the data cut-off
description: Open requests, share older than 30 and 90 days, median and P90 age, and count older than 180 days on the last complete day.
tags: [backlog]
status: stable
runtime: bigquery
parameters: []
executor:
  resource: ../references/bigquery/run.py
  receipt: [job_id, location, executed_sql, parameters, result]
attester:
  resource: ../references/bigquery/attest.py
dax_measures: ["Current Backlog", "% Backlog Over 30 Days", "% Backlog Over 90 Days", "Median Backlog Age (days)", "P90 Backlog Age (days)", "Backlog Over 180 Days"]
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
select snapshot_date, open_requests, pct_open_over_30d, pct_open_over_90d, median_age_days, p90_age_days, open_over_180d
from `mem-311.analytics.agg_backlog_daily_total`
where snapshot_date = (select data_through_date from `mem-311.analytics.meta_data_as_of`)
```

The backlog is a stock: every measure reads one day, here the last complete local day ([D25](../decisions/D25-backlog-reconstruction.md)).

# Expected values

Data through 2026-09-22:[^build-guide] 21,181 open, 72.8% older than 30 days, 43.8% older than 90 days,
median age 75 days (±1; the DAX median is an approximate quantile).

Used by [Open backlog](../metrics/open-backlog.md) and [Backlog age](../metrics/backlog-age.md).

[^build-guide]: Power BI build guide, section 5
