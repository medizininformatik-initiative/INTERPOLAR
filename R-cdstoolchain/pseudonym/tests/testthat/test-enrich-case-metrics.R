test_that("enrichSnapshotCaseMetricTables adds fall age and BMI", {
  tables <- list(
    patient_fe = data.table::data.table(
      record_id = "rec-1",
      pat_id = "pat-1",
      pat_gebdat = as.Date("1980-06-15")
    ),
    fall_fe = data.table::data.table(
      fall_id = "fall-1",
      patient_id_fk = "rec-1",
      fall_pat_id = "pat-1",
      fall_aufn_dat = as.POSIXct("2024-06-14 10:00:00", tz = "UTC"),
      fall_gewicht_aktuell = 80,
      fall_gewicht_aktl_einheit = "kg",
      fall_groesse = 180,
      fall_groesse_einheit = "cm"
    )
  )

  result <- enrichSnapshotCaseMetricTables(tables)

  expect_equal(result$fall_fe$fall_age_at_admission, 43L)
  expect_equal(result$fall_fe$fall_bmi, 80 / 1.8^2)
  expect_equal(
    tail(names(result$fall_fe), 2),
    c("fall_age_at_admission", "fall_bmi")
  )
})

test_that("enrichSnapshotCaseMetricTables adds encounter age for normal and last-version tables", {
  patient <- data.table::data.table(
    pat_id = "pat-1",
    pat_birthdate = as.Date("1970-01-02")
  )
  encounter <- data.table::data.table(
    enc_id = "enc-1",
    enc_patient_ref = "Patient/pat-1",
    enc_period_start = as.POSIXct("2020-01-01 00:00:00", tz = "UTC")
  )
  tables <- list(
    patient = patient,
    patient_last_version = patient,
    encounter = encounter,
    encounter_last_version = encounter
  )

  result <- enrichSnapshotCaseMetricTables(tables)

  expect_equal(result$encounter$enc_age_at_admission, 49L)
  expect_equal(result$encounter_last_version$enc_age_at_admission, 49L)
  expect_equal(tail(names(result$encounter), 1), "enc_age_at_admission")
  expect_equal(tail(names(result$encounter_last_version), 1), "enc_age_at_admission")
})

test_that("enrichSnapshotCaseMetricTables keeps empty metrics when inputs are missing", {
  tables <- list(
    fall_fe = data.table::data.table(fall_id = "fall-1"),
    encounter = data.table::data.table(enc_id = "enc-1")
  )

  result <- enrichSnapshotCaseMetricTables(tables)

  expect_true("fall_age_at_admission" %in% names(result$fall_fe))
  expect_true("fall_bmi" %in% names(result$fall_fe))
  expect_true(is.na(result$fall_fe$fall_age_at_admission))
  expect_true(is.na(result$fall_fe$fall_bmi))
  expect_true("enc_age_at_admission" %in% names(result$encounter))
  expect_true(is.na(result$encounter$enc_age_at_admission))
})
