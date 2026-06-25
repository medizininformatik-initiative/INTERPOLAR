normalizeArgumentName <- function(argument_name) {
  argument_name <- sub("^-+", "", argument_name)
  argument_name <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", argument_name)
  tolower(gsub("-", "_", argument_name, fixed = TRUE))
}

getCommandArguments <- function(command_arguments = NULL) {
  if (is.null(command_arguments)) {
    return(commandArgs(trailingOnly = TRUE))
  }
  if (length(command_arguments) == 1L) {
    return(strsplit(command_arguments, " +")[[1]])
  }
  command_arguments
}

parseCommandLineConfig <- function(command_arguments = NULL) {
  command_arguments <- getCommandArguments(command_arguments)
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
    normalizeArgumentName,
    character(1)
  )
  if (any(normalized_argument_names %in% c("skip_value_datetime_columns", "s"))) {
    parsed$INCLUDE_VALUE_DATETIME_COLUMNS <- FALSE
  }
  parsed
}

getConfig <- function(envir = .GlobalEnv, command_arguments = NULL) {
  command_line_config <- parseCommandLineConfig(command_arguments)

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
    grouping_overrides = parseGroupingOverrides(getConfigValue("GROUPING_OVERRIDES", character()))
  )
}

parseGroupingOverrides <- function(overrides) {
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
