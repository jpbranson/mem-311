{#
  Durability by service category under the primary definition (D22). Rates use only originals observed for the
  full window (right-censoring). Resolution medians are included so speed and durability sit side by side.
#}
with outcomes as (
    select o.*, r.resolution_days
    from {{ ref('int_recurrence_outcomes') }} o
    inner join {{ ref('int_requests_enriched') }} r using (request_id)
),

medians as (
    select distinct
        service_category,
        percentile_cont(resolution_days, 0.5) over (partition by service_category) as median_resolution_days,
        percentile_cont(if(is_eligible_180d and days_to_first_recurrence <= 180, days_to_first_recurrence, null), 0.5)
            over (partition by service_category) as median_days_to_recurrence
    from outcomes
)

select
    o.service_category,
    count(*)                                                          as recurrence_originals,
    {% for w in var('recurrence_windows') -%}
    countif(o.is_eligible_{{ w }}d)                                   as eligible_{{ w }}d,
    countif(o.has_recurrence_{{ w }}d)                                as recurred_{{ w }}d,
    safe_divide(countif(o.has_recurrence_{{ w }}d), countif(o.is_eligible_{{ w }}d)) as recurrence_rate_{{ w }}d,
    {% endfor -%}
    any_value(m.median_days_to_recurrence)                            as median_days_to_recurrence,
    any_value(m.median_resolution_days)                               as median_resolution_days
from outcomes o
inner join medians m using (service_category)
group by 1
