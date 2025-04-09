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
fhirdbGetResourceAbbreviation <- function(resource_name) {
  resource_name <- tolower(resource_name)
  resource_to_abbreviation[[resource_name]]
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
fhirdbGetPIDColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  if (resource_name == "patient") {
    pid_column <- "id"
  } else {
    pid_column <- "patient_ref"
  }
  pid_column <- paste0(fhirdbGetResourceAbbreviation(resource_name), "_", pid_column)
  return(pid_column)
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
fhirdbGetIDColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  id_column <- paste0(fhirdbGetResourceAbbreviation(resource_name), "_id")
  return(id_column)
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
fhirdbGetEncIDColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  if (resource_name == "encounter") {
    enc_id_column <- "id"
  } else {
    enc_id_column <- "encounter_ref"
  }
  enc_id_column <- paste0(fhirdbGetResourceAbbreviation(resource_name), "_", enc_id_column)
  return(enc_id_column)
}

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
extractIDsFromReferences <- function(references, unique = TRUE) {
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
getFHIRReference <- function(reference_type, fhir_id_or_reference) {
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
getFHIRPatientReference <- function(patient_id_or_reference) {
  getFHIRReference("Patient", patient_id_or_reference)
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
getFHIREncounterReference <- function(encounter_id_or_reference) {
  getFHIRReference("Encounter", encounter_id_or_reference)
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
#' removeFHIRIndices(indexed_elements)
#'
#' @export
removeFHIRIndices <- function(indexed_elements, brackets = c("[", "]")) {
  brackets_pattern <- paste0(getEscaped(brackets[1]), "([0-9]+\\.*)*", getEscaped(brackets[2]))
  indexed_elements <- gsub(brackets_pattern, "", indexed_elements)
  return(indexed_elements)
}

