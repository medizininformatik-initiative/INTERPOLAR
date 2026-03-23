############################
### TEST parseStructuredConfigDefinitions ###
############################

testthat::test_that("parseStructuredConfigDefinitions parses simple definitions without plus", {
  definitions <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1'",
        "phase_a_start = '2026-01-11 10:00:00'"
      )
    )
  )

  parsed_records <- parseStructuredConfigDefinitions(
    definitions = definitions,
    allowed_key_pattern = "ward_name|phase_a_start|phase_b_start",
    allow_plus = FALSE
  )

  testthat::expect_length(parsed_records, 2L)

  testthat::expect_identical(parsed_records[[1]]$definition_name, "[[1]]")
  testthat::expect_identical(parsed_records[[1]]$entry_name, "PHASES_WARD_1")
  testthat::expect_identical(parsed_records[[1]]$line_index, 1L)
  testthat::expect_identical(parsed_records[[1]]$part_index, 1L)
  testthat::expect_identical(parsed_records[[1]]$part_count_in_line, 1L)
  testthat::expect_identical(parsed_records[[1]]$key, "ward_name")
  testthat::expect_identical(parsed_records[[1]]$value, "Station 1")
  testthat::expect_identical(parsed_records[[1]]$original_line, "ward_name = 'Station 1'")

  testthat::expect_identical(parsed_records[[2]]$key, "phase_a_start")
  testthat::expect_identical(parsed_records[[2]]$value, "2026-01-11 10:00:00")
})

testthat::test_that("parseStructuredConfigDefinitions uses fallback names for unnamed outer and inner lists", {
  definitions <- list(
    list(c(
      "ward_name = 'Station 1'",
      "phase_a_start = '2026-01-11'"
    ))
  )

  parsed_records <- parseStructuredConfigDefinitions(
    definitions = definitions,
    allowed_key_pattern = "ward_name|phase_a_start|phase_b_start",
    allow_plus = FALSE
  )

  testthat::expect_identical(parsed_records[[1]]$definition_name, "[[1]]")
  testthat::expect_identical(parsed_records[[1]]$entry_name, "[[1]]")
})

testthat::test_that("parseStructuredConfigDefinitions preserves whitespace inside values", {
  definitions <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1 West'"
      )
    )
  )

  parsed_records <- parseStructuredConfigDefinitions(
    definitions = definitions,
    allowed_key_pattern = "ward_name|phase_a_start|phase_b_start",
    allow_plus = FALSE
  )

  testthat::expect_identical(parsed_records[[1]]$value, "Station 1 West")
})

testthat::test_that("parseStructuredConfigDefinitions parses multiple subconditions with plus", {
  definitions <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "location/location/reference = 'Location/location_id_1' + type/coding/code = 'Y'"
      )
    )
  )

  parsed_records <- parseStructuredConfigDefinitions(
    definitions = definitions,
    allowed_key_pattern = "ward_name|[a-z/]+",
    allow_plus = TRUE
  )

  testthat::expect_length(parsed_records, 2L)

  testthat::expect_identical(parsed_records[[1]]$key, "location/location/reference")
  testthat::expect_identical(parsed_records[[1]]$value, "Location/location_id_1")
  testthat::expect_identical(parsed_records[[1]]$part_index, 1L)
  testthat::expect_identical(parsed_records[[1]]$part_count_in_line, 2L)

  testthat::expect_identical(parsed_records[[2]]$key, "type/coding/code")
  testthat::expect_identical(parsed_records[[2]]$value, "Y")
  testthat::expect_identical(parsed_records[[2]]$part_index, 2L)
  testthat::expect_identical(parsed_records[[2]]$part_count_in_line, 2L)
})

testthat::test_that("parseStructuredConfigDefinitions accepts plus inside quoted values", {
  definitions <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "ward_name = 'Station 1+'",
        "location/location/reference = 'Location/location_id_1+test'"
      )
    )
  )

  parsed_records <- parseStructuredConfigDefinitions(
    definitions = definitions,
    allowed_key_pattern = "ward_name|[a-z/]+",
    allow_plus = TRUE
  )

  testthat::expect_length(parsed_records, 2L)
  testthat::expect_identical(parsed_records[[1]]$value, "Station 1+")
  testthat::expect_identical(parsed_records[[2]]$value, "Location/location_id_1+test")
})

testthat::test_that("parseStructuredConfigDefinitions rejects plus when allow_plus is FALSE", {
  definitions <- list(
    list(
      PHASES_WARD_1 = c(
        "phase_a_start = '2026-01-11 10:00:00' + phase_b_start = '2026-01-12 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    parseStructuredConfigDefinitions(
      definitions = definitions,
      allowed_key_pattern = "ward_name|phase_a_start|phase_b_start",
      allow_plus = FALSE
    ),
    "Character '\\+' is not allowed"
  )
})

testthat::test_that("parseStructuredConfigDefinitions rejects trailing plus", {
  definitions <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "location/location/reference = 'Location/location_id_1' + "
      )
    )
  )

  testthat::expect_error(
    parseStructuredConfigDefinitions(
      definitions = definitions,
      allowed_key_pattern = "ward_name|[a-z/]+",
      allow_plus = TRUE
    ),
    "Invalid empty subcondition"
  )
})

testthat::test_that("parseStructuredConfigDefinitions rejects leading plus", {
  definitions <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        " + location/location/reference = 'Location/location_id_1'"
      )
    )
  )

  testthat::expect_error(
    parseStructuredConfigDefinitions(
      definitions = definitions,
      allowed_key_pattern = "ward_name|[a-z/]+",
      allow_plus = TRUE
    ),
    "Invalid empty subcondition"
  )
})

testthat::test_that("parseStructuredConfigDefinitions rejects double plus", {
  definitions <- list(
    list(
      ENCOUNTER_FILTER_PATTERN_1 = c(
        "location/location/reference = 'Location/location_id_1' ++ type/coding/code = 'Y'"
      )
    )
  )

  testthat::expect_error(
    parseStructuredConfigDefinitions(
      definitions = definitions,
      allowed_key_pattern = "ward_name|[a-z/]+",
      allow_plus = TRUE
    ),
    "Invalid empty subcondition"
  )
})

testthat::test_that("parseStructuredConfigDefinitions rejects invalid keys", {
  definitions <- list(
    list(
      PHASES_WARD_1 = c(
        "phase_c_start = '2026-01-11 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    parseStructuredConfigDefinitions(
      definitions = definitions,
      allowed_key_pattern = "ward_name|phase_a_start|phase_b_start",
      allow_plus = FALSE
    ),
    "Invalid subcondition"
  )
})

testthat::test_that("parseStructuredConfigDefinitions rejects invalid syntax without equals sign", {
  definitions <- list(
    list(
      PHASES_WARD_1 = c(
        "phase_a_start '2026-01-11 10:00:00'"
      )
    )
  )

  testthat::expect_error(
    parseStructuredConfigDefinitions(
      definitions = definitions,
      allowed_key_pattern = "ward_name|phase_a_start|phase_b_start",
      allow_plus = FALSE
    ),
    "Invalid subcondition"
  )
})

testthat::test_that("parseStructuredConfigDefinitions rejects unmatched single quotes", {
  definitions <- list(
    list(
      PHASES_WARD_1 = c(
        "ward_name = 'Station 1"
      )
    )
  )

  testthat::expect_error(
    parseStructuredConfigDefinitions(
      definitions = definitions,
      allowed_key_pattern = "ward_name|phase_a_start|phase_b_start",
      allow_plus = FALSE
    ),
    "Unmatched single quote"
  )
})

testthat::test_that("parseStructuredConfigDefinitions returns empty list for empty input", {
  parsed_records <- parseStructuredConfigDefinitions(
    definitions = list(),
    allowed_key_pattern = "ward_name|phase_a_start|phase_b_start",
    allow_plus = FALSE
  )

  testthat::expect_identical(parsed_records, list())
})
