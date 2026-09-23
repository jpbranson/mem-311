{#
  One row per live 311 request, latest extracted version (D06, D07).
  Live = present in the most recent successful full snapshot, or in a successful incremental batch loaded after it.
  Types, statuses and timestamps are standardized here; business classification happens downstream.
#}
with batches as (
    select batch_id, extract_mode, started_at
    from {{ source('raw', 'ingestion_batches') }}
    where status = 'success'
),

latest_full as (
    select max(started_at) as started_at from batches where extract_mode = 'full'
),

live_batches as (
    select b.batch_id
    from batches b
    cross join latest_full f
    where b.started_at >= f.started_at
),

latest_version as (
    select r.*
    from {{ source('raw', 'memphis_311_requests') }} r
    inner join live_batches lb on r._batch_id = lb.batch_id
    qualify row_number() over (partition by r.OBJECTID order by r._ingested_at desc) = 1
),

typed as (
    select
        OBJECTID                                                    as request_id,
        INCIDENT_NUMBER                                             as request_number,
        GlobalID                                                    as global_id,
        INCIDENT_TYPE_ID                                            as request_type_code,
        coalesce(nullif(trim(REQUEST_TYPE), ''), '(none)')          as request_type,
        nullif(trim(DEPARTMENT), '')                                as source_department,
        nullif(trim(DIVISION), '')                                  as source_division,
        -- the source contains an en dash that some exports mangle to U+FFFD
        regexp_replace(nullif(trim(REQUEST_STATUS), ''), r'\s*[\x{2013}\x{FFFD}-]\s*', ' - ') as source_status,
        nullif(trim(Request_Sub_Status), '')                        as source_sub_status,
        nullif(trim(REQUEST_PRIORITY), '')                          as priority,

        REPORTED_DATE                                               as reported_at_utc,
        Closed_Date                                                 as source_closed_at_utc,
        RESOLVED_DATE                                               as source_resolved_at_utc,
        created_date                                                as created_at_utc,
        last_edited_date                                            as last_edited_at_utc,

        nullif(trim(RESOLUTION_CODE), '')                           as resolution_code,
        nullif(trim(RESOLUTION_SUMMARY), '')                        as resolution_summary,

        nullif(trim(Location_Address), '')                          as source_address,
        regexp_extract(ZipCode, r'^\s*(\d{5})')                     as zip_code,
        nullif(trim(PARCEL_ID), '')                                 as parcel_id,
        if(cd_name between 1 and 7, cd_name, null)                  as council_district,
        longitude,
        latitude,

        coalesce(is_ai_detected, false)                             as is_ai_detected,
        coalesce(is_seeclickfix, false)                             as is_seeclickfix,
        upper(Transfer) = 'YES'                                     as was_transferred,
        nullif(trim(Transfer_Dept), '')                             as transfer_department,
        _batch_id,
        _ingested_at
    from latest_version
),

status_std as (
    select
        *,
        case
            when lower(source_status) in ('closed', 'resolved') then 'closed'
            when source_status is null then if(coalesce(source_closed_at_utc, source_resolved_at_utc) is not null, 'closed', 'open')
            else 'open'
        end as status_group,
        -- D10: midnight-UTC reported timestamps are local calendar dates
        format_timestamp('%H:%M:%S', reported_at_utc) = '00:00:00' as opened_is_date_only
    from typed
),

times as (
    select
        *,
        if(opened_is_date_only,
           datetime(date(reported_at_utc)),
           {{ local_datetime('reported_at_utc') }})                          as opened_at,
        case when status_group = 'closed' then
            coalesce(source_closed_at_utc, source_resolved_at_utc, last_edited_at_utc)
        end                                                                  as closed_at_utc,
        case when status_group = 'closed' then
            case
                when source_closed_at_utc is not null then 'closed_date'
                when source_resolved_at_utc is not null then 'resolved_date'
                else 'last_edited_date'
            end
        end                                                                  as closed_at_source
    from status_std
)

select
    request_id,
    request_number,
    global_id,
    request_type_code,
    request_type,
    source_department,
    source_division,
    source_status,
    source_sub_status,
    status_group,
    status_group = 'open'                                             as is_open,
    priority,
    reported_at_utc,
    opened_at,
    date(opened_at)                                                   as opened_date,
    opened_is_date_only,
    closed_at_utc,
    {{ local_datetime('closed_at_utc') }}                             as closed_at,
    date({{ local_datetime('closed_at_utc') }})                       as closed_date,
    closed_at_source,
    closed_at_source = 'last_edited_date'                             as closed_at_is_imputed,
    source_closed_at_utc,
    created_at_utc,
    last_edited_at_utc,
    resolution_code,
    resolution_summary,
    source_address,
    zip_code,
    parcel_id,
    council_district,
    longitude,
    latitude,
    is_ai_detected,
    is_seeclickfix,
    was_transferred,
    transfer_department,
    extract(year from opened_at)                                      as opened_year,
    date_trunc(date(opened_at), month)                                as opened_month,
    _batch_id,
    _ingested_at
from times
