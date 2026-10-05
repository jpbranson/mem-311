---
type: Decision
id: D04
title: "D04 — Coordinates: geometry reprojected to WGS84, not X/Y attributes"
description: "Use feature geometry reprojected to WGS84, not the X/Y attributes"
tags: [coordinates]
area: Coordinates
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

**Decision.** Request `outSR=4326` and read `geometry.x/y` as longitude/latitude. Ignore the `X` and `Y`
attribute columns.

**Evidence.** The `X`/`Y` attributes mix coordinate systems. Some rows hold degrees (−90.07, 35.05) and others
hold Tennessee State Plane feet (778547, 307054). The layer's native CRS is EPSG:2274.
