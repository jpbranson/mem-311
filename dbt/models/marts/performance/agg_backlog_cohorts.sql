{#
  Monthly intake cohorts: how quickly each month's requests left the backlog and how many remain open.
  closed_within_Nd is null when the cohort's last day has not yet been observed for N days.
#}
with as_of as (select data_through_date from {{ ref('meta_data_as_of') }})

select
    r.opened_month                                                  as cohort_month,
    r.service_category,
    count(*)                                                        as requests_opened,
    {% for n in [7, 30, 90, 180] -%}
    if(date_diff(any_value(a.data_through_date), last_day(r.opened_month), day) >= {{ n }},
       countif(r.status_group = 'closed' and date_diff(r.closed_date, r.opened_date, day) <= {{ n }}), null)
                                                                    as closed_within_{{ n }}d,
    {% endfor -%}
    countif(r.is_open)                                              as still_open,
    date_diff(any_value(a.data_through_date), last_day(r.opened_month), day) as cohort_observed_days
from {{ ref('fact_service_requests') }} r
cross join as_of a
where not r.has_invalid_resolution_time
group by 1, 2
