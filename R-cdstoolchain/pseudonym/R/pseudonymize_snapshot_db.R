snapshotRuleTables <- function(rules) {
  rules <- data.table::as.data.table(rules)
  if (!"TABLE_OR_RESOURCE" %in% names(rules)) {
    stop("rules must contain TABLE_OR_RESOURCE.")
  }
  if (!"SOURCE_TYPE" %in% names(rules)) {
    rules[["SOURCE_TYPE"]] <- "table_description"
  }
  unique(stats::na.omit(rules[
    rules[["SOURCE_TYPE"]] == "table_description",
    "TABLE_OR_RESOURCE",
    drop = TRUE
  ]))
}

snapshotQualifiedName <- function(connection, name, schema = NULL) {
  if (!is.null(schema) && !is.na(schema) && nzchar(schema)) {
    return(as.character(DBI::dbQuoteIdentifier(connection, DBI::Id(schema = schema, table = name))))
  }
  as.character(DBI::dbQuoteIdentifier(connection, name))
}

#' Build Source View Plan for Snapshot Pseudonymization
#'
#' This derives the database read plan from loaded pseudonymization rules. Only
#' normal table-description sources define input tables; snapshot-extension
#' rules describe columns that are added during snapshot creation and therefore
#' do not create additional source relations.
#'
#' @param rules Rules loaded by `loadPseudonymizationRules()`.
#' @param source_view_prefix Prefix used for the source view names.
#' @param source_view_suffix Suffix used for the source view names.
#' @param tables Optional character vector limiting the tables to read.
#'
#' @return A data.table with `TABLE_NAME` and `SOURCE_RELATION`.
#' @export
getSnapshotSourceViewPlan <- function(
    rules,
    source_view_prefix = "v_",
    source_view_suffix = "_last_version",
    tables = NULL) {
  table_names <- snapshotRuleTables(rules)
  if (!is.null(tables)) {
    table_names <- table_names[tolower(table_names) %in% tolower(tables)]
  }
  data.table::data.table(
    TABLE_NAME = table_names,
    SOURCE_RELATION = paste0(source_view_prefix, table_names, source_view_suffix)
  )
}

#' Read Snapshot Source Tables from a Database Connection
#'
#' Reads all source views from a DBI connection according to
#' `getSnapshotSourceViewPlan()`. The default relation naming convention is
#' `v_<table>_last_version`, matching the analysis-facing last-version views.
#'
#' @param connection Source DBI connection.
#' @param rules Rules loaded by `loadPseudonymizationRules()`.
#' @param source_schema Optional schema containing the source views.
#' @param source_view_prefix Prefix used for the source view names.
#' @param source_view_suffix Suffix used for the source view names.
#' @param tables Optional character vector limiting the tables to read.
#'
#' @return A named list of data.tables.
#' @export
readSnapshotSourceTables <- function(
    connection,
    rules,
    source_schema = NULL,
    source_view_prefix = "v_",
    source_view_suffix = "_last_version",
    tables = NULL) {
  plan <- getSnapshotSourceViewPlan(
    rules = rules,
    source_view_prefix = source_view_prefix,
    source_view_suffix = source_view_suffix,
    tables = tables
  )

  result <- vector("list", nrow(plan))
  names(result) <- plan[["TABLE_NAME"]]
  for (i in seq_len(nrow(plan))) {
    relation <- snapshotQualifiedName(connection, plan[["SOURCE_RELATION"]][i], source_schema)
    query <- paste0("SELECT * FROM ", relation)
    result[[plan[["TABLE_NAME"]][i]]] <- data.table::as.data.table(DBI::dbGetQuery(connection, query))
  }

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
    target_schema = NULL,
    overwrite = TRUE,
    temporary = FALSE) {
  if (is.null(names(tables)) || any(!nzchar(names(tables)))) {
    stop("tables must be a named list.")
  }

  summary <- data.table::data.table(
    TABLE_NAME = character(),
    ROWS = integer(),
    COLUMNS = integer(),
    STATUS = character()
  )

  for (table_name in names(tables)) {
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
    summary <- data.table::rbindlist(list(
      summary,
      data.table::data.table(
        TABLE_NAME = table_name,
        ROWS = nrow(tables[[table_name]]),
        COLUMNS = length(names(tables[[table_name]])),
        STATUS = "written"
      )
    ))
  }

  summary
}

#' Pseudonymize a Snapshot from Source DB to Target DB Connections
#'
#' This is the DBI-based entry point for the snapshot pseudonymization core. It
#' loads rule sources, reads the matching last-version source views, runs
#' `pseudonymizeSnapshotTables()`, and writes the resulting tables to the target
#' connection. Opening the source/target databases from site-specific TOML files
#' remains a caller responsibility.
#'
#' @param source_connection Source DBI connection.
#' @param target_connection Target DBI connection.
#' @param table_descriptions Rule source specification. If `NULL`, the default
#'   INTERPOLAR snapshot rule sources from `project_root` are used.
#' @param snapshot_extensions Optional snapshot-extension rule source
#'   specification. Ignored when `table_descriptions` is `NULL` and defaults are
#'   used.
#' @param project_root Repository root used for default rule sources.
#' @param salt Salt used for `cryptoHash` and `pseudonymize(...)` rules.
#' @param input_repo_path TOML-configured input repository directory used for
#'   `pseudonym(sheet = ...)` mapping rules.
#' @param source_schema Optional schema containing source last-version views.
#' @param target_schema Optional target schema.
#' @param source_view_prefix Prefix used for source view names.
#' @param source_view_suffix Suffix used for source view names.
#' @param tables Optional character vector limiting tables to read.
#' @param enrich_tables Optional function called with the named source-table
#'   list before pseudonymization. It must return a named table list.
#' @param fail_on_review_problems Passed to `pseudonymizeSnapshotTables()`.
#' @param write_review_report Passed to `pseudonymizeSnapshotTables()`.
#' @param review_report_file Passed to `pseudonymizeSnapshotTables()`.
#' @param keep_unmatched_columns Passed to `pseudonymizeSnapshotTables()`.
#' @param overwrite Passed to `writeSnapshotTargetTables()`.
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
    salt = NULL,
    input_repo_path = NULL,
    source_schema = NULL,
    target_schema = NULL,
    source_view_prefix = "v_",
    source_view_suffix = "_last_version",
    tables = NULL,
    enrich_tables = NULL,
    fail_on_review_problems = TRUE,
    write_review_report = TRUE,
    review_report_file = NA,
    keep_unmatched_columns = FALSE,
    overwrite = TRUE,
    temporary = FALSE,
    log_steps = TRUE) {
  if (is.null(table_descriptions)) {
    rule_sources <- getDefaultSnapshotPseudonymizationRuleSources(project_root = project_root)
    table_descriptions <- rule_sources[["table_descriptions"]]
    snapshot_extensions <- rule_sources[["snapshot_extensions"]]
  }

  result <- list()
  runPseudonymizationLogStep(2L, "Load pseudonymization rules for snapshot DB", {
    result[["rules"]] <- loadPseudonymizationRules(
      table_descriptions = table_descriptions,
      snapshot_extensions = snapshot_extensions
    )
  }, log_steps = log_steps)

  runPseudonymizationLogStep(2L, "Read snapshot source tables", {
    result[["source_tables"]] <- readSnapshotSourceTables(
      source_connection,
      rules = result[["rules"]],
      source_schema = source_schema,
      source_view_prefix = source_view_prefix,
      source_view_suffix = source_view_suffix,
      tables = tables
    )
  }, log_steps = log_steps)

  if (!is.null(enrich_tables)) {
    runPseudonymizationLogStep(2L, "Enrich snapshot source tables", {
      result[["source_tables"]] <- enrich_tables(result[["source_tables"]])
    }, log_steps = log_steps)
  }

  result[["pseudonymization"]] <- pseudonymizeSnapshotTables(
    tables = result[["source_tables"]],
    table_descriptions = table_descriptions,
    snapshot_extensions = snapshot_extensions,
    rules = result[["rules"]],
    salt = salt,
    input_repo_path = input_repo_path,
    fail_on_review_problems = fail_on_review_problems,
    write_review_report = write_review_report,
    review_report_file = review_report_file,
    keep_unmatched_columns = keep_unmatched_columns,
    log_steps = log_steps
  )

  runPseudonymizationLogStep(2L, "Write pseudonymized snapshot tables", {
    result[["write_summary"]] <- writeSnapshotTargetTables(
      target_connection,
      result[["pseudonymization"]][["tables"]],
      target_schema = target_schema,
      overwrite = overwrite,
      temporary = temporary
    )
  }, log_steps = log_steps)

  result
}
