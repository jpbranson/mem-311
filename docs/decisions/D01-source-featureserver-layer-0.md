---
type: Decision
id: D01
title: "D01 — Source: layer 0 of the 311 FeatureServer, read-only"
description: "Use layer 0 of the city FeatureServer; read-only access only"
tags: [source]
area: Source
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

**Decision.** Extract from
`https://311.memphistn.gov/server/rest/services/311/311_Request_Map_PROD/FeatureServer/0` ("311 Requests").
Layers 2–4 ("Reported Today", "Last 7 Days", "Transfer Pending") are filtered views of the same records and are
ignored. Table 1 (`CoM_311_Notes`) is not ingested (see [D02](D02-drop-personal-fields-at-extraction.md)).

**Evidence.** Layer 0 holds 406,902 records; its description is "all 311 requests created by 311 Support
center staff and citizens". The service advertises `Create,Update,Editing` capabilities to anonymous callers.
This project only issues `query` requests and sends an identifying User-Agent.

**Consequence.** Other open-data mirrors (e.g. data.memphistn.gov) were not used, so the pipeline depends on
this endpoint's schema. The extractor fails fast if any retained field disappears.
