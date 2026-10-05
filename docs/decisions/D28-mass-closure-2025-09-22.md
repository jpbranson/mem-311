---
type: Decision
id: D28
title: "D28 — The 2025-09-22 administrative mass closure"
description: "Treat the 2025-09-22 administrative mass closure as a backlog exit, not a resolution"
tags: [quality]
area: Quality
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

**Decision.** A closure day is a **mass closure** if it has ≥10× the median daily number of closures and ≥80%
of its closures are more than 30 days old. Requests closed on such a day get `closure_outcome =
'administrative_mass_closure'`. They leave the backlog on that day, but they have no resolution time and
cannot be recurrence originals.

**Evidence.** Exactly one day qualifies. On 2025-09-22, 24,632 requests were closed, most of them aged. The
total backlog fell from 35,860 (2025-09-01) to 10,438 (2025-10-01). This coincides with the city-wide bulk
edits noted in [D07](D07-incremental-and-full-snapshots.md). Counting these as resolutions would put a spike of multi-month resolution times into
September 2025. Counting them as recurrence originals would add thousands of "closures" that describe no
service event.
