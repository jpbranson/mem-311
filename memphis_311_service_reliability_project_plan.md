# Memphis Urban Service Reliability Platform
## Revised Project Plan

## Project Goal

Build an end-to-end analytics platform using Memphis 311 service-request data to measure not only how quickly service requests are closed, but also whether problems **stay resolved** and whether unresolved work accumulates over time.

The platform should demonstrate an industry-style analytics workflow using Python, BigQuery, dbt, SQL, GIS, and Power BI.

The central questions are:

1. **Responsiveness:** How quickly are Memphis 311 requests resolved?
2. **Backlog health:** Are unresolved requests accumulating or aging?
3. **Durability:** After a request is closed, how often does the same or a similar problem recur at the same location?
4. **Persistent problems:** Which locations repeatedly generate the same types of requests?
5. **Stretch analysis:** For potholes, can Memphis's shift toward automated detection reveal differences between citizen-reported problems and proactively detected problems?

The project's distinctive contribution should be **recurrence and backlog dynamics**, rather than simply another map of 311 requests.

---

# Overall Analytical Framework

## 1. Responsiveness

Measure how quickly service requests move through the system.

Primary metrics:

- Requests opened
- Requests closed
- Median resolution time
- 90th-percentile resolution time
- Percentage resolved within selected time thresholds
- Resolution-time trends
- Resolution time by request category

This provides conventional operational context but should not be the project's primary contribution.

---

## 2. Backlog Health

Treat the backlog as a changing population rather than a single count.

Track:

- Total open requests
- New requests entering backlog
- Requests leaving backlog
- Net backlog change
- Median age of open requests
- 90th-percentile age of open requests

Create backlog age bands such as:

- Under 7 days
- 7–30 days
- 31–90 days
- 91–180 days
- More than 180 days

Track how those cohorts change over time.

Key question:

**Is a high backlog simply the result of high incoming volume, or are old requests accumulating faster than they are resolved?**

---

## 3. Service Durability

Develop a measure of whether closed service requests remain resolved.

The basic concept:

> A request is considered recurrent when a related request appears at the same or nearby location within a specified period after closure.

Calculate:

- 30-day recurrence rate
- 90-day recurrence rate
- 180-day recurrence rate
- Median time to recurrence
- Number of recurrence cycles
- Recurrence rate by request type
- Recurrence rate by geography

This should become one of the project's primary metrics.

---

## 4. Persistent Problem Locations

Identify locations that repeatedly generate service requests over long periods.

For each persistent location, calculate:

- Total requests
- First recorded request
- Most recent request
- Number of years with activity
- Number of recurrence cycles
- Most common request categories
- Average and median resolution time
- Number of unresolved requests
- Average time between requests

The goal is to distinguish isolated incidents from chronic locations.

---

## 5. Pothole Detection Analysis — Stretch Goal

If the data supports it, investigate Memphis's transition from primarily citizen-reported potholes toward proactive or automated detection.

Potential questions:

- Did pothole request volume change after automated detection expanded?
- Did the geographic distribution of requests change?
- Did neighborhoods with historically low reporting see more identified potholes?
- Did resolution times change?
- Did recurrence rates change?
- Did automated detection identify problems earlier than citizen reporting?

Do not make this a required component until the source data is inspected.

If automated versus citizen-generated records cannot be distinguished reliably, document that limitation and omit this analysis.

---

# Technical Architecture

```text
Memphis 311 ArcGIS API
        ↓
Python ingestion
        ↓
BigQuery raw layer
        ↓
dbt staging models
        ↓
dbt intermediate models
        ↓
Analytical marts
        ↓
Power BI
```

Supporting components:

- Git/GitHub
- dbt tests
- data dictionary
- methodology documentation
- architecture diagram
- GIS/spatial processing

---

# Data Model

## Raw Layer

Preserve source data as received.

Example:

`raw.memphis_311_requests`

Add ingestion metadata:

- `_ingested_at`
- `_batch_id`
- `_source`

---

## Staging Layer

Example:

`staging.stg_311_requests`

Standardize:

- request ID
- creation timestamp
- closure timestamp
- status
- service type
- description/category
- latitude
- longitude
- address
- agency/department
- source fields if available

Derived fields:

- resolution hours
- resolution days
- request year
- request month
- open/closed status
- valid-coordinate indicator

---

## Core Analytical Tables

### `analytics.fact_service_requests`

One row per service request.

Fields could include:

- request_id
- opened_at
- closed_at
- resolution_hours
- request_type_id
- location_id
- geography_id
- status
- latitude
- longitude

---

### `analytics.dim_request_type`

Standardized request classifications.

Retain:

- source request type
- standardized category
- higher-level service group

---

### `analytics.dim_date`

Standard calendar dimension.

---

### `analytics.dim_location`

A derived location entity used to identify repeated requests.

Possible fields:

- location_id
- standardized address
- centroid latitude
- centroid longitude
- Census tract
- neighborhood or other geography

---

# Analytical Marts

## `agg_monthly_service_performance`

Fields:

- month
- service category
- requests opened
- requests closed
- median resolution time
- 90th-percentile resolution time

---

## `agg_backlog_age`

Fields:

- reporting date
- age band
- service category
- number of open requests
- median age
- 90th-percentile age

---

## `fact_request_recurrence`

One row per identified recurrence relationship.

Possible fields:

- original_request_id
- recurring_request_id
- location_id
- days_between
- same_category
- recurrence_window

---

## `agg_service_recurrence`

Fields:

- service category
- 30-day recurrence rate
- 90-day recurrence rate
- 180-day recurrence rate
- median days to recurrence

---

## `agg_persistent_locations`

Fields:

- location_id
- total requests
- first request date
- most recent request date
- number of active months/years
- recurrence cycles
- dominant category
- median resolution time
- unresolved requests

---

# Recurrence Methodology

This is the project's most important methodological component.

## Phase A — Exact Location Matching

Start with standardized address matching.

Standardize:

- street abbreviations
- capitalization
- punctuation
- unit information
- whitespace

Determine how reliably Memphis addresses can be matched.

---

## Phase B — Spatial Matching

Use coordinates to match nearby requests.

Test several distances:

- 25 meters
- 50 meters
- 100 meters

Do not assume one radius is correct.

Compare results manually using samples.

---

## Phase C — Category Similarity

A nearby request should not automatically count as recurrence.

For example:

- pothole → pothole likely represents recurrence
- pothole → missed garbage pickup probably does not

Create rules based on:

- exact request category
- standardized higher-level service category
- related-category mappings

---

## Phase D — Time Window

Calculate recurrence separately at:

- 30 days
- 90 days
- 180 days

Avoid choosing one arbitrary threshold as the only definition.

---

## Phase E — Sensitivity Analysis

Report how recurrence rates change when:

- radius changes
- recurrence window changes
- exact-category versus broad-category matching is used

This demonstrates analytical judgment rather than treating the recurrence definition as objectively fixed.

---

# Backlog Cohort Methodology

For each reporting date, determine which requests remained open.

Calculate request age as:

```text
reporting_date - opened_date
```

Assign requests to age bands.

Then examine:

- cohort growth
- cohort resolution
- percentage of backlog older than 30/90/180 days
- whether old backlog is growing faster than new backlog

This should allow statements such as:

> Overall backlog remained stable, but requests older than 90 days increased.

That is more operationally meaningful than reporting the total backlog alone.

---

# Geographic Analysis

Assign requests and persistent locations to useful Memphis geographies such as:

- Census tract
- ZIP code
- council district
- neighborhood, if a defensible boundary source is available

Geographic measures should include:

- request volume
- median resolution time
- backlog age
- recurrence rate
- persistent-location count

Exercise caution with per-capita complaint rates.

311 reporting depends partly on resident reporting behavior, so request volume should not automatically be interpreted as underlying service need.

---

# Power BI Dashboard

## Page 1 — System Health

Executive overview.

Show:

- Requests opened
- Requests closed
- Current backlog
- Median resolution time
- 90th-percentile resolution time
- 90-day recurrence rate

Visuals:

- monthly opened versus closed
- backlog trend
- resolution-time trend

Primary question:

**Is the overall service system keeping pace with demand?**

---

## Page 2 — Backlog Aging

Show:

- backlog by age band
- percentage older than 30 days
- percentage older than 90 days
- median backlog age
- backlog age over time

Allow filtering by request category.

Primary question:

**Where is unresolved work accumulating?**

---

## Page 3 — Service Durability

Show:

- 30-, 90-, and 180-day recurrence
- recurrence by service category
- median time until recurrence
- distribution of recurrence cycles

Example analytical comparison:

| Service | Median Resolution | 90-Day Recurrence |
|---|---:|---:|
| Category A | 3 days | 7% |
| Category B | 2 days | 28% |

Primary question:

**Which services are closed quickly but frequently return?**

---

## Page 4 — Persistent Locations

Map and rank locations with repeated requests.

Show:

- recurrence cycles
- request history
- dominant service type
- first and latest request
- unresolved requests

Allow selection of a location to reveal its event history.

Primary question:

**Where are chronic problems concentrated?**

---

## Page 5 — Pothole Detection Analysis

Only build this page if source data supports the analysis.

Possible visuals:

- pothole requests over time
- geographic distribution before/after detection changes
- response time
- recurrence
- citizen versus automated source, if identifiable

Primary question:

**Did proactive detection change what the 311 system observes?**

---

# Revised Timeline

## Week 1 — Data Audit and Research Design

### Deliverables

- Repository
- Source-data inventory
- Data dictionary draft
- Analytical question document
- Initial recurrence methodology
- Initial backlog methodology
- Assessment of whether pothole source/type can be identified

### Tasks

1. Inspect the ArcGIS API.
2. Download a representative sample.
3. Review available fields.
4. Examine historical coverage.
5. Determine whether records are updated after creation.
6. Inspect location quality.
7. Inspect service categories.
8. Determine whether pothole records contain useful source metadata.
9. Write metric definitions before implementation.

### Decision gate

At the end of Week 1, determine whether the pothole stretch analysis is feasible.

---

## Week 2 — Python Ingestion

### Deliverables

- Repeatable historical extraction
- Pagination handling
- Raw-data storage
- Logging
- API validation
- BigQuery loading prototype

### Tasks

1. Write API request function.
2. Handle pagination.
3. Validate extracted record count.
4. Preserve raw fields.
5. Add ingestion metadata.
6. Write basic failure handling.
7. Upload initial raw dataset to BigQuery.

---

## Week 3 — Warehouse and Incremental Pipeline

### Deliverables

- BigQuery raw layer
- Incremental ingestion method
- Raw/staging/analytics organization
- Duplicate/update handling

### Tasks

1. Configure BigQuery datasets.
2. Establish field types.
3. Determine update key.
4. Implement merge/upsert behavior where needed.
5. Validate historical counts.
6. Test repeat execution.

At the end of Week 3:

```text
Memphis API → Python → BigQuery
```

should work reliably.

---

## Week 4 — dbt Core Models

### Deliverables

- dbt configuration
- staging model
- fact table
- dimensions
- tests
- documentation

### Tasks

1. Define source.
2. Clean timestamps.
3. Standardize statuses.
4. Standardize service categories.
5. Calculate resolution times.
6. Create date dimension.
7. Create service dimension.
8. Create fact table.
9. Add tests.
10. Document models.

---

## Week 5 — Recurrence and Persistence

This is the project's main analytical development week.

### Deliverables

- Location entity methodology
- Recurrence table
- 30/90/180-day measures
- Persistent-location table
- Sensitivity analysis

### Tasks

1. Standardize addresses.
2. Test exact-address matching.
3. Build coordinate-based matching.
4. Compare 25m/50m/100m radii.
5. Build category matching.
6. Link recurrent requests.
7. Calculate recurrence windows.
8. Manually inspect samples.
9. Document false-match risks.
10. Build persistent-location metrics.

---

## Week 6 — Backlog Dynamics and Geography

### Deliverables

- Backlog cohorts
- Aging measures
- Geographic joins
- Analytical marts

### Tasks

1. Reconstruct open backlog by reporting period.
2. Assign age bands.
3. Calculate backlog inflow/outflow.
4. Create age-distribution trends.
5. Join geographic boundaries.
6. Calculate geographic recurrence.
7. Calculate geographic backlog metrics.
8. Build Power BI-ready marts.

---

## Week 7 — Power BI

### Deliverables

- System Health page
- Backlog Aging page
- Service Durability page
- Persistent Locations page

### Tasks

1. Connect Power BI to analytics marts.
2. Build dimensional model.
3. Develop DAX measures.
4. Prototype layouts.
5. Build interactions.
6. Create geographic visualizations.
7. Check dashboard calculations against SQL output.

Do not build the pothole page yet unless the core dashboard is complete.

---

## Week 8 — Validation and Portfolio Packaging

### Deliverables

- Final dashboard
- README
- Architecture diagram
- Methodology document
- Data-quality notes
- Key findings
- Dashboard screenshots
- Resume bullets
- LinkedIn project description

### Tasks

1. Validate recurrence matches manually.
2. Run sensitivity analysis.
3. Verify backlog calculations.
4. Improve dbt tests.
5. Identify 3–5 substantive findings.
6. Document limitations.
7. Clean GitHub repository.
8. Produce architecture diagram.
9. Write portfolio README.
10. Add pothole analysis only if core project is already complete.

---

# Minimum Viable Project

To protect against scope creep, define a minimum version.

The project is already valuable if it contains:

1. Automated Python ingestion
2. BigQuery warehouse
3. dbt staging/fact/dimension models
4. Recurrence methodology
5. Backlog aging analysis
6. Power BI dashboard with:
   - system health
   - backlog aging
   - recurrence
   - persistent locations

Everything else is optional.

The pothole analysis is explicitly a **stretch goal**.

---

# Key Analytical Deliverables

The finished project should ideally produce findings resembling:

- Some service categories are closed rapidly but have unusually high recurrence.
- Long-term backlog is moving differently from total backlog.
- A small number of locations account for disproportionate repeat service activity.
- Recurrence differs substantially depending on service type.
- Apparent service performance changes when durability is considered alongside closure speed.

These are examples only.

Do not decide conclusions before running the analysis.

---

# Methodological Limitations to Document

The README should explicitly discuss:

### Reporting bias

311 records reflect reported problems, not necessarily all underlying problems.

### Recurrence ambiguity

Two nearby complaints may refer to:

- the same unresolved problem
- a poorly repaired problem
- a genuinely new incident

Recurrence should therefore be described as an **operational proxy**, not confirmed service failure.

### Location accuracy

Addresses and coordinates may be inconsistent.

### Category changes

311 service classifications may change over time.

### Closure meaning

A closed ticket may not necessarily mean the underlying physical condition was permanently resolved.

These limitations strengthen the project when handled transparently.

---

# Portfolio Positioning

The final project should be presented as:

> An operational analytics platform examining service responsiveness, backlog health, and repeat incidents within Memphis's 311 system.

Not:

> An analysis of Memphis 311 complaints.

The project's main technical story is:

```text
Python
  ↓
BigQuery
  ↓
dbt
  ↓
dimensional + longitudinal modeling
  ↓
spatial recurrence analysis
  ↓
Power BI
```

The main analytical story is:

> **Closing a service request quickly is not necessarily the same as solving the problem reliably.**

That distinction should be the organizing idea throughout the project.

