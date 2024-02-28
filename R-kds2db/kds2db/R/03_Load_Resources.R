#' Create a data.table with ward and patient ID per date.
#'
#' This function takes a list of patient IDs per ward and constructs a data.table
#' with columns for date_time, ward, and pid. Each row represents a unique combination
#' of date, ward, and patient ID extracted from the provided list.
#'
#' @param patientIDsPerWard A list of patient IDs, where each element corresponds to a ward.
#'
#' @return A data.table with columns date_time, ward, and pid, representing the date, ward,
#'   and patient ID for each combination extracted from the provided list.
#'
#' @examples
#' library(data.table)
#' # Example: A list of patient IDs per ward
#' patientIDsPerWard <- list(
#'   Ward_A = c("PID_A001", "PID_A002", "PID_A003"),
#'   Ward_B = c("PID_B001", "PID_B002"),
#'   Ward_C = c("PID_C001", "PID_C002", "PID_C003", "PID_C004")
#' )
#'
#' # Applying the function
#' result_table <- createWardPatitentIDPerDateTable(patientIDsPerWard)
#'
#' # Displaying the result
#' print(result_table)
#'
#' @export
createWardPatitentIDPerDateTable <- function(patientIDsPerWard) {
  date_time <- Sys.time()
  ward_names <- names(patientIDsPerWard)
  patient_ids <- unlist(patientIDsPerWard)
  wardPatitentIDPerDate <- data.table::data.table(
    date_time = rep(date_time, length(patient_ids)),
    ward = rep(ward_names, lengths(patientIDsPerWard)),
    pid = patient_ids
  )
  return(wardPatitentIDPerDate)
}

#' Load FHIR resources for a given set of patient IDs and create a table of ward-patient ID per date.
#'
#' This function takes a list of patient IDs per ward, extracts unique patient IDs,
#' loads FHIR resources for those patient IDs from the FHIR server using the provided
#' `TABLE_DESCRIPTION`, and creates an additional table of ward-patient ID per date. The
#' result is a list of data.tables, where each element contains FHIR resources for a specific
#' patient, and the last element is a table representing the ward and patient ID per date.
#'
#' @param patientIDsPerWard A list of patient IDs, where each element corresponds to a ward.
#' @param table_descriptions the fhircrackr table descriptions of the result tables
#' @return A list of data.tables, each containing FHIR resources for a specific patient,
#'   and the last element is a table representing the ward and patient ID per date.
#'
#' @export
loadResourcesByPatientIDFromFHIRServer <- function(patientIDsPerWard, table_descriptions) {
  patientIDs <- unique(unlist(patientIDsPerWard))

  # Find the names of the elements that start with a lowercase letter (pids_per_ward are no resources to download)
  # All names of real resources start with a capital letter
  resource_table_descriptions <- table_descriptions[-grep("^[a-z]", names(table_descriptions))]

  resource_tables <- etlutils::loadResourcesByPID(patientIDs, resource_table_descriptions)

  # Add additional table of ward-patient ID per date
  resource_tables[['pids_per_ward']] <- createWardPatitentIDPerDateTable(patientIDsPerWard)

  for (i in seq_along(resource_tables)) {
    polar_write_rdata(resource_tables[[i]], tolower(names(resource_tables)[i]))
  }

  return(resource_tables)
}
