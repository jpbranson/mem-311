---
type: Methodology
title: Populations
description: The nested populations every rate is computed over, from all live requests down to originals eligible for the 90-day recurrence rate.
tags: [scope]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-09-23T12:41:15Z }
stale_after: 2026-12-23T00:00:00Z
sources:
  - id: methodology
    resource: https://github.com/jpbranson/mem-311/blob/1a13bed/docs/methodology.md
    title: Methodology as one file, before the OKF conversion
  - id: full-extract-2026-09-23
    resource: raw.memphis_311_requests, full extraction batch of 2026-09-23 (data through 2026-09-22)
    title: Population sizes
---

| Population | Definition | Size |
|---|---|---:|
| All requests | Every live record in layer 0 of the city FeatureServer | 406,902 |
| Analysis window | Reported on or after 2023-10-01, excluding the 1,502-record bulk-load artifact ([D09](../decisions/D09-analysis-window-start.md), [D16](../decisions/D16-bulk-load-artifact.md)) | 405,398 |
| Condition reports | Request types that report a problem at a place, not a transaction such as a cart application ([D14](../decisions/D14-administrative-types-not-recurrence-eligible.md)) | 364,850 |
| Recurrence originals | Closed condition reports with a recorded closure, not duplicates or mass-closed, with a usable location ([D21](../decisions/D21-recurrence-original-eligibility.md)) | 299,839 |
| Eligible for the 90-day rate | Originals closed ≥90 days before the cut-off ([D22](../decisions/D22-primary-recurrence-definition.md)) | 265,983 |

Sizes are from the extraction of 2026-09-23, with data through 2026-09-22.[^full-extract-2026-09-23]

The 166 source request types are mapped to 24 service categories and 8 service groups in a reviewed seed,
[`request_type_map`](../tables/reference/request_type_map.md) ([D13](../decisions/D13-request-type-categories-seed.md)).

[^full-extract-2026-09-23]: Full extraction of 2026-09-23
