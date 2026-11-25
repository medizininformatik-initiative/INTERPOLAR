test_that("subsequent IP stays include returns to the same ward without double counting", {
  time <- as.POSIXct("2026-01-01", tz = "UTC")
  cases <- data.table::data.table(
    patient_id = "p", case_id = "c", hospital_start = time,
    hospital_end = time + 10 * 86400, ip_start = time + 86400,
    ip_end = time + 3 * 86400
  )
  analyses <- data.table::data.table(
    patient_id = "p", meda_id = letters[1:7],
    meda_dat = time + c(0, 1, 3, 4, 5, 6, 7) * 86400,
    medikationsanalyse_complete = "Complete"
  )
  contacts <- data.table::data.table(
    patient_id = "p", case_id = "c", ward_name = c("A", "A", "B", "B"),
    enc_period_start = time + c(1, 4, 6, 6) * 86400,
    enc_period_end = time + c(3, 5, 7, 7) * 86400
  )
  completed <- prepareCohortMedicationAnalyses(cases, analyses)$all_completed
  result <- classifyCohortMedicationAnalyses(completed, contacts)
  expect_equal(result$meda_location, c(
    "before_first_ip", "first_ip", "after_non_ip", "after_subsequent_ip",
    "after_non_ip", "after_subsequent_ip", "after_non_ip"
  ))
  expect_equal(nrow(result), nrow(completed))
  expect_false("meda_location" %in% names(completed))
  contacts$case_id <- "another-case"
  expect_false(any(classifyCohortMedicationAnalyses(completed, contacts)$meda_location ==
    "after_subsequent_ip"))
  expect_equal(nrow(classifyCohortMedicationAnalyses(completed[0], contacts)), 0L)
})


test_that("tied completed analyses use creation order rather than hashed IDs", {
  time <- as.POSIXct("2026-01-01", tz = "UTC")
  cases <- data.table::data.table(
    patient_id = "p", case_id = "c", hospital_start = time,
    hospital_end = time + 86400, ip_start = time, ip_end = time + 86400
  )
  analyses <- data.table::data.table(
    patient_id = "p", case_id = "c", meda_id = c("a", "z"),
    meda_dat = time, medikationsanalyse_complete = "Complete", redcap_repeat_instance = c(10L, 2L)
  )
  selected <- prepareCohortMedicationAnalyses(cases, analyses)
  expect_equal(selected$first_ip$meda_id, "z")
  expect_equal(selected$first_case$meda_id, "z")
  expect_equal(prepareCohortMedicationAnalyses(cases, analyses[2:1])$first_ip$meda_id, "z")
  analyses$case_id <- "parallel-case"
  expect_equal(nrow(prepareCohortMedicationAnalyses(cases, analyses)$all_completed), 0L)
})
