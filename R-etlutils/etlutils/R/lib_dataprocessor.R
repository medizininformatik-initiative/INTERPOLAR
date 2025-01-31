#' Validate ATC7 Codes in Multiple Columns
#'
#' This function checks whether the values in specified columns of a data table
#' are valid ATC7 codes and issues warnings for any invalid values.
#'
#' @param data A data table containing the columns to validate.
#' @param columns A character vector specifying the column names to check for ATC7 validity.
#'
#' @details The function filters out \code{NA} values and validates each value in the specified
#' columns using \code{etlutils::isATC7}. If invalid ATC7 codes are found, a warning is issued
#' for each column.
#'
#' @return This function does not return any value. It issues warnings for invalid codes.
#'
#' @examples
#' library(data.table)
#' drug_disease_mrp_definition <- data.table(
#'   ATC = c("A01AB07", "INVALID", NA),
#'   ATC_PROXY = c(NA, "WRONG", "B03AA02")
#' )
#' validateATC7Codes(drug_disease_mrp_definition, c("ATC", "ATC_PROXY"))
#'
#' @export
validateATC7Codes <- function(data, columns) {
  for (column in columns) {
    # Filter out NA values and check for invalid ATC7 codes
    invalid_codes <- data[[column]][!etlutils::isATC7(data[[column]]) & !is.na(data[[column]])]
    # Issue a warning if there are invalid codes
    if (length(invalid_codes) > 0) {
      warning(sprintf(
        "The following codes are not valid in column '%s', please check:\n%s",
        column,
        paste(invalid_codes, collapse = ", \n")
      ))
    }
  }
}

#' Validate LOINC Codes in a Column
#'
#' This function validates whether all non-NA values in a specified column of a data table
#' conform to the standard LOINC format.
#'
#' @param data A data.table containing the column to validate.
#' @param column_name The name of the column to check for valid LOINC codes.
#'
#' @details A valid LOINC code matches the pattern `^\d{1,5}-\d$`:
#' - 1 to 5 digits
#' - Followed by a hyphen (`-`)
#' - Ending with exactly 1 digit.
#'
#' If invalid codes are found, the function will issue a warning with the invalid codes.
#'
#' @return The function does not return any value but will issue a warning
#' if invalid LOINC codes are found in the column.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(
#'   LOINC = c("12345-6", "67890-1", "INVALID", NA, "12321", "21312123-1")
#' )
#' validateLOINCCodes(dt, "LOINC")
#' # Warning: The following codes in column 'LOINC' are not valid LOINC codes: INVALID
#'
#' @export
validateLOINCCodes <- function(data, column_name) {
  # Extract the column values
  column_values <- data[[column_name]]
  # Identify invalid codes (ignore NA values)
  invalid_codes <- column_values[!isLOINC(column_values) & !is.na(column_values)]
  # If there are invalid codes, issue a warning
  if (length(invalid_codes) > 0) {
    warning(sprintf(
      "The following codes in column '%s' are not valid LOINC codes:\n%s",
      column_name,
      paste(invalid_codes, collapse = ", \n")
    ))
  }
}

# List with resource abbreviations
resource_to_abbreviation <- list(
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
#' @export
getResourceAbbreviation <- function(resource_name) {
  resource_name <- tolower(resource_name)
  resource_to_abbreviation[[resource_name]]
}

#' Get ID Column for Resource
#'
#' This function retrieves the name of the ID column for a given resource.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the ID column for the specified resource.
#'
#' @export
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
  foreign_id_column <- paste0(foreign_resource_name, "_ref")
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
#' @export
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
#' @export
getEncIDColumn <- function(resource_name) {
  getForeignIDColumn(resource_name, "encounter")
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
#' @export
getLastProcessingNumber <- function() {
  query <- "SELECT db.get_last_processing_nr_typed();"
  etlutils::dbGetReadOnlyQuery(query, lock_id = "getLastProcessingNumber()")
}

#' Load All Data with Last Timestamp from Database
#'
#' This function loads all data from a database table that has the most recent timestamp.
#' It constructs a SQL query to fetch records where the timestamp is the latest in the table.
#'
#' @param table_name The table name.
#' @return A data frame containing the records with the most recent timestamp from the specified table.
#'
#' @export
loadLastImportedDatasetsFromDB <- function(table_name) {
  last_processing_nr <- getLastProcessingNumber()
  # Create the SQL query to get the records with the maximum last_processing_nr
  query <- paste0("SELECT * FROM ", table_name, "\n",
                  " WHERE last_processing_nr = ", last_processing_nr, ";")
  # This only occurs if the database has been reset and the dataprocessor was executed too quickly
  if (is.na(last_processing_nr)) {
    stop(paste0("In table ", table_name, " the content of column last_processing_nr in the ",
                "database is NA, so the following SQL query will return an error:\n", statement,
                "\nThis should never happen..."))
  }
  etlutils::dbGetReadOnlyQuery(query, lock_id = "loadLastImportedDatasetsFromDB()")
}

#' Get Current Datetime
#'
#' This function returns the current datetime. If the global variable `DEBUG_ENCOUNTER_DATETIME` exists, it returns its value as a POSIXct object.
#' Otherwise, it returns the current system time.
#'
#' @return A POSIXct object representing the current datetime or the value of `DEBUG_ENCOUNTER_DATETIME` if it exists.
#'
#' @export
getCurrentDatetime <- function() {
  if (exists("DEBUG_ENCOUNTER_DATETIME")) {
    return(as.POSIXct(DEBUG_ENCOUNTER_DATETIME))
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
#' @export
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
#' @export
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
#' @export
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
#' @export
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
#' @export
getViewTableName <- function(resource_name) paste0("v_", tolower(resource_name))

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
#' @export
getQueryToLoadResourcesLastStatusFromDB <- function(resource_name, filter = "") {
  last_processing_nr <- getLastProcessingNumber()
  # this should be view tables named in a style like 'v_patient' for resource_name Patient
  table_name <- getViewTableName(resource_name)
  id_column <- getIDColumn(resource_name)
  query <-paste0(
    "SELECT * FROM ", table_name, " a\n",
    " WHERE last_processing_nr = ", last_processing_nr,
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
#' @export
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
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#' @return A data frame containing the results of the SQL query.
#'
#' @export
loadResourcesFromDB <- function(resource_name, filter_column, ids, lock_id) {
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
#' @export
loadResourcesLastStatusFromDB <- function(resource_name) {
  query <- getQueryToLoadResourcesLastStatusFromDB(resource_name, filter = "")
  etlutils::dbGetReadOnlyQuery(query, lock_id = "loadResourcesLastStatusFromDB()")
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
#' @export
loadResourcesLastStatusByOwnIDFromDB <- function(resource_name, ids) {
  id_column <- getIDColumn(resource_name)
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
#' @export
loadResourcesLastStatusByPIDFromDB <- function(resource_name, pids) {
  if (tolower(resource_name) %in% "patient") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, pids))
  }
  pid_column <- getPIDColumn(resource_name)
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
#' @export
loadResourcesLastStatusByEncIDFromDB <- function(resource_name, enc_ids) {
  if (tolower(resource_name) %in% "encounter") {
    return(loadResourcesLastStatusByOwnIDFromDB(resource_name, enc_ids))
  }
  enc_id_column <- getPIDColumn(resource_name)
  loadResourcesFromDB(
    resource_name = resource_name,
    filter_column = enc_id_column,
    ids = enc_ids,
    lock_id = paste0("loadResourcesLastStatusByEncIDFromDB(",resource_name,")"))
}

#' Checks whether strings in a vector of ICD codes match specified patterns.
#'
#' This function takes a vector of ICD (International Classification of Diseases)
#' codes and checks whether the strings in this vector match predefined patterns.
#' The patterns are retrieved from an external data frame named SIMPLE_ICD_PATTERN.
#'
#' @param codes A vector of strings containing the ICD codes to be checked.
#' @return A logical vector that returns TRUE for strings that match the patterns
#' and FALSE for strings that do not match the patterns.
#' @seealso SIMPLE_ICD_PATTERN This data frame contains the predefined patterns
#' for ICD codes.
#'
#' @examples
#' codes <- c('H77+M55.2', 'H77', 'XXX', 'X+X', 'X+XXXXX')
#' isICDCode(codes)
#'
#' @export
isICDCode <- function(codes) {
  icd_pattern <- paste(paste0('(', SIMPLE_ICD_PATTERN$ICD1, ')'), paste0('(', SIMPLE_ICD_PATTERN$ICD2_3, ')'), paste0('(', SIMPLE_ICD_PATTERN$ICD4_6, ')'), sep = '|')
  full_icd_pattern <- paste0('(','^','(', icd_pattern,')', '$', ')', '|', '(', '^', '(', icd_pattern,')', '\\+{1}', '(', icd_pattern, '){1}', '$', ')')
  grepl(full_icd_pattern, codes, perl = TRUE)
}

#' Clean and Validate ICD Code
#'
#' This function cleans and validates an ICD code by converting it to uppercase,
#' removing trailing non-alphanumeric characters, and checking if the resulting
#' code is a valid ICD code.
#'
#' @param icd A character vector representing the ICD code.
#'
#' @return A character vector containing the cleaned and validated ICD code,
#'         or NULL if the input is not a valid ICD code.
#' @examples
#' cleanICD("A11")
#' cleanICD(" B1.2 ")
#' cleanICD("C23-") # This will return NULL as it's not a valid ICD code.
#'
#' @export
cleanICD <- function(icd) {
  icd <- toupper(etlutils::removeLastCharsIfNotAlphanumeric(trimws(icd)))
  icd[isICDCode(icd)]
}

#' Reads the file path of an Excel file
#'
#' This function constructs the file path for an Excel file with the given file name.
#'
#' @param simpleExcelFileName The name of the Excel file without file extension.
#'
#' @return The full file path of the Excel file.
#'
#' @export
readExcelFilePath <- function(simpleExcelFileName) {
  paste0("./R-dataprocessor/dataprocessor/inst/extdata/", simpleExcelFileName, ".xlsx")
}

#' Read an Excel file and import each sheet as a separate data.table.
#'
#' This function reads an Excel file specified by the 'simpleExcelFileName' parameter
#' from internal directory './inst/extdata/' and imports each sheet as a separate
#' data.table. It returns a list of imported sheets.
#'
#' @param simpleExcelFileName The file name of the Excel file without extension.
#'
#' @return A list of imported sheets as data.tables.
#'
#' @export
readExcelFileAsTableListFromExtData <- function(simpleExcelFileName) {
  etlutils::readExcelFileAsTableList(readExcelFilePath(simpleExcelFileName))
}

#' Calculate Maximum Future Time to Check for MRPs
#'
#' This function calculates the maximum future time to check for Medication-Related Problems (MRPs)
#' based on the current time and a defined number of days into the future. The number of days to look ahead
#' is specified in the configuration file (`dataprocessor_config.toml`). This configuration sets
#' the interval end as a certain number of days from the current time, converted to seconds.
#'
#' @param current_time The current time as a POSIXct object, representing the starting point
#'   for the calculation.
#'
#' @return Returns a POSIXct object representing the maximum future time up to which MRPs should
#'   be checked, based on the current time and the configuration.
#'
#' @examples
#' MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE <- 30
#' current_time <- Sys.time()
#' future_time <- getMaxTimeInFutureToCheckForMRPs(current_time)
#' print(paste(current_time, " -> ", future_time))
#'
#' @export
getMaxTimeInFutureToCheckForMRPs <- function(current_time) {
  # MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE is defined in the dataprocessor_config.toml file
  max_seconds_checked_for_mrps_in_future <- MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE * 3600 * 24
  # every interval will end MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE days in the from current_time
  general_max_time <- current_time + max_seconds_checked_for_mrps_in_future
  return(general_max_time)
}
