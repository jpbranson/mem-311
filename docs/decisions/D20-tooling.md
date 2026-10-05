---
type: Decision
id: D20
title: "D20 — Tooling"
description: "Python 3.12 via uv; dbt-bigquery with service-account auth from an env var"
tags: [tooling]
area: Tooling
status: stable
logged_at: 2026-09-23T07:47:49Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T07:47:49Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (406,902 records)
    title: Evidence counts, unless the entry states otherwise
---

**Decision.** Python 3.12 (pinned via `.python-version`) managed by uv. dbt-core 1.12 with dbt-bigquery.
The dbt profile uses `method: service-account` with `keyfile: {{ env_var('GOOGLE_APPLICATION_CREDENTIALS') }}`,
so no credential path is committed. dbt writes custom schemas as literal dataset names (`staging`,
`intermediate`, `analytics`) via a `generate_schema_name` override.

**Reason.** uv initially resolved Python 3.14, which dbt 1.12 does not officially support.
