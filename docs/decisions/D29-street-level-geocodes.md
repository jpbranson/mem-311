---
type: Decision
id: D29
title: "D29 — Street-level geocodes"
description: "Street-level geocodes (street name without house number) are excluded from distance matching"
tags: [location]
area: Location
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

**Decision.** A request whose address is a street name with no house number (not an intersection), sharing a
coordinate with 2+ other such requests, is a **street-level geocode**. It keeps its coordinates for mapping but
gets no `match_point`, so it cannot drive distance-based recurrence matches.

**Evidence.** Found during manual validation. Requests giving only a street name geocode to one point per
street, so every pothole on that street "recurred" within 0 m. 4,091 requests are flagged.
