# Core

* [dim_census_tract](dim_census_tract.md) - Shelby County Census tracts (221) with simplified WKT geometry and centroid (D18).
* [dim_date](dim_date.md) - Calendar dimension from the analysis start through one year past the data cut-off.
* [dim_location](dim_location.md) - Derived location entity (D23) - one row per address key or ~38 m x 19 m geohash cell.
* [dim_request_type](dim_request_type.md) - One row per source request type with its standardized classification (D13, D14).
* [dim_service_category](dim_service_category.md) - One row per standardized service category - the shared slicer dimension for fact and aggregate tables.
* [fact_service_requests](fact_service_requests.md) - One row per 311 service request reported on or after 2023-10-01, excluding the bulk-load artifact (D09, D16).
* [meta_data_as_of](meta_data_as_of.md) - One-row table with the extraction time and the last complete local day covered.

# Performance

* [agg_backlog_age](agg_backlog_age.md) - Long-format backlog by age band for stacked charts.
* [agg_backlog_cohorts](agg_backlog_cohorts.md) - Monthly intake cohorts - how fast each month's requests closed and how many remain open.
* [agg_backlog_daily](agg_backlog_daily.md) - End-of-day backlog size, age distribution and flow per category (D25).
* [agg_backlog_daily_total](agg_backlog_daily_total.md) - Same measures as agg_backlog_daily across all categories (grain snapshot_date); medians over the whole open population.
* [agg_geography_performance](agg_geography_performance.md) - Geographic comparison across all categories.
* [agg_monthly_service_performance](agg_monthly_service_performance.md) - Monthly responsiveness by service category (D26).

# Recurrence

* [agg_persistent_locations](agg_persistent_locations.md) - Locations with 3+ condition reports, with persistence metrics and tier (D27).
* [agg_recurrence_sensitivity](agg_recurrence_sensitivity.md) - Phase E sensitivity grid - recurrence rate by location rule x match level x window, per category and overall.
* [agg_service_recurrence](agg_service_recurrence.md) - Durability by service category under the primary definition, with median resolution for the speed vs durability comparison.
* [fact_request_recurrence](fact_request_recurrence.md) - One row per recurrence relationship under the primary definition (D22), up to 180 days after closure.
