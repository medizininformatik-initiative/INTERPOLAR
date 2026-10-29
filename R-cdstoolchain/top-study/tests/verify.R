source("/runner/adapter.R")
expected <- sort(c("at_start", "early_hospital", "ended", "multiple", "ward_b_inside"))
files <- list.files("/run/results", pattern = "^(hypokalemia|icd_probe).*[.]zip$", full.names = TRUE)
stopifnot(length(files) == 2L)
for (file in files) {
  stopifnot(setequal(
    utils::unzip(file, list = TRUE)$Name,
    c("data_subjects.csv", "data_phenotypes.csv", "metadata.csv")
  ))
  result <- utils::read.csv(unz(file, "data_subjects.csv"), sep = ";", check.names = FALSE)
  phenotypes <- utils::read.csv(unz(file, "data_phenotypes.csv"), sep = ";", check.names = FALSE)
  metadata <- utils::read.csv(unz(file, "metadata.csv"), sep = ";", check.names = FALSE)
  stopifnot(
    setequal(phenotypes$subject, expected), nrow(metadata) > 0,
    # TOP names projected values <parent>_values_<restriction>.
    all(unlist(strsplit(phenotypes$phenotype, "_values_", fixed = TRUE)) %in% metadata$phenotype)
  )
  stopifnot(identical(sort(result$Id), expected))
}
status <- utils::read.delim("/run/run-summary.tsv")
algorithms <- utils::read.delim("/run/algorithms.tsv")
stopifnot(
  status$status == "completed", status$exit_code == 0,
  nrow(algorithms) == 8L, all(algorithms$status == "completed"),
  all(nzchar(algorithms$phenotype_name)), all(algorithms$entry_type == "Algorithmus"),
  all(algorithms$matched_cases[algorithms$model != "anaemia"] == 5), all(algorithms$duration_seconds >= 0),
  !file.exists("/run/private/adapter.yml")
)
versions <- jsonlite::read_json("/run/versions.json", simplifyVector = TRUE)
stopifnot(
  versions$top_image == readLines("/runner/image.txt"),
  versions$original_adapter_sha256 == digest::digest(file = "/run/original.yml", algo = "sha256")
)
health <- jsonlite::read_json("/run/preparation.json", simplifyVector = TRUE)
stopifnot(
  health$study_cases == 5, health$invalid_contacts == 7,
  health$ignored_missing_encounter_contacts == 7
)
log <- readLines("/run/preparation.log")
stopifnot(any(grepl("Ignorierte Stationszuordnungszeilen ohne Encounter: 7", log, fixed = TRUE)))
original <- yaml::read_yaml("/run/original.yml", eval.expr = FALSE)
actual <- yaml::read_yaml("/run/adapter.yml", eval.expr = FALSE)
condition <- yaml::read_yaml("/runner/icd-prefix.yml", eval.expr = FALSE)$condition
for (name in names(original$phenotypeQueries)) {
  expected_query <- if (name == "condition") condition else original$phenotypeQueries[[name]]
  actual_query <- actual$phenotypeQueries[[name]]
  expected_query$baseQuery <- NULL
  actual_query$baseQuery <- NULL
  stopifnot(identical(expected_query, actual_query))
}
# Missing study ends are configuration errors, never open-ended eligibility.
path <- tempfile(fileext = ".toml")
writeLines('[analyse]\nPHASES_WARD_1 = ["ward_name = \'A\'", "phase_a_start = \'2026-01-10\'"]', path)
stopifnot(inherits(try(readPeriods(path), silent = TRUE), "try-error"))
cat("PASS: exact laboratory and ICD case sets, completed logs, preserved restrictions and secret cleanup.\n")

# Only the aggregate report is public; all ZIP members including metadata stay local.
report <- readLines("/global/report.txt")
stopifnot(
  identical(list.files("/global", all.files = FALSE), "report.txt"),
  length(list.files("/run/results", pattern = "[.]zip$")) == 8L,
  any(grepl("Zwischenkriterium", report, fixed = TRUE)),
  all(vapply(algorithms$phenotype_name, function(name) any(grepl(name, report, fixed = TRUE)), logical(1))),
  any(grepl('"ignored_missing_encounter_contacts": 7', report, fixed = TRUE)),
  any(grepl('"total_hospital_cases": 9', report, fixed = TRUE)),
  any(grepl("hypokalemia", report, fixed = TRUE)),
  any(grepl("icd_probe", report, fixed = TRUE)),
  !any(grepl("early_hospital|Patient/P|password|jdbc:", report))
)
stopifnot(
  health$ignored_distinct_encounter_ids == 5, health$missing_encounter_id_contacts == 1,
  health$missing_start_contacts == 0, health$missing_main_reference_contacts == 0,
  health$missing_hospital_case_contacts == 0, health$unknown_ward_contacts == 0
)
cat("PASS: outputGlobal contains only the aggregate report; ZIPs, metadata, credentials and raw logs are not exported.\n")

source("/runner/tests/read-audit.R")
audit <- "/run/plausibility.txt"
cohort <- auditTable(audit, "ABGLEICH DER FALLAUSWAHL")
stopifnot(
  cohort$independent_cases == 5, cohort$adapter_cases == 5,
  cohort$independent_only == 0, cohort$adapter_only == 0
)
selection <- auditTable(audit, "FALLAUSWAHL NACH ERSTER IP-STATION (Studienende exklusiv)")
stopifnot(
  sum(selection$cases) == 9,
  sum(selection$cases[selection$selection == "selected"]) == 5,
  sum(selection$cases[selection$selection == "before_study"]) == 2,
  sum(selection$cases[selection$selection == "after_study"]) == 1,
  sum(selection$cases[selection$selection == "no_resolvable_ip_contact"]) == 1
)
comparison <- auditTable(audit, "ANÄMIE-KONTROLLVERGLEICH: Algorithmus 1")
stopifnot(
  comparison$comparison_status == "match", comparison$both_positive == 3,
  comparison$both_negative == 2, comparison$top_only == 0, comparison$control_only == 0,
  comparison$control_positive_without_confirmed_unit == 1
)
coverage <- auditTable(audit, "ANÄMIE: DATENABDECKUNG UND ZEITLICHE LAGE POSITIVER BEFUNDE (Fallzahlen, Zeitgruppen überlappen)")
female <- coverage[coverage$sex == "female", ]
stopifnot(
  female$positive_before_first_ip == 1, female$positive_after_study == 1,
  female$positive_with_confirmed_units == 2,
  coverage$cases[coverage$sex == "unknown_or_conflicting"] == 1
)
duplicates <- auditTable(audit, "MÖGLICHE MESSWERTDUBLETTEN (gleicher Fall, Code, Zeitpunkt, Wert und Einheit; kein Beweis einer Dublette)")
stopifnot(
  duplicates$analysis_loinc_code == "59260-0", duplicates$extra_rows == 1,
  duplicates$affected_cases == 1
)
exclusions <- auditTable(audit, "ANÄMIE: AUSSCHLUSSDIAGNOSEN UND FEHLENDE LABORNACHWEISE (Diagnosen werden hier nur gezählt, nicht ausgeschlossen)")
stopifnot(
  exclusions$with_exclusion_diagnosis[exclusions$algorithm == "Algorithmus 2 A"] == 1,
  exclusions$unknown_or_conflicting_sex[exclusions$algorithm == "Algorithmus 1 - CTCAE Grad 3"] == 1,
  file.exists("/run/model-limits.tsv"), !file.exists("/global/model-limits.tsv"),
  !any(grepl("hb1|source_conversion_failed.*Encounter/|P_unknown|hb_outside|< 7.76", report))
)
cat("PASS: independent cohort, anaemia counts, unit risk, duplicate measurements, exclusion diagnoses and event timing.\n")
