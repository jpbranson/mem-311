---
type: Decision
id: D13
title: "D13 — Standardized request categories via a reviewed seed"
description: "Standardize the 166 request types into 24 categories via a reviewed seed, not DEPARTMENT"
tags: [categories]
area: Categories
status: stable
logged_at: 2026-09-23T07:47:49Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T07:47:49Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (406,902 records)
    title: Evidence counts, unless the entry states otherwise
  - resource: ../../dbt/seeds/request_type_map.csv
---

**Decision.** `dbt/seeds/request_type_map.csv` maps each of the 166 source `REQUEST_TYPE` values to a
`service_category` (24 values), a `service_group` (8), a `recurrence_family` and an `owning_unit` parsed from
the type prefix. `DEPARTMENT` is not used for categorisation. Unmapped new types surface as
`Unmapped` and trip a dbt warning.

**Evidence.** `DEPARTMENT` is null for 56,672 records and blank for 2,023, mostly after late 2025. It also
disagrees with the type prefix, e.g. some `PW (SM)-Potholes` records are assigned to Drain Maintenance.
`CATEGORY` is null on 99.99% of records. The type prefix (`SWM-`, `CE-`, `PW (SM)-`, `EMI-`…) is stable and
always present.

**Judgment calls inside the mapping** (reviewable in the CSV):
* Missed pickups (garbage, recycling, bulk, "Service Quality") form one category, *Missed Collection*.
  Physical cart problems (repair, missing, burnt, switched) are *Cart Repair & Replacement*. Deliveries,
  applications, fees, waivers and new starts are *Cart & Account Requests*.
* EMI Cave-In / Street Sinking and Drain Maintenance "CAVITY" types form *Cave-ins & Street Sinking*, in the
  `street_surface` family with potholes rather than with sewer.
* Abandoned vehicles (Police) join code-enforcement vehicle violations under *Vehicle Violations*.
* Recurrence families group categories where a follow-up report plausibly describes the same underlying
  problem. `blight` covers weeds, dumping, code violations, vehicles, graffiti and carts-out.
  `street_surface` covers potholes, pavement and cave-ins. `drainage_sewer` covers drainage and sewer.
  `solid_waste_collection` covers missed collection and cart repair.
