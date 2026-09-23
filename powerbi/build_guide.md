# Power BI Build Guide

This guide builds the four-page dashboard from the finished BigQuery marts (`mem-311.analytics`). The marts,
measures, theme and map shapes are all in this repo. What remains is assembling visuals in Power BI Desktop,
which can't be scripted here. Allow about 3–4 hours.

The pothole page (plan Page 5) is **not built**. The data cannot support it (decision D15 in
[`docs/decisions.md`](../docs/decisions.md)).

| File | Purpose |
|---|---|
| `measures.dax` | All DAX measures, as a DAX-query-view script with a validation `EVALUATE` |
| `set_measure_properties.csx` | Optional Tabular Editor script that sets format strings and display folders |
| `mem311_theme.json` | Report theme (colour-blind-validated palette, light surface) |
| `shelby_tracts.topo.json` | Census tract shapes for the Shape Map visual (key: `GEOID`) |
| `validation_queries.sql` | SQL that reproduces every headline number for reconciliation |

---

## 1. Connect and load

1. **Get data > Google BigQuery.** Sign in with a Google account that can read project `mem-311`, or choose
   *Service Account Login* and use the key in `.secrets/bq-sa.json` (never commit a `.pbix` alongside the key;
   Power BI does not store the key in the file).
2. Navigate to `mem-311 > analytics` and select the tables below. Choose **Import** (the model is about
   450k fact rows; DirectQuery is unnecessary and slows the percentile measures).

| Table | Rows (Sep 2026) | Load notes |
|---|---:|---|
| `fact_service_requests` | 405k | Remove `address_normalized`, `request_number` if file size matters |
| `fact_request_recurrence` | ~170k | |
| `dim_date` | ~1.5k | Mark as date table on `date_day` |
| `dim_service_category` | 24 | |
| `dim_request_type` | 166 | |
| `dim_location` | ~154k | |
| `dim_census_tract` | 221 | Remove `tract_wkt` unless you use the Icon Map visual |
| `agg_backlog_daily` | ~26k | |
| `agg_backlog_daily_total` | ~1.1k | |
| `agg_backlog_age` | ~108k | |
| `agg_recurrence_sensitivity` | ~820 | |
| `agg_persistent_locations` | ~45k | |
| `agg_service_recurrence` | 20 | Reference/validation only |
| `meta_data_as_of` | 1 | |

3. In Power Query, confirm the BigQuery `BOOL` columns arrived as **True/False**, and `DATE` columns as **Date**
   (not Date/Time). `council_district` can be Whole Number or Text; the guide assumes Whole Number.

## 2. Model

### Relationships

Create these (Model view). All are single-direction, many-to-one, unless stated otherwise.

| From (many) | To (one) | Active | Note |
|---|---|:-:|---|
| `fact_service_requests[opened_date]` | `dim_date[date_day]` | ✔ | Opened / recurrence measures |
| `fact_service_requests[closed_date]` | `dim_date[date_day]` | ✘ | Closed / resolution measures via `USERELATIONSHIP` |
| `fact_service_requests[service_category]` | `dim_service_category[service_category]` | ✔ | |
| `fact_service_requests[request_type_id]` | `dim_request_type[request_type_id]` | ✔ | |
| `fact_service_requests[location_id]` | `dim_location[location_id]` | ✔ | |
| `fact_service_requests[census_tract_geoid]` | `dim_census_tract[census_tract_geoid]` | ✔ | |
| `agg_backlog_daily[snapshot_date]` | `dim_date[date_day]` | ✔ | |
| `agg_backlog_daily[service_category]` | `dim_service_category[service_category]` | ✔ | |
| `agg_backlog_daily_total[snapshot_date]` | `dim_date[date_day]` | ✔ | No category relationship, by design |
| `agg_backlog_age[snapshot_date]` | `dim_date[date_day]` | ✔ | |
| `agg_backlog_age[service_category]` | `dim_service_category[service_category]` | ✔ | |
| `fact_request_recurrence[service_category]` | `dim_service_category[service_category]` | ✔ | |
| `agg_persistent_locations[location_id]` | `dim_location[location_id]` | ✔ | **One-to-one, both directions**, so selecting a persistent location filters the event history |

Leave `agg_recurrence_sensitivity`, `agg_service_recurrence` and `meta_data_as_of` unrelated.

### Column settings

* `dim_date[month_label]` → *Sort by column* `month_start`. `dim_service_category[service_category]` → sort by
  `volume_rank`.
* Age bands (`agg_backlog_age[age_band]`, `fact_service_requests[current_age_band]`) and
  `agg_persistent_locations[persistence_tier]` carry numeric prefixes and sort correctly as text.
* `agg_persistent_locations[recurrence_cycles_band]`: create a 1-column sort helper, or set a custom order
  0, 1, 2-3, 4-9, 10+.
* Data category: `dim_location[latitude]`/`[longitude]` and `agg_persistent_locations[latitude]`/`[longitude]`
  → Latitude / Longitude. `fact_service_requests[zip_code]` → Postal code.
* Hide every key column (`*_id`, `*_geoid`, `snapshot_date` in agg tables) from report view.

### Measures and theme

1. **Home > Enter data**, create table `_Measures` (leave the default column), load it.
2. **DAX query view**: paste `measures.dax`, **Run**. The `EVALUATE` returns one row. Compare it with the
   Validation table in section 5, then click **Update model: Add new measures**. Hide the empty column in
   `_Measures`.
3. Optional: **External tools > Tabular Editor > C# Script**, paste `set_measure_properties.csx`, run and save.
   It sets the format strings and display folders. Without Tabular Editor, set the formats by hand. Use `#,0` for
   counts, `0.0%` for rates and `#,0.0` for day values.
4. **View > Themes > Browse for themes** → `mem311_theme.json`.

---

## 3. Report conventions (all pages)

* Canvas 1280 × 720. A 16 px margin, a 32 px header band and a 3-column grid.
* **Header band:** a page title that states the page's question, plus a text card bound to
  `[Data Through Label]` at the top right.
* **Slicers** sit in one row under the header: date range (`dim_date[date_day]`, *Between*) and service category
  (`dim_service_category[service_category]`, dropdown, multi-select). Sync both slicers across pages 1–3
  (View > Sync slicers).
* **Colour roles** (from the theme; do not recolour per visual):
  * *Opened*: blue `#2a78d6`. *Closed*: orange `#eb6834`.
  * **Age bands** use a single-hue ramp, darker = older: `#86b6ef`, `#5598e7`, `#2a78d6`, `#1c5cab`,
    `#104281` (validated as an ordinal ramp).
  * **Persistence tiers:** Chronic `#104281`, Persistent `#2a78d6`, Repeat `#86b6ef`.
* **No dual-axis charts.** Two measures with different scales get two charts.
* Line width 2 px. Direct-label the last point of each line and turn legends on for 2+ series.
  Keep gridlines to horizontal hairlines only.
* Every page gets a small footnote text box (8 pt, grey) with the page's caveats. The text is given below.

---

## 4. Pages

### Page 1 — System Health
**Title:** *Is the service system keeping pace with demand?*

**Row 1: six KPI cards** (new Card visual, 2 × 3 or 6 across):

| Card | Measure | Subtitle / reference label |
|---|---|---|
| Requests opened | `[Requests Opened]` | "in selected period" |
| Requests closed | `[Requests Closed]` | "by closure date" |
| Current backlog | `[Current Backlog]` | `[% Backlog Over 90 Days]` + " older than 90 days" |
| Median resolution | `[Median Resolution (days)]` | "days, requests closed in period" |
| 90th-percentile resolution | `[P90 Resolution (days)]` | "days" |
| 90-day recurrence | `[Recurrence Rate 90d]` | "of closed problems returned within 90 days" |

**Row 2, left (2/3 width): Opened vs closed by month.** Line chart. X axis `dim_date[month_start]`
(continuous) with tooltip `month_label`. Y axis `[Requests Opened]` and `[Requests Closed]`. Add a
constant-line annotation at 2025-09-22 labelled "Administrative mass closure: 24.6k requests closed in one
day". The closed line spikes there by design (D28).

**Row 2, right (1/3): Net change by month.** Column chart of `[Net Change (Opened - Closed)]` by
`month_start`. Use conditional colours: positive (backlog growing) `#eb6834`, negative `#2a78d6`.

**Row 3, left (1/2): Backlog trend.** Area chart. X `dim_date[date_day]`, Y `[Open Requests (Backlog)]`.
Add a visual-level filter `dim_date[is_backlog_burn_in] = False`, plus the same 2025-09-22 annotation.

**Row 3, right (1/2): Resolution time trend.** Line chart. X `month_start`, Y `[Median Resolution (days)]`
and `[P90 Resolution (days)]` on the **same** axis (both are in days). Use a log scale if P90 dwarfs the median.

**Footnote:** "Backlog is reconstructed from open and close dates; status history is not published, so reopen
cycles are invisible. Resolution times exclude closures with no recorded close time (4%) and the 2025-09-22
mass closure."

**Interaction check:** selecting a month in the opened/closed chart should filter the cards. Set the backlog
trend to *None* for that interaction (Format > Edit interactions), because backlog is a stock.

### Page 2 — Backlog Aging
**Title:** *Where is unresolved work accumulating?*

**Row 1: five cards.**
* `[Open Requests (Backlog)]`: its label reads "at " + `[Backlog Snapshot Date]`.
* `[% Backlog Over 30 Days]`.
* `[% Backlog Over 90 Days]`.
* `[Median Backlog Age (days)]`: add a tooltip explaining that it is blank for multi-category selections.
* `[Backlog Over 90 Days YoY Change %]` next to `[Backlog YoY Change %]`. Title this pair "Old backlog vs
  total backlog, year over year". It is the page's key comparison.

**Row 2, full width: Backlog by age band over time.** Stacked area chart. X `dim_date[date_day]`,
Y `[Open Requests by Age Band]`, Legend `agg_backlog_age[age_band]`. Filter `is_backlog_burn_in = False` and
apply the age-band ramp colours, lightest at the bottom (newest). This is the chart that shows whether old work
is piling up underneath a stable total.

**Row 3, left (1/2): Current backlog by category and age.** Stacked bar chart. Y
`dim_service_category[service_category]`, X `[Open Requests by Age Band]`, Legend `age_band`. Sort by total
descending and show the top 10 categories.

**Row 3, right (1/2): Share older than 90 days over time.** Line chart. X `date_day`, Y
`[% Backlog Over 90 Days]`, with the burn-in filter. Add a second line `[% Backlog Over 30 Days]` on the same
percent axis.

**Optional drill-through page, "Open request list":** a table of `fact_service_requests` filtered to
`is_open = True`. Columns: `request_number`, `dim_request_type[request_type_label]`, `opened_date`,
`current_age_days`, `source_status`, `council_district`. Enable drill-through on `service_category`.

**Footnote:** "Age = days between the report date and the snapshot date. The backlog fills up during the first
six months after the October 2023 system go-live (burn-in, hidden). The 2025-09-22 drop is an administrative
mass closure of mostly >90-day requests, not a surge in completed work."

### Page 3 — Service Durability
**Title:** *Which services are closed quickly but frequently return?*

**Row 1: four cards.** `[Recurrence Rate 30d]`, `[Recurrence Rate 90d]`, `[Recurrence Rate 180d]` and
`[Median Days to Recurrence]`.

**Row 2, left (1/2): Speed vs durability table.** This is the plan's example comparison, built as a Table
visual. Rows: `dim_service_category[service_category]`. Columns:
* `[Median Resolution (days)]`
* `[Recurrence Rate 90d]`: data bars in `#2a78d6`
* `[Median Days to Recurrence]`
* `[Speed vs Durability]`
* `[Recurrence Originals (90d)]`

Add a visual-level filter `[Recurrence Originals (90d)] >= 500` to suppress small-sample noise, and sort by
recurrence rate descending.

**Row 2, right (1/2): Speed vs durability scatter.** Details `service_category`, X
`[Median Resolution (days)]` (log scale), Y `[Recurrence Rate 90d]`, size `[Recurrence Originals (90d)]`.
Add X and Y constant lines at the all-category values; the quadrants then match the `[Speed vs Durability]`
labels. Use a single colour (`#2a78d6`), direct-label the top-left quadrant points, and disable the legend. Per
the palette caps, don't colour by 20 categories.

**Row 3, left (1/3): Time to recurrence.** Column chart of `[Recurrence Relationships]` by
`fact_request_recurrence[recurrence_window]` (0–30 / 31–90 / 91–180). Add a visual-level filter
`recurrence_sequence = 1`.

**Row 3, middle (1/3): Recurrence by Census tract.** Shape Map visual (enable it under Options > Preview
features if it is hidden). Location: `dim_census_tract[census_tract_geoid]`. Colour saturation:
`[Recurrence Rate 90d]`. Under Format > Map settings > Custom map, load `shelby_tracts.topo.json` and map the
key to `GEOID`. Use the sequential blue ramp: minimum `#cde2fb`, maximum `#104281`. Tooltip: `tract_label`,
`[Recurrence Originals (90d)]`.

**Row 3, right (1/3): Definition sensitivity.** Matrix on `agg_recurrence_sensitivity`. Rows `location_rule`,
columns `match_level`, values `[Sensitivity Recurrence Rate]`. Add **single-select** slicers for `scope`
(default "All condition reports") and `window_days` (default 90). Highlight the `Primary (hybrid)` row. This
visual shows that the headline number depends on a stated definition.

**Footnote:** "Recurrence = a related request (same service category) at the same address, or within 25 m for
street and public-space problems, after the original was closed. Only requests observed for the full window
count. It is an operational proxy: a return report may be an unfixed problem, a poor repair or a new incident.
See docs/methodology.md."

### Page 4 — Persistent Locations
**Title:** *Where are chronic problems concentrated?*

Page-level filter: `agg_persistent_locations[persistence_tier]` is not "Excluded (inconsistent location)".

**Row 1: four cards.** `[Persistent Locations]`, `[Chronic Locations]`,
`[% of Recurrence Cycles at Persistent Locations]` and `[Locations With Repeat Requests]`.

**Row 2, left (3/5): Location map.** Azure Maps visual, bubble layer. Latitude/Longitude from
`agg_persistent_locations`. Size `condition_requests`, legend `persistence_tier` with the tier colours. Add a
visual filter `is_persistent = True` so about 8.6k points render. Tooltip: `display_address`,
`dominant_category`, `recurrence_cycles`, `first_request_date`, `latest_request_date`,
`unresolved_requests`. Include a tier slicer.

**Row 2, right (2/5): Ranked location table.** Table on `agg_persistent_locations`, sorted by
`persistence_rank`. Columns: `persistence_rank`, `display_address`, `dominant_category`,
`condition_requests`, `recurrence_cycles`, `active_months`, `first_request_date`, `latest_request_date`,
`median_resolution_days` and `unresolved_requests`. Use a Top N filter (100 by `persistence_rank`,
ascending). Clicking a row filters the event history through the one-to-one relationship.

**Row 3, left (1/3): Recurrence cycle distribution.** Column chart. Count of
`agg_persistent_locations[location_id]` by `recurrence_cycles_band`, in a single colour.

**Row 3, right (2/3): Event history for the selected location.** Table on `fact_service_requests`. Columns:
`opened_date`, `dim_request_type[request_type_label]`, `service_category`, `status_group`, `closed_date`,
`resolution_days`, `closure_outcome` and `has_recurrence_90d`. Sort by `opened_date`. Title it with a
measure: `"History: " & SELECTEDVALUE(agg_persistent_locations[display_address], "select a location")`.

**Footnote:** "A location is an address or, where no address exists, a ~38 × 19 m grid cell. Persistent = 5+
problem reports, active in 3+ months and 2+ close-then-return cycles. Chronic = 10+, 6+ and 4+. Apartment
complexes and businesses with one address can appear as single locations. Volumes reflect reporting behaviour
as well as conditions."

### Page 5 — Pothole Detection Analysis
Not built (D15). Only 207 of 18,734 pothole requests are AI-detected, in bursts, and citizen versus staff
intake cannot be separated. If desired, add a text box on the Methodology page saying so. The
`is_ai_detected` flag on `fact_service_requests` remains available for ad-hoc filtering.

---

## 5. Validation

Run the `EVALUATE` in `measures.dax` (no filters). It should match `validation_queries.sql`. The values below
are from the extract of 2026-09-23 (data through 2026-09-22). After a refresh, re-run the SQL rather than
trusting these numbers.

| Measure | Expected |
|---|---:|
| Requests Opened | 405,398 |
| Requests Closed | 383,369 |
| Median Resolution (days) | 6.6 |
| P90 Resolution (days) | 46.6 |
| % Resolved Within 7 Days | 46.7% |
| % Resolved Within 30 Days | 75.6% |
| Current Backlog | 21,181 |
| % Backlog Over 30 Days | 72.8% |
| % Backlog Over 90 Days | 43.8% |
| Median Backlog Age (days) | 75 (±1, approximate quantile) |
| Recurrence Rate 30d / 90d / 180d | 14.1% / 22.1% / 28.3% |
| Median Days to Recurrence | 30.3 |
| Persistent Locations / Chronic | 8,630 / 1,972 |
| Headline Recurrence Rate (sensitivity table) | 22.1% (must equal Recurrence Rate 90d) |

Then spot-check one category. Select *Potholes & Pavement* and compare with
`select * from mem-311.analytics.agg_service_recurrence where service_category = 'Potholes & Pavement'`.
The 90-day rate should be 15.7% and the median resolution 1.6 days (originals only; the page measure uses all
closed requests, so small differences are expected).

## 6. Refresh

The pipeline is `uv run python scripts/run_pipeline.py` (extract, then `dbt build`). After it runs, click
Refresh in Power BI Desktop, or schedule a refresh in the Power BI Service. Scheduled refresh uses the
service-account credential; no gateway is needed for BigQuery.
