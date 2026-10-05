---
type: Methodology
title: Backlog reconstruction
description: The open backlog rebuilt day by day from open and close dates, split into age bands, with a burn-in period and a flow-conservation test.
tags: [backlog]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
---

The source has no status history, so the backlog is **reconstructed**. A request is open at the end of each
local day from its opened date until the day before its final closure ([D25](../decisions/D25-backlog-reconstruction.md)).

* **Open requests**: count of open requests at end of day
* **Age** = snapshot date − opened date, banded as < 7, 7–30, 31–90, 91–180 and > 180 days
  ([`dbt/macros/age_band.sql`](../../dbt/macros/age_band.sql))
* **Flow**: requests opened and closed per day. A dbt test
  ([`assert_backlog_conserves_flow`](../../dbt/tests/assert_backlog_conserves_flow.sql)) checks that
  `open(t) − open(t−1) = opened(t) − closed(t)`.
* **Burn-in**: the system went live on 2023-10-16. Until 2024-04-15 the > 180-day band cannot fill, so
  those dates are flagged and excluded from trend statements.
* **Cohorts** ([`agg_backlog_cohorts`](../tables/analytics/agg_backlog_cohorts.md)): for each opening month
  and category, the share closed within 7, 30, 90 and 180 days, and the number still open.

The mass closure of 2025-09-22 is a real backlog exit and is kept in the backlog series. It removed 24,632
requests in one day, so any backlog comparison across that date is annotated ([D28](../decisions/D28-mass-closure-2025-09-22.md)).

The daily series are [`agg_backlog_daily`](../tables/analytics/agg_backlog_daily.md) (per category),
[`agg_backlog_daily_total`](../tables/analytics/agg_backlog_daily_total.md) (all categories) and
[`agg_backlog_age`](../tables/analytics/agg_backlog_age.md) (long format by age band). The measures are
[Open backlog](../metrics/open-backlog.md) and [Backlog age](../metrics/backlog-age.md).
