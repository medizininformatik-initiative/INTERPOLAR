# Database Quality Analysis

`Database_Quality_Analysis` creates reports for checking data availability in
the dataprocessor output views. The module does not change source data. It reads
view and column metadata from the Data Processor output schema configured as
`DB_DATAPROCESSOR_SCHEMA_OUT` and uses database view comments as
`COLUMN_DESCRIPTION` where available.

## Start

From the repository root:

```console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R database-quality-analysis
```

The main configuration is
`R-dataprocessor/submodules/manual_start/Database_Quality_Analysis/database_quality_analysis_config.toml`.
Set `DB_NAME` in this project's `database.toml` to the pseudonymized snapshot
database. Other connection values are inherited from the normal database
configuration. Non-empty values in `database.toml` override them; missing or
empty optional values leave them unchanged. The repository Compose configuration
mounts `manual_start` into `r-env`, including this file, the DQA code and its
TOMLs. Changes to those mounted files need no image rebuild. The installed R
packages in the image must still match the checkout; rebuild the R image after
package changes. With a customized Compose file, check that the `manual_start`
mount and both output mounts are present. The shared template for new projects
is `R-dataprocessor/submodules/manual_start/database_example.toml`.

The database must be reachable and normally have
`database_content_type = pseudonymized_snapshot`. The manual-start framework
checks the configured database and its required views before running DQA.
For an intentional analysis of another database, including a compatible legacy
snapshot without that marker, the command accepts `--force`. This bypasses the
snapshot-type requirement, not missing database objects or invalid credentials.

### Processing sequence

1. Select the manual DQA project and read the base database configuration with
   overrides from its `database.toml`.
2. Validate the selected database, then load the DQA module configuration and
   `code_summary.toml`.
3. Read view/column metadata and calculate availability counts for the existing
   Excel sheets, including configured scope/detail sheets.
4. Calculate the existing Value Summary from the configured table families.
5. Resolve the code sources against the Table Description and actual view
   columns, and detect measurement statistics from mapped numeric value fields.
   This selects the four code-report resources and medication inputs;
   it does not restrict the existing availability and Value Summary reports.
6. Calculate counts, statistics and exact cross-code totals from shared prepared
   data, processing one resource type at a time.
   Resolve medication links and deduplicate IDs within each requested output group.
   From the same events, calculate the selected case and age variants, each
   with all detail groups; global CSVs mask positive counts below five as `<5`.
   Medication and all three medication usage resources remain in one batch.
   IDs are deduplicated independently for totals in each scope.
7. Write the files listed below. Each code ZIP contains the resource CSVs for
   the selected variants and a README describing its actual sources, fields and counting rules.

## Output Files

With the default configuration, each run writes three artifacts to
`outputGlobal/dataprocessor/reports`:

- `Database_Quality_Analysis_Count_Summary_<analysis-start>.xlsx`: Excel workbook with
  availability counts.
- `Database_Quality_Analysis_Value_Summary_<analysis-start>.zip`: ZIP archive
  with value summary CSV files grouped in `FHIR/` and `Frontend/` folders.
- `Database_Quality_Analysis_Code_Summary_<analysis-start>.zip`: code-based CSV
  reports for all eligible main cases and for the selected INTERPOLAR main cases,
  plus a description of the configured sources. Both selections use age at
  main-case admission (18 or older).

The Code Summary ZIP is also written to `outputLocal/dataprocessor/reports`,
with the same filename. Its local version contains all aggregate
combinations, including `count < 5`; its global version retains those combinations
and writes small positive counts as `<5`.
The filename timestamp is the analysis start time, shared by the run's outputs.
The normal toolchain start archives existing `dataprocessor` output directories
with a timestamp and applies `MAX_DIR_COUNT` retention. Check the current
`dataprocessor/reports` folders for the latest run. Progress and errors are logged
under `outputLocal/dataprocessor/log`.

## Progress logs and long-running queries

Every DQA progress line includes date, local time and timezone. Query messages
identify the table, batch and query type, and report start, elapsed duration and
aggregate row count on completion. The Code Summary also lists resolved Coding
sources and measurement handling before submitting SQL. Each query identifies its
resource report and batch number, for example `Observation (1/4)` or
`Medication (4/4)`. CSV/Excel/ZIP writing
has its own messages and elapsed times.

On Linux/Docker, a separate timer emits a status line every 60 seconds while a
query is running. Set `PROGRESS_INTERVAL_SECONDS` in
`database_quality_analysis_config.toml` to change that interval; `0` disables the
periodic timer. The timer runs no SQL and opens no database connection. It is
stopped when the query returns or fails. Other platforms still log start/end
and duration. Status lines report elapsed waiting time, not a percentage or a
claim that PostgreSQL is actively using the CPU. An executing query can also be
waiting for I/O or a lock.

For currently running queries, including older DQA versions, a database operator can inspect their state
without rerunning the expensive report (visibility depends on database privileges):

```sql
SELECT pid, application_name, clock_timestamp() - query_start AS elapsed,
       state, wait_event_type, wait_event, pg_blocking_pids(pid) AS blocking_pids
FROM pg_stat_activity
WHERE datname = current_database()
  AND pid <> pg_backend_pid()
  AND state IS DISTINCT FROM 'idle';
```

For this version, `query LIKE '/* INTERPOLAR DQA code summary */%'` can be added
to the WHERE conditions to select its Code Summary specifically.
The query tag identifies runs using this version. An already running older query
will retain its old SQL and logging until that run ends. The existing console
and `outputLocal/dataprocessor/log` outputs remain the log destinations.

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

The exceptions below apply to the existing availability reports. The code report
has its own explicit source fields and counting rules described afterwards.

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
  `field_name___2`; it can be changed with `BOOLEAN_GROUP_COLUMN_PATTERN` and
  `BOOLEAN_TRUE_VALUES`.

## Code Summary ZIP

The code report reads the configured FHIR last-version views. Set
`INCLUDE_CODE_SUMMARY = false` to disable the code reports.

When both case selections are available, the code ZIP contains eight CSVs:
Observation, Condition, Procedure and Medication for all adult main cases (suffix `_all`) and for selected adult
IP main cases (suffix `_interpolar`), plus `README.txt`. Adulthood means
an age of at least 18 years at main-case admission.

Medication usage resources contribute to Medication.csv only.
Resources with an available configured source but no selected codes still get
CSV headers. Unavailable sources are documented with their resolved fields.
No resource, patient or case IDs or individual measurement values are exported.

Both output folders receive one code ZIP containing these CSVs. Local CSVs retain
every code, version, unit, reference range and available statistic, even for counts below
five. Such combinations have `row_type = detail` in both outputs. In global CSVs,
the resource, patient, case, Medication and medication usage count columns
independently show `<5` for values from 1 to 4. `no_case_count` and
`unreferenced_medication_count` retain their exact values. Zero stays `0`, counts
of at least five remain exact, and unavailable counts remain empty. No
`other (count < 5)` rows are produced. Missing source fields stay empty; a
single measurement has a mean/median but no sample SD. Totals remain deduplicated
independently in both versions. Both exports share the passes of their resource/code batch.

### All cases and INTERPOLAR cases

The `*_interpolar.csv` files use the same case selection as the filtered Excel sheets: join
`pids_per_ward.encounter_id` to `Encounter.enc_id`, then select the distinct
`enc_main_encounter_calculated_ref` values. Relative and absolute references are
normalized before matching the code events to those main cases.

Filtering is by case, not just by patient. Another case of the same patient is
excluded if it is outside the selected set. Both reports require a usable main-case reference, so `no_case_count` is zero.

Medication has no own patient/case association. Its codes enter the IP report
through the Requests, Administrations and Statements assigned to selected cases.
Only those usage events supply patient, case and usage counts. Direct medication
codes and unresolved-reference rows use their owning usage resource's case.
A Medication without eligible usage events has no case association.

Counts, statistics and totals are calculated independently for each scope.
The same code may have an exact count of at least five across all eligible cases
and a masked `<5` count for IP cases. Both scopes retain its detail row; local
CSV counts remain exact.

Both case selections and both export targets share the aggregate SQL
query and projected source data within each resource batch. No separate detail/statistic query is
issued per scope or export target. Small counts are masked only during global
CSV export; this requires no additional database queries.
An empty IP selection produces CSV headers without fabricated zero totals.
If the required Encounter or `pids_per_ward` metadata is unavailable, the module
warns and omits the IP code CSVs; it never substitutes unfiltered results.

### Age at main-case admission

The DQA start requests both code reports, `all_cases` and `interpolar_cases`.
Both include cases from age 18 at main-case admission. The INTERPOLAR report
uses main cases selected through Encounter and `pids_per_ward`.

The age lookup matches the event's normalized main-case reference to the main
Encounter's own `enc_id`. A ward Encounter's admission age does not replace the
age at main-case admission. The configured age column takes precedence when it
exists; missing or invalid values in that column do not trigger a per-row fallback.
This column is added by snapshot enrichment and is not part of the regular
maintained Encounter schema. If it is absent and `fallback_to_birthdate = true`,
SQL derives completed calendar years from the main Encounter's `period/start`
and its Patient's `birthDate`, using the Table Description to resolve columns.
This fallback requires typed date/timestamp fields; it does not cast raw text dates.
A case beginning on the patient's 18th birthday belongs to the adult selection.

Missing, negative or invalid ages, dates before birth, unknown cases and
conflicting age groups for duplicate main Encounter IDs are excluded. Medication
codes contribute through usage events linked to eligible main cases.

If neither the age column nor the configured birthdate fallback is available,
DQA warns and writes the code ZIP with just its README.
An available age source with no matching cases produces header-only CSVs.
The ZIP README records the actual age source and each selected scope.

Encounter rows are scanned once per resource query and reduced to one compact
lookup row per case. IP membership and age are combined there; requested CSV
buckets are assigned once per case. Each code/usage event joins this lookup once
and expands only into its preselected buckets. The birthdate fallback adds one
deduplicated Patient scan per resource query, not one query per case or CSV.
No case lists or birthdates are transferred to R. Resource/code batches execute
serially, with global count masking applied independently within each variant and
full aggregate details in the local ZIP. Aggregate code catalogs and group
metadata may be transferred to R; individual IDs and measurement values are not.

### Configuration and Coding fields

The maintained configuration is `code_summary.toml` alongside the other module
TOMLs. It defines `[processing]`, `[exports]`, `[systems]`, `[report_types]`, `[[sources]]`, shared `[fields]`,
`[[medication_links]]`. The shared
`etlutils::tomlParseString()` parser retains nested source/field tables.

| System family | Resource and Coding field | Exact system URI |
| --- | --- | --- |
| LOINC | Observation: `code/coding` | `http://loinc.org` |
| ICD | Condition: `code/coding` | `http://fhir.de/CodeSystem/bfarm/icd-10-gm` |
| OPS | Procedure: `code/coding` | `http://fhir.de/CodeSystem/bfarm/ops` |
| ATC | Medication: `code/coding`; medication usage: `medicationCodeableConcept/coding` | `http://fhir.de/CodeSystem/bfarm/atc` |
| PZN | Same primary medication fields as ATC | `http://fhir.de/CodeSystem/ifa/pzn` |
| ASK | Medication: `ingredient/itemCodeableConcept/coding` | `http://fhir.de/CodeSystem/ask` |
| SNOMED CT | Primary `code/coding` on the four report resources, plus direct medication codes | `http://snomed.info/sct` |

WHO ATC (`http://www.whocc.no/atc`) is deliberately excluded. ASK is excluded
from Medication.code; ATC/PZN are excluded from Medication ingredients.

The default report scope is Observation, Condition, Procedure and Medication.
MedicationRequest, MedicationAdministration and MedicationStatement supply links
and direct medicationCodeableConcept codes; they have no separate CSVs. Other
resources such as Location, Patient or Encounter are not part of the code report.
SNOMED uses only `code/coding` on the four report resources and
`medicationCodeableConcept/coding` on the three medication input resources.
Method, category, body-site and coded-result fields are outside this default
scope. Ingredient Coding is included for ASK only. `coding_path` identifies
these configured origins; the Table Description resolves them to actual imported
DB columns. The archive documents every resolved source and field.

`[report_types]` defines `coding` or `medication` for each system family. Measurement
statistics are detected per source, independently of the resource or code-system
name: the configured `value` path must resolve to an available column with a
numeric database type. Detection reuses the already loaded view metadata and
does not issue another SQL query. An unrelated numeric column is not sufficient.
Missing or non-numeric value fields, or unknown type metadata, leave the source
as ordinary code counts. Unit and reference-range fields are optional.

The standard `value = "valueQuantity/value"` mapping therefore enables statistics
for both LOINC and SNOMED in Observation. Another resource can get the same
statistics by configuring its numeric value path in `[sources.fields]` or its
actual value column in `[sources.columns]`. No resource-name special case is
needed. The old `measurement` report-type label remains accepted for existing
configurations and uses the same automatic detection as `coding`.

Optional source-level `measurement = false` disables statistics, while
`measurement = true` forces them, for example for numeric values stored in a text
column. Forced values must be convertible to numbers. Without that override,
numeric-looking text is not treated as a numeric database type. The README in
each ZIP records the resolved fields and whether measurement handling was
automatic or explicitly configured.

For a deliberately broader custom report, `coding = "*"` can discover imported
Coding fields from the Table Description. Explicit sources take precedence for
the same resource/path/system family. The default configuration uses only
explicit paths and does not enable these wildcards. For roles that should not
describe the resource's quantitative value, such as method codes, set
`measurement = false` on the custom source.

To select another complete configuration, use `CODE_SUMMARY_CONFIG_FILE` (absolute
or repository-relative); see `code_summary_config_example.toml`.
`CODE_SUMMARY_TABLE_DESCRIPTION` optionally selects another description workbook.
`{coding}` in shared field paths expands to the source Coding path. Candidate
arrays choose the first available mapping. `[sources.fields]` overrides FHIR
paths; `[sources.columns]` overrides individual actual DB columns. Corresponding
overrides are available for medication links. Missing optional fields are empty;
sources without required ID/system/code columns are skipped with a warning.

### Counts and result rows

Each CSV includes `row_type`, `system`, `coding_path`, `version`, `code`, `count`,
`patient_count`, `case_count` and `no_case_count`. `system` is the exact Coding
system URI, not the system family label.

- `detail`: every coded combination in both outputs, including counts from 1 to 4.
  Groups use resource type, system, Coding path, version and code; measurement
  sources add unit code, unit system and reference limits, type code/system and age bounds with units. Global CSVs
  mask all positive counts below five as `<5`. Measured zeros remain `0`;
  unavailable counts remain empty. Local CSVs retain all exact counts.
- `total`: independently deduplicated per resource and system, across all Coding
  paths. `coding_path` is empty. Resources with multiple codes or Coding roles
  count once in this total; detail counts must not simply be added.
- `unresolved medication reference`: one diagnostic row in Medication.csv,
  with empty system/path/version/code. `count` and
  the usage-count columns describe affected resource IDs. It is excluded
  from coded system totals.

`count` counts distinct resource identities, never DB rows. In Medication.csv it
counts Medication IDs plus fallback usage IDs for direct medication codes without
a matching referenced Medication code/version. `medication_count` always counts actual Medication
IDs: five directly coded Requests without Medication yield `count = 5`,
`medication_count = 0` and `medication_request_count = 5`.

`medication_request_count`, `medication_administration_count` and
`medication_statement_count` independently count those resource types' IDs.
One Medication referenced by two Requests yields `count = 1`,
`medication_count = 1`, `medication_request_count = 2` within its code group.
Missing usage views leave their corresponding usage counts unavailable. The
unreferenced-Medication count is unavailable when any required source is missing.

Patient/case counts deduplicate valid references per result group. Medication
obtains patient/case associations from linked and directly coded usage resources;
other report resources use their own mapped references.
`no_case_count` counts resources without any valid case in that group; it does
not replace `case_count`. Case mapping prefers `*_main_encounter_calculated_ref`
if present, otherwise imported `encounter/calculated_ref` or
`context/calculated_ref`. Original encounter references are never substituted.
Relative and absolute unversioned references normalize to resource type/ID.

### Observation statistics

`unit` is exclusively `valueQuantity.code`; `unit_system` is
`valueQuantity.system`. Human-readable `valueQuantity.unit` is not read.
Finite numeric `valueQuantity.value` measurements supply `median`, `q1`, `q3`,
`mean`, `sd`, `minimum` and `maximum`. Quartiles use continuous interpolation;
SD is the sample standard deviation. Distinct resource/value pairs prevent
flattened Coding/reference rows from weighting statistics. Global detail rows with `count < 5` have empty measurement statistics and retain
their code, unit and reference limits. Local detail rows retain their statistics.
Totals have no statistics because they may mix units and analytes.

All supplied reference ranges contribute separate detail groups. `low`/`high`
retain the supplied limits; `range_type` and `range_type_system` identify the type.
`age_low` and `age_high` retain the applicability age bounds. Each bound has
`_unit` (display), `_code` and `_system` columns, preserving the supplied units
without conversion. Missing fields remain empty. These age bounds describe the
reference range; report scope still uses age at main-case admission.
An observation may appear in several detail groups. Total resource, patient and
case counts are independently deduplicated across those groups.

### Direct and referenced medication codes

Medication.csv contains codes on Medication itself and configured direct
`medicationCodeableConcept/coding` codes from Request, Administration and Statement.
Medication codes retain their own Coding path. Linked usage counts join that
same path. Direct usage codes have a resource-type prefix such as
`MedicationRequest/medicationCodeableConcept/coding` to preserve their origin.

A direct code whose reference resolves to the same primary Medication code and
version shares that Medication's counting identity. Otherwise its own usage ID
is the fallback. System totals deduplicate these identities across Coding paths;
matching direct and referenced codes therefore do not increase the total twice.
Reference resolution includes all Medication IDs, including medications without
selected codes. Ingredient references are not traversed recursively; contained
medications are not resolved.

`unreferenced_medication_count` counts actual Medication IDs without a recognized
incoming reference from Request, Administration or Statement in the configured
data. The reference lookup uses the same normalization as the existing report.
A reference counts even if its usage row has no case, no direct code or no usable
own ID.

An inline Request contributes its own usage ID and request count. Equal codes
alone do not connect resource IDs or make the Medication referenced.
The unreferenced count deduplicates Medication IDs independently in detail
and total rows. A Medication with multiple codes/ingredients can occur in several detail
rows but contributes once to each corresponding system total. Inline-only and
unresolved-reference rows contribute zero to the unreferenced-Medication count.

With the default mapping, an unreferenced Medication has no case association,
so this count is zero in both case reports. Missing
Medication or required usage sources produce empty/unavailable unreferenced
counts, rather than asserting that partially observed Medications are unused.
The lookup reuses the projected medication-link data and adds no SQL requests.

Directly coded rows with missing or unresolvable references remain assigned to
their code group. They are not repeated in the unresolved-code diagnostic row.
The diagnostic row contains only usage resources with neither a selected direct
medicationCodeableConcept code nor a resolvable Medication reference. It appears
once in Medication.csv, with empty system/path/code and actual Medication count 0.
If the Medication source is unavailable, no unresolved-reference diagnostic row
is calculated.

### Execution

Code reports are calculated one resource type at a time. Medication and its
Request, Administration and Statement resources are processed together.
Within each resource query, detail counts, measurement statistics and independently
deduplicated totals share the prepared data. The requested case scopes and both
export destinations use these same aggregates.

The Value Summary processes columns in batches and reuses the source data for
text value counts. A field counts as empty only when that resource has no filled
value for the field.
Progress logs show the active query and its elapsed time.
