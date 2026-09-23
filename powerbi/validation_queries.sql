-- Expected values for the Power BI measures (Week 7 task 7: check dashboard calculations against SQL output).
-- Each query mirrors one DAX measure in measures.dax with no slicers applied (all dates, all categories).
-- Run in the BigQuery console (project mem-311) and compare with the cards described in build_guide.md.

-- [Requests Opened], [Requests Closed], [Median Resolution (days)], [P90 Resolution (days)]
select
    count(*)                                                                         as requests_opened,
    countif(status_group = 'closed' and not has_invalid_resolution_time)             as requests_closed,
    (select percentile_cont(resolution_days, 0.5) over () from `mem-311.analytics.fact_service_requests`
      where resolution_days is not null limit 1)                                     as median_resolution_days,
    (select percentile_cont(resolution_days, 0.9) over () from `mem-311.analytics.fact_service_requests`
      where resolution_days is not null limit 1)                                     as p90_resolution_days
from `mem-311.analytics.fact_service_requests`;

-- [% Resolved Within 7 Days], [% Resolved Within 30 Days] (mature cohorts only)
select
    safe_divide(countif(days_open_to_close <= 7 and opened_date <= date_sub(m.data_through_date, interval 7 day)),
                countif(opened_date <= date_sub(m.data_through_date, interval 7 day)))  as pct_within_7d,
    safe_divide(countif(days_open_to_close <= 30 and opened_date <= date_sub(m.data_through_date, interval 30 day)),
                countif(opened_date <= date_sub(m.data_through_date, interval 30 day))) as pct_within_30d
from `mem-311.analytics.fact_service_requests`, `mem-311.analytics.meta_data_as_of` m;

-- [Current Backlog], [% Backlog >30 Days], [% Backlog >90 Days], [Median Backlog Age (days)]
select snapshot_date, open_requests, pct_open_over_30d, pct_open_over_90d, median_age_days, p90_age_days, open_over_180d
from `mem-311.analytics.agg_backlog_daily_total`
where snapshot_date = (select data_through_date from `mem-311.analytics.meta_data_as_of`);

-- [Recurrence Rate 30d / 90d / 180d], [Median Days to Recurrence]
select
    safe_divide(countif(has_recurrence_30d), countif(is_recurrence_eligible_30d))   as recurrence_rate_30d,
    safe_divide(countif(has_recurrence_90d), countif(is_recurrence_eligible_90d))   as recurrence_rate_90d,
    safe_divide(countif(has_recurrence_180d), countif(is_recurrence_eligible_180d)) as recurrence_rate_180d,
    (select percentile_cont(days_to_first_recurrence, 0.5) over () from `mem-311.analytics.fact_service_requests`
      where is_recurrence_eligible_180d and has_recurrence_180d limit 1)            as median_days_to_recurrence
from `mem-311.analytics.fact_service_requests`;

-- [Persistent Locations], [Chronic Locations]
select countif(is_persistent) as persistent_locations, countif(persistence_tier = '1. Chronic') as chronic_locations
from `mem-311.analytics.agg_persistent_locations`;
