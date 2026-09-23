-- Looser matching can only find more recurrences: rates must not fall as the radius widens,
-- as the match level broadens (type -> category -> family) or as the window lengthens on the same originals.
with s as (
    select * from {{ ref('agg_recurrence_sensitivity') }} where location_rule != 'Primary (hybrid)'
),

radius as (
    select a.scope, a.match_level, a.window_days, a.location_rule, a.recurred, b.location_rule as wider_rule, b.recurred as wider_recurred
    from s a
    inner join s b
        on a.scope = b.scope and a.match_level = b.match_level and a.window_days = b.window_days
       and a.radius_m < b.radius_m
    where a.recurred > b.recurred
),

level as (
    select a.scope, a.location_rule, a.window_days, a.match_level, a.recurred, b.match_level as broader, b.recurred as broader_recurred
    from s a
    inner join s b
        on a.scope = b.scope and a.location_rule = b.location_rule and a.window_days = b.window_days
       and ((a.match_level = 'request type' and b.match_level in ('category', 'family'))
         or (a.match_level = 'category' and b.match_level = 'family'))
    where a.recurred > b.recurred
)

select 'radius' as check_type, scope, match_level, window_days from radius
union all
select 'level', scope, match_level, window_days from level
