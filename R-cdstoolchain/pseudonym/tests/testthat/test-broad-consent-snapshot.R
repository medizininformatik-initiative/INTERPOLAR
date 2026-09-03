test_that("Broad Consent relation query currently passes every row through", {
  plan_row <- data.table::data.table(
    BASE_TABLE_NAME = "patient",
    SOURCE_RELATION = "v_patient",
    SNAPSHOT_RELATION_TYPE = SNAPSHOT_RELATION_TYPE_ALL
  )
  testthat::local_mocked_bindings(
    getSnapshotPartitionSource = function(
                                          connection,
                                          plan_row,
                                          source_schema,
                                          source_view_prefix,
                                          version_key_tables
    ) {
      list(
        relation = '"db2dataprocessor_out"."v_patient"',
        fields = c("patient_id", "pat_id")
      )
    }
  )

  result <- buildBroadConsentRelationQuery(
    DBI::ANSI(),
    plan_row,
    source_schema = "db2dataprocessor_out",
    source_view_prefix = "v_",
    version_key_tables = list()
  )

  expect_equal(
    result$query,
    'SELECT * FROM "db2dataprocessor_out"."v_patient"'
  )
  expect_equal(result$filter_action, "all_rows_pending_consent_filter")
})

test_that("Broad Consent chunk stream copies rows without changing them", {
  chunks <- list(
    data.table::data.table(patient_id = 1:2, pat_id = c("p1", "p2")),
    data.table::data.table(patient_id = 3L, pat_id = "p3")
  )
  chunk_index <- 0L
  requested_sizes <- integer()
  written_tables <- list()
  first_chunk_flags <- logical()

  result <- copyBroadConsentChunkStream(
    fetch_chunk = function(chunk_size) {
      requested_sizes <<- c(requested_sizes, chunk_size)
      chunk_index <<- chunk_index + 1L
      chunks[[chunk_index]]
    },
    has_completed = function() chunk_index == length(chunks),
    write_chunk = function(chunk, first_chunk) {
      written_tables[[length(written_tables) + 1L]] <<- data.table::copy(chunk)
      first_chunk_flags <<- c(first_chunk_flags, first_chunk)
    },
    chunk_size = 2L,
    table_name = "patient"
  )

  expect_equal(requested_sizes, c(2L, 2L))
  expect_equal(first_chunk_flags, c(TRUE, FALSE))
  expect_equal(data.table::rbindlist(written_tables), data.table::rbindlist(chunks))
  expect_equal(result$input_rows, 3L)
  expect_equal(result$output_rows, 3L)
  expect_equal(result$output_columns, 2L)
  expect_equal(result$chunks, 2L)
  expect_true(result$stream_seconds >= 0)
})

test_that("Broad Consent chunk stream creates an empty relation", {
  fetched <- FALSE
  writes <- 0L

  result <- copyBroadConsentChunkStream(
    fetch_chunk = function(chunk_size) {
      fetched <<- TRUE
      data.table::data.table(patient_id = integer(), pat_id = character())
    },
    has_completed = function() fetched,
    write_chunk = function(chunk, first_chunk) {
      writes <<- writes + 1L
      expect_true(first_chunk)
      expect_equal(nrow(chunk), 0L)
    },
    chunk_size = 100L,
    table_name = "patient"
  )

  expect_equal(writes, 1L)
  expect_equal(result$input_rows, 0L)
  expect_equal(result$output_rows, 0L)
  expect_equal(result$output_columns, 2L)
})

test_that("Broad Consent report writes an xlsx workbook", {
  file_name <- tempfile(fileext = ".xlsx")
  summary <- data.table::data.table(
    TABLE_NAME = "patient",
    FILTER_ACTION = "all_rows_pending_consent_filter",
    INPUT_ROWS = 3L,
    OUTPUT_ROWS = 3L
  )

  result <- writeBroadConsentSnapshotReport(summary, file_name = file_name)

  expect_true(file.exists(file_name))
  expect_equal(result, summary)
})

test_that("Broad Consent database workflow materializes and publishes its plan", {
  captured <- new.env(parent = emptyenv())
  plan <- data.table::data.table(
    BASE_TABLE_NAME = "patient",
    MATERIALIZED_TABLE_NAME = "patient",
    SOURCE_RELATION = "v_patient",
    TARGET_VIEW_NAME = "v_patient",
    SNAPSHOT_RELATION_TYPE = SNAPSHOT_RELATION_TYPE_ALL
  )
  summary <- data.table::data.table(
    TABLE_NAME = "patient",
    FILTER_ACTION = "all_rows_pending_consent_filter",
    INPUT_ROWS = 2L,
    OUTPUT_ROWS = 2L
  )
  view_summary <- data.table::data.table(
    VIEW_NAME = "v_patient",
    SOURCE_TABLE = "patient",
    STATUS = "created"
  )
  version_summary <- data.table::data.table(
    VIEW_NAME = "v_db_parameter",
    SOURCE_TABLE = NA_character_,
    STATUS = "created"
  )

  testthat::local_mocked_bindings(
    validateSnapshotChunkSize = function(chunk_size) as.integer(chunk_size),
    getSnapshotReleaseVersion = function(connection, source_schema) {
      captured$version_connection <- connection
      "2.1.0"
    },
    getSnapshotDatabaseContentType = function(connection, source_schema) {
      captured$content_type_connection <- connection
      "pseudonymized_snapshot"
    },
    getDefaultSnapshotPseudonymizationRuleSources = function(project_root) {
      list(table_descriptions = "rules", snapshot_extensions = "extensions")
    },
    loadPseudonymizationRules = function(table_descriptions, snapshot_extensions) "rules",
    getExistingSnapshotMaterializationPlan = function(
                                                      connection,
                                                      rules,
                                                      source_schema,
                                                      source_view_prefix,
                                                      last_version_suffix,
                                                      tables
    ) {
      captured$plan_connection <- connection
      plan
    },
    snapshotEnsureSchema = function(connection, schema) {
      captured$target_schema <- schema
    },
    snapshotAllowTemporarySourceTables = function(connection) {
      captured$temporary_source_connection <- connection
    },
    prepareSnapshotVersionKeyTables = function(
                                               connection,
                                               materialization_plan,
                                               source_schema
    ) {
      list()
    },
    dropSnapshotVersionKeyTables = function(connection, tables) invisible(),
    streamBroadConsentSnapshotTable = function(
                                               source_connection,
                                               target_connection,
                                               plan_row,
                                               source_schema,
                                               target_table_schema,
                                               source_view_prefix,
                                               chunk_size,
                                               version_key_tables
    ) {
      captured$stream_connections <- c(source_connection, target_connection)
      captured$chunk_size <- chunk_size
      summary
    },
    writeBroadConsentSnapshotReport = function(summary, file_name) {
      captured$reported_summary <- summary
      invisible(summary)
    },
    createSnapshotPassthroughViews = function(
                                              connection,
                                              materialization_plan,
                                              table_schema,
                                              view_schema
    ) {
      captured$view_connection <- connection
      view_summary
    },
    createSnapshotVersionView = function(
                                         connection,
                                         release_version,
                                         view_schema,
                                         database_content_type
    ) {
      captured$version_view_connection <- connection
      captured$release_version <- release_version
      captured$database_content_type <- database_content_type
      version_summary
    }
  )

  expect_warning(
    result <- createBroadConsentSnapshotDatabase(
      source_connection = "source-connection",
      target_connection = "target-connection",
      tables = "patient",
      chunk_size = 2L,
      log_steps = FALSE
    ),
    "filtering is not implemented"
  )

  expect_equal(captured$plan_connection, "source-connection")
  expect_equal(captured$version_connection, "source-connection")
  expect_equal(captured$content_type_connection, "source-connection")
  expect_equal(captured$target_schema, "db_log")
  expect_equal(captured$temporary_source_connection, "source-connection")
  expect_equal(captured$stream_connections, c("source-connection", "target-connection"))
  expect_equal(captured$chunk_size, 2L)
  expect_equal(captured$reported_summary, summary)
  expect_equal(captured$view_connection, "target-connection")
  expect_equal(captured$version_view_connection, "target-connection")
  expect_equal(captured$release_version, "2.1.0")
  expect_equal(captured$database_content_type, "pseudonymized_snapshot")
  expect_equal(result$materialization_plan, plan)
  expect_equal(result$summary, summary)
  expect_equal(result$release_version, "2.1.0")
  expect_equal(result$database_content_type, "pseudonymized_snapshot")
  expect_equal(
    result$view_summary,
    data.table::rbindlist(list(view_summary, version_summary))
  )
})
