test_that("indirect rows keep source ownership and shared medications follow retained events", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  schema <- basename(tempfile("bc_selection_"))
  snapshotEnsureSchema(connection, schema)
  on.exit(DBI::dbExecute(connection, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(connection, schema), " CASCADE")), add = TRUE)
  tables <- writeBroadConsentSnapshotFixture(connection, schema)
  intervals <- basename(tempfile("bc_intervals_"))
  DBI::dbWriteTable(connection, intervals, data.frame(
    patient_id = "p1", start = as.Date("2026-03-01"),
    end = as.Date("2026-03-15")
  ), temporary = TRUE)
  on.exit(DBI::dbRemoveTable(connection, intervals), add = TRUE)
  sources <- getDefaultSnapshotPseudonymizationRuleSources(testthat::test_path("../../../.."))
  rules <- loadPseudonymizationRules(sources$table_descriptions, sources$snapshot_extensions)
  plan <- getExistingSnapshotMaterializationPlan(connection, rules, schema, "v_", SNAPSHOT_LAST_VERSION_SUFFIX, names(tables))
  selection <- prepareBroadConsentResourceSelection(connection, plan, rules, schema, "v_", snapshotQualifiedName(connection, intervals))
  on.exit(dropSnapshotVersionKeyTables(connection, lapply(selection, `[[`, "table_name")), add = TRUE)
  read <- function(base) {
    rows <- DBI::dbReadTable(connection, selection[[base]]$table_name)
    rows[rows$reason == "included", ]
  }
  expect_equal(read("encounter")$resource_id, "ward")
  for (base in c("patient_fe", "fall_fe", "dp_mrp_calculations", "pids_per_ward")) {
    expect_equal(read(base)$row_id, "1")
    expect_equal(read(base)$patient_id, "p1")
  }
  expect_setequal(read("medication")$resource_id, c("m1", "ingredient"))
  expect_equal(nrow(read("location")), 0L)
})
