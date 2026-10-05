---
type: Dashboard Page
title: "Page 4 — Persistent Locations"
description: "Where are chronic problems concentrated? Tier cards, location map and ranking, recurrence-cycle distribution and the selected location's request history."
resource: ../../powerbi/build_guide.md
tags: [power-bi, persistence]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: build-guide
    resource: ../../powerbi/build_guide.md
    title: Power BI build guide, section 4, Page 4
---

**Question:** *Where are chronic problems concentrated?*[^build-guide]

Page filter: `persistence_tier` is not "Excluded (inconsistent location)".

# Visuals

| Row | Visual | Measures |
|---|---|---|
| 1 | Four cards: persistent and chronic locations, % of recurrence cycles at persistent locations, locations with repeat requests | [Persistent locations](../metrics/persistent-locations.md) |
| 2 | Location map (Azure Maps bubbles, persistent only, ~8.6k points, tier colours); ranked location table | `condition_requests`, `recurrence_cycles` |
| 3 | Recurrence-cycle distribution (column); event history of the selected location (table) | Unresolved at Location |

Selecting a ranked location filters the event history through the one-to-one relationship between
`agg_persistent_locations` and `dim_location`.

# Footnote

> A location is an address or, where no address exists, a ~38 × 19 m grid cell. Persistent = 5+ problem
> reports, active in 3+ months and 2+ close-then-return cycles. Chronic = 10+, 6+ and 4+. Apartment complexes
> and businesses with one address can appear as single locations. Volumes reflect reporting behaviour as well as
> conditions.

Findings: [F2](../findings/F2-missed-collection-drives-repeat-work.md),
[F4](../findings/F4-repeat-activity-is-concentrated.md). Method:
[Persistent locations](../methodology/persistent-locations.md), [D23](../decisions/D23-location-entity.md), [D27](../decisions/D27-persistent-location-tiers.md).

[^build-guide]: Power BI build guide, section 4, Page 4
