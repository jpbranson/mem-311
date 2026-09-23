{#
  Requests that can be the *original* in a recurrence relationship (D14, D19, D21):
  closed condition reports with a recorded, valid closure time, not closed as duplicates, not load artifacts,
  opened in the analysis window, with a usable location (address key or valid coordinates).
  follow_up_days = days observed after closure before the data cut-off; a window W is only evaluated
  for originals with follow_up_days >= W (right-censoring, D22).
#}
select
    r.request_id,
    r.request_type,
    r.service_category,
    r.recurrence_family,
    r.location_match_basis,
    r.location_id,
    r.census_tract_geoid,
    r.council_district,
    r.opened_at,
    r.closed_at,
    r.closed_date,
    r.resolution_days,
    r.closure_outcome,
    r.address_key,
    r.geo_point,
    date_diff(m.data_through_date, r.closed_date, day) as follow_up_days
from {{ ref('int_requests_enriched') }} r
cross join {{ ref('meta_data_as_of') }} m
where r.is_condition_report
  and not r.is_bulk_artifact
  and r.is_in_analysis_window
  and r.status_group = 'closed'
  and not r.closed_at_is_imputed
  and not r.has_invalid_resolution_time
  and r.closure_outcome != 'duplicate'
  and (r.address_key is not null or r.geo_point is not null)
  and r.closed_date <= m.data_through_date
