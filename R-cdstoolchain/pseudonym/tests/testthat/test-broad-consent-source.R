test_that("Consent selection runs against PostgreSQL without changing source data", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  schema <- basename(tempfile("consent_test_"))
  DBI::dbExecute(connection, paste0("CREATE SCHEMA ", DBI::dbQuoteIdentifier(connection, schema)))
  on.exit(DBI::dbExecute(connection, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(connection, schema), " CASCADE")))
  rows <- data.table::rbindlist(list(
    consentDocumentFixture(), consentProvisionFixture("45"),
    consentProvisionFixture("46", "deny", consent_id = "b", declared_at = "2021-01-01 12:00:00")
  ))
  source <- as.data.frame(rows)
  names(source) <- c(
    "cons_id", "cons_datetime", "cons_status",
    "cons_provision_provision_code_system", "cons_provision_provision_code_code",
    "cons_provision_provision_type", "cons_provision_provision_period_start", "cons_provision_provision_period_end"
  )
  source$cons_patient_ref <- "Patient/p1"
  source$cons_provision_provision_period_start <- as.POSIXct(source$cons_provision_provision_period_start, tz = "UTC")
  source$cons_provision_provision_period_end <- as.POSIXct(source$cons_provision_provision_period_end, tz = "UTC")
  # Unrelated repeated FHIR fields may duplicate the same flattened provision.
  source <- rbind(source, source)
  DBI::dbWriteTable(connection, DBI::Id(schema = schema, table = "consents"), source)
  DBI::dbWriteTable(connection, DBI::Id(schema = schema, table = "patients"), data.frame(pat_id = c("p1", "p2")))
  DBI::dbWriteTable(connection, DBI::Id(schema = schema, table = "encounters"), data.frame(
    enc_id = "e1", enc_patient_ref = "Patient/p1",
    enc_period_start = as.POSIXct("2019-12-20", tz = "UTC"),
    enc_period_end = as.POSIXct("2020-01-05", tz = "UTC")
  ))
  for (table in c("consent", "patient", "encounter")) {
    DBI::dbExecute(connection, paste0(
      "CREATE VIEW ",
      snapshotQualifiedName(connection, paste0("v_", table, SNAPSHOT_LAST_VERSION_SUFFIX), schema),
      " AS SELECT * FROM ", snapshotQualifiedName(connection, paste0(table, "s"), schema)
    ))
  }
  outputs <- list()
  for (details in c(FALSE, TRUE)) {
    review <- newBroadConsentReview(tempfile(), as.Date("2026-09-08"), schema, details)
    on.exit(unlink(review$directory, recursive = TRUE), add = TRUE)
    selection <- prepareBroadConsentSelection(connection, schema, as.Date("2026-09-08"), 1L, review)
    outputs[[length(outputs) + 1L]] <- DBI::dbReadTable(connection, selection$table_name)
    expect_equal(sum(selection$summary$patients), 2L)
    expect_equal(selection$summary$patients[selection$summary$reason == "included"], 1L)
    expect_true(file.exists(file.path(review$directory, "COMPLETE")))
    if (details) {
      provisions <- data.table::fread(file.path(review$directory, "provisions.csv"))
      expect_equal(nrow(provisions), nrow(rows))
    }
    DBI::dbRemoveTable(connection, selection$table_name)
  }
  expect_equal(outputs[[1L]], outputs[[2L]])
  expect_equal(outputs[[1L]]$patient_id, "p1")
  expect_equal(outputs[[1L]]$start, as.Date("2019-12-20"))
  expect_equal(outputs[[1L]]$end, as.Date("2025-12-31"))
  expect_equal(DBI::dbReadTable(connection, DBI::Id(schema = schema, table = "consents")), source)
  review_dir <- tempfile()
  on.exit(unlink(review_dir, recursive = TRUE), add = TRUE)
  result <- reviewBroadConsentSnapshot(
    connection,
    source_schema = schema,
    chunk_size = 2L, report_dir = review_dir, evaluation_date = as.Date("2026-09-08")
  )
  expect_equal(result$summary, selection$summary)
  expect_equal(result$summary$patients[result$summary$reason == "included"], 1L)
  expect_true(file.exists(file.path(review_dir, "patients.csv")))
  # Invalid references must not silently hide an unassignable revocation.
  DBI::dbExecute(connection, paste0(
    "UPDATE ", snapshotQualifiedName(connection, "consents", schema),
    " SET cons_patient_ref = NULL WHERE cons_id = 'b'"
  ))
  invalid_review <- newBroadConsentReview(tempfile(), as.Date("2026-09-08"), schema, TRUE)
  on.exit(unlink(invalid_review$directory, recursive = TRUE), add = TRUE)
  expect_error(
    prepareBroadConsentSelection(connection, schema, as.Date("2026-09-08"), 1L, invalid_review),
    "unresolvable patient references"
  )
  expect_false(file.exists(file.path(invalid_review$directory, "COMPLETE")))
  DBI::dbExecute(connection, paste0(
    "UPDATE ", snapshotQualifiedName(connection, "consents", schema),
    " SET cons_status = 'unknown-status' WHERE cons_id = 'b'"
  ))
  expect_error(
    prepareBroadConsentSelection(connection, schema, as.Date("2026-09-08"), 1L, invalid_review),
    "unresolvable patient references"
  )
  # A known inactive document cannot grant or revoke rights and may be ignored.
  DBI::dbExecute(connection, paste0(
    "UPDATE ", snapshotQualifiedName(connection, "consents", schema),
    " SET cons_status = 'inactive' WHERE cons_id = 'b'"
  ))
  selection <- prepareBroadConsentSelection(connection, schema, as.Date("2026-09-08"), 2L, invalid_review)
  expect_equal(sum(selection$summary$patients), 2L)
  DBI::dbRemoveTable(connection, selection$table_name)
})
