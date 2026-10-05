---
type: Finding
title: What was checked and not found
description: No measurable shift to AI pothole detection, and closures without work do not explain the recurrence rate.
tags: [pothole, recurrence, validation]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: findings
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/findings.md
    title: Findings as one file, before the OKF conversion
  - id: recurrence-fact
    resource: ../tables/analytics/fact_service_requests.md
    title: fact_service_requests recurrence flags by closure outcome, data through 2026-09-22
---

* **Pothole detection.** AI-detected potholes exist but are 1.1% of pothole requests and arrive in bursts.
  There is no measurable shift to automated detection to analyse ([D15](../decisions/D15-pothole-analysis-omitted.md),
  [Pothole detection](../methodology/pothole-detection.md)).
* **Closures without work do not explain recurrence.** Originals referred elsewhere (20.4%) or closed as
  "not found" (19.6%) recur at about the same rate as completed ones (21.9%). Misrouted (45.7%) and needs-info
  (31.1%) closures recur more often, mostly because residents refile, but together they are 2% of eligible
  closures. Restricting to completed closures moves the headline from 22.1% to 21.9% ([D30](../decisions/D30-recurrence-match-validation.md)).[^recurrence-fact]

[^recurrence-fact]: fact_service_requests recurrence flags by closure outcome
