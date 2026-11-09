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
empty optional values leave them unchanged. The file is mounted into `r-env`
automatically; rebuilding the image is not needed. The shared template for new
projects is `R-dataprocessor/submodules/manual_start/database_example.toml`.

## Output Files

Each run writes three artifacts to `outputGlobal/dataprocessor/reports`:

- `Database_Quality_Analysis_Count_Summary_<analysis-start>.xlsx`: Excel workbook with
  availability counts.
- `Database_Quality_Analysis_Value_Summary_<analysis-start>.zip`: ZIP archive
  with value summary CSV files grouped in `FHIR/` and `Frontend/` folders.
- `Database_Quality_Analysis_Code_Summary_<analysis-start>.zip`: code-based CSV
  reports and a description of the configured systems and resolved source fields.

The Code Summary ZIP is also written to `outputLocal/dataprocessor/reports`,
with the same filename. The local version contains all aggregate combinations,
including `count < 5`; the global version pools these rare combinations.

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
`INCLUDE_CODE_SUMMARY = false` to disable it. It reads configured FHIR
last-version views without an additional date, status or INTERPOLAR scope filter.
The additional global quality summary from #1462 and clinical categorization
remain outside this report. The availability workbook and Value Summary ZIP
keep their previous content.

The ZIP contains exactly four default reports: `Codes/Observation.csv`,
`Codes/Condition.csv`, `Codes/Procedure.csv` and `Codes/Medication.csv`, plus
`README.txt`. Medication usage resources contribute to Medication.csv only.
Resources with an available configured source but no selected codes still get
CSV headers. Unavailable sources are documented with their resolved fields.
No resource, patient or case IDs or individual measurement values are exported.

Both output folders receive the four code CSVs. Local CSVs retain every code,
version, unit, reference range and available statistic, even for counts below
five. Such combinations have `row_type = detail` locally. Global CSVs retain
their existing rare-group suppression. Missing source fields stay empty; a
single measurement has a mean/median but no sample SD. Totals remain deduplicated
independently in both versions. Both exports share one aggregate SQL query.

### Configuration and Coding fields

The maintained configuration is `code_summary.toml` alongside the other module
TOMLs. It defines `[systems]`, `[report_types]`, `[[sources]]`, shared `[fields]`,
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
| SNOMED CT | Imported Coding fields on the four report resources, plus direct medication codes | `http://snomed.info/sct` |

WHO ATC (`http://www.whocc.no/atc`) is deliberately excluded. ASK is excluded
from Medication.code; ATC/PZN are excluded from Medication ingredients.

The default report scope is Observation, Condition, Procedure and Medication.
MedicationRequest, MedicationAdministration and MedicationStatement supply links
and direct medicationCodeableConcept codes; they have no separate CSVs. Other
resources such as Location, Patient or Encounter are not part of the code report.
Within these resources, `coding = "*"` expands using the maintained Table Description,
not raw FHIR JSON or guessed database column names. Explicit sources take
precedence for the same resource/path/system family. Consequently SNOMED may
describe a resource's primary code, category, method or other Coding role.
`coding_path` keeps those roles separate. Only fields actually imported into the
database can be analyzed. The archive documents every resolved source and field.

`[report_types]` defines `coding`, `measurement` or `medication` for each system
family. Source-level `measurement = true/false` overrides the measurement default
for that source. The default Observation `code/coding` source enables statistics
for LOINC and SNOMED; SNOMED method/category/result Coding fields remain ordinary
coding counts. Behavior follows configuration rather than family names.

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

- `detail`: a combination present in at least five distinct resources. Groups use
  resource type, system, Coding path, version and code; measurement sources add
  unit code, unit system and selected reference limits.
- `other (count < 5)`: in the global output, rare combinations pooled per resource, system
  and Coding path. IDs are deduplicated again. Code/version/measurement fields
  and statistics are empty.
- `total`: independently deduplicated per resource and system, across all Coding
  paths. `coding_path` is empty. Resources with multiple codes or Coding roles
  count once in this total; detail/rare counts must not simply be added.
- `unresolved medication reference`: one diagnostic row in Medication.csv, with empty system/path/version/code. `count` and
  `no_reference_count_to_medication` count affected resource IDs. It is excluded
  from coded system totals.

`count` counts distinct resource identities, never DB rows. In Medication.csv it
counts Medication IDs plus fallback usage IDs for direct medication codes without
a matching referenced Medication code/version. This same count determines the
rare-combination threshold. `medication_count` always counts actual Medication
IDs: five directly coded Requests without Medication yield `count = 5`,
`medication_count = 0` and `medication_request_count = 5`.

`medication_request_count`, `medication_administration_count` and
`medication_statement_count` independently count those resource types' IDs.
One Medication referenced by two Requests yields `count = 1`,
`medication_count = 1`, `medication_request_count = 2` within its code group.
Missing link-source views produce empty counts rather than a measured zero;
reference-issue counts are also empty when any link source is unavailable.

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
flattened Coding/reference rows from weighting statistics. Totals and rare
groups in the global output have no statistics because they may mix units and
analytes. Local rare combinations remain separate detail groups with statistics;
totals have no statistics in either export.

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

`no_reference_count_to_medication` counts missing or unresolvable references,
including on directly coded rows. Directly coded resources remain assigned to
their code group and are not repeated in the unresolved-code diagnostic row.
The diagnostic row contains only usage resources with neither a selected direct
medicationCodeableConcept code nor a resolvable Medication reference. It appears
once in Medication.csv, with empty system/path/code and actual Medication count 0.
If the Medication source is unavailable, reference diagnostics are unavailable
and their counts are empty rather than reported as zero.

### Query batching and tests

One aggregate query covers all configured resources, Coding fields, systems and
medication links. Each source view is projected once into a materialized CTE;
Coding fields expand together with a lateral query, rather than rescanning the
projection for each Coding path. Where reference resolution does not require
all resources, projections filter to configured systems. Only aggregates leave
the database. Integer group keys permit equality joins for counts/statistics.

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
groups in all four CSVs, measurement statistics, different Coding roles, rare
codes and directly coded medications without a Medication entry. All resources,
values and links in this fixture are synthetic; `demo-v1` is a test version label.
