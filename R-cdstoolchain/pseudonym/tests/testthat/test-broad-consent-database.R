test_that("snapshot retains covered children and records every masked reference permanently", {
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
  evidence <- DBI::dbReadTable(target, DBI::Id(schema = target_schema, table = BROAD_CONSENT_MASKED_TABLE))
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
  metadata <- DBI::dbReadTable(target, DBI::Id(schema = target_schema, table = "broad_consent_run"))
  expect_equal(metadata$evaluation_date, as.Date("2026-09-11"))
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
  # Details cannot change the selected data. Re-selection must also retain
  # earlier masking evidence whose original reference value is already NULL.
  for (input_schema in c(source_schema, target_schema)) {
    next_schema <- basename(tempfile("bc_repeat_"))
    tryCatch(
      {
        repeated <- createBroadConsentSnapshotDatabase(source, target,
          project_root = output_root,
          source_schema = input_schema, target_table_schema = next_schema, target_view_schema = next_schema,
          tables = names(tables), chunk_size = 3L, consent_details = FALSE, evaluation_date = as.Date("2026-09-11"),
          report_file = file.path(output_root, paste0(next_schema, ".xlsx")), log_steps = FALSE
        )
        for (base in names(tables)) {
          actual <- DBI::dbReadTable(target, DBI::Id(schema = next_schema, table = paste0("v_", base)))
          expected <- read(base)
          key <- snapshotTechnicalRowIdColumn(base)
          expect_equal(actual[order(actual[[key]]), ], expected[order(expected[[key]]), ])
        }
        repeated_evidence <- DBI::dbReadTable(target, DBI::Id(schema = next_schema, table = BROAD_CONSENT_MASKED_TABLE))
        expect_equal(
          data.table::setorderv(data.table::as.data.table(repeated_evidence), names(evidence)),
          data.table::setorderv(data.table::as.data.table(evidence), names(evidence))
        )
        expect_false(file.exists(file.path(repeated$review_directory, "patients.csv")))
      },
      finally = DBI::dbExecute(target, paste0(
        "DROP SCHEMA IF EXISTS ",
        DBI::dbQuoteIdentifier(target, next_schema), " CASCADE"
      ))
    )
  }
  for (base in names(tables)) expect_equal(DBI::dbReadTable(source, DBI::Id(schema = source_schema, table = base)), tables[[base]])
})
