{# Shelby County Census tracts (D18) with WKT geometry for map visuals and a centroid for bubble maps. #}
select
    geo_id                                           as census_tract_geoid,
    tract_name,
    lsad_name                                        as tract_label,
    area_land_meters / 1e6                           as land_area_km2,
    safe_cast(internal_point_lat as float64)         as centroid_latitude,
    safe_cast(internal_point_lon as float64)         as centroid_longitude,
    st_astext(st_simplify(tract_geom, 10))           as tract_wkt  -- simplified to 10 m for map visuals
from `bigquery-public-data.geo_census_tracts.census_tracts_tennessee`
where county_fips_code = '157'
