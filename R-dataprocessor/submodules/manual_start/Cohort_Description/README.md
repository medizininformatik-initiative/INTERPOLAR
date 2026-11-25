# Cohort Description

The manual submodule generates the complete expanded local cohort table for
each configured station, each FAS (1, 2.1, 2.2, 3), and each study period
(BS, CRS, CRS A, CRS B): 16 workbooks per station.

Set `DB_NAME` in `database.toml` to the database to analyse. Configure the ward
phase dates, department and ward type in `dataprocessor_config.toml`, and provide
the normal WP7 input repository. Run from the repository root:

```sh
docker compose run --build --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R cohort-description
```

The console shows each loading/calculation step and its duration. During export,
it shows file x of y, station, study period and FAS.

Results are written to `outputGlobal/dataprocessor/reports/cohort_description/`.
Each workbook contains the expanded local sheet with aggregate results.
`cohort_manifest.csv` lists all files and population sizes; `cohort_quality.csv`
contains aggregate data-quality counts. `open_questions.md` documents the agreed
calculation rules and any remaining scientific questions. `NA` denotes an unavailable statistic.

`cohort_run_metrics.csv` records run status, elapsed analysis time in seconds and
peak R-process resident memory in KiB (Linux). Divide KiB by 1048576 for GiB.
The peak covers the R process since startup; database memory is separate.
A completed export has status `completed`. `failed` indicates a handled failure;
`running` without a final update indicates that the run has not completed.
An unavailable measurement is written as `NA`.

Return the report directory, including the Excel workbooks and aggregate CSV files.

Unlinked station assignments are excluded from the analysis. Their identifiers
and available assignment details are written locally to
`outputLocal/dataprocessor/diagnostics/cohort_description/unlinked_station_contacts.csv`.
This diagnostic file is separate from the aggregate report directory and is for
local investigation. The log records only the excluded row count and file path.
