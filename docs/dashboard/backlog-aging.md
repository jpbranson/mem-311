---
type: Dashboard Page
title: "Page 2 — Backlog Aging"
description: "Where is unresolved work accumulating? Backlog by age band over time, current backlog by category and age, share older than 90 days."
resource: ../../powerbi/build_guide.md
tags: [power-bi, backlog]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: build-guide
    resource: ../../powerbi/build_guide.md
    title: Power BI build guide, section 4, Page 2
---

**Question:** *Where is unresolved work accumulating?*[^build-guide]

# Visuals

| Row | Visual | Measures |
|---|---|---|
| 1 | Five cards: open requests at the snapshot date, % older than 30 and 90 days, median age, and old vs total backlog year over year (the page's key comparison) | [Open backlog](../metrics/open-backlog.md), [Backlog age](../metrics/backlog-age.md) |
| 2 | Backlog by age band over time (stacked area, darker = older) | Open Requests by Age Band |
| 3 | Current backlog by category and age (stacked bar); share older than 90 days over time (line) | [Open backlog](../metrics/open-backlog.md) |

Median backlog age is blank for multi-category selections, by design.

# Footnote

> Age = days between the report date and the snapshot date. The backlog fills up during the first six months
> after the October 2023 system go-live (burn-in, hidden). The 2025-09-22 drop is an administrative mass
> closure of mostly >90-day requests, not a surge in completed work.

Finding: [Old backlog keeps accumulating](../findings/F3-old-backlog-keeps-growing.md). Method:
[Backlog reconstruction](../methodology/backlog.md), [D25](../decisions/D25-backlog-reconstruction.md), [D28](../decisions/D28-mass-closure-2025-09-22.md).

[^build-guide]: Power BI build guide, section 4, Page 2
