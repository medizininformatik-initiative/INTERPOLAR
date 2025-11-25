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

#' Retrieve All Related FHIR Encounter Records (via main-encounter refs)
#'
#' @param encounter_ids Character vector of FHIR Encounter IDs (enc_id).
#' @param lock_id_extension Character scalar appended to lock_id for DB queries.
#'
#' @return data.table with all related encounters (deduplicated).
#'
#' @export
fhirdataGetAllEncounters <- function(encounter_ids, lock_id_extension) {
  # Guard: empty input
  if (!length(encounter_ids)) {
    return(data.table::data.table())
  }

  # 1) Fetch encounters for given enc_id
  query_ids <- fhirdbGetQueryList(encounter_ids)
  query <- paste0(
    "SELECT * FROM v_encounter_last_version\n",
    "WHERE enc_id IN ", query_ids, "\n"
  )
  encounters <- dbGetReadOnlyQuery(query, lock_id = paste0("getAllEncounters.main[", lock_id_extension, "]"))
  if (!nrow(encounters)) {
    return(encounters)
  }

  # 2) Resolve main-encounter refs from the encounters (ignore 'invalid')
  main_refs <- unique(na.omit(encounters$enc_main_encounter_calculated_ref))
  main_refs <- main_refs[main_refs != "invalid"]

  # Also keep seeds that had invalid/no main
  encounters_without_main_ref <- encounters[is.na(enc_main_encounter_calculated_ref) | enc_main_encounter_calculated_ref == "invalid"]

  # 3) Pull all encounters of those cases in one query
  all_encounters <- data.table::data.table()
  if (length(main_refs)) {
    query_refs <- fhirdbGetQueryList(main_refs)
    query <- paste0(
      "SELECT * FROM v_encounter_last_version\n",
      "WHERE enc_main_encounter_calculated_ref IN ", query_refs, "\n"
    )
    all_encounters <- dbGetReadOnlyQuery(query, lock_id = paste0("getAllEncounters.cases[", lock_id_extension, "]"))
  }

  # 4) Union with seeds without main and the seeds themselves; dedupe
  if (nrow(encounters_without_main_ref)) {
    all_encounters <- if (nrow(all_encounters)) data.table::rbindlist(list(all_encounters, encounters_without_main_ref), use.names = TRUE, fill = TRUE) else encounters_without_main_ref
  }
  all_encounters <- if (nrow(all_encounters)) data.table::rbindlist(list(all_encounters, encounters), use.names = TRUE, fill = TRUE) else encounters

  unique(all_encounters)
}

#' Filter a main encounter and its directly related sub-encounters
#'
#' This function extracts a main encounter and all directly related encounters from a given
#' data.table of encounters. It includes:
#' - the main encounter identified by its enc_id,
#' - any encounters referencing the main encounter via enc_partof_ref,
#' - any encounters referencing those encounters (i.e., one level deeper),
#' - and, optionally, encounters sharing a common identifier value if a
#' common_encounter_fhir_identifier_system is provided.
#'
#' It is assumed that all_encounters is not empty and contains at least one row with the
#' given main_encounter_id.
#'
#' @param main_encounter_id A character string representing the enc_id of the main encounter
#' to extract.
#' @param all_encounters A data.table containing all available encounters, including columns
#' enc_id, enc_partof_ref, enc_identifier_system, and
#' enc_identifier_value.
#' @param common_encounter_fhir_identifier_system Optional character string indicating the
#' identifier system to be used for identifying encounters with a shared identifier value.
#'
#' @return A data.table containing the main encounter, directly and indirectly related
#' sub-encounters, and optionally all encounters with the same common identifier value.
#'
#' @examples
#' # Not runnable without specific data structure
#' # fhirdataFilterMainAndSubEncounters("enc-123", all_encounters_dt, "http://example.org/system")
#'
#' @export
fhirdataFilterMainAndSubEncounters <- function(main_encounter_id, all_encounters, common_encounter_fhir_identifier_system = NULL) {
  # 1. Find the main encounter with the given id
  encounters <- list(main_encounter = all_encounters[enc_id == main_encounter_id])
  # 2. Find all encounter with partof reference to this encounter
  part_of_encounters <- all_encounters[enc_partof_ref %in% fhirdataGetEncounterReference(main_encounter_id)]
  # 3. Find all encounters with partof reference to the encounters of step 2
  if (nrow(part_of_encounters)  > 0) {
    encounters[["part_of_encounters"]] <- part_of_encounters
    part_of_encounters_references <- fhirdataGetEncounterReference(encounters$part_of_encounters$enc_id)
    encounters[["sub_part_of_encounters"]] <- all_encounters[enc_partof_ref %in% part_of_encounters_references]
  }
  # 4. Find all encounters which the same common identifier if the common_encounter_fhir_identifier_system is given
  if (!is.null(common_encounter_fhir_identifier_system)) {
    # This should be only one, but just in case we handle multiple values
    common_identifier_value <- encounters$main_encounter[
      enc_identifier_system == common_encounter_fhir_identifier_system
    ]$enc_identifier_value
    common_identifier_value <- unique(common_identifier_value)
    if (length(common_identifier_value) > 1) {
      stop(
        "Multiple common identifier values found for encounter ",
        main_encounter_id,
        " and identifier system ",
        common_encounter_fhir_identifier_system,
        ". All encounters must have the following unique identifier value ",
        common_identifier_value, ". "
      )
    }
    if (length(common_identifier_value) == 1 && !is.na(common_identifier_value)) {
       common_identifier_encounters <- all_encounters[
        enc_identifier_system == common_encounter_fhir_identifier_system &
          enc_identifier_value %in% common_identifier_value
      ]
       if(nrow(common_identifier_encounters) > 0) {
         encounters[["common_identifier_encounters"]] <- common_identifier_encounters
       }
    }
  }
  # 5. Rbind all encounter and return them
  encounters <- data.table::rbindlist(Filter(Negate(is.null), encounters))
  return(unique(encounters))
}
