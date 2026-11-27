# Cohort description results

`regular/` contains BS, CRS A and CRS B results. `broad_consent/` contains TRS
and RES results. Each source directory contains the CSV files below, the Excel
workbooks listed in its manifest, and `open_questions.md` with calculation notes.
The CSV headers are on the first line. Counts from 1 to 4 appear as `<5` in
the workbooks and aggregate CSV files. Zero counts appear as `0`.

## cohort_manifest.csv

One row per Excel workbook.

- `file`: Workbook name relative to the source directory.
- `source`, `ward`, `phase`, `fas`: Database source, station, study and full analysis set.
- `definition_status`: Status of the study and FAS definition. `agreed` means the definition has been agreed.
- `cases`, `patients`: Number of hospital cases and distinct patients in the workbook's cohort. A patient can contribute more than one case.

## cohort_quality.csv

One row per data quality check for the source. `check` names the check and
`count` gives the number found. The unit depends on the check: known IP contacts,
hospital cases, procedure or diagnosis records, or laboratory observations.
Catalogue approximations use the closest available year. Unresolved catalogue
checks count records whose code status could not be determined.

## cohort_run_metrics.csv

One row per source. `status` is `running`, `completed` or `failed`.
`elapsed_seconds` measures elapsed time for that source. `max_rss_kib` is the
peak resident memory of the R process in KiB. `memory_scope` indicates that
the peak covers the R process since it started, including preceding sources
in the same run. `NA` means a metric is unavailable.

## algorithmic_mrps_by_first_meda_timing.csv

One row per station (`ward_name`), study (`phase`) and time group
(`first_meda_location`) in FAS 1. The time group refers to the first completed
medication analysis (MedA) of the hospital case:

- `before_first_ip`: Before the first known INTERPOLAR ward stay.
- `first_ip`: During that stay.
- `after_subsequent_ip`: After that stay, during a later known INTERPOLAR ward stay.
- `after_non_ip`: After that stay, outside known INTERPOLAR ward stays.

`cases_with_first_completed_meda` counts cases in the time group.
`cases_with_algorithmic_mrp` counts those cases with at least one stored
algorithmic MRP linked to that MedA. `algorithmic_mrps` counts the stored MRPs
linked to those MedAs, including those without a completed review. Zero means
no cases or MRPs met the corresponding condition.
