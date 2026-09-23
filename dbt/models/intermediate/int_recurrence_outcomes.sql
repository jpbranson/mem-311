{#
  One row per recurrence-eligible original: first recurrence under the primary definition (D22) and
  right-censoring-aware window flags. A window W counts only when follow_up_days >= W.
#}
with firsts as (
    select
        original_request_id as request_id,
        min(days_after_closure) as days_to_first_recurrence,
        countif(days_after_closure <= 30) as recurrences_within_30d,
        countif(days_after_closure <= 90) as recurrences_within_90d,
        count(*) as recurrences_within_180d
    from {{ ref('int_recurrence_candidates') }}
    where is_primary_match
    group by 1
)

select
    o.request_id,
    o.service_category,
    o.location_id,
    o.follow_up_days,
    f.days_to_first_recurrence,
    coalesce(f.recurrences_within_30d, 0)  as recurrences_within_30d,
    coalesce(f.recurrences_within_90d, 0)  as recurrences_within_90d,
    coalesce(f.recurrences_within_180d, 0) as recurrences_within_180d,
    {% for w in var('recurrence_windows') -%}
    o.follow_up_days >= {{ w }} as is_eligible_{{ w }}d,
    o.follow_up_days >= {{ w }} and coalesce(f.days_to_first_recurrence <= {{ w }}, false) as has_recurrence_{{ w }}d{{ ',' if not loop.last }}
    {% endfor %}
from {{ ref('int_recurrence_originals') }} o
left join firsts f using (request_id)
