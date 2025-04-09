#' Extract IDs from References
#'
#' This function extracts IDs from a vector of references by getting the
#' substring after the last slash in each reference.Optionally, duplicate IDs
#' can be removed.
#'
#' @param references A character vector of references from which to extract IDs.
#' @param unique A logical value indicating whether to return only unique IDs.
#' Default is TRUE.
#' @return A character vector containing the extracted IDs, optionally unique.
#'
#' @export
fhirdataExtractIDs <- function(references, unique = TRUE) {
  ids <- etlutils::getAfterLastSlash(na.omit(references))
  if (unique) {
    ids <- unique(ids)
  }
  return(ids)
}

#' Generate FHIR resource references
#'
#' This function generates a valid FHIR resource reference by combining a given `reference_type`
#' (e.g., `"Patient"`, `"Encounter"`) with a cleaned FHIR ID. The ID is extracted using
#' `getAfterLastSlash()`, ensuring that any existing reference structure is properly handled.
#'
#' @param reference_type A character string specifying the type of FHIR resource
#'                       (e.g., `"Patient"`, `"Encounter"`).
#' @param fhir_id_or_reference A character string containing either a full FHIR reference
#'                              or just an ID. If a full reference is provided, only the
#'                              ID after the last slash is used.
#'
#' @return A character string representing the correctly formatted FHIR reference
#'         in the form `"<reference_type>/<fhir_id>"`.
#'
#' @export
fhirdataGetReference <- function(reference_type, fhir_id_or_reference) {
  fhir_id <- getAfterLastSlash(fhir_id_or_reference)
  return(paste0(reference_type, "/", fhir_id))
}

#' Generate a FHIR Patient reference
#'
#' This function generates a valid FHIR Patient reference by extracting the patient ID
#' from a given input and appending it to `"Patient/"`.
#'
#' @param patient_id_or_reference A character string containing a full FHIR reference
#'                                 or just a patient ID.
#'
#' @return A character string representing the correctly formatted FHIR Patient reference.
#'
#' @export
fhirdataGetPatientReference <- function(patient_id_or_reference) {
  fhirdataGetReference("Patient", patient_id_or_reference)
}

#' Generate a FHIR Encounter reference
#'
#' This function generates a valid FHIR Encounter reference by extracting the encounter ID
#' from a given input and appending it to `"Encounter/"`.
#'
#' @param encounter_id_or_reference A character string containing a full FHIR reference
#'                                   or just an encounter ID.
#'
#' @return A character string representing the correctly formatted FHIR Encounter reference.
#'
#' @export
fhirdataGetEncounterReference <- function(encounter_id_or_reference) {
  fhirdataGetReference("Encounter", encounter_id_or_reference)
}

#' Remove FHIR-style indices from element names
#'
#' This function removes numerical indices enclosed in brackets (e.g., "\\[0\\]", "\\[1.2\\]")
#' from a given vector of indexed element names.
#'
#' @param indexed_elements A character vector containing FHIR-style indexed element names.
#' @param brackets A character vector of length 2 specifying the opening and closing brackets.
#'        Default is c("\\[", "\\]").
#'
#' @return A character vector with FHIR-style indices removed.
#'
#' @examples
#' indexed_elements <- c("[0]Patient.name", "[1.2]Observation.value", "Condition.category")
#' fhirdataRemoveIndices(indexed_elements)
#'
#' @export
fhirdataRemoveIndices <- function(indexed_elements, brackets = c("[", "]")) {
  brackets_pattern <- paste0(getEscaped(brackets[1]), "([0-9]+\\.*)*", getEscaped(brackets[2]))
  indexed_elements <- gsub(brackets_pattern, "", indexed_elements)
  return(indexed_elements)
}

#' Create or Store a Resource Table
#'
#' This function initializes an empty `data.table` based on a given table description.
#' It can either return the table directly or store it in a specified collection under a given key.
#'
#' @param table_description A description object containing table column names.
#'                          Expected to have a `@cols@names` attribute with column names.
#' @param resource_key (Optional) A character string specifying the key under which the table should
#'                     be stored in the `resource_collection`.
#' @param resource_collection (Optional) A named list to store the table. If provided with
#'                             `resource_key`, the table will be added to this collection.
#'
#' @return If both `resource_key` and `resource_collection` are provided, returns the updated
#'         `resource_collection`. Otherwise, returns the initialized `data.table`.
#'
#' @export
fhirdataCreateResourceTable <- function(
    table_description,
    resource_key = NULL,
    resource_collection = NULL
) {
  # Extract column names from the table description object
  column_names <- table_description@cols@names
  # Create an empty data.table with the appropriate number of columns
  resource_table <- data.table::data.table(matrix(ncol = length(column_names), nrow = 0))
  # Set the column names for the table
  data.table::setnames(resource_table, column_names)
  # Convert all columns to character type
  resource_table[, (column_names) := lapply(.SD, as.character), .SDcols = column_names]
  # If a resource_key and resource_collection are provided, store the table in the collection
  if (!is.null(resource_key) && !is.null(resource_collection)) {
    resource_collection[[resource_key]] <- resource_table
    return(resource_collection)
  }
  # Otherwise, return the resource_table directly
  return(resource_table)
}
