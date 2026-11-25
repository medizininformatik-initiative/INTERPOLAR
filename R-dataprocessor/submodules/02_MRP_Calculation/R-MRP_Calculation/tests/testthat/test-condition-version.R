test_that("condition loader preserves catalogue version without changing event time selection", {
  time <- as.POSIXct("2025-01-02", tz = "UTC")
  local_mocked_bindings(getResourcesFromDB = function(resource_name, column_names, ...) {
    expect_identical(resource_name, "Condition")
    expect_true("con_code_version" %in% column_names)
    data.table::data.table(
      con_code_version = c("2024", NA_character_),
      con_onsetperiod_start = c(time - 86400, as.POSIXct(NA)), con_recordeddate = time
    )
  }, .package = "MrpCalculation")
  result <- getConditionsFromDB("p")
  expect_identical(result$con_code_version, c("2024", NA_character_))
  expect_equal(result$start_datetime, time + c(-86400, 0))
})
