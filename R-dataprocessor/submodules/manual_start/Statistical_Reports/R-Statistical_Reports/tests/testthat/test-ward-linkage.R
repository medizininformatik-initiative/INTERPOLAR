test_that("MRP references never broadcast to other wards for the same record", {
  ward_rows <- tibble::tibble(
    record_id = "p1",
    meda_id = c(NA_character_, "meda1"),
    fall_fhir_main_enc_id = c("case1", "case2"),
    enc_id = c("enc1", "enc2"),
    fall_station = c("A", "B"),
    multiple_medas_per_patient = FALSE,
    processing_exclusion_reason = NA_character_
  )
  source <- tibble::tibble(
    record_id = "p1",
    mrp_meda_id = c("meda1", "missing", NA_character_),
    mrp_id = c("linked", "unmatched", "no-reference")
  )
  result <- addMRPDokuData(ward_rows, source)
  linked <- dplyr::filter(result, mrp_id == "linked")
  unresolved <- dplyr::filter(result, mrp_id %in% c("unmatched", "no-reference"))

  expect_identical(linked$fall_station, "B")
  expect_setequal(unresolved$mrp_id, c("unmatched", "no-reference"))
  expect_equal(nrow(unresolved), 2L)
  expect_true(all(is.na(unresolved$fall_station)))
  expect_true(all(grepl("linkage_issues", unresolved$processing_exclusion_reason)))
})

test_that("medication analyses require one distinct ward contact", {
  ward_rows <- tibble::tibble(
    record_id = "p1",
    pat_id = "patient1",
    fall_fhir_main_enc_id = "case1",
    fall_id_cis = "cis1",
    fall_station = c("A", "B"),
    enc_id = c("enc1", "enc2"),
    enc_period_start = as.POSIXct(c("2026-01-01", "2026-01-02"), tz = "UTC"),
    curated_enc_period_end = as.POSIXct(c("2026-01-03", "2026-01-04"), tz = "UTC"),
    multiple_main_encounters_per_patient = FALSE,
    multiple_wards_per_main_encounter = TRUE,
    processing_exclusion_reason = NA_character_
  )
  medas <- tibble::tibble(
    record_id = "p1",
    fall_meda_id = "cis1",
    meda_id = c("unique", "overlap", "unmatched"),
    meda_dat = as.POSIXct(c(
      "2026-01-01 12:00:00", "2026-01-02 12:00:00",
      "2026-01-05 12:00:00"
    ), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
  )
  result <- addMedaData(ward_rows, medas)
  linked <- dplyr::filter(result, meda_id == "unique")
  ambiguous <- dplyr::filter(result, meda_id == "overlap")
  unmatched <- dplyr::filter(result, meda_id == "unmatched")

  expect_identical(linked$fall_station, "A")
  expect_identical(ambiguous$fall_station, NA_character_)
  expect_match(ambiguous$processing_exclusion_reason, "ambiguous_meda_ward_link")
  expect_identical(unmatched$fall_station, NA_character_)
  expect_match(unmatched$processing_exclusion_reason, "no_matching_ward_stay_period_information")
  expect_setequal(result$enc_id, c("enc1", "enc2", NA_character_))
})

test_that("retrospective evaluations retain unresolved and ambiguous references once", {
  ward_rows <- tibble::tibble(
    record_id = "p1",
    meda_id = c("meda1", "meda2", "meda2"),
    meda_dat = as.Date("2026-01-01"),
    mrp_id = c("mrp1", "mrp2", "mrp3"),
    fall_fhir_main_enc_id = "case1",
    enc_id = c("enc1", "enc1", "enc2"),
    fall_station = c("A", "A", "B"),
    processing_exclusion_reason = NA_character_
  )
  evaluations <- tibble::tibble(
    record_id = "p1",
    ret_id = c("exact", "fallback", "ambiguous", "unmatched"),
    ret_meda_id = c("meda1", "meda1", "meda2", "missing"),
    ret_mrp_zuordnung1 = c("mrp1", NA_character_, NA_character_, NA_character_)
  )
  result <- addRetrolektiveMRPBewertungData(ward_rows, evaluations)
  exact <- dplyr::filter(result, ret_id == "exact")
  fallback <- dplyr::filter(result, ret_id == "fallback")
  ambiguous <- dplyr::filter(result, ret_id == "ambiguous")
  unmatched <- dplyr::filter(result, ret_id == "unmatched")

  expect_identical(exact$fall_station, "A")
  expect_identical(fallback$fall_station, "A")
  expect_identical(ambiguous$fall_station, NA_character_)
  expect_match(ambiguous$processing_exclusion_reason, "ambiguous_ret_ward_link")
  expect_identical(unmatched$fall_station, NA_character_)
  expect_match(unmatched$processing_exclusion_reason, "unresolved_ret_meda_id")
  expect_setequal(stats::na.omit(result$mrp_id), ward_rows$mrp_id)
})

test_that("MRP links to distinct contacts on the same ward are flagged", {
  ward_rows <- tibble::tibble(
    record_id = "p1",
    meda_id = "meda1",
    fall_fhir_main_enc_id = "case1",
    enc_id = c("enc1", "enc2"),
    fall_station = "A",
    processing_exclusion_reason = NA_character_
  )
  source <- tibble::tibble(record_id = "p1", mrp_meda_id = "meda1", mrp_id = "mrp1")
  result <- addMRPDokuData(ward_rows, source)
  unresolved <- dplyr::filter(result, mrp_id == "mrp1")

  expect_identical(unresolved$fall_station, NA_character_)
  expect_match(unresolved$processing_exclusion_reason, "ambiguous_mrp_ward_link")
  expect_setequal(stats::na.omit(result$enc_id), ward_rows$enc_id)
})
