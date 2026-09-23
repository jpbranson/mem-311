{# Standardized request classification (D13, D14): one row per source request type. #}
with observed as (
    select request_type, count(*) as request_count, min(opened_date) as first_seen_date, max(opened_date) as last_seen_date
    from {{ ref('int_requests_enriched') }}
    group by 1
)

select
    farm_fingerprint(o.request_type)                          as request_type_id,
    o.request_type,
    coalesce(m.request_type_label, o.request_type)            as request_type_label,
    coalesce(m.owning_unit, 'Other')                          as owning_unit,
    coalesce(m.service_category, 'Unmapped')                  as service_category,
    coalesce(m.service_group, 'Unmapped')                     as service_group,
    coalesce(m.recurrence_family, 'unmapped')                 as recurrence_family,
    coalesce(m.is_condition_report, false)                    as is_condition_report,
    o.request_count,
    o.first_seen_date,
    o.last_seen_date
from observed o
left join {{ ref('request_type_map') }} m using (request_type)
