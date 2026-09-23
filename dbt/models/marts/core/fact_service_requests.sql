{#
  One row per service request in the analysis window (bulk-load artifacts excluded, D16).
  Grain: request_id. Joins: dim_request_type, dim_service_category, dim_location, dim_census_tract, dim_date.
#}
with requests as (
    select * from {{ ref('int_requests_enriched') }}
    where is_in_analysis_window and not is_bulk_artifact
),

as_of as (
    select data_through_date from {{ ref('meta_data_as_of') }}
)

select
    r.request_id,
    r.request_number,
    farm_fingerprint(r.request_type)                            as request_type_id,
    r.service_category,
    r.location_id,
    r.census_tract_geoid,
    r.council_district,
    r.zip_code,

    r.opened_date,
    r.opened_at,
    r.opened_month,
    r.opened_is_date_only,
    r.closed_date,
    r.closed_at,
    date_trunc(r.closed_date, month)                            as closed_month,
    r.closed_at_source,
    r.closed_at_is_imputed,
    r.is_mass_closure,

    r.status_group,
    r.is_open,
    r.source_status,
    r.source_sub_status,
    r.priority,
    r.closure_outcome,

    r.resolution_hours,
    if(r.status_group = 'closed' and not r.has_invalid_resolution_time,
       date_diff(r.closed_date, r.opened_date, day), null)     as days_open_to_close,
    r.resolution_days,
    r.has_invalid_resolution_time,
    r.has_same_day_time_conflict,
    case
        when r.resolution_days is null then null
        when r.resolution_days < 1 then '0-1 days'
        when r.resolution_days < 7 then '1-7 days'
        when r.resolution_days < 30 then '7-30 days'
        when r.resolution_days < 90 then '30-90 days'
        else '90+ days'
    end                                                         as resolution_band,
    if(r.is_open, date_diff(a.data_through_date, r.opened_date, day), null) as current_age_days,
    case
        when not r.is_open then null
        when date_diff(a.data_through_date, r.opened_date, day) < 7 then '1. Under 7 days'
        when date_diff(a.data_through_date, r.opened_date, day) <= 30 then '2. 7-30 days'
        when date_diff(a.data_through_date, r.opened_date, day) <= 90 then '3. 31-90 days'
        when date_diff(a.data_through_date, r.opened_date, day) <= 180 then '4. 91-180 days'
        else '5. Over 180 days'
    end                                                         as current_age_band,

    r.is_condition_report,
    r.has_valid_coordinates,
    if(r.has_valid_coordinates, r.latitude, null)               as latitude,
    if(r.has_valid_coordinates, r.longitude, null)              as longitude,
    r.address_normalized,
    r.is_ai_detected,
    r.is_seeclickfix,
    r.was_transferred,

    -- recurrence outcome when this request is the original (primary definition, D22); null = not eligible
    o.request_id is not null                                    as is_recurrence_original,
    o.follow_up_days                                            as recurrence_follow_up_days,
    o.days_to_first_recurrence,
    {% for w in var('recurrence_windows') -%}
    o.is_eligible_{{ w }}d                                      as is_recurrence_eligible_{{ w }}d,
    o.has_recurrence_{{ w }}d                                   as has_recurrence_{{ w }}d,
    {% endfor -%}
    o.recurrences_within_180d
from requests r
cross join as_of a
left join {{ ref('int_recurrence_outcomes') }} o using (request_id)
