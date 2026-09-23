{# One row per standardized service category; the slicer dimension shared by fact and aggregate tables. #}
select
    service_category,
    any_value(service_group)                                   as service_group,
    logical_or(is_condition_report)                            as has_condition_reports,
    logical_and(is_condition_report)                           as is_recurrence_eligible,
    count(*)                                                   as request_type_count,
    sum(request_count)                                         as request_count,
    dense_rank() over (order by sum(request_count) desc)       as volume_rank
from {{ ref('dim_request_type') }}
group by 1
