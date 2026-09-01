SNAPSHOT_LAST_VERSION_SUFFIX <- "_last_version"
SNAPSHOT_OLD_VERSIONS_SUFFIX <- "_old_versions"
SNAPSHOT_RELATION_TYPE_ALL <- "all"
SNAPSHOT_RELATION_TYPE_OLD <- "old_versions"
SNAPSHOT_RELATION_TYPE_LAST <- "last_version"

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

snapshotAllowTemporarySourceTables <- function(connection) {
  DBI::dbExecute(connection, "SET SESSION default_transaction_read_only = off")
}

snapshotRelationExists <- function(connection, name, schema = NULL) {
  relation <- if (!is.null(schema) && !is.na(schema) && nzchar(schema)) {
    DBI::Id(schema = schema, table = name)
  } else {
    name
  }
  DBI::dbExistsTable(connection, relation)
}

getSnapshotReleaseVersion <- function(
  connection,
  source_schema = "db2dataprocessor_out"
) {
  source_view <- snapshotQualifiedName(connection, "v_db_parameter", source_schema)
  statement <- paste0(
    "SELECT parameter_value FROM ",
    source_view,
    " WHERE parameter_name = 'release_version'"
  )
  version_rows <- DBI::dbGetQuery(connection, statement)
  if (nrow(version_rows) != 1L) {
    stop(
      "Source view ", source_view,
      " must contain exactly one release_version row.",
      call. = FALSE
    )
  }
  release_version <- as.character(version_rows[["parameter_value"]][1])
  if (is.na(release_version) || !nzchar(release_version)) {
    stop("Source database release_version must not be empty.", call. = FALSE)
  }
  release_version
}

createSnapshotVersionView <- function(
  connection,
  release_version,
  view_schema = "db2dataprocessor_out"
) {
  if (
    length(release_version) != 1L ||
    is.na(release_version) ||
    !nzchar(release_version)
  ) {
    stop("release_version must be one non-empty value.", call. = FALSE)
  }
  view_name <- "v_db_parameter"
  snapshotEnsureSchema(connection, view_schema)
  if (snapshotRelationExists(connection, view_name, view_schema)) {
    stop("Target view already exists: ", snapshotQualifiedName(
      connection,
      view_name,
      view_schema
    ))
  }
  quoted_version <- as.character(DBI::dbQuoteString(connection, release_version))
  statement <- paste0(
    "CREATE VIEW ",
    snapshotQualifiedName(connection, view_name, view_schema),
    " AS SELECT ",
    "CAST(NULL AS integer) AS id, ",
    "CAST('release_version' AS varchar) AS parameter_name, ",
    "CAST(", quoted_version, " AS varchar) AS parameter_value, ",
    "CAST('Source database release version' AS varchar) AS parameter_description, ",
    "CAST(NULL AS timestamp) AS input_datetime, ",
    "CAST(NULL AS timestamp) AS last_change_timestamp"
  )
  DBI::dbExecute(connection, statement)
  data.table::data.table(
    VIEW_NAME = view_name,
    SOURCE_TABLE = NA_character_,
    STATUS = "created"
  )
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
getSnapshotSourceViewPlan <- function(
  rules,
  source_view_prefix = "v_",
  last_version_suffix = SNAPSHOT_LAST_VERSION_SUFFIX,
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
      SNAPSHOT_RELATION_TYPE = SNAPSHOT_RELATION_TYPE_ALL
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
      SNAPSHOT_RELATION_TYPE = SNAPSHOT_RELATION_TYPE_LAST
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

#' Create Views for Pseudonymized Snapshot Tables
#'
#' Creates passthrough views for materialized pseudonymized tables. For sources
#' with a last-version relation, it additionally creates the stable
#' `v_<table>` view as a `UNION ALL` of the disjoint old- and last-version
#' passthrough views.
#'
#' @param connection Target DBI connection.
#' @param materialization_plan Plan returned by `getSnapshotSourceViewPlan()`.
#' @param table_schema Schema containing materialized pseudonymized tables.
#' @param view_schema Schema containing passthrough views.
#'
#' @return A data.table with one row per created view.
createSnapshotPassthroughViews <- function(
  connection,
  materialization_plan,
  table_schema = "db_log",
  view_schema = "db2dataprocessor_out"
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
    if (snapshotRelationExists(connection, view_name, view_schema)) {
      stop("Target view already exists: ", snapshotQualifiedName(
        connection,
        view_name,
        view_schema
      ))
    }
    statement <- paste0(
      "CREATE VIEW ",
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

  partitioned_tables <- unique(materialization_plan[["BASE_TABLE_NAME"]][
    materialization_plan[["SNAPSHOT_RELATION_TYPE"]] == SNAPSHOT_RELATION_TYPE_OLD
  ])
  for (base_table_name in partitioned_tables) {
    partition_rows <- materialization_plan[
      materialization_plan[["BASE_TABLE_NAME"]] == base_table_name &
        materialization_plan[["SNAPSHOT_RELATION_TYPE"]] %in% c(
          SNAPSHOT_RELATION_TYPE_OLD,
          SNAPSHOT_RELATION_TYPE_LAST
        ),
    ]
    if (nrow(partition_rows) != 2L) {
      stop("Expected old- and last-version views for: ", base_table_name)
    }
    old_view <- partition_rows[["TARGET_VIEW_NAME"]][
      partition_rows[["SNAPSHOT_RELATION_TYPE"]] == SNAPSHOT_RELATION_TYPE_OLD
    ]
    last_view <- partition_rows[["TARGET_VIEW_NAME"]][
      partition_rows[["SNAPSHOT_RELATION_TYPE"]] == SNAPSHOT_RELATION_TYPE_LAST
    ]
    view_name <- sub(paste0(SNAPSHOT_OLD_VERSIONS_SUFFIX, "$"), "", old_view)
    if (snapshotRelationExists(connection, view_name, view_schema)) {
      stop("Target view already exists: ", snapshotQualifiedName(
        connection,
        view_name,
        view_schema
      ))
    }
    statement <- paste0(
      "CREATE VIEW ",
      snapshotQualifiedName(connection, view_name, view_schema),
      " AS SELECT * FROM ",
      snapshotQualifiedName(connection, old_view, view_schema),
      " UNION ALL SELECT * FROM ",
      snapshotQualifiedName(connection, last_view, view_schema)
    )
    DBI::dbExecute(connection, statement)
    summary_rows[[length(summary_rows) + 1L]] <- data.table::data.table(
      VIEW_NAME = view_name,
      SOURCE_TABLE = paste(old_view, last_view, sep = " UNION ALL "),
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

writeSnapshotIssueReport <- function(report, file_name = NA) {
  report_tables <- if (data.table::is.data.table(report)) {
    list(unmatched_medication_references = report)
  } else {
    report
  }
  writePseudonymizationReportWorkbook(
    report_tables,
    file_name = file_name,
    filename_without_extension = "snapshot_pseudonymization_issues"
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
#' @param chunk_size Maximum number of source rows held in memory at once for
#'   each materialized relation.
#' @param review_report_file Optional explicit pseudonymization rule review
#'   path. If `NA`, the report is written below `outputLocal`.
#' @param issue_report_file Optional explicit pseudonymization issue report
#'   path. If `NA`, the report is written to
#'   `outputLocal/<MODULE>/reports`.
#' @param postprocessing_report_file Optional explicit snapshot postprocessing
#'   report path. If `NA`, the report is written to
#'   `outputLocal/<MODULE>/reports`.
#' @param mapping_preflight_completed Whether mapping coverage and workbook
#'   validation already completed against the same source database immediately
#'   before this call.
#' @param log_steps If `TRUE` and module logging is initialized, wrap major
#'   steps in the existing `etlutils::runLevel...` logging.
#'
#' @return A list with rules, reports, the materialization plan, and write and
#'   view summaries. Full source and target tables are not returned because the
#'   database pipeline processes them incrementally.
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
  last_version_suffix = SNAPSHOT_LAST_VERSION_SUFFIX,
  tables = NULL,
  chunk_size = DEFAULT_SNAPSHOT_CHUNK_SIZE,
  review_report_file = NA,
  issue_report_file = NA,
  postprocessing_report_file = NA,
  mapping_preflight_completed = FALSE,
  log_steps = TRUE
) {
  chunk_size <- validateSnapshotChunkSize(chunk_size)
  if (is.null(table_descriptions)) {
    rule_sources <- getDefaultSnapshotPseudonymizationRuleSources(project_root = project_root)
    table_descriptions <- rule_sources[["table_descriptions"]]
    snapshot_extensions <- rule_sources[["snapshot_extensions"]]
  }

  result <- list()
  runPseudonymizationLogStep(2L,
    "Read source database release version",
    {
      result[["release_version"]] <- getSnapshotReleaseVersion(
        source_connection,
        source_schema = source_schema
      )
    },
    log_steps = log_steps
  )
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
    "Review static pseudonymization rules",
    {
      result[["static_review_report"]] <- reviewPseudonymizationRules(
        result[["rules"]],
        input_repo_path = input_repo_path,
        validate_mapping_files = FALSE,
        fail_on_review_problems = TRUE,
        write_review_report = TRUE,
        review_report_file = review_report_file
      )
    },
    log_steps = log_steps
  )

  runPseudonymizationLogStep(2L,
    "Plan snapshot source relations",
    {
      result[["materialization_plan"]] <- getExistingSnapshotMaterializationPlan(
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

  if (!isTRUE(mapping_preflight_completed)) {
    runPseudonymizationLogStep(2L,
      "Prepare and validate pseudonym mapping workbook",
      {
        result[["mapping_coverage"]] <- ensurePseudonymMappingCoverage(
          connection = source_connection,
          rules = result[["rules"]],
          materialization_plan = result[["materialization_plan"]],
          input_repo_path = input_repo_path,
          source_schema = source_schema
        )
      },
      log_steps = log_steps
    )

    runPseudonymizationLogStep(2L,
      "Validate pseudonym mapping workbook",
      {
        result[["review_report"]] <- reviewPseudonymizationRules(
          result[["rules"]],
          input_repo_path = input_repo_path,
          validate_mapping_files = TRUE,
          fail_on_review_problems = TRUE,
          write_review_report = TRUE,
          review_report_file = review_report_file
        )
      },
      log_steps = log_steps
    )
  }

  snapshotEnsureSchema(target_connection, target_table_schema)
  snapshotAllowTemporarySourceTables(source_connection)
  version_key_tables <- list()
  runPseudonymizationLogStep(2L,
    "Prepare snapshot version partitions",
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
  medication_resolution_tables <- list()
  runPseudonymizationLogStep(2L,
    "Prepare shared Medication reference resolution",
    {
      medication_resolution_tables <- prepareSnapshotMedicationResolutionTables(
        connection = source_connection,
        materialization_plan = result[["materialization_plan"]],
        rules = result[["rules"]],
        source_schema = source_schema,
        source_view_prefix = source_view_prefix,
        last_version_suffix = last_version_suffix
      )
    },
    log_steps = log_steps
  )
  on.exit(
    dropSnapshotMedicationResolutionTables(
      source_connection,
      medication_resolution_tables
    ),
    add = TRUE
  )
  streaming_context <- newSnapshotStreamingContext(
    input_repo_path,
    medication_resolution_tables,
    version_key_tables
  )
  summary_rows <- list()
  write_summary_rows <- list()
  runPseudonymizationLogStep(2L,
    "Stream and pseudonymize snapshot tables",
    {
      for (i in seq_len(nrow(result[["materialization_plan"]]))) {
        relation_result <- streamSnapshotMaterializedTable(
          source_connection = source_connection,
          target_connection = target_connection,
          plan_row = result[["materialization_plan"]][i, ],
          rules = result[["rules"]],
          input_repo_path = input_repo_path,
          source_schema = source_schema,
          target_table_schema = target_table_schema,
          source_view_prefix = source_view_prefix,
          last_version_suffix = last_version_suffix,
          chunk_size = chunk_size,
          streaming_context = streaming_context,
          log_steps = log_steps
        )
        summary_rows[[length(summary_rows) + 1L]] <- relation_result[["summary"]]
        write_summary_rows[[length(write_summary_rows) + 1L]] <-
          relation_result[["write_summary"]]
      }
    },
    log_steps = log_steps
  )

  result[["pseudonymization"]] <- list(summary = data.table::rbindlist(summary_rows, fill = TRUE))
  result[["postprocessing_report"]] <- result[["pseudonymization"]][["summary"]]
  result[["write_summary"]] <- data.table::rbindlist(write_summary_rows, fill = TRUE)
  medication_review <- finalizeBoundedMedicationReferenceReview(streaming_context$medication_review)
  age_review <- finalizeBoundedAgeCalculationReview(streaming_context$age_review)
  loinc_unit_review <- finalizeLoincUnitConversionReview(streaming_context$loinc_unit_review)
  result[["issue_report"]] <- c(
    list(
      medication_issue_summary = medication_review[["summary"]],
      medication_issue_examples =
        medication_review[["unmatched_reference_examples"]],
      loinc_unit_conversion_issues = loinc_unit_review
    ),
    age_review
  )

  runPseudonymizationLogStep(2L,
    "Write snapshot processing reports",
    {
      writeSnapshotIssueReport(result[["issue_report"]], file_name = issue_report_file)
      writeSnapshotPostprocessingReport(
        result[["postprocessing_report"]],
        file_name = postprocessing_report_file
      )
    },
    log_steps = log_steps
  )

  runPseudonymizationLogStep(2L,
    "Create snapshot passthrough views",
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
        view_schema = target_view_schema
      )
      result[["view_summary"]] <- data.table::rbindlist(list(
        passthrough_summary,
        version_summary
      ))
    },
    log_steps = log_steps
  )

  result
}
