cohortFixture <- function() {
  time <- as.POSIXct("2025-01-01", tz = "UTC")
  cases <- data.table::data.table(
    patient_id = c("p", "q", "missing"), case_id = c("c", "d", "e"),
    ward_name = "A", age = c(40, 65, 30), gender = c("male", "female", NA_character_),
    hospital_start = time, hospital_end = time + 10 * 86400,
    ip_start = time + 86400, ip_end = time + 8 * 86400,
    m15 = 1, m17 = 2, m18 = 1, m43 = 10, m62 = 7, m360 = c(2L, 0L, 0L)
  )
  contacts <- data.table::data.table(
    patient_id = "p", case_id = "c",
    enc_period_start = time + c(1, 9) * 86400, enc_period_end = time + c(8, 10) * 86400
  )
  analyses <- data.table::data.table(
    patient_id = "p", meda_id = c("earlier-incomplete", "first", "later"),
    meda_dat = time + c(0, 2, 9) * 86400, medikationsanalyse_complete = c("Incomplete", "Complete", "Complete")
  )
  validations <- data.table::data.table(
    patient_id = "p", meda_id = "first", mrp_id = "manual",
    outcome = "Problem nicht gelöst"
  )
  cases <- calculateCohortMedAFeatures(cases, analyses, contacts, validations)
  diagnoses <- data.table::data.table(
    patient_id = c("p", "p", "q"),
    start_datetime = time + c(0, 10, 1) * 86400, code = c("E11.90", "E11.90", "Z00.0"), icd_terminal = TRUE
  )
  medications <- data.table::data.table(
    patient_id = "p", start_datetime = time + c(1, 2, 3) * 86400,
    code = c("A10BA02", "A10BA02", "B01AC06")
  )
  observations <- data.table::data.table(
    patient_id = "p", start_datetime = time + c(1, 1, 8) * 86400,
    code = c("62238-1", "62238-1", "62238-1"), relevant = TRUE, unit_ok = TRUE,
    numeric_ok = TRUE, abnormal = c(TRUE, FALSE, FALSE), normal = c(FALSE, TRUE, TRUE),
    egfr = TRUE, value_reference = c(89, 130, 131)
  )
  procedures <- data.table::data.table(
    patient_id = "p", start_datetime = time + c(1, 2, 3) * 86400,
    proc_code_code = c("8-017", "8-017.1", "8-853"), ops_terminal = c(FALSE, TRUE, FALSE)
  )
  list(
    cases = calculateCohortCodeFeatures(cases, diagnoses, medications, observations, procedures),
    wards = data.table::data.table(
      ward_name = "A", phase_a_start = time,
      phase_b_start = time + 60 * 86400, phase_b_end = time + 90 * 86400,
      ward_type = "internistic", department = "0100 Innere Medizin"
    )
  )
}
