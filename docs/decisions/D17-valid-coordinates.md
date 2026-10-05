---
type: Decision
id: D17
title: "D17 — Valid coordinates"
description: "Coordinates are valid only inside Shelby County and away from geocoder default points"
tags: [location]
area: Location
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

**Decision.** `has_valid_coordinates = true` only when the point is inside Shelby County (Census county
polygon) **and** is not a geocoder default point. A default point is a coordinate shared by ≥50 requests whose
address is null or spread across ≥10 distinct addresses. Records without valid coordinates are kept for
responsiveness and backlog metrics but excluded from spatial matching.

**Evidence.** 24 records have no geometry. 1,088 sit at one point in Arkansas (−92.509, 34.154), a geocoding
fallback. One Memphis point (−90.050, 35.208) holds 181 records, 61 with null address. In total, 405,652 of
406,902 records fall inside a Memphis-area bounding box.
