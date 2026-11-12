test_that("laboratory conversion and overlapping normality use documented observations", {
  x <- data.table::data.table(
    obs_patient_ref = "Patient/p", obs_code_code = "62238-1",
    start_datetime = as.POSIXct("2025-01-01", tz = "UTC"),
    obs_valuequantity_value = c(89, 130, 131, NA_real_),
    obs_valuequantity_code = "mL/min/{1.73_m2}", obs_valuequantity_unit = "mL/min/{1.73_m2}",
    obs_referencerange_low_value = c(90, 90, 90, NA_real_),
    obs_referencerange_high_value = c(130, 130, 130, NA_real_),
    obs_referencerange_low_code = "mL/min/{1.73_m2}",
    obs_referencerange_high_code = "mL/min/{1.73_m2}"
  )
  mapping <- data.table::data.table(
    LOINC = "62238-1", LOINC_PRIMARY = "62238-1",
    UNIT = "mL/min/{1.73_m2}", CONVERSION_FACTOR = 1, CONVERSION_UNIT = "mL/min"
  )
  result <- prepareCohortLaboratory(x, mapping)
  expect_equal(result$value_reference, c(89, 130, 131, NA_real_))
  expect_equal(result$normal, c(FALSE, TRUE, FALSE, NA))
  expect_equal(result$abnormal, c(TRUE, FALSE, TRUE, NA))
  expect_true(all(result$egfr))
  expect_true(all(result$compatible_unit))
  expect_equal(result$numeric_ok, c(TRUE, TRUE, TRUE, FALSE))
  expect_equal(nrow(prepareCohortLaboratory(x[0], mapping)), 0L)
  mapping[, `:=`(
    LOINC = "1234-5", LOINC_PRIMARY = "1234-5", UNIT = "mg/dL",
    CONVERSION_FACTOR = 18.0182, CONVERSION_UNIT = "mmol/L"
  )]
  x[, `:=`(
    obs_code_code = "1234-5", obs_valuequantity_value = 5,
    obs_valuequantity_code = "mmol/L", obs_valuequantity_unit = "mmol/L"
  )]
  result <- prepareCohortLaboratory(x, mapping)
  expect_equal(result$value_reference, rep(90.091, 4), tolerance = 1e-5)
})
