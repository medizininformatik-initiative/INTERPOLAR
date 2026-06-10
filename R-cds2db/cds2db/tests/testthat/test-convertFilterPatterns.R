############################
### TEST convertCohortFilterPatterns ###
############################

testthat::test_that("convertCohortFilterPatterns groups conditions by cohort and resource", {
  variable_names <- "TEST_MULTI_RESOURCE_COHORT_FILTER_PATTERN_1"
  on.exit(rm(list = variable_names, envir = .GlobalEnv), add = TRUE)

  assign(
    variable_names,
    c(
      "cohort_name = 'DUP 1'",
      "resource = 'Encounter' + location/location/reference = 'Location/location_id_1'",
      "resource = 'Observation' + code/coding/code = '12345' + effectiveDateTime = '2025-01-01'",
      "resource = 'Observation' + code/coding/code = '67890'"
    ),
    envir = .GlobalEnv
  )

  converted_filter_patterns <- convertCohortFilterPatterns("TEST_MULTI_RESOURCE_COHORT_FILTER_PATTERN")

  testthat::expect_named(converted_filter_patterns, "DUP 1")
  testthat::expect_named(converted_filter_patterns[["DUP 1"]], c("Encounter", "Observation"))
  testthat::expect_identical(
    converted_filter_patterns[["DUP 1"]][["Encounter"]][["Condition_1"]],
    list("location/location/reference" = "Location/location_id_1")
  )
  testthat::expect_identical(
    converted_filter_patterns[["DUP 1"]][["Observation"]][["Condition_1"]],
    list(
      "code/coding/code" = "12345",
      effectiveDateTime = "2025-01-01"
    )
  )
  testthat::expect_identical(
    converted_filter_patterns[["DUP 1"]][["Observation"]][["Condition_2"]],
    list("code/coding/code" = "67890")
  )
})

testthat::test_that("convertCohortFilterPatterns maps legacy encounter patterns to Encounter", {
  variable_names <- "TEST_LEGACY_ENCOUNTER_FILTER_PATTERN_1"
  on.exit(rm(list = variable_names, envir = .GlobalEnv), add = TRUE)

  assign(
    variable_names,
    c(
      "ward_name = 'Station 1'",
      "location/location/reference = 'Location/location_id_1'"
    ),
    envir = .GlobalEnv
  )

  converted_filter_patterns <- convertCohortFilterPatterns("TEST_LEGACY_ENCOUNTER_FILTER_PATTERN")

  testthat::expect_named(converted_filter_patterns, "Station 1")
  testthat::expect_named(converted_filter_patterns[["Station 1"]], "Encounter")
  testthat::expect_identical(
    converted_filter_patterns[["Station 1"]][["Encounter"]][["Condition_1"]],
    list("location/location/reference" = "Location/location_id_1")
  )
})

############################
### TEST convertFilterPatterns ###
############################

testthat::test_that("convertFilterPatterns returns one final entry per legacy ward", {
  variable_names <- c(
    "TEST_ENCOUNTER_FILTER_PATTERN_1",
    "TEST_ENCOUNTER_FILTER_PATTERN_2",
    "TEST_ENCOUNTER_FILTER_PATTERN_3"
  )
  on.exit(rm(list = variable_names, envir = .GlobalEnv), add = TRUE)

  assign(
    variable_names[1],
    c(
      "ward_name = 'Station 1'",
      "location/location/reference = 'Location/location_id_1a' + id = 'AAA'",
      "location/location/reference = 'Location/location_id_1b'"
    ),
    envir = .GlobalEnv
  )
  assign(
    variable_names[2],
    c(
      "ward_name = 'Station 2'",
      "id = '.*'"
    ),
    envir = .GlobalEnv
  )
  assign(
    variable_names[3],
    c("ward_name = 'Station 3'"),
    envir = .GlobalEnv
  )

  converted_filter_patterns <- convertFilterPatterns("TEST_ENCOUNTER_FILTER_PATTERN")

  testthat::expect_named(
    converted_filter_patterns,
    c("Station 1", "Station 2", "Station 3")
  )
  testthat::expect_length(converted_filter_patterns, 3)
  testthat::expect_length(converted_filter_patterns[["Station 1"]], 2)
  testthat::expect_length(converted_filter_patterns[["Station 2"]], 1)
  testthat::expect_length(converted_filter_patterns[["Station 3"]], 0)
  testthat::expect_identical(
    converted_filter_patterns[["Station 1"]][["Condition_1"]],
    list(
      "location/location/reference" = "Location/location_id_1a",
      id = "AAA"
    )
  )
  testthat::expect_identical(
    converted_filter_patterns[["Station 1"]][["Condition_2"]],
    list("location/location/reference" = "Location/location_id_1b")
  )
})

testthat::test_that("convertFilterPatterns keeps plus signs inside quoted values", {
  variable_names <- "TEST_PLUS_ENCOUNTER_FILTER_PATTERN_1"
  on.exit(rm(list = variable_names, envir = .GlobalEnv), add = TRUE)

  assign(
    variable_names,
    c(
      "ward_name = 'Station 1+'",
      "location/location/reference = 'Location/location_id_1'"
    ),
    envir = .GlobalEnv
  )

  converted_filter_patterns <- convertFilterPatterns("TEST_PLUS_ENCOUNTER_FILTER_PATTERN")

  testthat::expect_named(converted_filter_patterns, "Station 1+")
})

testthat::test_that("convertFilterPatterns converts resource-scoped cohort patterns for Encounter", {
  variable_names <- "TEST_COHORT_FILTER_PATTERN_1"
  on.exit(rm(list = variable_names, envir = .GlobalEnv), add = TRUE)

  assign(
    variable_names,
    c(
      "cohort_name = 'DUP 1'",
      "resource = 'Encounter' + location/location/reference = 'Location/location_id_1' + id = 'AAA'",
      "resource = 'Encounter' + location/location/reference = 'Location/location_id_2'"
    ),
    envir = .GlobalEnv
  )

  converted_filter_patterns <- convertFilterPatterns("TEST_COHORT_FILTER_PATTERN")

  testthat::expect_named(converted_filter_patterns, "DUP 1")
  testthat::expect_identical(
    converted_filter_patterns[["DUP 1"]][["Condition_1"]],
    list(
      "location/location/reference" = "Location/location_id_1",
      id = "AAA"
    )
  )
  testthat::expect_false("resource" %in% names(converted_filter_patterns[["DUP 1"]][["Condition_1"]]))
})

testthat::test_that("convertFilterPatterns rejects non-Encounter resources until generic PID selection exists", {
  variable_names <- "TEST_OBSERVATION_COHORT_FILTER_PATTERN_1"
  on.exit(rm(list = variable_names, envir = .GlobalEnv), add = TRUE)

  assign(
    variable_names,
    c(
      "cohort_name = 'DUP 1'",
      "resource = 'Observation' + code/coding/code = '12345'"
    ),
    envir = .GlobalEnv
  )

  testthat::expect_error(
    convertFilterPatterns("TEST_OBSERVATION_COHORT_FILTER_PATTERN"),
    "Only Encounter cohort filter resources are supported"
  )
})
