DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS <- c(
  resource_id = "count per resource_id",
  pid = "count per PID",
  case_id = "count per Fall-Id"
)

DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS <- c(
  first_import = "first value import datetime",
  last_import = "last value import datetime",
  first_meta_last_updated = "first value meta last updated",
  last_meta_last_updated = "last value meta last updated"
)

DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN <- "USED_AS_GROUPING_FOR"

logDatabaseQualityAnalysisProgress <- function(...) {
  cat("[Database Quality Analysis] ", ..., "\n", sep = "")
}

formatDatabaseQualityAnalysisDuration <- function(start_time, end_time = Sys.time()) {
  paste0(round(as.numeric(difftime(end_time, start_time, units = "secs")), 2), "s")
}

formatDatabaseQualityAnalysisCountLabel <- function(count, singular, plural = paste0(singular, "s")) {
  paste(count, if (identical(as.integer(count), 1L)) singular else plural)
}

normalizeDatabaseQualityAnalysisArgumentName <- function(argument_name) {
  argument_name <- sub("^-+", "", argument_name)
  argument_name <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", argument_name)
  tolower(gsub("-", "_", argument_name, fixed = TRUE))
}

getDatabaseQualityAnalysisCommandArguments <- function(command_arguments = NULL) {
  if (is.null(command_arguments)) {
    return(commandArgs(trailingOnly = TRUE))
  }
  if (length(command_arguments) == 1L) {
    return(strsplit(command_arguments, " +")[[1]])
  }
  command_arguments
}

parseDatabaseQualityAnalysisCommandLineConfig <- function(command_arguments = NULL) {
  command_arguments <- getDatabaseQualityAnalysisCommandArguments(command_arguments)
  key_value_arguments <- command_arguments[grepl("=", command_arguments, fixed = TRUE)]
  parsed <- etlutils::initCommandLineArguments(
    argument2global_variable_name = c(
      "view_schema" = "VIEW_SCHEMA",
      "view_prefix" = "VIEW_PREFIX",
      "view_postfix" = "VIEW_POSTFIX",
      "value_import_datetime_column" = "VALUE_IMPORT_DATETIME_COLUMN",
      "output_filename" = "OUTPUT_FILENAME",
      "count_batch_size" = "COUNT_BATCH_SIZE"
    ),
    command_arguments = key_value_arguments,
    store_as_global = FALSE
  )
  argument_names <- sub("=.*$", "", command_arguments)
  normalized_argument_names <- vapply(
    argument_names,
    normalizeDatabaseQualityAnalysisArgumentName,
    character(1)
  )
  if (any(normalized_argument_names %in% c("skip_value_datetime_columns", "s"))) {
    parsed$INCLUDE_VALUE_DATETIME_COLUMNS <- FALSE
  }
  parsed
}

getDatabaseQualityAnalysisConfig <- function(envir = .GlobalEnv, command_arguments = NULL) {
  command_line_config <- parseDatabaseQualityAnalysisCommandLineConfig(command_arguments)

  getConfigValue <- function(name, default) {
    if (!is.null(command_line_config[[name]])) {
      return(command_line_config[[name]])
    }
    if (exists(name, envir = envir, inherits = FALSE)) {
      return(get(name, envir = envir))
    }
    default
  }

  list(
    view_schema = getConfigValue("VIEW_SCHEMA", "db2dataprocessor_out"),
    view_prefix = getConfigValue("VIEW_PREFIX", "v_"),
    view_postfix = getConfigValue("VIEW_POSTFIX", "_last_version"),
    value_import_datetime_column = getConfigValue("VALUE_IMPORT_DATETIME_COLUMN", "input_datetime"),
    include_value_datetime_columns = as.logical(
      getConfigValue("INCLUDE_VALUE_DATETIME_COLUMNS", TRUE)
    ),
    output_filename = getConfigValue("OUTPUT_FILENAME", "Database_Quality_Analysis"),
    count_batch_size = as.integer(getConfigValue("COUNT_BATCH_SIZE", 100)),
    included_view_patterns = getConfigValue(
      "INCLUDED_VIEW_PATTERNS",
      c("^v_[a-z0-9_]+_last_version$", "^v_[a-z0-9_]+_fe_last_version$")
    ),
    excluded_view_patterns = getConfigValue("EXCLUDED_VIEW_PATTERNS", "_raw_"),
    additional_views = getConfigValue("ADDITIONAL_VIEWS", character()),
    technical_columns = getConfigValue(
      "TECHNICAL_COLUMNS",
      c(
        "raw_already_processed",
        "hash_index_col",
        "id",
        "last_version_date",
        "input_datetime",
        "last_check_datetime",
        "current_dataset_status",
        "input_processing_nr",
        "last_processing_nr"
      )
    ),
    grouping_overrides = parseDatabaseQualityAnalysisGroupingOverrides(
      getConfigValue("GROUPING_OVERRIDES", character())
    )
  )
}

parseDatabaseQualityAnalysisGroupingOverrides <- function(overrides) {
  empty_result <- data.table::data.table(
    TABLE_NAME = character(),
    resource_id = character(),
    pid = character(),
    case_id = character()
  )
  if (!length(overrides)) {
    return(empty_result)
  }

  override_rows <- strsplit(overrides, "|", fixed = TRUE)
  override_rows <- Map(function(raw_override, row) {
    if (endsWith(raw_override, "|") && length(row) == 3L) {
      return(c(row, ""))
    }
    row
  }, overrides, override_rows)
  invalid_rows <- vapply(override_rows, length, integer(1)) != 4L
  if (any(invalid_rows)) {
    stop(
      "Invalid GROUPING_OVERRIDES entries. Expected format: ",
      "table_name|resource_id_column|pid_column|case_id_column"
    )
  }

  result <- data.table::rbindlist(lapply(override_rows, function(row) {
    data.table::data.table(
      TABLE_NAME = row[[1]],
      resource_id = row[[2]],
      pid = row[[3]],
      case_id = row[[4]]
    )
  }))
  result[result == ""] <- NA_character_
  result
}

quoteDatabaseQualityAnalysisIdentifier <- function(identifier) {
  if (is.na(identifier) || !nzchar(identifier)) {
    stop("Identifier must not be empty.")
  }
  paste0('"', gsub('"', '""', identifier, fixed = TRUE), '"')
}

quoteDatabaseQualityAnalysisTable <- function(schema, table_name) {
  paste(
    quoteDatabaseQualityAnalysisIdentifier(schema),
    quoteDatabaseQualityAnalysisIdentifier(table_name),
    sep = "."
  )
}

normalizeDatabaseQualityAnalysisViewName <- function(view_name, config) {
  table_name <- view_name
  if (startsWith(table_name, config$view_prefix)) {
    table_name <- substring(table_name, nchar(config$view_prefix) + 1L)
  }
  if (endsWith(table_name, config$view_postfix)) {
    table_name <- substr(table_name, 1L, nchar(table_name) - nchar(config$view_postfix))
  }
  table_name
}

normalizeDatabaseQualityAnalysisColumnDescription <- function(column_description) {
  ifelse(
    is.na(column_description),
    NA_character_,
    sub("\\s+\\([A-Za-z0-9_ ]+\\)$", "", column_description, perl = TRUE)
  )
}

getDatabaseQualityAnalysisTableFamily <- function(table_name) {
  if (endsWith(table_name, "_fe")) {
    return("Frontend")
  }
  if (identical(table_name, "pids_per_ward")) {
    return("Other")
  }
  "FHIR"
}

isDatabaseQualityAnalysisIncludedView <- function(view_name, config) {
  matches_pattern <- any(vapply(
    config$included_view_patterns,
    grepl,
    logical(1),
    x = view_name,
    perl = TRUE
  ))
  excluded <- any(vapply(
    config$excluded_view_patterns,
    grepl,
    logical(1),
    x = view_name,
    perl = TRUE
  ))
  (matches_pattern || view_name %in% config$additional_views) && !excluded
}

loadDatabaseQualityAnalysisViewMetadata <- function(config) {
  logDatabaseQualityAnalysisProgress("Loading view metadata from schema ", config$view_schema, ".")
  query <- paste0(
    "SELECT c.table_schema,\n",
    "       c.table_name AS view_name,\n",
    "       c.column_name,\n",
    "       c.ordinal_position,\n",
    "       c.data_type,\n",
    "       col_description((quote_ident(c.table_schema) || '.' || ",
    "quote_ident(c.table_name))::regclass::oid, c.ordinal_position) AS column_description\n",
    "FROM information_schema.columns c\n",
    "JOIN information_schema.views v\n",
    "  ON v.table_schema = c.table_schema\n",
    " AND v.table_name = c.table_name\n",
    "WHERE c.table_schema = $1\n",
    "ORDER BY c.table_name, c.ordinal_position"
  )

  metadata <- etlutils::dbGetReadOnlyQuery(
    query,
    params = list(config$view_schema),
    lock_id = "load database quality analysis view metadata"
  )
  metadata <- normalizeDatabaseQualityAnalysisMetadata(metadata, config)
  table_counts <- unique(metadata[, .(TABLE_FAMILY, TABLE_NAME)])[, .N, by = TABLE_FAMILY]
  logDatabaseQualityAnalysisProgress(
    "Loaded metadata for ",
    data.table::uniqueN(metadata$TABLE_NAME),
    " tables and ",
    nrow(metadata),
    " report columns: ",
    paste(paste(table_counts$TABLE_FAMILY, table_counts$N, sep = "="), collapse = ", "),
    "."
  )
  metadata
}

loadDatabaseQualityAnalysisHistoryMetadata <- function(config) {
  logDatabaseQualityAnalysisProgress("Loading historical view metadata for value datetime columns.")
  query <- paste0(
    "SELECT c.table_schema,\n",
    "       c.table_name AS view_name,\n",
    "       c.column_name,\n",
    "       c.data_type\n",
    "FROM information_schema.columns c\n",
    "JOIN information_schema.views v\n",
    "  ON v.table_schema = c.table_schema\n",
    " AND v.table_name = c.table_name\n",
    "WHERE c.table_schema = $1\n",
    "ORDER BY c.table_name, c.ordinal_position"
  )

  metadata <- etlutils::dbGetReadOnlyQuery(
    query,
    params = list(config$view_schema),
    lock_id = "load database quality analysis history metadata"
  )
  metadata <- data.table::as.data.table(metadata)
  data.table::setnames(
    metadata,
    old = c("table_schema", "view_name", "column_name", "data_type"),
    new = c("VIEW_SCHEMA", "VIEW_NAME", "COLUMN_NAME", "DATA_TYPE"),
    skip_absent = TRUE
  )
  metadata[]
}

loadDatabaseQualityAnalysisDatabaseMetadata <- function() {
  logDatabaseQualityAnalysisProgress("Loading neutral database metadata.")
  query <- paste0(
    "SELECT 'PostgreSQL' AS dbms,\n",
    "       current_setting('server_version') AS server_version,\n",
    "       current_setting('server_encoding') AS server_encoding"
  )

  metadata <- etlutils::dbGetReadOnlyQuery(
    query,
    lock_id = "load database quality analysis database metadata"
  )
  data.table::as.data.table(metadata)
}

normalizeDatabaseQualityAnalysisMetadata <- function(metadata, config) {
  metadata <- data.table::as.data.table(metadata)
  if (!nrow(metadata)) {
    return(data.table::data.table(
      VIEW_SCHEMA = character(),
      VIEW_NAME = character(),
      TABLE_NAME = character(),
      TABLE_FAMILY = character(),
      COLUMN_NAME = character(),
      COLUMN_DESCRIPTION = character(),
      ORDINAL_POSITION = integer(),
      DATA_TYPE = character()
    ))
  }

  data.table::setnames(
    metadata,
    old = c("table_schema", "view_name", "column_name", "ordinal_position", "data_type", "column_description"),
    new = c("VIEW_SCHEMA", "VIEW_NAME", "COLUMN_NAME", "ORDINAL_POSITION", "DATA_TYPE", "COLUMN_DESCRIPTION"),
    skip_absent = TRUE
  )

  metadata <- metadata[
    vapply(VIEW_NAME, isDatabaseQualityAnalysisIncludedView, logical(1), config = config)
  ]
  metadata[, TABLE_NAME := vapply(VIEW_NAME, normalizeDatabaseQualityAnalysisViewName, character(1), config = config)]
  metadata[, TABLE_FAMILY := vapply(TABLE_NAME, getDatabaseQualityAnalysisTableFamily, character(1))]
  metadata[, COLUMN_DESCRIPTION := normalizeDatabaseQualityAnalysisColumnDescription(COLUMN_DESCRIPTION)]
  metadata <- metadata[!isDatabaseQualityAnalysisTechnicalColumn(TABLE_NAME, COLUMN_NAME, config)]
  metadata[]
}

getDatabaseQualityAnalysisHistoryViewName <- function(table_name, config) {
  paste0(config$view_prefix, table_name)
}

getDatabaseQualityAnalysisDateSources <- function(table_metadata, history_table_metadata, config) {
  sources <- data.table::data.table(
    source_name = character(),
    column_name = character(),
    first_result_column = character(),
    last_result_column = character()
  )

  if (config$value_import_datetime_column %in% history_table_metadata$COLUMN_NAME) {
    sources <- rbind(
      sources,
      data.table::data.table(
        source_name = "import",
        column_name = config$value_import_datetime_column,
        first_result_column = DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[["first_import"]],
        last_result_column = DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[["last_import"]]
      )
    )
  }

  if (identical(table_metadata$TABLE_FAMILY[[1]], "FHIR")) {
    meta_last_updated_column <- grep("_meta_lastupdated$", history_table_metadata$COLUMN_NAME, value = TRUE)
    if (length(meta_last_updated_column)) {
      sources <- rbind(
        sources,
        data.table::data.table(
          source_name = "meta_last_updated",
          column_name = meta_last_updated_column[[1]],
          first_result_column = DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[["first_meta_last_updated"]],
          last_result_column = DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[["last_meta_last_updated"]]
        )
      )
    }
  }

  sources
}

isDatabaseQualityAnalysisTechnicalColumn <- function(table_name, column_name, config) {
  column_name %in% config$technical_columns |
    endsWith(column_name, "_raw_id") |
    column_name == paste0(table_name, "_id")
}

firstPresentColumn <- function(columns, candidates) {
  present <- candidates[candidates %in% columns]
  if (length(present)) {
    return(present[[1]])
  }
  NA_character_
}

inferDatabaseQualityAnalysisGroupingColumns <- function(table_metadata, config) {
  table_name <- table_metadata$TABLE_NAME[[1]]
  columns <- table_metadata$COLUMN_NAME

  override <- config$grouping_overrides[TABLE_NAME == table_name]
  grouping <- list(resource_id = NA_character_, pid = NA_character_, case_id = NA_character_)
  if (nrow(override)) {
    grouping$resource_id <- override$resource_id[[1]]
    grouping$pid <- override$pid[[1]]
    grouping$case_id <- override$case_id[[1]]
  }

  if (is.na(grouping$resource_id) || !grouping$resource_id %in% columns) {
    own_id_candidates <- grep("^[a-z0-9]+_id$", columns, value = TRUE)
    grouping$resource_id <- firstPresentColumn(columns, own_id_candidates)
  }

  if (is.na(grouping$pid) || !grouping$pid %in% columns) {
    grouping$pid <- firstPresentColumn(
      columns,
      c(
        grep("_patient_id$", columns, value = TRUE),
        grep("_patient_ref$", columns, value = TRUE),
        grep("_subject_ref$", columns, value = TRUE),
        "record_id",
        "patient_id",
        "pat_id",
        "pat_cis_pid"
      )
    )
  }

  if (is.na(grouping$case_id) || !grouping$case_id %in% columns) {
    grouping$case_id <- firstPresentColumn(
      columns,
      c(
        grep("_encounter_calculated_ref$", columns, value = TRUE),
        grep("_calculated_encounter_ref$", columns, value = TRUE),
        grep("_encounter_ref$", columns, value = TRUE),
        "encounter_id",
        "fall_fhir_enc_id",
        "fall_id"
      )
    )
  }

  unlist(grouping, use.names = TRUE)
}

addDatabaseQualityAnalysisGroupingRoles <- function(result, grouping_columns) {
  result[, (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) := NA_character_]
  for (grouping_name in names(grouping_columns)) {
    grouping_column <- grouping_columns[[grouping_name]]
    if (is.na(grouping_column) || !grouping_column %in% result$COLUMN_NAME) {
      next
    }
    count_column <- DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS[[grouping_name]]
    result[
      COLUMN_NAME == grouping_column,
      (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) := data.table::fifelse(
        is.na(get(DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN)),
        count_column,
        paste(get(DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN), count_column, sep = "; ")
      )
    ]
  }
  result
}

getDatabaseQualityAnalysisFilledCondition <- function(column_name) {
  getDatabaseQualityAnalysisColumnFilledCondition(column_name, NA_character_)
}

isDatabaseQualityAnalysisTextType <- function(data_type) {
  if (is.na(data_type) || !nzchar(data_type)) {
    return(TRUE)
  }
  data_type %in% c("character", "character varying", "text")
}

getDatabaseQualityAnalysisColumnFilledCondition <- function(column_name, data_type) {
  quoted_column <- quoteDatabaseQualityAnalysisIdentifier(column_name)
  not_null_condition <- paste(quoted_column, "IS NOT NULL")
  if (!isDatabaseQualityAnalysisTextType(data_type)) {
    return(not_null_condition)
  }
  paste0(not_null_condition, " AND ", quoted_column, "::text <> ''")
}

buildDatabaseQualityAnalysisCountQuery <- function(table_metadata, grouping_columns, data_columns) {
  table_ref <- quoteDatabaseQualityAnalysisTable(
    table_metadata$VIEW_SCHEMA[[1]],
    table_metadata$VIEW_NAME[[1]]
  )

  select_parts <- character()
  alias_map <- data.table::data.table(
    alias = character(),
    COLUMN_NAME = character(),
    count_column = character()
  )
  alias_index <- 1L

  data_types <- stats::setNames(
    if ("DATA_TYPE" %in% names(table_metadata)) table_metadata$DATA_TYPE else rep(NA_character_, nrow(table_metadata)),
    table_metadata$COLUMN_NAME
  )

  for (column_name in data_columns) {
    filled_condition <- getDatabaseQualityAnalysisColumnFilledCondition(column_name, data_types[[column_name]])
    for (grouping_name in names(grouping_columns)) {
      grouping_column <- grouping_columns[[grouping_name]]
      if (is.na(grouping_column) || !grouping_column %in% table_metadata$COLUMN_NAME) {
        next
      }
      alias <- paste0("count_", alias_index)
      quoted_grouping <- quoteDatabaseQualityAnalysisIdentifier(grouping_column)
      grouping_filled_condition <- getDatabaseQualityAnalysisColumnFilledCondition(
        grouping_column,
        data_types[[grouping_column]]
      )
      select_parts <- c(select_parts, paste0(
        "COUNT(DISTINCT CASE WHEN ",
        filled_condition,
        " AND ",
        grouping_filled_condition,
        " THEN ",
        quoted_grouping,
        " END) AS ",
        quoteDatabaseQualityAnalysisIdentifier(alias)
      ))
      alias_map <- rbind(
        alias_map,
        data.table::data.table(
          alias = alias,
          COLUMN_NAME = column_name,
          count_column = DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS[[grouping_name]]
        )
      )
      alias_index <- alias_index + 1L
    }
  }

  if (!length(select_parts)) {
    return(list(query = NA_character_, alias_map = alias_map))
  }

  list(
    query = paste0(
      "SELECT\n  ",
      paste(select_parts, collapse = ",\n  "),
      "\nFROM ",
      table_ref
    ),
    alias_map = alias_map
  )
}

buildDatabaseQualityAnalysisValueDateRangeQuery <- function(table_metadata, history_metadata, config, data_columns) {
  if (is.null(history_metadata) || !nrow(history_metadata)) {
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }

  history_view_name <- getDatabaseQualityAnalysisHistoryViewName(table_metadata$TABLE_NAME[[1]], config)
  history_table_metadata <- history_metadata[
    VIEW_SCHEMA == table_metadata$VIEW_SCHEMA[[1]] &
      VIEW_NAME == history_view_name
  ]
  if (!nrow(history_table_metadata)) {
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }

  data_columns <- intersect(data_columns, history_table_metadata$COLUMN_NAME)
  if (!length(data_columns)) {
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }

  date_sources <- getDatabaseQualityAnalysisDateSources(table_metadata, history_table_metadata, config)
  if (!nrow(date_sources)) {
    return(list(query = NA_character_, alias_map = data.table::data.table()))
  }

  table_ref <- quoteDatabaseQualityAnalysisTable(
    table_metadata$VIEW_SCHEMA[[1]],
    history_view_name
  )
  data_types <- stats::setNames(history_table_metadata$DATA_TYPE, history_table_metadata$COLUMN_NAME)
  select_parts <- character()
  alias_map <- data.table::data.table(
    first_alias = character(),
    last_alias = character(),
    first_result_column = character(),
    last_result_column = character(),
    COLUMN_NAME = character()
  )

  for (column_index in seq_along(data_columns)) {
    column_name <- data_columns[[column_index]]
    filled_condition <- getDatabaseQualityAnalysisColumnFilledCondition(column_name, data_types[[column_name]])
    for (source_index in seq_len(nrow(date_sources))) {
      date_source <- date_sources[source_index]
      first_alias <- paste0("first_value_datetime_", column_index, "_", date_source$source_name)
      last_alias <- paste0("last_value_datetime_", column_index, "_", date_source$source_name)
      quoted_datetime_column <- quoteDatabaseQualityAnalysisIdentifier(date_source$column_name)
      select_parts <- c(
        select_parts,
        paste0(
          "MIN(CASE WHEN ",
          filled_condition,
          " THEN ",
          quoted_datetime_column,
          " END) AS ",
          quoteDatabaseQualityAnalysisIdentifier(first_alias)
        ),
        paste0(
          "MAX(CASE WHEN ",
          filled_condition,
          " THEN ",
          quoted_datetime_column,
          " END) AS ",
          quoteDatabaseQualityAnalysisIdentifier(last_alias)
        )
      )
      alias_map <- rbind(
        alias_map,
        data.table::data.table(
          first_alias = first_alias,
          last_alias = last_alias,
          first_result_column = date_source$first_result_column,
          last_result_column = date_source$last_result_column,
          COLUMN_NAME = column_name
        )
      )
    }
  }

  list(
    query = paste0(
      "SELECT\n  ",
      paste(select_parts, collapse = ",\n  "),
      "\nFROM ",
      table_ref
    ),
    alias_map = alias_map
  )
}

calculateDatabaseQualityAnalysisCounts <- function(
  metadata,
  config,
  query_fun = etlutils::dbGetReadOnlyQuery,
  history_metadata = NULL
) {
  result <- unique(metadata[, .(TABLE_FAMILY, TABLE_NAME, COLUMN_NAME, COLUMN_DESCRIPTION, ORDINAL_POSITION)])
  result[, (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) := NA_character_]
  if (isTRUE(config$include_value_datetime_columns)) {
    result[, (DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS) := as.POSIXct(NA)]
  }
  for (count_column in DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS) {
    result[, (count_column) := NA_integer_]
  }

  table_names <- unique(metadata$TABLE_NAME)
  for (table_index in seq_along(table_names)) {
    table_start_time <- Sys.time()
    table_name <- table_names[[table_index]]
    table_metadata <- metadata[TABLE_NAME == table_name][order(ORDINAL_POSITION)]
    grouping_columns <- inferDatabaseQualityAnalysisGroupingColumns(table_metadata, config)
    table_result <- result[TABLE_NAME == table_name]
    table_result <- addDatabaseQualityAnalysisGroupingRoles(table_result, grouping_columns)
    result[TABLE_NAME == table_name, (DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN) :=
      table_result[[DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN]]]

    data_columns <- table_metadata$COLUMN_NAME
    column_batches <- split(data_columns, ceiling(seq_along(data_columns) / config$count_batch_size))
    logDatabaseQualityAnalysisProgress(
      "Table ",
      table_index,
      "/",
      length(table_names),
      " ",
      table_name,
      " (",
      table_metadata$TABLE_FAMILY[[1]],
      "): ",
      formatDatabaseQualityAnalysisCountLabel(length(data_columns), "column"),
      ", ",
      formatDatabaseQualityAnalysisCountLabel(length(column_batches), "batch", "batches"),
      ", value datetime columns ",
      if (isTRUE(config$include_value_datetime_columns)) "enabled" else "disabled",
      "."
    )

    for (batch_index in seq_along(column_batches)) {
      data_column_batch <- column_batches[[batch_index]]
      if (length(column_batches) > 1L) {
        logDatabaseQualityAnalysisProgress(
          "Table ",
          table_name,
          ": batch ",
          batch_index,
          "/",
          length(column_batches),
          " with ",
          formatDatabaseQualityAnalysisCountLabel(length(data_column_batch), "column"),
          "."
        )
      }

      count_query <- buildDatabaseQualityAnalysisCountQuery(table_metadata, grouping_columns, data_column_batch)
      if (!is.na(count_query$query)) {
        count_result <- query_fun(
          count_query$query,
          lock_id = paste0("calculate database quality analysis counts for ", table_name)
        )
        for (row_index in seq_len(nrow(count_query$alias_map))) {
          alias_row <- count_query$alias_map[row_index]
          result[
            TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
            (alias_row$count_column) := as.integer(count_result[[alias_row$alias]][[1]])
          ]
        }
      }

      if (isTRUE(config$include_value_datetime_columns)) {
        date_range_query <- buildDatabaseQualityAnalysisValueDateRangeQuery(
          table_metadata,
          history_metadata,
          config,
          data_column_batch
        )
        if (!is.na(date_range_query$query)) {
          date_range_result <- query_fun(
            date_range_query$query,
            lock_id = paste0("calculate database quality analysis value date ranges for ", table_name)
          )
          for (row_index in seq_len(nrow(date_range_query$alias_map))) {
            alias_row <- date_range_query$alias_map[row_index]
            result[
              TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
              (alias_row$first_result_column) := date_range_result[[alias_row$first_alias]][[1]]
            ]
            result[
              TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
              (alias_row$last_result_column) := date_range_result[[alias_row$last_alias]][[1]]
            ]
          }
        }
      }
    }
    logDatabaseQualityAnalysisProgress(
      "Finished table ",
      table_name,
      " in ",
      formatDatabaseQualityAnalysisDuration(table_start_time),
      "."
    )
  }

  data.table::setcolorder(result, c(
    "TABLE_NAME",
    "COLUMN_NAME",
    "COLUMN_DESCRIPTION",
    DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN,
    DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS,
    intersect(DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS, names(result)),
    "TABLE_FAMILY",
    "ORDINAL_POSITION"
  ))
  result[order(TABLE_FAMILY, TABLE_NAME, ORDINAL_POSITION)]
}

formatDatabaseQualityAnalysisRunTimestamp <- function(timestamp) {
  format(timestamp, "%Y-%m-%d %H:%M:%S UTC", tz = "UTC")
}

formatDatabaseQualityAnalysisFilenameTimestamp <- function(timestamp) {
  format(timestamp, "%Y-%m-%d_%H-%M-%S")
}

collapseDatabaseQualityAnalysisConfigValue <- function(value) {
  if (length(value) == 0L) {
    return("")
  }
  paste(value, collapse = "; ")
}

createDatabaseQualityAnalysisMetadataSheet <- function(
  result,
  source_metadata,
  config,
  analysis_start_time,
  analysis_end_time,
  database_metadata = NULL
) {
  add_row <- function(property, value) {
    data.table::data.table(PROPERTY = property, VALUE = as.character(value))
  }

  result_rows_by_family <- result[, .N, by = TABLE_FAMILY][order(TABLE_FAMILY)]
  table_counts_by_family <- unique(result[, .(TABLE_FAMILY, TABLE_NAME)])[
    ,
    .N,
    by = TABLE_FAMILY
  ][order(TABLE_FAMILY)]
  commented_columns <- source_metadata[
    !is.na(COLUMN_DESCRIPTION) & nzchar(COLUMN_DESCRIPTION)
  ]

  rows <- list(
    add_row("analysis started at", formatDatabaseQualityAnalysisRunTimestamp(analysis_start_time)),
    add_row("analysis finished at", formatDatabaseQualityAnalysisRunTimestamp(analysis_end_time)),
    add_row(
      "analysis duration seconds",
      round(as.numeric(difftime(analysis_end_time, analysis_start_time, units = "secs")), 2)
    ),
    add_row("view schema", config$view_schema),
    add_row("view prefix", config$view_prefix),
    add_row("view postfix", config$view_postfix),
    add_row("included view patterns", collapseDatabaseQualityAnalysisConfigValue(config$included_view_patterns)),
    add_row("excluded view patterns", collapseDatabaseQualityAnalysisConfigValue(config$excluded_view_patterns)),
    add_row("additional views", collapseDatabaseQualityAnalysisConfigValue(config$additional_views)),
    add_row("count batch size", config$count_batch_size),
    add_row("value datetime columns enabled", isTRUE(config$include_value_datetime_columns)),
    add_row("value import datetime column", config$value_import_datetime_column),
    add_row("grouping overrides", nrow(config$grouping_overrides)),
    add_row("source views", data.table::uniqueN(source_metadata$VIEW_NAME)),
    add_row("source columns", nrow(source_metadata)),
    add_row("source columns with description", nrow(commented_columns)),
    add_row("report rows", nrow(result))
  )

  for (row_index in seq_len(nrow(table_counts_by_family))) {
    family_row <- table_counts_by_family[row_index]
    rows <- c(rows, list(add_row(
      paste0("tables in ", family_row$TABLE_FAMILY),
      family_row$N
    )))
  }
  for (row_index in seq_len(nrow(result_rows_by_family))) {
    family_row <- result_rows_by_family[row_index]
    rows <- c(rows, list(add_row(
      paste0("report rows in ", family_row$TABLE_FAMILY),
      family_row$N
    )))
  }

  if (!is.null(database_metadata) && nrow(database_metadata)) {
    rows <- c(rows, list(
      add_row("database system", database_metadata$dbms[[1]]),
      add_row("database server version", database_metadata$server_version[[1]]),
      add_row("database server encoding", database_metadata$server_encoding[[1]])
    ))
  }

  data.table::rbindlist(rows, use.names = TRUE)
}

splitDatabaseQualityAnalysisResultForExcel <- function(result) {
  output_columns <- setdiff(names(result), c("TABLE_FAMILY", "ORDINAL_POSITION"))
  non_fhir_output_columns <- setdiff(
    output_columns,
    DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[c("first_meta_last_updated", "last_meta_last_updated")]
  )
  sheets <- list(
    FHIR = result[TABLE_FAMILY == "FHIR", ..output_columns],
    Frontend = result[TABLE_FAMILY == "Frontend", ..non_fhir_output_columns],
    Other = result[TABLE_FAMILY == "Other", ..non_fhir_output_columns]
  )
  sheets <- lapply(sheets, function(sheet) {
    for (count_column in DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS) {
      data.table::set(
        sheet,
        i = which(!is.na(sheet[[count_column]]) & sheet[[count_column]] == 0L),
        j = count_column,
        value = NA_integer_
      )
    }
    sheet
  })
  sheets[vapply(sheets, nrow, integer(1)) > 0L]
}

formatDatabaseQualityAnalysisSheetForExcel <- function(sheet) {
  sheet <- data.table::as.data.table(data.table::copy(sheet))
  if (!nrow(sheet)) {
    return(sheet)
  }

  blank_row <- data.table::as.data.table(
    stats::setNames(
      as.list(rep(NA, ncol(sheet))),
      names(sheet)
    )
  )
  formatted_tables <- lapply(split(sheet, sheet$TABLE_NAME), function(table_rows) {
    table_rows[-1, TABLE_NAME := NA_character_]
    data.table::rbindlist(list(table_rows, blank_row), use.names = TRUE)
  })
  data.table::rbindlist(formatted_tables, use.names = TRUE)
}

writeDatabaseQualityAnalysisExcelFile <- function(
  sheets,
  filename_without_extension,
  timestamp = Sys.time(),
  subdir = "reports",
  target = c("global", "local")
) {
  target <- match.arg(target)
  module_sub_dir <- file.path(
    if (identical(target, "global")) MODULE_DIRS$global_dir else MODULE_DIRS$local_dir,
    subdir
  )
  if (!dir.exists(module_sub_dir)) {
    dir.create(module_sub_dir, recursive = TRUE)
  }
  file_name <- file.path(
    module_sub_dir,
    paste0(
      filename_without_extension,
      "_",
      formatDatabaseQualityAnalysisFilenameTimestamp(timestamp),
      ".xlsx"
    )
  )
  logDatabaseQualityAnalysisProgress("Writing Excel report to ", file_name, ".")

  workbook <- openxlsx::createWorkbook()
  datetime_style <- openxlsx::createStyle(numFmt = "yyyy-mm-dd hh:mm:ss")
  for (sheet_name in names(sheets)) {
    sheet <- data.table::as.data.table(sheets[[sheet_name]])
    if ("TABLE_NAME" %in% names(sheet)) {
      sheet <- formatDatabaseQualityAnalysisSheetForExcel(sheet)
    }
    openxlsx::addWorksheet(workbook, sheet_name)
    openxlsx::writeData(workbook, sheet_name, sheet, colNames = TRUE)
    datetime_columns <- match(DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS, names(sheet))
    datetime_columns <- datetime_columns[!is.na(datetime_columns)]
    if (length(datetime_columns) && nrow(sheet)) {
      openxlsx::addStyle(
        workbook,
        sheet = sheet_name,
        style = datetime_style,
        rows = seq_len(nrow(sheet)) + 1L,
        cols = datetime_columns,
        gridExpand = TRUE,
        stack = TRUE
      )
    }
    openxlsx::setColWidths(
      workbook,
      sheet = sheet_name,
      cols = seq_along(sheet),
      widths = "auto"
    )
  }
  openxlsx::saveWorkbook(workbook, file_name, overwrite = TRUE)
  logDatabaseQualityAnalysisProgress("Excel report written to ", file_name, ".")
  invisible(file_name)
}

createDatabaseQualityAnalysisReport <- function(config = getDatabaseQualityAnalysisConfig()) {
  analysis_start_time <- Sys.time()
  logDatabaseQualityAnalysisProgress(
    "Starting report. Output filename=",
    config$output_filename,
    ", count batch size=",
    config$count_batch_size,
    ", value datetime columns=",
    isTRUE(config$include_value_datetime_columns),
    "."
  )
  metadata <- loadDatabaseQualityAnalysisViewMetadata(config)
  history_metadata <- if (isTRUE(config$include_value_datetime_columns)) {
    loadDatabaseQualityAnalysisHistoryMetadata(config)
  } else {
    logDatabaseQualityAnalysisProgress(
      "Skipping historical view metadata because value datetime columns are disabled."
    )
    NULL
  }
  database_metadata <- loadDatabaseQualityAnalysisDatabaseMetadata()
  logDatabaseQualityAnalysisProgress("Calculating database quality analysis counts.")
  result <- calculateDatabaseQualityAnalysisCounts(metadata, config, history_metadata = history_metadata)
  analysis_end_time <- Sys.time()
  result_rows_by_family <- result[, .N, by = TABLE_FAMILY][order(TABLE_FAMILY)]
  logDatabaseQualityAnalysisProgress(
    "Calculated ",
    nrow(result),
    " report rows: ",
    paste(paste(result_rows_by_family$TABLE_FAMILY, result_rows_by_family$N, sep = "="), collapse = ", "),
    "."
  )
  sheets <- splitDatabaseQualityAnalysisResultForExcel(result)
  sheets$Metadata <- createDatabaseQualityAnalysisMetadataSheet(
    result,
    metadata,
    config,
    analysis_start_time,
    analysis_end_time,
    database_metadata = database_metadata
  )

  output_file <- writeDatabaseQualityAnalysisExcelFile(
    sheets,
    config$output_filename,
    timestamp = analysis_start_time
  )
  logDatabaseQualityAnalysisProgress(
    "Finished report in ",
    formatDatabaseQualityAnalysisDuration(analysis_start_time),
    ". Output: ",
    output_file
  )

  invisible(result)
}
