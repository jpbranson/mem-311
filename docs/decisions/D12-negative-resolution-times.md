---
type: Decision
id: D12
title: "D12 — Negative resolution times"
description: "Negative resolution times are set to null, not zeroed"
tags: [status]
area: Status
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

**Decision.** If `closed_at < opened_at`, resolution time is null and `has_invalid_resolution_time = true`.
Values are not clipped to zero. Date-only records are compared at date grain.

**Evidence.** 951 records have `Closed_Date < REPORTED_DATE`.
