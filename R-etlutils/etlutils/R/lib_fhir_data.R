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
  ids <- getAfterLastSlash(na.omit(references))
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

#' Retrieve All Related FHIR Encounter Records
#'
#' Collects a comprehensive set of FHIR Encounter records that are part of the same medical case.
#' This includes the originally specified encounters, those sharing the same identifier, and those
#' related through FHIR partOf references, either as parent or child encounters. The function
#' ensures uniqueness of the returned encounters.
#'
#' @param encounter_ids A character vector of FHIR Encounter resource IDs.
#' @param common_encounter_fhir_identifier_system A character string representing the common FHIR
#' identifier system for a group of encounters which should be interpreted as the same medical case.
#' @param lock_id_extension A character string used to extend the lock ID for database queries.
#'
#' @return A `data.table` containing all relevant and deduplicated encounter records.
#'
#' @export
fhirdataGetAllEncounters <- function(encounter_ids, common_encounter_fhir_identifier_system = NULL, lock_id_extension) {

  getEncounters <- function(encounter_ids, sub_lock_id_extension) {
    if (length(encounter_ids)) {
      query_ids <- fhirdbGetQueryList(encounter_ids)
      query <- paste0( "SELECT * FROM v_encounter_last_version\n",
                       "WHERE enc_id IN (", query_ids, ")\n")
      encounters <- dbGetReadOnlyQuery(query, lock_id = paste0("getAllEncounters()[", lock_id_extension, sub_lock_id_extension, "]"))
      return(encounters)
    }
    return(NA)
  }

  joinEncounters <- function(encounters_1, encounters_2) {
    encounters <- rbind(encounters_1, encounters_2)
    encounters <- unique(encounters)
    return(encounters)
  }

  appendEncounters <- function(encounters, encounter_ids, sub_lock_id_extension) {
    encounters_2 <- getEncounters(encounter_ids, sub_lock_id_extension)
    encounters <- joinEncounters(encounters, encounters_2)
    return(encounters)
  }

  getParentEncounters <- function(encounters, sub_lock_id_extension) {
    if (nrow(encounters)) {
      encounter_refs <- na.omit(encounters$enc_partof_ref)
      if (length(encounter_refs)) {
        query_ids <- fhirdataExtractIDs(encounter_refs)
        parent_encounters <- getEncounters(query_ids, sub_lock_id_extension)
        # are there any new encounters?
        parent_encounters <- data.table::fsetdiff(parent_encounters, encounters)
        return(parent_encounters)
      }
    }
    return(data.table::data.table())
  }

  getPartEncounters <- function(encounters, sub_lock_id_extension) {
    if (nrow(encounters)) {
      query_ids <- fhirdbGetQueryList(fhirdataGetReference("Encounter", encounters$enc_id))
      query <- paste0( "SELECT * FROM v_encounter_last_version\n",
                       "WHERE enc_partof_ref IN (", query_ids, ")\n")
      part_encounters <- dbGetReadOnlyQuery(query, lock_id = paste0("getAllEncounters()[", lock_id_extension, sub_lock_id_extension, "]"))
      # are there any new encounters?
      part_encounters <- data.table::fsetdiff(part_encounters, encounters)
      return(part_encounters)
    }
    return(data.table::data.table())
  }

  encounters <- getEncounters(encounter_ids, 1)

  # Assumption 1: All Encounters of the same medical case have the same enc_identifier_value for
  # the common_encounter_fhir_identifier_system
  if (isSimpleNotEmptyString(common_encounter_fhir_identifier_system)) {
    query_ids <- fhirdbGetQueryList(encounters$enc_identifier_value)
    query <- paste0( "SELECT * FROM v_encounter_last_version\n",
                     "WHERE enc_identifier_system = '", common_encounter_fhir_identifier_system, "'\n",
                     "AND enc_identifier_value IN (", query_ids, ")\n")
    encounters_with_same_identifier <- dbGetReadOnlyQuery(query, lock_id = paste0("getAllEncounters()[2]"))
    encounters <- joinEncounters(encounters, encounters_with_same_identifier)
  }

  # Assumption 2: If there are partOf references in the FHIR Encounter resources so
  # we can collect all Encounters of the same medical case by this references

  parent_encounters <- getParentEncounters(encounters, "getParentEncounters_1")
  if (nrow(parent_encounters)) {
    encounters <- joinEncounters(encounters, parent_encounters)
    parent_encounters <- getParentEncounters(parent_encounters, "getParentEncounters_2")
    if (nrow(parent_encounters)) {
      encounters <- joinEncounters(encounters, parent_encounters)
    }
  }

  part_encounters <- getPartEncounters(encounters, "getPartEncounters_1")
  if (nrow(part_encounters)) {
    encounters <- joinEncounters(encounters, part_encounters)
    part_encounters <- getPartEncounters(part_encounters, "getPartEncounters_2")
    if (nrow(part_encounters)) {
      encounters <- joinEncounters(encounters, part_encounters)
    }
  }

  return(encounters)
}
