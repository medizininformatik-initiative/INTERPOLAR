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

#' Get a Column for Resource
#'
#' This function retrieves the full name of a column for a given resource.
#'
#' @param resource_name A character string representing the name of the resource.
#' @param column_names A vector of names of the columns without the prefix
#'
#' @return A vector character string containing the names of the columns for the specified resource.
#'
#' @export
fhirdbGetColumns <- function(resource_name, column_names) {
  resource_name <- tolower(resource_name)
  column_names <- paste0(fhirdbGetResourceAbbreviation(resource_name), column_names)
  return(column_names)
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
  return(fhirdbGetColumns(resource_name, "_id"))
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
  return(fhirdbGetColumns(resource_name, "_identifier_value"))
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

#' Get cases from interrupted toolchain runs
#'
#' Finds cases that occurred in a historical `pids_per_ward` import but have no
#' corresponding entry in `fall_fe`. The current database context must provide
#' the views `v_pids_per_ward`, `v_encounter_last_version`, and `v_fall_fe`.
#' At most one case per patient is returned so that processing can handle the
#' result. Further cases for the same patient can be recovered by a later run.
#'
#' @return A named list by ward. Each element is a data table with `patient_id`
#' and `encounter_id` columns. An empty list is returned if no cases are missing.
#'
#' @export
fhirdbGetIncompleteCasesPidsPerWard <- function() {
  on.exit(dbCloseAllConnections(), add = TRUE)

  # Find historical pids_per_ward entries whose main encounter has not reached
  # fall_fe yet. Return at most one missing encounter per patient so the next
  # full toolchain start can recover unfinished work without looping.
  query <- paste0(
    "WITH incomplete_candidates AS (\n",
    "  SELECT DISTINCT\n",
    "    ppw.ward_name,\n",
    "    ppw.patient_id,\n",
    "    ppw.encounter_id,\n",
    "    COALESCE(\n",
    "      NULLIF(regexp_replace(enc.enc_main_encounter_calculated_ref, '^.*/', ''), 'invalid'),\n",
    "      enc.enc_id\n",
    "    ) AS main_encounter_id,\n",
    "    enc.enc_period_start,\n",
    "    enc.enc_meta_lastupdated\n",
    "  FROM v_pids_per_ward ppw\n",
    "  INNER JOIN v_encounter_last_version enc\n",
    "    ON enc.enc_id = ppw.encounter_id\n",
    ")\n",
    "SELECT DISTINCT ON (candidate.patient_id)\n",
    "  candidate.ward_name,\n",
    "  candidate.patient_id,\n",
    "  candidate.encounter_id\n",
    "FROM incomplete_candidates candidate\n",
    "WHERE candidate.ward_name IS NOT NULL\n",
    "  AND candidate.patient_id IS NOT NULL\n",
    "  AND candidate.encounter_id IS NOT NULL\n",
    "  AND NOT EXISTS (\n",
    "    SELECT 1\n",
    "    FROM v_fall_fe fall\n",
    "    WHERE fall.fall_fhir_enc_id = candidate.main_encounter_id\n",
    "  )\n",
    "ORDER BY\n",
    "  candidate.patient_id,\n",
    "  candidate.enc_period_start DESC NULLS LAST,\n",
    "  candidate.enc_meta_lastupdated DESC NULLS LAST,\n",
    "  candidate.encounter_id;"
  )

  incomplete_cases <- dbGetReadOnlyQuery(
    query,
    lock_id = "fhirdbGetIncompleteCasesPidsPerWard()"
  )

  fhirdbSplitIncompleteCasesByWard(incomplete_cases)
}

fhirdbSplitIncompleteCasesByWard <- function(incomplete_cases) {
  incomplete_cases <- data.table::as.data.table(incomplete_cases)
  if (!nrow(incomplete_cases)) {
    return(list())
  }

  pids_splitted_by_ward <- split(
    incomplete_cases[, .(patient_id, encounter_id)],
    incomplete_cases$ward_name
  )
  lapply(pids_splitted_by_ward, unique)
}
