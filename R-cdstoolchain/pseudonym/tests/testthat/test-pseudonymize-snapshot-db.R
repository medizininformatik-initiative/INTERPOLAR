test_that("getSnapshotSourceViewPlan uses described table sources only", {
  rules <- data.table::data.table(
    SOURCE_TYPE = c("table_description", "snapshot_extension", "table_description"),
    TABLE_OR_RESOURCE = c("patient", "observation", "observation")
  )

  plan <- getSnapshotSourceViewPlan(rules)

  expect_equal(plan$BASE_TABLE_NAME, c("patient", "observation", "patient", "observation"))
  expect_equal(
    plan$MATERIALIZED_TABLE_NAME,
    c("patient", "observation", "patient_last_version", "observation_last_version")
  )
  expect_equal(
    plan$SOURCE_RELATION,
    c("v_patient", "v_observation", "v_patient_last_version", "v_observation_last_version")
  )
  expect_equal(plan$TARGET_VIEW_NAME, plan$SOURCE_RELATION)
})

test_that("getSnapshotSourceViewPlan can limit tables", {
  rules <- data.table::data.table(
    SOURCE_TYPE = "table_description",
    TABLE_OR_RESOURCE = c("patient", "observation", "encounter")
  )

  plan <- getSnapshotSourceViewPlan(rules, tables = c("Observation", "unknown"))

  expect_equal(plan$BASE_TABLE_NAME, c("observation", "observation"))
  expect_equal(plan$MATERIALIZED_TABLE_NAME, c("observation", "observation_last_version"))
  expect_equal(plan$SOURCE_RELATION, c("v_observation", "v_observation_last_version"))
})

test_that("getSnapshotSourceViewPlan maps frontend rule names to frontend DB tables", {
  rules <- data.table::data.table(
    SOURCE = c("frontend", "fhir"),
    SOURCE_TYPE = "table_description",
    TABLE_OR_RESOURCE = c("fall", "Patient")
  )

  plan <- getSnapshotSourceViewPlan(rules)

  expect_equal(plan$BASE_TABLE_NAME, c("fall_fe", "patient", "fall_fe", "patient"))
  expect_equal(plan$RULE_TABLE_NAME, c("fall", "patient", "fall", "patient"))
  expect_equal(
    plan$SOURCE_RELATION,
    c("v_fall_fe", "v_patient", "v_fall_fe_last_version", "v_patient_last_version")
  )
})

test_that("pseudonymizeTableForSnapshot keeps matching snapshot extension columns", {
  rules <- data.table::data.table(
    SOURCE = c("fhir", "snapshot_extensions"),
    SOURCE_TYPE = c("table_description", "snapshot_extension"),
    TABLE_OR_RESOURCE = c("observation", "observation"),
    COLUMN_NAME = c("obs_id", "value_in_reference_unit"),
    PSEUDONYMIZATION_RULE = c("keep", "keep")
  )
  observation <- data.table::data.table(
    obs_id = "obs-1",
    value_in_reference_unit = 1000
  )

  result <- pseudonymizeTableForSnapshot(
    observation,
    rules,
    table_name = "observation",
    rule_source = "fhir",
    input_repo_path = NULL,
    keep_unmatched_columns = FALSE
  )

  expect_equal(names(result$table), c("obs_id", "value_in_reference_unit"))
  expect_equal(result$table$value_in_reference_unit, 1000)
})
