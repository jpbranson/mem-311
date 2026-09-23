{#
  Shared body of agg_backlog_daily (by category) and agg_backlog_daily_total (all categories):
  end-of-day backlog size, age distribution and flow for each observed day. group_col = none for the total.
#}
{% macro backlog_daily_select(group_col=none) -%}
{%- set g = ', ' ~ group_col if group_col else '' -%}
with grid as (
    select d.date_day as snapshot_date{% if group_col %}, c.{{ group_col }}{% endif %}
    from {{ ref('dim_date') }} d
    {% if group_col -%}
    cross join (select distinct {{ group_col }} from {{ ref('fact_service_requests') }}) c
    {% endif -%}
    where d.is_observed
),

open_stats as (
    select
        snapshot_date{{ g }},
        count(*)                                        as open_requests,
        approx_quantiles(age_days, 100)[offset(50)]     as median_age_days,
        approx_quantiles(age_days, 100)[offset(90)]     as p90_age_days,
        countif(age_days < 7)                           as open_under_7d,
        countif(age_days between 7 and 30)              as open_7_30d,
        countif(age_days between 31 and 90)             as open_31_90d,
        countif(age_days between 91 and 180)            as open_91_180d,
        countif(age_days > 180)                         as open_over_180d
    from {{ ref('int_backlog_daily_open') }}
    group by snapshot_date{{ g }}
),

inflow as (
    select opened_date as snapshot_date{{ g }}, count(*) as opened
    from {{ ref('fact_service_requests') }}
    group by snapshot_date{{ g }}
),

outflow as (
    select closed_date as snapshot_date{{ g }}, count(*) as closed
    from {{ ref('fact_service_requests') }}
    where status_group = 'closed' and not has_invalid_resolution_time
    group by snapshot_date{{ g }}
)

select
    grid.snapshot_date{% if group_col %},
    grid.{{ group_col }}{% endif %},
    coalesce(i.opened, 0)                               as requests_opened,
    coalesce(o.closed, 0)                               as requests_closed,
    coalesce(i.opened, 0) - coalesce(o.closed, 0)       as net_backlog_change,
    coalesce(s.open_requests, 0)                        as open_requests,
    s.median_age_days,
    s.p90_age_days,
    coalesce(s.open_under_7d, 0)                        as open_under_7d,
    coalesce(s.open_7_30d, 0)                           as open_7_30d,
    coalesce(s.open_31_90d, 0)                          as open_31_90d,
    coalesce(s.open_91_180d, 0)                         as open_91_180d,
    coalesce(s.open_over_180d, 0)                       as open_over_180d,
    safe_divide(s.open_31_90d + s.open_91_180d + s.open_over_180d, s.open_requests) as pct_open_over_30d,
    safe_divide(s.open_91_180d + s.open_over_180d, s.open_requests)                 as pct_open_over_90d,
    -- D25: until 181 days after go-live the >180-day band cannot fill and totals are still building up
    grid.snapshot_date < date_add(date '{{ var("go_live_date") }}', interval 181 day) as is_burn_in_period
from grid
left join open_stats s using (snapshot_date{{ g }})
left join inflow i using (snapshot_date{{ g }})
left join outflow o using (snapshot_date{{ g }})
{%- endmacro %}
