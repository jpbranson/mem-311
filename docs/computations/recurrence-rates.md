---
type: Attested Computation
title: Recurrence rates
description: Primary-definition recurrence rate at 30, 90 and 180 days over right-censored originals, and the median days to first recurrence.
tags: [recurrence]
status: stable
runtime: bigquery
parameters: []
executor:
  resource: ../references/bigquery/run.py
  receipt: [job_id, location, executed_sql, parameters, result]
attester:
  resource: ../references/bigquery/attest.py
dax_measures: ["Recurrence Rate 30d", "Recurrence Rate 90d", "Recurrence Rate 180d", "Median Days to Recurrence"]
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
    safe_divide(countif(has_recurrence_30d), countif(is_recurrence_eligible_30d))   as recurrence_rate_30d,
    safe_divide(countif(has_recurrence_90d), countif(is_recurrence_eligible_90d))   as recurrence_rate_90d,
    safe_divide(countif(has_recurrence_180d), countif(is_recurrence_eligible_180d)) as recurrence_rate_180d,
    (select percentile_cont(days_to_first_recurrence, 0.5) over () from `mem-311.analytics.fact_service_requests`
      where is_recurrence_eligible_180d and has_recurrence_180d limit 1)            as median_days_to_recurrence
from `mem-311.analytics.fact_service_requests`
```

Only originals observed for the whole window count (right-censoring, [D22](../decisions/D22-primary-recurrence-definition.md)). The 90-day rate must equal the
headline cell of the sensitivity grid ([D22](../decisions/D22-primary-recurrence-definition.md), [Recurrence sensitivity](../methodology/recurrence-sensitivity.md)).

# Expected values

Data through 2026-09-22:[^build-guide] 14.1% / 22.1% / 28.3% at 30 / 90 / 180 days; median 30.3 days to
recurrence.

Used by [Recurrence rate](../metrics/recurrence-rate.md).

[^build-guide]: Power BI build guide, section 5
