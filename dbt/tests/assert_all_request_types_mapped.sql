{{ config(severity='warn') }}
-- A new source REQUEST_TYPE appeared that is not in seeds/request_type_map.csv (D13).
select request_type, count(*) as requests
from {{ ref('int_requests_enriched') }}
where service_category = 'Unmapped'
group by 1
