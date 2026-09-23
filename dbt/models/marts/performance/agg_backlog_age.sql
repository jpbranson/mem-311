{# Long-format backlog age bands for stacked charts (grain: snapshot_date x service_category x age_band). #}
select
    snapshot_date,
    service_category,
    {{ age_band('age_days') }} as age_band,
    count(*) as open_requests
from {{ ref('int_backlog_daily_open') }}
group by 1, 2, 3
