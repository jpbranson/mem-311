{#
  Derived location entity (D23): one row per address key, or per ~38 m x 19 m geohash cell for requests
  without a usable address. Only locations with at least one request in fact_service_requests.
#}
with requests as (
    select r.*
    from {{ ref('int_requests_enriched') }} r
    where r.location_id is not null and r.is_in_analysis_window and not r.is_bulk_artifact
),

agg as (
    select
        location_id,
        any_value(location_key)                                                   as location_key,
        approx_top_count(coalesce(address_normalized, '(no address)'), 1)[offset(0)].value as display_address,
        st_centroid(st_union_agg(geo_point))                                      as centroid,
        coalesce(st_maxdistance(st_union_agg(geo_point), st_union_agg(geo_point)), 0) as point_spread_m,
        approx_top_count(census_tract_geoid, 1)[offset(0)].value                  as census_tract_geoid,
        approx_top_count(council_district, 1)[offset(0)].value                    as council_district,
        approx_top_count(zip_code, 1)[offset(0)].value                            as zip_code,
        count(*)                                                                  as request_count
    from requests
    group by 1
)

select
    location_id,
    location_key,
    if(starts_with(location_key, 'A|'), 'address', 'grid_cell')    as location_type,
    display_address,
    st_y(centroid)                                                 as latitude,
    st_x(centroid)                                                 as longitude,
    round(point_spread_m, 1)                                       as point_spread_m,
    -- an address key whose points are >250 m apart likely merges different places (D23)
    point_spread_m > 250                                           as is_spatially_inconsistent,
    census_tract_geoid,
    council_district,
    zip_code,
    request_count
from agg
