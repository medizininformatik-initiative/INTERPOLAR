test_that("ICD version resolution respects origin admission and outpatient treatment year", {
  origins <- data.table::data.table(
    enc_id = c("in", "out", "wrong"),
    enc_patient_ref = c("Patient/p", "Patient/p", "Patient/other"),
    enc_class_code = c("IMP", "AMB", "IMP"),
    enc_period_start = as.POSIXct("2023-12-31", tz = "UTC")
  )
  procedures <- data.table::data.table(
    con_code_code = "A00.0",
    con_code_version = c("2025", NA, NA, NA, "bad", NA), con_patient_ref = "Patient/p",
    con_encounter_calculated_ref = paste0("Encounter/", c("in", "in", "out", "wrong", "in", "absent")),
    start_datetime = as.POSIXct("2024-01-02", tz = "UTC")
  )
  result <- prepareCohortCoding(procedures, origins, etlutils::loadICDCatalogues(), "Europe/Berlin", "con", "icd")
  expect_equal(result$icd_requested_year, c(2025L, 2023L, 2024L, NA, NA, NA))
  expect_equal(result$icd_year_source, c(
    "documented", "origin_admission", "event_date",
    "unresolved", "invalid_documented_version", "unresolved"
  ))
  expect_equal(result$icd_terminal, c(TRUE, TRUE, TRUE, NA, NA, NA))
})

test_that("ICD catalogue approximation is explicit and does not stop the analysis", {
  origins <- data.table::data.table(
    enc_id = character(), enc_patient_ref = character(),
    enc_class_code = character(), enc_period_start = as.POSIXct(character(), tz = "UTC")
  )
  procedures <- data.table::data.table(
    con_code_code = "A00.0",
    con_code_version = c("2021", "2022", "2027", "2030"), con_patient_ref = "Patient/p",
    con_encounter_calculated_ref = NA_character_, start_datetime = as.POSIXct("2024-01-02", tz = "UTC")
  )
  expect_warning(
    result <- prepareCohortCoding(procedures, origins, etlutils::loadICDCatalogues(), "UTC", "con", "icd"),
    "4 ICD coding"
  )
  expect_equal(result$icd_catalogue_year, c(2023L, 2023L, 2026L, 2026L))
  expect_true(all(result$icd_year_approximated))
  expect_true(all(result$icd_terminal))
})

test_that("full-length diagnoses use annual leaves while other ICD metrics retain their scope", {
  cases <- cohortFixture()$cases
  time <- cases$hospital_start[1]
  diagnoses <- data.table::data.table(
    patient_id = c("p", "q"), start_datetime = time,
    code = c("E11.9", "Z00.0"), icd_terminal = c(FALSE, NA)
  )
  empty <- data.table::data.table(patient_id = character(), start_datetime = time[FALSE], code = character())
  labs <- data.table::copy(empty)
  labs[, `:=`(
    relevant = logical(), unit_ok = logical(), numeric_ok = logical(),
    abnormal = logical(), normal = logical(), egfr = logical(), value_reference = numeric()
  )]
  ops <- data.table::copy(empty)
  ops[, `:=`(proc_code_code = character(), ops_terminal = logical())]
  result <- calculateCohortCodeFeatures(cases, diagnoses, empty, labs, ops)
  expect_false(result[patient_id == "p"]$m65)
  expect_equal(result[patient_id == "p"]$m67, 0)
  expect_true(result[patient_id == "p"]$m69)
  expect_equal(result[patient_id == "p"]$m71, 1)
  expect_false(is.na(result[patient_id == "p"]$m76))
  expect_true(is.na(result[patient_id == "q"]$m65))
  expect_true(result[patient_id == "q"]$m69)
  expect_true(is.na(result[patient_id == "missing"]$m65))
})
