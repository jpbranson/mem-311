{#
  One row per request with classification (D13, D14), closure outcome (D19), resolution time (D11, D12),
  data-quality exclusions (D16, D17) and location entity (D23). Basis of fact_service_requests.
#}
with requests as (
    select * from {{ ref('stg_311_requests') }}
),

locations as (
    select * from {{ ref('int_request_locations') }}
),

type_map as (
    select * from {{ ref('request_type_map') }}
),

joined as (
    select
        r.*,
        l.address_normalized,
        l.address_key,
        l.geo_point,
        l.match_point,
        l.is_street_level_geocode,
        l.is_in_shelby_county,
        l.is_default_geocode_point,
        l.has_valid_coordinates,
        l.census_tract_geoid,
        l.location_key,
        coalesce(m.request_type_label, r.request_type)   as request_type_label,
        coalesce(m.owning_unit, 'Other')                 as owning_unit,
        coalesce(m.service_category, 'Unmapped')         as service_category,
        coalesce(m.service_group, 'Unmapped')            as service_group,
        coalesce(m.recurrence_family, 'unmapped')        as recurrence_family,
        coalesce(m.is_condition_report, false)           as is_condition_report,
        coalesce(m.location_match_basis, 'public_space') as location_match_basis
    from requests r
    left join locations l using (request_id)
    left join type_map m using (request_type)
),

-- D28: days on which the city closed an unusually large, mostly aged share of the backlog at once
closure_days as (
    select
        closed_date,
        count(*) as closures,
        countif(date_diff(closed_date, opened_date, day) > 30) / count(*) as aged_share
    from joined
    where status_group = 'closed'
    group by 1
),

mass_closure_days as (
    select closed_date
    from closure_days
    where closures >= 10 * (select approx_quantiles(closures, 2)[offset(1)] from closure_days)
      and aged_share >= 0.8
),

derived as (
    select
        *,
        -- D16: mass-created records (same place, type and day, 100+ times) are load artifacts
        count(*) over (
            partition by coalesce(address_normalized, format('%.5f,%.5f', longitude, latitude)), request_type, opened_date
        ) >= 100 as is_bulk_artifact,

        closed_date in (select closed_date from mass_closure_days) as is_mass_closure,

        case
            when status_group != 'closed' then null
            when closed_date in (select closed_date from mass_closure_days) then 'administrative_mass_closure'
            when regexp_contains(lower(concat(coalesce(resolution_summary, ''), ' ', coalesce(resolution_code, ''))),
                 r'already been reported|duplicate|\bdup\b') then 'duplicate'
            when regexp_contains(lower(concat(coalesce(resolution_summary, ''), ' ', coalesce(resolution_code, ''))),
                 r'tdot|mlgw|private property|purview|not a city') then 'referred'
            when regexp_contains(lower(concat(coalesce(resolution_summary, ''), ' ', coalesce(resolution_code, ''))),
                 r'no pot ?holes? found|no violation|\bnot out\b|unable to locate|could not locate|nothing found|no issue found') then 'no_issue_found'
            when regexp_contains(lower(concat(coalesce(resolution_summary, ''), ' ', coalesce(resolution_code, ''))),
                 r'wrong service|routed incorrectly|incorrectly routed|reopened by system|wrong department') then 'misrouted'
            when regexp_contains(lower(concat(coalesce(resolution_summary, ''), ' ', coalesce(resolution_code, ''))),
                 r'provide additional information|need your name') then 'needs_info'
            else 'completed_or_unspecified'
        end as closure_outcome,

        -- D12: compare at local-date grain; a same-day close with an earlier clock time is a same-day closure
        closed_date < opened_date as closed_before_opened,
        closed_date = opened_date and closed_at < opened_at as has_same_day_time_conflict
    from joined
)

select
    *,
    status_group = 'closed' and closed_before_opened                     as has_invalid_resolution_time,
    -- D11/D12: resolution time only for closures with a recorded (not imputed) timestamp that is not negative
    -- D28: mass administrative closures are not resolutions
    if(status_group = 'closed' and not closed_at_is_imputed and not closed_before_opened and not is_mass_closure,
       greatest(datetime_diff(closed_at, opened_at, second), 0) / 3600.0, null)  as resolution_hours,
    if(status_group = 'closed' and not closed_at_is_imputed and not closed_before_opened and not is_mass_closure,
       greatest(datetime_diff(closed_at, opened_at, second), 0) / 86400.0, null) as resolution_days,
    opened_date >= date('{{ var("analysis_start_date") }}')              as is_in_analysis_window,
    farm_fingerprint(location_key)                                       as location_id
from derived
