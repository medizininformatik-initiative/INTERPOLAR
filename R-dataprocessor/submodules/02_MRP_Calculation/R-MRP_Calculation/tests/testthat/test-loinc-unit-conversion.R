test_that("filterObservations keeps mU/L observations convertible through etlutils", {
  obs <- data.table::data.table(
    code = "TSH",
    value = 1000,
    unit = "mU/L",
    start_datetime = as.POSIXct("2026-01-01", tz = "UTC"),
    reference_range_type = "normal",
    reference_range_low_value = NA_real_,
    reference_range_low_code = NA_character_,
    reference_range_low_system = NA_character_,
    reference_range_high_value = 2,
    reference_range_high_code = "U/L",
    reference_range_high_system = "http://unitsofmeasure.org"
  )

  result <- filterObservations(
    obs,
    reference_value_col = "reference_range_high_value",
    invalid_obs = data.table::data.table()
  )

  expect_equal(nrow(result), 1)
  expect_equal(result[["converted_value"]], 1)
  expect_equal(result[["converted_unit"]], "U/L")
})
