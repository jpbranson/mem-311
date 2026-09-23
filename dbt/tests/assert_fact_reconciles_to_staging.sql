-- Every staged request is either in the fact table or explicitly excluded (pre-window or bulk artifact).
select
    (select count(*) from {{ ref('stg_311_requests') }}) as staged,
    (select count(*) from {{ ref('fact_service_requests') }}) as in_fact,
    (select count(*) from {{ ref('int_requests_enriched') }} where not is_in_analysis_window or is_bulk_artifact) as excluded
from (select 1)
where (select count(*) from {{ ref('stg_311_requests') }})
   != (select count(*) from {{ ref('fact_service_requests') }})
    + (select count(*) from {{ ref('int_requests_enriched') }} where not is_in_analysis_window or is_bulk_artifact)
