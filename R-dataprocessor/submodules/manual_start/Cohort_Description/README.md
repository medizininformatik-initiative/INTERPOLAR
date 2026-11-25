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

Results are written to `outputLocal/dataprocessor/reports/cohort_description/`.
Each workbook contains the expanded local sheet with aggregate results.
`cohort_manifest.csv` lists all files and population sizes; `cohort_quality.csv`
contains aggregate data-quality counts. `open_questions.md` documents the agreed
calculation rules and any remaining scientific questions. `NA` denotes an unavailable statistic.
