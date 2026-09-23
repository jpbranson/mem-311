{#
  Monthly responsiveness by service category (D26).
    requests_opened / requests_closed : counted in the month the event happened
    median / p90 resolution           : requests *closed* in the month with a recorded closure time
    pct_resolved_within_7d / 30d      : of requests *opened* in the month (null until the cohort is observable)
    open_at_month_end                 : reconstructed backlog on the month's last observed day
#}
with as_of as (select data_through_date from {{ ref('meta_data_as_of') }}),

months as (
    select distinct d.month_start, c.service_category
    from {{ ref('dim_date') }} d
    cross join (select distinct service_category from {{ ref('fact_service_requests') }}) c
    where d.is_observed
),

opened as (
    select
        opened_month as month_start,
        service_category,
        count(*) as requests_opened,
        countif(status_group = 'closed' and not has_invalid_resolution_time
                and date_diff(closed_date, opened_date, day) <= 7) as resolved_within_7d,
        countif(status_group = 'closed' and not has_invalid_resolution_time
                and date_diff(closed_date, opened_date, day) <= 30) as resolved_within_30d
    from {{ ref('fact_service_requests') }}
    group by 1, 2
),

closed as (
    select
        closed_month as month_start,
        service_category,
        count(*) as requests_closed,
        countif(resolution_days is not null) as closed_with_resolution_time
    from {{ ref('fact_service_requests') }}
    where status_group = 'closed' and not has_invalid_resolution_time
    group by 1, 2
),

closed_pct as (
    select distinct
        closed_month as month_start,
        service_category,
        percentile_cont(resolution_days, 0.5) over (partition by closed_month, service_category) as median_resolution_days,
        percentile_cont(resolution_days, 0.9) over (partition by closed_month, service_category) as p90_resolution_days
    from {{ ref('fact_service_requests') }}
    where resolution_days is not null
),

month_end_backlog as (
    select date_trunc(snapshot_date, month) as month_start, service_category, open_requests as open_at_month_end
    from {{ ref('agg_backlog_daily') }}
    where snapshot_date = least(last_day(snapshot_date), (select data_through_date from as_of))
)

select
    m.month_start,
    m.service_category,
    coalesce(o.requests_opened, 0)                                  as requests_opened,
    coalesce(c.requests_closed, 0)                                  as requests_closed,
    coalesce(o.requests_opened, 0) - coalesce(c.requests_closed, 0) as net_change,
    coalesce(c.closed_with_resolution_time, 0)                      as closed_with_resolution_time,
    p.median_resolution_days,
    p.p90_resolution_days,
    if(date_diff(a.data_through_date, last_day(m.month_start), day) >= 7,
       safe_divide(o.resolved_within_7d, o.requests_opened), null)  as pct_resolved_within_7d,
    if(date_diff(a.data_through_date, last_day(m.month_start), day) >= 30,
       safe_divide(o.resolved_within_30d, o.requests_opened), null) as pct_resolved_within_30d,
    b.open_at_month_end,
    m.month_start = date_trunc(date '{{ var("go_live_date") }}', month)
        or last_day(m.month_start) > a.data_through_date            as is_partial_month
from months m
cross join as_of a
left join opened o using (month_start, service_category)
left join closed c using (month_start, service_category)
left join closed_pct p using (month_start, service_category)
left join month_end_backlog b using (month_start, service_category)
