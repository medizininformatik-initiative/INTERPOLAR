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
#' \dontrun{
#'   library(data.table)
#'   # Example: A list of patient IDs per ward
#'   patientIDsPerWard <- list(
#'     Ward_A = c("PID_A001", "PID_A002", "PID_A003"),
#'     Ward_B = c("PID_B001", "PID_B002"),
#'     Ward_C = c("PID_C001", "PID_C002", "PID_C003", "PID_C004")
#'   )
#'
#'   # Applying the function
#'   result_table <- createWardPatientIDPerDateTable(patientIDsPerWard)
#'
#'   # Displaying the result
#'   print(result_table)
#' }
#'
createWardPatientIDPerDateTable <- function(patientIDsPerWard) {
  ward_names <- names(patientIDsPerWard)
  patient_ids <- unlist(patientIDsPerWard)
  wardPatientIDPerDate <- data.table::data.table(
    ward_name = rep(ward_names, lengths(patientIDsPerWard)),
    patient_id = patient_ids
  )
  return(wardPatientIDPerDate)
}

#' Load FHIR resources for a given set of patient IDs and create a table of ward-patient ID per date.
#'
#' This function takes a list of patient IDs per ward, extracts unique patient IDs,
#' loads FHIR resources for those patient IDs from the FHIR server using the provided
#' `TABLE_DESCRIPTION`, and creates an additional table of ward-patient ID per date. The
#' result is a list of data.tables, where each element contains FHIR resources for a specific
#' patient, and the last element is a table representing the ward and patient ID per date.
#'
#' @param patient_IDs_per_ward A list of patient IDs, where each element corresponds to a ward.
#' @param table_descriptions the fhircrackr table descriptions of the result tables
#' @return A list of data.tables, each containing FHIR resources for a specific patient,
#'   and the last element is a table representing the ward and patient ID per date.
#'
loadResourcesByPatientIDFromFHIRServer <- function(patient_IDs_per_ward, table_descriptions) {
  patientIDs <- unique(unlist(patient_IDs_per_ward))

  # # Find the names of the elements that start with a lowercase letter (pids_per_ward are no resources to download)
  # # All names of real resources start with a capital letter
  # resource_table_descriptions <- table_descriptions[-grep("^[a-z]", names(table_descriptions))]
  #
  # resource_tables <- etlutils::loadResourcesByPID(patientIDs, resource_table_descriptions)
  resource_tables <- etlutils::loadMultipleFHIRResourcesByPID(patientIDs, table_descriptions)

  #########################
  # START: FOR DEBUG ONLY #
  #########################
  # NOTE: only works correctly with very specific test data
  if (etlutils::isDefinedAndTrue("DEBUG_ADD_PATIENT_IDENTIFIER")) {
    # adds a second patient identifier
    debugAddPatientIdentifier(resource_tables)
    # adds a new Patient
    result <- debugAddPatient(resource_tables$Patient, patient_IDs_per_ward)
    resource_tables$Patient <- result$Patient
    patient_IDs_per_ward <- result$patient_IDs_per_ward
    rm(result)
  }
  #######################
  # END: FOR DEBUG ONLY #
  #######################


  # Add additional table of ward-patient ID per date
  resource_tables[['pids_per_ward']] <- createWardPatientIDPerDateTable(patient_IDs_per_ward)

  return(resource_tables)
}

#' Load Referenced Resources by Own ID from FHIR Server
#'
#' This function loads FHIR resources referenced by other resources from a FHIR server. It takes
#' a set of table descriptions and a list of resource tables, identifies all unique resource names
#' in the `reference_types` column of the table descriptions, and loads the referenced resources
#' for each unique resource name. The result is an updated list of resource tables including the
#' newly loaded referenced resources.
#'
#' @param table_descriptions A list containing the fhircrackr table descriptions for the result
#'   tables, including `reference_types` which lists all resources that reference other resources.
#' @param resource_tables A list of data.tables, each containing FHIR resources for specific
#'   patients. This list is updated with the referenced resources.
#'
#' @return An updated list of data.tables including the referenced resources.
#'
loadReferencedResourcesByOwnIDFromFHIRServer <- function(table_descriptions, resource_tables) {
  # table_descriptions$reference_types can be a comma or whitespace separated list like
  # "MedicationStatement, MedicationAdministration". We need the all unique diffrerent
  # resource names in this column
  reference_types <- unique(etlutils::extractWords(table_descriptions$reference_types$reference_types))
  for (reference_type in reference_types) {
    referenced_table_description <- table_descriptions$pid_independant[[reference_type]]
    if (!is.null(referenced_table_description)) {
      # now extract all rows where the single reference_type is in the reference_types column as whole word
      whole_word_pattern <- paste0("\\b", reference_type, "\\b")
      sub_reference_type <- table_descriptions$reference_types[grepl(whole_word_pattern, reference_types)]

      referenced_ids <- c()
      for (i in seq_len(nrow(sub_reference_type))) {
        resource_name <- sub_reference_type[i]$resource
        column_name <- sub_reference_type[i]$column_name
        new_referenced_ids <- resource_tables[[resource_name]][[column_name]]
        new_referenced_ids <- unique(na.omit(new_referenced_ids))
        referenced_ids <- c(referenced_ids, new_referenced_ids)
      }
      referenced_ids <- unique(referenced_ids)

      resource_tables[[reference_type]] <- etlutils::loadFHIRResourcesByOwnID(referenced_ids, referenced_table_description)
    }
  }
  return(resource_tables)
}

#' Load Resources and Referenced Resources from FHIR Server
#'
#' This function loads resources for a given set of patient IDs per ward from a FHIR server and
#' then loads any additional referenced resources. It uses two steps: first, loading resources
#' directly associated with patient IDs using `loadResourcesByPatientIDFromFHIRServer`, and second,
#' loading resources referenced by the initially loaded resources using
#' `loadReferencedResourcesByOwnIDFromFHIRServer`. The results are then saved as RData files, with
#' filenames derived from the resource names.
#'
#' @param patient_IDs_per_ward A list of patient IDs, where each element corresponds to a ward and
#'   contains patient IDs associated with that ward.
#' @param table_descriptions A list containing two elements: `pid_dependant` and
#'   `pid_independant`, each of which describes table structures for resources that are dependent
#'   and independent of patient IDs, respectively.
#'
#' @details The function iterates through all resources loaded in both steps and saves them as
#'   RData files using `writeRData`. The filenames are derived by converting the names of the
#'   resources in the `resource_tables` list to lowercase.
#'
loadResourcesFromFHIRServer <- function(patient_IDs_per_ward, table_descriptions) {
  resource_tables <- loadResourcesByPatientIDFromFHIRServer(patient_IDs_per_ward, table_descriptions$pid_dependant)
  resource_tables <- loadReferencedResourcesByOwnIDFromFHIRServer(table_descriptions, resource_tables)
  for (i in seq_along(resource_tables)) {
    writeRData(resource_tables[[i]], tolower(paste0(names(resource_tables)[i], "_raw")))
  }
  return(resource_tables)
}
