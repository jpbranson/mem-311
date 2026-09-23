{#
  Reconstructed daily backlog (D25): one row per request per local day on which it was open at end of day,
  from the day it was opened until the day before it closed (or the data cut-off if still open).
  Status history is not published, so a request is assumed open continuously from opening to its final
  closure (reopen/close cycles are invisible). Imputed closures (D11) are used as exit dates.
#}
{{ config(
    partition_by={'field': 'snapshot_date', 'data_type': 'date', 'granularity': 'month'},
    cluster_by=['service_category']
) }}

with as_of as (select data_through_date from {{ ref('meta_data_as_of') }})

select
    snapshot_date,
    r.request_id,
    r.service_category,
    date_diff(snapshot_date, r.opened_date, day) as age_days
from {{ ref('fact_service_requests') }} r
cross join as_of a
cross join unnest(generate_date_array(
    r.opened_date,
    least(coalesce(date_sub(r.closed_date, interval 1 day), a.data_through_date), a.data_through_date)
)) as snapshot_date
where not r.has_invalid_resolution_time
