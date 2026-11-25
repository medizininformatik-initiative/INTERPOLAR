test_that("normal cohort start writes metrics on success and on an analysis error", {
  directory <- tempfile("cohort-metrics-")
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  global_dir <- file.path(directory, "outputGlobal", "dataprocessor")
  local_dir <- file.path(directory, "outputLocal", "dataprocessor")
  report_dir <- file.path(global_dir, "reports", "cohort_description", "regular")
  output <- file.path(report_dir, "cohort_run_metrics.csv")
  values <- list(
    ward_name = "A", phase_a_start = "2025-01-01", phase_b_start = "2025-03-01",
    phase_b_end = "2025-06-01", ward_type = "internistic", department = "0100"
  )
  testthat::local_mocked_bindings(
    getModuleDirNames = function(...) list(local_dir = local_dir, global_dir = global_dir),
    getProcessPeakMemoryKiB = function() 2048,
    extractVariablesListValues = function(group, column) values[[column]],
    getVarByNameOrDefaultIfMissing = function(...) "site",
    .package = "etlutils"
  )
  fail <- FALSE
  testthat::local_mocked_bindings(
    prepareCohortDescription = function() {
      initial <- data.table::fread(output, na.strings = "NA")
      expect_identical(initial$status, "running")
      expect_true(is.na(initial$elapsed_seconds))
      if (fail) stop("simulated analysis failure")
      list(known_ip_contacts = data.table::data.table(
        encounter_id = c("missing", "present"), encounter_found = c(FALSE, TRUE)
      ))
    },
    loadCohortAnalysisData = function(prepared, timezone) {
      expect_identical(prepared$known_ip_contacts$encounter_id, "present")
      list(
        cases = data.table::data.table(),
        quality = data.table::data.table(check = "example", count = 0L)
      )
    },
    exportCohortDescription = function(cases, wards, timezone, site, directory, source) {
      expect_identical(directory, report_dir)
      data.table::data.table(file = "example.xlsx")
    },
    .package = "CohortDescription"
  )
  expect_message(result <- createCohortDescription(), "completed")
  metrics <- data.table::fread(output)
  expect_identical(metrics$status, "completed")
  expect_gte(metrics$elapsed_seconds, 0)
  expect_equal(metrics$max_rss_kib, 2048)
  expect_equal(result$file, "example.xlsx")
  expect_true(file.exists(file.path(report_dir, "cohort_quality.csv")))
  diagnostic <- file.path(local_dir, "diagnostics", "cohort_description", "regular", "unlinked_station_contacts.csv")
  expect_identical(data.table::fread(diagnostic)$encounter_id, "missing")
  expect_false(dir.exists(file.path(local_dir, "reports")))
  expect_false(any(grepl("unlinked_station_contacts", list.files(global_dir, recursive = TRUE))))
  fail <- TRUE
  expect_error(createCohortDescription(), "simulated analysis failure")
  expect_identical(data.table::fread(output)$status, "failed")
})
