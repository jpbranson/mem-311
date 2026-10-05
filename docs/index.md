---
okf_version: "0.2"
---

# Start here

* [Memphis 311 Service Reliability](overview.md) - An operational analytics platform on Memphis 311 requests that measures how fast requests close, whether unresolved work piles up, and whether problems stay fixed.
* [Bundle conventions](conventions.md) - How this OKF v0.2 bundle is organized, generated, checked and kept trustworthy - read before adding or changing knowledge.

# What was decided, and how things are measured

* [Decisions](decisions/index.md) - Every judgment call, with its evidence, the alternatives and what it affects (D01–D32).
* [Methodology](methodology/index.md) - How each measure is defined and why: populations, responsiveness, backlog, recurrence, persistence, geography, limitations.
* [Metrics](metrics/index.md) - Dashboard measures: definition, DAX measure names, source columns, sanctioned computation and last checked value.
* [Computations](computations/index.md) - Attested Computations: the sanctioned BigQuery SQL behind every headline figure.

# What the data shows

* [Findings](findings/index.md) - What the data shows, with figures from the analytics marts.

# Data

* [Tables](tables/index.md) - Generated from dbt: one concept per BigQuery table, view, seed and raw source, with schema, lineage and tests.
* [Sources](sources/index.md) - External data the pipeline reads.

# Running and delivering

* [Playbooks](playbooks/index.md) - How to run, refresh, extend and validate the project.
* [Dashboard](dashboard/index.md) - The Power BI report, page by page.
* [References](references/index.md) - Executor and attester code for the Attested Computations.
* [Project](project/index.md) - The plan the project was built from, and ready-to-use portfolio text.
