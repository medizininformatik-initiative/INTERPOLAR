test_that("value summaries share source reads in column batches by default", {
  config <- getConfig(envir = new.env(parent = emptyenv()), command_arguments = character())
  expect_equal(config$value_summary_column_batch_size, 100L)
  expect_equal(config$count_batch_size, 100L)
  expect_false(config$code_summary_processing$enabled)
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

test_that("text value counts deduplicate resources and count only entirely empty resources as empty", {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- paste0(
    "TRUNCATE observation; INSERT INTO observation (obs_id,obs_code_code,obs_unit) VALUES ",
    "('one','A','mg'),('one','A','mg'),('one',NULL,NULL),('one','',''),",
    "('one','B','g'),('two','A',NULL),('three',NULL,''),('three','',NULL),",
    "(NULL,'A','mg'),(NULL,NULL,NULL);"
  )
  metadata <- fixture$metadata[TABLE_NAME == "observation"]
  for (columns in list("obs_code_code", c("obs_code_code", "obs_unit"))) {
    query <- buildTextValueSummaryQuery(metadata, columns, "obs_id")
    rows <- runCodeSummaryFixtureQuery(fixture, query)
    codes <- rows[COLUMN_NAME == "obs_code_code"]
    expect_equal(codes[VALUE == "A", COUNT], 2)
    expect_equal(codes[VALUE == "B", COUNT], 1)
    expect_equal(codes[is.na(VALUE), COUNT], 1)
    if ("obs_unit" %in% columns) {
      units <- rows[COLUMN_NAME == "obs_unit"]
      expect_equal(units[VALUE == "mg", COUNT], 1)
      expect_equal(units[VALUE == "g", COUNT], 1)
      expect_equal(units[is.na(VALUE), COUNT], 2)
    }
  }
})

test_that("filled-value aggregation preserves empty tables and missing resource IDs", {
  fixture <- codeSummaryFixture()
  metadata <- fixture$metadata[TABLE_NAME == "observation"]
  columns <- c("obs_code_code", "obs_unit")
  for (null_ids_only in c(FALSE, TRUE)) {
    fixture$extra_sql <- paste0(
      "TRUNCATE observation;",
      if (null_ids_only) paste0(
        "INSERT INTO observation (obs_id,obs_code_code) VALUES ",
        "(NULL,'A'),(NULL,'A'),(NULL,NULL);"
      )
    )
    counts <- runCodeSummaryFixtureQuery(
      fixture, buildTextValueSummaryQuery(metadata, columns, "obs_id")
    )
    result <- summariseTextValueCounts(counts, metadata, columns)
    expect_equal(result$EMPTY, c(0L, 0L))
    expect_equal(result$DISTINCT_VALUES, c(as.integer(null_ids_only), 0L))
    expect_true(is.na(result[COLUMN_NAME == "obs_unit", VALUE_COUNTS]))
  }
})
