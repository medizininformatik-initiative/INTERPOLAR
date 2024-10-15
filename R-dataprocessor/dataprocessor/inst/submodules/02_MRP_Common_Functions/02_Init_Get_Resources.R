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
