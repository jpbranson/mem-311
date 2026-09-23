-- Stratified random sample of primary-definition recurrence pairs for manual review (Week 8, task 1).
-- Deterministic: the sample is the lowest farm_fingerprint hashes per category.
-- Run: dbt compile -s recurrence_validation_sample, then execute target/compiled/.../recurrence_validation_sample.sql
select
    r.service_category,
    r.days_between,
    r.distance_m,
    r.is_same_address,
    o.request_type                       as original_type,
    f.request_type                       as recurring_type,
    o.source_address                     as original_address,
    f.source_address                     as recurring_address,
    o.closure_outcome                    as original_outcome,
    left(o.resolution_summary, 60)       as original_resolution,
    r.original_request_id,
    r.recurring_request_id
from {{ ref('fact_request_recurrence') }} r
inner join {{ ref('int_requests_enriched') }} o on o.request_id = r.original_request_id
inner join {{ ref('int_requests_enriched') }} f on f.request_id = r.recurring_request_id
where r.recurrence_sequence = 1
qualify row_number() over (
    partition by r.service_category
    order by farm_fingerprint(concat(cast(r.original_request_id as string), '-', cast(r.recurring_request_id as string)))
) <= 4
order by r.service_category
