testthat::test_that("conversion preserves AND, OR, regex values and station order", {
  definitions <- list(
    ENCOUNTER_FILTER_PATTERN_2 = c(
      "ward_name = 'Station B'",
      "location/location/reference = '^Location/A$' + type/coding/code = '^ward$'",
      "location/location/reference = '^Location/B+$'"
    ),
    ENCOUNTER_FILTER_PATTERN_1 = "ward_name = 'Station A'"
  )
  validateEncounterFilterPatterns(definitions)
  converted <- convertFilterPatterns(definitions)
  testthat::expect_identical(converted, list(
    "Station B" = list(
      Condition_1 = list(
        "location/location/reference" = "^Location/A$",
        "type/coding/code" = "^ward$"
      ),
      Condition_2 = list("location/location/reference" = "^Location/B+$")
    ),
    "Station A" = list()
  ))
  encounters <- data.table::data.table(
    id = c("and-match", "wrong-type", "or-match", "no-match"),
    "location/location/reference" = c("Location/A", "Location/A", "location/BB", "Location/C"),
    "type/coding/code" = c("WARD", "other", "other", "ward")
  )
  testthat::expect_identical(
    filterResources(data.table::copy(encounters), converted[["Station B"]])$id,
    c("and-match", "or-match")
  )
  # A ward-only definition retains the existing match-all behavior.
  testthat::expect_identical(
    filterResources(data.table::copy(encounters), converted[["Station A"]])$id,
    encounters$id
  )
})

testthat::test_that("conversion accepts both supported definition representations", {
  flat <- list(ENCOUNTER_FILTER_PATTERN_1 = c(
    "ward_name = 'Station 1'",
    "serviceProvider/identifier/value = 'M4D03'"
  ))
  testthat::expect_identical(convertFilterPatterns(flat), convertFilterPatterns(list(flat)))
  testthat::expect_error(convertFilterPatterns(list()), "No encounter filter definitions")
})
