# Key Findings

Data: Memphis 311, 405,398 requests reported 2023-10-01 to 2026-09-22 (extracted 2026-09-23). Definitions
are in [`methodology.md`](methodology.md). Every number here can be reproduced from the `analytics` marts
(see `powerbi/validation_queries.sql` for the headline figures). The findings are descriptive: they show where
to look, not why it happens.

## System at a glance

| Measure | Value |
|---|---:|
| Requests reported | 405,398 |
| Median resolution time | 6.6 days |
| P90 resolution time | 46.5 days |
| Open at 2026-09-22 | 21,181 |
| 90-day recurrence rate (primary definition) | 22.1% of 265,983 eligible closures |

## 1. Closing fast and staying fixed are different things

Median resolution time and 90-day recurrence, by service category (categories with ≥2,000 eligible closures):

| Category | Median resolution | 90-day recurrence |
|---|---:|---:|
| Sewer | 0.5 days | 21.3% |
| Street Cleaning | 1.4 days | 23.4% |
| Potholes & Pavement | 1.6 days | 15.7% |
| Trees | 1.7 days | 8.0% |
| Dead Animal Collection | 2.6 days | 8.6% |
| Drainage & Flooding | 3.1 days | 13.8% |
| Missed Collection | 6.4 days | 31.3% |
| Illegal Dumping & Litter | 6.8 days | 13.1% |
| Cart Repair & Replacement | 8.4 days | 15.0% |
| Traffic Signs, Signals & Markings | 13.8 days | 23.0% |
| Property Code Violations | 16.2 days | 18.6% |
| Vehicle Violations | 17.2 days | 15.2% |
| Weeds & Overgrowth | 19.4 days | 16.7% |
| Cave-ins & Street Sinking | 23.5 days | 9.4% |

Sewer backups are closed in about half a day, the fastest of any category. Yet one in five returns to the same
address within 90 days, a median of 17 days after closure. Street cleaning behaves the same way. Trees and
dead-animal pickups are about as fast, but only 8–9% of them return. Cave-ins take more than three weeks to close and
recur least of all.

Across the 18 categories with ≥500 eligible closures, the rank correlation between speed and durability is
−0.25. Faster categories recur slightly *more*, and speed alone tells very little about whether a problem
stays fixed. A dashboard that shows only resolution time would rank sewer as the best-performing service.

## 2. Missed collection is the single largest source of repeat work

*Missed Collection* (missed garbage, recycling and bulk-trash pickups) accounts for:

* **41%** of closures eligible for the 90-day rate, and **58%** of 90-day recurrences
* a **31.3%** 90-day recurrence rate, the highest of any major category
* **73%** of Chronic locations (1,449 of 1,972) and **67%** of all Persistent-or-Chronic locations
* 8 of the 10 top-ranked persistent locations. The top address had 89 requests and 74 recurrence cycles in
  three years.

Without it, the system-wide 90-day recurrence rate falls from 22.1% to 15.7%.

The category combines three collection streams, so some "recurrences" are a different stream missed at the
same household (D30). Even so, the pattern is the clearest case of a service that is closed within a week and
comes back at the same address.

## 3. Old backlog keeps accumulating whatever the total does

The total backlog has swung widely. It grew from 14,751 open requests (2024-08-01) to 35,860 (2025-09-01).
On 2025-09-22 the city closed 24,632 mostly aged requests in a single day (D28), which brought the total down
to 10,438 on 2025-10-01. It has since doubled again, to 21,181.

The oldest band moved differently:

| Date | Total open | Open > 180 days |
|---|---:|---:|
| 2024-08-01 | 14,751 | 886 |
| 2025-09-01 | 35,860 | 14,343 |
| 2025-10-01 | 10,438 | 2,704 |
| 2026-03-01 | 8,644 | 4,107 |
| 2026-09-22 | 21,181 | 4,994 |

Before the mass closure, requests older than 180 days grew sixteen-fold in 13 months, to 40% of the backlog.
After it, the > 180-day band rose in ten of the eleven months to 2026-09-01, by about 190 requests a month.
That happened while the total first fell (to 8,644 in March 2026) and then rose. The spring 2026 dip came
entirely from the younger bands. At that point 61% of what remained was more than 90 days old.

Excluding the mass closure, the city closed fewer requests than it received in both of the last two years:
123,607 closed against 141,257 opened in Sep 2024–Aug 2025, and about 138,000 against 148,420 from
September 2025 to the cut-off. The administrative closure reset the count. It did not change the rate at
which old work accumulates.

## 4. A small share of places generates a large share of repeat activity

Of 44,818 locations with three or more condition reports:

* The **1,972 Chronic locations (4.4%)** account for **29%** of all recurrence cycles.
* Chronic and Persistent locations together (**19%** of these locations) account for **64%**.
* The top **1%** of locations by recurrence cycles hold **12.7%** of cycles but only 4.6% of requests.

Repeat activity is concentrated well beyond what request volume alone would suggest. That supports treating
chronic locations as a work list of their own rather than as a stream of independent tickets.

## 5. Geography: recurrence varies more within the city than between districts

| Council district | Requests | Median resolution | 90-day recurrence | Open > 90 days |
|---|---:|---:|---:|---:|
| 1 | 40,618 | 5.3 days | 24.4% | 48.5% |
| 2 | 47,109 | 6.5 days | 23.3% | 37.5% |
| 3 | 45,863 | 6.5 days | 21.9% | 38.0% |
| 4 | 64,911 | 7.6 days | 20.1% | 40.3% |
| 5 | 55,387 | 6.8 days | 21.5% | 41.3% |
| 6 | 63,821 | 9.0 days | 19.6% | 40.2% |
| 7 | 52,950 | 4.5 days | 24.3% | 45.8% |

The district pattern repeats finding 1. Districts 7 and 1 have the two fastest median closures and the two
highest recurrence rates. District 6 is the slowest and recurs least. Council districts differ by only 5 points in
recurrence, but the 162 Census tracts with ≥500 eligible closures range from **12.8% to 35.9%**. Tract-level
maps are therefore where durability differences become visible.

Volume differences between areas are not interpreted as differences in need. 311 volume depends on who
reports (see methodology, limitations).

## What was checked and not found

* **Pothole detection.** AI-detected potholes exist but are 1.1% of pothole requests and arrive in bursts.
  There is no measurable shift to automated detection to analyse (D15).
* **Closures without work do not explain recurrence.** Originals referred elsewhere (20.4%) or closed as
  "not found" (19.6%) recur at about the same rate as completed ones (21.9%). Misrouted (45.7%) and needs-info
  (31.1%) closures recur more often, mostly because residents refile, but together they are 2% of eligible
  closures. Restricting to completed closures moves the headline from 22.1% to 21.9% (D30).
