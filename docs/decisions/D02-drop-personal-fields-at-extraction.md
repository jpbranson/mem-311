---
type: Decision
id: D02
title: "D02 — Privacy: drop personal and free-text fields at extraction"
description: "Drop contact, owner, staff-name and free-text fields at extraction"
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

**Decision.** The following fields are never written anywhere, not even the raw layer:

* Resident contact: `CONTACT_NAME`, `CONTACT_EMAIL`, `CONTACT_PHONE`, `Anonymous`-related contact info
* Owner / utility customer: `CONTACT_NAME_FIRST` (owner name), `Owner_*`, `MLGW_CUSTOMER`, `MLGW_CONTACT1/2`,
  `MLGW_EMAIL`, `MLGW_PremiseCode`, `MLGW_CustCode`, `MLGW_EstDate`, `MLGW_STATUS`, `SWF_RATE`, `SWF_STATUS`
* Free text written by residents or staff: `REQUEST_SUMMARY`, `REQUEST_NOTES`, `JOB_NOTES`, `SCF_Description`,
  `Transfer_Notes`, `Supervisor_Notes`
* Staff identities: `created_user`, `last_edited_user`, `ASSIGNED_TO`, `SUPERVISOR`, `NOTIFICATION`
* The related notes table `CoM_311_Notes`

**Evidence.** The public endpoint returns contact emails on 139,662 records and phone numbers on 251,278.
A scan of pothole records found phone numbers, emails and caller names embedded in `SCF_Description` and
`REQUEST_SUMMARY` (e.g. "per the caller (name, phone)").

**Alternatives.** Keeping everything in a locked-down raw dataset (the plan says "preserve source data as
received") was rejected. None of these fields are needed for the analysis, and a portfolio repo plus Power BI
file are the wrong places for them.

**Consequence.** Two flags that need free text are derived *before* the fields are dropped: `is_ai_detected`
(from `REQUEST_SUMMARY` / `SCF_URL`) and `is_seeclickfix` (from `SCF_URL`). `SCF_URL` itself is also dropped.
The raw layer therefore deviates deliberately from "as received". Intake channel (staff vs. web) cannot be
recovered because `created_user` is masked for most records in query results anyway: group-by statistics
report 154,733 `Esri_Anonymous`, but feature queries return blank.
