test_that("snapshot retains covered children and writes masking evidence only to external reports", {
  source <- getOption("interpolar.test.postgres_connection")
  target <- getOption("interpolar.test.postgres_target_connection")
  skip_if(is.null(source) || is.null(target), "Two isolated PostgreSQL test connections were not supplied.")
  source_schema <- basename(tempfile("bc_source_"))
  target_schema <- basename(tempfile("bc_target_"))
  output_root <- tempfile("bc_output_")
  dir.create(output_root)
  on.exit(unlink(output_root, recursive = TRUE), add = TRUE)
  for (schema in c(source_schema, target_schema)) snapshotEnsureSchema(source, schema)
  on.exit(DBI::dbExecute(source, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(source, source_schema), " CASCADE")), add = TRUE)
  on.exit(DBI::dbExecute(target, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(target, target_schema), " CASCADE")), add = TRUE)
  tables <- writeBroadConsentSnapshotFixture(source, source_schema)
  rule_sources <- getDefaultSnapshotPseudonymizationRuleSources(testthat::test_path("../../../.."))
  testthat::local_mocked_bindings(getDefaultSnapshotPseudonymizationRuleSources = function(project_root) rule_sources)
  result <- createBroadConsentSnapshotDatabase(source, target,
    project_root = output_root,
    source_schema = source_schema, target_table_schema = target_schema, target_view_schema = target_schema,
    tables = names(tables), chunk_size = 1L, consent_details = TRUE, evaluation_date = as.Date("2026-09-11"),
    report_file = file.path(output_root, "summary.xlsx"), log_steps = FALSE
  )
  read <- function(base) DBI::dbReadTable(target, DBI::Id(schema = target_schema, table = paste0("v_", base)))
  expect_equal(read("patient")$pat_id, "p1")
  expect_equal(read("encounter")$enc_id, "ward")
  expect_true(is.na(read("encounter")$enc_main_encounter_calculated_ref))
  observations <- read("observation")
  expect_setequal(observations$obs_id, c("good", "empty", "dangling", "versioned"))
  expect_true(is.na(observations$obs_encounter_ref[observations$obs_id == "good"]))
  expect_equal(observations$obs_encounter_ref[observations$obs_id == "dangling"], "Encounter/absent")
  expect_equal(observations$obs_encounter_calculated_ref[observations$obs_id == "dangling"], "invalid")
  expect_true(all(is.na(observations$obs_encounter_calculated_ref[observations$obs_id != "dangling"])))
  expect_equal(read("fall_fe")$record_id, "r1")
  expect_true(is.na(read("fall_fe")$fall_fhir_enc_id))
  expect_equal(nrow(read("dp_mrp_calculations")), 1L)
  expect_true(is.na(read("dp_mrp_calculations")$enc_id))
  expect_equal(read("pids_per_ward")$patient_id, "p1")
  expect_true(is.na(read("pids_per_ward")$encounter_id))
  expect_setequal(read("medication")$med_id, c("m1", "ingredient"))
  expect_equal(nrow(read("location")), 0L)
  evidence <- data.table::fread(file.path(result$review_directory, "masked_references.csv"))
  expect_equal(nrow(evidence), 10L)
  expect_true(all(evidence$reason == "masked"))
  expect_false(any(evidence$row_id == "4" & grepl("observation", evidence$table_name)))
  expect_false(any(evidence$row_id == "3" & evidence$column_name == "obs_encounter_ref"))
  expect_equal(nrow(unique(evidence)), nrow(evidence))
  expect_equal(sum(result$patient_summary$patients), 2L)
  expect_true(all(result$summary$OUTPUT_COLUMNS == vapply(
    result$materialization_plan$BASE_TABLE_NAME,
    function(base) ncol(tables[[base]]), integer(1)
  )))
  expect_true(any(result$resource_decisions$reason == "missing_resource_date_mapping"))
  for (name in c("broad_consent_run", "broad_consent_masked_reference", "v_broad_consent_masked_reference")) {
    expect_false(snapshotRelationExists(target, name, target_schema))
  }
  metadata <- data.table::fread(file.path(result$review_directory, "run.csv"))
  expect_setequal(names(metadata), c("source_database", "evaluation_date", "completed_at"))
  expect_equal(as.Date(metadata$evaluation_date), as.Date("2026-09-11"))
  review <- reviewBroadConsentSnapshot(
    source,
    project_root = output_root, source_schema = source_schema,
    chunk_size = 2L, evaluation_date = as.Date("2026-09-11")
  )
  expect_equal(review$summary, result$patient_summary)
  for (name in c("patients", "intervals")) {
    expect_equal(
      data.table::fread(file.path(review$directory, paste0(name, ".csv"))),
      data.table::fread(file.path(result$review_directory, paste0(name, ".csv")))
    )
  }
  # Both supported source types yield the same selected data without detail reports.
  for (content_type in c("snapshot", "pseudonymized_snapshot")) {
    DBI::dbExecute(source, paste0(
      "UPDATE ", snapshotQualifiedName(source, "v_db_parameter", source_schema),
      " SET parameter_value = ", DBI::dbQuoteString(source, content_type),
      " WHERE parameter_name = 'database_content_type'"
    ))
    next_schema <- basename(tempfile("bc_repeat_"))
    tryCatch(
      {
        repeated <- createBroadConsentSnapshotDatabase(source, target,
          project_root = output_root,
          source_schema = source_schema, target_table_schema = next_schema, target_view_schema = next_schema,
          tables = names(tables), chunk_size = 3L, consent_details = FALSE, evaluation_date = as.Date("2026-09-11"),
          report_file = file.path(output_root, paste0(next_schema, ".xlsx")), log_steps = FALSE
        )
        for (base in names(tables)) {
          actual <- DBI::dbReadTable(target, DBI::Id(schema = next_schema, table = paste0("v_", base)))
          expected <- read(base)
          key <- snapshotTechnicalRowIdColumn(base)
          expect_equal(actual[order(actual[[key]]), ], expected[order(expected[[key]]), ])
        }
        repeated_evidence <- data.table::fread(file.path(repeated$review_directory, "masked_references.csv"))
        expect_equal(
          data.table::setorderv(data.table::as.data.table(repeated_evidence), names(evidence)),
          data.table::setorderv(data.table::as.data.table(evidence), names(evidence))
        )
        expect_false(file.exists(file.path(repeated$review_directory, "patients.csv")))
        expect_identical(repeated$database_content_type, content_type)
        expect_false(snapshotRelationExists(target, "broad_consent_run", next_schema))
        expect_false(snapshotRelationExists(target, "broad_consent_masked_reference", next_schema))
      },
      finally = DBI::dbExecute(target, paste0(
        "DROP SCHEMA IF EXISTS ",
        DBI::dbQuoteIdentifier(target, next_schema), " CASCADE"
      ))
    )
  }
  for (base in names(tables)) expect_equal(DBI::dbReadTable(source, DBI::Id(schema = source_schema, table = base)), tables[[base]])
})

test_that("enriched source rows survive selection with external evidence across chunks", {
  source <- getOption("interpolar.test.postgres_connection")
  target <- getOption("interpolar.test.postgres_target_connection")
  skip_if(is.null(source) || is.null(target), "Two isolated PostgreSQL test connections were not supplied.")
  source_schema <- basename(tempfile("bc_enriched_source_"))
  output_root <- tempfile("bc_enriched_output_")
  dir.create(output_root)
  on.exit(unlink(output_root, recursive = TRUE), add = TRUE)
  snapshotEnsureSchema(source, source_schema)
  on.exit(DBI::dbExecute(source, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(source, source_schema), " CASCADE")), add = TRUE)
  tables <- writeBroadConsentSnapshotFixture(source, source_schema)
  relation <- snapshotQualifiedName(source, "medicationrequest", source_schema)
  DBI::dbExecute(source, paste0("ALTER TABLE ", relation, " ADD COLUMN medreq_medication_code text, ADD COLUMN medreq_encounter_ref text"))
  DBI::dbExecute(source, paste0("UPDATE ", relation, " SET medreq_medication_code = 'A01AA01', medreq_encounter_ref = 'Encounter/main'"))
  DBI::dbExecute(source, paste0("INSERT INTO ", relation, " SELECT * FROM ", relation))
  DBI::dbExecute(source, paste0("UPDATE ", relation, " SET medreq_medication_code = 'B01AA01' WHERE ctid IN (SELECT max(ctid) FROM ", relation, " GROUP BY medicationrequest_id)"))
  for (suffix in c("", SNAPSHOT_LAST_VERSION_SUFFIX)) {
    DBI::dbExecute(source, paste0("CREATE OR REPLACE VIEW ", snapshotQualifiedName(source, paste0("v_medicationrequest", suffix), source_schema), " AS SELECT * FROM ", relation))
  }
  original <- DBI::dbReadTable(source, DBI::Id(schema = source_schema, table = "medicationrequest"))
  rule_sources <- getDefaultSnapshotPseudonymizationRuleSources(testthat::test_path("../../../.."))
  testthat::local_mocked_bindings(getDefaultSnapshotPseudonymizationRuleSources = function(project_root) rule_sources)
  target_schemas <- character()
  on.exit(for (schema in target_schemas) DBI::dbExecute(target, paste0("DROP SCHEMA IF EXISTS ", DBI::dbQuoteIdentifier(target, schema), " CASCADE")), add = TRUE)
  for (chunk_size in c(1L, 8L)) {
    target_schema <- basename(tempfile("bc_enriched_target_"))
    target_schemas <- c(target_schemas, target_schema)
    result <- createBroadConsentSnapshotDatabase(source, target,
      project_root = output_root,
      source_schema = source_schema, target_table_schema = target_schema, target_view_schema = target_schema,
      tables = names(tables), chunk_size = chunk_size, evaluation_date = as.Date("2026-09-11"),
      report_file = file.path(output_root, paste0(target_schema, ".xlsx")), log_steps = FALSE
    )
    actual <- DBI::dbReadTable(target, DBI::Id(schema = target_schema, table = "v_medicationrequest"))
    expect_equal(nrow(actual), 2L)
    expect_equal(actual$medicationrequest_id, c(1L, 1L))
    expect_setequal(actual$medreq_medication_code, c("A01AA01", "B01AA01"))
    expect_true(all(is.na(actual$medreq_encounter_ref)))
    summary <- result$summary[result$summary$BASE_TABLE_NAME == "medicationrequest", ]
    expect_equal(sum(summary$INPUT_ROWS), 4)
    expect_equal(sum(summary$OUTPUT_ROWS), 2)
    evidence <- data.table::fread(file.path(result$review_directory, "masked_references.csv"))
    expect_equal(nrow(evidence), 12L)
    expect_equal(nrow(unique(evidence)), 11L)
    expect_false("value" %in% names(evidence))
    expect_false(snapshotRelationExists(target, "broad_consent_masked_reference", target_schema))
    expect_false(snapshotRelationExists(target, "v_broad_consent_masked_reference", target_schema))
    expect_false(snapshotRelationExists(target, "broad_consent_run", target_schema))
  }
  expect_equal(DBI::dbReadTable(source, DBI::Id(schema = source_schema, table = "medicationrequest")), original)
})
