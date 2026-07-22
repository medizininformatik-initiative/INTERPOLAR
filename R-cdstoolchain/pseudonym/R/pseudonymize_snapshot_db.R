snapshotRuleTables <- function(rules) {
  snapshotRuleTablePlan(rules)[["DB_TABLE_NAME"]]
}

snapshotRuleTablePlan <- function(rules) {
  rules <- data.table::as.data.table(rules)
  if (!"TABLE_OR_RESOURCE" %in% names(rules)) {
    stop("rules must contain TABLE_OR_RESOURCE.")
  }
  if (!"SOURCE_TYPE" %in% names(rules)) {
    rules[["SOURCE_TYPE"]] <- "table_description"
  }
  if (!"SOURCE" %in% names(rules)) {
    rules[["SOURCE"]] <- NA_character_
  }
  table_rows <- rules[rules[["SOURCE_TYPE"]] == "table_description", ]
  result <- unique(data.table::data.table(
    RULE_TABLE_NAME = tolower(table_rows[["TABLE_OR_RESOURCE"]]),
    RULE_SOURCE = table_rows[["SOURCE"]]
  ))
  result <- result[
    !is.na(result[["RULE_TABLE_NAME"]]) & nzchar(result[["RULE_TABLE_NAME"]]), ,
    drop = FALSE
  ]
  is_frontend_source <- !is.na(result[["RULE_SOURCE"]]) &
    result[["RULE_SOURCE"]] == "frontend" &
    !endsWith(result[["RULE_TABLE_NAME"]], "_fe")
  result[["DB_TABLE_NAME"]] <- data.table::fifelse(
    is_frontend_source,
    paste0(result[["RULE_TABLE_NAME"]], "_fe"),
    result[["RULE_TABLE_NAME"]]
  )
  unique(result[, c("RULE_TABLE_NAME", "RULE_SOURCE", "DB_TABLE_NAME"), with = FALSE])
}

snapshotQualifiedName <- function(connection, name, schema = NULL) {
  if (!is.null(schema) && !is.na(schema) && nzchar(schema)) {
    return(as.character(DBI::dbQuoteIdentifier(connection, DBI::Id(schema = schema, table = name))))
  }
  as.character(DBI::dbQuoteIdentifier(connection, name))
}

snapshotEnsureSchema <- function(connection, schema) {
  if (!is.null(schema) && !is.na(schema) && nzchar(schema)) {
    quoted_schema <- as.character(DBI::dbQuoteIdentifier(connection, schema))
    statement <- paste0("CREATE SCHEMA IF NOT EXISTS ", quoted_schema)
    DBI::dbExecute(connection, statement)
  }
}

snapshotRelationExists <- function(connection, name, schema = NULL) {
  relation <- if (!is.null(schema) && !is.na(schema) && nzchar(schema)) {
    DBI::Id(schema = schema, table = name)
  } else {
    name
  }
  DBI::dbExistsTable(connection, relation)
}

#' Build Source Relation Plan for Snapshot Pseudonymization
#'
#' This derives the database read plan from loaded pseudonymization rules. Only
#' normal table-description sources define input tables; snapshot-extension
#' rules describe columns that are added during snapshot creation and therefore
#' do not create additional source relations.
#'
#' @param rules Rules loaded by `loadPseudonymizationRules()`.
#' @param source_view_prefix Prefix used for source view names.
#' @param last_version_suffix Suffix used for last-version source views and
#'   materialized target tables.
#' @param tables Optional character vector limiting the tables to read.
#'
#' @return A data.table with one row for each materialized source relation.
#' @export
getSnapshotSourceViewPlan <- function(
  rules,
  source_view_prefix = "v_",
  last_version_suffix = "_last_version",
  tables = NULL
) {
  table_plan <- snapshotRuleTablePlan(rules)
  if (!is.null(tables)) {
    table_plan <- table_plan[
      tolower(table_plan[["DB_TABLE_NAME"]]) %in% tolower(tables) |
        tolower(table_plan[["RULE_TABLE_NAME"]]) %in% tolower(tables), ,
      drop = FALSE
    ]
  }
  plan <- data.table::rbindlist(list(
    data.table::data.table(
      BASE_TABLE_NAME = table_plan[["DB_TABLE_NAME"]],
      RULE_TABLE_NAME = table_plan[["RULE_TABLE_NAME"]],
      RULE_SOURCE = table_plan[["RULE_SOURCE"]],
      MATERIALIZED_TABLE_NAME = table_plan[["DB_TABLE_NAME"]],
      SOURCE_RELATION = paste0(source_view_prefix, table_plan[["DB_TABLE_NAME"]]),
      TARGET_VIEW_NAME = paste0(source_view_prefix, table_plan[["DB_TABLE_NAME"]]),
      SNAPSHOT_RELATION_TYPE = "all"
    ),
    data.table::data.table(
      BASE_TABLE_NAME = table_plan[["DB_TABLE_NAME"]],
      RULE_TABLE_NAME = table_plan[["RULE_TABLE_NAME"]],
      RULE_SOURCE = table_plan[["RULE_SOURCE"]],
      MATERIALIZED_TABLE_NAME = paste0(table_plan[["DB_TABLE_NAME"]], last_version_suffix),
      SOURCE_RELATION = paste0(
        source_view_prefix,
        table_plan[["DB_TABLE_NAME"]],
        last_version_suffix
      ),
      TARGET_VIEW_NAME = paste0(
        source_view_prefix,
        table_plan[["DB_TABLE_NAME"]],
        last_version_suffix
      ),
      SNAPSHOT_RELATION_TYPE = "last_version"
    )
  ))
  plan[
    ,
    c(
      "BASE_TABLE_NAME",
      "RULE_TABLE_NAME",
      "RULE_SOURCE",
      "MATERIALIZED_TABLE_NAME",
      "SOURCE_RELATION",
      "TARGET_VIEW_NAME",
      "SNAPSHOT_RELATION_TYPE"
    ),
    with = FALSE
  ]
}

pseudonymizeSnapshotMaterializedTables <- function(
  tables,
  materialization_plan,
  rules,
  input_repo_path,
  keep_unmatched_columns,
  log_steps
) {
  result_tables <- list()
  summary_rows <- list()

  for (i in seq_len(nrow(materialization_plan))) {
    materialized_table_name <- materialization_plan[["MATERIALIZED_TABLE_NAME"]][i]
    base_table_name <- materialization_plan[["BASE_TABLE_NAME"]][i]
    rule_table_name <- materialization_plan[["RULE_TABLE_NAME"]][i]
    rule_source <- materialization_plan[["RULE_SOURCE"]][i]
    table_result <- runPseudonymizationLogStep(
      3L,
      paste0("Pseudonymize table ", materialized_table_name),
      pseudonymizeTableForSnapshot(
        tables[[materialized_table_name]],
        rules,
        rule_table_name,
        rule_source,
        input_repo_path,
        keep_unmatched_columns
      ),
      log_steps = log_steps
    )
    table_result[["summary"]][["TABLE_NAME"]] <- materialized_table_name
    table_result[["summary"]][["BASE_TABLE_NAME"]] <- base_table_name
    table_result[["summary"]][["RULE_TABLE_NAME"]] <- rule_table_name
    table_result[["summary"]][["RULE_SOURCE"]] <- rule_source
    table_result[["summary"]][["SNAPSHOT_RELATION_TYPE"]] <-
      materialization_plan[["SNAPSHOT_RELATION_TYPE"]][i]
    result_tables[[materialized_table_name]] <- table_result[["table"]]
    summary_rows[[length(summary_rows) + 1L]] <- table_result[["summary"]]
  }

  list(
    tables = result_tables,
    summary = if (length(summary_rows) > 0) {
      data.table::rbindlist(summary_rows, fill = TRUE)
    } else {
      data.table::data.table()
    }
  )
}

setSummaryValue <- function(summary, row_index, column_name, value) {
  if (!column_name %in% names(summary)) {
    if (is.integer(value)) {
      summary[[column_name]] <- rep(NA_integer_, nrow(summary))
    } else if (is.numeric(value)) {
      summary[[column_name]] <- rep(NA_real_, nrow(summary))
    } else {
      summary[[column_name]] <- rep(NA_character_, nrow(summary))
    }
  }
  summary[row_index, column_name] <- value
  summary
}

postprocessPseudonymizedSnapshotTables <- function(pseudonymization_result) {
  summary <- as.data.frame(
    data.table::copy(pseudonymization_result[["summary"]]),
    stringsAsFactors = FALSE
  )

  for (table_name in names(pseudonymization_result[["tables"]])) {
    table <- data.table::as.data.table(data.table::copy(
      pseudonymization_result[["tables"]][[table_name]]
    ))
    row_index <- which(summary[["TABLE_NAME"]] == table_name)
    if (length(row_index) == 1) {
      summary <- setSummaryValue(
        summary,
        row_index,
        "ORIGINAL_COLUMNS_REMOVED",
        0L
      )
      summary <- setSummaryValue(
        summary,
        row_index,
        "DUPLICATE_ROWS_REMOVED",
        0L
      )
      summary <- setSummaryValue(
        summary,
        row_index,
        "POSTPROCESSING_ACTION",
        "none"
      )
      summary <- setSummaryValue(
        summary,
        row_index,
        "OUTPUT_COLUMNS",
        length(names(table))
      )
    }
  }

  pseudonymization_result[["summary"]] <- data.table::as.data.table(summary)
  pseudonymization_result
}

#' Read Snapshot Source Tables from a Database Connection
#'
#' Reads all source views from a DBI connection according to
#' `getSnapshotSourceViewPlan()`. The default source relations are
#' `v_<table>` and `v_<table>_last_version`.
#'
#' @param connection Source DBI connection.
#' @param rules Rules loaded by `loadPseudonymizationRules()`.
#' @param source_schema Optional schema containing the source views.
#' @param source_view_prefix Prefix used for the source view names.
#' @param last_version_suffix Suffix used for last-version source views and
#'   materialized target tables.
#' @param tables Optional character vector limiting the tables to read.
#'
#' @return A named list of data.tables.
#' @export
readSnapshotSourceTables <- function(
  connection,
  rules,
  source_schema = NULL,
  source_view_prefix = "v_",
  last_version_suffix = "_last_version",
  tables = NULL
) {
  plan <- getSnapshotSourceViewPlan(
    rules = rules,
    source_view_prefix = source_view_prefix,
    last_version_suffix = last_version_suffix,
    tables = tables
  )

  result <- list()
  existing_plan_rows <- rep(FALSE, nrow(plan))
  for (i in seq_len(nrow(plan))) {
    source_relation_name <- plan[["SOURCE_RELATION"]][i]
    materialized_table_name <- plan[["MATERIALIZED_TABLE_NAME"]][i]
    relation_type <- plan[["SNAPSHOT_RELATION_TYPE"]][i]
    if (!snapshotRelationExists(connection, source_relation_name, source_schema)) {
      if (identical(relation_type, "last_version")) {
        next
      }
      stop("Required source relation does not exist: ", source_relation_name)
    }
    relation <- snapshotQualifiedName(connection, source_relation_name, source_schema)
    query <- paste0("SELECT * FROM ", relation)
    message(
      "Reading snapshot source relation ", relation,
      " as ", materialized_table_name,
      " (", relation_type, ")"
    )
    table_data <- tryCatch(
      data.table::as.data.table(DBI::dbGetQuery(connection, query)),
      error = function(error) {
        stop(
          "Failed to read snapshot source relation ", relation,
          " as ", materialized_table_name,
          ": ", conditionMessage(error),
          call. = FALSE
        )
      }
    )
    message(
      "Read snapshot source relation ", relation,
      " as ", materialized_table_name,
      ": ", nrow(table_data), " rows, ", length(names(table_data)), " columns"
    )
    result[[materialized_table_name]] <- table_data
    existing_plan_rows[i] <- TRUE
  }
  attr(result, "materialization_plan") <- plan[existing_plan_rows, , drop = FALSE]

  result
}

#' Write Pseudonymized Snapshot Tables to a Database Connection
#'
#' Writes a named list of pseudonymized tables to a target DBI connection. Table
#' names are taken from the list names and can optionally be written to a target
#' schema.
#'
#' @param connection Target DBI connection.
#' @param tables Named list of data.frames or data.tables.
#' @param target_schema Optional target schema.
#' @param overwrite Passed to `DBI::dbWriteTable()`.
#' @param temporary Passed to `DBI::dbWriteTable()`.
#'
#' @return A data.table with one row per written table.
#' @export
writeSnapshotTargetTables <- function(
  connection,
  tables,
  target_schema = "db_log",
  overwrite = FALSE,
  temporary = FALSE
) {
  if (is.null(names(tables)) || any(!nzchar(names(tables)))) {
    stop("tables must be a named list.")
  }
  snapshotEnsureSchema(connection, target_schema)

  summary <- data.table::data.table(
    TABLE_NAME = character(),
    ROWS = integer(),
    COLUMNS = integer(),
    STATUS = character()
  )

  summary_rows <- list()
  for (table_name in names(tables)) {
    if (!isTRUE(overwrite) && snapshotRelationExists(connection, table_name, target_schema)) {
      stop("Target table already exists: ", snapshotQualifiedName(connection, table_name, target_schema))
    }
    target <- if (!is.null(target_schema) && !is.na(target_schema) && nzchar(target_schema)) {
      DBI::Id(schema = target_schema, table = table_name)
    } else {
      table_name
    }
    DBI::dbWriteTable(
      connection,
      target,
      as.data.frame(tables[[table_name]]),
      overwrite = overwrite,
      temporary = temporary
    )
    summary_rows[[length(summary_rows) + 1L]] <- data.table::data.table(
      TABLE_NAME = table_name,
      ROWS = nrow(tables[[table_name]]),
      COLUMNS = length(names(tables[[table_name]])),
      STATUS = "written"
    )
  }

  if (length(summary_rows) > 0) {
    summary <- data.table::rbindlist(summary_rows)
  }
  summary
}

#' Create Passthrough Views for Pseudonymized Snapshot Tables
#'
#' Creates `db2dataprocessor_out.v_<table>` style views that directly select
#' from the materialized pseudonymized tables in `db_log`.
#'
#' @param connection Target DBI connection.
#' @param materialization_plan Plan returned by `getSnapshotSourceViewPlan()`.
#' @param table_schema Schema containing materialized pseudonymized tables.
#' @param view_schema Schema containing passthrough views.
#' @param replace If `TRUE`, existing views are replaced.
#'
#' @return A data.table with one row per created view.
#' @export
createSnapshotPassthroughViews <- function(
  connection,
  materialization_plan,
  table_schema = "db_log",
  view_schema = "db2dataprocessor_out",
  replace = FALSE
) {
  snapshotEnsureSchema(connection, view_schema)

  summary <- data.table::data.table(
    VIEW_NAME = character(),
    SOURCE_TABLE = character(),
    STATUS = character()
  )

  summary_rows <- list()
  for (i in seq_len(nrow(materialization_plan))) {
    view_name <- materialization_plan[["TARGET_VIEW_NAME"]][i]
    source_table <- materialization_plan[["MATERIALIZED_TABLE_NAME"]][i]
    if (!isTRUE(replace) && snapshotRelationExists(connection, view_name, view_schema)) {
      stop("Target view already exists: ", snapshotQualifiedName(connection, view_name, view_schema))
    }
    statement <- paste0(
      "CREATE ",
      if (isTRUE(replace)) "OR REPLACE " else "",
      "VIEW ",
      snapshotQualifiedName(connection, view_name, view_schema),
      " AS SELECT * FROM ",
      snapshotQualifiedName(connection, source_table, table_schema)
    )
    DBI::dbExecute(connection, statement)
    summary_rows[[length(summary_rows) + 1L]] <- data.table::data.table(
      VIEW_NAME = view_name,
      SOURCE_TABLE = source_table,
      STATUS = "created"
    )
  }

  if (length(summary_rows) > 0) {
    summary <- data.table::rbindlist(summary_rows)
  }
  summary
}

writePseudonymizationReportWorkbook <- function(
  report_tables,
  file_name = NA,
  filename_without_extension,
  subdir = "reports"
) {
  if (is.na(file_name)) {
    etlutils::writeExcelFileLocal(
      report_tables,
      filename_without_extension = filename_without_extension,
      with_column_names = TRUE,
      subdir = subdir
    )
  } else {
    output_dir <- dirname(file_name)
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    }
    etlutils::writeExcelFile(
      report_tables,
      file_name,
      with_column_names = TRUE
    )
  }
}

writeSnapshotEnrichmentReviewReport <- function(report, file_name = NA) {
  report_tables <- list(unmatched_medication_references = report)
  writePseudonymizationReportWorkbook(
    report_tables,
    file_name = file_name,
    filename_without_extension = "snapshot_enrichment_review"
  )
  invisible(report)
}

writeSnapshotPostprocessingReport <- function(summary, file_name = NA) {
  report_tables <- list(snapshot_postprocessing_summary = summary)
  writePseudonymizationReportWorkbook(
    report_tables,
    file_name = file_name,
    filename_without_extension = "snapshot_postprocessing_report"
  )
  invisible(summary)
}

#' Pseudonymize a Snapshot from Source DB to Target DB Connections
#'
#' This is the DBI-based entry point for the snapshot pseudonymization core. It
#' loads rule sources, reads `v_<table>` and `v_<table>_last_version` from the
#' source connection, materializes pseudonymized tables in `db_log`, and creates
#' passthrough views in `db2dataprocessor_out`. Opening the source/target
#' databases from site-specific TOML files remains a caller responsibility.
#'
#' @param source_connection Source DBI connection.
#' @param target_connection Target DBI connection.
#' @param table_descriptions Rule source specification. If `NULL`, the default
#'   INTERPOLAR snapshot rule sources from `project_root` are used.
#' @param snapshot_extensions Optional snapshot-extension rule source
#'   specification. Ignored when `table_descriptions` is `NULL` and defaults are
#'   used.
#' @param project_root Repository root used for default rule sources.
#' @param input_repo_path TOML-configured input repository directory used for
#'   `pseudonym(sheet = ...)` mapping rules.
#' @param source_schema Optional schema containing source views.
#' @param target_table_schema Target schema for materialized pseudonymized tables.
#' @param target_view_schema Target schema for passthrough analysis views.
#' @param source_view_prefix Prefix used for source view names.
#' @param last_version_suffix Suffix used for last-version source views and
#'   materialized target tables.
#' @param tables Optional character vector limiting tables to read.
#' @param enrich_tables Optional function called with the named source-table
#'   list before pseudonymization. It must return a named table list.
#' @param fail_on_review_problems Passed to `pseudonymizeSnapshotTables()`.
#' @param write_review_report Passed to `pseudonymizeSnapshotTables()`.
#' @param review_report_file Passed to `pseudonymizeSnapshotTables()`.
#' @param enrichment_review_report_file Optional explicit enrichment review
#'   report path. If `NA`, the report is written to
#'   `outputLocal/<MODULE>/reports`.
#' @param postprocessing_report_file Optional explicit snapshot postprocessing
#'   report path. If `NA`, the report is written to
#'   `outputLocal/<MODULE>/reports`.
#' @param keep_unmatched_columns Passed to `pseudonymizeSnapshotTables()`. The
#'   default keeps original source columns without a loaded rule unchanged.
#' @param overwrite_tables Passed to `writeSnapshotTargetTables()`.
#' @param replace_views Passed to `createSnapshotPassthroughViews()`.
#' @param temporary Passed to `writeSnapshotTargetTables()`.
#' @param log_steps If `TRUE` and module logging is initialized, wrap major
#'   steps in the existing `etlutils::runLevel...` logging.
#'
#' @return A list with source tables, pseudonymization result, and write summary.
#' @export
pseudonymizeSnapshotDatabase <- function(
  source_connection,
  target_connection,
  table_descriptions = NULL,
  snapshot_extensions = NULL,
  project_root = ".",
  input_repo_path = NULL,
  source_schema = NULL,
  target_table_schema = "db_log",
  target_view_schema = "db2dataprocessor_out",
  source_view_prefix = "v_",
  last_version_suffix = "_last_version",
  tables = NULL,
  enrich_tables = NULL,
  fail_on_review_problems = TRUE,
  write_review_report = TRUE,
  review_report_file = NA,
  enrichment_review_report_file = NA,
  postprocessing_report_file = NA,
  keep_unmatched_columns = TRUE,
  overwrite_tables = FALSE,
  replace_views = FALSE,
  temporary = FALSE,
  log_steps = TRUE
) {
  if (is.null(table_descriptions)) {
    rule_sources <- getDefaultSnapshotPseudonymizationRuleSources(project_root = project_root)
    table_descriptions <- rule_sources[["table_descriptions"]]
    snapshot_extensions <- rule_sources[["snapshot_extensions"]]
  }

  result <- list()
  runPseudonymizationLogStep(2L,
    "Load pseudonymization rules for snapshot DB",
    {
      result[["rules"]] <- loadPseudonymizationRules(
        table_descriptions = table_descriptions,
        snapshot_extensions = snapshot_extensions
      )
    },
    log_steps = log_steps
  )

  runPseudonymizationLogStep(2L,
    "Read snapshot source tables",
    {
      result[["source_tables"]] <- readSnapshotSourceTables(
        source_connection,
        rules = result[["rules"]],
        source_schema = source_schema,
        source_view_prefix = source_view_prefix,
        last_version_suffix = last_version_suffix,
        tables = tables
      )
    },
    log_steps = log_steps
  )

  if (!is.null(enrich_tables)) {
    runPseudonymizationLogStep(2L,
      "Enrich snapshot source tables",
      {
        result[["source_tables"]] <- enrich_tables(result[["source_tables"]])
      },
      log_steps = log_steps
    )
  }

  runPseudonymizationLogStep(2L,
    "Review snapshot enrichment",
    {
      result[["enrichment_review_report"]] <- list(
        unmatched_medication_references = getSnapshotMedicationReferenceReview(result[["source_tables"]])
      )
      if (isTRUE(write_review_report)) {
        writeSnapshotEnrichmentReviewReport(
          result[["enrichment_review_report"]][["unmatched_medication_references"]],
          file_name = enrichment_review_report_file
        )
      }
    },
    log_steps = log_steps
  )

  runPseudonymizationLogStep(2L,
    "Review pseudonymization rules",
    {
      result[["review_report"]] <- getPseudonymizationRuleReviewReport(
        result[["rules"]],
        input_repo_path = input_repo_path
      )
      if (isTRUE(write_review_report)) {
        writePseudonymizationRuleReviewReport(
          result[["rules"]],
          file_name = review_report_file,
          input_repo_path = input_repo_path
        )
      }
      if (
        isTRUE(fail_on_review_problems) &&
          pseudonymizationReviewHasBlockingProblems(result[["review_report"]])
      ) {
        stop(
          "Pseudonymization rule review contains blocking problems:\n",
          paste(summarizePseudonymizationReviewProblems(result[["review_report"]]), collapse = "\n")
        )
      }
    },
    log_steps = log_steps
  )

  materialization_plan <- attr(result[["source_tables"]], "materialization_plan")
  result[["pseudonymization"]] <- runPseudonymizationLogStep(
    2L,
    "Pseudonymize snapshot tables",
    pseudonymizeSnapshotMaterializedTables(
      tables = result[["source_tables"]],
      materialization_plan = materialization_plan,
      rules = result[["rules"]],
      input_repo_path = input_repo_path,
      keep_unmatched_columns = keep_unmatched_columns,
      log_steps = log_steps
    ),
    log_steps = log_steps
  )

  runPseudonymizationLogStep(2L,
    "Postprocess pseudonymized snapshot tables",
    {
      result[["pseudonymization"]] <- postprocessPseudonymizedSnapshotTables(
        result[["pseudonymization"]]
      )
      result[["postprocessing_report"]] <- result[["pseudonymization"]][["summary"]]
      if (isTRUE(write_review_report)) {
        writeSnapshotPostprocessingReport(
          result[["postprocessing_report"]],
          file_name = postprocessing_report_file
        )
      }
    },
    log_steps = log_steps
  )

  runPseudonymizationLogStep(2L,
    "Write pseudonymized snapshot tables",
    {
      result[["write_summary"]] <- writeSnapshotTargetTables(
        target_connection,
        result[["pseudonymization"]][["tables"]],
        target_schema = target_table_schema,
        overwrite = overwrite_tables,
        temporary = temporary
      )
    },
    log_steps = log_steps
  )

  runPseudonymizationLogStep(2L,
    "Create snapshot passthrough views",
    {
      result[["view_summary"]] <- createSnapshotPassthroughViews(
        target_connection,
        materialization_plan = materialization_plan,
        table_schema = target_table_schema,
        view_schema = target_view_schema,
        replace = replace_views
      )
    },
    log_steps = log_steps
  )

  result
}
