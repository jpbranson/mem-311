# intermediate dataset

* [int_backlog_daily_open](int_backlog_daily_open.md) - One row per request per local day it was open at end of day (D25).
* [int_recurrence_candidates](int_recurrence_candidates.md) - All original/follower pairs under the loosest definition (family, 100 m or same address, 180 days).
* [int_recurrence_originals](int_recurrence_originals.md) - Requests eligible to be the original in a recurrence relationship, with observed follow-up days (D21, D22).
* [int_recurrence_outcomes](int_recurrence_outcomes.md) - One row per recurrence original with first-recurrence timing and censoring-aware window flags.
* [int_request_locations](int_request_locations.md) - Location attributes per request - normalized address, matching key, coordinate validity, Census tract, location entity (D17, D18, D23).
* [int_requests_enriched](int_requests_enriched.md) - One row per request with classification, closure outcome, resolution time, data-quality flags and location entity.
