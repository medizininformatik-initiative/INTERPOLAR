############################
### TEST validateEncounterFilterPatterns ###
############################

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
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'"
      )
    ),
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
    list(
      ENCOUNTER_FILTER_PATTERN_2 = c(
        "ward_name='Station 2'"
      )
    )
  )

  testthat::expect_true(isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns)))
})

testthat::test_that("validateEncounterFilterPatterns accepts unnamed outer and inner lists", {
  encounter_filter_patterns <- list(
    list(c(
      "ward_name = 'Station 1'",
      "location/location/reference = 'Location/location_id_1'"
    )),
    list(c(
      "ward_name = 'Station 2'"
    ))
  )

  testthat::expect_true(isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns)))
})

testthat::test_that("validateEncounterFilterPatterns rejects invalid key names", {
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1'",
        "Location/location/reference = 'Location/location_id_1'"
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

  testthat::expect_true(
    isTRUE(validateEncounterFilterPatterns(encounter_filter_patterns))
  )
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
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "location/location/reference = 'Location/location_id_1'"
      )
    )
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
  encounter_filter_patterns <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = ''"
      )
    )
  )

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

