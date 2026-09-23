# Methodology

How each metric is defined, and why. Individual judgment calls, with evidence, are numbered in
[`decisions.md`](decisions.md) (D01–D30). Column definitions are in [`data_dictionary.md`](data_dictionary.md).
Figures below come from the extraction of 2026-09-23, with data through 2026-09-22.

## Populations

| Population | Definition | Size |
|---|---|---:|
| All requests | Every live record in layer 0 of the city FeatureServer | 406,902 |
| Analysis window | Reported on or after 2023-10-01, excluding the 1,502-record bulk-load artifact (D09, D16) | 405,398 |
| Condition reports | Request types that report a problem at a place, not a transaction such as a cart application (D14) | 364,850 |
| Recurrence originals | Closed condition reports with a recorded closure, not duplicates or mass-closed, with a usable location (D21) | 299,839 |
| Eligible for the 90-day rate | Originals closed ≥90 days before the cut-off (D22) | 265,983 |

The 166 source request types are mapped to 24 service categories and 8 service groups in a reviewed seed,
`dbt/seeds/request_type_map.csv` (D13).

## 1. Responsiveness

* **Resolution time** = closed_at − opened_at, in local time (America/Chicago, D10). It is null when the
  closure time is imputed (D11), negative (D12) or part of the 2025-09-22 mass closure (D28).
* **Median / P90 resolution** are reported for requests *closed* in a period (D26).
* **% resolved within 7 / 30 days** are reported for the cohort *opened* in a period, and only once the whole
  cohort has been observable that long (D26).
* About 17% of requests (mostly SeeClickFix intake) have a date-only opened timestamp, so hour-level
  resolution is overstated by up to a day for them. All reporting is in days, and medians are robust to this
  (D10).

## 2. Backlog

The source has no status history, so the backlog is **reconstructed**. A request is open at the end of each
local day from its opened date until the day before its final closure (D25).

* **Open requests**: count of open requests at end of day
* **Age** = snapshot date − opened date, banded as < 7, 7–30, 31–90, 91–180 and > 180 days
  (`dbt/macros/age_band.sql`)
* **Flow**: requests opened and closed per day. A dbt test checks that
  `open(t) − open(t−1) = opened(t) − closed(t)`.
* **Burn-in**: the system went live on 2023-10-16. Until 2024-04-15 the > 180-day band cannot fill, so
  those dates are flagged and excluded from trend statements.
* **Cohorts** (`agg_backlog_cohorts`): for each opening month and category, the share closed within 7, 30,
  90 and 180 days, and the number still open.

The mass closure of 2025-09-22 is a real backlog exit and is kept in the backlog series. It removed 24,632
requests in one day, so any backlog comparison across that date is annotated (D28).

## 3. Durability (recurrence)

> A closed request **recurred** when a related condition report appeared at the same place after it was
> closed.

Recurrence is an **operational proxy**. A return report may mean the problem was never fixed, was fixed
poorly, or has genuinely happened again. It does not by itself establish service failure.

### Location matching (Phases A and B)

**Phase A — addresses.** Addresses are normalized by `dbt/macros/normalize_address.sql`: uppercase; leading
business names, city/state/ZIP, unit designators and punctuation removed; street types and directionals
abbreviated; house-number ranges reduced to the first number. The **address key** is the normalized address
without its trailing street type. It exists only when there is a non-zero house number (D23). 96.4% of
in-window requests have one.

**Phase B — coordinates.** A coordinate is usable for matching only if it is inside Shelby County, is not a
geocoder default point (D17) and is not a street-level geocode (D29). Candidate pairs within 100 m are found
with a grid-cell join followed by an exact distance check (D24). Radii of 25, 50 and 100 m are all evaluated.

### Category similarity (Phase C)

Three match levels, from strictest to loosest:

1. **Request type**: identical source type
2. **Category**: same standardized service category (**primary**)
3. **Family**: same recurrence family, a group of categories where a follow-up report plausibly describes the
   same underlying problem. For example, `street_surface` = potholes, pavement and cave-ins (D13).

### Time windows (Phase D)

The window starts at the original's closure. Recurrence is evaluated at 30, 90 and 180 days. An original is
only evaluated for window W if it was closed at least W days before the cut-off (**right-censoring**, D22).
Rates for different windows therefore have slightly different denominators.

### Primary definition

The headline recurrence rate uses **same category, 90 days**. The location rule is **same address key**,
plus a **25 m radius for public-space problems** such as potholes, drainage, signs, trees and litter (D22).
Property-based problems such as missed collection, carts, code enforcement and weeds match on the address
only, because 25 m on a residential street reaches the neighbours' houses.

### Sensitivity (Phase E)

`agg_recurrence_sensitivity` recomputes the rate for every combination of rule, level and window. The 90-day
results for all condition reports:

| Location rule | Request type | **Category** | Family |
|---|---:|---:|---:|
| Same address only | 16.7% | 20.9% | 24.1% |
| Address or within 25 m | 19.7% | 25.2% | 30.0% |
| Address or within 50 m | 25.2% | 33.9% | 42.4% |
| Address or within 100 m | 38.3% | 52.6% | 65.3% |
| **Primary (hybrid)** | — | **22.1%** | — |

At the category level the rate is fairly stable at the strict end of the grid: 21–25% for same address or
25 m. It more than doubles at 100 m, where the match starts to capture neighbouring properties and busy
corridors. The headline sits deliberately at the strict end. A dbt test (`assert_sensitivity_is_monotonic`) checks
that a wider radius or a broader match level never finds fewer recurrences.

### Validation

An 80-pair stratified sample (4 per category; `dbt/analyses/recurrence_validation_sample.sql`) was reviewed
by hand (D30):

* **71 of 80 (89%)** were same-place, same-problem matches.
* 5 had questionable locations: a placeholder "0" house number, a large park sharing one address, and
  opposite sides of a street.
* 4 joined different problems within one category, e.g. a missed bulk pickup followed by a missed recycling
  pickup.
* About one in five originals had been closed **without work** (referred to MLGW or TDOT, private
  property, not found). Restricting to originals closed as completed changes the 90-day rate only from 22.1% to
  21.9%, so this does not drive the headline.

An earlier round of the same review led to D29: street-only addresses were producing 0 m "recurrences"
between unrelated potholes on the same street.

**Known false-match risks.** Large sites sharing one address (parks, apartment complexes, shopping centres).
Placeholder house numbers. Categories that merge distinct services: *Missed Collection* covers garbage,
recycling and bulk trash. Rapid re-reports: 14% of first recurrences arrive less than 1 day after closure and 33%
within 7 days. These look more like a resident disputing the closure than a new problem, which fits the
"never fixed" reading of recurrence.

## 4. Persistent locations

A **location** is an address key, or an 8-character geohash cell (~38 m × 19 m) for requests without one (D23).
Address keys whose points span more than 250 m are excluded as spatially inconsistent.

Among locations with 3+ condition reports (`agg_persistent_locations`, D27):

| Tier | Rule | Locations |
|---|---|---:|
| Chronic | ≥10 reports, ≥6 active months, ≥4 recurrence cycles | 1,972 |
| Persistent | ≥5 reports, ≥3 active months, ≥2 recurrence cycles | 6,658 |
| Repeat | other locations with 3+ reports | 35,729 |

A **recurrence cycle** is a closure at the location followed within 90 days by a primary-definition recurrence.

## 5. Geography

Requests are assigned to Census tracts by point-in-polygon (221 Shelby County tracts), to council districts
from the source field, and to ZIP codes (D18). No neighborhood geography is used, because no defensible
boundary source is available.

Per-capita rates are **not** computed. 311 volume reflects who reports as well as what is broken, so volume is
not treated as a measure of need. Geographic comparisons use rates *within* reported requests: resolution time,
backlog age, and recurrence rate. Comparisons in [`findings.md`](findings.md) use only areas with ≥500 eligible
originals, to avoid small-sample noise.

## 6. Pothole detection (stretch goal) — omitted

AI-detected potholes can be identified (1,098 AI-detected records, 207 of them potholes), but they are 1.1% of
pothole requests and arrive in irregular bursts. That cannot support a before/after analysis of a shift to
automated detection (D15).

## Limitations

* **Reporting bias.** 311 records are reported problems, not all problems. Areas and services with lower
  reporting look healthier than they are.
* **Recurrence ambiguity.** A return report can mean an unfixed problem, a poor repair or a new incident.
  Recurrence is a proxy, validated at roughly 89% precision on a small sample.
* **Location accuracy.** Addresses are free text and coordinates sometimes fall back to street-level or
  default points. Mitigations: D17, D23, D29.
* **Category changes.** Department assignments drifted in late 2025. Categories come from the request type,
  which is stable, not the department (D13).
* **Closure meaning.** A closed ticket is the city's statement, not a verified fix. 16,883 closures have no
  closure date (D11), and one day of mass closure removed 24,632 requests (D28).
* **No status history.** Reopen/close cycles cannot be seen, so the backlog assumes each request was open
  continuously until its final closure (D25).
* **Short history.** The current system starts in October 2023, which gives about three years of data and only
  two complete seasonal cycles.
