---
type: Dashboard Page
title: "Page 3 — Service Durability"
description: "Which services are closed quickly but frequently return? Recurrence cards, speed vs durability table and scatter, time to recurrence, tract map, definition sensitivity."
resource: ../../powerbi/build_guide.md
tags: [power-bi, recurrence]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: build-guide
    resource: ../../powerbi/build_guide.md
    title: Power BI build guide, section 4, Page 3
---

**Question:** *Which services are closed quickly but frequently return?*[^build-guide]

# Visuals

| Row | Visual | Measures |
|---|---|---|
| 1 | Four cards: recurrence rate at 30, 90 and 180 days; median days to recurrence | [Recurrence rate](../metrics/recurrence-rate.md) |
| 2 | Speed vs durability table (categories with ≥500 eligible originals) and scatter | Median Resolution, Recurrence Rate 90d, Speed vs Durability |
| 3 | Time to recurrence (column); recurrence by Census tract (Shape Map); definition-sensitivity matrix | Recurrence Relationships, Recurrence Rate 90d, Sensitivity Recurrence Rate |

The sensitivity matrix keeps scope and window single-select; it shows that the headline depends on a stated
definition ([Recurrence sensitivity](../methodology/recurrence-sensitivity.md)).

# Footnote

> Recurrence = a related request (same service category) at the same address, or within 25 m for street and
> public-space problems, after the original was closed. Only requests observed for the full window count. It
> is an operational proxy: a return report may be an unfixed problem, a poor repair or a new incident. See
> docs/methodology/recurrence.md.

Findings: [F1](../findings/F1-fast-is-not-durable.md), [F5](../findings/F5-durability-varies-within-the-city.md).
Method: [Recurrence](../methodology/recurrence.md), [D22](../decisions/D22-primary-recurrence-definition.md).

[^build-guide]: Power BI build guide, section 4, Page 3
