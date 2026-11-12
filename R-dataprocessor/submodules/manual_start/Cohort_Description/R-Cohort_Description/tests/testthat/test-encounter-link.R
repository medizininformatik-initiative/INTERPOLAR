test_that("contact linking preserves assignments, codings and input tables", {
  assignments <- data.table::data.table(
    ward_name = c("A", "B", "C", "D"),
    patient_id = c("p1", "p1", "wrong-patient", "p2"),
    encounter_id = c("e1", "e1", "e2", "absent")
  )
  encounters <- data.table::data.table(
    enc_id = c("e1", "e1", "e1", "e2", "unmapped"),
    enc_patient_ref = c(rep("Patient/p1", 4), "Patient/p2"),
    enc_main_encounter_calculated_ref = "Encounter/main",
    enc_period_start = as.POSIXct("2026-01-01", tz = "UTC"),
    enc_period_end = as.POSIXct("2026-01-10", tz = "UTC"),
    enc_type_system = "system",
    enc_type_code = c("ward", "ward", "other-coding", "ward", "ward")
  )
  original_assignments <- data.table::copy(assignments)
  original_encounters <- data.table::copy(encounters)
  expect_warning(result <- linkCohortStationContacts(assignments, encounters), "2 known station contact")
  expect_equal(nrow(result), 6L)
  expect_equal(sum(result$encounter_found), 4L)
  expect_false("unmapped" %in% result$encounter_id)
  expect_true(all(is.na(result[encounter_found == FALSE]$enc_period_start)))
  expect_setequal(result$ward_name, assignments$ward_name)
  expect_equal(assignments, original_assignments)
  expect_equal(encounters, original_encounters)
})

test_that("missing Encounter data keeps the known contacts visible", {
  assignments <- data.table::data.table(ward_name = "A", patient_id = "p1", encounter_id = "e1")
  expect_warning(result <- linkCohortStationContacts(assignments, data.table::data.table()), "could not be linked")
  expect_equal(nrow(result), 1L)
  expect_false(result$encounter_found)
})

test_that("missing starts are reported without dropping the contact", {
  assignments <- data.table::data.table(ward_name = "A", patient_id = "p1", encounter_id = "e1")
  encounters <- data.table::data.table(
    enc_id = "e1", enc_patient_ref = "Patient/p1",
    enc_period_start = as.POSIXct(NA_character_, tz = "UTC")
  )
  expect_warning(result <- linkCohortStationContacts(assignments, encounters), "missing start timestamps")
  expect_true(result$encounter_found)
  expect_equal(nrow(result), 1L)
})

test_that("missing patient keys never create a match", {
  assignments <- data.table::data.table(ward_name = "A", patient_id = NA_character_, encounter_id = "e1")
  encounters <- data.table::data.table(enc_id = "e1", enc_patient_ref = NA_character_)
  expect_warning(result <- linkCohortStationContacts(assignments, encounters), "could not be linked")
  expect_false(result$encounter_found)
  expect_equal(nrow(result), 1L)
})
