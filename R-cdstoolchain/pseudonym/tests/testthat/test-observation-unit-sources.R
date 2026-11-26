test_that("observation conversion respects unit systems and optional columns", {
  mapping <- data.table::data.table(
    LOINC = "mass", LOINC_PRIMARY = "primary", UNIT = "g",
    CONVERSION_FACTOR = NA_real_, CONVERSION_UNIT = NA_character_
  )
  cases <- list(
    list(code = "mg", system = "http://unitsofmeasure.org", expected = 0.002),
    list(unit = "mg", expected = 0.002),
    list(code = "mg", unit = "g", system = "http://unitsofmeasure.org", expected = 0.002),
    list(code = "mg", unit = "g", system = "https://example.org/units", expected = 2),
    list(code = "mg", unit = "g", expected = 2),
    list(code = "mg", unit = "g", system = "", expected = 2),
    list(code = "mg", unit = "g", system = NA_character_, expected = 2),
    list(code = "invalid", unit = "mg", system = "http://unitsofmeasure.org", expected = 0.002),
    list(code = "mg", system = "https://example.org/units", expected = NA_real_),
    list(code = "mg", expected = NA_real_),
    list(code = "mg", system = NA_character_, expected = NA_real_),
    list(expected = NA_real_)
  )
  for (case in cases) {
    source <- data.table::data.table(
      obs_code_system = "http://loinc.org", obs_code_code = "mass",
      obs_valuequantity_value = 2
    )
    for (field in intersect(c("code", "unit", "system"), names(case))) {
      source[[paste0("obs_valuequantity_", field)]] <- case[[field]]
    }
    context <- newSnapshotStreamingContext(NULL)
    context$loinc_mapping <- mapping
    result <- enrichSnapshotStreamingChunk(
      source, "observation", context,
      described_columns = c(names(source), SNAPSHOT_OBSERVATION_ANALYSIS_COLUMNS)
    )
    expect_equal(result[, names(source), with = FALSE], source)
    expect_equal(result$analysis_loinc_code, "primary")
    if (is.na(case$expected)) {
      expect_equal(result$analysis_value, 2)
      expect_true(is.na(result$analysis_unit))
      expect_equal(result$analysis_value_status, "source_missing_unit")
      review <- getLoincUnitConversionReview(result, "observation")
      expect_equal(review$AFFECTED_ROWS, 1)
      expect_true(is.na(review$USED_SOURCE_UNIT))
    } else {
      expect_equal(result$analysis_value, case$expected)
      expect_equal(result$analysis_unit, "g")
      expect_equal(result$analysis_value_status, if (case$expected == 2) "already_reference_unit" else "converted")
    }
  }
})

test_that("unmapped values and failed conversions preserve their source", {
  mapping <- data.table::data.table(
    LOINC = "mass", LOINC_PRIMARY = "primary", UNIT = "g",
    CONVERSION_FACTOR = NA_real_, CONVERSION_UNIT = NA_character_
  )
  source <- data.table::data.table(
    obs_code_system = "http://loinc.org", obs_code_code = c("mass", "unmapped"),
    obs_valuequantity_value = c(2, 3), obs_valuequantity_unit = "mmol/L"
  )
  result <- enrichObservationWithLoincMapping(source, mapping)
  expect_equal(result$analysis_value, c(2, 3))
  expect_equal(result$analysis_unit, rep("mmol/L", 2))
  expect_equal(result$analysis_value_status, c("source_conversion_failed", "source_no_mapping"))
  review <- getLoincUnitConversionReview(result, "observation")
  expect_true(is.na(review$SOURCE_UNIT_CODE))
  expect_equal(review$SOURCE_UNIT_DISPLAY, "mmol/L")
  source$obs_valuequantity_unit <- NULL
  result <- enrichObservationWithLoincMapping(source, mapping)
  expect_equal(result$analysis_loinc_code, c("primary", "unmapped"))
  expect_equal(result$analysis_value, c(2, 3))
  expect_true(all(is.na(result$analysis_unit)))
  expect_equal(result$analysis_value_status, c("source_missing_unit", "source_no_mapping_missing_unit"))
})

test_that("streaming loads the mapping with optional unit columns absent", {
  calls <- 0L
  mapping <- data.table::data.table(
    LOINC = character(), LOINC_PRIMARY = character(), UNIT = character(),
    CONVERSION_FACTOR = numeric(), CONVERSION_UNIT = character()
  )
  testthat::local_mocked_bindings(loadSnapshotLoincMapping = function(input_repo_path) {
    calls <<- calls + 1L
    mapping
  })
  source <- data.table::data.table(
    obs_code_system = "http://loinc.org", obs_code_code = "unmapped",
    obs_valuequantity_value = 2
  )
  context <- newSnapshotStreamingContext(NULL)
  for (i in 1:2) {
    result <- enrichSnapshotStreamingChunk(source, "observation", context,
      described_columns = c(names(source), SNAPSHOT_OBSERVATION_ANALYSIS_COLUMNS)
    )
    expect_equal(result$analysis_value, 2)
    expect_equal(result$analysis_value_status, "source_no_mapping_missing_unit")
  }
  expect_equal(calls, 1L)
})
