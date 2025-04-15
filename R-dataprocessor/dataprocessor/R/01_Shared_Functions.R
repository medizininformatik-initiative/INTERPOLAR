#' Get the most relevant current datetime
#'
#' This function retrieves the latest encounter end datetime from the `encounters` table.
#' If no valid end datetime is available, it defaults to the current system time (`Sys.time()`).
#' The result is converted to a `POSIXct` object with the appropriate timezone.
#'
#' @param encounters A `data.table` or `data.frame` containing encounter records,
#'                   where `enc_period_end` represents the encounter end timestamps.
#'
#' @return A `POSIXct` object representing the most recent encounter end datetime
#'         or the current system time if no valid datetime is found.
#'
getCurrentDatetime <- function(encounters) {
  encounters_end <- na.omit(encounters$enc_period_end)
  datetime <- if (length(encounters_end)) min(encounters_end) - 1 else Sys.time()
  return(etlutils::as.POSIXctWithTimezone(datetime))
}

#' Format datetime for SQL queries
#'
#' This function formats the datetime returned by `getCurrentDatetime()` into an SQL-compatible
#' timestamp string in the format `"YYYY-MM-DD HH:MM:SS"`.
#'
#' @param encounters A `data.table` or `data.frame` containing encounter records.
#'                   Used to determine the latest encounter end datetime.
#'
#' @return A character string representing the formatted SQL datetime.
#'
getQueryDatetime <- function(encounters) {
  format(getCurrentDatetime(encounters), "%Y-%m-%d %H:%M:%S")
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

####################################################
# Load Resources by ID (= own ID or PID or Enc ID) #
####################################################

#' Load Resources Last Status From Database Query
#'
#' This function constructs a SQL statement to retrieve the last status of load resources
#' from a specified table in the database. It utilizes various helper functions to
#' determine the table name, ID column, and apply optional filtering conditions.
#'
#' @param resource_name The name of the resource for which to retrieve the last status.
#' @param filter Additional filtering conditions to apply to the query. Default is an empty string.
#'
#' @return A character string representing the SQL query.
#'
getQueryToLoadResourcesLastStatusFromDB <- function(resource_name, filter = "") {
  # this should be view tables named in a style like 'v_patient' for resource_name Patient
  query <-paste0(
    "SELECT * FROM v_", resource_name, "_last_version\n",
    if (nchar(filter)) paste0("\n", filter) else "",
    ";\n"
  )
  return(query)
}

#' Generate a filter statement for a SQL query.
#'
#' This function generates a filter statement to be used in a SQL query based on the
#' provided filter column and filter column values. It quotes each value and collapses
#' them into a comma-separated string. If the filter column is the resource ID column,
#' it adjusts the filter column values accordingly to handle references.
#'
#' @param resource_name The name of the resource table.
#' @param filter_column The column on which to apply the filter.
#' @param filter_column_values A vector of values to filter on.
#'
#' @return A character string representing the filter statement for the SQL query.
#'
getStatementFilter <- function(resource_name, filter_column = NA, filter_column_values = NA) {
  if (is.na(filter_column) || all(is.na(filter_column_values))) {
    return("")
  }
  resource_id_column <- etlutils::fhirdbGetIDColumn(resource_name)
  if (filter_column == resource_id_column) {
    # remove resource name and the slash if the IDs are references and not pure IDs
    filter_column_values <- gsub(paste0("^", resource_name, "/"), "", filter_column_values)
  }
  # quote every pid and collapse the vector comma separated
  filter_column_values <- paste0("'", filter_column_values, "'", collapse = ",")
  filter_line <- paste0("WHERE ", filter_column, " IN (", filter_column_values, ")\n")
  return(filter_line)
}

#' Execute a SQL query to retrieve data from the database.
#'
#' This function constructs and executes a SQL query to retrieve data from the database
#' based on the provided resource name, filter column, and IDs. It utilizes helper functions
#' to generate the filter statement and the main query statement.
#'
#' @param resource_name The name of the resource table.
#' @param filter_column The column on which to apply the filter.
#' @param ids A vector of IDs to filter on.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#' @return A data frame containing the results of the SQL query.
#'
loadResourcesFromDB <- function(resource_name, filter_column = NA, ids = NA, lock_id) {
  filter <- getStatementFilter(resource_name, filter_column, ids)
  query <- getQueryToLoadResourcesLastStatusFromDB(resource_name, filter)
  etlutils::dbGetReadOnlyQuery(query, lock_id = lock_id)
}

#' Retrieve the last status of load resources from the database.
#'
#' This function executes a SQL query to retrieve the last status of load resources
#' from the database, based on the provided resource name. It utilizes a helper function
#' to construct the query statement.
#'
#' @param resource_name The name of the resource table.
#'
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusFromDB <- function(resource_name) {
  query <- getQueryToLoadResourcesLastStatusFromDB(resource_name)
  etlutils::dbGetReadOnlyQuery(query, lock_id = paste0("loadResourcesLastStatusFromDB(", resource_name, ")"))
}

#' Retrieve the last status of load resources from the database by their own IDs.
#'
#' This function retrieves the last status of load resources from the database
#' based on their own IDs. It constructs and executes a SQL query using the provided
#' resource name and IDs, leveraging a helper function.
#'
#' @param resource_name The name of the resource table.
#' @param ids A vector of IDs to retrieve the last status for.
#'
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByOwnIDFromDB <- function(resource_name, ids) {
  id_column <- etlutils::fhirdbGetIDColumn(resource_name)
  loadResourcesFromDB(
    resource_name = resource_name,
    filter_column = id_column,
    ids = ids,
    lock_id = paste0("loadResourcesLastStatusByOwnIDFromDB(", resource_name, ")"))
}

#' Retrieve the last status of load resources from the database by PID.
#'
#' This function retrieves the last status of load resources from the database
#' based on Patient ID (PID) if the resource is patient-related; otherwise, it
#' retrieves based on the provided PID column name. It constructs and executes
#' a SQL query using the provided resource name and PID(s), leveraging helper functions.
#'
#' @param resource_name The name of the resource table.
#' @param pids A vector of Patient IDs (PIDs) or related IDs to retrieve the last status for.
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByPIDFromDB <- function(resource_name, pids) {
  if (tolower(resource_name) %in% "patient") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, pids))
  }
  pid_column <- etlutils::fhirdbGetPIDColumn(resource_name)
  loadResourcesFromDB(
    resource_name = resource_name,
    filter_column = pid_column,
    ids = pids,
    lock_id = paste0("loadResourcesLastStatusByPIDFromDB(",resource_name,")"))
}

#' Load Resources Last Status By Encounter ID From Database
#'
#' Retrieve the last status of load resources from the database by Encounter ID.
#'
#' This function retrieves the last status of load resources from the database
#' based on Encounter ID if the resource is encounter-related; otherwise, it
#' retrieves based on the provided Encounter ID column name. It constructs and
#' executes a SQL query using the provided resource name and Encounter ID(s),
#' leveraging helper functions.
#'
#' @param resource_name The name of the resource table.
#' @param enc_ids A vector of Encounter IDs to retrieve the last status for.
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByEncIDFromDB <- function(resource_name, enc_ids) {
  if (tolower(resource_name) %in% "encounter") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, enc_ids))
  }
  enc_id_column <- etlutils::fhirdbGetEncIDColumn(resource_name)
  loadResourcesFromDB(
    resource_name = resource_name,
    filter_column = enc_id_column,
    ids = enc_ids,
    lock_id = paste0("loadResourcesLastStatusByEncIDFromDB(", resource_name, ")"))
}

#' Find Related Partof Encounters for a Main Encounter
#'
#' This function identifies valid part encounters that are associated with a given main encounter.
#' A part encounter is considered valid if:
#' - It starts on or after the main encounter's start time.
#' - If both the main and part encounters have an end time, the part encounter must end on or before the main encounter's end time.
#'
#' @param main_encounter A **data.table** containing a single row with the main encounter information.
#' It should include `enc_period_start` and optionally `enc_period_end`.
#' @param pid_part_of_encounters A **data.table** with multiple part encounters, each having
#' `enc_period_start` and optionally `enc_period_end`.
#'
#' @return A filtered **data.table** containing only the part encounters that meet the conditions.
#'
findPartOfEncounters <- function(main_encounter, pid_part_of_encounters) {
  # Condition 1: The part encounter must start on or after the main encounter starts
  condition_start <- pid_part_of_encounters$enc_period_start >= main_encounter$enc_period_start

  # Condition 2: Compare enc_period_end only if both values are not NA
  condition_end <- is.na(main_encounter$enc_period_end) |
    is.na(pid_part_of_encounters$enc_period_end) |
    (pid_part_of_encounters$enc_period_end <= main_encounter$enc_period_end)

  result <- pid_part_of_encounters[condition_start & condition_end]
}
