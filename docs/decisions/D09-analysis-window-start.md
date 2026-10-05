---
type: Decision
id: D09
title: "D09 — Coverage: analysis window starts 2023-10-01"
description: "Analysis window starts 2023-10-01"
tags: [coverage]
area: Coverage
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

**Decision.** Staging keeps every record. Marts, rates and trends use requests reported on or after
2023-10-01 (America/Chicago).

**Evidence.** Only 2 records predate October 2023 (one each in June and August 2023). Monthly volume is
6,289 in 2023-10 and 8,000–17,000 thereafter. The city system appears to have gone live mid-October 2023:
most request types' first record is 2023-10-16. October 2023 is therefore a partial month and is flagged in
the monthly mart, not dropped.
