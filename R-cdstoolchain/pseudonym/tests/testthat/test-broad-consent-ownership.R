test_that("ambiguous Consent ownership excludes every affected patient across batches", {
  source <- getOption("interpolar.test.postgres_connection")
  target <- getOption("interpolar.test.postgres_target_connection")
  skip_if(is.null(source) || is.null(target), "Two isolated PostgreSQL test connections were not supplied.")
  schema <- basename(tempfile("bc_owners_"))
  output <- tempfile("bc_owners_output_")
  dir.create(output)
  on.exit(unlink(output, recursive = TRUE), add = TRUE)
  snapshotEnsureSchema(source, schema)
  on.exit(DBI::dbExecute(source, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(source, schema), " CASCADE")), add = TRUE)
  tables <- writeBroadConsentSnapshotFixture(source, schema)
  conflicting <- tables$consent
  conflicting$consent_id <- conflicting$consent_id + 2L
  conflicting$cons_patient_ref <- "Patient/p2"
  # Separate valid documents must not override the ambiguous document.
  independent <- rbind(tables$consent, conflicting)
  independent$consent_id <- independent$consent_id + 4L
  independent$cons_id <- paste0("independent", rep(1:2, each = 2L))
  DBI::dbAppendTable(source, DBI::Id(schema = schema, table = "consent"), rbind(conflicting, independent))
  unaffected <- tables$consent
  unaffected$consent_id <- unaffected$consent_id + 8L
  unaffected$cons_id <- "unaffected"
  unaffected$cons_patient_ref <- "Patient/p3"
  DBI::dbAppendTable(source, DBI::Id(schema = schema, table = "consent"), unaffected)
  DBI::dbAppendTable(source, DBI::Id(schema = schema, table = "patient"), data.frame(
    patient_id = 3L, pat_id = "p3", pat_meta_versionid = "1"
  ))
  baseline <- DBI::dbReadTable(source, DBI::Id(schema = schema, table = "consent"))
  rule_sources <- getDefaultSnapshotPseudonymizationRuleSources(testthat::test_path("../../../.."))
  testthat::local_mocked_bindings(getDefaultSnapshotPseudonymizationRuleSources = function(project_root) rule_sources)
  for (chunk_size in c(1L, 2L)) {
    review <- reviewBroadConsentSnapshot(
      source,
      project_root = output,
      source_schema = schema, chunk_size = chunk_size, evaluation_date = as.Date("2026-09-11")
    )
    expect_equal(review$summary$patients[review$summary$reason == "ambiguous_consent_patient"], 2L)
    expect_equal(review$summary$patients[review$summary$reason == "included"], 1L)
    patients <- data.table::fread(file.path(review$directory, "patients.csv"))
    expect_true(all(!patients$included[patients$patient_id %in% c("p1", "p2")]))
    expect_equal(patients$patient_id[patients$included], "p3")
    target_schema <- basename(tempfile("bc_owners_target_"))
    tryCatch(
      {
        result <- createBroadConsentSnapshotDatabase(source, target,
          project_root = output,
          source_schema = schema, target_table_schema = target_schema, target_view_schema = target_schema,
          tables = names(tables), chunk_size = chunk_size, consent_details = chunk_size == 1L,
          evaluation_date = as.Date("2026-09-11"), report_file = file.path(output, paste0(target_schema, ".xlsx")), log_steps = FALSE
        )
        expect_equal(result$patient_summary, review$summary)
        for (base in names(tables)) {
          expected_rows <- switch(
            base,
            patient = 1L,
            consent = 2L,
            0L
          )
          expect_equal(nrow(DBI::dbReadTable(target, DBI::Id(schema = target_schema, table = paste0("v_", base)))), expected_rows)
        }
        expect_equal(nrow(DBI::dbReadTable(target, DBI::Id(schema = target_schema, table = BROAD_CONSENT_MASKED_TABLE))), 0L)
      },
      finally = DBI::dbExecute(target, paste0("DROP SCHEMA IF EXISTS ", DBI::dbQuoteIdentifier(target, target_schema), " CASCADE"))
    )
  }
  expect_equal(DBI::dbReadTable(source, DBI::Id(schema = schema, table = "consent")), baseline)
  # Duplicated inactive documents cannot affect independent valid grants.
  DBI::dbExecute(source, paste0("UPDATE ", snapshotQualifiedName(source, "consent", schema), " SET cons_status = 'inactive' WHERE cons_id = 'a'"))
  review <- reviewBroadConsentSnapshot(
    source,
    project_root = output,
    source_schema = schema, chunk_size = 1L, evaluation_date = as.Date("2026-09-11")
  )
  expect_equal(review$summary$reason, "included")
  expect_equal(review$summary$patients, 3L)
})
