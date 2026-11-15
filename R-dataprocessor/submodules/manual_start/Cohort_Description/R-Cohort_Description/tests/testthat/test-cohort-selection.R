test_that("first contact uses clinical start then original registration, never FHIR ID", {
  time <- as.POSIXct("2026-01-01", tz = "UTC")
  contacts <- data.table::data.table(
    patient_id = "p", encounter_id = c("a", "z", "b"),
    ward_name = c("later-registration", "first", "later-contact"), encounter_found = TRUE,
    enc_main_encounter_calculated_ref = "Encounter/case", enc_period_start = time + c(0, 0, 60),
    enc_period_end = time + 86400, input_datetime = time + c(20, 10, 0), pids_per_ward_id = 1:3
  )
  expect_equal(selectFirstCohortContacts(contacts)$ward_name, "first")
  expect_equal(selectFirstCohortContacts(contacts[3:1, ])$ward_name, "first")
  contacts$input_datetime <- time
  contacts$pids_per_ward_id <- c(20L, 10L, 1L)
  expect_equal(selectFirstCohortContacts(contacts)$ward_name, "first")
  contacts$enc_period_start[1] <- NA
  expect_error(selectFirstCohortContacts(contacts), "lack data")
})

test_that("MedA selections distinguish the whole case from its first IP interval", {
  time <- as.POSIXct("2026-01-01", tz = "UTC")
  cases <- data.table::data.table(
    patient_id = "p", case_id = "c",
    hospital_start = time, hospital_end = time + 10 * 86400,
    ip_start = time + 86400, ip_end = time + 3 * 86400
  )
  analyses <- data.table::data.table(
    patient_id = "p", meda_id = letters[1:5],
    meda_dat = time + c(0, 0.5, 1, 3, 5) * 86400,
    medikationsanalyse_complete = c("Incomplete", rep("Complete", 4))
  )
  result <- prepareCohortMedicationAnalyses(cases, analyses)
  expect_equal(result$first_case$meda_id, "b")
  expect_equal(result$first_ip$meda_id, "c")
  expect_equal(nrow(result$all_completed), 4L)
  expect_false(result$all_completed$on_first_ip[result$all_completed$meda_id == "d"])
  analyses$meda_dat[4] <- analyses$meda_dat[3]
  expect_error(prepareCohortMedicationAnalyses(cases, analyses), "earliest timestamp")
})

test_that("FAS duration and phase boundaries use exact timestamps", {
  time <- as.POSIXct("2026-01-01", tz = "UTC")
  wards <- data.table::data.table(
    ward_name = "A", phase_a_start = time,
    phase_b_start = time + 60 * 86400, phase_b_end = time + 90 * 86400
  )
  periods <- buildCohortPeriods(wards)
  cases <- data.table::data.table(
    patient_id = letters[1:4], case_id = letters[1:4],
    ward_name = "A", age = c(18, 18, 18, 17), hospital_start = time,
    hospital_end = time + 10 * 86400, ip_start = time,
    ip_end = time + c(168 * 3600, 168 * 3600 - 1, 86400, 86400),
    has_completed_ip_meda = c(FALSE, FALSE, TRUE, TRUE),
    has_qualifying_manual_mrp = c(FALSE, FALSE, TRUE, TRUE)
  )
  result <- assignCohortPopulations(cases, periods, "UTC")
  expect_equal(result$case_id, letters[1:3])
  expect_equal(result$fas21, c(TRUE, FALSE, TRUE))
  expect_equal(result$fas22, c(FALSE, FALSE, TRUE))
  expect_equal(result$fas3, c(FALSE, FALSE, TRUE))
  cases$hospital_start <- time + 32 * 86400
  cases$ip_start <- time + 60 * 86400
  cases$ip_end <- time + 70 * 86400
  cases$hospital_end <- time + 118 * 86400
  expect_equal(nrow(assignCohortPopulations(cases, periods, "UTC")), 0L)
  cases$hospital_end <- cases$hospital_end - 1
  result <- assignCohortPopulations(cases, periods, "UTC")
  expect_setequal(result$phase, c("CRS", "CRS B"))
})

test_that("BS can use a first-IP MedA without a documented hospital discharge", {
  time <- as.POSIXct("2025-01-01", tz = "UTC")
  cases <- data.table::data.table(
    patient_id = "p", case_id = "c", hospital_start = time,
    hospital_end = as.POSIXct(NA), ip_start = time, ip_end = time + 86400
  )
  analyses <- data.table::data.table(
    patient_id = "p", case_id = "c", meda_id = "m",
    meda_dat = time + 3600, medikationsanalyse_complete = "Complete", redcap_repeat_instance = 1L
  )
  expect_equal(prepareCohortMedicationAnalyses(cases, analyses)$first_ip$meda_id, "m")
})

test_that("CRS limits are site-wide while A/B boundaries remain ward-specific", {
  time <- as.POSIXct("2025-01-01", tz = "UTC")
  wards <- data.table::data.table(
    ward_name = c("A", "B"), phase_a_start = time,
    phase_b_start = time + c(60, 70) * 86400, phase_b_end = time + c(90, 100) * 86400
  )
  periods <- buildCohortPeriods(wards)
  expect_true(all(periods[phase == "CRS"]$period_start == time + 32 * 86400))
  expect_true(all(periods[phase == "CRS"]$period_end == time + 100 * 86400))
  cases <- data.table::data.table(
    patient_id = c("p", "q"), case_id = c("c", "d"),
    ward_name = c("A", "B"), age = 18, hospital_start = time + 50 * 86400,
    hospital_end = time + 99 * 86400, ip_start = time + 65 * 86400,
    ip_end = time + 72 * 86400, has_completed_ip_meda = TRUE, has_qualifying_manual_mrp = FALSE
  )
  result <- assignCohortPopulations(cases, periods, "UTC")
  expect_setequal(result[ward_name == "A"]$phase, c("CRS", "CRS B"))
  expect_setequal(result[ward_name == "B"]$phase, c("CRS", "CRS A"))
})


test_that("invalid first contacts report aggregate causes without exposing identifiers", {
  time <- as.POSIXct("2026-01-01", tz = "UTC")
  contacts <- data.table::data.table(
    patient_id = "private-patient", encounter_id = paste0("private-contact-", 1:5),
    ward_name = "private-ward", encounter_found = c(FALSE, TRUE, TRUE, TRUE, TRUE),
    enc_main_encounter_calculated_ref = c(NA, "", rep("Encounter/private-case", 3)),
    enc_period_start = c(as.POSIXct(NA), rep(time, 4)),
    enc_period_end = time + 86400, input_datetime = c(rep(time, 2), as.POSIXct(NA), time, time),
    pids_per_ward_id = c(1L, 2L, 3L, NA_integer_, 5L)
  )
  # A second coding repeats the first invalid contact; the fifth contact is valid.
  contacts <- data.table::rbindlist(list(contacts, contacts[1]))
  before <- data.table::copy(contacts)
  error <- tryCatch(selectFirstCohortContacts(contacts), error = identity)
  expect_s3_class(error, "error")
  message <- conditionMessage(error)
  expect_match(message, "5 known IP assignment row(s)", fixed = TRUE)
  expect_match(message, "Affected distinct contacts (patient/Encounter): 4; rows without complete contact key: 0", fixed = TRUE)
  expect_match(message, "Affected identifiable cases (patient/case): 1; rows without complete case key: 3", fixed = TRUE)
  expect_match(message, "encounter_not_found=2, missing_case_id=3, missing_contact_start=2, missing_input_datetime=1, missing_pids_per_ward_id=1", fixed = TRUE)
  expect_false(grepl("private-", message, fixed = TRUE))
  expect_equal(contacts, before)
  contacts[1, patient_id := NA_character_]
  message <- conditionMessage(tryCatch(selectFirstCohortContacts(contacts), error = identity))
  expect_match(message, "rows without complete contact key: 1", fixed = TRUE)
})
