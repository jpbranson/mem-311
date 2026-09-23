{# One-row table: when the data was extracted and the last complete local day it covers. #}
select
    max(_ingested_at)                                                        as extracted_at_utc,
    date_sub(date(max(_ingested_at), '{{ var("local_tz") }}'), interval 1 day) as data_through_date,
    date('{{ var("analysis_start_date") }}')                                 as analysis_start_date,
    count(*)                                                                 as live_request_count
from {{ ref('stg_311_requests') }}
