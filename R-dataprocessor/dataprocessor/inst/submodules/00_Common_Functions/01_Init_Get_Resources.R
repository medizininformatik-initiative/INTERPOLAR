# List with resource abbreviations
column_prefixes <- list(
  condition = "con",
  consent = "cons",
  diagnosticreport = "diagrep",
  encounter = "enc",
  location = "loc",
  medication = "med",
  medicationadministration = "medadm",
  medicationrequest = "medreq",
  medicationstatement = "medstat",
  observation = "obs",
  patient = "pat",
  procedure = "proc",
  servicerequest = "servreq"
)

#' Get Abbreviation for Resource Name
#'
#' This function retrieves the abbreviation for a given resource name.
#'
#' @param resource_name A character string representing the resource name.
#'
#' @return A character string containing the abbreviation for the specified resource name.
#'
getResourceAbbreviation <- function(resource_name) {
  resource_name <- tolower(resource_name)
  column_prefixes[[resource_name]]
}

#' Get ID Column for Resource
#'
#' This function retrieves the name of the ID column for a given resource.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the ID column for the specified resource.
#'
getIDColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  id_column <- paste0(getResourceAbbreviation(resource_name), "_id")
  return(id_column)
}

#' Get Foreign ID Column for Resource
#'
#' This function retrieves the name of the foreign ID column for a given resource and a
#' specified foreign resource. If the resource and foreign resource are the same, it returns
#' the ID column for the resource itself.
#'
#' @param resource_name A character string representing the name of the primary resource.
#' @param foreign_resource_name A character string representing the name of the foreign
#' resource for which the ID column should be retrieved.
#'
#' @return A character string containing the name of the foreign ID column for the
#' specified resource pair.
#'
getForeignIDColumn <- function(resource_name, foreign_resource_name) {
  resource_name <- tolower(resource_name)
  foreign_resource_name <- tolower(foreign_resource_name)
  # returns not a real foreign ID if the resource name and the foreign_resource_name are equals
  if (resource_name == foreign_resource_name) {
    getIDColumn(resource_name)
  }
  foreign_id_column <- paste0(foreign_resource_name, "_id")
  foreign_id_column <- paste0(getResourceAbbreviation(resource_name), "_", foreign_id_column)
  return(pid_column)
}

#' Get PID Column for Resource
#'
#' This function retrieves the name of the PID column for a given resource.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the PID column for the specified resource.
#'
getPIDColumn <- function(resource_name) {
  getForeignIDColumn(resource_name, "patient")
}

#' Get Encounter ID/Reference Column for Resource
#'
#' This function retrieves the name of the column with the reference to Encounters for a given
#' resource type.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the Encounter ID column for the specified resource.
#'
getEncIDColumn <- function(resource_name) {
  getForeignIDColumn(resource_name, "encounter")
}

#' Get Resources for Specific Patient ID
#'
#' This function filters rows from a resource table based on a specific patient ID.
#'
#' @param resource_name A character string specifying the name of the resource.
#' @param pid A character string representing the specific patient ID to filter for.
#'
#' @return A filtered data.table containing resource information for the specified patient ID.
#'
getResourcesByPID <- function(resource_name, pid) {
  # get PID Column name
  pid_column_name <- getPIDColumn(resource_name)
  # load resource table
  resource_table <- loadResourceTable(resource_name)
  # only for resource patient relevant, append string "Patient/"
  if (tolower(resource_name) == "patient" && startsWith(pid[1], "Patient/")) {
    resource_table[, pat_id := paste0("Patient/", pat_id)]
  }
  # extract rows from resource table with match patient id
  return(resource_table[get(pid_column_name) == pid])
}

#' Get Resources for Specific Resource IDs
#'
#' This function filters rows from a resource table based on resource IDs.
#'
#' @param resource_name A character string specifying the name of the resource.
#' @param ids A vector of character string representing the specific resource ID to filter for.
#'
#' @return A filtered data.table containing resource information for the resource IDs.
#'
getResourcesByIDs <- function(resource_name, ids) {
  id_column_name <- getIDColumn(resource_name)
  # load resource table
  resource_table <- loadResourceTable(resource_table_name)
  # We need a relative ID here without the resource name. If a resource name appears before the
  # actual ID, it is removed.
  ids <- etlutils::getAfterLastSlash(ids)
  # extract rows from resource table with match patient id
  return(resource_table[get(id_column_name) %in% ids])
}

#' Get Resources by ID or PID
#'
#' This function retrieves resource information based on either a resource ID or a patient ID.
#'
#' @param resource_name A character string specifying the name of the resource.
#' @param ids_or_pid A character string representing either a resource ID or a patient ID.
#'
#' @return A filtered data.table containing resource information based on the provided ID or PID.
#'
getResources <- function(resource_name, ids_or_pid) {
  if (startsWith(ids_or_pid[1], "Patient/")) {
    resources <- getResourcesByPID(resource_name, ids_or_pid)
  } else {
    resources <- getResourcesByIDs(resource_name, ids_or_pid)
  }
  etlutils::normalizeAllPOSIXctToUTC(resources)
  return(resources)
}

#' Retrieve the Last Processing Number from the Database
#'
#' This function connects to the database and retrieves the maximum `last_processing_nr`
#' from the `data_import_hist` table within the `db_log` schema. It specifically looks
#' for records where the `function_name` is `'copy_type_cds_in_to_db_log'` and the
#' `table_name` does not contain `'_raw'`.
#'
#' @return A data frame containing the maximum `last_processing_nr` from the specified
#'         records in the `db_log.data_import_hist` table.
#'
getLastProcessingNumber <- function() {
  db_connection_read <- getDatabaseReadConnection()
  statement <- "SELECT MAX(last_processing_nr)
                FROM db_log.data_import_hist
                WHERE function_name = 'copy_type_cds_in_to_db_log'
                  AND schema_name = 'db_log' AND table_name NOT LIKE '%_raw';"
  etlutils::dbGetQuery(db_connection_read, statement)
}

#' Load All Data with Last Timestamp from Database
#'
#' This function loads all data from a database table that has the most recent timestamp.
#' It constructs a SQL query to fetch records where the timestamp is the latest in the table.
#'
#' @param table_name the table name
#' @return A data frame containing the records with the most recent timestamp from the specified table.
#'
loadLastImportedDatasetsFromDB <- function(table_name) {
  db_connection_read <- getDatabaseReadConnection()
  last_processing_nr <- getLastProcessingNumber()
  # Create the SQL query to get the records with the maximum last_processing_nr
  statement <- paste0("SELECT * FROM ", table_name, "\n",
                      " WHERE last_processing_nr = ", last_processing_nr, ";")
  etlutils::dbGetQuery(db_connection_read, statement)
}

#' Get Current Datetime
#'
#' This function returns the current datetime. If the global variable `DEBUG_CURRENT_DATETIME` exists, it returns its value as a POSIXct object.
#' Otherwise, it returns the current system time.
#'
#' @return A POSIXct object representing the current datetime or the value of `DEBUG_CURRENT_DATETIME` if it exists.
#'
getCurrentDatetime <- function() {
  if (exists("DEBUG_CURRENT_DATETIME")) {
    return(as.POSIXct(DEBUG_CURRENT_DATETIME))
  }
  return(as.POSIXct(Sys.time()))
}

#' Get Query Datetime
#'
#' This function returns the current datetime formatted for SQL queries.
#' It retrieves the current datetime using the \code{getCurrentDatetime} function and formats it as a string in "YYYY-MM-DD HH:MM:SS" format.
#'
#' @return A character string representing the current datetime formatted for SQL queries.
#'
getQueryDatetime <- function() {
  format(getCurrentDatetime(), "%Y-%m-%d %H:%M:%S")
}

#' Extract IDs from References
#'
#' This function extracts IDs from a vector of references by getting the substring after the last slash in each reference.
#'
#' @param references A character vector of references from which to extract IDs.
#' @return A character vector containing the extracted IDs.
#'
extractIDsFromReferences <- function(references) {
  etlutils::getAfterLastSlash(references)
}

#' Get Query List
#'
#' This function takes a collection and optionally removes reference types
#' to create a query list. It concatenates the elements of the collection
#' into a single string, each enclosed in single quotes and separated by commas.
#'
#' @param collection The collection from which to create the query list.
#' @param remove_ref_type Logical indicating whether to remove reference types.
#' Default is \code{FALSE}.
#'
getQueryList <- function(collection, remove_ref_type = FALSE) {
  if (remove_ref_type) {
    collection <- extractIDsFromReferences(collection)
  }
  paste0("'", collection, "'", collapse = ", ")
}

#' Parse Query List
#'
#' This function takes a query list string and splits it based on a specified delimiter
#' to create a vector of elements. It utilizes the \code{getQueryList} function to
#' create the vector.
#'
#' @param list_string The query list string to parse.
#' @param split The delimiter used to split the query list string. Default is a space.
#'
#' @return A vector containing the parsed elements from the query list string.
#'
parseQueryList <- function(list_string, split = " ") {
  splitted <- unlist(strsplit(list_string, split))
  getQueryList(splitted)
}

####################################################
# Load Resources by ID (= own ID or PID or Enc ID) #
####################################################

#' Get Full Table Name for Resource
#'
#' This function constructs the full table name for a given resource by converting the
#' resource name to lowercase and appending it to a prefix and suffix.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the full table name for the specified resource.
#'
getFullTableName <- function(resource_name) paste0("v_", tolower(resource_name), "_all")


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
  db_connection_read <- getDatabaseReadConnection()
  last_processing_nr <- getLastProcessingNumber()
  # this should be view tables named in a style like 'v_patient_all' for resource_name Patient
  table_name <- getFullTableName(resource_name)
  id_column <- getIDColumn(resource_name)
  statement <-paste0(
    "SELECT * FROM ", table_name, " a\n",
    " WHERE last_processing_nr = ", last_processing_nr,
    if (nchar(filter)) paste0("\n", filter) else "",
    ";\n"
  )
  return(statement)
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
getStatementFilter <- function(resource_name, filter_column, filter_column_values) {
  resource_id_column <- getIDColumn(resource_name)
  if (filter_column == resource_id_column) {
    # remove resource name and the slash if the IDs are references and not pure IDs
    filter_column_values <- gsub(paste0("^", resource_name, "/"), "", filter_column_values)
  }
  # quote every pid and collapse the vector comma separated
  filter_column_values <- paste0("'", filter_column_values, "'", collapse = ",")
  filter_line <- paste0("AND a.", filter_column, " IN (", filter_column_values, ")\n")
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
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#' @return A data frame containing the results of the SQL query.
#'
runQuery <- function(resource_name, filter_column, ids, log = TRUE) {
  filter <- getStatementFilter(resource_name, filter_column, ids)
  statement <- getQueryToLoadResourcesLastStatusFromDB(resource_name, filter)
  db_connection_read <- getDatabaseReadConnection()
  etlutils::dbGetQuery(db_connection_read, statement, log)
}

#' Retrieve the last status of load resources from the database.
#'
#' This function executes a SQL query to retrieve the last status of load resources
#' from the database, based on the provided resource name. It utilizes a helper function
#' to construct the query statement.
#'
#' @param resource_name The name of the resource table.
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#'
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusFromDB <- function(resource_name, log = TRUE) {
  statement <- getQueryToLoadResourcesLastStatusFromDB(resource_name, filter = "")
  db_connection_read <- getDatabaseReadConnection()
  etlutils::dbGetQuery(db_connection_read, statement, log)
}

#' Retrieve the last status of load resources from the database by their own IDs.
#'
#' This function retrieves the last status of load resources from the database
#' based on their own IDs. It constructs and executes a SQL query using the provided
#' resource name and IDs, leveraging a helper function.
#'
#' @param resource_name The name of the resource table.
#' @param ids A vector of IDs to retrieve the last status for.
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#'
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByOwnIDFromDB <- function(resource_name, ids, log = TRUE) {
  id_column <- getIDColumn(resource_name)
  runQuery(resource_name, id_column, ids, log)
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
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByPIDFromDB <- function(resource_name, pids, log = TRUE) {
  if (tolower(resource_name) %in% "patient") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, pids, log))
  }
  pid_column <- getPIDColumn(resource_name)
  runQuery(resource_name, pid_column, pids, log)
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
#' @param log Logical indicating whether to log the query execution. Default is \code{TRUE}.
#' @return A data frame containing the last status of load resources.
#'
loadResourcesLastStatusByEncIDFromDB <- function(resource_name, enc_ids, log = TRUE) {
  if (tolower(resource_name) %in% "encounter") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, enc_ids, log))
  }
  enc_id_column <- getPIDColumn(resource_name)
  runQuery(resource_name, enc_id_column, enc_ids, log)
}
