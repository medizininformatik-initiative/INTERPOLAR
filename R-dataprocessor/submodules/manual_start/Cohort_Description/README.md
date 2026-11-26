# Cohort Description

The module generates all seven FAS (1, 2.1, 2.2, 3, 4, 4.1, 4.2) for every
configured station and study, including empty combinations: 35 workbooks per station.
BS, CRS A and CRS B use the regular snapshot; TRS and RES use the Broad Consent snapshot.
The TRS time window uses a provisional definition documented in `open_questions.md`.

## Prepare the databases

Start PostgreSQL and list the available snapshots:

```sh
docker compose up -d cds_hub
./ip-snapshot.sh list
```

Activate each snapshot if its database is not already listed as activated:

```sh
./ip-snapshot.sh activate snap01_20261125_pseud
./ip-snapshot.sh activate snap01_20261125_pseud_broad_consent
```

Replace these example snapshot names with the names shown by `list`.
If the Broad Consent snapshot still needs to be created from the activated
pseudonymized snapshot, use:

```sh
./ip-snapshot.sh create-broad-consent snap01_20261125_pseud
```

This leaves the BC database activated. Both databases use the same PostgreSQL service.
See [snapshot operation](../../../../Database_Snapshot.md) for the complete workflow.

## Configure and run

Set the actual database names in this module's `database.toml`:

```toml
[sources.regular]
DB_NAME = "ip_snap01_20261125_pseud"

[sources.broad_consent]
DB_NAME = "ip_snap01_20261125_pseud_broad_consent"
```

Select the database produced by the Broad Consent workflow as `broad_consent`.
Connection settings inherit from the normal database configuration. Configure
ward phase dates, department and ward type in `dataprocessor_config.toml`, and
provide the normal WP7 input repository. Run from the repository root:

```sh
docker compose run --build --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R cohort-description
```

The full run requires both databases and checks their connections before analysis.
For an explicit partial run, append `database-source=regular` or
`database-source=broad_consent`. Only the selected database is required.

The console shows loading/calculation steps and their durations. During export,
it shows file x of y for the current source, station, study and FAS.

## Results

Results are written below `outputGlobal/dataprocessor/reports/cohort_description/`,
separately in `regular/` and `broad_consent/`. A partial run updates its selected source.
Each source directory contains the expanded Excel workbooks, `cohort_manifest.csv`,
`cohort_quality.csv`, `cohort_run_metrics.csv` and `open_questions.md`.
The manifest records the source, population sizes and whether definitions are provisional.
`NA` denotes an unavailable statistic.

The metrics record source, status, elapsed seconds and peak R-process memory in KiB.
A successfully finished source has status `completed`; `failed` indicates a handled
failure and `running` means completion has not been recorded. For a full run, check
both sources from that invocation. Return the completed source directories.

Local ID diagnostics are written to
`outputLocal/dataprocessor/diagnostics/cohort_description/<source>/unlinked_station_contacts.csv`.
The log records only the excluded row count and file path.

`mrp_nach_meda_lage.csv` counts FAS 1 cases and stored algorithmic MRPs by
station, study and timing of the first completed MedA of the hospital case.
It includes MRPs without a completed review.
