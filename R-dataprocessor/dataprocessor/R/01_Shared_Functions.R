#' Get the most relevant current datetime
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
getCurrentDatetime <- function(encounters) {
  encounters_end <- na.omit(encounters$enc_period_end)
  datetime <- if (length(encounters_end)) max(encounters_end) - 1 else Sys.time()
  return(etlutils::as.POSIXctWithTimezone(datetime))
}

#' Format datetime for SQL queries for Observations.
#'
#' This function formats the datetime returned by `getCurrentDatetime()` into an SQL-compatible
#' timestamp string in the format `"YYYY-MM-DD HH:MM:SS"`.
#'
#' @param encounters A `data.table` or `data.frame` containing encounter records.
#'                   Used to determine the latest encounter end datetime.
#'
#' @return A character string representing the formatted SQL datetime.
#'
getObservationQueryDatetime <- function(encounters) {
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

#' Load Resources Last Version From Database Query
#'
#' This function constructs a SQL statement to retrieve the last version of resources
#' from a specified table in the database. It utilizes various helper functions to
#' determine the table name, ID column, and apply optional filtering conditions.
#'
#' @param resource_name The name of the resource for which to retrieve the last version.
#' @param filter Additional filtering conditions to apply to the query. Default is an empty string.
#'
#' @return A character string representing the SQL query.
#'
getQueryToLoadResourcesLastVersionFromDB <- function(resource_name, filter = "") {
  # this should be view tables named in a style like 'v_patient' for resource_name Patient
  query <-paste0(
    "SELECT * FROM v_", resource_name, "_last_version\n",
    if (nchar(filter)) paste0("\n", filter) else "",
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
getWhereClause <- function(resource_name, target_column = NA, target_values = NA) {
  if (is.na(target_column) || all(is.na(target_values))) {
    return("")
  }
  target_values <- unique(na.omit(target_values))
  resource_id_column <- etlutils::fhirdbGetIDColumn(resource_name)
  if (target_column == resource_id_column) {
    # remove resource name and the slash if the IDs are references and not pure IDs
    target_values <- gsub(paste0("^", resource_name, "/"), "", target_values)
  }
  # quote every pid and collapse the vector comma separated
  target_values <- paste0("'", target_values, "'", collapse = ",")
  where_clause <- paste0("WHERE ", target_column, " IN (", target_values, ")\n")
  return(where_clause)
}

#' Execute a SQL query to retrieve data from the database.
#'
#' This function constructs and executes a SQL query to retrieve data from the database
#' based on the provided resource name, filter column, and IDs. It utilizes helper functions
#' to generate the filter statement and the main query statement.
#'
#' @param resource_name The name of the resource table.
#' @param filter_column The column on which to apply the filter.
#' @param filter_column_values A vector of values to filter on.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#' @return A data frame containing the results of the SQL query.
#'
loadResourcesFilteredFromDB <- function(resource_name, filter_column = NA, filter_column_values = NA, lock_id) {
  where_clause <- getWhereClause(resource_name, filter_column, filter_column_values)
  query <- getQueryToLoadResourcesLastVersionFromDB(resource_name, where_clause)
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
  loadResourcesFilteredFromDB(
    resource_name = resource_name,
    filter_column = id_column,
    filter_column_values = ids_or_refs,
    lock_id = paste0("loadResourcesLastVersionByOwnIDFromDB(", resource_name, ")"))
}
