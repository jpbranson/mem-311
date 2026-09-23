{#
  Candidate recurrence pairs under the *loosest* definition considered (docs/methodology.md, Phases A-D):
    original = row of int_recurrence_originals
    follower = any condition report in the same recurrence family, opened after the original closed and within
               max_window_days of that closure, at the same address key OR within max_match_radius_m.
  Stricter definitions (smaller radius, same category / request type, shorter window) are filters on this
  table, which makes the sensitivity analysis (Phase E) a plain aggregation.

  Spatial matching uses an equi-join on ~105 m grid cells (each follower is expanded to its 3x3 neighbourhood)
  followed by an exact geodesic distance check. match_point excludes street-level geocodes (D29). A direct ST_DWITHIN join with the extra family/time predicates
  did not finish in 10 minutes (D24).
#}
{{ config(cluster_by=['original_request_id']) }}

{%- set cell_m = 105 -%}
{%- set m_per_deg_lon = 91000 -%}   {# at ~35.1 N #}
{%- set m_per_deg_lat = 110950 -%}

with followers as (
    select
        request_id, request_type, service_category, recurrence_family, opened_at, address_key, match_point,
        cast(floor(st_x(match_point) * {{ m_per_deg_lon }} / {{ cell_m }}) as int64) as cell_x,
        cast(floor(st_y(match_point) * {{ m_per_deg_lat }} / {{ cell_m }}) as int64) as cell_y
    from {{ ref('int_requests_enriched') }}
    where is_condition_report
      and not is_bulk_artifact
      and is_in_analysis_window
      and (address_key is not null or match_point is not null)
),

originals as (
    select
        *,
        cast(floor(st_x(match_point) * {{ m_per_deg_lon }} / {{ cell_m }}) as int64) as cell_x,
        cast(floor(st_y(match_point) * {{ m_per_deg_lat }} / {{ cell_m }}) as int64) as cell_y
    from {{ ref('int_recurrence_originals') }}
),

follower_neighbourhood as (
    select f.request_id, f.recurrence_family, f.opened_at, f.match_point, f.cell_x + dx as cell_x, f.cell_y + dy as cell_y
    from followers f, unnest([-1, 0, 1]) as dx, unnest([-1, 0, 1]) as dy
    where f.match_point is not null
),

spatial_pairs as (
    select o.request_id as original_request_id, f.request_id as follower_request_id
    from originals o
    inner join follower_neighbourhood f
        on o.recurrence_family = f.recurrence_family
       and o.cell_x = f.cell_x
       and o.cell_y = f.cell_y
    where f.opened_at > o.closed_at
      and f.opened_at <= datetime_add(o.closed_at, interval {{ var('max_window_days') }} day)
      and st_dwithin(o.match_point, f.match_point, {{ var('max_match_radius_m') }})
),

address_pairs as (
    select o.request_id as original_request_id, f.request_id as follower_request_id
    from originals o
    inner join followers f
        on o.address_key = f.address_key
       and o.recurrence_family = f.recurrence_family
    where f.opened_at > o.closed_at
      and f.opened_at <= datetime_add(o.closed_at, interval {{ var('max_window_days') }} day)
),

pairs as (
    select * from spatial_pairs
    union distinct
    select * from address_pairs
)

select
    p.original_request_id,
    p.follower_request_id,
    o.location_id                                                    as original_location_id,
    o.service_category                                               as original_service_category,
    f.service_category                                               as follower_service_category,
    o.recurrence_family,
    o.closed_at                                                      as original_closed_at,
    f.opened_at                                                      as follower_opened_at,
    datetime_diff(f.opened_at, o.closed_at, second) / 86400.0        as days_after_closure,
    st_distance(o.match_point, f.match_point)                            as distance_m,
    coalesce(o.address_key = f.address_key, false)                   as is_same_address,
    o.request_type = f.request_type                                  as is_same_request_type,
    o.service_category = f.service_category                          as is_same_category,
    o.location_match_basis                                           as original_location_match_basis,
    o.address_key is not null and f.address_key is not null          as both_have_address_key,
    -- D22 primary definition: same category, and same address; a 25 m radius is also accepted for
    -- public-space problems, or for property-based problems when either request lacks an address key
    o.service_category = f.service_category
      and (
        (o.address_key is not null and o.address_key = f.address_key)
        or (st_distance(o.match_point, f.match_point) <= {{ var('primary_match_radius_m') }}
            and (o.location_match_basis = 'public_space' or o.address_key is null or f.address_key is null))
      )                                                              as is_primary_match
from pairs p
inner join originals o on o.request_id = p.original_request_id
inner join followers f on f.request_id = p.follower_request_id
