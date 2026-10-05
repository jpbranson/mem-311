---
type: Playbook
title: Map a new request type
description: What to do when the city adds a REQUEST_TYPE - classify it in the request_type_map seed and rebuild.
tags: [seed, categories, operations]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: seed
    resource: ../../dbt/seeds/request_type_map.csv
    title: request_type_map seed
  - id: unmapped-test
    resource: ../../dbt/tests/assert_all_request_types_mapped.sql
    title: Warning test for unmapped request types
---

# Trigger

`dbt build` warns on
[`assert_all_request_types_mapped`](../../dbt/tests/assert_all_request_types_mapped.sql): a source
`REQUEST_TYPE` is missing from the seed, so its requests carry `service_category = 'Unmapped'`.[^unmapped-test]
They still count in volume and backlog, but sit outside every category view and outside recurrence.

# Steps

1. Run the test's query to list the new types and their volumes.
2. Add one row per type to [`dbt/seeds/request_type_map.csv`](../../dbt/seeds/request_type_map.csv) (columns in
   [`request_type_map`](../tables/reference/request_type_map.md)):[^seed]
   * `request_type`: exactly as in the source; `request_type_label`: without the department prefix.
   * `owning_unit`: the department implied by the prefix (`SWM-`, `CE-`, `PW (SM)-`, `EMI-`…), not `DEPARTMENT` ([D13](../decisions/D13-request-type-categories-seed.md)).
   * `service_category` (one of the 24), `service_group` (one of the 8), `recurrence_family`: follow the
     judgment calls in [D13](../decisions/D13-request-type-categories-seed.md).
   * `is_condition_report`: `false` for transactions such as applications, fees, new signs and proactive work
     orders ([D14](../decisions/D14-administrative-types-not-recurrence-eligible.md)).
   * `location_match_basis`: `property` when 25 m would reach a neighbour's problem (collection, carts, code
     enforcement, weeds), else `public_space` ([D22](../decisions/D22-primary-recurrence-definition.md)).
3. `uv run python scripts/run_pipeline.py --skip-extract` and confirm the warning is gone.
4. Commit the seed and the regenerated [tables](../tables/index.md). If the type changes a category's figures
   materially, note it in the [log](../log.md).

[^seed]: request_type_map seed
[^unmapped-test]: Warning test for unmapped request types
