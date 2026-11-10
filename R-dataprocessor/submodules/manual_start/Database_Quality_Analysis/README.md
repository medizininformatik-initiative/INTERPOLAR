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
6. Execute one shared code-aggregation query: collect Coding combinations,
   resolve medication links, deduplicate IDs and calculate counts/statistics.
   From the same events, calculate the complete database and the configured IP
   case subset, each with complete local groups and globally pooled rare groups.
   IDs are deduplicated again for pooled groups and totals in each scope.
7. Write the files listed below. Each code ZIP contains the resource CSVs for
   both scopes and a README describing its actual sources, fields and counting rules.

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
combinations, including `count < 5`; its global version pools rare combinations.
The additional IP CSVs are enabled when `FILTERED_SCOPE_SHEET_NAMES` contains `FHIR`.
Their filename suffix follows `FILTERED_SCOPE_DETAIL_SHEET_SUFFIX` (default
`INTERPOLAR`). Disabling that scope keeps only the complete-database CSVs in each ZIP.

The filename timestamp is the analysis start time, shared by the run's outputs.
The normal toolchain start archives existing `dataprocessor` output directories
with a timestamp and applies `MAX_DIR_COUNT` retention. Check the current
`dataprocessor/reports` folders for the latest run. Progress and errors are logged
under `outputLocal/dataprocessor/log`.

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
`INCLUDE_CODE_SUMMARY = false` to disable both code scopes. The complete-database
variant reads configured FHIR last-version views without an additional date or
status filter. A separate variant restricts events to the selected IP main cases.
The additional global quality summary from #1462 and clinical categorization
remain outside this report. The availability workbook and Value Summary ZIP
keep their previous content.

The ZIP contains four complete-database reports: `Codes/Observation.csv`,
`Codes/Condition.csv`, `Codes/Procedure.csv` and `Codes/Medication.csv`, plus
`README.txt`. With the default IP scope enabled, the same ZIP also contains
`Codes/Observation_INTERPOLAR.csv`, `Codes/Condition_INTERPOLAR.csv`,
`Codes/Procedure_INTERPOLAR.csv` and `Codes/Medication_INTERPOLAR.csv`.
Medication usage resources contribute to Medication.csv only.
Resources with an available configured source but no selected codes still get
CSV headers. Unavailable sources are documented with their resolved fields.
No resource, patient or case IDs or individual measurement values are exported.

Both output folders receive one code ZIP containing these CSVs. Local CSVs retain
every code, version, unit, reference range and available statistic, even for counts below
five. Such combinations have `row_type = detail` locally. Global CSVs retain
their existing rare-group suppression. Missing source fields stay empty; a
single measurement has a mean/median but no sample SD. Totals remain deduplicated
independently in both versions. Both exports share one aggregate SQL query.

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

Counts, statistics, totals and the rare-combination threshold are calculated
independently for each scope. A code can be a visible detail globally for the
complete database and a pooled rare combination globally for IP cases. The local
IP file still shows that combination in full.

All four code variants (complete/IP cases, global/local) share one aggregate SQL
query and the same projected source data. No separate query is issued per scope.
An empty IP selection produces CSV headers without fabricated zero totals.
If the required Encounter or `pids_per_ward` metadata is unavailable, the module
warns and omits the IP code CSVs; it never substitutes unfiltered results.

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

- `detail`: globally, a combination with `count >= 5`; locally, every coded
  combination, including counts from 1 to 4. Groups use resource type, system,
  Coding path, version and code; measurement sources add unit code, unit system
  and selected reference limits.
- `other (count < 5)`: in the global output, rare combinations pooled per
  resource, system and Coding path. IDs are deduplicated again.
  Code/version/measurement fields and statistics are empty. These rows do not
  occur in the local output.
- `total`: independently deduplicated per resource and system, across all Coding
  paths. `coding_path` is empty. Resources with multiple codes or Coding roles
  count once in this total; detail/rare counts must not simply be added.
- `unresolved medication reference`: one diagnostic row in Medication.csv,
  with empty system/path/version/code. `count` and
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

One aggregate query covers all configured resources, Coding fields, systems,
medication links, output targets and case scopes. Each source view is projected once into a materialized CTE;
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
Expect 9 SNOMED detail rows globally and 12 locally: the local files also show
the rare SNOMED codes with counts of two or four.
Remove the test container afterwards with `docker stop dqa-test-postgres`.
