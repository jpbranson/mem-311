---
type: Methodology
title: Limitations
description: What the data and methods cannot show - reporting bias, recurrence ambiguity, location accuracy, category drift, closure meaning, no status history, short history.
tags: [limitations]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
---

* **Reporting bias.** 311 records are reported problems, not all problems. Areas and services with lower
  reporting look healthier than they are.
* **Recurrence ambiguity.** A return report can mean an unfixed problem, a poor repair or a new incident.
  Recurrence is a proxy, validated at roughly 89% precision on a small sample
  ([Recurrence validation](recurrence-validation.md)).
* **Location accuracy.** Addresses are free text and coordinates sometimes fall back to street-level or
  default points. Mitigations: [D17](../decisions/D17-valid-coordinates.md), [D23](../decisions/D23-location-entity.md), [D29](../decisions/D29-street-level-geocodes.md).
* **Category changes.** Department assignments drifted in late 2025. Categories come from the request type,
  which is stable, not the department ([D13](../decisions/D13-request-type-categories-seed.md)).
* **Closure meaning.** A closed ticket is the city's statement, not a verified fix. 16,883 closures have no
  closure date ([D11](../decisions/D11-open-closed-status-and-imputed-closure.md)), and one day of mass closure removed 24,632 requests ([D28](../decisions/D28-mass-closure-2025-09-22.md)).
* **No status history.** Reopen/close cycles cannot be seen, so the backlog assumes each request was open
  continuously until its final closure ([D25](../decisions/D25-backlog-reconstruction.md)).
* **Short history.** The current system starts in October 2023, which gives about three years of data and only
  two complete seasonal cycles.
