# Operations

* [Run the pipeline](run-the-pipeline.md) - Extract from the 311 API, build and test the dbt project, and regenerate the table concepts with one command.
* [Scheduled refresh and its status file](scheduled-refresh.md) - The daily GitHub Actions refresh - schedule, secret, the status file the project tracker reads, and how to triage a failed or stale run.
* [Map a new request type](map-a-new-request-type.md) - What to do when the city adds a REQUEST_TYPE - classify it in the request_type_map seed and rebuild.

# Delivery and validation

* [Build the Power BI dashboard](build-the-power-bi-dashboard.md) - Assemble the four-page report in Power BI Desktop from the analytics marts, load the DAX measures and validate every headline card against SQL.
* [Review recurrence matches](review-recurrence-matches.md) - Draw the deterministic 80-pair sample of first recurrences and hand-review whether each pair is the same problem at the same place.
