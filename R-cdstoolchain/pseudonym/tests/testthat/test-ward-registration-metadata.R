test_that("snapshot pseudonymization retains original ward registration metadata", {
  registered <- as.POSIXct("2026-01-02 10:00:00", tz = "UTC")
  source <- data.table::data.table(
    ward_name = c("B", "A", "C"),
    patient_id = rep("patient-1", 3),
    encounter_id = c("enc-z", "enc-a", "enc-m"),
    input_datetime = registered + c(0, 60, 0),
    input_processing_nr = c(7L, 8L, 7L),
    pids_per_ward_id = c(102L, 103L, 101L)
  )
  rules <- data.table::data.table(
    TABLE_NAME = "pids_per_ward",
    COLUMN_NAME = c("ward_name", "patient_id", "encounter_id"),
    PSEUDONYMIZATION_RULE = c("keep", "cryptoHash", "cryptoHash")
  )
  result <- pseudonymizeTableForSnapshot(
    as.data.frame(source)[c(2, 3, 1), ], rules, "pids_per_ward",
    input_repo_path = newPseudonymTestInputRepoPath()
  )$table

  metadata <- c("ward_name", "input_datetime", "input_processing_nr", "pids_per_ward_id")
  expect_equal(
    as.data.frame(result)[, metadata],
    as.data.frame(source)[c(2, 3, 1), metadata],
    ignore_attr = TRUE
  )
  expect_false(any(result$patient_id %in% source$patient_id))
  expect_false(any(result$encounter_id %in% source$encounter_id))
  # Registration order must not depend on hashed identifiers or fetch order.
  original_order <- order(source$input_datetime, source$pids_per_ward_id)
  snapshot_order <- order(result$input_datetime, result$pids_per_ward_id)
  expect_identical(result$ward_name[snapshot_order], source$ward_name[original_order])
  expect_identical(result$ward_name[snapshot_order][1], "C")
})
