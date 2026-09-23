{#
  Phase E sensitivity analysis: recurrence rate under every combination of location rule
  (same address only; address or within 25/50/100 m; the hybrid primary rule), match level
  (same request type / same category / same recurrence family) and window (30/90/180 days).
  scope = 'All condition reports' rows are computed from originals directly, not by summing categories.
#}
{%- set radii = var('sensitivity_radii_m') -%}
{%- set levels = {'request type': 'c.is_same_request_type', 'category': 'c.is_same_category', 'family': 'true'} -%}

with firsts as (
    select
        o.request_id,
        o.service_category,
        o.follow_up_days,
        {% for level, cond in levels.items() -%}
        min(if(c.is_same_address and {{ cond }}, c.days_after_closure, null)) as `d_address_{{ level | replace(' ', '_') }}`,
        {% for r in radii -%}
        min(if((c.is_same_address or c.distance_m <= {{ r }}) and {{ cond }}, c.days_after_closure, null)) as `d_{{ r }}m_{{ level | replace(' ', '_') }}`,
        {% endfor -%}
        {% endfor -%}
        min(if(c.is_primary_match, c.days_after_closure, null)) as d_primary_category
    from {{ ref('int_recurrence_originals') }} o
    left join {{ ref('int_recurrence_candidates') }} c on c.original_request_id = o.request_id
    group by 1, 2, 3
),

long as (
    {% set combos = [] -%}
    {% for level in levels -%}
        {% do combos.append(('Same address only', 0, level, 'd_address_' ~ level | replace(' ', '_'))) -%}
        {% for r in radii -%}
            {% do combos.append(('Address or within ' ~ r ~ ' m', r, level, 'd_' ~ r ~ 'm_' ~ level | replace(' ', '_'))) -%}
        {% endfor -%}
    {% endfor -%}
    {% do combos.append(('Primary (hybrid)', var('primary_match_radius_m'), 'category', 'd_primary_category')) -%}
    {% for label, r, level, col in combos -%}
    select request_id, service_category, follow_up_days,
           '{{ label }}' as location_rule, {{ r }} as radius_m, '{{ level }}' as match_level, {{ col }} as first_days
    from firsts
    {{ 'union all' if not loop.last }}
    {% endfor %}
),

windows as (
    select l.*, w as window_days
    from long l, unnest({{ var('recurrence_windows') }}) as w
    where l.follow_up_days >= w
),

by_category as (
    select service_category as scope, location_rule, radius_m, match_level, window_days,
           count(*) as eligible_originals, countif(first_days <= window_days) as recurred
    from windows group by 1, 2, 3, 4, 5
),

overall as (
    select 'All condition reports' as scope, location_rule, radius_m, match_level, window_days,
           count(*) as eligible_originals, countif(first_days <= window_days) as recurred
    from windows group by 2, 3, 4, 5
)

select
    *,
    safe_divide(recurred, eligible_originals) as recurrence_rate,
    location_rule = 'Primary (hybrid)' and window_days = {{ var('primary_window_days') }} as is_headline_definition
from (select * from by_category union all select * from overall)
