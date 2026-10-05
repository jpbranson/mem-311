---
type: Decision
id: D24
title: "D24 — Spatial matching via grid cells"
description: "Spatial matching via a grid-cell equi-join plus exact distance check, not a bare `ST_DWITHIN` join"
tags: [performance]
area: Performance
status: stable
logged_at: 2026-09-23T12:41:15Z
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: decision-log
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/decisions.md
    title: Decision log as one file, before the OKF conversion
    last_modified: 2026-09-27T20:56:38Z
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (406,902 records)
    title: Evidence counts, unless the entry states otherwise
---

**Decision.** Candidate pairs within 100 m are found with an equi-join on ~105 m grid cells. Each follower is
expanded to its 3×3 cell neighbourhood, and an exact `ST_DWITHIN` check on the joined rows follows. Address
matches come from a separate equi-join on the address key. The union of both is the candidate table
(`int_recurrence_candidates`). Every stricter definition is a filter on it.

**Evidence.** A direct `ST_DWITHIN` join carrying the family and time-window predicates did not finish within
10 minutes.
