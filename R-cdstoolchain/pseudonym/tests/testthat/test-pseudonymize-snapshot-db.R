test_that("getSnapshotSourceViewPlan uses described table sources only", {
  rules <- data.table::data.table(
    SOURCE_TYPE = c("table_description", "snapshot_extension", "table_description"),
    TABLE_OR_RESOURCE = c("patient", "observation", "observation")
  )

  plan <- getSnapshotSourceViewPlan(rules)

  expect_equal(plan$TABLE_NAME, c("patient", "observation"))
  expect_equal(plan$SOURCE_RELATION, c("v_patient_last_version", "v_observation_last_version"))
})

test_that("getSnapshotSourceViewPlan can limit tables", {
  rules <- data.table::data.table(
    SOURCE_TYPE = "table_description",
    TABLE_OR_RESOURCE = c("patient", "observation", "encounter")
  )

  plan <- getSnapshotSourceViewPlan(rules, tables = c("Observation", "unknown"))

  expect_equal(plan$TABLE_NAME, "observation")
  expect_equal(plan$SOURCE_RELATION, "v_observation_last_version")
})
