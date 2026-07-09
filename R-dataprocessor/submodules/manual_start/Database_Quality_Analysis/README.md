# Database_Quality_Analysis

`Database_Quality_Analysis` is a manual dataprocessor submodule for creating an Excel
report that counts how often database columns are populated per grouping level.

The submodule reads metadata from the `db2dataprocessor_out` views and treats
view column comments as `COLUMN_DESCRIPTION`. Until the database generator adds
comments to the output views, `COLUMN_DESCRIPTION` can be empty.

## Execution

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R database-quality-analysis
```

To skip the optional datetime columns for a faster count-only report, pass:

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R database-quality-analysis --skip-value-datetime-columns
```

## Output

The report is written to
`outputGlobal/dataprocessor/reports/Database_Quality_Analysis_<analysis-start>.xlsx`
with separate sheets for FHIR, Frontend, optional other tables, and run
metadata. The timestamp uses the analysis start time and contains no spaces,
for example `Database_Quality_Analysis_2026-06-19_08-00-02.xlsx`.

Progress is written to the console. When the submodule is started through
`StartDataProcessor.R`, the existing dataprocessor logging captures these
messages in `outputLocal/dataprocessor/log/dataprocessor-log.txt`.

The normalized output columns are:

- `TABLE_NAME`
- `COLUMN_NAME`
- `COLUMN_DESCRIPTION`
- `USED_AS_GROUPING_FOR`
- `count per resource_id`
- `count per PID`
- `count per Fall-Id`
- `first value import datetime`
- `last value import datetime`
- `first value meta last updated`
- `last value meta last updated`
- `count per Einrichtungskontakt`
- `count per Einrichtungskontakt class IMP`
- `count per Einrichtungskontakt class SS`
- `count per Einrichtungskontakt class AMB`
- `count per Einrichtungskontakt class Andere`
- `count per Abteilungskontakt`
- `count per Abteilungskontakt class IMP`
- `count per Abteilungskontakt class SS`
- `count per Abteilungskontakt class AMB`
- `count per Abteilungskontakt class Andere`
- `count per Versorgungsstellenkontakt`
- `count per Versorgungsstellenkontakt class IMP`
- `count per Versorgungsstellenkontakt class SS`
- `count per Versorgungsstellenkontakt class AMB`
- `count per Versorgungsstellenkontakt class Andere`

The datetime columns are optional because they require additional reads from the
historical views without the `_last_version` suffix. Use
`--skip-value-datetime-columns` for a faster report that only counts current
last-version availability.

The `Metadata` sheet contains neutral run metadata such as analysis start/end,
duration, report row counts, source view/column counts, and non-site-specific
database details. It deliberately does not include database host, port, name, or
user values.

## Configuration

Configuration is read from `database_quality_analysis_config.toml`.

`INCLUDE_VALUE_DATETIME_COLUMNS` controls whether the report calculates the
optional first/last value datetime columns. The default is `true` for the full
report.

Grouping columns are resolved from table-specific overrides first. Missing
grouping columns are then inferred by convention from the available columns. If
no grouping column can be resolved for a count, that count remains `NA`.

Database-internal columns such as processing metadata, `*_raw_id`,
last-version helper columns, and the physical table primary key
`<table_name>_id` are excluded from the report. Raw last-version views are
excluded by default.

For the `encounter` table in the FHIR sheet, additional count columns at the end
distinguish the CDS encounter hierarchy levels by `enc_type_system` and
`enc_type_code`. They also split each hierarchy level by `enc_class_system`
and `enc_class_code` into `AMB`, `IMP`, `SS`, and `Andere`.

Configured REDCap checkbox groups are counted as available only when at least
one checkbox option in the group is `Checked`. `Unchecked` values alone are not
counted as available data for these groups.

## Development

The implementation lives in the `R-Database_Quality_Analysis` R subproject. Tests for
this submodule belong to that subproject so the main `dataprocessor` package does
not depend on this concrete submodule.
