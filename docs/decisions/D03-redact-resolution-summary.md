---
type: Decision
id: D03
title: "D03 — Privacy: redact phone numbers and emails in `RESOLUTION_SUMMARY`"
description: "Redact phone numbers and emails in the one retained free-text field"
tags: [privacy]
area: Privacy
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

**Decision.** Keep `RESOLUTION_SUMMARY` (city-written closure text, needed for [D19](D19-closure-outcomes.md)), with phone- and
email-shaped substrings replaced by `[phone]` / `[email]`.

**Evidence.** The most common summaries are boilerplate ("Picked up", "Serviced by Public Works", referral
text to TDOT / MLGW), but several include department phone numbers. Names could not be ruled out.
