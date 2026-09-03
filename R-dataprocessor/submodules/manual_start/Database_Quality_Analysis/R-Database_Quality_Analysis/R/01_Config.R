#' Normalize a command-line argument name
#'
#' Converts command-line option names to lower snake case config keys.
normalizeArgumentName <- function(argument_name) {
  argument_name <- sub("^-+", "", argument_name)
  argument_name <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", argument_name)
  tolower(gsub("-", "_", argument_name, fixed = TRUE))
}

#' Get command-line arguments
#'
#' Returns explicit arguments or the trailing arguments from the current R process.
getCommandArguments <- function(command_arguments = NULL) {
  if (is.null(command_arguments)) {
    return(commandArgs(trailingOnly = TRUE))
  }
  if (length(command_arguments) == 1L) {
    return(strsplit(command_arguments, " +")[[1]])
  }
  command_arguments
}

#' Parse command-line config overrides
#'
#' Maps supported command-line key-value arguments to DQA config names.
parseCommandLineConfig <- function(command_arguments = NULL) {
  command_arguments <- getCommandArguments(command_arguments)
  key_value_arguments <- command_arguments[grepl("=", command_arguments, fixed = TRUE)]
  parsed <- etlutils::initCommandLineArguments(
    argument2global_variable_name = c(
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
  if (any(normalized_argument_names %in% c(
    "include_value_summary_values_columns",
    "include_values_columns"
  ))) {
    parsed$INCLUDE_VALUE_SUMMARY_VALUES_COLUMNS <- TRUE
  }
  parsed
}

#' Build the database quality analysis configuration
#'
#' Reads command-line, global-environment and default values into one config list.
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
    view_prefix = getConfigValue("VIEW_PREFIX", "v_"),
    view_postfix = getConfigValue("VIEW_POSTFIX", "_last_version"),
    value_import_datetime_column = getConfigValue("VALUE_IMPORT_DATETIME_COLUMN", "input_datetime"),
    include_value_datetime_columns = as.logical(
      getConfigValue("INCLUDE_VALUE_DATETIME_COLUMNS", TRUE)
    ),
    output_filename = getConfigValue("OUTPUT_FILENAME", "Database_Quality_Analysis"),
    count_batch_size = as.integer(getConfigValue("COUNT_BATCH_SIZE", 100)),
    use_database_locks = as.logical(getConfigValue("USE_DATABASE_LOCKS", FALSE)),
    boolean_group_table_families = getConfigValue("BOOLEAN_GROUP_TABLE_FAMILIES", "Frontend"),
    boolean_group_column_pattern = getConfigValue("BOOLEAN_GROUP_COLUMN_PATTERN", "___[0-9]+$"),
    boolean_true_values = getConfigValue("BOOLEAN_TRUE_VALUES", "Checked"),
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
    grouping_overrides = parseGroupingOverrides(getConfigValue("GROUPING_OVERRIDES", character())),
    filtered_scope_sheet_names = getConfigValue("FILTERED_SCOPE_SHEET_NAMES", character()),
    filtered_scope_detail_sheet_suffix = getConfigValue("FILTERED_SCOPE_DETAIL_SHEET_SUFFIX", "FILTERED"),
    value_summary_table_families = getConfigValue(
      "VALUE_SUMMARY_TABLE_FAMILIES",
      c("FHIR", "Frontend")
    ),
    value_summary_suppressed_column_patterns = list(
      FHIR = getConfigValue(
        "VALUE_SUMMARY_FHIR_SUPPRESSED_COLUMN_PATTERNS",
        character()
      ),
      Frontend = getConfigValue(
        "VALUE_SUMMARY_FRONTEND_SUPPRESSED_COLUMN_PATTERNS",
        character()
      )
    ),
    include_value_summary_values_columns = as.logical(
      getConfigValue("INCLUDE_VALUE_SUMMARY_VALUES_COLUMNS", FALSE)
    ),
    resource_detail_sheets = parseResourceDetailSheets(getConfigValue)
  )
}

#' Get configured filtered-scope sheet names
#'
#' Returns the base sheet names for which filtered-scope sheets should be created.
getFilteredScopeSheetNames <- function(config) {
  if (!is.null(config$filtered_scope_sheet_names)) {
    return(config$filtered_scope_sheet_names[nzchar(config$filtered_scope_sheet_names)])
  }
  character()
}

#' Check whether filtered-scope sheets are configured
#'
#' Returns TRUE when at least one filtered-scope base sheet name is configured.
isFilteredScopeSheetsEnabled <- function(config) {
  length(getFilteredScopeSheetNames(config)) > 0L
}

#' Check whether a sheet has a filtered-scope variant
#'
#' Tests whether a base sheet name is listed for filtered-scope generation.
isFilteredScopeSheetConfigured <- function(sheet_name, config) {
  sheet_name %in% getFilteredScopeSheetNames(config)
}

#' Get the filtered-scope detail sheet suffix
#'
#' Returns the configured suffix used for filtered resource detail sheet names.
getFilteredScopeDetailSheetSuffix <- function(config) {
  if (!is.null(config$filtered_scope_detail_sheet_suffix)) {
    return(config$filtered_scope_detail_sheet_suffix)
  }
  "FILTERED"
}

#' Get the filtered-scope label
#'
#' Returns the configured suffix or a generic label for descriptions and logs.
getFilteredScopeLabel <- function(config) {
  getFilteredScopeDetailSheetSuffix(config)
}

#' Build a filtered-scope sheet name
#'
#' Appends the configured suffix to a base sheet name when filtered output is enabled.
getFilteredScopeSheetName <- function(sheet_name, config) {
  suffix <- getFilteredScopeDetailSheetSuffix(config)
  if (!nzchar(suffix)) {
    return(sheet_name)
  }
  paste(sheet_name, suffix)
}

#' Parse grouping column overrides
#'
#' Converts configured grouping override strings into a nested lookup table.
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

#' Parse semicolon-separated name-value pairs
#'
#' Converts configuration strings like name=value into named character vectors.
parseNameValuePairs <- function(value, entry_name) {
  if (length(value) > 1L) {
    pairs <- value
  } else {
    pairs <- strsplit(value, ";", fixed = TRUE)[[1]]
  }
  pairs <- pairs[nzchar(pairs)]
  pair_parts <- strsplit(pairs, "=", fixed = TRUE)
  invalid_pairs <- vapply(pair_parts, length, integer(1)) != 2L
  if (any(invalid_pairs)) {
    stop(
      "Invalid ",
      entry_name,
      " entry. Expected name=value pairs.",
      call. = FALSE
    )
  }

  result <- vapply(pair_parts, function(pair) pair[[2]], character(1))
  names(result) <- vapply(pair_parts, function(pair) pair[[1]], character(1))
  result
}

#' Parse resource detail sheet configuration
#'
#' Builds resource detail sheet definitions from the configured sheet keys.
parseResourceDetailSheets <- function(get_config_value) {
  sheet_names <- get_config_value("RESOURCE_DETAIL_SHEET_NAMES", character())
  if (!length(sheet_names)) {
    return(list())
  }

  parseResourceDetailSheetFields(sheet_names, get_config_value)
}

#' Parse resource detail sheet fields
#'
#' Reads the table, grouping and count settings for each configured detail sheet.
parseResourceDetailSheetFields <- function(sheet_names, get_config_value) {
  # Resource detail sheets use the same grouping mechanism on two nested levels:
  # row_group creates the repeated row/table groups, and count_group creates
  # additional count columns inside each row group. For one detail sheet, the
  # group values can be configured as readable TOML lists of name=value entries.
  scalar_field_names <- c(
    "TABLE_NAMES",
    "ROW_GROUP_SYSTEM_COLUMNS",
    "ROW_GROUP_SYSTEMS",
    "ROW_GROUP_VALUE_COLUMNS",
    "COUNT_GROUP_SYSTEM_COLUMNS",
    "COUNT_GROUP_SYSTEMS",
    "COUNT_GROUP_VALUE_COLUMNS"
  )
  fields <- stats::setNames(lapply(scalar_field_names, function(field_name) {
    value <- get_config_value(paste0("RESOURCE_DETAIL_", field_name), NULL)
    if (is.null(value)) {
      stop("Missing RESOURCE_DETAIL_", field_name, ".", call. = FALSE)
    }
    if (length(value) != length(sheet_names)) {
      stop(
        "RESOURCE_DETAIL_",
        field_name,
        " must have the same length as RESOURCE_DETAIL_SHEET_NAMES.",
        call. = FALSE
      )
    }
    value
  }), scalar_field_names)
  fields$ROW_GROUP_VALUES <- getResourceDetailGroupValueFields(
    "ROW_GROUP_VALUES",
    sheet_names,
    get_config_value
  )
  fields$COUNT_GROUP_VALUES <- getResourceDetailGroupValueFields(
    "COUNT_GROUP_VALUES",
    sheet_names,
    get_config_value
  )

  result <- lapply(seq_along(sheet_names), function(sheet_index) {
    count_group_values <- parseNameValuePairs(
      fields$COUNT_GROUP_VALUES[[sheet_index]],
      "RESOURCE_DETAIL_COUNT_GROUP_VALUES"
    )
    list(
      sheet_name = sheet_names[[sheet_index]],
      table_name = fields$TABLE_NAMES[[sheet_index]],
      row_group_system_column = fields$ROW_GROUP_SYSTEM_COLUMNS[[sheet_index]],
      row_group_system = fields$ROW_GROUP_SYSTEMS[[sheet_index]],
      row_group_value_column = fields$ROW_GROUP_VALUE_COLUMNS[[sheet_index]],
      row_group_values = parseNameValuePairs(
        fields$ROW_GROUP_VALUES[[sheet_index]],
        "RESOURCE_DETAIL_ROW_GROUP_VALUES"
      ),
      count_group_system_column = fields$COUNT_GROUP_SYSTEM_COLUMNS[[sheet_index]],
      count_group_system = fields$COUNT_GROUP_SYSTEMS[[sheet_index]],
      count_group_value_column = fields$COUNT_GROUP_VALUE_COLUMNS[[sheet_index]],
      count_group_values = count_group_values,
      count_group_count_columns = stats::setNames(names(count_group_values), names(count_group_values))
    )
  })
  names(result) <- vapply(result, function(detail_config) detail_config$table_name, character(1))
  result
}

#' Read grouped detail sheet values
#'
#' Reads and validates named value lists for resource detail row or count groups.
getResourceDetailGroupValueFields <- function(field_name, sheet_names, get_config_value) {
  value <- get_config_value(paste0("RESOURCE_DETAIL_", field_name), NULL)
  if (is.null(value)) {
    stop("Missing RESOURCE_DETAIL_", field_name, ".", call. = FALSE)
  }
  if (length(sheet_names) == 1L) {
    return(list(value))
  }
  if (length(value) != length(sheet_names)) {
    stop(
      "RESOURCE_DETAIL_",
      field_name,
      " must have the same length as RESOURCE_DETAIL_SHEET_NAMES.",
      call. = FALSE
    )
  }
  as.list(value)
}
