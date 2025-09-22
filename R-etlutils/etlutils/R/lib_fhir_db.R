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

#' Get Identifier Column for Resource
#'
#' This function retrieves the name of the ID column for a given resource.
#'
#' @param resource_name A character string representing the name of the resource.
#'
#' @return A character string containing the name of the ID column for the specified resource.
#'
#' @export
fhirdbGetIdentifierColumn <- function(resource_name) {
  resource_name <- tolower(resource_name)
  id_column <- paste0(fhirdbGetResourceAbbreviation(resource_name), "_identifier_value")
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

#' Get Query List
#'
#' This function takes a collection and optionally removes reference types
#' to create a query list. It concatenates the elements of the collection
#' into a single string, each enclosed in single quotes and separated by commas.
#'
#' @param collection The collection from which to create the query list.
#' @param remove_ref_type Logical indicating whether to remove reference types.
#' Default is \code{FALSE}.
#' @param return_NA_if_empty Logical indicating whether to return \code{NA} if
#' the collection is empty.
#'
#' @export
fhirdbGetQueryList <- function(collection, remove_ref_type = FALSE, return_NA_if_empty = FALSE) {
  collection <- unique(na.omit(collection))
  if (!length(collection)) {
    return(ifelse(return_NA_if_empty, NA, "('')"))
  }
  if (remove_ref_type) {
    collection <- etlutils::fhirdataExtractIDs(collection)
  }
  paste0("(", paste0("'", collection, "'", collapse = ", "), ")")
}
