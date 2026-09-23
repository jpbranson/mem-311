# Portfolio Text

Ready-to-use descriptions of the project. Figures match [`findings.md`](findings.md) (data through
2026-09-22).

## Resume bullets

* Built an end-to-end analytics platform on Memphis 311 data (405k service requests): a Python/ArcGIS REST
  ingestion into BigQuery with incremental loads and snapshot-based delete detection, a 24-model dbt project
  with 77 data tests, and a 4-page Power BI dashboard.
* Designed a spatial **recurrence metric** that measures whether closed requests stay fixed. It combines
  address normalization, BigQuery GIS matching and category rules, is right-censored, and was checked with a
  39-definition sensitivity grid and manual validation (89% precision on a stratified sample).
* Reconstructed the daily open backlog by age band from open/close dates. This showed that requests older than
  180 days kept growing by about 190 a month after a 24,632-request administrative closure, while the total
  backlog swung by more than 20,000.
* Found that categories closed fastest are not the most durable. Sewer backups close in 0.5 days but recur
  21% of the time. Missed collection produces 58% of all repeat requests. 4.4% of locations account for 29% of
  recurrence cycles.
* Documented 30 data decisions with evidence, including dropping personal data at extraction, repairing
  mixed coordinate systems, imputing 16.9k missing closure dates, and detecting a bulk-load artifact and a
  mass closure.

## LinkedIn project description

**Memphis 311 Service Reliability: closing a ticket is not the same as fixing the problem**

Most 311 dashboards measure how fast requests are closed. I wanted to know whether problems stay fixed.

I built a pipeline that pulls every Memphis 311 request (405,000 since October 2023) from the city's ArcGIS
service into BigQuery, models it with dbt, and feeds a Power BI dashboard. Two measures do most of the work.

**Recurrence**: after the city closes a request, does a related one come back to the same place? This
needed address normalization, spatial matching in BigQuery GIS, category rules, and a sensitivity analysis.
Depending on the definition, the 90-day rate ranges from 17% to 65%, so the dashboard shows that range
instead of hiding it behind one number.

**Backlog dynamics**: rebuilding the open backlog day by day, by age, to separate a growing pile of old
work from ordinary swings in volume.

What the data showed:
• Sewer backups are closed in half a day, but one in five comes back within 90 days.
• Missed garbage and recycling pickups produce 58% of all repeat requests.
• A one-day administrative closure of 24,632 old requests cut the backlog by two thirds, but requests older
  than six months have kept accumulating at about 190 a month since.
• 4% of repeat locations account for 29% of recurrences.

Every judgment call (30 of them, from privacy to geocoding quirks) is documented with its evidence.

Stack: Python · BigQuery · dbt · SQL · GIS · Power BI

## One-line summary

An operational analytics platform on 405k Memphis 311 requests that measures responsiveness, backlog aging
and whether closed problems stay fixed (Python, BigQuery, dbt, GIS, Power BI).
