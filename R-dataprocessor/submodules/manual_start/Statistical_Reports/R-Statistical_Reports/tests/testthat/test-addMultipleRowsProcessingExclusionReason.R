test_that("addMultipleRowsProcessingExclusionReason flags multiple rows correctly", {
  df <- data.frame(
    patient_id = c(1, 1, 2, 3, 3, 3),
    value = c(10, 12, 5, 7, 8, 9),
    processing_exclusion_reason = NA_character_
  )

  df_flagged <- addMultipleRowsProcessingExclusionReason(
    data = df,
    grouping_vars = c("patient_id"),
    processing_exclusion_reason_name = "Multiple entries for patient"
  )

  # Patient 1 has 2 rows, should be flagged
  expect_equal(df_flagged$processing_exclusion_reason[df_flagged$patient_id == 1],
               rep("Multiple entries for patient", 2))

  # Patient 2 has 1 row, should remain NA
  expect_equal(df_flagged$processing_exclusion_reason[df_flagged$patient_id == 2],
               NA_character_)

  # Patient 3 has 3 rows, should be flagged
  expect_equal(df_flagged$processing_exclusion_reason[df_flagged$patient_id == 3],
               rep("Multiple entries for patient", 3))
})
