# Power BI Build Guide

This guide builds the four-page dashboard from the finished BigQuery marts (`mem-311.analytics`). The marts,
measures, theme and map shapes are all in this repo. What remains is assembling visuals in Power BI Desktop,
which can't be scripted here. Allow about 3–4 hours.

The pothole page (plan Page 5) is **not built**. The data cannot support it (decision D15 in
[`docs/decisions/D15-pothole-analysis-omitted.md`](../docs/decisions/D15-pothole-analysis-omitted.md)).

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
* `agg_persistent_locations[recurrence_cycles_band]` → sort by `recurrence_cycles_band_order`. Don't build the
  sort helper as a DAX calculated column that reads the band: Sort by column makes the band depend on the
  helper, so Power BI reports a circular dependency.
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

#### [Implementation details - 2026-09-26] Set the canvas and position the grid

Click a blank area of the report page so no visual is selected, then open **Format page > Canvas settings**.
Choose **Custom** and enter Width **1280** and Height **720**, or select the matching 16:9 size if offered.
**View > Page view > Fit to page** changes only the viewing scale; it does not set the canvas dimensions.
See [Microsoft's page-size settings](https://learn.microsoft.com/en-us/power-bi/create-reports/power-bi-report-display-settings).

The margin and three-column grid are layout conventions, not a built-in three-column page setting.
Keep content between X = **16** and **1264**, and between Y = **16** and **704**. With 16 px gaps between
columns, this is one usable arrangement (coordinates and widths are in canvas pixels):

| Column | X position | Width |
|---|---:|---:|
| Left | 16 | 405 |
| Middle | 437 | 406 |
| Right | 859 | 405 |

A full-width visual is 1248 px wide. A visual spanning the first two columns is 827 px wide, including
their internal gap. These are starting dimensions; use Section 4's half-width or 3/5-width divisions for
rows that specify them. Reserve Y = **16–48** for the 32 px header band, then place the slicer row below
it with a gap. Reserve space for the footnote before sizing the chart rows.

Select each visual and use **Format visual > General > Properties** to enter its position and size
(the controls may be grouped under **Position** and **Size**). **View > Gridlines/Snap to grid** and
**Format > Align/Distribute** help align objects; snapping does not automatically create this layout.
If snapping prevents an exact position, turn it off and enter the coordinates. See [Microsoft's alignment tools](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-gridlines-snap-to-grid).

#### [Implementation details - 2026-09-26] Build the header and bind the data-through text

Use **Insert > Text box** for the page question given under **Title** in Section 4. Place it at the left
of the header. The page tab's name and a visual's General > Title are separate from this page heading.
The header band is reserved space; it does not require a coloured rectangle behind it.

For the top-right text, add a separate **Card** visual and put the existing `[Data Through Label]` measure
in its **Value/Values** well. Leave Categories empty. Show the callout value, hide its measure-name label
(called **Label** or **Category label**, depending on version), and turn off the visual title, border and
card background if they make it look like a KPI tile. Use a small callout font, for example 10 pt, and
right-align the text. Reduce the card's padding and give it enough width or text wrapping to display the
full sentence within the header without overlapping the page question.

The displayed text is the **measure value**, not the literal characters `[Data Through Label]` typed into
a text box. It includes both the date and the source wording. This measure already exists in `measures.dax`;
no new subtitle measure is needed for the header. It reads the disconnected `meta_data_as_of` table, so
the date represents data coverage and stays unchanged when a reader changes the date/category slicers.
It changes when the refreshed metadata changes, not simply when the report is opened.
See [Microsoft's Card visual setup](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-card).

#### [Implementation details - 2026-09-26] Create and sync the two common slicers

1. Add the standard **Slicer** visual with `dim_date[date_day]`. Choose the actual date column in the field
   menu, not **Date hierarchy**. Under **Format visual > Visual > Slicer settings > Options**, select
   **Between** (older versions also expose this in the slicer's header menu). Keep both date inputs visible.
2. Add a second Slicer with `dim_service_category[service_category]`. Set its style to **Dropdown**.
   Under **Selection**, turn **Single select** off. Turn **Multi-select with CTRL** off if present so a
   reader can select several categories without holding Ctrl. Give the slicers clear titles such as
   "Date range" and "Service category", and align them in the row below the header.
   See [Microsoft's Slicer visual settings](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-slicer-visual).
3. Open **View > Sync slicers**, select the date slicer, and check both **Sync** and **Visible** for
   Pages 1, 2 and 3. Repeat with the service-category slicer. Sync shares the selection; Visible displays
   the control. A synced but hidden slicer still filters its page. Leave both unchecked for Page 4 and
   the optional request-list drillthrough page, as explained in Section 4.
4. Change the date range on Page 1 and navigate to Pages 2 and 3 to check the selection matches. Repeat
   with two service categories, then clear the test selections. If you copy an existing slicer and Power BI
   asks whether to sync the copy, choose Sync and verify the page checkboxes rather than creating a second
   independent filter on the same field.
   See [Microsoft's slicer synchronization instructions](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-slicers#sync-and-use-slicers-on-other-pages).

Synchronization does not create model relationships or override a measure's DAX. Section 4 explains the
exceptions: Current Backlog ignores the date selection, the recurrence-relationships chart lacks a date
relationship, and the sensitivity matrix uses its own disconnected scope/window slicers. Do not add
relationships just to make those visuals respond to the common slicers.

#### [Implementation details - 2026-09-26] Apply the specified colour roles consistently

Import `mem311_theme.json` using Section 2 before styling the visuals. The current JSON provides a default
palette and general formatting, but it does **not** bind colours to measure names, individual age-band
values or persistence-tier values. Its categorical palette also contains colours outside the blue age ramp.
The instruction above to avoid recolouring means to keep the stated roles consistent; assigning those
specified colours in a visual is necessary when its defaults do not match.

For opened/closed charts, add Requests Opened before Requests Closed so the theme's first two colours
are blue and orange. Verify the mapping, including on charts showing just one measure. In the visual's
**Lines/Columns/Bars > Colours** or **Data colours** settings, select the individual series to assign the
specified hex value if needed. In older versions, enable **Show all** to expose individual categories.
See [Microsoft's explanation of how theme colours are assigned to series](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-report-themes#understand-how-theme-colors-are-used-by-the-report).

Use these exact mappings for the repository's age-band labels:

| Age-band value | Colour |
|---|---|
| `1. Under 7 days` | `#86b6ef` |
| `2. 7-30 days` | `#5598e7` |
| `3. 31-90 days` | `#2a78d6` |
| `4. 91-180 days` | `#1c5cab` |
| `5. Over 180 days` | `#104281` |

Likewise, map `1. Chronic` to `#104281`, `2. Persistent` to `#2a78d6`, and `3. Repeat` to `#86b6ef`.
Use the same assignments in every chart/map that displays those values. Check the age-band stack order
as well as the legend: the newest/lightest band belongs at the bottom of the stacked area chart. Copying
a correctly formatted visual is a useful starting point, but recheck the mapping after changing its fields.
Importing a theme does not erase colours already set directly on a visual; inspect existing overrides.

#### [Implementation details - 2026-09-26] Configure shared axes, line labels and gridlines

For two compatible measures, put both in the same chart's **Y-axis** well and leave **Secondary Y-axis**
empty. Opened/closed counts can share an axis; median/P90 resolution can share a days axis. A count and a
percentage need separate charts under this report's convention, even if Power BI offers a secondary axis.

Select a line chart and open **Format visual > Visual**:

* Under **Lines**, set **Width/Stroke width = 2** for all series; check any per-series overrides.
* Turn **Series labels** on to put the series names at the line ends. Keep their right-side placement
  and, where available, match the label text colour to the series. These identify the lines; **Data labels**
  display numeric values and are a separate setting. Allow room at the right so labels are not clipped.
* Turn **Legend** on for two or more series. With multiple measures in Y-axis, their names supply the
  legend automatically; no extra field is needed in the Legend well. Keep the legend off for one series.
* Under **Gridlines** (or the axis settings in older versions), enable horizontal lines only, using a
  light colour such as the theme's `#e1e0d9` and 1 px width. Disable vertical gridlines.

See [Microsoft's line formatting and series-label controls](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-line-chart).
If a visual/version has no Series labels control, keep the legend and use hover values until an equivalent
endpoint-label option is available; fixed text boxes beside the last point will not track filter changes.
After applying a date filter, check that the labels still identify the visible lines. Canvas alignment
gridlines from View are editing aids and are separate from these chart gridlines.

#### [Implementation details - 2026-09-26] Add readable page footnotes

Use **Insert > Text box**, paste the corresponding page's **Footnote** wording from Section 4, and format
it in Segoe UI, **8 pt**, using the theme's grey `#52514e`. Keep it inside the bottom/side margins and allow
enough height for all wrapped lines. Review it at **Actual size** as well as Fit to page; do not shrink the
text further to make a chart fit. A footnote is a static page text box, separate from a visual subtitle or
hover tooltip. It needs no DAX measure.

Reuse the positions and formatting across pages, but replace each page's question and caveat text with
the specified wording. Before finishing a page, confirm the entire source/date label and footnote are
visible and that neither overlaps the slicers or charts.

---

## 4. Pages

#### [Implementation - 2026-09-26] How to use these notes

The original page specifications below are preserved. These additions supply UI steps, helper measures and
clarifications. Power BI versions use slightly different field-well and formatting names; use the named
setting's equivalent in your version. A **Card visual** can contain several individual **cards**.
All helper measures shown here are additions to create in Power BI, not measures already supplied by
`measures.dax`: select `_Measures`, choose **Modeling > New measure**, and enter each definition separately.
Do not paste an entire block containing multiple definitions into one measure's formula bar.

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

#### [Implementation - 2026-09-26] Card names, values and individual subtitles

Keep the six numeric measures in the Card visual's **Value/Values** well. Each creates one card. Leave
**Categories** empty: it splits the cards by data categories and is not where their names or subtitles go.
For the compact layout, use **Format visual > Visual > Multi-card layout** to arrange three columns and two
rows; two columns and three rows also works but leaves less height for the charts below. Keep the measures
in the table's order, with Requests Opened before Requests Closed.

There are three distinct pieces of text:

| Piece | Example | Implementation |
|---|---|---|
| Main card label | Requests opened | Keep the measure-name label visible. In the Values well, use the measure's menu > **Rename for this visual** for the friendly name in the table. This does not rename the model measure. |
| Callout value | 385K | The numeric measure already in Values. Use the callout's formatting controls for units and decimals. |
| Supporting line | in selected period | A **Reference label** assigned to that particular card. |

**General > Title > Subtitle** applies to the entire visual, so it cannot supply six different subtitles
inside one grid. See [Microsoft's visual title settings](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-customize-title-background-and-legend).

For a consistent implementation of the supporting lines, create these six text measures, one at a time:

```dax
Requests Opened Subtitle = "in selected period"

Requests Closed Subtitle = "by closure date"

Current Backlog Subtitle =
    VAR share =
        CALCULATE ( [% Backlog Over 90 Days], REMOVEFILTERS ( dim_date ) )
    RETURN
        IF (
            ISBLANK ( share ),
            "No backlog age data",
            FORMAT ( share, "0.0%" ) & " older than 90 days"
        )

Median Resolution Subtitle = "days, requests closed in period"

P90 Resolution Subtitle = "days"

Recurrence Rate 90d Subtitle = "of closed problems returned within 90 days"
```

The backlog subtitle deliberately removes the date filter: `[Current Backlog]` also ignores that filter.
Using `[% Backlog Over 90 Days]` directly would let a historical date selection change the percentage while
the main number remains current. Service-category filters still apply to both. The table's `+` denotes
the intended display; DAX joins text with `&`.

To attach the text measures:

1. Select the grid, click the **Format visual** paintbrush, and open **Visual > Reference labels**.
2. Under **Apply settings to**, select the Requests Opened card (called **Select series** in older versions).
3. Drag `[Requests Opened Subtitle]` into **Add label**, then select that label for formatting.
4. Turn the reference label's **Title** off and its **Value** on; leave **Detail** off. Keep the main card's
   measure-name label on. The subtitle is the text measure's value, not its field name.
5. Repeat for the other five cards, selecting each main measure and its corresponding subtitle. These
   helpers belong in Reference labels, not the main Values well, where they would create extra cards.
6. In **Cards > Layout**, place the reference-label section below the callout. Adjust callout size and
   padding if the longer sentence is clipped; increase the visual's height if necessary.

See Microsoft's [per-card reference-label walkthrough](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-card#add-reference-labels)
and [Title, Value and Detail explanation](https://powerbi.microsoft.com/en-us/blog/new-cards-reference-labels-public-preview/).

Set the **numeric** measures' model formats as specified in Section 2: rates `0.0%`, days `#,0.0`, counts
`#,0`. Thus a recurrence value near `0.22` displays near `22.0%`; do not multiply the measure by 100.
Use **Display units = None** for percentages and days; counts may use Auto/thousands if desired. Keep
numeric measures numeric, using `FORMAT` only in the text helpers. This same card setup applies on later
pages; add supporting text only where specified.

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

#### [Implementation - 2026-09-26] Date axes, annotations and conditional colours

* In each date-axis field menu, choose the actual `month_start` or `date_day` column rather than **Date
  hierarchy**. Set the X axis to **Continuous**, and put `dim_date[month_label]` in the monthly chart's
  **Tooltips** well.
* For the mass-closure annotation, select the chart and use **Analytics > X-axis constant line > Add**
  (or the equivalent **Reference lines** control). Set the date to **2025-09-22** and enable a label with
  the supplied wording. A Y-axis constant line marks a request count, not a date. On the monthly chart,
  September's value is plotted at September 1; the September 22 marker identifies the event within that
  month, not a separate daily data point. If your version lacks the X-axis option, add the dated explanation
  as a nearby text box rather than a manually positioned line that can drift when the date range changes.
  See [Microsoft's Analytics pane reference](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-analytics-pane).
* On the net-change chart, open the column colour's **fx** control, choose **Rules**, and base the rules on
  `[Net Change (Opened - Closed)]`. Use numeric thresholds: values greater than zero are orange; values
  below zero are blue. Zero has no column height. This implements the specified colour roles.
* Drag `dim_date[is_backlog_burn_in]` into **Filters on this visual** for the backlog chart and select
  **False**. Repeat on the specified Page 2 time-series visuals; a page-level burn-in filter would also
  change other metrics' selected period.
* Use a logarithmic resolution axis only when all plotted, nonblank values are positive. Otherwise keep
  the linear scale; do not remove zero-day resolutions just to enable the log axis.

**Footnote:** "Backlog is reconstructed from open and close dates; status history is not published, so reopen
cycles are invisible. Resolution times exclude closures with no recorded close time (4%) and the 2025-09-22
mass closure."

**Interaction check:** selecting a month in the opened/closed chart should filter the cards. Set the backlog
trend to *None* for that interaction (Format > Edit interactions), because backlog is a stock.

#### [Implementation - 2026-09-26] Check the intended card interactions

Select the opened/closed chart first, then **Format > Edit interactions**. Choose **Filter** over the card
visual and **None** over the backlog trend. Test by clicking a month, then clear the selection.
The period-based card values should respond; `[Current Backlog]` and its subtitle should stay at the latest
data date because their DAX removes `dim_date` filters. The recurrence card follows the original request's
opened date, while the closed/resolution cards use closure date, as defined in `measures.dax`.

### Page 2 — Backlog Aging
**Title:** *Where is unresolved work accumulating?*

**Row 1: five cards.**
* `[Open Requests (Backlog)]`: its label reads "at " + `[Backlog Snapshot Date]`.
* `[% Backlog Over 30 Days]`.
* `[% Backlog Over 90 Days]`.
* `[Median Backlog Age (days)]`: add a tooltip explaining that it is blank for multi-category selections.
* `[Backlog Over 90 Days YoY Change %]` next to `[Backlog YoY Change %]`. Title this pair "Old backlog vs
  total backlog, year over year". It is the page's key comparison.

#### [Implementation - 2026-09-26] Card count, snapshot label and median tooltip

The five bullets above specify **six values**: four individual KPIs plus a two-value comparison. To retain
the grouping, use a four-measure Card visual and a separate two-measure Card visual containing the two
YoY measures. Apply the shared comparison title under **General > Title** on the two-measure visual.
Give its individual cards the friendly labels "Backlog older than 90 days" and "Total backlog".

Create this helper and attach it only to `[Open Requests (Backlog)]` using the Page 1 reference-label steps:

```dax
Backlog Snapshot Subtitle =
    VAR snapshot = [Backlog Snapshot Date]
    RETURN
        IF (
            ISBLANK ( snapshot ),
            "No snapshot in selected period",
            "at " & FORMAT ( snapshot, "mmm d, yyyy" )
        )
```

Unlike Page 1's Current Backlog, this card and subtitle follow the last selected date, capped at the data
cut-off. Keep the label "Open requests (backlog)" and display the date beneath its value.

For the median's tooltip, create the text measure below and add it to the card visual's **Tooltips** well:

```dax
Median Backlog Age Note =
    "Available for one category or all categories; blank for a subset of multiple categories."
```

The all-category selection has a precomputed median and is not blank. A normal tooltip field applies to
the whole Card visual; use a separate median Card visual if the explanation must appear only over that
card. Blank YoY values can also be legitimate when the prior-year comparison has no usable denominator.

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

#### [Implementation - 2026-09-26] Top categories and snapshot behaviour

On the category bar chart, open the `service_category` filter under **Filters on this visual**, choose
**Top N**, enter **Top 10**, and use `[Open Requests (Backlog)]` as **By value**. Click **Apply filter**,
then sort the chart by its total backlog descending. This selects categories by total backlog across all
age bands, while `[Open Requests by Age Band]` supplies the coloured segments. The existing measure uses
one snapshot at the end of the selected period; do not replace it with a sum across snapshot dates.

**Optional drill-through page, "Open request list":** a table of `fact_service_requests` filtered to
`is_open = True`. Columns: `request_number`, `dim_request_type[request_type_label]`, `opened_date`,
`current_age_days`, `source_status`, `council_district`. Enable drill-through on `service_category`.

#### [Implementation - 2026-09-26] Configure the optional request-list drillthrough

On the destination page, add `dim_service_category[service_category]` to the **Drill through** field well
and set `fact_service_requests[is_open] = True` under **Filters on this page**. Use the same dimension field
in the source chart so its category can be passed to the destination. Retain `request_number` during load
if building this optional page; Section 1 otherwise permits removing it.

This is a list of requests open at the latest extract, not a reconstruction of a historical snapshot.
Turn **Keep all filters** off to pass the drillthrough category without the source date/age-band context,
and do not sync the date slicer to this page. Otherwise an opened-date filter can hide older requests that
remain open. Test by right-clicking a category > **Drill through > Open request list**, then use Back.
See [Microsoft's drillthrough setup](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-drillthrough).

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

#### [Implementation - 2026-09-26] Table field wells and data bars

For a **Table** visual, put `dim_service_category[service_category]` first in **Columns/Values**, followed
by the five listed measures. "Rows" above describes the displayed category rows; Table does not have a
Matrix-style Rows well. On the recurrence-rate column, open **Conditional formatting > Data bars** (or
**Cell elements > Data bars**) and use the specified blue. Keep the numeric percentage visible. Add
`[Recurrence Originals (90d)]` to **Filters on this visual**, set **is greater than or equal to 500**, and
sort by the recurrence-rate column descending.

**Row 2, right (1/2): Speed vs durability scatter.** Details `service_category`, X
`[Median Resolution (days)]` (log scale), Y `[Recurrence Rate 90d]`, size `[Recurrence Originals (90d)]`.
Add X and Y constant lines at the all-category values; the quadrants then match the `[Speed vs Durability]`
labels. Use a single colour (`#2a78d6`), direct-label the top-left quadrant points, and disable the legend. Per
the palette caps, don't colour by 20 categories.

#### [Implementation - 2026-09-26] Scatter points and matching quadrant thresholds

Use `dim_service_category[service_category]` in the scatter's grouping well, called **Details** or
**Values** depending on version, so there is one point per category. Put the three measures in X, Y and
Size as specified. Keep category in **Tooltips** as well. Confirm multiple points appear before formatting.
See [Microsoft's scatter chart guide](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-scatter).

Create these helpers to reproduce the baselines inside `[Speed vs Durability]`:

```dax
All-category Median Resolution =
    CALCULATE ( [Median Resolution (days)], REMOVEFILTERS ( dim_service_category ) )

All-category Recurrence Rate 90d =
    CALCULATE ( [Recurrence Rate 90d], REMOVEFILTERS ( dim_service_category ) )
```

Add X and Y constant lines in **Analytics**. Where the line's Value exposes **fx**, bind X to the median
helper and Y to the recurrence helper. If your version accepts only typed constants, obtain the helper
values in temporary cards and enter them, but update those constants whenever the date context changes.
Do not use an average of the plotted category values: it does not reproduce the overall median/rate.
For a typed Y value, use the underlying fraction (for example, `0.221` for `22.1%`).
The log X axis requires positive values. If your version cannot label only selected points, show category
labels for all readable points and use the adjacent table/tooltips to identify the "Fast but returns"
categories; static text boxes will not follow points when filters change.

**Row 3, left (1/3): Time to recurrence.** Column chart of `[Recurrence Relationships]` by
`fact_request_recurrence[recurrence_window]` (0–30 / 31–90 / 91–180). Add a visual-level filter
`recurrence_sequence = 1`.

#### [Implementation - 2026-09-26] Time-to-recurrence filter scope

Apply `recurrence_sequence = 1` as a **visual-level** filter. The source labels include "days" and should
appear in the order 0–30, 31–90, 91–180; sort by the window label, not the bar height. Under Section 2's
relationships, `fact_request_recurrence` receives service-category filters but has no date relationship.
Consequently this chart does not follow the date slicer. Label its scope accordingly, for example
"First recurrence — all available originals", so it is not read as a selected-period distribution.

**Row 3, middle (1/3): Recurrence by Census tract.** Shape Map visual (enable it under Options > Preview
features if it is hidden). Location: `dim_census_tract[census_tract_geoid]`. Colour saturation:
`[Recurrence Rate 90d]`. Under Format > Map settings > Custom map, load `shelby_tracts.topo.json` and map the
key to `GEOID`. Use the sequential blue ramp: minimum `#cde2fb`, maximum `#104281`. Tooltip: `tract_label`,
`[Recurrence Originals (90d)]`.

#### [Implementation - 2026-09-26] Match the tract map keys

Keep `census_tract_geoid` as **Text** and use the full tract identifier. If it was hidden under Section 2's
column settings, temporarily unhide it to add it to **Location**. In the custom map settings, inspect
**View map keys** and confirm the values under `GEOID` match the dimension values. Do not substitute
`tract_label` as the key; it belongs in Tooltips. Use the supplied local TopoJSON file and check a known
tract before styling the colour ramp. See [Microsoft's custom Shape map instructions](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-shape-map).

**Row 3, right (1/3): Definition sensitivity.** Matrix on `agg_recurrence_sensitivity`. Rows `location_rule`,
columns `match_level`, values `[Sensitivity Recurrence Rate]`. Add **single-select** slicers for `scope`
(default "All condition reports") and `window_days` (default 90). Highlight the `Primary (hybrid)` row. This
visual shows that the headline number depends on a stated definition.

#### [Implementation - 2026-09-26] Sensitivity slicers and row emphasis

Both slicers must use columns from **agg_recurrence_sensitivity**, which is intentionally disconnected.
Under each slicer's selection controls, enable **Single select**, disable **Select all**, and save with
the specified default selected. The common date/category slicers do not filter this matrix; its `scope`
slicer chooses the category. Disable matrix grand totals, which would combine overlapping definitions.

To shade the Primary row's value cells, create this helper, then set the matrix measure's background
colour **fx > Field value** to it:

```dax
Sensitivity Row Colour =
    IF (
        SELECTEDVALUE ( agg_recurrence_sensitivity[location_rule] ) = "Primary (hybrid)",
        "#cde2fb",
        "#FFFFFF"
    )
```

This formats value cells; row-header formatting is a separate control. Empty Primary cells for other
match levels are expected: the repository defines Primary (hybrid) for category matching only.

**Footnote:** "Recurrence = a related request (same service category) at the same address, or within 25 m for
street and public-space problems, after the original was closed. Only requests observed for the full window
count. It is an operational proxy: a return report may be an unfixed problem, a poor repair or a new incident.
See docs/methodology/recurrence.md."

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

#### [Implementation - 2026-09-26] Location map and tier controls

Use the latitude and longitude from **agg_persistent_locations** together, with numeric data types and
the geographic data categories set in Section 2. In newer Azure Maps versions, the bubble controls are
under **Marker layer**. Put `condition_requests` in Size and `persistence_tier` in Legend; verify a known
location's tooltip and bubble before styling. Use `agg_persistent_locations[persistence_tier]` for the
tier slicer, and map the actual values `1. Chronic`, `2. Persistent`, `3. Repeat` to the specified colours.
The map's `is_persistent = True` filter leaves only the first two tiers on that visual; the page-level
Excluded filter still applies to all visuals. See [Microsoft's Azure Maps marker-layer guide](https://learn.microsoft.com/en-us/azure/azure-maps/power-bi-visual-add-bubble-layer).

**Row 2, right (2/5): Ranked location table.** Table on `agg_persistent_locations`, sorted by
`persistence_rank`. Columns: `persistence_rank`, `display_address`, `dominant_category`,
`condition_requests`, `recurrence_cycles`, `active_months`, `first_request_date`, `latest_request_date`,
`median_resolution_days` and `unresolved_requests`. Use a Top N filter (100 by `persistence_rank`,
ascending). Clicking a row filters the event history through the one-to-one relationship.

#### [Implementation - 2026-09-26] Select the best ranks and retain location identity

Rank **1** is the most persistent, so the Top N instruction requires **Bottom 100 by numeric rank**,
followed by ascending display order. Choosing Top 100 by rank would select the largest, least-prioritized
rank numbers. Add `agg_persistent_locations[location_id]` to the table to keep one identifiable location
per row (temporarily unhide it if necessary). On that field's visual filter choose **Top N > Bottom 100**,
use `persistence_rank` with **Minimum** aggregation as **By value**, then **Apply filter**. Keep the rank
column itself unsummarized and sort it ascending. Rank ties can include more than 100 locations.

Select this table, open **Format > Edit interactions**, and set the event-history table to **Filter**.
Check a selected row's location against the displayed history; this depends on the location relationships
in Section 2. Page 4's location summaries are precomputed across the available history and are not
recalculated by the date/category slicers from Pages 1–3, so do not sync those slicers to this page.

**Row 3, left (1/3): Recurrence cycle distribution.** Column chart. Count of
`agg_persistent_locations[location_id]` by `recurrence_cycles_band`, in a single colour.

**Row 3, right (2/3): Event history for the selected location.** Table on `fact_service_requests`. Columns:
`opened_date`, `dim_request_type[request_type_label]`, `service_category`, `status_group`, `closed_date`,
`resolution_days`, `closure_outcome` and `has_recurrence_90d`. Sort by `opened_date`. Title it with a
measure: `"History: " & SELECTEDVALUE(agg_persistent_locations[display_address], "select a location")`.

#### [Implementation - 2026-09-26] Bind the event-history title

Create a measure named **Event History Title** using the expression above. Select the event-history
table and open **Format visual > General > Title**, turn Title on, click **fx** beside its text, and select
that measure using **Field value**. Typing the DAX into the title text box would display literal text.
Test one selected location, then clear the selection and confirm the prompt returns. The title's fallback
does not hide the table's rows when no location is selected. See [Microsoft's expression-based title setup](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-conditional-format-visual-titles).

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

The pipeline is `uv run python scripts/run_pipeline.py` (extract, then `dbt build`). It runs automatically
every day at 11:00 UTC via GitHub Actions (`.github/workflows/refresh.yml`) and usually finishes within
5 minutes. After it runs, click Refresh in Power BI Desktop, or schedule a refresh in the Power BI Service
for 12:00 UTC or later. Scheduled refresh uses the
service-account credential; no gateway is needed for BigQuery.
