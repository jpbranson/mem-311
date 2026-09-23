{#
  Geographic comparison across all service categories (D18). Grain: geography_type x geography_id, where
  geography_type is census_tract, council_district or zip_code. No per-capita rates (reporting bias).
  Category-filtered geographic measures are computed in Power BI from fact_service_requests.
#}
{%- set geos = {'census_tract': 'census_tract_geoid', 'council_district': 'cast(council_district as string)', 'zip_code': 'zip_code'} -%}

with as_of as (select data_through_date from {{ ref('meta_data_as_of') }}),

requests as (
    {% for gtype, expr in geos.items() -%}
    select '{{ gtype }}' as geography_type, {{ expr }} as geography_id, f.*
    from {{ ref('fact_service_requests') }} f
    where {{ expr }} is not null
    {{ 'union all' if not loop.last }}
    {% endfor %}
),

medians as (
    select distinct
        geography_type,
        geography_id,
        percentile_cont(resolution_days, 0.5) over (partition by geography_type, geography_id) as median_resolution_days,
        percentile_cont(current_age_days, 0.5) over (partition by geography_type, geography_id) as median_open_age_days
    from requests
),

persistent as (
    {% for gtype, expr in geos.items() -%}
    select '{{ gtype }}' as geography_type, {{ expr }} as geography_id, countif(is_persistent) as persistent_locations
    from {{ ref('agg_persistent_locations') }}
    where {{ expr }} is not null
    group by 1, 2
    {{ 'union all' if not loop.last }}
    {% endfor %}
)

select
    r.geography_type,
    r.geography_id,
    case r.geography_type
        when 'census_tract' then any_value(t.tract_label)
        when 'council_district' then concat('Council District ', r.geography_id)
        else concat('ZIP ', r.geography_id)
    end                                                              as geography_name,
    count(*)                                                         as requests_opened,
    countif(r.is_condition_report)                                   as condition_requests,
    any_value(m.median_resolution_days)                              as median_resolution_days,
    safe_divide(countif(r.resolution_days <= 30), countif(r.resolution_days is not null)) as pct_resolved_within_30d,
    countif(r.is_open)                                               as open_requests,
    any_value(m.median_open_age_days)                                as median_open_age_days,
    safe_divide(countif(r.current_age_days > 90), countif(r.is_open)) as pct_open_over_90d,
    countif(r.is_recurrence_eligible_90d)                            as recurrence_eligible_90d,
    countif(r.has_recurrence_90d)                                    as recurred_90d,
    safe_divide(countif(r.has_recurrence_90d), countif(r.is_recurrence_eligible_90d)) as recurrence_rate_90d,
    coalesce(any_value(p.persistent_locations), 0)                   as persistent_locations
from requests r
left join medians m using (geography_type, geography_id)
left join persistent p using (geography_type, geography_id)
left join {{ ref('dim_census_tract') }} t
    on r.geography_type = 'census_tract' and t.census_tract_geoid = r.geography_id
group by 1, 2
