---
type: Decision
id: D22
title: "D22 — Primary recurrence definition and right-censoring"
description: "Primary definition: same category, same address (or ≤25 m for public-space problems), 90 days; right-censored"
tags: [recurrence]
area: Recurrence
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
---

**Decision.** The headline ("primary") definition is: a follower in the **same service category**, opened within
**90 days** after the original closed, at the **same address key**. For *public-space* request types (potholes,
street cleaning, signs, trees, litter, drainage…) a follower within **25 m** also counts. For *property* types
(missed collection, carts, code enforcement, weeds…) the 25 m radius is only used when one of the two
requests lacks an address key. The split is the `location_match_basis` column of the request-type seed
(61 property types, 105 public-space types).

A window of W days is only evaluated for originals closed at least W days before the data cut-off. Recent
closures are *not eligible* rather than counted as "did not recur".

**Evidence.** On residential streets 25 m spans two or three neighbouring houses. For a missed-garbage report
next door, that is a different customer and a different failure. For a pothole or a clogged inlet, a 25 m
offset is ordinary geocoding noise for the same defect. Without right-censoring, every closure in the last 90
days would count as a non-recurrence. That biases the 90-day rate down in exactly the months a dashboard
user looks at first.

**Alternatives.** Every combination of location rule (same address; address or 25/50/100 m), match level
(request type / category / family) and window (30/90/180) is computed in `agg_recurrence_sensitivity`. The
headline number is one stated point in that grid, not the only definition (see [methodology, Phase E](../methodology/recurrence-sensitivity.md)).
