{#
  Location attributes per request: normalized address, matching key, coordinate validity (D17),
  Census tract (D18) and the derived location entity used for persistence analysis (D23).
#}
with shelby as (
    select county_geom from `bigquery-public-data.geo_us_boundaries.counties` where geo_id = '47157'
),

tracts as (
    select geo_id as census_tract_geoid, tract_geom
    from `bigquery-public-data.geo_census_tracts.census_tracts_tennessee`
    where county_fips_code = '157'
),

base as (
    select
        request_id,
        source_address,
        {{ normalize_address('source_address') }} as address_normalized,
        longitude,
        latitude,
        if(longitude is not null and latitude is not null, st_geogpoint(longitude, latitude), null) as geo_point,
        format('%.5f,%.5f', longitude, latitude) as point_key
    from {{ ref('stg_311_requests') }}
),

keyed as (
    select
        *,
        {{ address_key('address_normalized') }} as address_key,
        regexp_contains(upper(coalesce(source_address, '')), r'&| AT | AND |/') as is_intersection_address
    from base
),

-- geocoder default points: one coordinate shared by many requests with missing or unrelated addresses
point_stats as (
    select
        point_key,
        count(*) as requests_at_point,
        count(distinct address_key) as distinct_addresses_at_point,
        countif(address_key is null) as keyless_at_point,
        countif(address_key is null and not is_intersection_address) as street_only_at_point
    from keyed
    where geo_point is not null
    group by 1
),

flagged as (
    select
        k.*,
        coalesce(st_contains(s.county_geom, k.geo_point), false) as is_in_shelby_county,
        coalesce(ps.requests_at_point >= 50
                 and (ps.distinct_addresses_at_point >= 10 or ps.keyless_at_point >= 0.5 * ps.requests_at_point),
                 false) as is_default_geocode_point,
        -- D29: a street name without a house number geocodes to one point per street; 3+ such requests on the
        -- same point mark a street-level geocode that must not drive distance-based matching
        coalesce(k.address_key is null and not k.is_intersection_address and ps.street_only_at_point >= 3, false)
            as is_street_level_geocode
    from keyed k
    cross join shelby s
    left join point_stats ps using (point_key)
),

valid as (
    select
        *,
        geo_point is not null and is_in_shelby_county and not is_default_geocode_point as has_valid_coordinates
    from flagged
),

with_tract as (
    select v.*, t.census_tract_geoid
    from valid v
    left join tracts t
        on v.has_valid_coordinates and st_intersects(v.geo_point, t.tract_geom)
    -- a point on a shared boundary can intersect two tracts; keep one deterministically
    qualify row_number() over (partition by v.request_id order by t.census_tract_geoid) = 1
)

select
    request_id,
    source_address,
    nullif(address_normalized, '') as address_normalized,
    address_key,
    longitude,
    latitude,
    if(has_valid_coordinates, geo_point, null) as geo_point,
    is_in_shelby_county,
    is_default_geocode_point,
    is_street_level_geocode,
    has_valid_coordinates,
    -- point used for distance-based recurrence matching and grid-cell location entities
    if(has_valid_coordinates and not is_street_level_geocode, geo_point, null) as match_point,
    census_tract_geoid,
    -- D23: location entity = address key when available, else a ~38m x 19m geohash cell of a valid point
    case
        when address_key is not null then concat('A|', address_key)
        when has_valid_coordinates and not is_street_level_geocode then concat('G|', st_geohash(geo_point, 8))
    end as location_key
from with_tract
