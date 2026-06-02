# "MRP_Recalculation" - additive recalculation of retrospective MRPs

## Function

Recalculates retrospective MRPs for a configurable encounter period and writes
only those MRP evaluations to the database that are not already present on the
domain-specific MRP key.

Existing data is not deleted from the database or from REDCap. Already existing
retrospective MRP evaluations are identified using patient/record, medication
analysis, reference timestamp, short description, ATC values, and MRP class.

## Flow

The process is split across the existing modules:

1. `R-cdstoolchain/StartMRPRecalculation.R` parses the optional CLI parameters
   and starts the recalculation run.
2. `dataprocessor::recalculateMRPs()` recalculates retrospective MRPs for the
   selected encounters and writes only newly identified rows to the database.
3. `db2frontend::startDB2Frontend()` is started afterwards so that the new
   retrospective MRP evaluations are exported to REDCap.

This mirrors the existing `StartDataImport.R` pattern: the orchestration lives
in `R-cdstoolchain`, while the actual dataprocessor logic stays inside the
`dataprocessor` package.

## Steps inside the recalculation

1. Read `start-date` and optional `end-date`.
   Without explicit values, both default to the current date.

2. Select all Einrichtungskontakte whose start and end lie in this range.
   Existing retrospective MRP evaluations do not exclude the encounter at this
   stage.

3. Re-run the normal retrospective MRP calculation for these encounters.

4. Compare the resulting MRP candidates with already existing rows in
   `v_retrolektive_mrpbewertung_fe`.

5. Keep only clinically new retrospective MRP evaluations and reduce the
   matching `dp_mrp_calculations` rows to the same `ret_id` set.

6. Reassign `redcap_repeat_instance` per `record_id` so that new rows continue
   the current REDCap repeat sequence without collisions.

7. Write the remaining rows additively to the database.

8. Export the updated frontend tables to REDCap.

## Execution

Run the dedicated start script:

``` console
docker compose run --rm --no-deps r-env Rscript R-cdstoolchain/StartMRPRecalculation.R
```

Optionally specify a time range. The range refers to the start of the
Einrichtungskontakt:

``` console
docker compose run --rm --no-deps r-env Rscript R-cdstoolchain/StartMRPRecalculation.R start-date=2025-09-01 end-date=2025-09-08
```
