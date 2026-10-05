---
type: Methodology
title: Persistent locations
description: The location entity and the Chronic, Persistent and Repeat tiers for places with three or more condition reports.
tags: [persistence, location]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
  - id: persistent-mart
    resource: ../tables/analytics/agg_persistent_locations.md
    title: agg_persistent_locations, data through 2026-09-22
---

A **location** is an address key, or an 8-character geohash cell (~38 m × 19 m) for requests without one ([D23](../decisions/D23-location-entity.md)).
Address keys whose points span more than 250 m are excluded as spatially inconsistent.

Among locations with 3+ condition reports ([`agg_persistent_locations`](../tables/analytics/agg_persistent_locations.md),
[D27](../decisions/D27-persistent-location-tiers.md)):[^persistent-mart]

| Tier | Rule | Locations |
|---|---|---:|
| Chronic | ≥10 reports, ≥6 active months, ≥4 recurrence cycles | 1,972 |
| Persistent | ≥5 reports, ≥3 active months, ≥2 recurrence cycles | 6,658 |
| Repeat | other locations with 3+ reports | 35,729 |

A **recurrence cycle** is a closure at the location followed within 90 days by a primary-definition recurrence.

The measures are in [Persistent locations](../metrics/persistent-locations.md), shown on the
[Persistent Locations](../dashboard/persistent-locations.md) page.

[^persistent-mart]: agg_persistent_locations, data through 2026-09-22
