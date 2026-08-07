# Database Quality Analysis

`Database_Quality_Analysis` creates reports for checking data availability in
the dataprocessor output views. The module does not change source data. It reads
view and column metadata from the configured database schema and uses database
view comments as `COLUMN_DESCRIPTION` where available.

## Start

From the repository root:

```console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R database-quality-analysis
```

The main configuration is
`R-dataprocessor/submodules/manual_start/Database_Quality_Analysis/database_quality_analysis_config.toml`.
For the pseudonymized snapshot database, point `PATH_TO_DB_CONFIG_TOML` to the
matching database credential TOML file. If the analysis database uses a different
database name, host or port, set `DB_ANALYSIS_NAME`, `DB_ANALYSIS_HOST` and
`DB_ANALYSIS_PORT` in that DB config file. If the admin password differs,
set `DB_ANALYSIS_ADMIN_PASSWORD`. Leave these values empty to use `DB_NAME`,
`DB_HOST`, `DB_PORT` and `DB_ADMIN_PASSWORD`.

## Output Files

Each run writes two artifacts to `outputGlobal/dataprocessor/reports`:

- `Database_Quality_Analysis_Count_Summary_<analysis-start>.xlsx`: Excel workbook with
  availability counts.
- `Database_Quality_Analysis_Value_Summary_<analysis-start>.zip`: ZIP archive
  with value summary CSV files grouped in `FHIR/` and `Frontend/` folders.

## Excel Sheets

The workbook can contain these sheets:

- `Sheet Description`: describes the generated sheets in the workbook.
- `FHIR`: availability counts for FHIR last-version views.
- `FHIR <suffix>`: optional filtered FHIR variant, for example
  `FHIR INTERPOLAR`. Patient-dependent resources are filtered to patients in
  the filtered scope. Case-dependent resources are filtered to cases in the
  filtered scope. Resources without patient or case reference are skipped.
- `Frontend`: availability counts for frontend last-version views.
- `Other`: configured additional views that are neither FHIR nor frontend.
- `FHIR Encounter`: optional detail sheet for the `encounter` resource. It
  creates one block per configured contact level and additional count columns
  per configured encounter class.
- `FHIR Encounter <suffix>`: optional filtered variant of the encounter detail
  sheet, for example `FHIR Encounter INTERPOLAR`.
- `Metadata`: technical run metadata such as analysis start/end, duration and
  row counts. Connection details such as host, port, database name and user are
  intentionally not written.

Filtered-scope sheets are enabled by `FILTERED_SCOPE_SHEET_NAMES`. The default
INTERPOLAR scope is derived from `pids_per_ward` and `encounter`: scoped ward
encounters are mapped to main encounter IDs and patient references.

## Availability Columns

The main availability sheets use these columns:

- `TABLE_NAME`: logical table/resource name derived from the view name.
- `COLUMN_NAME`: database column being checked.
- `COLUMN_DESCRIPTION`: database comment for the column, if available.
- `USED_AS_GROUPING_FOR`: marks columns used as `resource_id`, `pid` or
  `case_id` grouping columns.
- `count per resource_id`: number of distinct resources where this column has
  an available value.
- `count per PID`: number of distinct patients where this column has an
  available value.
- `count per Fall-Id`: number of distinct cases where this column has an
  available value.
- `first value import datetime` / `last value import datetime`: earliest and
  latest import timestamps among rows where this column has an available value.
- `first value meta last updated` / `last value meta last updated`: earliest
  and latest FHIR meta-last-updated timestamps among rows where this column has
  an available value.

The timestamp columns require historical views without the `_last_version`
suffix. They can be disabled with `--skip-value-datetime-columns` or
`INCLUDE_VALUE_DATETIME_COLUMNS = false`.

## Count Basis

Availability counts are distinct counts, not row counts. For each checked
column, the module counts distinct IDs only when both conditions are true:

- the checked column has an available value, and
- the grouping column used for the count is also available.

Grouping columns are resolved from `GROUPING_OVERRIDES` first and otherwise by
naming convention. If a grouping column cannot be resolved, the corresponding
count stays empty.

FHIR rows are sorted by reference scope: patient-dependent resources first,
case-dependent resources next, and resources without patient/case reference at
the end. Filtered FHIR sheets keep the same order as the unfiltered `FHIR`
sheet.

## Encounter Detail Sheet

The default `FHIR Encounter` sheet uses the configured resource detail settings:

- row groups: `Einrichtungskontakt`, `Abteilungskontakt`,
  `Versorgungsstellenkontakt`, based on `enc_type_system` and `enc_type_code`.
- count groups: `count class IMP`, `count class SS`, `count class AMB`,
  `count class Andere`, based on `enc_class_system` and `enc_class_code`.

`count class Andere` uses the special configured value `OTHER`. It counts
non-empty class values outside the explicitly configured class values. Empty or
missing class values are not counted as `Andere`. The configured system columns
must match as well.

## Value Summary ZIP

The value summary is calculated for the table families configured in
`VALUE_SUMMARY_TABLE_FAMILIES`, by default `FHIR` and `Frontend`. The ZIP
archive stores CSV files below one folder per table family, for example
`FHIR/observation.csv` and `Frontend/patient_fe.csv`. It is not
calculated for other, detail or filtered-scope sheets.

The value summary is resource-ID based. Values are counted per distinct resource
ID. If one resource ID contains the same value multiple times in the same
column, it contributes `1` to that value. If two different resource IDs contain
the same value, it contributes `2`.

CSV columns:

- `COLUMN_NAME`: checked database column.
- `VALUE_TYPE`: summary type derived from the database column type: `text`,
  `numeric` or `datetime`.
- `DISTINCT_VALUES`: number of distinct non-empty values in the column.
- `VALUE_COUNTS`: compact value distribution for text columns.
- `MIN`, `MAX`, `AVG`, `MEDIAN`, `Q1`, `Q3`: statistics for numeric and
  datetime columns.
- `SE`: standard error for numeric and datetime columns.
- `EMPTY`: number of distinct resource IDs where the column has no available
  value.

For text columns, frequent values are shown as `value: count`. Values whose
resource-ID based count is below the suppression threshold are grouped into
`Other (count < 5): n`. Here `n` is the summed count of resource IDs with rare
values, not the number of different rare values.

Text columns matched by the family-specific suppression patterns still receive
`DISTINCT_VALUES` and `EMPTY`, but concrete values are omitted. FHIR rules are
configured with `VALUE_SUMMARY_FHIR_SUPPRESSED_COLUMN_PATTERNS`; frontend rules
are configured separately with `VALUE_SUMMARY_FRONTEND_SUPPRESSED_COLUMN_PATTERNS`.
Numeric and datetime columns are summarized with statistics instead of concrete
values. To include concrete text values from columns ending in `_values`, set
`INCLUDE_VALUE_SUMMARY_VALUES_COLUMNS = true` or pass
`--include-value-summary-values-columns`.

If no resource ID column can be resolved for a configured value-summary table,
the module logs a warning and leaves its value summaries empty instead of using
a fallback ID.

## Availability Exceptions

The following columns or values are handled specially:

- technical columns listed in `TECHNICAL_COLUMNS` are excluded from the Excel
  availability sheets.
- raw views matching `EXCLUDED_VIEW_PATTERNS`, for example `_raw_`, are skipped.
- physical table primary keys named `<table_name>_id` and last-version helper
  columns are excluded.
- calculated reference columns such as `*_calculated_ref` are counted only when
  they are filled and not equal to `invalid`.
- pattern-based boolean option groups are counted as available only when at
  least one option in the group contains a configured true value. The default
  pattern applies to frontend columns such as `field_name___1` and
  `field_name___2`; it can be changed with `BOOLEAN_GROUP_COLUMN_PATTERN`,
  `BOOLEAN_TRUE_VALUES` and `BOOLEAN_FALSE_VALUES`.
