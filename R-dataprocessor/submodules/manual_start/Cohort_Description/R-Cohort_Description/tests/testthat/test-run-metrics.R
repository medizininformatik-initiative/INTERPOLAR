test_that("normal cohort start writes metrics on success and on an analysis error", {
  directory <- tempfile("cohort-metrics-")
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  output <- file.path(directory, "reports", "cohort_description", "cohort_run_metrics.csv")
  values <- list(
    ward_name = "A", phase_a_start = "2025-01-01", phase_b_start = "2025-03-01",
    phase_b_end = "2025-06-01", ward_type = "internistic", department = "0100"
  )
  testthat::local_mocked_bindings(
    getModuleDirNames = function(...) list(local_dir = directory),
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
      list()
    },
    loadCohortAnalysisData = function(...) list(
      cases = data.table::data.table(),
      quality = data.table::data.table(check = "example", count = 0L)
    ),
    exportCohortDescription = function(...) data.table::data.table(file = "example.xlsx"),
    .package = "CohortDescription"
  )
  expect_message(result <- createCohortDescription(), "completed")
  metrics <- data.table::fread(output)
  expect_identical(metrics$status, "completed")
  expect_gte(metrics$elapsed_seconds, 0)
  expect_equal(metrics$max_rss_kib, 2048)
  expect_equal(result$file, "example.xlsx")
  fail <- TRUE
  expect_error(createCohortDescription(), "simulated analysis failure")
  expect_identical(data.table::fread(output)$status, "failed")
})
