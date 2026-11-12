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

#' Retrieve medication analyses from a front-end relation
#'
#' Reads each analysis once, retaining record_id, fall_meda_id, meda_id, meda_dat,
#' medikationsanalyse_complete and meda_mrp_detekt. Technical version columns are
#' discarded before deduplication, except redcap_repeat_instance, which preserves
#' form creation order for tied clinical timestamps. No time filter is applied.
#' Use v_medikationsanalyse_fe_last_version when current form states are required;
#' this function does not select the latest version itself.
#'
#' @param lock_id Identifier for the shared read-only database access.
#' @param table_name Source table/view name.
#' @return A data.table sorted by record_id, fall_meda_id and meda_dat, with missing
#'   sort values last. An empty result emits a warning.
#' @export
getMedikationsanalyseFeData <- function(lock_id, table_name) {
  query <- paste0(
    "SELECT record_id, fall_meda_id, meda_id, meda_dat, ",
    "medikationsanalyse_complete, meda_mrp_detekt, last_processing_nr, redcap_repeat_instance FROM ",
    table_name, "\n"
  )
  result <- data.table::as.data.table(dbGetReadOnlyQuery(query, lock_id = lock_id))
  result[, last_processing_nr := NULL]
  result <- unique(result)
  data.table::setorderv(result, c("record_id", "fall_meda_id", "meda_dat"), na.last = TRUE)
  if (!nrow(result)) warning("The medikationsanalyse_fe table is empty. Please check the data.")
  result
}

#' Retrieve known INTERPOLAR station assignments
#'
#' Reads distinct station, patient and Encounter combinations in the database and
#' orders them by patient and Encounter ID. All station assignments for a contact
#' are retained. Their order within identical patient/Encounter keys is unspecified;
#' contact chronology must be determined from Encounter timestamps.
#'
#' @param lock_id A character string identifying the database read operation.
#' @param table_name Name of the database table or view containing the assignments.
#' @param column_names Columns to retrieve. Include input_datetime and
#'   pids_per_ward_id when original registration order is needed.
#'
#' @return A data.table with `ward_name`, `patient_id` and `encounter_id`.
#'   An empty result raises an error.
#'
#' @export
getPidsPerWardData <- function(lock_id, table_name,
                               column_names = c("ward_name", "patient_id", "encounter_id")) {
  if (
    !is.character(column_names) || !length(column_names) || anyNA(column_names) ||
    any(!grepl("^[a-z][a-z0-9_]*$", column_names))
  ) {
    stop("Invalid station assignment column selection.")
  }
  column_names <- unique(c("ward_name", "patient_id", "encounter_id", column_names))
  query <- paste0(
    "SELECT DISTINCT ", paste(column_names, collapse = ", "), " FROM ", table_name,
    " ORDER BY patient_id, encounter_id"
  )
  pids_per_ward_table <- dbGetReadOnlyQuery(query, lock_id = lock_id)
  if (nrow(pids_per_ward_table) == 0L) {
    stop("The pids_per_ward table is empty. Please check the data.")
  }
  return(pids_per_ward_table)
}

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

#' Split Incomplete Cases by Ward
#'
#' This function takes a data frame of incomplete cases and splits them into a
#' named list by ward. Each element of the list is a data table containing unique
#' patient_id and encounter_id pairs for that ward.
#'
#' @param incomplete_cases A data frame containing incomplete cases with columns:
#'   ward_name, patient_id, and encounter_id.
#'
fhirdbSplitIncompleteCasesByWard <- function(incomplete_cases) {
  incomplete_cases <- data.table::as.data.table(incomplete_cases)
  if (!nrow(incomplete_cases)) {
    return(list())
  }

  # Convert the query result into the named ward list expected by cds2db and
  # remove duplicate patient/encounter pairs within each ward.
  pids_splitted_by_ward <- split(
    incomplete_cases[, .(patient_id, encounter_id)],
    incomplete_cases$ward_name
  )
  lapply(pids_splitted_by_ward, unique)
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
