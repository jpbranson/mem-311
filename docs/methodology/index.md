# Methodology

* [Populations](populations.md) - The nested populations every rate is computed over, from all live requests down to originals eligible for the 90-day recurrence rate.

# Measures

* [Responsiveness](responsiveness.md) - How resolution time and the share resolved within 7 and 30 days are defined, and which requests each counts.
* [Backlog reconstruction](backlog.md) - The open backlog rebuilt day by day from open and close dates, split into age bands, with a burn-in period and a flow-conservation test.
* [Recurrence (durability)](recurrence.md) - How a closed request is judged to have recurred - location matching, category similarity, time windows, right-censoring and the primary definition.
* [Recurrence sensitivity (Phase E)](recurrence-sensitivity.md) - The 90-day recurrence rate under every combination of location rule, match level and window; the headline sits at the strict end of the grid.
* [Recurrence validation](recurrence-validation.md) - Manual review of an 80-pair stratified sample - 89% same-place, same-problem matches - and the known false-match risks.
* [Persistent locations](persistent-locations.md) - The location entity and the Chronic, Persistent and Repeat tiers for places with three or more condition reports.
* [Geography](geography.md) - Census tract, council district and ZIP assignment, why no neighborhoods and no per-capita rates, and the minimum area size for comparisons.

# Caveats and scope

* [Limitations](limitations.md) - What the data and methods cannot show - reporting bias, recurrence ambiguity, location accuracy, category drift, closure meaning, no status history, short history.
* [Pothole detection (stretch goal, omitted)](pothole-detection.md) *(deprecated)* - The planned before/after analysis of AI pothole detection, dropped because AI-detected potholes are 1.1% of pothole requests and arrive in bursts.
