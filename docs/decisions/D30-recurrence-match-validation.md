---
type: Decision
id: D30
title: "D30 — Manual validation of recurrence matches"
description: "Manual review of an 80-pair stratified sample; headline definition kept, false-match risks documented"
tags: [validation]
area: Validation
status: stable
logged_at: 2026-09-23T12:41:15Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (406,902 records)
    title: Evidence counts, unless the entry states otherwise
  - resource: ../../dbt/analyses/recurrence_validation_sample.sql
---

**Decision.** Keep the primary definition ([D22](D22-primary-recurrence-definition.md)). Record the false-match patterns found in a stratified review.
Do not exclude originals based on their closure outcome; keep it as a filterable dimension.

**Evidence.** `dbt/analyses/recurrence_validation_sample.sql` draws a deterministic sample of four first
recurrences per category (80 pairs). The review of 2026-09-23 found:
* **Location.** 75 of 80 pairs clearly refer to the same place: same address, or nearby points on a
  public-space problem. The questionable five are a pothole pair at the placeholder address
  "0 WINCHESTER RD", three pairs at one park address (1264 Wellsville Rd) where different equipment at a large
  site shares an address, and a graffiti pair at 6140/6141 Poplar Ave, on opposite sides of the street.
* **Problem.** 4 pairs join different problems within one category: a missed bulk-trash pickup followed 73
  days later by a missed recycling pickup, a garbage-cart repair refiled as a recycling-cart repair, a
  construction inspection followed by a curb-ramp request, and a sign followed by a signal.
* **Closure without work.** Roughly one in five originals was closed without work: referred to MLGW or
  TDOT, "private property", "outside city limits", "didn't see anything". There the follow-up report is a
  genuine re-report of an unresolved condition, but not evidence of a failed repair.

A population check shows the last point does not drive the headline. The 90-day rate is 22.1% for all eligible
originals and 21.9% for originals closed as `completed_or_unspecified`. Misrouted originals recur at 45.7%,
mostly because residents refile under the right type. Overall, 71 of 80 sampled pairs (89%) are same-place,
same-problem matches. With n = 80 this is a rough precision estimate, not a measured rate.
