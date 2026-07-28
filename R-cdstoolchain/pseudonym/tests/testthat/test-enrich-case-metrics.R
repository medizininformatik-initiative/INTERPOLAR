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
