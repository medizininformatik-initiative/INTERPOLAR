BROAD_CONSENT_FILTER_ACTION <- "broad_consent_selected"

buildBroadConsentRelationQuery <- function(
  connection,
  plan_row,
  source_schema,
  source_view_prefix,
  version_key_tables,
  selections,
  reference_targets
) {
  partition_source <- getSnapshotPartitionSource(
    connection,
    plan_row,
    source_schema,
    source_view_prefix,
    version_key_tables
  )

  selection <- selections[[plan_row$BASE_TABLE_NAME]]
  decision_table <- snapshotQualifiedName(connection, selection$table_name)
  row_id <- paste0(snapshotQuotedColumn(connection, selection$row_column, "s"), "::text")
  mask_columns <- character()
  mask_expressions <- character()
  resource <- if (is.null(selection$spec)) plan_row$BASE_TABLE_NAME else selection$spec$resource
  reference_columns <- if (!is.null(selection$spec)) {
    unique(selection$rules$COLUMN_NAME[vapply(selection$rules$FHIR_EXPRESSION, isFhirReferenceExpression, logical(1))])
  } else intersect(selection$fields, c("enc_id", "encounter_id", "fall_fhir_enc_id", "atc1_medreq_fhir_id"))
  for (column in intersect(reference_columns, partition_source$fields)) {
    hidden <- paste0(".broad_consent_mask_", column)
    if (hidden %in% partition_source$fields) stop("Reserved Consent column already exists: ", hidden)
    mask_columns[column] <- hidden
    mask_expressions <- c(mask_expressions, paste0(
      buildBroadConsentReferenceMaskPredicate(
        connection, column, resource,
        snapshotQualifiedName(connection, reference_targets)
      ),
      " AS ", snapshotQuotedColumn(connection, hidden)
    ))
  }
  exclusions <- DBI::dbGetQuery(connection, paste0(
    "SELECT d.reason, COUNT(*) AS rows FROM ", partition_source$relation,
    " s JOIN ", decision_table, " d ON d.row_id = ", row_id, " GROUP BY d.reason"
  ))
  list(
    query = paste0(
      "SELECT s.*, (SELECT d.patient_id FROM ", decision_table, " d WHERE d.row_id = ", row_id,
      ") AS ", snapshotQuotedColumn(connection, ".broad_consent_patient_id"), if (length(mask_expressions)) paste0(", ", paste(mask_expressions, collapse = ", ")) else "",
      " FROM ", partition_source$relation, " s WHERE EXISTS (SELECT 1 FROM ", decision_table,
      " d WHERE d.row_id = ", row_id, " AND d.reason = 'included')"
    ),
    filter_action = BROAD_CONSENT_FILTER_ACTION,
    input_rows = sum(exclusions$rows), exclusions = exclusions, mask_columns = mask_columns
  )
}

copyBroadConsentChunkStream <- function(
  fetch_chunk,
  has_completed,
  write_chunk,
  chunk_size,
  table_name
) {
  first_chunk <- TRUE
  chunk_number <- 0L
  input_rows <- 0L
  output_rows <- 0L
  output_columns <- 0L
  fetch_seconds <- 0
  write_seconds <- 0
  stream_started <- proc.time()[["elapsed"]]

  repeat {
    fetch_started <- proc.time()[["elapsed"]]
    chunk <- data.table::as.data.table(fetch_chunk(chunk_size))
    fetch_seconds <- fetch_seconds + proc.time()[["elapsed"]] - fetch_started
    chunk_number <- chunk_number + 1L

    write_started <- proc.time()[["elapsed"]]
    write_chunk(chunk, first_chunk)
    write_seconds <- write_seconds + proc.time()[["elapsed"]] - write_started
    first_chunk <- FALSE

    input_rows <- input_rows + nrow(chunk)
    output_rows <- output_rows + nrow(chunk)
    output_columns <- ncol(chunk)
    message(
      "Copied Broad Consent snapshot chunk ", chunk_number,
      " for ", table_name, ": ", nrow(chunk), " rows"
    )
    rm(chunk)

    if (has_completed()) {
      break
    }
  }

  stream_seconds <- proc.time()[["elapsed"]] - stream_started
  list(
    input_rows = input_rows,
    output_rows = output_rows,
    output_columns = output_columns,
    chunks = chunk_number,
    fetch_seconds = fetch_seconds,
    write_seconds = write_seconds,
    other_seconds = max(0, stream_seconds - fetch_seconds - write_seconds),
    stream_seconds = stream_seconds
  )
}

streamBroadConsentSnapshotTable <- function(
  source_connection,
  target_connection,
  plan_row,
  source_schema,
  target_table_schema,
  source_view_prefix,
  chunk_size,
  version_key_tables,
  selections,
  reference_targets
) {
  materialized_table_name <- plan_row[["MATERIALIZED_TABLE_NAME"]]
  source_relation_name <- plan_row[["SOURCE_RELATION"]]
  if (snapshotRelationExists(
    target_connection,
    materialized_table_name,
    target_table_schema
  )) {
    stop(
      "Target table already exists: ",
      snapshotQualifiedName(
        target_connection,
        materialized_table_name,
        target_table_schema
      )
    )
  }

  table_started <- proc.time()[["elapsed"]]
  source_open_started <- proc.time()[["elapsed"]]
  query_info <- buildBroadConsentRelationQuery(
    source_connection,
    plan_row,
    source_schema,
    source_view_prefix,
    version_key_tables,
    selections,
    reference_targets
  )
  source_result <- tryCatch(
    DBI::dbSendQuery(source_connection, query_info[["query"]]),
    error = function(error) {
      stop(
        "Failed to open Broad Consent source relation ", source_relation_name,
        " as ", materialized_table_name, ": ", conditionMessage(error),
        call. = FALSE
      )
    }
  )
  source_open_seconds <- proc.time()[["elapsed"]] - source_open_started
  on.exit(
    {
      if (DBI::dbIsValid(source_result)) {
        DBI::dbClearResult(source_result)
      }
    },
    add = TRUE
  )

  message(
    "Streaming Broad Consent source relation ",
    snapshotQualifiedName(source_connection, source_relation_name, source_schema),
    " as ", materialized_table_name, " in chunks of ", chunk_size, " rows"
  )
  target <- snapshotRelationId(materialized_table_name, target_table_schema)
  stream_result <- copyBroadConsentChunkStream(
    fetch_chunk = function(fetch_size) {
      tryCatch(
        DBI::dbFetch(source_result, n = fetch_size),
        error = function(error) {
          stop(
            "Failed to fetch Broad Consent source relation ", source_relation_name,
            " as ", materialized_table_name, ": ", conditionMessage(error),
            call. = FALSE
          )
        }
      )
    },
    has_completed = function() DBI::dbHasCompleted(source_result),
    write_chunk = function(chunk, first_chunk) {
      masked <- maskBroadConsentChunkReferences(
        chunk, selections[[plan_row$BASE_TABLE_NAME]],
        materialized_table_name, query_info$mask_columns
      )
      chunk <- masked$chunk
      if (nrow(masked$evidence)) {
        DBI::dbAppendTable(
          target_connection,
          snapshotRelationId(BROAD_CONSENT_MASKED_TABLE, target_table_schema), masked$evidence
        )
      }
      if (isTRUE(first_chunk)) {
        DBI::dbWriteTable(
          target_connection,
          target,
          chunk,
          overwrite = FALSE,
          temporary = FALSE
        )
      } else if (nrow(chunk) > 0L) {
        DBI::dbAppendTable(target_connection, target, chunk)
      }
    },
    chunk_size = chunk_size,
    table_name = materialized_table_name
  )

  summary <- data.table::data.table(
    TABLE_NAME = materialized_table_name,
    BASE_TABLE_NAME = plan_row[["BASE_TABLE_NAME"]],
    SOURCE_RELATION = source_relation_name,
    SNAPSHOT_RELATION_TYPE = plan_row[["SNAPSHOT_RELATION_TYPE"]],
    FILTER_ACTION = query_info[["filter_action"]],
    INPUT_ROWS = query_info$input_rows,
    OUTPUT_ROWS = stream_result[["output_rows"]],
    OUTPUT_COLUMNS = length(selections[[plan_row$BASE_TABLE_NAME]]$fields),
    CHUNKS = stream_result[["chunks"]],
    SOURCE_OPEN_SECONDS = source_open_seconds,
    FETCH_SECONDS = stream_result[["fetch_seconds"]],
    WRITE_SECONDS = stream_result[["write_seconds"]],
    OTHER_SECONDS = stream_result[["other_seconds"]],
    STREAM_SECONDS = stream_result[["stream_seconds"]],
    TOTAL_SECONDS = proc.time()[["elapsed"]] - table_started
  )
  attr(summary, "exclusions") <- query_info$exclusions
  summary
}

writeBroadConsentSnapshotReport <- function(summary, file_name = NA, patients = NULL, exclusions = NULL) {
  sheets <- list(broad_consent_snapshot_summary = summary)
  if (!is.null(patients)) sheets$patient_decisions <- patients
  if (!is.null(exclusions)) sheets$resource_decisions <- exclusions
  writePseudonymizationReportWorkbook(
    sheets,
    file_name = file_name,
    filename_without_extension = "broad_consent_snapshot_report"
  )
  invisible(summary)
}

#' Create a Broad Consent Snapshot Database
#'
#' Materializes the analysis relations of a compatible snapshot database into
#' a separate target database using current Consent permissions and the resource
#' date mapping. References to excluded targets become SQL NULL with permanent
#' masking evidence. The source database is not modified.
#'
#' @param source_connection Source DBI connection.
#' @param target_connection Target DBI connection.
#' @param project_root Repository root used for the snapshot rule sources.
#' @param source_schema Schema containing the source analysis views.
#' @param target_table_schema Target schema for materialized tables.
#' @param target_view_schema Target schema for analysis views.
#' @param source_view_prefix Prefix used for source view names.
#' @param last_version_suffix Suffix used for last-version source views.
#' @param tables Optional character vector limiting the tables to copy.
#' @param chunk_size Maximum number of rows copied at once.
#' @param report_file Optional explicit report path. If `NA`, the report is
#'   written below `outputLocal`.
#' @param consent_details Write optional patient-level CSV evidence.
#' @param evaluation_date Date captured once for the complete selection.
#' @param log_steps If `TRUE` and module logging is initialized, wrap major
#'   steps in the existing logging helpers.
#'
#' @return A list containing the materialization plan, processing summary, and
#'   created-view summary.
#'
#' @export
createBroadConsentSnapshotDatabase <- function(
  source_connection,
  target_connection,
  project_root = ".",
  source_schema = "db2dataprocessor_out",
  target_table_schema = "db_log",
  target_view_schema = "db2dataprocessor_out",
  source_view_prefix = "v_",
  last_version_suffix = SNAPSHOT_LAST_VERSION_SUFFIX,
  tables = NULL,
  chunk_size = DEFAULT_SNAPSHOT_CHUNK_SIZE,
  report_file = NA,
  log_steps = TRUE,
  consent_details = FALSE,
  evaluation_date = Sys.Date()
) {
  force(evaluation_date)
  chunk_size <- validateSnapshotChunkSize(chunk_size)
  rule_sources <- getDefaultSnapshotPseudonymizationRuleSources(project_root = project_root)
  rules <- loadPseudonymizationRules(
    table_descriptions = rule_sources[["table_descriptions"]],
    snapshot_extensions = rule_sources[["snapshot_extensions"]]
  )

  result <- list()
  runPseudonymizationLogStep(2L,
    "Read source database metadata",
    {
      result[["release_version"]] <- getSnapshotReleaseVersion(
        source_connection,
        source_schema = source_schema
      )
      result[["database_content_type"]] <- getSnapshotDatabaseContentType(
        source_connection,
        source_schema = source_schema
      )
    },
    log_steps = log_steps
  )
  runPseudonymizationLogStep(2L,
    "Plan Broad Consent snapshot source relations",
    {
      result[["materialization_plan"]] <- getExistingSnapshotMaterializationPlan(
        source_connection,
        rules = rules,
        source_schema = source_schema,
        source_view_prefix = source_view_prefix,
        last_version_suffix = last_version_suffix,
        tables = tables
      )
    },
    log_steps = log_steps
  )

  snapshotEnsureSchema(target_connection, target_table_schema)
  snapshotAllowTemporarySourceTables(source_connection)
  version_key_tables <- list()
  runPseudonymizationLogStep(2L,
    "Prepare Broad Consent snapshot version partitions",
    {
      version_key_tables <- prepareSnapshotVersionKeyTables(
        connection = source_connection,
        materialization_plan = result[["materialization_plan"]],
        source_schema = source_schema
      )
    },
    log_steps = log_steps
  )
  on.exit(dropSnapshotVersionKeyTables(source_connection, version_key_tables), add = TRUE)
  source_name <- DBI::dbGetQuery(source_connection, "SELECT current_database() AS name")$name
  review <- newBroadConsentReview(
    tempfile(
      pattern = paste0(format(Sys.time(), "%Y%m%d_%H%M%S"), "_"),
      tmpdir = file.path(project_root, "outputLocal", "broad_consent_snapshot")
    ),
    evaluation_date, source_name,
    details = consent_details
  )
  consent_selection <- prepareBroadConsentSelection(
    source_connection, source_schema, evaluation_date, chunk_size, review,
    source_view_prefix, last_version_suffix
  )
  on.exit(DBI::dbRemoveTable(source_connection, consent_selection$table_name), add = TRUE)
  selections <- prepareBroadConsentResourceSelection(
    source_connection, result$materialization_plan, rules,
    source_schema, source_view_prefix, snapshotQualifiedName(source_connection, consent_selection$table_name)
  )
  on.exit(dropSnapshotVersionKeyTables(source_connection, lapply(selections, `[[`, "table_name")), add = TRUE)
  reference_targets <- prepareBroadConsentReferenceTargets(
    source_connection, selections,
    result$materialization_plan, source_schema
  )
  on.exit(DBI::dbRemoveTable(source_connection, reference_targets), add = TRUE)
  DBI::dbWriteTable(target_connection, snapshotRelationId(BROAD_CONSENT_MASKED_TABLE, target_table_schema),
    emptyBroadConsentMaskedReferences(),
    overwrite = FALSE
  )
  copyBroadConsentPriorEvidence(
    source_connection, target_connection, selections, result$materialization_plan,
    source_schema, target_table_schema, source_view_prefix, chunk_size
  )
  result$patient_summary <- consent_selection$summary
  result$evaluation_date <- evaluation_date
  result$review_directory <- review$directory

  summary_rows <- list()
  runPseudonymizationLogStep(2L,
    "Stream Broad Consent snapshot tables",
    {
      for (i in seq_len(nrow(result[["materialization_plan"]]))) {
        summary_rows[[length(summary_rows) + 1L]] <- streamBroadConsentSnapshotTable(
          source_connection = source_connection,
          target_connection = target_connection,
          plan_row = result[["materialization_plan"]][i, ],
          source_schema = source_schema,
          target_table_schema = target_table_schema,
          source_view_prefix = source_view_prefix,
          chunk_size = chunk_size,
          version_key_tables = version_key_tables,
          selections = selections,
          reference_targets = reference_targets
        )
      }
    },
    log_steps = log_steps
  )
  result[["summary"]] <- data.table::rbindlist(summary_rows, fill = TRUE)
  result$resource_decisions <- data.table::rbindlist(lapply(seq_along(summary_rows), function(i) {
    decisions <- data.table::as.data.table(attr(summary_rows[[i]], "exclusions"))
    decisions$table_name <- rep(result$materialization_plan$MATERIALIZED_TABLE_NAME[i], nrow(decisions))
    decisions
  }))

  runPseudonymizationLogStep(2L,
    "Write Broad Consent snapshot report",
    writeBroadConsentSnapshotReport(
      result[["summary"]],
      file_name = report_file,
      patients = result$patient_summary, exclusions = result$resource_decisions
    ),
    log_steps = log_steps
  )
  runPseudonymizationLogStep(2L,
    "Create Broad Consent snapshot views",
    {
      passthrough_summary <- createSnapshotPassthroughViews(
        target_connection,
        materialization_plan = result[["materialization_plan"]],
        table_schema = target_table_schema,
        view_schema = target_view_schema
      )
      version_summary <- createSnapshotVersionView(
        target_connection,
        release_version = result[["release_version"]],
        view_schema = target_view_schema,
        database_content_type = result[["database_content_type"]]
      )
      result[["view_summary"]] <- data.table::rbindlist(list(
        passthrough_summary,
        version_summary
      ))
    },
    log_steps = log_steps
  )

  DBI::dbExecute(target_connection, paste0(
    "CREATE UNIQUE INDEX ON ",
    snapshotQualifiedName(target_connection, BROAD_CONSENT_MASKED_TABLE, target_table_schema),
    " (table_name, row_id, column_name)"
  ))
  DBI::dbExecute(target_connection, paste0(
    "CREATE VIEW ",
    snapshotQualifiedName(target_connection, paste0(source_view_prefix, BROAD_CONSENT_MASKED_TABLE), target_view_schema),
    " AS SELECT * FROM ", snapshotQualifiedName(target_connection, BROAD_CONSENT_MASKED_TABLE, target_table_schema)
  ))
  DBI::dbWriteTable(
    target_connection, snapshotRelationId("broad_consent_run", target_table_schema),
    data.frame(
      source_database = source_name, evaluation_date = evaluation_date,
      torch_commit = "b12757d09a525ae1a3309e4aded999b209b1d600", completed_at = Sys.time()
    )
  )
  result
}
