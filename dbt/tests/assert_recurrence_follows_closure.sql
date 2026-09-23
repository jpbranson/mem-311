-- A recurring request must open after the original closed (days_between is rounded, so 0.0 = same hour) and within 180 days, at a matched location.
select r.*
from {{ ref('fact_request_recurrence') }} r
where r.days_between < 0
   or r.days_between > 180
   or not (r.is_same_address or r.distance_m <= {{ var('primary_match_radius_m') }})
