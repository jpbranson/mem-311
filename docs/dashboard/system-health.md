---
type: Dashboard Page
title: "Page 1 — System Health"
description: "Is the service system keeping pace with demand? KPI cards, opened vs closed, net change, backlog trend and resolution trend."
resource: ../../powerbi/build_guide.md
tags: [power-bi, responsiveness, backlog]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: build-guide
    resource: ../../powerbi/build_guide.md
    title: Power BI build guide, section 4, Page 1
---

**Question:** *Is the service system keeping pace with demand?*[^build-guide]

# Visuals

| Row | Visual | Measures |
|---|---|---|
| 1 | Six KPI cards | Requests opened and closed, current backlog (with share older than 90 days), median and P90 resolution, 90-day recurrence |
| 2 | Opened vs closed by month (line); net change by month (column) | [Requests opened and closed](../metrics/request-volume.md) |
| 3 | Backlog trend (area); resolution time trend (line) | [Open backlog](../metrics/open-backlog.md), [Resolution time](../metrics/resolution-time.md) |

Selecting a month in the opened/closed chart filters the cards; the backlog trend does not cross-filter.

# Footnote

> Backlog is reconstructed from open and close dates; status history is not published, so reopen cycles are
> invisible. Resolution times exclude closures with no recorded close time (4%) and the 2025-09-22 mass closure.

Method: [Responsiveness](../methodology/responsiveness.md), [Backlog reconstruction](../methodology/backlog.md).

[^build-guide]: Power BI build guide, section 4, Page 1
