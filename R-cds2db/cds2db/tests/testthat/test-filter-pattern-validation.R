############################################
### TEST validateEncounterFilterPatterns ###
############################################

testthat::test_that("validateEncounterFilterPatterns returns TRUE for valid definitions", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "location/location/reference = 'Location/location_id_1'"
      )
    ),
    list(
      ENCOUNTER_FILTER_PATTERN_2 = c(
        "ward_name = 'Station 2'",
        "location/location/reference = 'Location/location_id_2' + type/coding/code = 'Y'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns)))
})

testthat::test_that("validateEncounterFilterPatterns accepts definition with only ward_name", {
  encounter_filter_patterns <- list(
    list(ENCOUNTER_FILTER_PATTERN_1 = c("ward_name = 'Station 1'")),
    list(
      ENCOUNTER_FILTER_PATTERN_2 = c(
        "ward_name = 'Station 2'",
        "location/location/reference = 'Location/location_id_2'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns)))
})

testthat::test_that("validateEncounterFilterPatterns accepts whitespace variations", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "   ward_name   =   'Station 1'   ",
        " location/location/reference   =   'Location/location_id_1'  +  type/coding/code = 'Y' "
      )
    ),
    list(ENCOUNTER_FILTER_PATTERN_2 = c("ward_name='Station 2'"))
  )

  testthat::expect_true(isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns)))
})

testthat::test_that("validateEncounterFilterPatterns accepts unnamed outer and inner lists", {
  encounter_filter_patterns <- list(
    list(c(
      "ward_name = 'Station 1'",
      "location/location/reference = 'Location/location_id_1'"
    )),
    list(c("ward_name = 'Station 2'"))
  )

  testthat::expect_true(isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns)))
})

testthat::test_that("validateEncounterFilterPatterns rejects invalid key names", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "Location1/location/reference = 'Location/location_id_1'"
      )
    )
  )

  testthat::expect_error(
    validateEncounterFilterPatterns(encounter_filter_patterns),
    "Invalid subcondition"
  )
})

testthat::test_that("validateEncounterFilterPatterns rejects invalid syntax", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "location/location/reference 'Location/location_id_1'"
      )
    )
  )

  testthat::expect_error(
    validateEncounterFilterPatterns(encounter_filter_patterns),
    "Invalid subcondition"
  )
})

testthat::test_that("validateEncounterFilterPatterns rejects empty subcondition caused by trailing plus", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "location/location/reference = 'Location/location_id_1' + "
      )
    )
  )

  testthat::expect_error(
    validateEncounterFilterPatterns(encounter_filter_patterns),
    "Invalid empty subcondition"
  )
})

testthat::test_that("validateEncounterFilterPatterns accepts plus in values of key-value patterns", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1+'",
        "location/location/reference = 'Location/location_id_1'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns)))
})

testthat::test_that("validateEncounterFilterPatterns rejects empty subcondition caused by double plus", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "location/location/reference = 'Location/location_id_1' ++ type/coding/code = 'Y'"
      )
    )
  )

  testthat::expect_error(
    validateEncounterFilterPatterns(encounter_filter_patterns),
    "Invalid empty subcondition"
  )
})

testthat::test_that("validateEncounterFilterPatterns rejects ward_name combined with other subconditions", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1' + location/location/reference = 'Location/location_id_1'"
      )
    )
  )

  testthat::expect_error(
    validateEncounterFilterPatterns(encounter_filter_patterns),
    "ward_name must not be combined with other subconditions using '\\+'"
  )
})

testthat::test_that("validateEncounterFilterPatterns rejects missing ward_name", {
  encounter_filter_patterns <- list(
    list(ENCOUNTER_FILTER_PATTERN_1 = c("location/location/reference = 'Location/location_id_1'"))
  )

  testthat::expect_error(
    validateEncounterFilterPatterns(encounter_filter_patterns),
    "must contain exactly one ward_name, but contains 0"
  )
})

testthat::test_that("validateEncounterFilterPatterns rejects multiple ward_name definitions", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "ward_name = 'Station 1'"
      )
    )
  )

  testthat::expect_error(
    validateEncounterFilterPatterns(encounter_filter_patterns),
    "must contain exactly one ward_name, but contains 2"
  )
})

testthat::test_that("validateEncounterFilterPatterns rejects empty ward_name", {
  encounter_filter_patterns <- list(list(ENCOUNTER_FILTER_PATTERN_1 = c("ward_name = ''")))

  testthat::expect_error(
    validateEncounterFilterPatterns(encounter_filter_patterns),
    "ward_name must not be empty"
  )
})

testthat::test_that("validateEncounterFilterPatterns rejects duplicate ward names across definitions", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "location/location/reference = 'Location/location_id_1'"
      )
    ),
    list(
      ENCOUNTER_FILTER_PATTERN_2 = c(
        "ward_name = 'Station 1'",
        "location/location/reference = 'Location/location_id_2'"
      )
    )
  )

  testthat::expect_error(
    validateEncounterFilterPatterns(encounter_filter_patterns),
    "Duplicate ward_name found: 'Station 1'"
  )
})

testthat::test_that("validateEncounterFilterPatterns allows same encounter condition for different wards", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "location/location/reference = 'Location/location_id_1'"
      )
    ),
    list(
      ENCOUNTER_FILTER_PATTERN_2 = c(
        "ward_name = 'Station 2'",
        "location/location/reference = 'Location/location_id_1'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns)))
})

testthat::test_that("validateEncounterFilterPatterns allows capital letters in key names", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Nephrologie'",
        "serviceProvider/identifier/value = 'M4D03'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns)))
})

#########################################
### TEST validateCohortFilterPatterns ###
#########################################

testthat::test_that("validateCohortFilterPatterns accepts resource-scoped cohort definitions", {
  cohort_filter_patterns <- list(
    list(
      COHORT_FILTER_PATTERN_1 = c(
        "cohort_name = 'DUP 1'",
        "resource = 'Encounter' + location/location/reference = 'Location/location_id_1'",
        "resource = 'Observation' + code/coding/code = '12345'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateCohortFilterPatterns(cohort_filter_patterns)))
})

testthat::test_that("validateCohortFilterPatterns rejects missing resource in condition lines", {
  cohort_filter_patterns <- list(
    list(
      COHORT_FILTER_PATTERN_1 = c(
        "cohort_name = 'DUP 1'",
        "location/location/reference = 'Location/location_id_1'"
      )
    )
  )

  testthat::expect_error(
    validateCohortFilterPatterns(cohort_filter_patterns),
    "must contain exactly one resource, but contains 0"
  )
})

testthat::test_that("validateCohortFilterPatterns rejects duplicate cohort names", {
  cohort_filter_patterns <- list(
    list(
      COHORT_FILTER_PATTERN_1 = c(
        "cohort_name = 'DUP 1'",
        "resource = 'Encounter' + id = '.*'"
      )
    ),
    list(
      COHORT_FILTER_PATTERN_2 = c(
        "cohort_name = 'DUP 1'",
        "resource = 'Encounter' + id = '.*'"
      )
    )
  )

  testthat::expect_error(
    validateCohortFilterPatterns(cohort_filter_patterns),
    "Duplicate cohort_name found: 'DUP 1'"
  )
})

testthat::test_that("normalizeLegacyEncounterFilterPatterns converts ward_name to cohort_name", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "location/location/reference = 'Location/location_id_1'"
      )
    )
  )

  cohort_filter_patterns <- normalizeLegacyEncounterFilterPatterns(encounter_filter_patterns)

  testthat::expect_identical(
    cohort_filter_patterns[[1]][[1]][[1]],
    "cohort_name = 'Station 1'"
  )
})

testthat::test_that("getConfiguredCohortFilterPatterns rejects mixed cohort and encounter definitions", {
  test_env <- new.env(parent = emptyenv())
  assign("COHORT_FILTER_PATTERN_1", c("cohort_name = 'DUP 1'"), envir = test_env)
  assign("ENCOUNTER_FILTER_PATTERN_1", c("ward_name = 'Station 1'"), envir = test_env)

  testthat::expect_error(
    getConfiguredCohortFilterPatterns(envir = test_env),
    "Define either COHORT_FILTER_PATTERN or ENCOUNTER_FILTER_PATTERN, not both"
  )
})

testthat::test_that("getConfiguredCohortFilterPatterns returns normalized legacy definitions", {
  test_env <- new.env(parent = emptyenv())
  assign(
    "ENCOUNTER_FILTER_PATTERN_1",
    c(
      "ward_name = 'Station 1'",
      "location/location/reference = 'Location/location_id_1'"
    ),
    envir = test_env
  )

  configured_filter_patterns <- getConfiguredCohortFilterPatterns(envir = test_env)

  testthat::expect_true(configured_filter_patterns$legacy)
  testthat::expect_identical(
    configured_filter_patterns$definitions[[1]][[1]][[1]],
    "cohort_name = 'Station 1'"
  )
})

testthat::test_that("validateConfig rejects overlapping patients switch for legacy encounter patterns", {
  variable_names <- c(
    "PROCESS",
    "ENCOUNTER_FILTER_PATTERN_1",
    "ALLOW_PATIENTS_IN_MULTIPLE_COHORTS"
  )
  on.exit(rm(list = variable_names, envir = .GlobalEnv), add = TRUE)

  assign("PROCESS", "CDSToolChain", envir = .GlobalEnv)
  assign(
    "ENCOUNTER_FILTER_PATTERN_1",
    c(
      "ward_name = 'Station 1'",
      "id = '.*'"
    ),
    envir = .GlobalEnv
  )
  assign("ALLOW_PATIENTS_IN_MULTIPLE_COHORTS", TRUE, envir = .GlobalEnv)

  testthat::expect_error(
    validateConfig(),
    "cannot be TRUE with legacy ENCOUNTER_FILTER_PATTERN"
  )
})
