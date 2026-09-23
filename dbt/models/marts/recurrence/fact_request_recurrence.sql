{#
  One row per recurrence relationship under the primary definition (D22), up to 180 days after closure.
  An original with several later related requests has several rows; recurrence_sequence = 1 is the first.
#}
select
    c.original_request_id,
    c.follower_request_id                                         as recurring_request_id,
    c.original_location_id                                        as location_id,
    c.original_service_category                                   as service_category,
    date(c.original_closed_at)                                    as original_closed_date,
    date(c.follower_opened_at)                                    as recurring_opened_date,
    round(c.days_after_closure, 2)                                as days_between,
    round(c.distance_m, 1)                                        as distance_m,
    c.is_same_address,
    c.is_same_request_type,
    case
        when c.days_after_closure <= 30 then '0-30 days'
        when c.days_after_closure <= 90 then '31-90 days'
        else '91-180 days'
    end                                                           as recurrence_window,
    row_number() over (partition by c.original_request_id order by c.days_after_closure, c.follower_request_id) as recurrence_sequence
from {{ ref('int_recurrence_candidates') }} c
where c.is_primary_match
