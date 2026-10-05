---
type: Methodology
title: Pothole detection (stretch goal, omitted)
description: The planned before/after analysis of AI pothole detection, dropped because AI-detected potholes are 1.1% of pothole requests and arrive in bursts.
tags: [pothole, scope]
status: deprecated
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
---

AI-detected potholes can be identified (1,098 AI-detected records, 207 of them potholes), but they are 1.1% of
pothole requests and arrive in irregular bursts. That cannot support a before/after analysis of a shift to
automated detection ([D15](../decisions/D15-pothole-analysis-omitted.md)).

Kept for links and history: the analysis and the planned dashboard Page 5 were never built. The
`is_ai_detected` flag remains on [`fact_service_requests`](../tables/analytics/fact_service_requests.md) for
ad-hoc filtering. The original scope is in the [project plan](../project/plan.md).
