test_that("historical requests can retain stopped statuses while MRP defaults stay unchanged", {
  exclusions <- list()
  time <- as.POSIXct("2025-01-01", tz = "UTC")
  local_mocked_bindings(getResourcesFromDB = function(..., status_exclusion) {
    exclusions[[length(exclusions) + 1L]] <<- status_exclusion
    data.table::data.table(
      medicationrequest_id = 1L, medreq_id = "request",
      medreq_medicationreference_ref = "Medication/medication", medreq_authoredon = time,
      medreq_doseinstruc_timing_event = time,
      medreq_doseinstruc_timing_repeat_boundsperiod_start = time,
      medreq_doseinstruc_timing_repeat_boundsperiod_end = as.POSIXct(NA)
    )
  }, .package = "MrpCalculation")
  usual <- getMedicationRequestsFromDB("p")
  historical <- getMedicationRequestsFromDB("p", status_exclusion = c("cancelled", "entered-in-error"))
  expect_equal(exclusions[[1]], c("on-hold", "cancelled", "entered-in-error", "stopped"))
  expect_equal(exclusions[[2]], c("cancelled", "entered-in-error"))
  expect_equal(usual, historical)
  expect_equal(historical$start_datetime, time)
})
