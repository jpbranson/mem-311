---
type: Decision
id: D16
title: "D16 — Exclude a bulk-load artifact"
description: "Exclude a bulk-load artifact (1,502 records at one address on one day)"
tags: [quality]
area: Quality
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

**Decision.** Flag `is_bulk_artifact` on any group of ≥100 requests with the same address, request type and
reported date. Exclude flagged records from every mart.

**Evidence.** 1,502 `MCSC-Miscellaneous` records at "4532 Jamerson Rd" were all reported on 2024-06-03 at one
coordinate. No other group of this kind reaches 100. Left in, this address would top the persistent-location
ranking and distort the June 2024 open/close trend.
