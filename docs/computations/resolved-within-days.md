---
type: Attested Computation
title: Resolved within 7 and 30 days
description: Share of requests resolved within 7 and 30 days, counting only opening cohorts old enough to have been observed that long.
tags: [responsiveness]
status: stable
runtime: bigquery
parameters: []
executor:
  resource: ../references/bigquery/run.py
  receipt: [job_id, location, executed_sql, parameters, result]
attester:
  resource: ../references/bigquery/attest.py
dax_measures: ["% Resolved Within 7 Days", "% Resolved Within 30 Days"]
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
    safe_divide(countif(days_open_to_close <= 7 and opened_date <= date_sub(m.data_through_date, interval 7 day)),
                countif(opened_date <= date_sub(m.data_through_date, interval 7 day)))  as pct_within_7d,
    safe_divide(countif(days_open_to_close <= 30 and opened_date <= date_sub(m.data_through_date, interval 30 day)),
                countif(opened_date <= date_sub(m.data_through_date, interval 30 day))) as pct_within_30d
from `mem-311.analytics.fact_service_requests`, `mem-311.analytics.meta_data_as_of` m
```

Requests younger than N days at the cut-off are left out of both numerator and denominator, so recent periods
are not understated ([D26](../decisions/D26-responsiveness-counting-rules.md)).

# Expected values

Data through 2026-09-22:[^build-guide] 46.7% within 7 days, 75.6% within 30 days.

Used by [Resolved within 7 and 30 days](../metrics/resolved-within-days.md).

[^build-guide]: Power BI build guide, section 5
