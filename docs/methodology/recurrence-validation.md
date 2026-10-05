---
type: Methodology
title: Recurrence validation
description: Manual review of an 80-pair stratified sample - 89% same-place, same-problem matches - and the known false-match risks.
tags: [recurrence, validation]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
  - id: sample
    resource: ../../dbt/analyses/recurrence_validation_sample.sql
    title: Deterministic stratified sample, 4 first recurrences per category
---

An 80-pair stratified sample (4 per category)[^sample] was reviewed by hand ([D30](../decisions/D30-recurrence-match-validation.md)):

* **71 of 80 (89%)** were same-place, same-problem matches.
* 5 had questionable locations: a placeholder "0" house number, a large park sharing one address, and
  opposite sides of a street.
* 4 joined different problems within one category, e.g. a missed bulk pickup followed by a missed recycling
  pickup.
* About one in five originals had been closed **without work** (referred to MLGW or TDOT, private
  property, not found). Restricting to originals closed as completed changes the 90-day rate only from 22.1% to
  21.9%, so this does not drive the headline.

An earlier round of the same review led to [D29](../decisions/D29-street-level-geocodes.md): street-only addresses were producing 0 m "recurrences"
between unrelated potholes on the same street.

# Known false-match risks

* Large sites sharing one address (parks, apartment complexes, shopping centres).
* Placeholder house numbers.
* Categories that merge distinct services: *Missed Collection* covers garbage, recycling and bulk trash.
* Rapid re-reports: 14% of first recurrences arrive less than 1 day after closure and 33% within 7 days. These
  look more like a resident disputing the closure than a new problem, which fits the "never fixed" reading of
  recurrence.

To repeat the review, follow [Review recurrence matches](../playbooks/review-recurrence-matches.md).

[^sample]: Deterministic stratified sample, 4 first recurrences per category
