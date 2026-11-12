test_that("value summaries have a separate one-column production default", {
  config <- getConfig(envir = new.env(parent = emptyenv()), command_arguments = character())
  expect_equal(config$value_summary_column_batch_size, 1L)
  expect_equal(config$count_batch_size, 100L)
  expect_true(config$code_summary_processing$enabled)
  expect_equal(config$code_summary_processing$target_rows_per_chunk, 500000)
  expect_equal(config$code_summary_processing$max_codes_per_chunk, 500)
  parsed <- parseCommandLineConfig("value_summary_column_batch_size=3")
  expect_equal(as.numeric(parsed$VALUE_SUMMARY_COLUMN_BATCH_SIZE), 3)
})

test_that("small value-summary column batches preserve values and statistics", {
  fixture <- codeSummaryFixture()
  metadata <- fixture$metadata[TABLE_NAME == "observation" & COLUMN_NAME %in% c("obs_id", "obs_code_code", "obs_code_system", "obs_value", "obs_unit")]
  config <- fixture$config
  config$value_summary_suppressed_column_patterns <- list(FHIR = "_id$")
  queries <- list()
  run <- function(size) {
    config$value_summary_column_batch_size <- size
    createValueSummaryReports(metadata, config, query_fun = function(query, lock_id) {
      queries[[length(queries) + 1L]] <<- query
      runCodeSummaryFixtureQuery(fixture, query)
    })
  }
  expected <- run(100)
  baseline_calls <- length(queries)
  queries <- list()
  actual <- run(1)
  expect_equal(actual, expected, tolerance = 1e-12)
  expect_true(length(queries) > baseline_calls)
  expect_equal(actual$observation$COLUMN_NAME, metadata$COLUMN_NAME)
  for (size in list(0, -1, 1.5, Inf, NA_real_, "1")) {
    expect_error(run(size), "positive integer")
  }
})
