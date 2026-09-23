# Decision Log

Every judgment call made while building the project, in the order it was made. Metric definitions and how
the pieces fit together are in [`methodology.md`](methodology.md). Each entry records what was
decided, the evidence behind it, the alternatives considered and what it affects downstream. Evidence counts
come from the full extraction of 2026-09-23 (406,902 records) unless stated otherwise.

| # | Area | Decision |
|---|------|----------|
| D01 | Source | Use layer 0 of the city FeatureServer; read-only access only |
| D02 | Privacy | Drop contact, owner, staff-name and free-text fields at extraction |
| D03 | Privacy | Redact phone numbers and emails in the one retained free-text field |
| D04 | Coordinates | Use feature geometry reprojected to WGS84, not the X/Y attributes |
| D05 | Ingestion | Keyset pagination on OBJECTID |
| D06 | Warehouse | Append-only raw table with batch metadata; dedupe in staging |
| D07 | Warehouse | Full snapshot plus watermark-based incremental; deletes inferred from snapshots |
| D08 | Keys | OBJECTID is the record key; INCIDENT_NUMBER is the business key |
| D09 | Coverage | Analysis window starts 2023-10-01 |
| D10 | Time | Convert timestamps to America/Chicago; treat midnight-UTC reported dates as date-only |
| D11 | Status | Status is authoritative for open/closed; closure time falls back through RESOLVED_DATE then last_edited_date |
| D12 | Status | Negative resolution times are set to null, not zeroed |
| D13 | Categories | Standardize the 166 request types into 24 categories via a reviewed seed, not DEPARTMENT |
| D14 | Categories | Flag administrative request types as not eligible for recurrence |
| D15 | Pothole | **Stretch analysis not feasible**: AI-detected potholes are identifiable but too sparse; no Page 5 |
| D16 | Quality | Exclude a bulk-load artifact (1,502 records at one address on one day) |
| D17 | Location | Coordinates are valid only inside Shelby County and away from geocoder default points |
| D18 | Geography | Use Census tracts (spatial join), council district (source field) and ZIP; no neighborhoods |
| D19 | Closure | Classify closure outcomes heuristically from resolution text |
| D20 | Tooling | Python 3.12 via uv; dbt-bigquery with service-account auth from an env var |
| D21 | Recurrence | Only closed, dated, non-duplicate condition reports with a usable location can be an original |
| D22 | Recurrence | Primary definition: same category, same address (or ≤25 m for public-space problems), 90 days; right-censored |
| D23 | Location | Location entity = address key when a house number exists, else an 8-character geohash cell |
| D24 | Performance | Spatial matching via a grid-cell equi-join plus exact distance check, not a bare `ST_DWITHIN` join |
| D25 | Backlog | Reconstruct the daily backlog from open/close dates; flag a 181-day burn-in after go-live |
| D26 | Responsiveness | Count events in the month they happen; resolution percentiles by closure month |
| D27 | Persistence | Chronic / Persistent / Repeat tiers from request count, active months and recurrence cycles |
| D28 | Quality | Treat the 2025-09-22 administrative mass closure as a backlog exit, not a resolution |
| D29 | Location | Street-level geocodes (street name without house number) are excluded from distance matching |
| D30 | Validation | Manual review of an 80-pair stratified sample; headline definition kept, false-match risks documented |

---

## D01 — Source: layer 0 of the 311 FeatureServer, read-only

**Decision.** Extract from
`https://311.memphistn.gov/server/rest/services/311/311_Request_Map_PROD/FeatureServer/0` ("311 Requests").
Layers 2–4 ("Reported Today", "Last 7 Days", "Transfer Pending") are filtered views of the same records and are
ignored. Table 1 (`CoM_311_Notes`) is not ingested (see D02).

**Evidence.** Layer 0 holds 406,902 records; its description is "all 311 requests created by 311 Support
center staff and citizens". The service advertises `Create,Update,Editing` capabilities to anonymous callers.
This project only issues `query` requests and sends an identifying User-Agent.

**Consequence.** Other open-data mirrors (e.g. data.memphistn.gov) were not used, so the pipeline depends on
this endpoint's schema. The extractor fails fast if any retained field disappears.

## D02 — Privacy: drop personal and free-text fields at extraction

**Decision.** The following fields are never written anywhere, not even the raw layer:

* Resident contact: `CONTACT_NAME`, `CONTACT_EMAIL`, `CONTACT_PHONE`, `Anonymous`-related contact info
* Owner / utility customer: `CONTACT_NAME_FIRST` (owner name), `Owner_*`, `MLGW_CUSTOMER`, `MLGW_CONTACT1/2`,
  `MLGW_EMAIL`, `MLGW_PremiseCode`, `MLGW_CustCode`, `MLGW_EstDate`, `MLGW_STATUS`, `SWF_RATE`, `SWF_STATUS`
* Free text written by residents or staff: `REQUEST_SUMMARY`, `REQUEST_NOTES`, `JOB_NOTES`, `SCF_Description`,
  `Transfer_Notes`, `Supervisor_Notes`
* Staff identities: `created_user`, `last_edited_user`, `ASSIGNED_TO`, `SUPERVISOR`, `NOTIFICATION`
* The related notes table `CoM_311_Notes`

**Evidence.** The public endpoint returns contact emails on 139,662 records and phone numbers on 251,278.
A scan of pothole records found phone numbers, emails and caller names embedded in `SCF_Description` and
`REQUEST_SUMMARY` (e.g. "per the caller (name, phone)").

**Alternatives.** Keeping everything in a locked-down raw dataset (the plan says "preserve source data as
received") was rejected. None of these fields are needed for the analysis, and a portfolio repo plus Power BI
file are the wrong places for them.

**Consequence.** Two flags that need free text are derived *before* the fields are dropped: `is_ai_detected`
(from `REQUEST_SUMMARY` / `SCF_URL`) and `is_seeclickfix` (from `SCF_URL`). `SCF_URL` itself is also dropped.
The raw layer therefore deviates deliberately from "as received". Intake channel (staff vs. web) cannot be
recovered because `created_user` is masked for most records in query results anyway: group-by statistics
report 154,733 `Esri_Anonymous`, but feature queries return blank.

## D03 — Privacy: redact phone numbers and emails in `RESOLUTION_SUMMARY`

**Decision.** Keep `RESOLUTION_SUMMARY` (city-written closure text, needed for D19), with phone- and
email-shaped substrings replaced by `[phone]` / `[email]`.

**Evidence.** The most common summaries are boilerplate ("Picked up", "Serviced by Public Works", referral
text to TDOT / MLGW), but several include department phone numbers. Names could not be ruled out.

## D04 — Coordinates: geometry reprojected to WGS84, not X/Y attributes

**Decision.** Request `outSR=4326` and read `geometry.x/y` as longitude/latitude. Ignore the `X` and `Y`
attribute columns.

**Evidence.** The `X`/`Y` attributes mix coordinate systems. Some rows hold degrees (−90.07, 35.05) and others
hold Tennessee State Plane feet (778547, 307054). The layer's native CRS is EPSG:2274.

## D05 — Ingestion: keyset pagination on OBJECTID

**Decision.** Page with `OBJECTID > last ORDER BY OBJECTID`, 3,000 per page (the service `maxRecordCount`),
rather than `resultOffset`.

**Reason.** Offset paging over a table that is being edited during the run can skip or duplicate records.
Keyset paging cannot. The run also fails if an OBJECTID repeats across pages, or if the extracted count falls
below the server's `returnCountOnly`. For full runs it also fails if the count exceeds that value by more than
1%.

## D06 — Warehouse: append-only raw table; staging picks latest version

**Decision.** `raw.memphis_311_requests` is append-only, partitioned on `_ingested_at` and clustered on
`OBJECTID`. Each run adds `_batch_id`, `_ingested_at`, `_source` and `_extract_mode`. `raw.ingestion_batches`
records expected/extracted/loaded counts and the `last_edited_date` high-water mark. Staging takes the latest
row per OBJECTID.

**Alternatives.** MERGE into a current-state raw table would be smaller, but it loses the history of edits,
which D07's deletion logic and any audit of status changes need. At ~400k rows (~250 MB) per full snapshot,
storage cost is negligible.

## D07 — Incremental strategy: watermark + periodic full snapshot

**Decision.** `--mode incremental` pulls `last_edited_date >= high_water_mark − 48h`. `--mode full`
re-snapshots everything. Staging treats a record as live if it appears in the latest full snapshot, or in any
incremental batch loaded after that snapshot.

**Evidence.** Records are edited long after creation. 260,510 of 373,272 closed records were edited more than
a day after closure. There were city-wide bulk edits: over 24k records were touched in single minutes on
2025-09-22, 2025-09-23 and 2025-09-30. Deletions cannot be seen by a watermark query. Full extraction takes
about 2 minutes, so a weekly full snapshot is cheap.

## D08 — Keys

**Decision.** `OBJECTID` is the record key through raw and staging. `INCIDENT_NUMBER` (the city's "Service
Request Number") is exposed as the business key `request_number`.

**Evidence.** OBJECTID, INCIDENT_NUMBER and GlobalID are each unique across all 406,902 rows; no nulls.
`LINKED_SR` ("Duplicate SR") is null on every record, so source-declared duplicate links are unavailable.

## D09 — Coverage: analysis window starts 2023-10-01

**Decision.** Staging keeps every record. Marts, rates and trends use requests reported on or after
2023-10-01 (America/Chicago).

**Evidence.** Only 2 records predate October 2023 (one each in June and August 2023). Monthly volume is
6,289 in 2023-10 and 8,000–17,000 thereafter. The city system appears to have gone live mid-October 2023:
most request types' first record is 2023-10-16. October 2023 is therefore a partial month and is flagged in
the monthly mart, not dropped.

## D10 — Time zones and date-only reported timestamps

**Decision.** All timestamps are stored UTC in raw and converted to `America/Chicago` in staging. When
`REPORTED_DATE` is exactly 00:00:00 UTC it is treated as **date-only**: the local opened date is the UTC
calendar date, and the opened timestamp is local midnight of that date. These rows get
`opened_is_date_only = true`.

**Evidence.** 68,253 records (16.8%) have `REPORTED_DATE` at exactly midnight UTC; 67,795 of them are
SeeClickFix intake. For those, `created_date` falls 13–25 hours after `REPORTED_DATE` (deciles 812–1,500
minutes). That pattern fits a local calendar date stored as UTC midnight. A naive conversion would move them
to 18:00/19:00 on the *previous* local day.

**Consequence.** Hour-level resolution times for date-only requests are overstated by up to one day. The
dashboard's resolution metrics are reported in days, and medians are robust to this. `opened_is_date_only` is
carried to the fact table so hour-level analysis can exclude these rows.

## D11 — Open/closed status and imputed closure time

**Decision.**
* `Closed`, `closed` and `Resolved` → closed. `Open`, `In Progress`, `In Progress – Part of Ongoing Case`,
  `Back to Department`, `Back to MCSC` and `Pending Litigation` → open. A null status is closed if a close
  date exists, otherwise open.
* `closed_at = coalesce(Closed_Date, RESOLVED_DATE)` for closed records. If both are missing,
  `last_edited_date` is used as an **imputed** closure time (`closed_at_is_imputed = true`).
* Imputed closures count for backlog exit but are **excluded from resolution-time metrics**.
* A record whose status is open is open, even if it carries a `Closed_Date` (it was reopened).

**Evidence.** 16,883 `Closed` records have no `Closed_Date` (4.1%). They cluster in 2025-08/09 and
2025-11 through 2026-01, and again in 2026-04/05, mostly Solid Waste. Many of the Dec-2025/Jan-2026 records
also lack `DEPARTMENT`, which suggests a system change. Their `last_edited_date` values spread over days and
weeks after reporting, consistent with real closure edits. The exception is 994 closed in one sweep on
2025-09-19. `DAYS_OLD` is null on 92% of closed records and inconsistent with close dates where present, so it
is unused. 287 `Open` and ~3,700 in-progress records carry a `Closed_Date`, consistent with reopening.

**Alternatives.** Dropping the 16,883 records from the backlog would leave them open forever and inflate the
old backlog by ~17k. Keeping them open was rejected for the same reason.

## D12 — Negative resolution times

**Decision.** If `closed_at < opened_at`, resolution time is null and `has_invalid_resolution_time = true`.
Values are not clipped to zero. Date-only records are compared at date grain.

**Evidence.** 951 records have `Closed_Date < REPORTED_DATE`.

## D13 — Standardized request categories via a reviewed seed

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

## D14 — Administrative request types are not recurrence-eligible

**Decision.** `is_condition_report = false` for request types that are transactions, not reports of a
problem at a place. These are *Cart & Account Requests*, *Traffic Engineering Requests* (new signs, speed-hump
requests), *Damage Claims*, *General / Miscellaneous*, Drain Maintenance "PREVENTATIVE MAINTENANCE" and
"SITE CHECK" (proactive work orders), and "Bulk Trash Validation". These requests appear in responsiveness and
backlog metrics but never as the original or the recurring request in recurrence analysis.

**Reason.** A resident who applies for a second cart or a fee waiver has not had a problem "recur". Counting
these would inflate Solid Waste recurrence.

## D15 — Pothole stretch analysis: **not feasible; omitted**

**Decision.** Do not build the pothole detection analysis or the Power BI Page 5. Keep `is_ai_detected` as an
attribute on the fact table and document the finding.

**Evidence.**
* AI-detected records *can* be identified. 1,098 records carry the summary "Issue detected by Google AI
  Detection system and approved." and/or an image link on `memphis.egen.ai`. Of those, 758 are Drain Inlet
  Clogged, 207 Potholes and 120 Roadside Litter.
* Only **207 of 18,734 pothole requests (1.1%)** are AI-detected, and they come in bursts: 52 in 2025-01,
  59 in 2025-05, 37 in 2025-09, 35 in 2025-08, and single digits in other months. That pattern looks like a
  pilot run on occasional imagery batches, not a shift in how potholes enter the system.
* The source cannot separate citizen from staff/proactive reports. `GROUP_NAME` ("CITIZEN"/"MEMPHIS") is
  inconsistent and drifts over time. `created_user` is masked in query results. Only SeeClickFix intake (41%
  of potholes) is identifiable.
* The pre-period is short. Pothole records begin 2023-10, about 15 months before the first AI records.

**Plan criterion applied.** "If automated versus citizen-generated records cannot be distinguished reliably,
document that limitation and omit this analysis." Automated records *are* distinguishable. But the question
asked is whether a *transition* toward automated detection changed what 311 observes, and 207 bursty records
cannot support it. A before/after comparison would be dominated by seasonality and the 2025 system changes
(D11).

## D16 — Exclude a bulk-load artifact

**Decision.** Flag `is_bulk_artifact` on any group of ≥100 requests with the same address, request type and
reported date. Exclude flagged records from every mart.

**Evidence.** 1,502 `MCSC-Miscellaneous` records at "4532 Jamerson Rd" were all reported on 2024-06-03 at one
coordinate. No other group of this kind reaches 100. Left in, this address would top the persistent-location
ranking and distort the June 2024 open/close trend.

## D17 — Valid coordinates

**Decision.** `has_valid_coordinates = true` only when the point is inside Shelby County (Census county
polygon) **and** is not a geocoder default point. A default point is a coordinate shared by ≥50 requests whose
address is null or spread across ≥10 distinct addresses. Records without valid coordinates are kept for
responsiveness and backlog metrics but excluded from spatial matching.

**Evidence.** 24 records have no geometry. 1,088 sit at one point in Arkansas (−92.509, 34.154), a geocoding
fallback. One Memphis point (−90.050, 35.208) holds 181 records, 61 with null address. In total, 405,652 of
406,902 records fall inside a Memphis-area bounding box.

## D18 — Geography

**Decision.** Assign each request to:
* **Census tract.** Point-in-polygon against `bigquery-public-data.geo_census_tracts.census_tracts_tennessee`
  (Shelby County, 221 tracts).
* **City council district.** The source `cd_name` (1–7), as recorded at intake.
* **ZIP code.** The source `ZipCode`, trimmed to 5 digits.

No neighborhood geography is used.

**Evidence.** `neigh_desc` is populated on only 456 records, and no defensible neighborhood boundary file is
available in the warehouse. `cd_name` is populated on 91%; its companion `cd_desc` is almost always null and
sometimes contradicts `cd_name`, so `cd_desc` is ignored.

**Caveat.** Per-capita rates are not computed (see methodology: reporting bias).

## D19 — Heuristic closure outcomes

**Decision.** Classify each closed request into `closure_outcome` from `RESOLUTION_SUMMARY` and
`RESOLUTION_CODE` text rules. The outcomes are:
* `duplicate`: "already been reported", "duplicate"
* `referred`: TDOT, MLGW, private property, "purview"
* `no_issue_found`: "no potholes found", "no violation", "not out", "unable to locate"
* `misrouted`: "wrong service", "routed incorrectly", "reopened by system"
* `needs_info`: "please contact…to provide additional information"
* `completed_or_unspecified`: everything else

Duplicate closures are excluded as *original* requests in recurrence analysis. A duplicate cannot be
"resolved and then recur".

**Caveat.** 142k closed records have no summary and fall into `completed_or_unspecified`. The outcome is a
descriptive dimension, not a validated measure.

## D20 — Tooling

**Decision.** Python 3.12 (pinned via `.python-version`) managed by uv. dbt-core 1.12 with dbt-bigquery.
The dbt profile uses `method: service-account` with `keyfile: {{ env_var('GOOGLE_APPLICATION_CREDENTIALS') }}`,
so no credential path is committed. dbt writes custom schemas as literal dataset names (`staging`,
`intermediate`, `analytics`) via a `generate_schema_name` override.

**Reason.** uv initially resolved Python 3.14, which dbt 1.12 does not officially support.

## D21 — Who can be the original in a recurrence relationship

**Decision.** An original must be a condition report (D14) opened in the analysis window, closed with a
recorded closure time (not imputed, D11), with a non-negative resolution time (D12), not closed as a
duplicate (D19) or in the mass closure (D28), not a load artifact (D16), and with an address key or a valid
match point (D23, D29). The follower (the "recurring" request) must be a condition report in the same
recurrence family, opened after the original closed.

**Evidence.** 299,839 of 345,016 closed condition reports qualify. The largest exclusions are the mass
closure (24,632 requests of all types), imputed closure times (16,883 of all types) and duplicate closures
(4,956).

**Reason.** Recurrence is measured from the moment the city said the problem was dealt with. Without a
trustworthy closure time there is no starting point for the window.

## D22 — Primary recurrence definition and right-censoring

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
headline number is one stated point in that grid, not the only definition (see methodology, Phase E).

## D23 — Location entity

**Decision.** A request's location is its **address key** (normalized address with a non-zero house number,
trailing street type removed) when available. Otherwise it is the **8-character geohash** (~38 m × 19 m) of a
valid, non-street-level coordinate. An address key whose points are more than 250 m apart is flagged
`is_spatially_inconsistent` and excluded from persistent-location rankings.

**Evidence.** 390,669 of 405,398 in-window requests (96.4%) have an address key. 10,520 more fall into
8,143 grid cells. 4,209 have no usable location. 661 of 144,499 address locations are spatially
inconsistent: points more than 250 m apart share one address key.

**Normalization** (`dbt/macros/normalize_address.sql`) drops a leading business name before a house number
("Dollar General, 1234 Getwell Rd"), city/state/ZIP, unit designators and punctuation. It abbreviates
street types and directionals and reduces a house-number range to its first number. "2785 CLAUDETTE" and
"2785 CLAUDETTE RD" share a key.

## D24 — Spatial matching via grid cells

**Decision.** Candidate pairs within 100 m are found with an equi-join on ~105 m grid cells. Each follower is
expanded to its 3×3 cell neighbourhood, and an exact `ST_DWITHIN` check on the joined rows follows. Address
matches come from a separate equi-join on the address key. The union of both is the candidate table
(`int_recurrence_candidates`). Every stricter definition is a filter on it.

**Evidence.** A direct `ST_DWITHIN` join carrying the family and time-window predicates did not finish within
10 minutes.

## D25 — Backlog reconstruction and burn-in

**Decision.** The source publishes no status history. A request is therefore assumed open at the end of every
local day from its opened date to the day before its final closure (or to the data cut-off). Imputed closures
(D11) are used as exit dates. Backlog age = snapshot date − opened date. Snapshots before
**2024-04-15** (181 days after the 2023-10-16 go-live) are flagged `is_burn_in_period`. Before that date the
>180-day band cannot yet contain anything and the total is still filling up from zero.

**Consequence.** Reopen/close cycles are invisible: a request closed, reopened and closed again is treated as
open for the whole span. A dbt test (`assert_backlog_conserves_flow`) checks that the day-over-day change in
open requests equals opened − closed.

## D26 — Responsiveness counting rules

**Decision.** In the monthly mart, `requests_opened` counts the month of opening and `requests_closed` the month
of closure. Median and P90 resolution time describe requests **closed** in the month, using only recorded,
valid, non-mass closures. `pct_resolved_within_7d/30d` describe the **opening cohort** and stay null until the
month's last day is at least 7 or 30 days before the cut-off.

**Reason.** Measuring resolution time for requests *opened* in a month makes recent months look faster than
they are, because only the quickly closed requests have closed yet.

## D27 — Persistent-location tiers

**Decision.** Among locations with 3+ condition reports:
* **Chronic**: ≥10 condition reports, active in ≥6 distinct months, ≥4 recurrence cycles
* **Persistent**: ≥5 condition reports, ≥3 active months, ≥2 recurrence cycles
* **Repeat**: everything else with 3+ reports

A recurrence cycle is a closure at the location followed within 90 days by a primary-definition recurrence.
`is_persistent` covers Chronic and Persistent.

**Evidence.** 44,818 locations have 3+ condition reports: 1,972 Chronic, 6,658 Persistent, 35,729 Repeat
and 459 excluded as spatially inconsistent. The thresholds separate "busy address" from "problem keeps
coming back". A location with 20 unrelated one-off reports and no recurrence cycles stays in Repeat.

## D28 — The 2025-09-22 administrative mass closure

**Decision.** A closure day is a **mass closure** if it has ≥10× the median daily number of closures and ≥80%
of its closures are more than 30 days old. Requests closed on such a day get `closure_outcome =
'administrative_mass_closure'`. They leave the backlog on that day, but they have no resolution time and
cannot be recurrence originals.

**Evidence.** Exactly one day qualifies. On 2025-09-22, 24,632 requests were closed, most of them aged. The
total backlog fell from 35,860 (2025-09-01) to 10,438 (2025-10-01). This coincides with the city-wide bulk
edits noted in D07. Counting these as resolutions would put a spike of multi-month resolution times into
September 2025. Counting them as recurrence originals would add thousands of "closures" that describe no
service event.

## D29 — Street-level geocodes

**Decision.** A request whose address is a street name with no house number (not an intersection), sharing a
coordinate with 2+ other such requests, is a **street-level geocode**. It keeps its coordinates for mapping but
gets no `match_point`, so it cannot drive distance-based recurrence matches.

**Evidence.** Found during manual validation. Requests giving only a street name geocode to one point per
street, so every pothole on that street "recurred" within 0 m. 4,091 requests are flagged.

## D30 — Manual validation of recurrence matches

**Decision.** Keep the primary definition (D22). Record the false-match patterns found in a stratified review.
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
