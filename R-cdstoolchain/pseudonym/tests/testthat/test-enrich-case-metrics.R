test_that("enrichSnapshotFallChunk adds age and BMI", {
  fall_fe <- data.table::data.table(
    fall_id = "fall-1",
    fall_aufn_dat = as.POSIXct("2024-06-14 10:00:00", tz = "UTC"),
    fall_gewicht_aktuell = 80,
    fall_gewicht_aktl_einheit = "kg",
    fall_groesse = 180,
    fall_groesse_einheit = "cm"
  )

  result <- enrichSnapshotFallChunk(
    fall_fe,
    birthdates = as.Date("1980-06-15")
  )

  expect_equal(result$fall_age_at_admission, 43L)
  expect_equal(result$fall_bmi, 80 / 1.8^2)
  expect_equal(tail(names(result), 2), c("fall_age_at_admission", "fall_bmi"))
})

test_that("enrichSnapshotEncounterChunk adds age", {
  encounter <- data.table::data.table(
    enc_id = "enc-1",
    enc_period_start = as.POSIXct("2020-01-01 00:00:00", tz = "UTC")
  )

  result <- enrichSnapshotEncounterChunk(
    encounter,
    birthdates = as.Date("1970-01-02")
  )

  expect_equal(result$enc_age_at_admission, 49L)
  expect_equal(tail(names(result), 1), "enc_age_at_admission")
})

test_that("case metric enrichment remains optional when source columns are missing", {
  fall_result <- enrichSnapshotFallChunk(
    data.table::data.table(fall_id = "fall-1"),
    source_columns = "fall_id"
  )
  encounter_result <- enrichSnapshotEncounterChunk(
    data.table::data.table(enc_id = "enc-1"),
    source_columns = "enc_id"
  )

  expect_true(is.na(fall_result$fall_age_at_admission))
  expect_true(is.na(fall_result$fall_bmi))
  expect_true(is.na(encounter_result$enc_age_at_admission))
})

test_that("age calculation accepts 1910-01-01 and rejects earlier birthdates", {
  reference_dates <- as.Date(c("2026-01-01", "2026-01-01"))
  birth_dates <- as.Date(c("1910-01-01", "1909-12-31"))

  expect_equal(
    calculateCompletedYears(reference_dates, birth_dates),
    c(116L, NA_integer_)
  )
})

test_that("age review contains identifiers and every calculation problem", {
  encounter <- data.table::data.table(
    enc_id = paste0("enc-", 1:6),
    enc_patient_ref = paste0("Patient/pat-", 1:6),
    enc_period_start = as.Date(c(
      "2020-01-01",
      "2020-01-01",
      "2020-01-01",
      NA,
      "1979-01-01",
      "2020-01-01"
    ))
  )
  birthdates <- as.Date(c(
    NA,
    NA,
    "1900-01-01",
    "1980-01-01",
    "1980-01-01",
    "1980-01-01"
  ))
  matched_patient_keys <- c(NA, paste0("pat-", 2:6))

  report <- getAgeCalculationReview(
    encounter,
    "encounter",
    "encounter",
    birthdates,
    matched_patient_keys
  )

  expect_equal(
    report$ISSUE_TYPE,
    c(
      "patient_not_found",
      "missing_birthdate",
      "birthdate_before_1910_01_01",
      "missing_reference_date",
      "reference_date_before_birthdate"
    )
  )
  expect_equal(report$FHIR_PATIENT_ID, paste0("pat-", 1:5))
  expect_equal(report$FHIR_ENCOUNTER_ID, paste0("enc-", 1:5))
  expect_equal(report$RAW_CALCULATED_AGE[5], -1L)
})

test_that("fall age review contains REDCap and FHIR identifiers", {
  fall <- data.table::data.table(
    record_id = "redcap-1",
    fall_pat_id = "patient-1",
    fall_fhir_enc_id = "encounter-1",
    fall_id = "case-1",
    fall_aufn_dat = as.Date("2020-01-01")
  )

  report <- getAgeCalculationReview(
    fall,
    "fall_fe",
    "fall_fe",
    as.Date("1900-01-01"),
    "redcap-1"
  )

  expect_equal(report$REDCAP_RECORD_ID, "redcap-1")
  expect_equal(report$FHIR_PATIENT_ID, "patient-1")
  expect_equal(report$FHIR_ENCOUNTER_ID, "encounter-1")
  expect_equal(report$LOCAL_CASE_ID, "case-1")
})

test_that("bounded age review keeps exact counts and bounded examples", {
  report <- data.table::data.table(
    TABLE_NAME = c("encounter", "encounter"),
    ISSUE_TYPE = c("patient_not_found", "patient_not_found"),
    REDCAP_RECORD_ID = NA_character_,
    FHIR_PATIENT_ID = c("pat-1", "pat-2"),
    FHIR_ENCOUNTER_ID = c("enc-1", "enc-2"),
    LOCAL_CASE_ID = NA_character_,
    PATIENT_LOOKUP_KEY = NA_character_,
    BIRTHDATE = as.Date(NA),
    REFERENCE_DATE = as.Date("2020-01-01"),
    RAW_CALCULATED_AGE = NA_integer_,
    N = 1L
  )
  context <- newBoundedAgeCalculationReview(detail_limit = 1L)

  recordBoundedAgeCalculationReview(context, report)
  recordBoundedAgeCalculationReview(context, report)
  result <- finalizeBoundedAgeCalculationReview(context)

  expect_equal(result$age_issue_summary$AFFECTED_ROWS, 4)
  expect_equal(nrow(result$age_issue_examples), 1L)
})
