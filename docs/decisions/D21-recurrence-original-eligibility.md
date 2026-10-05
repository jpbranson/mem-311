---
type: Decision
id: D21
title: "D21 — Who can be the original in a recurrence relationship"
description: "Only closed, dated, non-duplicate condition reports with a usable location can be an original"
tags: [recurrence]
area: Recurrence
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

**Decision.** An original must be a condition report ([D14](D14-administrative-types-not-recurrence-eligible.md)) opened in the analysis window, closed with a
recorded closure time (not imputed, [D11](D11-open-closed-status-and-imputed-closure.md)), with a non-negative resolution time ([D12](D12-negative-resolution-times.md)), not closed as a
duplicate ([D19](D19-closure-outcomes.md)) or in the mass closure ([D28](D28-mass-closure-2025-09-22.md)), not a load artifact ([D16](D16-bulk-load-artifact.md)), and with an address key or a valid
match point ([D23](D23-location-entity.md), [D29](D29-street-level-geocodes.md)). The follower (the "recurring" request) must be a condition report in the same
recurrence family, opened after the original closed.

**Evidence.** 299,839 of 345,016 closed condition reports qualify. The largest exclusions are the mass
closure (24,632 requests of all types), imputed closure times (16,883 of all types) and duplicate closures
(4,956).

**Reason.** Recurrence is measured from the moment the city said the problem was dealt with. Without a
trustworthy closure time there is no starting point for the window.
