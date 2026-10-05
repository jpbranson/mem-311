---
type: Finding
title: System at a glance
description: "Headline figures: 405,398 requests, 6.6-day median resolution, 21,181 open, 22.1% of eligible closures recur within 90 days."
tags: [summary]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: findings
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/findings.md
    title: Findings as one file, before the OKF conversion
  - id: headline-sql
    resource: ../computations/index.md
    title: Attested Computations for the headline figures, run on data through 2026-09-22
---

Data: Memphis 311, 405,398 requests reported 2023-10-01 to 2026-09-22 (extracted 2026-09-23). Definitions are in
the [methodology](../methodology/index.md). Every number can be reproduced from the `analytics` marts; the
headline figures have sanctioned SQL in [computations](../computations/index.md).[^headline-sql] The findings
are descriptive: they show where to look, not why it happens.

| Measure | Value |
|---|---:|
| Requests reported | 405,398 |
| Median resolution time | 6.6 days |
| P90 resolution time | 46.5 days |
| Open at 2026-09-22 | 21,181 |
| 90-day recurrence rate (primary definition) | 22.1% of 265,983 eligible closures |

[^headline-sql]: Attested Computations for the headline figures
