---
type: Decision
id: D08
title: "D08 — Keys"
description: "OBJECTID is the record key; INCIDENT_NUMBER is the business key"
tags: [keys]
area: Keys
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

**Decision.** `OBJECTID` is the record key through raw and staging. `INCIDENT_NUMBER` (the city's "Service
Request Number") is exposed as the business key `request_number`.

**Evidence.** OBJECTID, INCIDENT_NUMBER and GlobalID are each unique across all 406,902 rows; no nulls.
`LINKED_SR` ("Duplicate SR") is null on every record, so source-declared duplicate links are unavailable.
