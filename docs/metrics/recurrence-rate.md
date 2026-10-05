---
type: Metric
title: Recurrence rate
description: Share of eligible closed condition reports followed by a related report at the same place within 30, 90 or 180 days, under the primary definition.
tags: [recurrence]
status: stable
dax_measures: ["Recurrence Rate 30d", "Recurrence Rate 90d", "Recurrence Rate 180d", "Recurrence Originals (90d)", "Recurred Within 90d", "Median Days to Recurrence", "Recurrence Relationships", "Speed vs Durability", "Sensitivity Recurrence Rate", "Headline Recurrence Rate"]
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: dax
    resource: ../../powerbi/measures.dax
    title: DAX measures
  - id: build-guide
    resource: ../../powerbi/build_guide.md
    title: Power BI build guide, section 5 (expected values, data through 2026-09-22)
---

# Definition

Primary definition ([D22](../decisions/D22-primary-recurrence-definition.md)): same service category; same address key, or within 25 m for public-space
problems; within W days of the original's closure. Only originals closed at least W days before the cut-off
are eligible (right-censoring). Who can be an original is set out in [D21](../decisions/D21-recurrence-original-eligibility.md).

* **Recurrence Rate Wd** = count of `has_recurrence_Wd` ÷ count of `is_recurrence_eligible_Wd` on
  [`fact_service_requests`](../tables/analytics/fact_service_requests.md). Date context follows the original's
  report date.
* **Median Days to Recurrence**: median `days_to_first_recurrence` among 180-day-eligible originals that recurred.
* **Recurrence Relationships**: rows of [`fact_request_recurrence`](../tables/analytics/fact_request_recurrence.md).
* **Speed vs Durability**: labels a category as fast/slow and returns/durable against the all-category median
  resolution and 90-day rate.
* **Sensitivity / Headline Recurrence Rate** read
  [`agg_recurrence_sensitivity`](../tables/analytics/agg_recurrence_sensitivity.md); the headline cell must
  equal Recurrence Rate 90d.

# Sanctioned computation

Sanctioned SQL: [Recurrence rates](../computations/recurrence-rates.md).

# Value

All dates and categories, data through 2026-09-22: 14.1% / 22.1% / 28.3% at 30 / 90 / 180 days; median 30.3
days to recurrence.[^build-guide]

Method: [Recurrence](../methodology/recurrence.md), [sensitivity](../methodology/recurrence-sensitivity.md),
[validation](../methodology/recurrence-validation.md). Shown on
[Service Durability](../dashboard/service-durability.md).

[^build-guide]: Power BI build guide, section 5
