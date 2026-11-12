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
6. Plan serial code-group batches per resource from a narrow catalog, then execute
   separate count/statistic passes and exact cross-code totals.
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
  reports for the complete database, additional CSVs restricted to the selected
  IP main cases, and a description of the configured sources.

The Code Summary ZIP is also written to `outputLocal/dataprocessor/reports`,
with the same filename. Its local version contains all aggregate
combinations, including `count < 5`; its global version retains those combinations
and writes small positive counts as `<5`.
Selected IP variants require `FHIR` in `FILTERED_SCOPE_SHEET_NAMES`.
Their IP filename suffix follows `FILTERED_SCOPE_DETAIL_SHEET_SUFFIX` (default
`INTERPOLAR`). If that scope is disabled, selected IP variants are omitted.
Only variants selected in `[exports].variants` are calculated and written.

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

The code report implements #1495 and is enabled by default. Set
`INCLUDE_CODE_SUMMARY = false` to disable all code scopes. The complete-database
variant reads configured FHIR last-version views without an additional date or
status filter. A separate variant restricts events to the selected IP main cases.
The additional global quality summary from #1462 and clinical categorization
remain outside this report. The availability workbook and Value Summary ZIP
keep their previous content.

The current `[exports].variants = ["filtered_age_ge18"]` selection produces
`Codes/Observation_INTERPOLAR_AGE_GE18.csv`, `Codes/Condition_INTERPOLAR_AGE_GE18.csv`,
`Codes/Procedure_INTERPOLAR_AGE_GE18.csv` and `Codes/Medication_INTERPOLAR_AGE_GE18.csv`,
plus `README.txt`. These files contain only events assigned to selected IP main
cases with an admission age of at least 18 years.

Selecting all six supported variants produces six CSVs per resource (24 total)
in that same ZIP. `[exports].variants` in `code_summary.toml` selects which
variants are calculated and written; see the selection table below.
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

### Complete database and IP cases

The additional `*_INTERPOLAR.csv` files reuse the existing filtered Excel scope: join
`pids_per_ward.encounter_id` to `Encounter.enc_id`, then select the distinct
`enc_main_encounter_calculated_ref` values. Relative and absolute references are
normalized before matching the code events to those main cases.

Filtering is by case, not just by patient. Another case of the same patient is
excluded if it is outside the selected set. Events without a usable main-case
reference contribute only to the complete-database report. Consequently
`no_case_count` is zero for the selected IP events.

Medication has no own patient/case association. Its codes enter the IP report
through the Requests, Administrations and Statements assigned to selected cases.
Only those usage events supply patient, case and usage counts. Direct medication
codes and unresolved-reference rows use their owning usage resource's case.
An unlinked Medication therefore contributes only to the complete-database report.

Counts, statistics and totals are calculated independently for each scope.
The same code may have an exact count of at least five for the complete database
and a masked `<5` count for IP cases. Both scopes retain its detail row; local
CSV counts remain exact.

All configured case/age variants and both export targets share the aggregate SQL
query and projected source data within each resource batch. No separate detail/statistic query is
issued per scope or export target. Small counts are masked only during global
CSV export; this requires no additional database queries.
An empty IP selection produces CSV headers without fabricated zero totals.
If the required Encounter or `pids_per_ward` metadata is unavailable, the module
warns and omits the IP code CSVs; it never substitutes unfiltered results.

### Age at main-case admission and CSV selection

The current selection in `code_summary.toml` is `variants = ["filtered_age_ge18"]`.
To request all six code ZIP variants, configure:

```toml
[exports]
variants = ["all", "all_age_ge18", "all_age_lt18", "filtered", "filtered_age_ge18", "filtered_age_lt18"]
age_column = "enc_age_at_admission"
fallback_to_birthdate = true
```

| Variant | CSV example | Included events |
| --- | --- | --- |
| `all` | `Observation.csv` | Complete database, including events without case/age |
| `all_age_ge18` | `Observation_AGE_GE18.csv` | Main-case admission age >=18 |
| `all_age_lt18` | `Observation_AGE_LT18.csv` | Main-case admission age <18 |
| `filtered` | `Observation_INTERPOLAR.csv` | Selected IP main cases, regardless of known age |
| `filtered_age_ge18` | `Observation_INTERPOLAR_AGE_GE18.csv` | Selected IP main cases with admission age >=18 |
| `filtered_age_lt18` | `Observation_INTERPOLAR_AGE_LT18.csv` | Selected IP main cases with admission age <18 |

Any non-empty subset is supported; omitted variants are neither aggregated nor
written. For example, `variants = ["all_age_ge18", "filtered_age_ge18"]` writes
only the adult reports. The IP suffix follows `FILTERED_SCOPE_DETAIL_SHEET_SUFFIX`;
filtered variants still require `FHIR` in `FILTERED_SCOPE_SHEET_NAMES`.
Older custom TOMLs without `[exports]` retain the original `all`/`filtered` layout.

The age lookup matches the event's normalized main-case reference to the main
Encounter's own `enc_id`. A ward Encounter's admission age does not replace the
age at main-case admission. The configured age column takes precedence when it
exists; missing or invalid values in that column do not trigger a per-row fallback.
This column is added by snapshot enrichment and is not part of the regular
maintained Encounter schema. If it is absent and `fallback_to_birthdate = true`,
SQL derives completed calendar years from the main Encounter's `period/start`
and its Patient's `birthDate`, using the Table Description to resolve columns.
This fallback requires typed date/timestamp fields; it does not cast raw text dates.
A case beginning on the patient's 18th birthday belongs to `AGE_GE18`.

Missing, negative or invalid ages, dates before birth, unknown cases and
conflicting age groups for duplicate main Encounter IDs do not enter either age
group. They remain in the corresponding report without an age filter. Newborns
(age zero) belong to `AGE_LT18`. A patient with cases in both age groups can be
counted once in each group. Medication codes enter age groups through their
case-linked usage events, so the same Medication ID can occur in both age groups.
These are event selections, not additive partitions of all distinct resource IDs.

An unavailable age column and unavailable/disabled birthdate fallback produce a
warning and omit only age-specific CSVs. No unfiltered data is substituted.
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
`[[medication_links]]` and `[normal_range]`. The shared
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
  sources add unit code, unit system and selected reference limits. Global CSVs
  mask small positive counts as `<5`, except `no_case_count` and
  `unreferenced_medication_count`; local CSVs retain all exact counts.
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
flattened Coding/reference rows from weighting statistics. All detail groups
retain their statistics in both outputs, including those with masked counts.
Totals have no statistics because they may mix units and analytes.

`low`/`high` retain the MRP reference-range priority per resource/Coding/measurement:
prefer type code `normal`, regardless of its system, otherwise missing type when
`[normal_range].fallback_to_missing_type = true`. Blank types count as missing.
Other range types do not supply limits. Observations without eligible limits
still contribute to counts and statistics. DQA retains all ranges at the
preferred priority and does not convert units; totals remain deduplicated.

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

For example, a Medication with code `A02AH01` and no recognized usage contributes
`unreferenced_medication_count = 1`. An inline Request with the same code and no
Medication reference contributes its own usage ID and request count; equal codes
alone do not connect resource IDs or make the Medication referenced.
The unreferenced count deduplicates Medication IDs independently in detail
and total rows. A Medication with multiple codes/ingredients can occur in several detail
rows but contributes once to each corresponding system total. Inline-only and
unresolved-reference rows contribute zero to the unreferenced-Medication count.

With the default mapping, Medication has no own patient/case reference. An
unreferenced Medication cannot enter the IP subset through a usage event, so its
count occurs only in the complete-database CSV; IP rows have zero. Missing
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

### Query batching and tests

The default `CODE_SUMMARY_QUERY_BATCHING = "resource"` separates Observation,
Condition, Procedure and Medication. Medication and its usage resources stay
together. This selects resource batches, not the number of SQL queries.

#### Spaltenbatches der Value Summary

The production default `VALUE_SUMMARY_COLUMN_BATCH_SIZE = 1` processes one column
at a time. Configure it independently of `COUNT_BATCH_SIZE` (availability counts)
in `database_quality_analysis_config.toml`; the documented example is
`code_summary_config_example.toml`. For example, `5` allows five columns per
batch. Smaller batches repeat table reads but reduce simultaneous distinct/sort
state. This prevents a 100-text-column lateral expansion of 30 million rows into
up to three billion intermediate rows in a single query. Resource/value counting,
statistics and suppression rules remain unchanged. Programmatic configurations
without the new field retain their existing `count_batch_size` fallback.

#### Complete code groups and narrow summary passes

`code_summary.toml` enables code-group processing by default:

```toml
[processing]
enabled = true
target_rows_per_chunk = 500000
max_codes_per_chunk = 500
```

A narrow catalog estimates projected Coding rows per exact system/code pair,
including linked Medication usages without a direct code. Groups are processed
serially, with each complete system/code pair assigned to exactly one chunk.
Version, Coding path, units and reference ranges remain separate detail groups
inside that chunk. The code predicate is applied before source materialization,
numeric conversion and reference-range ranking. Only aggregate metadata leaves
SQL for planning; IDs and individual values stay in PostgreSQL.

Each resource batch performs:

1. The code/volume catalog and an independent, narrow total/diagnostic pass.
   Ordinary totals omit measurement values, units, limits and actual code/version
   dimensions. Distinct resource, patient and case totals are computed globally
   in SQL and never added from partial counts.
2. A count pass for each code chunk and, only for chunks with measurements, a
   separate exact statistic pass. Counts are aggregated once per complete detail
   group; small counts are masked only during global CSV export. No event/frequency/label
   caches are retained in these detail passes. The statistic pass also avoids
   those caches. A single percentile-array
   aggregate computes Q1/median/Q3 from the full deduplicated resource/value
   stream. R joins these aggregate results by nullable detail-group metadata;
   it does not average medians, quartiles, means or standard deviations.

Both exports retain all detail groups. The shared archive writer masks each
eligible small positive count in global CSVs after all SQL aggregation and statistics.
No rare-code catalog or rare-pool query is needed.

Medication chunks retain all reference identities needed for their selected
usage IDs and incoming-reference markers for their Medication IDs. Out-of-chunk
clinical code rows are excluded; unrelated incoming usage IDs collapse to NULL
markers before DISTINCT. Global Medication existence and diagnostic rules remain
available in the independent summary pass, including references to Medications
without selected codes.

**A row target is not a disk-space cap.** A code larger than the target runs alone
and is logged explicitly. Its exact quantiles require all of that code's values;
we do not split resource-ID ranges and combine partial medians. The independent
totals pass also needs the selected ID population. Flattened multiplicity,
reference fan-out, case selection and row widths still affect peak disk use.
Changing data between catalog and execution passes can invalidate a plan; run
against the intended unchanged snapshot.

More small queries are intentional. Case lookups and source reads may repeat;
log labels identify catalogs, totals and each chunk's counts/statistics, with the existing timestamps, duration and periodic status messages.
All requested variants and both export targets share each chunk's computation.
The CSV layout/counting rules are unchanged. Chunked rows use deterministic
client sorting; their order can differ from a database's locale-based ordering.

`[processing].enabled = false` retains the former combined query for comparisons.
`CODE_SUMMARY_QUERY_BATCHING = "all"` remains supported but combines resources;
`"resource"` is preferable for large data. The descriptions below also document
the shared mechanics and the combined reference mode.

When `all` is not requested, the union of selected case buckets filters source
rows **before** materialization, Coding expansion/deduplication, numeric casts and
reference-range ranking. The filter uses normalized main-case references and
never substitutes a patient cohort. Different case-field mappings on the same
view are retained separately. Source/normalized-stage row counts and an excluded
non-numeric measurement are checked in integration tests.

Restricted Medication reports also need global identity information: an incoming
reference or direct Coding on another row/case of the same usage ID can affect
reference matching and unresolved-reference diagnostics. One extra narrow scan
of each usage view retains only resource type, IDs/references and a Coding-presence
flag, without patient, case, unit, version or measurement columns. Global Medication
ID existence is read separately, including Medications without selected codes.
Only codes for relevant referenced Medication IDs or Medications with their own
selected case enter Coding preparation. Wide usage rows are filtered first.
All of this stays in the corresponding resource/chunk passes; identity projections
may require additional narrow scans. There is no longer a fixed four-query target.
If `all` is selected, full-database processing remains necessary and these extra
restricted-report identity projections are not used.

Restricted case/event joins use the same FULL-equality-join pattern as the
count/statistics merge below. Cases without events emit no output buckets. This
preserves the selected events while avoiding quadratic nested loops when
PostgreSQL underestimates the number of selected cases after the early filter.

Measurement statistics are a subset of the count groups, using identical keys.
Their final merge uses a FULL join after expanding the count output targets. This
preserves the same rows while requiring a hash/merge join even if PostgreSQL
underestimates the number of statistic groups; a nested-loop final join produced
millions of pair comparisons in the large-volume test. No statistic merge runs
for batches without measurement sources.

Medication links are deduplicated before joining. Direct-code resolution joins
only the medication usage codings against distinct primary Medication code keys;
unrelated resources do not enter that join. Normalized empty versions use a
non-null equality key, preserving the existing NULL-version matching rule.
The main-case and no-case counts use distinct keys; no-case counts are obtained
by subtracting keys with a case from all keys instead of joining a second large
per-resource aggregation. Common detail groups, unresolved rows and totals are
computed once for global/local output; only CSV count formatting differs.
The final small result is expanded to both targets. Resource batching releases
large intermediate results between queries instead of retaining all resources
until one combined query finishes. The Encounter/pids_per_ward scope lookup is
repeated per batch; Coding source views are not rescanned for each scope.
`CODE_SUMMARY_QUERY_BATCHING = "all"` retains the shared-query mode for controlled
comparisons. Resource batching remains the default for large databases.
CSV columns, thresholds,
reference-range priority and counting semantics are unchanged.

For performance investigation, use PostgreSQL
[`EXPLAIN (ANALYZE, BUFFERS)`](https://www.postgresql.org/docs/17/using-explain.html) in
an isolated development database with representative synthetic cardinalities.
It executes the query and should not be started alongside an expensive site
report just to obtain its plan. The operator status query above is suitable for
observing an ongoing run. A synthetic speedup is not a site runtime guarantee.

A local large-volume check on 2026-11-11, before adding the unreferenced-Medication
counter, used PostgreSQL 17.11 with
`work_mem = 4MB`: 2,000,000 additional Observation rows and 1,000,000 rows each
for Medication, MedicationRequest, MedicationAdministration and MedicationStatement.
The workload used 100,000 main-case IDs, 50,000 patient references and 2,000 codes
per system, with half the main cases selected for the IP scope. Both global/local
and complete/IP variants were calculated. Condition and Procedure were empty in
this particular load test; their semantics are covered by the integration tests.

| Resource batch | Additional source rows | SQL execution time |
| --- | ---: | ---: |
| Observation | 2,000,000 | 296.7 s |
| Medication and all three usage types | 4,000,000 | 622.1 s |

These times exclude synthetic-data loading and report-file writing. Analytical
checks verified exact totals, IP selection, case/no-case and reference diagnostics,
direct/reference identity deduplication, and measurement mean/SD/median/min/max.
The full Docker report also retained byte-identical Code and Value Summary CSVs
on the existing snapshot. These are local synthetic results, not site runtime
guarantees: code/reference fan-out, flattened duplicates, view definitions,
aggregate-group cardinality, storage and server resources affect the workload.

A separate check of all six age/case variants used 250,000 additional Observations,
100,000 main cases and `work_mem = 4MB`. The Observation query, including all
statistics and both export targets, completed in 75.3 seconds; the shared case
bucket lookup took about 2.3 seconds. EXPLAIN confirmed one scan each of the
Observation, Encounter and ward tables and a hash join for event/case matching.
Independent analytical checks matched all six distinct-resource totals. A run
with 1,000,000 additional Observations reached the deliberately configured
five-minute statement timeout and did not provide a completed timing/plan.
These checks exercise the existing age-column path; the typed birthdate fallback,
18th-birthday boundary, unavailable ages, Medication usage selection, empty scopes
and configurable ZIP contents are covered by PostgreSQL integration tests.

The early source filter was compared directly with the preceding query builder
(`0a1b97d3`), requesting only `filtered_age_ge18` in both runs. These synthetic
checks used 100,000 cases, approximately 20% selected events, both export targets
and `work_mem = 4MB`. All aggregate columns matched exactly (`EXCEPT ALL` in both
directions), including reference diagnostics and measurement statistics.

| Workload | Late filter SQL time | Early filter SQL time | Late filter sampled temp peak | Early filter sampled temp peak |
| --- | ---: | ---: | ---: | ---: |
| 250,000 additional Observations | 10.3 s | 6.8 s | 309 MiB | 139 MiB |
| 100,000 each Medication/Request/Administration/Statement | 19.7 s | 17.4 s | 310 MiB | 196 MiB |

For Observations, the first source materialization decreased from 250,036 to
50,000 rows, and normalized Codings from 250,022 to 49,997 rows. In the Medication
batch, prepared Codings decreased from 200,011 to 40,002, and full clinical usage
links from 300,018 to 60,002; global narrow identities remain available.

The optimized single-variant query also completed with 1,000,000 additional
Observations in 25.6 seconds, with a sampled temp-file peak of 555 MiB. Its total
of 199,983 selected distinct observations across 19,999 cases matched analytical
expected values. This uses one requested variant, unlike the earlier six-variant
million-row timeout test above.

Temp peaks were sampled approximately every 0.2 seconds from allocated files in
PostgreSQL's isolated `base/pgsql_tmp` directory. They describe the sampled
concurrent SQL temporary-file footprint, not output ZIP sizes or a guaranteed
upper bound. EXPLAIN's `Temp Written Blocks` measures cumulative writes instead;
for the paired Observation runs these were 309 versus 143 MiB, and for Medication
400 versus 229 MiB. Real site workloads may differ in selected-case fraction,
flattened row multiplicity, reference fan-out and row width. That early-filter
correction did not impose a fixed disk-space cap or change the Value Summary queries.

The subsequent serial-batching implementation was compared with that early-filter
version on isolated PostgreSQL 17 with `work_mem = 4MB`. Both implementations
returned the same aggregate values (floating-point statistics compared with a
relative tolerance of `1e-12`). These benchmarks requested `filtered_age_ge18`;
all added clinical resources belonged to selected adult IP cases, so the
improvement does not depend on discarding most resources through the case filter.
The code benchmarks explicitly used a 250,000-row target and 50 codes per chunk;
the production defaults are 500,000 and 500 respectively.

| Workload | Previous SQL time | Batched SQL time | Previous sampled temp peak | Batched sampled temp peak |
| --- | ---: | ---: | ---: | ---: |
| 2 million additional Observations and 500,000 Conditions | 294 s | 391 s | 5,499 MiB | 621 MiB |
| 100,000 each Medication/Request/Administration/Statement | 45.6 s | 104.9 s | 693 MiB | 386 MiB |
| Value Summary: 100,000 rows, 23 columns; column batch 100 versus 1 | 13.7 s | 10.2 s | 184 MiB | 7.8 MiB |

One million Observations shared a single code, exercising the oversized-code
path. The code comparisons needed 19 instead of two queries for
Observation/Condition and six instead of one for Medication. Repeated scans can
increase runtime; this change prioritizes lower concurrent temporary disk usage.
The peaks use the same sampling method described above and are not disk-space
limits. Exact statistics for a frequent code and exact cross-code distinct
counts still need their complete populations. A 30-million-Observation site
workload has not been reproduced locally.

Before the subsequent CSV count-masking change, all 111 package tests passed.
A complete Docker report using the production
settings and a read-only historical local snapshot also completed successfully:
all four selected resource CSVs retained their aggregate values, all 20 Value
Summary CSVs were byte-identical, and the seven non-runtime availability sheets
were unchanged. The existing query builder, source/reference resolution,
`runLoggedQuery()` and archive writers are reused by the new serial passes.

Run package tests with the project R environment:

```r
testthat::test_local(
  "R-dataprocessor/submodules/manual_start/Database_Quality_Analysis/R-Database_Quality_Analysis",
  filter = "code-summary"
)
```

SQL integration tests accept `DQA_TEST_POSTGRES_CONTAINER`, naming an isolated
PostgreSQL container reachable via `docker exec`. They use temporary tables and
need a `postgres` database/user. Without it, SQL tests are skipped.
Coverage includes wildcard/override mappings, resource/system/Coding-role
separation, direct/reference deduplication, all three medication usage types,
leading-zero codes, rare groups, main cases and MRP reference-range priority.
The shared `codeSummarySnomedFixture()` test fixture adds visible SNOMED detail
groups in all four CSVs, measurement statistics, direct medication origins, rare
codes and directly coded medications without a Medication entry. All resources,
values and links in this fixture are synthetic; `demo-v1` is a test version label.

### Inspecting a synthetic SNOMED example

A normal DQA run reads the selected database only; it never inserts example
codes. If that database contains no selected SNOMED codes, its CSVs contain no
SNOMED detail rows. The tests use a separate PostgreSQL container and temporary
tables. Their fixture covers visible detail groups as well as counts below five.

In a development environment with the local `interpolar-cds_hub:latest` image,
start an isolated test database:

```sh
docker run -d --rm --network none --name dqa-test-postgres \
  --user postgres --entrypoint sh interpolar-cds_hub:latest \
  -c 'initdb -D /tmp/dqa-pg -A trust >/tmp/dqa-init.log && exec postgres -D /tmp/dqa-pg -c listen_addresses='
docker exec dqa-test-postgres pg_isready -U postgres
```

Wait until `pg_isready` reports that the server accepts connections. Then run
the following from the repository root in the development R environment, with
`pkgload`, the package dependencies, the Docker CLI and write access to the two
output directories available. It reuses the test fixture and production exporter:

```r
Sys.setenv(DQA_TEST_POSTGRES_CONTAINER = "dqa-test-postgres")
dqa_package <- paste0(
  "R-dataprocessor/submodules/manual_start/Database_Quality_Analysis/",
  "R-Database_Quality_Analysis"
)
pkgload::load_all(dqa_package, quiet = TRUE)
source(file.path(dqa_package, "tests/testthat/helper-code-summary.R"))
fixture <- codeSummarySnomedFixture()
reports <- createCodeSummaryReports(
  fixture$metadata, fixture$config, table_description = fixture$description,
  query_fun = function(query, lock_id) runCodeSummaryFixtureQuery(fixture, query)
)
attr(reports, "description") <- c("SYNTHETIC TEST DATA", attr(reports, "description"))
local_reports <- attr(reports, "local_reports", exact = TRUE)
attr(local_reports, "description") <- c("SYNTHETIC TEST DATA", attr(local_reports, "description"))
attr(reports, "local_reports") <- local_reports
MODULE_DIRS <- etlutils::getModuleDirNames("dataprocessor")
timestamp <- Sys.time()
for (target in c("global", "local")) {
  writeCodeSummaryArchive(
    reports, "Database_Quality_Analysis_SYNTHETIC_SNOMED",
    timestamp = timestamp, target = target
  )
}
```

The two example ZIPs appear in the normal global/local report directories, with
`SYNTHETIC_SNOMED` in their names. No existing snapshot is read or changed.
Expect 12 SNOMED detail rows in both outputs. Counts of two or four are shown
as `<5` globally and as exact numbers locally.
Remove the test container afterwards with `docker stop dqa-test-postgres`.
