---
type: Decision
id: D19
title: "D19 — Heuristic closure outcomes"
description: "Classify closure outcomes heuristically from resolution text"
tags: [closure]
area: Closure
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

**Decision.** Classify each closed request into `closure_outcome` from `RESOLUTION_SUMMARY` and
`RESOLUTION_CODE` text rules. The outcomes are:
* `duplicate`: "already been reported", "duplicate"
* `referred`: TDOT, MLGW, private property, "purview"
* `no_issue_found`: "no potholes found", "no violation", "not out", "unable to locate"
* `misrouted`: "wrong service", "routed incorrectly", "reopened by system"
* `needs_info`: "please contact…to provide additional information"
* `completed_or_unspecified`: everything else

Duplicate closures are excluded as *original* requests in recurrence analysis. A duplicate cannot be
"resolved and then recur".

**Caveat.** 142k closed records have no summary and fall into `completed_or_unspecified`. The outcome is a
descriptive dimension, not a validated measure.
