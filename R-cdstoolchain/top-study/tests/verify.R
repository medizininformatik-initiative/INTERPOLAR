source("/runner/adapter.R")
expected <- sort(c("at_start", "early_hospital", "ended", "multiple", "ward_b_inside"))
files <- list.files("/run/results", pattern = "[.]csv$", full.names = TRUE)
stopifnot(length(files) == 2L)
for (file in files) {
  result <- utils::read.csv(file, sep = ";", check.names = FALSE)
  stopifnot(identical(sort(result$Id), expected))
}
status <- utils::read.delim("/run/run-summary.tsv")
algorithms <- utils::read.delim("/run/algorithms.tsv")
stopifnot(
  status$status == "completed", status$exit_code == 0,
  nrow(algorithms) == 2L, all(algorithms$status == "completed"),
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
