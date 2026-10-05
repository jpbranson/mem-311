# Week 1 data audit

* [D01 — Source: layer 0 of the 311 FeatureServer, read-only](D01-source-featureserver-layer-0.md) - Use layer 0 of the city FeatureServer; read-only access only
* [D02 — Privacy: drop personal and free-text fields at extraction](D02-drop-personal-fields-at-extraction.md) - Drop contact, owner, staff-name and free-text fields at extraction
* [D03 — Privacy: redact phone numbers and emails in `RESOLUTION_SUMMARY`](D03-redact-resolution-summary.md) - Redact phone numbers and emails in the one retained free-text field
* [D04 — Coordinates: geometry reprojected to WGS84, not X/Y attributes](D04-coordinates-from-geometry.md) - Use feature geometry reprojected to WGS84, not the X/Y attributes
* [D05 — Ingestion: keyset pagination on OBJECTID](D05-keyset-pagination.md) - Keyset pagination on OBJECTID
* [D06 — Warehouse: append-only raw table; staging picks latest version](D06-append-only-raw-table.md) - Append-only raw table with batch metadata; dedupe in staging
* [D07 — Incremental strategy: watermark + periodic full snapshot](D07-incremental-and-full-snapshots.md) - Full snapshot plus watermark-based incremental; deletes inferred from snapshots
* [D08 — Keys](D08-record-and-business-keys.md) - OBJECTID is the record key; INCIDENT_NUMBER is the business key
* [D09 — Coverage: analysis window starts 2023-10-01](D09-analysis-window-start.md) - Analysis window starts 2023-10-01
* [D10 — Time zones and date-only reported timestamps](D10-time-zones-and-date-only-timestamps.md) - Convert timestamps to America/Chicago; treat midnight-UTC reported dates as date-only
* [D11 — Open/closed status and imputed closure time](D11-open-closed-status-and-imputed-closure.md) - Status is authoritative for open/closed; closure time falls back through RESOLVED_DATE then last_edited_date
* [D12 — Negative resolution times](D12-negative-resolution-times.md) - Negative resolution times are set to null, not zeroed
* [D13 — Standardized request categories via a reviewed seed](D13-request-type-categories-seed.md) - Standardize the 166 request types into 24 categories via a reviewed seed, not DEPARTMENT
* [D14 — Administrative request types are not recurrence-eligible](D14-administrative-types-not-recurrence-eligible.md) - Flag administrative request types as not eligible for recurrence
* [D15 — Pothole stretch analysis: **not feasible; omitted**](D15-pothole-analysis-omitted.md) - Stretch analysis not feasible: AI-detected potholes are identifiable but too sparse; no Page 5
* [D16 — Exclude a bulk-load artifact](D16-bulk-load-artifact.md) - Exclude a bulk-load artifact (1,502 records at one address on one day)
* [D17 — Valid coordinates](D17-valid-coordinates.md) - Coordinates are valid only inside Shelby County and away from geocoder default points
* [D18 — Geography](D18-geography.md) - Use Census tracts (spatial join), council district (source field) and ZIP; no neighborhoods
* [D19 — Heuristic closure outcomes](D19-closure-outcomes.md) - Classify closure outcomes heuristically from resolution text
* [D20 — Tooling](D20-tooling.md) - Python 3.12 via uv; dbt-bigquery with service-account auth from an env var

# Recurrence, backlog and validation

* [D21 — Who can be the original in a recurrence relationship](D21-recurrence-original-eligibility.md) - Only closed, dated, non-duplicate condition reports with a usable location can be an original
* [D22 — Primary recurrence definition and right-censoring](D22-primary-recurrence-definition.md) - Primary definition: same category, same address (or ≤25 m for public-space problems), 90 days; right-censored
* [D23 — Location entity](D23-location-entity.md) - Location entity = address key when a house number exists, else an 8-character geohash cell
* [D24 — Spatial matching via grid cells](D24-spatial-matching-grid-cells.md) - Spatial matching via a grid-cell equi-join plus exact distance check, not a bare `ST_DWITHIN` join
* [D25 — Backlog reconstruction and burn-in](D25-backlog-reconstruction.md) - Reconstruct the daily backlog from open/close dates; flag a 181-day burn-in after go-live
* [D26 — Responsiveness counting rules](D26-responsiveness-counting-rules.md) - Count events in the month they happen; resolution percentiles by closure month
* [D27 — Persistent-location tiers](D27-persistent-location-tiers.md) - Chronic / Persistent / Repeat tiers from request count, active months and recurrence cycles
* [D28 — The 2025-09-22 administrative mass closure](D28-mass-closure-2025-09-22.md) - Treat the 2025-09-22 administrative mass closure as a backlog exit, not a resolution
* [D29 — Street-level geocodes](D29-street-level-geocodes.md) - Street-level geocodes (street name without house number) are excluded from distance matching
* [D30 — Manual validation of recurrence matches](D30-recurrence-match-validation.md) - Manual review of an 80-pair stratified sample; headline definition kept, false-match risks documented

# Operations

* [D31 — A status file for the project tracker](D31-tracker-status-file.md) - Every refresh publishes a status file for the project tracker: fail, warn when the source is stale, ok otherwise
* [D32 — An empty full extraction fails](D32-empty-full-extract-fails.md) - A full extraction that returns 0 rows fails instead of recording an empty snapshot
