test_that("measurement statistics depend on the mapped numeric column, not the code family", {
  fixture <- codeSummaryFixture()
  fixture$config$code_summary_report_types[] <- "coding"
  for (column_type in c("smallint", "integer", "bigint", "numeric", "decimal", "real", "double precision")) {
    metadata <- data.table::copy(fixture$metadata)
    metadata[COLUMN_NAME == "obs_value", DATA_TYPE := column_type]
    sources <- resolveCodeSummarySources(metadata, fixture$config, fixture$description)
    expect_true(sources[[1]]$measurement, info = column_type)
    expect_identical(sources[[1]]$measurement_mode, "auto")
    expect_identical(sources[[1]]$fields[["value"]], "obs_value")
    expect_false(sources[[2]]$measurement)
  }
})

test_that("non-numeric, absent and unknown value types do not enable statistics", {
  fixture <- codeSummaryFixture()
  for (column_type in c("text", "character varying", "boolean", "timestamp without time zone", "ARRAY", NA_character_)) {
    metadata <- data.table::copy(fixture$metadata)
    metadata[COLUMN_NAME == "obs_value", DATA_TYPE := column_type]
    # Another numeric column is not evidence of a quantitative measurement.
    metadata[COLUMN_NAME == "obs_code_code", DATA_TYPE := "integer"]
    source <- resolveCodeSummarySources(metadata, fixture$config, fixture$description)[[1]]
    expect_false(source$measurement)
    expect_true(all(is.na(source$fields[c("value", "unit", "low", "high")])))
  }
  metadata <- data.table::copy(fixture$metadata)
  metadata[, DATA_TYPE := NULL]
  expect_false(resolveCodeSummarySources(metadata, fixture$config, fixture$description)[[1]]$measurement)
  expect_false(resolveCodeSummarySources(
    fixture$metadata[COLUMN_NAME != "obs_value"], fixture$config, fixture$description
  )[[1]]$measurement)
  fixture$config$code_summary_report_types[["LOINC"]] <- "measurement"
  expect_false(resolveCodeSummarySources(metadata, fixture$config, fixture$description)[[1]]$measurement)
})

test_that("units and limits are optional and configured value overrides are honored", {
  fixture <- codeSummaryFixture()
  metadata <- fixture$metadata[!COLUMN_NAME %in% c("obs_unit", "obs_unit_system", "obs_low", "obs_high", "obs_range_type")]
  source <- resolveCodeSummarySources(metadata, fixture$config, fixture$description)[[1]]
  expect_true(source$measurement)
  expect_true(all(is.na(source$fields[c("unit", "unit_system", "low", "high", "range_type")])))
  fixture$config$code_summary_sources[[1]]$fields <- list(value = "not/imported")
  expect_false(resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description)[[1]]$measurement)
  fixture$config$code_summary_sources[[1]]$columns <- list(value = "obs_value")
  expect_true(resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description)[[1]]$measurement)
})

test_that("explicit measurement overrides remain available", {
  fixture <- codeSummaryFixture()
  fixture$config$code_summary_sources[[1]]$measurement <- FALSE
  source <- resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description)[[1]]
  expect_false(source$measurement)
  expect_identical(source$measurement_mode, "explicit")
  expect_true(is.na(source$fields[["value"]]))
  fixture$config$code_summary_sources[[1]]$measurement <- TRUE
  fixture$metadata[COLUMN_NAME == "obs_value", DATA_TYPE := "text"]
  calls <- 0L
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(calls, 1L)
  expect_equal(reports$Observation[row_type == "detail", mean], 3.5)
  fixture$config$code_summary_sources[[1]]$measurement <- "auto"
  expect_error(resolveCodeSummarySources(fixture$metadata, fixture$config, fixture$description), "TOML boolean")
})

test_that("a configured numeric value enables statistics on another resource and coding system", {
  fixture <- codeSummaryFixture()
  fixture$description <- data.table::rbindlist(list(fixture$description, data.table::data.table(
    RESOURCE = "Condition", FHIR_EXPRESSION = "score/value", COLUMN_NAME = "con_score"
  )))
  fixture$metadata <- data.table::rbindlist(list(fixture$metadata, data.table::data.table(
    TABLE_FAMILY = "FHIR", TABLE_NAME = "condition", VIEW_SCHEMA = "pg_temp", VIEW_NAME = "condition",
    COLUMN_NAME = "con_score", DATA_TYPE = "double precision"
  )))
  fixture$config$code_summary_sources[[2]]$fields <- list(value = "score/value")
  fixture$extra_sql <- paste0(
    "INSERT INTO condition (con_id,con_code_system,con_code_code,con_score) ",
    "SELECT 'score'||n,'http://fhir.de/CodeSystem/bfarm/icd-10-gm','test-score',n ",
    "FROM generate_series(1,6) n;"
  )
  calls <- 0L
  reports <- createCodeSummaryReports(
    fixture$metadata, fixture$config,
    table_description = fixture$description,
    query_fun = function(query, lock_id) {
      calls <<- calls + 1L
      runCodeSummaryFixtureQuery(fixture, query)
    }
  )
  expect_equal(calls, 1L)
  detail <- reports$Condition[row_type == "detail"]
  expect_equal(detail$count, 6)
  expect_equal(detail$mean, 3.5)
  expect_equal(detail$sd, stats::sd(1:6))
  expect_true(is.na(detail$unit))
  expect_true(is.na(detail$low))
  expect_true(any(grepl("measurement=TRUE (auto)", attr(reports, "description"), fixed = TRUE)))
})
