test_that("OPS version resolution respects origin admission and outpatient treatment year", {
  origins <- data.table::data.table(
    enc_id = c("in", "out", "wrong"),
    enc_patient_ref = c("Patient/p", "Patient/p", "Patient/other"),
    enc_class_code = c("IMP", "AMB", "IMP"),
    enc_period_start = as.POSIXct("2023-12-31", tz = "UTC")
  )
  procedures <- data.table::data.table(
    proc_code_code = "8-016",
    proc_code_version = c("2025", NA, NA, NA, "bad", NA), proc_patient_ref = "Patient/p",
    proc_encounter_calculated_ref = paste0("Encounter/", c("in", "in", "out", "wrong", "in", "absent")),
    start_datetime = as.POSIXct("2024-01-02", tz = "UTC")
  )
  result <- prepareCohortOPS(procedures, origins, etlutils::loadOPSCatalogues(), "Europe/Berlin")
  expect_equal(result$ops_requested_year, c(2025L, 2023L, 2024L, NA, NA, NA))
  expect_equal(result$ops_year_source, c(
    "documented", "origin_admission", "procedure_date",
    "unresolved", "invalid_documented_version", "unresolved"
  ))
  expect_equal(result$ops_terminal, c(TRUE, TRUE, TRUE, NA, NA, NA))
})

test_that("OPS catalogue approximation is explicit and does not stop the analysis", {
  origins <- data.table::data.table(
    enc_id = character(), enc_patient_ref = character(),
    enc_class_code = character(), enc_period_start = as.POSIXct(character(), tz = "UTC")
  )
  procedures <- data.table::data.table(
    proc_code_code = "8-016",
    proc_code_version = c("2021", "2022", "2027", "2030"), proc_patient_ref = "Patient/p",
    proc_encounter_calculated_ref = NA_character_, start_datetime = as.POSIXct("2024-01-02", tz = "UTC")
  )
  expect_warning(
    result <- prepareCohortOPS(procedures, origins, etlutils::loadOPSCatalogues(), "UTC"),
    "4 OPS coding"
  )
  expect_equal(result$ops_catalogue_year, c(2023L, 2023L, 2026L, 2026L))
  expect_true(all(result$ops_year_approximated))
  expect_true(all(result$ops_terminal))
})
