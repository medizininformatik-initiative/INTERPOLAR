source("/runner/adapter.R")
expected <- sort(c("at_start", "early_hospital", "ended", "multiple", "ward_b_inside"))
files <- list.files("/global/results", pattern = "[.]zip$", full.names = TRUE)
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
  nrow(algorithms) == 2L, all(algorithms$status == "completed"),
  all(nzchar(algorithms$phenotype_name)), all(algorithms$entry_type == "Algorithmus"),
  all(algorithms$matched_cases == 5), all(algorithms$duration_seconds >= 0),
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

# The report contains aggregates; detailed result rows are confined to the TOP ZIPs.
report <- readLines("/global/report.txt")
stopifnot(
  setequal(list.files("/global", all.files = FALSE), c("report.txt", "results")),
  length(list.files("/global/results")) == 2L,
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
cat("PASS: outputGlobal contains complete TOP ZIPs and a named aggregate report, without credentials or raw logs.\n")
