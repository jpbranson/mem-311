---
type: Playbook
title: Review recurrence matches
description: Draw the deterministic 80-pair sample of first recurrences and hand-review whether each pair is the same problem at the same place.
tags: [recurrence, validation]
status: stable
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-05T01:45:00Z }
sources:
  - id: sample
    resource: ../../dbt/analyses/recurrence_validation_sample.sql
    title: Stratified validation sample (dbt analysis)
---

Repeat after any change to address normalization, location matching or the primary definition, and record the
outcome as a decision, as [D30](../decisions/D30-recurrence-match-validation.md) did.

# Steps

1. Compile the sample:[^sample]

   ```bash
   cd dbt && uv run dbt compile -s recurrence_validation_sample --profiles-dir .
   ```

   Run the compiled SQL from `dbt/target/compiled/.../recurrence_validation_sample.sql` in BigQuery. The sample
   is deterministic (lowest `farm_fingerprint` per category, 4 per category), so a re-run shows the same pairs
   unless the data changed.
2. For each pair, judge three things:
   * **Location**: same place? Watch for placeholder house numbers ("0 …"), large sites sharing one address,
     and opposite sides of a street.
   * **Problem**: same problem? Watch for categories that merge services (garbage, recycling and bulk in
     *Missed Collection*).
   * **Closure**: was the original closed with work, or referred, "not found", private property?
3. Count same-place, same-problem pairs; the 2026-09-23 review found 71 of 80
   ([Recurrence validation](../methodology/recurrence-validation.md)).
4. If a systematic false match appears (as street-level geocodes did, [D29](../decisions/D29-street-level-geocodes.md)), fix the model, rebuild and review
   again. Log the result as a new decision in [decisions](../decisions/index.md).

[^sample]: Stratified validation sample (dbt analysis)
