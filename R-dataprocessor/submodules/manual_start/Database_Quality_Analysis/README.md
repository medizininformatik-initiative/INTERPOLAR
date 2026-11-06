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
`INCLUDE_CODE_SUMMARY = false` to disable it. It reads the configured FHIR
last-version views without an additional date, status or INTERPOLAR scope filter.
The additional global quality summary from #1462 is not part of this report.

The archive contains six CSVs: `Codes/LOINC.csv`, `ICD.csv`, `OPS.csv`,
`ATC.csv`, `PZN.csv` and `ASK.csv`, all below `Codes/`, plus `README.txt` with
system URIs, source views, resolved columns, skipped sources and counting rules.
Empty reports still contain CSV headers. These are additional outputs; the
availability workbook and existing Value Summary ZIP keep their previous content.

Default sources are explicit, not all Coding fields found in a resource:

| Report | Resource and Coding field | System URI |
| --- | --- | --- |
| LOINC | Observation: `code/coding` | `http://loinc.org` |
| ICD | Condition: `code/coding` | `http://fhir.de/CodeSystem/bfarm/icd-10-gm` |
| OPS | Procedure: `code/coding` | `http://fhir.de/CodeSystem/bfarm/ops` |
| ATC | Medication: `code/coding` | `http://fhir.de/CodeSystem/bfarm/atc` |
| PZN | Medication: `code/coding` | `http://fhir.de/CodeSystem/ifa/pzn` |
| ASK | Medication: `ingredient/itemCodeableConcept/coding` | `http://fhir.de/CodeSystem/ask` |

SNOMED CT is deferred until the relevant resource types and Coding fields have
been explicitly scoped; it is not included in the default code report.

The maintained configuration is `code_summary.toml` in this module directory,
alongside `database_quality_analysis_config.toml` and `database.toml`.
It defines `[systems]`, `[report_types]`, `[[sources]]`, shared `[fields]`,
`[[medication_links]]` and the `[normal_range]` rule. R code reads these settings
with `etlutils::tomlParseString()` without flattening the nested tables.
ATC selects only the BfArM system; `http://www.whocc.no/atc` is not included.

Every system/report name must have exactly one entry in `[report_types]`:

- `coding`: distinct resource, patient and case counts.
- `measurement`: those counts plus quantity/unit/reference-range groups and statistics.
- `medication`: Medication counts plus directly linked Requests, Administrations,
  Statements and unresolved Medication-reference counts. Sources for this type
  must be Medication resources.

The standard reports use `measurement` for LOINC, `coding` for ICD/OPS and
`medication` for ATC/PZN/ASK. Behavior follows this type, not the report name.
To add another medication code system, add its URI in `[systems]`, its type in
`[report_types]`, and its name to the appropriate source's `reports` array. No R
change is needed to obtain the medication-specific columns. Measurement fields
are likewise selected by report type and their configured paths, rather than by
the report or source resource name.

To customize the report, edit `code_summary.toml`. Optionally select another file
with `CODE_SUMMARY_CONFIG_FILE` in the module configuration (absolute path or
relative to the repository root). See `code_summary_config_example.toml` for the
module settings. The selected file replaces the complete report configuration;
there are no fallback systems or source fields hardcoded in R.
For a LOINC-only report, retain only LOINC in `[systems]` and `[report_types]` and one Observation source
with `reports = ["LOINC"]`; the other sections can remain present.
The existing Table Description maps resource/FHIR paths to actual DB columns.
`CODE_SUMMARY_TABLE_DESCRIPTION` optionally selects another description file.
`{coding}` in shared field paths is replaced by the source Coding path. Arrays of
candidate paths use the first available mapping. A `[sources.fields]` table can
override shared paths for one source. `[sources.columns]` overrides individual DB
columns directly; corresponding tables are also supported for medication links.
Required columns are checked against the actual view metadata. Missing optional
fields become empty values. Sources without required ID/system/code columns are
skipped with a warning and recorded in the archive description.
Unavailable medication link sources are also documented. Their dedicated counts
are empty rather than zero; the combined reference-issue count is left empty if
any of the three link sources is unavailable.

Medication system URIs and ingredient Coding fields follow the
[MII Medication profile](https://www.medizininformatik-initiative.de/Kerndatensatz/KDS_Medikation_V2025/MIIIGModulMedikation-TechnischeImplementierung-FHIR-Profile-Medication.html).

### Resolved source fields

The mapping below was checked against the repository Table Description. Actual
view availability is checked at report runtime; this mapping check does not imply
that a particular snapshot database contains every field.

| Reports | Resource | Code column | Version column |
| --- | --- | --- | --- |
| LOINC | Observation | `obs_code_code` | `obs_code_version` |
| ICD | Condition | `con_code_code` | `con_code_version` |
| OPS | Procedure | `proc_code_code` | `proc_code_version` |
| ATC, PZN | Medication | `med_code_code` | `med_code_version` |
| ASK | Medication ingredient | `med_ingredient_itemcodeableconcept_code` | `med_ingredient_itemcodeableconcept_version` |

System columns have the corresponding `_system` suffix. Observations, Conditions
and Procedures use their own `*_patient_ref` and `*_encounter_calculated_ref`
columns. The import reference calculation populates the latter from the
Encounter main-case reference; the original encounter reference is not used.

Medication itself has no patient or case reference in the Table Description.
These counts come from directly linked resources:

| Linked resource | Medication reference | Patient reference | Main-case reference |
| --- | --- | --- | --- |
| MedicationRequest | `medreq_medicationreference_ref` | `medreq_patient_ref` | `medreq_encounter_calculated_ref` |
| MedicationAdministration | `medadm_medicationreference_ref` | `medadm_patient_ref` | `medadm_encounter_calculated_ref` |
| MedicationStatement | `medstat_medicationreference_ref` | `medstat_patient_ref` | `medstat_encounter_calculated_ref` |

For LOINC, measurement values use `obs_valuequantity_value`, unit codes use
`obs_valuequantity_code`, and unit systems use `obs_valuequantity_system`.
Reference limits use `obs_referencerange_low_value` and
`obs_referencerange_high_value`; their type is read from
`obs_referencerange_type_code`, matching the MRP type-selection rule.

### Counts and result rows

Each CSV includes `row_type`, `version`, `code`, `count`, `patient_count`,
`case_count` and `no_case_count`. System URIs are documented centrally rather than
repeated in the code rows.

- `detail`: a combination present in at least five distinct resources.
- `other (count < 5)`: all rare combinations pooled, with identifying combination
  fields and statistics left empty. Distinct IDs are deduplicated again when
  pooling; counts are not added from already aggregated rows.
- `total`: independently deduplicated totals over resources with a selected code,
  including rare combinations. A resource with multiple codes counts once in this
  total, so summing detail rows does not necessarily reproduce it.
- `unresolved medication reference`: a separate unassigned-code row in the three
  medication-code reports. It has an empty `count` and counts reference problems
  in `no_reference_count_to_medication`. These same problem totals repeat in the
  three reports and must not be added together. Missing or unresolvable references
  cannot be attributed to a particular code. No individual code is exposed here.
  In this row `no_case_count` counts the unlinked Request/Administration/Statement
  IDs without a valid main-case reference.

`count` uses resource type plus FHIR ID and never DB-row counts. For ATC, PZN and
ASK it counts distinct Medication IDs. Repeated rows with the same resource and
combination count once. Patient/case counts deduplicate valid references across
all associated events. `no_case_count` counts resources without any valid case
reference in that group; it is not a fallback within `case_count`. Only calculated
main-encounter references are used (`*_main_encounter_calculated_ref` if present,
otherwise the imported `encounter/calculated_ref` or `context/calculated_ref`).
The original encounter reference is never substituted. Relative and absolute
unversioned Patient/Encounter/Medication references are normalized to type/ID.

### LOINC statistics

LOINC rows group by version, code, `unit` (only `valueQuantity.code`), unit system
and normal reference limits. `unit_system` is the measurement unit system, not the
LOINC coding system; it prevents distinct groups with the same unit code from
becoming indistinguishable. The human-readable `valueQuantity.unit` is not read.

`low` and `high` use the MRP selection priority per observation/coding/measurement:
prefer reference ranges with type code `normal`, regardless of the type system.
Only when none is explicitly normal, use ranges without a type code. This fallback
is controlled by `[normal_range].fallback_to_missing_type = true` in the TOML;
`code` defines the preferred type code. Blank type codes count as missing.
Other types, such as therapeutic ranges, do not supply reference limits. A coded
observation without eligible ranges still contributes to counts and measurement
statistics with empty limits.

Unlike the MRP calculation, DQA retains all ranges at the preferred priority and
does not convert their units or choose a single candidate. Multiple selected
ranges may place an observation in several groups; totals remain deduplicated.
Missing measurement values do not exclude the coded resource from counts.

`median`, `q1`, `q3`, `mean`, `sd`, `minimum` and `maximum` summarize finite numeric
`valueQuantity.value` measurements per detail group. Quartiles use continuous
interpolation and SD is the sample standard deviation. Distinct observation/value
pairs prevent repeated flattened coding/reference rows from weighting statistics.
Totals and rare groups have no statistics because they may mix units and analytes.

### Medication links

The report counts distinct directly linked MedicationRequest,
MedicationAdministration and MedicationStatement IDs in dedicated columns,
alongside `medication_count`. One Medication linked by two Requests and three
Administrations yields `count = 1`, `medication_count = 1`, request count 2 and
administration count 3. It therefore belongs to the rare-combination group.

Links resolve against all Medication IDs, including medications without a selected
code. Missing and unresolvable references are counted together in the separate
unassigned row. Ingredient CodeableConcepts are supported by the explicit source
configuration; ingredient Medication references are not traversed recursively.
Embedded or contained medications are not resolved by this initial report.

### Query batching and tests

One additional aggregate query covers all code reports and medication links.
Each source view is projected once into a materialized CTE; non-medication views
are filtered to the configured systems. Only aggregate results leave the DB.
Integer group keys permit equality joins for counts and statistics. This avoids
an individual query per code, field or result row.
Unresolved Medication references are identified once against all Medication IDs,
including medications without a report code. A shared materialized result is
reused across all medication-type reports, instead of repeating the reference
lookup for each report. With coding/measurement reports only, medication-link
sources are not read.

Run focused tests with the project R environment:

```r
testthat::test_local(
  "R-dataprocessor/submodules/manual_start/Database_Quality_Analysis/R-Database_Quality_Analysis",
  filter = "code-summary"
)
```

SQL integration tests additionally accept `DQA_TEST_POSTGRES_CONTAINER`, naming an
isolated PostgreSQL container reachable via `docker exec`. They use temporary
tables only and need a local `postgres` database/user. Without this variable the
SQL integration tests are skipped; configuration and archive tests still run.
Medication test data include multiple ingredients per product, repeated flattened
rows, versioned product codes with leading zeroes, all three linked resource types
and codes intentionally placed in the wrong Coding field. Product/ingredient
counts and patient/case totals are deduplicated independently.
