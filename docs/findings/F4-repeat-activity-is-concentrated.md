---
type: Finding
id: F4
title: "F4 — A small share of places generates a large share of repeat activity"
description: The 4.4% of repeat locations in the Chronic tier account for 29% of recurrence cycles; Chronic and Persistent together (19%) account for 64%.
tags: [persistence]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: findings
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/findings.md
    title: Findings as one file, before the OKF conversion
  - id: persistent-mart
    resource: ../tables/analytics/agg_persistent_locations.md
    title: agg_persistent_locations, data through 2026-09-22
---

Of 44,818 locations with three or more condition reports:[^persistent-mart]

* The **1,972 Chronic locations (4.4%)** account for **29%** of all recurrence cycles.
* Chronic and Persistent locations together (**19%** of these locations) account for **64%**.
* The top **1%** of locations by recurrence cycles hold **12.7%** of cycles but only 4.6% of requests.

Repeat activity is concentrated well beyond what request volume alone would suggest. That supports treating
chronic locations as a work list of their own rather than as a stream of independent tickets.

Tiers are defined in [Persistent locations](../methodology/persistent-locations.md) ([D27](../decisions/D27-persistent-location-tiers.md)) and shown on the
[Persistent Locations](../dashboard/persistent-locations.md) page.

[^persistent-mart]: agg_persistent_locations, data through 2026-09-22
