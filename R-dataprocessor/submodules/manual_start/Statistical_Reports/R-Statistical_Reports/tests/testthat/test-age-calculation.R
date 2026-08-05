test_that("calculateAge prefers an existing precomputed age column", {
  input <- data.frame(
    pat_birthdate = c("2008-08", "1980-05", "1990-01"),
    main_enc_period_start = as.Date(c("2026-08-01", "2026-08-01", "2026-08-01")),
    enc_age_at_admission = c(17L, 46L, NA_integer_),
    processing_exclusion_reason = NA_character_
  )

  result <- suppressWarnings(calculateAge(
    input,
    precalculated_age_column = "enc_age_at_admission"
  ))

  expect_equal(result$age_at_hospitalization, c(17L, 46L, NA_integer_))
})

test_that("calculateAge falls back to birthdate calculation when age column is absent", {
  input <- data.frame(
    pat_birthdate = as.Date(c("1980-05-17", "1975-12-01")),
    main_enc_period_start = as.Date(c("2026-08-01", "2026-08-01")),
    processing_exclusion_reason = NA_character_
  )

  result <- calculateAge(
    input,
    precalculated_age_column = "enc_age_at_admission"
  )

  expect_equal(result$age_at_hospitalization, c(46, 50))
})

test_that("addMainEncPeriodStart propagates the main encounter age", {
  input <- data.frame(
    enc_id = c("main", "child"),
    main_enc_id = c("main", "main"),
    enc_period_start = as.POSIXct(c("2026-01-01", "2026-03-01"), tz = "UTC"),
    enc_period_end = as.POSIXct(c("2026-04-01", "2026-03-02"), tz = "UTC"),
    enc_age_at_admission = c(17L, 18L),
    enc_class_code = "IMP",
    enc_type_code_Kontaktebene = c("einrichtungskontakt", "versorgungsstellenkontakt"),
    processing_exclusion_reason = NA_character_
  )

  result <- addMainEncPeriodStart(input)

  expect_equal(result$main_enc_age_at_admission, c(17L, 17L))
})
