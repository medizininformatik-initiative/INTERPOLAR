# Execution orchestration for the fallvignette process evaluation.

#' Collect the WP7 definitions needed for fallvignettes
#'
#' @param mrp_pair_lists Processed local WP7 MRP definition tables.
#' @param loinc_mapping Processed local LOINC mapping table.
#'
#' @return A named list containing diagnosis rules, relevant LOINC codes and
#'   the LOINC mapping.
prepareFallvignetteWp7Definitions <- function(
  mrp_pair_lists,
  loinc_mapping
) {
  relevant_mrp_types <- intersect(
    c("Drug_Disease", "Drug_Niereninsuffizienz"),
    names(mrp_pair_lists)
  )
  if (!length(relevant_mrp_types)) {
    stop("No WP7 diagnosis definition was loaded for fallvignettes.")
  }

  relevant_mrp_definitions <- lapply(
    mrp_pair_lists[relevant_mrp_types],
    function(mrp_definition) {
      if ("processed_content" %in% names(mrp_definition)) {
        return(mrp_definition[["processed_content"]])
      }
      mrp_definition
    }
  )

  diagnosis_rules <- data.table::rbindlist(lapply(
    relevant_mrp_definitions,
    function(mrp_definition) {
      required_columns <- c("ICD", "ICD_VALIDITY_DAYS")
      missing_columns <- setdiff(required_columns, names(mrp_definition))
      if (length(missing_columns)) {
        stop(
          "WP7 diagnosis definition is missing columns: ",
          paste(missing_columns, collapse = ", ")
        )
      }
      data.table::as.data.table(mrp_definition)[
        , required_columns,
        with = FALSE
      ]
    }
  ), use.names = TRUE, fill = TRUE)
  valid_diagnosis_rows <- !is.na(diagnosis_rules[["ICD"]]) &
    nzchar(trimws(diagnosis_rules[["ICD"]]))
  diagnosis_rules <- unique(diagnosis_rules[
    which(valid_diagnosis_rows),
    names(diagnosis_rules),
    with = FALSE
  ])

  relevant_loinc_codes <- unique(unlist(lapply(
    relevant_mrp_definitions,
    function(mrp_definition) {
      if (!"LOINC_PRIMARY_PROXY" %in% names(mrp_definition)) {
        return(character())
      }
      trimws(as.character(mrp_definition[["LOINC_PRIMARY_PROXY"]]))
    }
  ), use.names = FALSE))
  relevant_loinc_codes <- relevant_loinc_codes[
    !is.na(relevant_loinc_codes) & nzchar(relevant_loinc_codes)
  ]

  list(
    diagnosis_rules = diagnosis_rules,
    relevant_loinc_codes = relevant_loinc_codes,
    loinc_mapping = data.table::as.data.table(loinc_mapping)
  )
}

#' Load encounters needed to identify recent operations
#'
#' @param patient_references Patient references or IDs.
#'
#' @param resource_fun Existing generic FHIR resource loader.
#' @param lock_id Optional database lock identifier.
#'
#' @return Encounter resources containing KontaktArt and period columns.
getFallvignetteEncountersFromDB <- function(
  patient_references,
  resource_fun = getResourcesFromDB,
  lock_id = NULL
) {
  resource_fun(
    resource_name = "Encounter",
    column_names = c(
      "enc_id",
      "enc_patient_ref",
      "enc_type_system",
      "enc_type_code",
      "enc_period_start",
      "enc_period_end"
    ),
    patient_references = patient_references,
    status_exclusion = c("cancelled", "entered-in-error"),
    lock_id = lock_id
  )
}

#' Load referenced PZN-coded medications
#'
#' The existing MRP medication loader resolves ATC ingredients. This small
#' companion query is needed because PZN is only a fallvignette fallback and is
#' intentionally not treated as an ATC by appendATCColumns().
#'
#' @param medication_requests MedicationRequest resources.
#' @param query_fun Read-only database query function.
#'
#' @return Medication resources carrying a PZN code.
getFallvignettePznMedicationsFromDB <- function(
  medication_requests,
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  medication_ids <- unique(medication_requests[["med_id"]])
  medication_ids <- medication_ids[
    !is.na(medication_ids) & nzchar(medication_ids)
  ]
  if (!length(medication_ids)) {
    return(data.table::data.table(
      med_id = character(),
      med_code_system = character(),
      med_code_code = character(),
      med_code_display = character()
    ))
  }

  where_clause <- paste0(
    "WHERE med_id IN ",
    etlutils::fhirdbGetQueryList(medication_ids),
    "\nAND LOWER(med_code_system) LIKE '%pzn%'\n"
  )
  query <- getQueryToLoadResourcesLastVersionFromDB(
    resource_name = "Medication",
    column_names = c(
      "med_id",
      "med_code_system",
      "med_code_code",
      "med_code_display"
    ),
    filter = where_clause
  )
  data.table::as.data.table(query_fun(query, lock_id = NULL))
}

#' Add ATC information while retaining direct PZN fallbacks
#'
#' @param medication_requests MedicationRequest resources.
#' @param medications Medication resources returned by
#'   getATCMedicationsFromDB().
#' @param pzn_medications Referenced Medication resources carrying PZN codes.
#' @param append_atc_fun Existing helper used to resolve ATC codes.
#'
#' @return MedicationRequest rows with optional atc_code and atc_display.
prepareFallvignetteMedicationRequests <- function(
  medication_requests,
  medications,
  pzn_medications = data.table::data.table(),
  append_atc_fun = appendATCColumns
) {
  if (!nrow(medication_requests)) {
    result <- data.table::copy(medication_requests)
    data.table::set(result, j = "atc_code", value = character())
    data.table::set(result, j = "atc_display", value = character())
    return(result[])
  }

  atc_requests <- append_atc_fun(
    data.table::copy(medication_requests),
    medications
  )
  requests_with_atc <- unique(atc_requests[["medreq_id"]])
  fallback_indices <- which(
    !medication_requests[["medreq_id"]] %in% requests_with_atc
  )
  fallback_requests <- data.table::copy(medication_requests)[
    fallback_indices,
    names(medication_requests),
    with = FALSE
  ]
  data.table::set(
    fallback_requests,
    j = "atc_code",
    value = rep(NA_character_, nrow(fallback_requests))
  )
  if (nrow(pzn_medications) && nrow(fallback_requests)) {
    pzn_indices <- match(
      fallback_requests[["med_id"]],
      pzn_medications[["med_id"]]
    )
    has_pzn <- !is.na(pzn_indices)
    for (column_name in c("system", "code", "display")) {
      target_column <- paste0(
        "medreq_medicationcodeableconcept_",
        column_name
      )
      source_column <- paste0("med_code_", column_name)
      data.table::set(
        fallback_requests,
        i = which(has_pzn),
        j = target_column,
        value = pzn_medications[[source_column]][pzn_indices[has_pzn]]
      )
    }
  }
  data.table::set(
    fallback_requests,
    j = "atc_display",
    value = rep(NA_character_, nrow(fallback_requests))
  )

  data.table::rbindlist(
    list(atc_requests, fallback_requests),
    use.names = TRUE,
    fill = TRUE
  )[]
}

#' Load clinical resources for fallvignettes
#'
#' @param patient_references Patient references or IDs.
#'
#' @return Named list of clinical FHIR resource tables.
getFallvignetteClinicalResources <- function(patient_references) {
  medication_requests <- getMedicationRequestsFromDB(
    patient_references,
    lock_id = NULL
  )
  empty_administrations <- data.table::data.table(
    medadm_medicationreference_ref = character()
  )
  empty_statements <- data.table::data.table(
    medstat_medicationreference_ref = character()
  )
  medications <- getATCMedicationsFromDB(
    medication_requests,
    empty_administrations,
    empty_statements,
    lock_id_prefix = NULL
  )
  pzn_medications <- getFallvignettePznMedicationsFromDB(
    medication_requests
  )

  list(
    conditions = getConditionsFromDB(patient_references, lock_id = NULL),
    medication_requests = prepareFallvignetteMedicationRequests(
      medication_requests,
      medications,
      pzn_medications
    ),
    observations = getObservationsFromDB(patient_references, lock_id = NULL),
    procedures = getProceduresFromDB(patient_references, lock_id = NULL),
    encounters = getFallvignetteEncountersFromDB(
      patient_references,
      lock_id = NULL
    )
  )
}

#' Run the fallvignette process evaluation export
#'
#' Loads the local WP7 definitions before switching the database context to the
#' configured DB_ANALYSIS target. All patient and case data are then read from
#' that target and written as REDCap-compatible CSV and XLSX files.
#'
#' @param output_dir Output directory.
#' @param id_mapping_output_dir Local-only ID mapping output directory.
#' @param site_code Configured site code.
#' @param ward_definitions Environment containing PHASES_WARD definitions.
#' @param db_config_environment Environment containing the central
#'   `PATH_TO_DB_CONFIG_TOML` dataprocessor setting.
#' @param load_mrp_fun Function loading processed local WP7 MRP definitions.
#' @param load_loinc_fun Function loading the processed local LOINC mapping.
#' @param set_db_context_fun Function switching to the analysis database.
#' @param get_source_fun Function loading eligible source rows.
#' @param get_resources_fun Function loading clinical FHIR resources.
#' @param write_fun Function writing the final import files.
#' @param write_id_mapping_fun Function writing the local ID mapping.
#'
#' @return Invisibly returns the import and local ID mapping paths.
runFallvignetteProcessEvaluation <- function(
  output_dir,
  id_mapping_output_dir,
  site_code,
  ward_definitions = .GlobalEnv,
  db_config_environment = .GlobalEnv,
  load_mrp_fun = getMRPPairLists,
  load_loinc_fun = getLOINCMapping,
  set_db_context_fun = etlutils::dbSetModuleContextFromEnvironment,
  get_source_fun = getFallvignetteSourceData,
  get_resources_fun = getFallvignetteClinicalResources,
  write_fun = writeFallvignetteImportFiles,
  write_id_mapping_fun = writeFallvignetteIdMappingFile
) {
  mapping_path <- getFallvignetteMappingPath()
  mapping <- loadFallvignetteMapping(mapping_path)

  wp7_definitions <- prepareFallvignetteWp7Definitions(
    load_mrp_fun(),
    load_loinc_fun()$processed_content
  )

  set_database_context <- function(target_prefix) {
    set_db_context_fun(
      module_name = "dataprocessor",
      path_variable = "PATH_TO_DB_CONFIG_TOML",
      envir = db_config_environment,
      db_schema_base_name = "dataprocessor",
      target_prefix = target_prefix,
      log = FALSE
    )
  }
  set_database_context("DB_ANALYSIS")
  on.exit(set_database_context(NULL), add = TRUE)

  source_data <- get_source_fun(mapping, lock_id = NULL)
  if (nrow(source_data)) {
    resources <- get_resources_fun(unique(source_data[["pat_id"]]))
    source_data <- addFallvignetteClinicalContext(
      source_data = source_data,
      conditions = resources$conditions,
      diagnosis_rules = wp7_definitions$diagnosis_rules,
      medication_requests = resources$medication_requests,
      observations = resources$observations,
      loinc_mapping = wp7_definitions$loinc_mapping,
      relevant_loinc_codes = wp7_definitions$relevant_loinc_codes,
      procedures = resources$procedures,
      encounters = resources$encounters
    )
  }

  import_data <- createFallvignetteImportData(
    source_data = source_data,
    mapping = mapping,
    ward_definitions = ward_definitions,
    site_code = site_code
  )
  id_mapping <- attr(import_data, "fallvignette_id_mapping")
  if (!data.table::is.data.table(id_mapping)) {
    stop("Fallvignette import data is missing its local ID mapping.")
  }
  id_mapping_path <- write_id_mapping_fun(
    id_mapping = id_mapping,
    output_dir = id_mapping_output_dir,
    file_name = "Fallvignette_Process_Evaluation_ID_Mapping"
  )
  import_paths <- write_fun(
    fallvignettes = import_data,
    output_dir = output_dir,
    mapping = mapping,
    file_name = "WP8_Fallvignetten_Import"
  )
  invisible(c(import_paths, list(id_mapping = id_mapping_path)))
}
