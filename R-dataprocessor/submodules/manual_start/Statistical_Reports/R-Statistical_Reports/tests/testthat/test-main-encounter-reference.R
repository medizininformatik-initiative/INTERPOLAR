source(testthat::test_path("..", "..", "R", "00_help-functions.R"), local = TRUE)
source(testthat::test_path("..", "..", "R", "02_mergers_and_calculations.R"), local = TRUE)

test_that("main encounter IDs follow calculated references and remove duplicate rows", {
  encounters <- tibble::tibble(
    enc_id = c("main-1", "ward-1", "main-2", "ward-2", "ward-2"),
    enc_identifier_value = c(NA, "", "shared", "shared", "shared"),
    enc_partof_calculated_ref = "Encounter/wrong-parent",
    enc_main_encounter_calculated_ref = c(
      "Encounter/main-1", "Encounter/main-1", "Encounter/main-2",
      "Encounter/main-2", "Encounter/main-2"
    ),
    processing_exclusion_reason = NA_character_
  )
  expect_no_warning(result <- addMainEncId(encounters))
  expect_equal(result$main_enc_id, c("main-1", "main-1", "main-2", "main-2"))
  expect_identical(result[, names(encounters)], encounters[1:4, ])
  expect_false("main_enc_id_initial_try" %in% names(result))
  expect_identical(
    addMainEncId(dplyr::select(encounters, -enc_identifier_value, -enc_partof_calculated_ref))$main_enc_id,
    result$main_enc_id
  )
})

test_that("missing and invalid references are flagged without inferring a main encounter", {
  encounters <- tibble::tibble(
    enc_id = paste0("enc-", 1:7),
    enc_main_encounter_calculated_ref = c(NA, "", " ", "invalid", "Encounter/", "Patient/p1", "Encounter/main-1"),
    enc_identifier_value = "shared-case",
    enc_partof_calculated_ref = "Encounter/main-1",
    processing_exclusion_reason = "existing-reason"
  )
  invisible(capture.output(expect_warning(
    result <- addMainEncId(encounters), "Some encounters have no calculated main_enc_id"
  )))
  expect_true(all(is.na(result$main_enc_id[1:6])))
  expect_equal(result$main_enc_id[7], "main-1")
  expect_true(all(grepl("encounter_without_main_enc_id", result$processing_exclusion_reason[1:6])))
  expect_true(all(grepl("existing-reason", result$processing_exclusion_reason)))
  expect_equal(result$processing_exclusion_reason[7], "existing-reason")
  expect_equal(nrow(result), nrow(encounters))
  expect_equal(nrow(addMainEncId(encounters[0, ])), 0L)
})
