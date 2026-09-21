test_that("Consent config is optional and independent", {
  root <- tempfile()
  dir.create(file.path(root, "R-cdstoolchain"), recursive = TRUE)
  expect_null(readSnapshotConsentConfig(root))
  path <- file.path(root, "R-cdstoolchain", "consent_config.toml")
  writeLines('FHIR_SERVER_ENDPOINT = ""', path)
  expect_null(readSnapshotConsentConfig(root))
  writeLines(c('FHIR_SERVER_ENDPOINT = "https://example.test/fhir"', 'FHIR_SERVER_USER = "own-user"'), path)
  expect_identical(readSnapshotConsentConfig(root)$FHIR_SERVER_USER, "own-user")
})

test_that("a remote patient replaces the complete snapshot Consent history", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  schema <- basename(tempfile("consent_refresh_"))
  snapshotEnsureSchema(connection, schema)
  on.exit(DBI::dbExecute(connection, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(connection, schema), " CASCADE")))
  original <- data.frame(
    consent_id = 1:4, cons_id = c("old", "old", "keep", "keep"),
    cons_patient_ref = c("Patient/p1", "Patient/p1", "Patient/p2", "Patient/p2"),
    cons_status = c("active", "active", "active", "inactive")
  )
  DBI::dbWriteTable(connection, DBI::Id(schema = schema, table = "consent"), original)
  relation <- snapshotQualifiedName(connection, "consent", schema)
  for (suffix in c("", "_last_version")) {
    DBI::dbExecute(connection, paste0(
      "CREATE VIEW ", snapshotQualifiedName(connection, paste0("v_consent", suffix), schema),
      " AS SELECT * FROM ", relation, if (nzchar(suffix)) " WHERE consent_id IN (2,4)" else ""
    ))
  }
  plan <- data.table::data.table(
    BASE_TABLE_NAME = "consent",
    SOURCE_RELATION = c("v_consent", "v_consent_last_version"),
    MATERIALIZED_TABLE_NAME = c("consent_old_versions", "consent_last_version"),
    SNAPSHOT_RELATION_TYPE = c("old_versions", "last_version")
  )
  keys <- prepareSnapshotVersionKeyTables(connection, plan, schema)
  on.exit(dropSnapshotVersionKeyTables(connection, keys), add = TRUE)
  remote <- data.table::data.table(
    cons_id = c("different-id", "other-document"),
    cons_patient_ref = "Patient/p1", cons_status = c("inactive", "active")
  )
  refreshed <- prepareSnapshotConsentRefresh(connection, schema, "v_", keys, plan, remote)
  on.exit(dropSnapshotVersionKeyTables(connection, refreshed$tables), add = TRUE)
  current <- DBI::dbGetQuery(connection, refreshed$queries$consent_last_version)
  old <- DBI::dbGetQuery(connection, refreshed$queries$consent_old_versions)
  expect_setequal(current$cons_id, c("keep", "different-id", "other-document"))
  expect_identical(old$cons_id, "keep")
  expect_equal(current$cons_status[current$cons_id == "different-id"], "inactive")
  expect_true(all(current$consent_id[current$cons_id != "keep"] > 4))
  expect_identical(anyDuplicated(c(current$consent_id, old$consent_id)), 0L)
  expect_equal(DBI::dbGetQuery(connection, paste0("SELECT * FROM ", relation, " ORDER BY consent_id")), original)
  empty <- prepareSnapshotConsentRefresh(connection, schema, "v_", keys, plan, remote[0])
  expect_length(empty$queries, 0)
  expect_equal(empty$patients, 0L)
})

test_that("identifier mapping uses matching system/value pairs and rejects ambiguity", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection))
  schema <- basename(tempfile("consent_patient_"))
  snapshotEnsureSchema(connection, schema)
  on.exit(DBI::dbExecute(connection, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(connection, schema), " CASCADE")))
  DBI::dbWriteTable(
    connection, DBI::Id(schema = schema, table = "v_patient_last_version"),
    data.frame(
      pat_id = c("p1", "p1", "p2"), pat_identifier_system = c("urn:local", "urn:other", NA),
      pat_identifier_value = c("ABC", "wrong", NA)
    )
  )
  config <- list(FHIR_SERVER_ENDPOINT = "https://example.test/fhir", PATIENT_IDENTIFIER_SYSTEM = "urn:local")
  testthat::local_mocked_bindings(searchSnapshotConsentFHIR = function(config, resource, parameters) {
    expect_identical(resource, "Patient")
    expect_identical(unname(parameters), "urn:local|ABC")
    fhircrackr::fhir_bundle_list(list(xml2::read_xml(paste0(
      '<Bundle xmlns="http://hl7.org/fhir"><type value="searchset"/><entry><resource><Patient><id value="remote1"/>',
      '<identifier><system value="urn:other"/><value value="ABC"/></identifier>',
      '<identifier><system value="urn:local"/><value value="ABC"/></identifier>',
      "</Patient></resource></entry></Bundle>"
    ))))
  })
  actual <- snapshotConsentPatientMap(connection, schema, "v_", config)
  expect_equal(actual, data.table::data.table(pat_id = "p1", remote_id = "remote1"))
  config$PATIENT_IDENTIFIER_SYSTEM <- ""
  direct <- snapshotConsentPatientMap(connection, schema, "v_", config)
  expect_setequal(direct$pat_id, c("p1", "p2"))
  expect_identical(direct$pat_id, direct$remote_id)
})

test_that("FHIR refresh uses only its own credentials and requests all pages", {
  testthat::local_mocked_bindings(fhir_search = function(request, max_bundles, verbose, username, password) {
    expect_equal(username, "own")
    expect_equal(password, "secret")
    expect_equal(max_bundles, Inf)
    expect_equal(verbose, 0)
    expect_match(as.character(request), "Consent")
    TRUE
  }, .package = "fhircrackr")
  expect_true(searchSnapshotConsentFHIR(list(
    FHIR_SERVER_ENDPOINT = "https://example.test/fhir",
    FHIR_SERVER_USER = "own", FHIR_SERVER_PASS = "secret"
  ), "Consent", c(patient = "p1")))
})

test_that("refreshed Consent rows pass through pseudonymization and unchanged BC selection", {
  source <- getOption("interpolar.test.postgres_connection")
  target <- getOption("interpolar.test.postgres_target_connection")
  skip_if(is.null(source) || is.null(target))
  schemas <- vapply(1:3, function(i) basename(tempfile(paste0("refresh_flow_", i))), character(1))
  for (schema in schemas) snapshotEnsureSchema(source, schema)
  on.exit(for (schema in rev(schemas)) DBI::dbExecute(source, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(source, schema), " CASCADE")))
  tables <- writeBroadConsentSnapshotFixture(source, schemas[1])
  root <- tempfile("refresh_flow_")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  rules <- getDefaultSnapshotPseudonymizationRuleSources(testthat::test_path("../../../.."))
  fresh <- data.table::as.data.table(tables$consent)
  fresh$cons_id <- "server-document"
  fresh$cons_status <- "inactive"
  fresh$consent_id <- NULL
  # Exercise the real DB pipeline; only the network boundary is replaced here.
  testthat::local_mocked_bindings(
    getDefaultSnapshotPseudonymizationRuleSources = function(...) rules,
    readSnapshotConsentConfig = function(...) list(FHIR_SERVER_ENDPOINT = "https://example.test/fhir"),
    fetchSnapshotConsentRows = function(...) fresh
  )
  result <- pseudonymizeSnapshotDatabase(source, target,
    project_root = root, source_schema = schemas[1],
    target_table_schema = schemas[2], target_view_schema = schemas[2],
    tables = c("patient", "consent", "encounter"), chunk_size = 1L,
    review_report_file = file.path(root, "rules.xlsx"), issue_report_file = file.path(root, "issues.xlsx"),
    postprocessing_report_file = file.path(root, "summary.xlsx"), mapping_preflight_completed = TRUE, log_steps = FALSE
  )
  current <- DBI::dbReadTable(target, DBI::Id(schema = schemas[2], table = "v_consent_last_version"))
  expect_true(all(current$cons_status == "inactive"))
  expect_false(any(current$cons_patient_ref == "Patient/p1"))
  expect_true(snapshotRelationExists(target, "consent_updated", schemas[2]))
  expect_equal(nrow(DBI::dbReadTable(target, DBI::Id(schema = schemas[2], table = "consent_old_versions"))), 0L)
  bc <- createBroadConsentSnapshotDatabase(source, target,
    project_root = root, source_schema = schemas[2], target_table_schema = schemas[3], target_view_schema = schemas[3],
    tables = c("patient", "consent", "encounter"), chunk_size = 1L, consent_details = FALSE,
    report_file = file.path(root, "bc.xlsx"), evaluation_date = as.Date("2026-09-15"), log_steps = FALSE
  )
  expect_equal(nrow(DBI::dbReadTable(target, DBI::Id(schema = schemas[3], table = "v_patient"))), 0L)
})
