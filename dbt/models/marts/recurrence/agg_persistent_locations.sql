{#
  Location-level history for places with repeated condition reports (D27). Grain: location_id.
  Only locations with 3+ condition reports in the analysis window are kept; isolated incidents are not.
    recurrence_cycles = requests at the location that were closed and then followed, within 90 days, by a
                        related request under the primary definition (a close -> return event)
    persistence_tier  = Chronic / Persistent / Repeat, see docs/methodology.md
#}
with requests as (
    select * from {{ ref('fact_service_requests') }}
    where location_id is not null and is_condition_report
),

category_counts as (
    select location_id, service_category, count(*) as n
    from requests
    group by 1, 2
),

dominant as (
    select
        location_id,
        service_category as dominant_category,
        n as dominant_category_requests
    from category_counts
    qualify row_number() over (partition by location_id order by n desc, service_category) = 1
),

medians as (
    select distinct
        location_id,
        percentile_cont(resolution_days, 0.5) over (partition by location_id) as median_resolution_days
    from requests
),

agg as (
    select
        location_id,
        count(*)                                              as condition_requests,
        count(distinct service_category)                      as distinct_categories,
        min(opened_date)                                      as first_request_date,
        max(opened_date)                                      as latest_request_date,
        count(distinct opened_month)                          as active_months,
        count(distinct extract(year from opened_date))       as active_years,
        countif(coalesce(has_recurrence_90d, false))          as recurrence_cycles,
        countif(is_recurrence_eligible_90d)                   as recurrence_eligible_closures,
        avg(resolution_days)                                  as avg_resolution_days,
        countif(is_open)                                      as unresolved_requests,
        safe_divide(date_diff(max(opened_date), min(opened_date), day), count(*) - 1) as avg_days_between_requests
    from requests
    group by 1
    having count(*) >= 3
),

all_requests as (
    select location_id, count(*) as total_requests
    from {{ ref('fact_service_requests') }}
    where location_id is not null
    group by 1
)

select
    a.location_id,
    l.display_address,
    l.location_type,
    l.latitude,
    l.longitude,
    l.census_tract_geoid,
    l.council_district,
    l.zip_code,
    t.total_requests,
    a.condition_requests,
    a.distinct_categories,
    a.first_request_date,
    a.latest_request_date,
    a.active_months,
    a.active_years,
    a.recurrence_cycles,
    case
        when a.recurrence_cycles = 0 then '0'
        when a.recurrence_cycles = 1 then '1'
        when a.recurrence_cycles <= 3 then '2-3'
        when a.recurrence_cycles <= 9 then '4-9'
        else '10+'
    end                                                                as recurrence_cycles_band,
    a.recurrence_eligible_closures,
    d.dominant_category,
    d.dominant_category_requests,
    safe_divide(d.dominant_category_requests, a.condition_requests) as dominant_category_share,
    m.median_resolution_days,
    a.avg_resolution_days,
    a.unresolved_requests,
    a.avg_days_between_requests,
    l.is_spatially_inconsistent,
    case
        when l.is_spatially_inconsistent then 'Excluded (inconsistent location)'
        when a.condition_requests >= 10 and a.active_months >= 6 and a.recurrence_cycles >= 4 then '1. Chronic'
        when a.condition_requests >= 5 and a.active_months >= 3 and a.recurrence_cycles >= 2 then '2. Persistent'
        else '3. Repeat'
    end as persistence_tier,
    not l.is_spatially_inconsistent and a.condition_requests >= 5 and a.active_months >= 3
        and a.recurrence_cycles >= 2                                   as is_persistent,
    rank() over (
        order by if(l.is_spatially_inconsistent, 0, 1) desc, a.recurrence_cycles desc, a.condition_requests desc
    )                                                                  as persistence_rank
from agg a
inner join {{ ref('dim_location') }} l using (location_id)
inner join all_requests t using (location_id)
inner join dominant d using (location_id)
inner join medians m using (location_id)
