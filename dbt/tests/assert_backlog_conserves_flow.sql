-- Backlog reconstruction is internally consistent: for every day, open(d) = open(d-1) + valid opened(d) - closed(d).
with opened as (
    select opened_date as date_day, count(*) as opened_valid
    from {{ ref('fact_service_requests') }}
    where not has_invalid_resolution_time
    group by 1
),

t as (
    select
        b.snapshot_date,
        b.open_requests,
        lag(b.open_requests) over (order by b.snapshot_date) as prev_open,
        coalesce(o.opened_valid, 0) as opened_valid,
        b.requests_closed
    from {{ ref('agg_backlog_daily_total') }} b
    left join opened o on o.date_day = b.snapshot_date
)

select *
from t
where prev_open is not null
  and open_requests != prev_open + opened_valid - requests_closed
