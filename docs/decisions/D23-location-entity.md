---
type: Decision
id: D23
title: "D23 — Location entity"
description: "Location entity = address key when a house number exists, else an 8-character geohash cell"
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
  - resource: ../../dbt/macros/normalize_address.sql
---

**Decision.** A request's location is its **address key** (normalized address with a non-zero house number,
trailing street type removed) when available. Otherwise it is the **8-character geohash** (~38 m × 19 m) of a
valid, non-street-level coordinate. An address key whose points are more than 250 m apart is flagged
`is_spatially_inconsistent` and excluded from persistent-location rankings.

**Evidence.** 390,669 of 405,398 in-window requests (96.4%) have an address key. 10,520 more fall into
8,143 grid cells. 4,209 have no usable location. 661 of 144,499 address locations are spatially
inconsistent: points more than 250 m apart share one address key.

**Normalization** (`dbt/macros/normalize_address.sql`) drops a leading business name before a house number
("Dollar General, 1234 Getwell Rd"), city/state/ZIP, unit designators and punctuation. It abbreviates
street types and directionals and reduces a house-number range to its first number. "2785 CLAUDETTE" and
"2785 CLAUDETTE RD" share a key.
