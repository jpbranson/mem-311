---
type: Decision
id: D15
title: "D15 — Pothole stretch analysis: **not feasible; omitted**"
description: "Stretch analysis not feasible: AI-detected potholes are identifiable but too sparse; no Page 5"
tags: [pothole]
area: Pothole
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

**Decision.** Do not build the pothole detection analysis or the Power BI Page 5. Keep `is_ai_detected` as an
attribute on the fact table and document the finding.

**Evidence.**
* AI-detected records *can* be identified. 1,098 records carry the summary "Issue detected by Google AI
  Detection system and approved." and/or an image link on `memphis.egen.ai`. Of those, 758 are Drain Inlet
  Clogged, 207 Potholes and 120 Roadside Litter.
* Only **207 of 18,734 pothole requests (1.1%)** are AI-detected, and they come in bursts: 52 in 2025-01,
  59 in 2025-05, 37 in 2025-09, 35 in 2025-08, and single digits in other months. That pattern looks like a
  pilot run on occasional imagery batches, not a shift in how potholes enter the system.
* The source cannot separate citizen from staff/proactive reports. `GROUP_NAME` ("CITIZEN"/"MEMPHIS") is
  inconsistent and drifts over time. `created_user` is masked in query results. Only SeeClickFix intake (41%
  of potholes) is identifiable.
* The pre-period is short. Pothole records begin 2023-10, about 15 months before the first AI records.

**Plan criterion applied.** "If automated versus citizen-generated records cannot be distinguished reliably,
document that limitation and omit this analysis." Automated records *are* distinguishable. But the question
asked is whether a *transition* toward automated detection changed what 311 observes, and 207 bursty records
cannot support it. A before/after comparison would be dominated by seasonality and the 2025 system changes
([D11](D11-open-closed-status-and-imputed-closure.md)).
