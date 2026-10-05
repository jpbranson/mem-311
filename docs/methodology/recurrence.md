---
type: Methodology
title: Recurrence (durability)
description: How a closed request is judged to have recurred - location matching, category similarity, time windows, right-censoring and the primary definition.
tags: [recurrence]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
---

> A closed request **recurred** when a related condition report appeared at the same place after it was
> closed.

Recurrence is an **operational proxy**. A return report may mean the problem was never fixed, was fixed
poorly, or has genuinely happened again. It does not by itself establish service failure.

# Location matching (Phases A and B)

**Phase A — addresses.** Addresses are normalized by
[`dbt/macros/normalize_address.sql`](../../dbt/macros/normalize_address.sql): uppercase; leading business
names, city/state/ZIP, unit designators and punctuation removed; street types and directionals abbreviated;
house-number ranges reduced to the first number. The **address key** is the normalized address without its
trailing street type. It exists only when there is a non-zero house number ([D23](../decisions/D23-location-entity.md)). 96.4% of in-window requests
have one.

**Phase B — coordinates.** A coordinate is usable for matching only if it is inside Shelby County, is not a
geocoder default point ([D17](../decisions/D17-valid-coordinates.md)) and is not a street-level geocode ([D29](../decisions/D29-street-level-geocodes.md)). Candidate pairs within 100 m are found
with a grid-cell join followed by an exact distance check ([D24](../decisions/D24-spatial-matching-grid-cells.md)). Radii of 25, 50 and 100 m are all evaluated.

# Category similarity (Phase C)

Three match levels, from strictest to loosest:

1. **Request type**: identical source type
2. **Category**: same standardized service category (**primary**)
3. **Family**: same recurrence family, a group of categories where a follow-up report plausibly describes the
   same underlying problem. For example, `street_surface` = potholes, pavement and cave-ins ([D13](../decisions/D13-request-type-categories-seed.md)).

# Time windows (Phase D)

The window starts at the original's closure. Recurrence is evaluated at 30, 90 and 180 days. An original is
only evaluated for window W if it was closed at least W days before the cut-off (**right-censoring**, [D22](../decisions/D22-primary-recurrence-definition.md)).
Rates for different windows therefore have slightly different denominators.

# Primary definition

The headline recurrence rate uses **same category, 90 days**. The location rule is **same address key**,
plus a **25 m radius for public-space problems** such as potholes, drainage, signs, trees and litter ([D22](../decisions/D22-primary-recurrence-definition.md)).
Property-based problems such as missed collection, carts, code enforcement and weeds match on the address
only, because 25 m on a residential street reaches the neighbours' houses.

Who can be an original, and who a follower, is set out in [D21](../decisions/D21-recurrence-original-eligibility.md).

# Where it is computed

* [`int_recurrence_candidates`](../tables/intermediate/int_recurrence_candidates.md): every pair under the
  loosest definition; each stricter definition is a filter on it ([D24](../decisions/D24-spatial-matching-grid-cells.md)).
* [`int_recurrence_originals`](../tables/intermediate/int_recurrence_originals.md) and
  [`int_recurrence_outcomes`](../tables/intermediate/int_recurrence_outcomes.md): eligible originals and
  their censoring-aware window flags.
* [`fact_request_recurrence`](../tables/analytics/fact_request_recurrence.md): one row per primary-definition
  relationship.
* [`agg_service_recurrence`](../tables/analytics/agg_service_recurrence.md): durability by category.

How robust the headline is to the definition is in [Recurrence sensitivity](recurrence-sensitivity.md); how
often a match is a real repeat is in [Recurrence validation](recurrence-validation.md). The measures are in
[Recurrence rate](../metrics/recurrence-rate.md).
