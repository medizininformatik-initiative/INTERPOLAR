# Cohort Description

`Cohort_Description` is the manual Data Processor entry point for the
INTERPOLAR-wide cohort description (#1460). The current stage loads distinct
station, patient and Encounter assignments from `v_pids_per_ward` in the selected
database. Successful preparation is reported in the normal Data Processor log.
An empty assignment table stops preparation with an error.

## Configuration and start

Set `DB_NAME` in this directory's `database.toml` to the target database.
The shared manual-project mechanism inherits other connection settings from the
normal database configuration and validates the selected database.

Run this block from the repository root after configuring `database.toml`:

```sh
set -eu
module_name="cohort-description"
if docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R "$module_name"; then
  echo "Cohort Description preparation completed."
else
  echo "Cohort Description preparation failed; inspect the preceding log." >&2
  exit 1
fi
```

## Analysis stages

The next stages link the known assignments to Encounters using patient and
Encounter IDs, select the first known INTERPOLAR contact per hospital case by its
documented start, select the first MedA, assign study/FAS populations, and
calculate/export the cohort tables. A missing assignment does not prove that a
contact occurred outside INTERPOLAR. The current preparation returns the known
assignments for these subsequent stages.

The accepted final text of SAP v12_TB and the agreed clarifications govern the
analysis. The current working table is v11 with `Missing Information`. #1478
tracks the local specification; central aggregation is tracked separately in #1483.
