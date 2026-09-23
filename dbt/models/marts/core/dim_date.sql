{# Calendar dimension covering the analysis window through the data cut-off (+1 year for recurrence windows). #}
with bounds as (
    select analysis_start_date, data_through_date from {{ ref('meta_data_as_of') }}
),

days as (
    select d as date_day
    from bounds, unnest(generate_date_array(analysis_start_date, date_add(data_through_date, interval 1 year))) as d
)

select
    date_day,
    extract(year from date_day)                                   as year,
    extract(quarter from date_day)                                as quarter,
    format_date('%Y-Q%Q', date_day)                               as year_quarter,
    date_trunc(date_day, month)                                   as month_start,
    format_date('%Y-%m', date_day)                                as year_month,
    format_date('%b %Y', date_day)                                as month_label,
    extract(month from date_day)                                  as month_number,
    format_date('%B', date_day)                                   as month_name,
    date_trunc(date_day, isoweek)                                 as week_start,
    extract(dayofweek from date_day)                              as day_of_week_number,
    format_date('%A', date_day)                                   as day_name,
    extract(dayofweek from date_day) in (1, 7)                    as is_weekend,
    -- City of Memphis fiscal year runs July-June; FY2026 = Jul 2025 - Jun 2026
    extract(year from date_day) + if(extract(month from date_day) >= 7, 1, 0) as fiscal_year,
    date_day <= (select data_through_date from bounds)            as is_observed,
    -- D25: backlog totals and the >180-day band are still filling until 181 days after go-live
    date_day < date_add(date '{{ var("go_live_date") }}', interval 181 day) as is_backlog_burn_in,
    date_trunc(date_day, month) = date_trunc((select data_through_date from bounds), month) as is_current_month
from days
