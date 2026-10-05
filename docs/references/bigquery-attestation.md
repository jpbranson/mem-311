---
type: Reference
title: BigQuery executor and attester
description: How to run an Attested Computation on BigQuery and check the run - receipt fields, verdict checks and commands.
tags: [attestation, bigquery]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: okf-spec
    resource: https://github.com/GoogleCloudPlatform/open-knowledge-format/blob/main/SPEC.md
    title: Open Knowledge Format v0.2, section 10 (Attested computations)
---

Every concept in [computations](../computations/index.md) names these two scripts as its `executor` and
`attester`.[^okf-spec] Both are deterministic Python (no LLM) and use the caller's BigQuery credentials
(`GOOGLE_APPLICATION_CREDENTIALS`).

| File | Role |
|---|---|
| [`bigquery/run.py`](bigquery/run.py) | Executor. Binds only declared parameters, runs the computation unchanged, prints a receipt. |
| [`bigquery/attest.py`](bigquery/attest.py) | Attester. Re-reads the job by id and returns a pass/fail verdict. |
| [`bigquery/computation.py`](bigquery/computation.py) | Shared loader: frontmatter, the `# Computation` fence or `computation` file, parameter binding. |

# Examples

```bash
uv run python docs/references/bigquery/run.py docs/computations/recurrence-rates.md > receipt.json
uv run python docs/references/bigquery/attest.py docs/computations/recurrence-rates.md receipt.json
```

A computation with declared parameters takes `name=value` arguments after the concept path. Undeclared or
missing required parameters are refused.

# Receipt

`job_id`, `project`, `location`, `executed_sql` (the SQL BigQuery received), `parameters` and `result` (rows as
JSON). It is a runtime artifact: do not commit it.

# Verdict

The attester fails the run unless:

* the job is a finished query without errors that only read data (`SELECT`);
* the SQL the job ran equals the concept's computation, ignoring whitespace, and the receipt's SQL is that SQL;
* the job's query parameters are exactly the receipt's values for declared parameters, with declared types;
* the receipt's result equals the job's own output, re-read from BigQuery by job id.

It also reports `stale: true` when the concept is past its `stale_after`. Query results are kept for about 24
hours, so attest soon after running.

Verification and attestation are different things: `verified` on a concept says its *definition* was
reviewed; a passing verdict says one *run* used that definition.

[^okf-spec]: Open Knowledge Format v0.2, section 10
