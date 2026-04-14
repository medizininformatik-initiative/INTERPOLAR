#' Validate ward phase definitions
#'
#' Validates ward phase definitions loaded from global variables with the prefix
#' `PHASES_WARD`. Each definition must contain exactly one non-empty
#' `ward_name`, exactly one `phase_a_start`, and at most one `phase_b_start`.
#' The function also checks that all timestamps have a valid format and that
#' `phase_b_start`, if present, is later than `phase_a_start`.
#'
#' @param timezone A character string defining the timezone used for parsing
#'   phase timestamps.
#'
#' @return Invisibly returns `TRUE` if all ward phase definitions are valid.
#'   Otherwise, the function stops with an error describing the first invalid
#'   definition found.
#'
#' @examples
#' PHASES_WARD_1 <- c(
#'   "ward_name = 'Station 1'",
#'   "phase_a_start = '2026-01-11 10:00:00'",
#'   "phase_b_start = '2026-01-21 10:00:00'"
#' )
#'
#' PHASES_WARD_2 <- c(
#'   "ward_name = 'Station 2'",
#'   "phase_a_start = '2026-01-11'",
#'   "phase_b_start = '2026-01-12'"
#' )
#'
#' validateWardPhases(timezone = "UTC")
#'
#' @export
validateWardPhases <- function(timezone = GLOBAL_TIMEZONE) {

  msg_prefix <- "dataprocessor_config.toml: "

  ward_phases <- etlutils::getGlobalVariablesByPrefix("PHASES_WARD")
  if (!is.list(ward_phases) || length(ward_phases) == 0L) {
    return(invisible(TRUE))
  }

  pattern <- "^\\s*(ward_name|phase_a_start|phase_b_start)\\s*=\\s*'([^']*)'\\s*$"

  ward_names <- character()
  getEntryName <- function(x, index) {
    x_names <- names(x)
    if (is.null(x_names) || length(x_names) < index || is.na(x_names[index]) || x_names[index] == "") {
      return(paste0("[[", index, "]]"))
    }
    x_names[index]
  }

  for (i in seq_along(ward_phases)) {

    entry_name <- getEntryName(ward_phases, i)

    entry <- ward_phases[[i]]
    if (!is.character(entry)) {
      stop(msg_prefix, "Entry ", entry_name, " must be a character vector.")
    }
    if (length(entry) == 0L) {
      stop(msg_prefix, "Entry ", entry_name, " must not be empty.")
    }

    keys <- character()
    values <- character()

    for (line_index in seq_along(entry)) {
      line <- entry[[line_index]]
      parts <- strsplit(line, "(?=(?:[^']*'[^']*')*[^']*$)\\+", perl = TRUE)[[1]]
      if (length(parts) > 1L) {
        stop(msg_prefix, "Character '+' is not allowed in entry ", entry_name, " / line ", line_index, ": ", line)
      }
      if (!grepl(pattern, line, perl = TRUE)) {
        stop(msg_prefix, "Invalid line in entry ", entry_name, " / line ", line_index, ": ", line)
      }
      match <- regmatches(line, regexec(pattern, line, perl = TRUE))[[1]]
      keys <- c(keys, match[2])
      values <- c(values, match[3])
    }

    if (sum(keys == "ward_name") != 1L) {
      stop(msg_prefix, "Entry ", entry_name, " must contain exactly one ward_name.")
    }
    if (sum(keys == "phase_a_start") != 1L) {
      stop(msg_prefix, "Entry ", entry_name, " must contain exactly one phase_a_start.")
    }
    if (sum(keys == "phase_b_start") > 1L) {
      stop(msg_prefix, "Entry ", entry_name, " must contain at most one phase_b_start.")
    }

    ward_name <- values[keys == "ward_name"]
    if (trimws(ward_name) == "") {
      stop(msg_prefix, "ward_name must not be empty in entry ", entry_name, ".")
    }
    if (ward_name %in% ward_names) {
      stop(msg_prefix, "Duplicate ward_name found: '", ward_name, "'.")
    }

    phase_a_raw <- values[keys == "phase_a_start"]
    phase_a <- etlutils::parseTimestamp(phase_a_raw, timezone = timezone)

    if (is.na(phase_a)) {
      stop(msg_prefix, "phase_a_start is not a valid timestamp in entry ", entry_name, ": ", phase_a_raw)
    }
    if (any(keys == "phase_b_start")) {
      phase_b_raw <- values[keys == "phase_b_start"]
      phase_b <- etlutils::parseTimestamp(phase_b_raw, timezone = timezone)
      if (is.na(phase_b)) {
        stop(msg_prefix, "phase_b_start is not a valid timestamp in entry ", entry_name, ": ", phase_b_raw)
      }
      if (!(phase_a < phase_b)) {
        stop(msg_prefix, "phase_a_start must be earlier than phase_b_start in entry ", entry_name, ".")
      }
    }
    ward_names <- c(ward_names, ward_name)
  }
  invisible(TRUE)
}

# This function constructs an error or warning message with optional additional
# information such as related tables and database connection details. It can be
# used to provide more context when reporting errors or warnings.
getErrorOrWarningMessage <- function(text, tables = NA, readonly = TRUE) {
  tables <- if (!etlutils::isSimpleNA(tables)) paste0(" Table(s): ", paste0(tables, collapse = ", "), ";") else ""
  db_connection <- if (!etlutils::isSimpleNA(readonly)) etlutils::dbGetInfo(readonly) else ""
  text <- paste0(text, tables, db_connection)
  return(text)
}

#' Parse Query List
#'
#' This function takes a query list string and splits it based on a specified delimiter
#' to create a vector of elements. It utilizes the \code{etlutils::fhirdbGetQueryList}
#' function to create the vector.
#'
#' @param list_string The query list string to parse.
#' @param split The delimiter used to split the query list string. Default is a space.
#'
#' @return A vector containing the parsed elements from the query list string.
#'
parseQueryList <- function(list_string, split = " ") {
  splitted <- unlist(strsplit(list_string, split))
  etlutils::fhirdbGetQueryList(splitted)
}

#' Get the end datetime of the given encounters
#'
#' This function retrieves the latest encounter end datetime from the `encounters` table.
#' If no valid end datetime is available, it defaults to the current system time (`Sys.time()`).
#' The result is converted to a `POSIXct` object with the appropriate timezone.
#'
#' NOTE: If the cds2db modules runs with a dubug start and end date, then there can
#' be encounters with a start date after the end date of another encounter. This should
#' never happens in a non debug run and can lead to irregularities in the results.
#'
#' @param encounters A `data.table` or `data.frame` containing encounter records,
#'                   where `enc_period_end` represents the encounter end timestamps.
#'
#' @return A `POSIXct` object representing the most recent encounter end datetime
#'         or the current system time if no valid datetime is found.
#'
getEncountersPeriodEnd <- function(encounters) {
  encounters_end <- na.omit(encounters$enc_period_end)
  sys_time <- Sys.time()
  datetime <- if (length(encounters_end)) etlutils::getMaxDatetime(encounters_end) - 1 else sys_time
  if (datetime > sys_time) {
    # if the latest encounter end is in the future, use the current system time
    datetime <- sys_time
  }
  return(etlutils::as.POSIXctWithTimezone(datetime))
}

#' Format datetime for SQL queries for Observations.
#'
#' This function formats the datetime returned by `getEncountersEndDatetime()` into an SQL-compatible
#' timestamp string in the format `"YYYY-MM-DD HH:MM:SS"`.
#'
#' @param encounters A `data.table` or `data.frame` containing encounter records.
#'                   Used to determine the latest encounter end datetime.
#'
#' @return A character string representing the formatted SQL datetime.
#'
getObservationQueryDatetime <- function(encounters) {
  encounters_end <- getEncountersPeriodEnd(encounters)
  format(encounters_end, "%Y-%m-%d %H:%M:%S")
}

#' Load Resources Last Version From Database Query
#'
#' This function constructs a SQL statement to retrieve the last version of resources
#' from a specified table in the database. It utilizes various helper functions to
#' determine the table name, ID column, and apply optional filtering conditions.
#'
#' @param resource_name The name of the resource for which to retrieve the last version.
#' @param column_names names of the columns to return as vector or string. Default is "*".
#' @param filter Additional filtering conditions to apply to the query. Default is an empty string.
#'
#' @return A character string representing the SQL query.
#'
getQueryToLoadResourcesLastVersionFromDB <- function(resource_name, column_names = "*", filter = "") {
  resource_name <- tolower(resource_name)
  db_id_column <- paste0(resource_name, "_id")
  select_all <- identical(column_names, "*")
  if (!select_all && !(db_id_column %in% column_names)) {
    column_names <- c(db_id_column, column_names)
  }
  if (nchar(filter) && !endsWith(filter, "\n")) filter <- paste0(filter, "\n")
  # ensure that the resource name is valid
  distinct <- if (select_all) "" else "DISTINCT "
  # this should be view tables named in a style like 'v_patient' for resource_name Patient
  column_names <- paste0(column_names, collapse = ", ")
  query <- paste0(
    "SELECT ", distinct, column_names, " FROM v_", resource_name, "_last_version\n",
    filter,
    paste0("ORDER BY ", db_id_column, "\n"),
    ";\n"
  )
  return(query)
}

#' Generate a filter statement for a SQL query as WHERE Clause.
#'
#' This function generates a filter statement to be used in a SQL query based on the
#' provided target column and filter column values. It quotes each value and collapses
#' them into a comma-separated string. If the target column is the resource ID column,
#' it adjusts the filter column values accordingly to handle references.
#'
#' @param resource_name The name of the resource table.
#' @param target_column The column on which to apply the WHERE filter.
#' @param target_values A vector of values to filter on.
#'
#' @return A character string representing the filter statement for the SQL query.
#'
getWhereClauseForReferencedResources <- function(resource_name, target_column = NA, target_values = NA) {
  if (is.na(target_column) || all(is.na(target_values))) {
    return("")
  }
  target_values <- unique(na.omit(target_values))
  resource_id_column <- etlutils::fhirdbGetIDColumn(resource_name)
  if (target_column == resource_id_column) {
    # remove resource name and the slash if the IDs are references and not pure IDs
    target_values <- etlutils::fhirdataExtractIDs(target_values)
  }
  # quote every pid and collapse the vector comma separated
  target_values <- etlutils::fhirdbGetQueryList(target_values)
  where_clause <- paste0("WHERE ", target_column, " IN ", target_values, "\n")
  return(where_clause)
}

#' Execute a SQL query to retrieve data from the database.
#'
#' This function constructs and executes a SQL query to retrieve data from the database
#' based on the provided resource name, filter column, and IDs. It utilizes helper functions
#' to generate the filter statement and the main query statement.
#'
#' @param resource_name The name of the resource table.
#' @param column_names names of the columns to return as vector or string. Default is "*".
#' @param filter_column The column on which to apply the filter.
#' @param filter_column_values A vector of values to filter on.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#' @return A data frame containing the results of the SQL query.
#'
loadResourcesFilteredByValuesFromDB <- function(resource_name, column_names = "*", filter_column = NA, filter_column_values = NA, lock_id) {
  where_clause <- getWhereClauseForReferencedResources(resource_name, filter_column, filter_column_values)
  query <- getQueryToLoadResourcesLastVersionFromDB(resource_name, column_names, where_clause)
  etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id)
}

#' Retrieve the last version of load resources from the database by their own IDs.
#'
#' This function retrieves the last version of resources from the database based
#' on their own IDs. It constructs and executes a SQL query using the provided
#' resource name and IDs, leveraging a helper function.
#'
#' @param resource_name The name of the resource table.
#' @param ids_or_refs A vector of IDs to retrieve the last version for. If these are
#' references, they will be converted to IDs.
#'
#' @return A data frame containing the last version of load resources.
#'
loadResourcesLastVersionByOwnIDFromDB <- function(resource_name, ids_or_refs) {
  id_column <- etlutils::fhirdbGetIDColumn(resource_name)
  loadResourcesFilteredByValuesFromDB(
    resource_name = resource_name,
    filter_column = id_column,
    filter_column_values = ids_or_refs,
    lock_id = paste0("loadResourcesLastVersionByOwnIDFromDB(", resource_name, ")"))
}

#' Load existing record IDs from the database for given patient IDs
#'
#' This function retrieves the existing record IDs associated with a given set of
#' patient IDs from the `v_patient_fe` view in the database. It builds a query using
#' the provided patient IDs and executes it in read-only mode with an appropriate lock ID.
#'
#' @param pat_ids A character vector of patient IDs to look up in the database.
#'
#' @return A data.table containing the columns \code{pat_id} and \code{record_id} for
#' all matching patients found in the database.
#'
#' @export
loadExistingRecordIDsFromDB <- function(pat_ids) {
  pat_ids <- etlutils::fhirdataExtractIDs(pat_ids)
  query_ids <- etlutils::fhirdbGetQueryList(pat_ids)
  query <- paste0("SELECT pat_id, record_id FROM v_patient_fe WHERE pat_id IN ", query_ids)
  existing_record_ids <- etlutils::dbGetReadOnlyQuery(query, lock_id = "loadExistingRecordIDsFromDB()")
  return(existing_record_ids)
}
