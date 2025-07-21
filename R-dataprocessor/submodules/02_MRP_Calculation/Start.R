getMRPTypeFunction <- function(prefix, mrp_type) {
  mrp_type_cleaned <- gsub("_", "", mrp_type)
  function_name <- paste0(prefix, mrp_type_cleaned)
  return(get(function_name, mode = "function"))
}

getPairListColumnNames <- function(mrp_type) {
  getMRPTypeFunction("getPairListColumnNames", mrp_type)()
}

getCategoryDisplay <- function(mrp_type) {
  getMRPTypeFunction("getCategoryDisplay", mrp_type)()
}

getMRPPairLists <- function() {
  mrp_pair_lists <- list()
  for (mrp_type in MRP_TYPE) {
    etlutils::runLevel3(paste0("Load and expand ", mrp_type, " Definition"), {
      mrp_content <- getExpandedContent(mrp_type)
      if (!is.null(mrp_content)) {
        mrp_pair_lists[[mrp_type]] <- mrp_content
      }
    })
  }
  return(mrp_pair_lists)
}

#' Calculate Medication-Related Problems (MRPs) for All Types
#'
#' This function analyzes potential medication-related problems (MRPs) across a set of patient
#' encounters. It evaluates predefined MRP rules for contraindications between active medications
#' and known patient diagnoses or co-medications. The function supports multiple MRP types
#' (e.g., Drug-Disease, Drug-Drug) and consolidates results into unified output tables.
#'
#' For each MRP type and each encounter, the function:
#' \itemize{
#'   \item Gathers all active medications and patient conditions.
#'   \item Matches medication ATC codes against MRP definitions.
#'   \item Attempts to find matching ICD codes directly from patient conditions.
#'   \item If no direct ICD matches are found, evaluates proxy rules (using ATC or OPS codes).
#'   \item Compiles results into descriptive and audit tables.
#' }
#'
#' @return A named list with two `data.table` objects:
#' \describe{
#'   \item{retrolektive_mrpbewertung_fe}{Combined MRP evaluations across all types, ready for reporting or REDCap import.}
#'   \item{dp_mrp_calculations}{Combined audit log of all MRP evaluation steps, including proxy type and code used.}
#' }
#'
#' @details
#' - The function uses `getResourcesForMRPCalculation()` to load relevant FHIR resources.
#' - ATC codes are matched using `matchATCCodes()`, ICDs using `matchICDCodes()`.
#' - If no ICD match is found, `matchICDProxies()` evaluates proxy rules (ATC/OPS).
#' - Each match results in one entry in both output tables.
#' - If no match is found for an encounter, a placeholder entry is created in `dp_mrp_calculations`.
#' - The function merges all MRP types into two unified output tables.
#'
calculateMRPs <- function() {
  # Get all Einrichtungskontakt encounters that ended at least 14 days ago
  # and do not have a retrolective MRP evaluation for Drug_Disease
  main_encounters_by_mrp_type <- getEncountersWithoutRetrolectiveMRPEvaluationFromDB()
  main_encounters <- main_encounters_by_mrp_type[["ALL_TYPES"]]

  mrp_table_lists_all <- list()

  resources <- getResourcesForMRPCalculation(main_encounters)
  if (length(resources)) {
    mrp_pair_lists <- getMRPPairLists()

    for (mrp_type in names(mrp_pair_lists)) {

      etlutils::runLevel3(paste0("Calculate ", mrp_type, " MRPs"), {

        mrp_pair_list <- mrp_pair_lists[[mrp_type]]
        input_file_processed_content_hash <- mrp_pair_list$processed_content_hash
        splitted_mrp_tables <- getMRPTypeFunction("getSplittedMRPTables", mrp_type)(mrp_pair_list)

        # Initialize empty lists for results
        retrolektive_mrpbewertung_rows <- list()
        dp_mrp_calculations_rows <- list()

        for (encounter_id in resources$main_encounters$enc_id) {

          # Get encounter data and patient ID
          encounter <- resources$main_encounters[enc_id == encounter_id]
          patient_id <- etlutils::fhirdataExtractIDs(encounter$enc_patient_ref)
          meda <- resources$encounters_first_medication_analysis[[encounter_id]]
          meda_id <- if (!is.null(meda)) meda$meda_id else NA_character_
          meda_datetime <- if (!is.null(meda)) meda$meda_dat else NA
          meda_study_phase <- encounter$study_phase
          meda_ward_name <- encounter$ward_name
          record_id <- as.integer(resources$record_ids[pat_id == patient_id, record_id])
          # results in "1234-TEST-r" or "1234-r" with the meda_id = "1234"
          ret_id_prefix <- paste0(ifelse(meda_study_phase == "PhaseBTest", paste0(meda_id, "-TEST"), meda_id), "-r")
          ret_status <- ifelse(meda_study_phase == "PhaseBTest", "Unverified", NA_character_)
          kurzbeschr_prefix <- ifelse(meda_study_phase == "PhaseBTest", "*TEST* MRP FÜR FALL AUS PHASE A MIT TEST FÜR PHASE B *TEST*\n\n", "")

          # Get active MedicationRequests for the encounter
          active_requests <- getActiveMedicationRequests(resources$medication_requests, encounter$enc_period_start, meda_datetime)
          match_atc_and_item2_codes <- data.table::data.table()

          if (nrow(active_requests) && meda_study_phase != "PhaseA") {
            match_atc_and_item2_codes <- getMRPTypeFunction("calculateMRPs", mrp_type)(
              active_requests = active_requests,
              splitted_mrp_tables = splitted_mrp_tables,
              resources = resources,
              patient_id = patient_id,
              meda_datetime = meda_datetime
            )
          }

          if (nrow(match_atc_and_item2_codes)) {
            # Iterate over matched results and create new rows for retrolektive_mrpbewertung and dp_mrp_calculations
            for (match in seq_len(nrow(match_atc_and_item2_codes))) {
              match <- match_atc_and_item2_codes[match]
              meda_id_value <- meda_id # we need this renaming for the following comparison
              existing_ret_ids <- resources$existing_retrolective_mrp_evaluation_ids[meda_id == meda_id_value, ret_id]
              existing_redcap_repeat_instances <- resources$existing_retrolective_mrp_evaluation_ids[meda_id == meda_id_value, ret_redcap_repeat_instance]
              next_index <- if (length(existing_ret_ids) == 0) 1 else max(as.integer(sub(ret_id_prefix, "", existing_ret_ids)), na.rm = TRUE) + 1
              ret_id <- paste0(ret_id_prefix, next_index)
              ret_redcap_repeat_instance <- if (length(existing_redcap_repeat_instances) == 0) 1 else max(as.integer(existing_redcap_repeat_instances), na.rm = TRUE) + 1
              # always updating the references to the existing ret_ids
              resources$existing_retrolective_mrp_evaluation_ids <- etlutils::addTableRow(resources$existing_retrolective_mrp_evaluation_ids, meda_id, ret_id, ret_redcap_repeat_instance)

              # Create new row for table retrolektive_mrpbewertung
              retrolektive_mrpbewertung_rows[[length(retrolektive_mrpbewertung_rows) + 1]] <- list(
                record_id = record_id,
                ret_id = ret_id,
                ret_meda_id = meda_id,
                ret_meda_dat1 = meda_datetime,
                ret_kurzbeschr = paste0(kurzbeschr_prefix, match$kurzbeschr),
                ret_atc1 = match$atc_code,
                ret_ip_klasse_01 = getCategoryDisplay(mrp_type),
                ret_ip_klasse_disease = if (is.null(match$icd)) NA else match$icd,
                ret_atc2 = if (is.null(match$atc2_code)) NA else match$atc2_code,
                retrolektive_mrpbewertung_complete = ret_status,
                redcap_repeat_instrument = "retrolektive_mrpbewertung",
                redcap_repeat_instance = ret_redcap_repeat_instance
              )

              # Create new row for table dp_mrp_calculations
              dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
                enc_id = encounter_id,
                mrp_calculation_type = mrp_type,
                meda_id = meda_id,
                study_phase = meda_study_phase,
                ward_name = meda_ward_name,
                ret_id = ret_id,
                ret_redcap_repeat_instance = ret_redcap_repeat_instance,
                mrp_proxy_type = match$proxy_type,
                mrp_proxy_code = match$proxy_code,
                input_file_processed_content_hash = input_file_processed_content_hash
              )

            }
          } else {
            # No matches found for this encounter
            dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
              enc_id = encounter_id,
              mrp_calculation_type = mrp_type,
              meda_id = meda_id,
              study_phase = meda_study_phase,
              ward_name = meda_ward_name,
              ret_id = NA_character_,
              ret_redcap_repeat_instance = NA_character_,
              mrp_proxy_type = NA_character_,
              mrp_proxy_code = NA_character_,
              input_file_processed_content_hash = input_file_processed_content_hash
            )
          }
        }
        # Combine all collected rows into data.tables
        retrolektive_mrpbewertung <- data.table::rbindlist(retrolektive_mrpbewertung_rows, use.names = TRUE, fill = TRUE)
        dp_mrp_calculations <- data.table::rbindlist(dp_mrp_calculations_rows, use.names = TRUE, fill = TRUE)

        mrp_table_lists_all[[mrp_type]] <- list(
          retrolektive_mrpbewertung_fe = retrolektive_mrpbewertung,
          dp_mrp_calculations = dp_mrp_calculations
        )
      })
    }
  }
  # Merge all MRP tables into a single list for output
  mrp_table_lists_all_merged <- list(
    retrolektive_mrpbewertung_fe = data.table::rbindlist(
      lapply(mrp_table_lists_all, `[[`, "retrolektive_mrpbewertung_fe"),
      use.names = TRUE, fill = TRUE
    ),
    dp_mrp_calculations = data.table::rbindlist(
      lapply(mrp_table_lists_all, `[[`, "dp_mrp_calculations"),
      use.names = TRUE, fill = TRUE
    )
  )

  return(mrp_table_lists_all_merged)
}

etlutils::runLevel2("MRP Calculation", {
  mrp_table_lists_all <- calculateMRPs()
})

etlutils::runLevel2("Write Retrolective MRP calculation to database", {
  etlutils::dbWriteTables(
    tables = mrp_table_lists_all,
    lock_id = "Write Retrolective MRP calculation to database",
    stop_if_table_not_empty = FALSE)
})
