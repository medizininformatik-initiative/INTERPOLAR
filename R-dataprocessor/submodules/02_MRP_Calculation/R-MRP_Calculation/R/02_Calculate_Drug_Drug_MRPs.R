#' Clean and Expand Drug_Drug_MRP Definition Table
#'
#' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#' splitting and trimming values, and expanding concatenated ICD codes.
#'
#' @param drug_drug_mrp_definition A data.table containing the MRP definition table.
#' @param table_name A character string representing the base name of the MRP definition (e.g., `"Drug_Disease"`).
#'
#' @return A cleaned and expanded data.table containing the MRP definition table.
#'
#' @export
cleanAndExpandDefinitionDrugDrug <- function(drug_drug_mrp_definition, table_name) {

  # Remove not nesessary columns
  relevant_column_names <- unlist(MRP_TABLE_COLUMN_NAMES[[table_name]], use.names = FALSE)
  drug_drug_mrp_definition <- drug_drug_mrp_definition[,  ..relevant_column_names]
  drug_drug_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_drug_mrp_definition, relevant_column_names)

  computeATCForCalculation <- function(data_table, primary_col, inclusion_col, output_col, secondary_cols) {
    suffix_map <- setNames(secondary_cols, sub(".*_", "", secondary_cols))

    data_table[, (output_col) := apply(.SD, 1, function(row) {
      inclusions <- trimws(unlist(strsplit(row[[inclusion_col]], "\\s+")))
      all_secondary <- character(0)

      for (inclusion in inclusions) {
        if (inclusion == "alle") {
          raw_values <- row[secondary_cols]
        } else if (inclusion == "keine weiteren") {
          raw_values <- character(0)
        } else {
          suffixes <- trimws(unlist(strsplit(inclusion, ",")))
          cols <- suffix_map[suffixes]
          raw_values <- row[cols]
        }
        all_secondary <- c(all_secondary, raw_values)
      }
      secondary <- unlist(strsplit(paste(na.omit(all_secondary), collapse = " "), "\\s+"))
      all_atc <- unique(c(row[[primary_col]], secondary))
      all_atc <- all_atc[nzchar(all_atc)]
      paste(all_atc, collapse = " ")
    }), .SDcols = c(primary_col, inclusion_col, secondary_cols)]
  }

  computeATCForCalculation(
    data_table = drug_drug_mrp_definition,
    primary_col = "ATC_PRIMARY",
    inclusion_col = "ATC_INCLUSION",
    output_col = "ATC_FOR_CALCULATION",
    secondary_cols = c("ATC_SYSTEMIC_SY", "ATC_DERMATIKA_D", "ATC_OPHTHALMIKA_O", "ATC_INHALANDA_I", "ATC_SONSTIGE_SO")
  )
  computeATCForCalculation(
    data_table = drug_drug_mrp_definition,
    primary_col = "ATC2_PRIMARY",
    inclusion_col = "ATC2_INCLUSION",
    output_col = "ATC2_FOR_CALCULATION",
    secondary_cols = c("ATC2_SYSTEMIC_SY", "ATC2_DERMATIKA_D", "ATC2_OPHTHALMIKA_O", "ATC2_INHALANDA_I", "ATC2_SONSTIGE_SO")
  )

  relevant_column_names <- c("ATC_FOR_CALCULATION", "ATC2_FOR_CALCULATION")
  # SPLIT and TRIM: ICD and proxy column:
  # split the whitespace separated lists in ICD and proxy columns in a single row per code
  drug_drug_mrp_definition <- etlutils::splitColumnsToRows(drug_drug_mrp_definition, relevant_column_names)
  # trim all values in the whole table
  etlutils::trimTableValues(drug_drug_mrp_definition)
  # After the replacing of special signs with an empty string their can be new empty rows in this both columns
  drug_drug_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_drug_mrp_definition, relevant_column_names)

  # Remove duplicate rows
  drug_drug_mrp_definition <- unique(drug_drug_mrp_definition)

  # Clean rows with NA or empty values in relevant columns
  for (col in relevant_column_names) {
    drug_drug_mrp_definition[[col]] <- ifelse(
      is.na(drug_drug_mrp_definition[[col]]) |
        !nzchar(trimws(drug_drug_mrp_definition[[col]])),
      NA_character_,
      drug_drug_mrp_definition[[col]]
    )
  }

  # check column ATC and ATC_PROXY for correct ATC codes
  atc_columns <- grep("ATC(?!.*(DISPLAY|INCLUSION|VALIDITY_DAYS))", names(drug_drug_mrp_definition), value = TRUE, perl = TRUE)
  atc_errors <- validateATCCodes(drug_drug_mrp_definition, atc_columns)
  error_messages <- formatCodeErrors(atc_errors, "ATC")

  if (length(error_messages) > 0) {
    stop(paste(error_messages, collapse = "\n"))
  }

  return(drug_drug_mrp_definition)
}

#' Match ATC and ATC2 codes between active medication requests and MRP definitions
#'
#' This function compares ATC codes from a list of active medication requests with MRP rule definitions
#' in \code{mrp_table_list_by_atc}. It checks whether any defined interactions (via the \code{ATC2_FOR_CALCULATION}
#' field) also occur in the active medications. For each matched ATC–ATC2 pair, it returns a descriptive
#' entry indicating a potential contraindication.
#'
#' @param active_requests A \code{data.table} containing at least the column \code{atc_code},
#'        which lists ATC codes of currently active medication requests.
#' @param mrp_table_list_by_atc A named list of \code{data.table}s, where each name corresponds to an
#'        ATC code, and each table contains MRP rule definitions, including a column \code{ATC2_FOR_CALCULATION}.
#'
#' @return A \code{data.table} with the columns:
#'   \describe{
#'     \item{\code{atc_code}}{The ATC code from the active request matching the MRP rule.}
#'     \item{\code{atc2_code}}{The interacting ATC2 code also found in the active requests.}
#'     \item{\code{proxy_code}}{Currently unused (placeholder).}
#'     \item{\code{proxy_type}}{Currently unused (placeholder).}
#'     \item{\code{kurzbeschr}}{A short textual description of the interaction.}
#'   }
matchATCandATC2Codes <- function(active_requests, mrp_table_list_by_atc) {
  matched_rows <- list()
  active_atcs <- unique(active_requests$atc_code)
  used_keys <- intersect(names(mrp_table_list_by_atc), active_atcs)

  for (atc_code in used_keys) {
    mrp_rows <- mrp_table_list_by_atc[[atc_code]]
    mrp_rows <- mrp_rows[ATC2_FOR_CALCULATION %in% active_atcs]

    for (j in seq_len(nrow(mrp_rows))) {
      rule <- mrp_rows[j]
      atc2_code <- rule$ATC2_FOR_CALCULATION

      matched_rows[[length(matched_rows) + 1]] <- data.table::data.table(
        atc_code = atc_code,
        atc2_code = atc2_code,
        proxy_code = NA_character_,
        proxy_type = NA_character_,
        kurzbeschr = paste0(
          rule$ATC_DISPLAY, " (", atc_code, ") ist bei ",
          rule$ATC2_DISPLAY, " (", atc2_code, ") kontrainduziert."
        )
      )
    }
  }
  return(data.table::rbindlist(matched_rows, fill = TRUE))
}

#' Calculate Drug-Drug Medication-Related Problems (MRPs)
#'
#' This function evaluates potential drug-drug interactions for a set of patient encounters
#' based on predefined MRP (medication-related problem) rules. For each patient encounter,
#' it identifies all active medications and checks whether any known contraindications exist
#' between them using ATC-based MRP definitions.
#'
#' For each encounter, the function:
#' \itemize{
#'   \item Retrieves active medication requests (ATC codes).
#'   \item Matches pairs of ATC codes from the patient with known contraindicated combinations from the MRP definitions.
#'   \item Records the results for reporting and audit purposes.
#' }
#'
#' @param drug_drug_mrp_tables A \code{data.table} containing drug-drug MRP rules.
#'   Required columns include:
#'   \describe{
#'     \item{\code{ATC_FOR_CALCULATION}}{Primary ATC code used to match active medication.}
#'     \item{\code{ATC2_FOR_CALCULATION}}{Second ATC code for potential contraindication.}
#'     \item{\code{ATC_DISPLAY}, \code{ATC2_DISPLAY}}{Human-readable names for the ATC codes.}
#'     \item{Additional metadata columns may also be present.}
#'   }
#' @param input_file_processed_content_hash A string identifying the input file version for traceability
#'   (used in audit logs and for reproducibility).
#'
#' @return A named list with two \code{data.table} objects:
#' \describe{
#'   \item{\code{retrolektive_mrpbewertung_fe}}{Table with MRP evaluation results, formatted for REDCap import or reporting.}
#'   \item{\code{dp_mrp_calculations}}{Audit trail of all calculations performed, including metadata and proxy information.}
#' }
#'
#' @details
#' - This function internally uses:
#'   \itemize{
#'     \item \code{getResourcesForMRPCalculation()} to retrieve FHIR-based data sources.
#'     \item \code{getActiveMedicationRequests()} to determine relevant medications.
#'     \item \code{matchATCandATC2Codes()} to detect contraindicated drug combinations.
#'   }
calculateDrugDrugMRPs <- function(drug_drug_mrp_tables, input_file_processed_content_hash) {

  resources <- getResourcesForMRPCalculation(MRP_CALCULATION_TYPE$Drug_Drug)

  if (!length(resources)) {
    return(list())
  }

  # Split drug_disease_mrp_tables by ATC
  drug_drug_mrp_tables_by_atc <- etlutils::splitTableToList(drug_drug_mrp_tables, "ATC_FOR_CALCULATION")

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
    meda_study_phase <- if (!is.null(meda)) meda$study_phase else NA_character_
    meda_ward_name <- if (!is.null(meda)) meda$ward_name else NA_character_
    record_id <- as.integer(resources$record_ids[pat_id == patient_id, record_id])
    # results in "1234-TEST-r" or "1234-r" with the meda_id = "1234"
    ret_id_prefix <- paste0(ifelse(meda_study_phase == "PhaseBTest", paste0(meda_id, "-TEST"), meda_id), "-r")
    ret_status <- ifelse(meda_study_phase == "PhaseBTest", "Unverified", NA_character_)
    kurzbeschr_prefix <- ifelse(meda_study_phase == "PhaseBTest", "*TEST* MRP FÜR FALL AUS PHASE A MIT TEST FÜR PHASE B *TEST*\n\n", "")

    # Get active MedicationRequests for the encounter
    active_requests <- getActiveMedicationRequests(resources$medication_requests, encounter$enc_period_start, meda_datetime)

    if (nrow(active_requests) && meda_study_phase != "PhaseA") {
      # Match ATC-codes between encounter data and MRP definitions
      match_atc_and_atc2_codes <- matchATCandATC2Codes(active_requests, drug_drug_mrp_tables_by_atc)
    } else {
      # No active medication requests found for this encounter
      match_atc_and_atc2_codes <- data.table::data.table()
    }
  }

  if (nrow(match_atc_and_atc2_codes)) {
    # Iterate over matched results and create new rows for retrolektive_mrpbewertung and dp_mrp_calculations
    for (i in seq_len(nrow(match_atc_and_atc2_codes))) {
      match <- match_atc_and_atc2_codes[i]
      meda_id_value <- meda_id # we need this renaming for the following comparison
      existing_ret_ids <- resources$existing_retrolective_mrp_evaluation_ids[meda_id == meda_id_value, ret_id]

      next_index <- if (length(existing_ret_ids) == 0) 1 else max(as.integer(sub(ret_id_prefix, "", existing_ret_ids)), na.rm = TRUE) + 1
      ret_id <- paste0(ret_id_prefix, next_index)
      # always updating the references to the existing ret_ids
      resources$existing_retrolective_mrp_evaluation_ids <- etlutils::addTableRow(resources$existing_retrolective_mrp_evaluation_ids, meda_id, ret_id)

      # Create new row for table retrolektive_mrpbewertung
      retrolektive_mrpbewertung_rows[[length(retrolektive_mrpbewertung_rows) + 1]] <- list(
        record_id = record_id,
        ret_id = ret_id,
        ret_meda_id = meda_id,
        ret_meda_dat1 = meda_datetime,
        ret_kurzbeschr = paste0(kurzbeschr_prefix, match$kurzbeschr),
        ret_atc1 = match$atc_code,
        ret_ip_klasse_01 = MRP_CALCULATION_TYPE$Drug_Drug,
        ret_atc2 = match$atc2_code,
        retrolektive_mrpbewertung_complete = ret_status,
        redcap_repeat_instrument = "retrolektive_mrpbewertung",
        redcap_repeat_instance = i
      )

      # Create new row for table dp_mrp_calculations
      dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
        enc_id = encounter_id,
        mrp_calculation_type = MRP_CALCULATION_TYPE$Drug_Drug,
        meda_id = meda_id,
        study_phase = meda_study_phase,
        ward_name = meda_ward_name,
        ret_id = retrolektive_mrpbewertung_rows[[length(retrolektive_mrpbewertung_rows)]]$ret_id,
        mrp_proxy_type = match$proxy_type,
        mrp_proxy_code = match$proxy_code,
        input_file_processed_content_hash = input_file_processed_content_hash
      )

    }
  } else {
    # No matches found for this encounter
    dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
      enc_id = encounter_id,
      mrp_calculation_type = MRP_CALCULATION_TYPE$Drug_Disease,
      meda_id = meda_id,
      study_phase = meda_study_phase,
      ward_name = meda_ward_name,
      ret_id = NA_character_,
      mrp_proxy_type = NA_character_,
      mrp_proxy_code = NA_character_,
      input_file_processed_content_hash = input_file_processed_content_hash
    )
  }

  # Combine all collected rows into data.tables
  retrolektive_mrpbewertung <- data.table::rbindlist(retrolektive_mrpbewertung_rows, use.names = TRUE, fill = TRUE)
  dp_mrp_calculations <- data.table::rbindlist(dp_mrp_calculations_rows, use.names = TRUE, fill = TRUE)

  return(list(
    retrolektive_mrpbewertung_fe = retrolektive_mrpbewertung,
    dp_mrp_calculations = dp_mrp_calculations
  ))
}
