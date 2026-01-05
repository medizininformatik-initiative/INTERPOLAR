#' Get Column Names for Drug-Disease MRP Pair List
#'
#' Returns a named character vector of relevant column names used in the
#' Drug-Disease medication-related problem (MRP) pair list.
#' These columns define the structure of the MRP rule table, including
#' primary ATC codes, condition codes (ICD), proxy rules, and laboratory proxies (LOINC).
#'
#' @return A named character vector of column names relevant to Drug-Disease MRP definitions.
getRelevantColumnNamesDrugDisease <- function() {
  etlutils::namedVectorByValue(
    #"SMPC_NAME",
    #"SMPC_VERSION",
    "ATC_DISPLAY",
    "ATC_PRIMARY",
    "ATC_SYSTEMIC_SY",
    "ATC_DERMATIC_D",
    "ATC_OPHTHALMOLOGIC_OP",
    "ATC_INHALATIVE_I",
    "ATC_OTHER_OT",
    "ATC_INCLUSION",
    "CONDITION_DISPLAY",
    "CONDITION_DISPLAY_CLUSTER",
    "ICD",
    "ICD_VALIDITY_DAYS",
    "ICD_PROXY_ATC",
    "ICD_PROXY_ATC_VALIDITY_DAYS",
    "ICD_PROXY_OPS",
    "ICD_PROXY_OPS_VALIDITY_DAYS",
    "LOINC_PRIMARY_PROXY",
    "LOINC_UNIT",
    "LOINC_DISPLAY",
    "LOINC_VALIDITY_DAYS",
    "LOINC_CUTOFF_REFERENCE",
    "LOINC_CUTOFF_ABSOLUTE")
}

#' Get Category Display Name for Drug-Disease MRPs
#'
#' Returns the display label for the MRP category "Drug-Disease", used for
#' tagging or labeling MRPs in evaluation outputs.
#'
#' @return A character string: \code{"Drug-Disease"}
getCategoryDisplayDrugDisease <- function() {"Drug-Disease"}

#' Clean and Expand Drug_Disease_MRP Definition Table
#'
#' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#' splitting and trimming values, and expanding concatenated ICD codes.
#'
#' @param drug_disease_mrp_definition A data.table containing the MRP definition table.
#' @param mrp_type A character string representing the base name of the MRP definition (e.g., `"Drug_Disease"`).
#'
#' @return A cleaned and expanded data.table containing the MRP definition table.
#'
#' @export
processExcelContentDrugDisease <- function(drug_disease_mrp_definition, mrp_type) {

  drug_disease_mrp_definition <- processExcelContentDrugCondition(drug_disease_mrp_definition, mrp_type)

  return(drug_disease_mrp_definition)
}

#' Print a warning for observations with invalid or non-convertible units
#'
#' This helper function prints a formatted warning message when entries
#' in an observation table (`invalid_obs`) contain invalid or non-convertible
#' measurement units.
#' For each affected observation, the `code`, `value`, and `unit` are displayed.
#'
#' @param invalid_obs `data.table` or `data.frame`
#'   A table containing the columns `code`, `value`, and `unit`, representing
#'   observations with invalid or non-convertible units.
#'
#' @details
#' If `invalid_obs` is empty (i.e., `nrow(invalid_obs) == 0`), no warning
#' message is printed.
#' Otherwise, a multi-line warning is issued using
#' [`etlutils::catWarningMessage()`], listing all affected observations.
#'
#' @return
#' Invisibly returns `NULL`.
#' The function is called for its side effect — printing a warning message
#' to the console.
catInvalidObservationsWarning <- function(invalid_obs) {
  if (nrow(invalid_obs)) {
    # --- Create unique identifier for each (code, value, unit) combination ---
    invalid_obs_unique <- unique(
      invalid_obs[, .(code, value, unit)]
    )

    # --- Build message details ---
    details <- character(nrow(invalid_obs_unique))
    for (i in seq_len(nrow(invalid_obs_unique))) {
      details[i] <- paste0(
        "  code=", invalid_obs_unique$code[i],
        ", value=", invalid_obs_unique$value[i],
        ", unit=", invalid_obs_unique$unit[i]
      )
    }

    # --- Emit a single combined warning message ---
    etlutils::catWarningMessage(
      paste0(
        "The following observations have an invalid or not convertible unit and will be ignored:\n",
        paste(details, collapse = "\n")
      )
    )
  }
}

#' Generate a formatted description of matched laboratory observations
#'
#' This function takes a data.table of observations and a logical match vector,
#' filters the matching rows, and generates a grouped description by reference
#' range and unit. Each group is formatted with its reference range and all
#' corresponding observation values, including timestamps.
#'
#' @param obs A data.table containing observation data with columns:
#'   \code{code}, \code{value}, \code{unit}, \code{start_datetime},
#'   \code{reference_range_low_value}, and \code{reference_range_high_value}.
#' @param match_found A logical vector indicating which rows of \code{obs}
#'   matched a certain condition (e.g., a threshold).
#' @param loinc_mapping_table A data.table mapping LOINC codes to descriptive names.
#'   Must include columns \code{LOINC} and \code{GERMAN_NAME_LOINC_PRIMARY}.
#'
#' @return A character string containing a formatted summary of matched observations,
#'   grouped by reference range and unit.
generateMatchDescriptionReferenceCutoff <- function(obs, match_found, loinc_mapping_table) {

  # Filter matched observations and extract relevant columns
  matched_obs <- data.table::data.table(
    matched_values = obs$converted_value[match_found],
    matched_code = obs$code[match_found],
    matched_unit = obs$converted_unit[match_found],
    matched_start_datetime = obs$start_datetime[match_found],
    matched_reference_range_low = obs$reference_range_low_value[match_found],
    matched_reference_range_high = obs$reference_range_high_value[match_found]
  )

  if (nrow(matched_obs) == 0) {
    return("No matching observations found.\n")
  }

  # Group by reference range and unit, and build formatted text per group
  obs_values_by_reference_range <- matched_obs[
    ,
    {
      # Extract unique reference range values and unit for this group
      ref_low  <- unique(matched_reference_range_low)
      ref_high <- unique(matched_reference_range_high)
      unit     <- unique(matched_unit)
      # Create one formatted line per observation
      value_lines <- sprintf(
        "    %s %s (%s)",
        matched_values,
        matched_unit,
        format(matched_start_datetime, "%Y-%m-%d %H:%M:%S")
      )
      # Combine all lines for the group
      group_text <- paste0(
        sprintf(
          "Referenzbereich: %s - %s %s\n    ",
          ref_low, ref_high, unit
        ),
        trimws(paste(value_lines, collapse = "\n"))
      )
      .(text = group_text)
    },
    by = .(matched_reference_range_low, matched_reference_range_high, matched_unit)
  ][, paste(text, collapse = "\n")]

  # Add LOINC description (names and codes)
  loinc_description <- loinc_mapping_table[
    LOINC %in% matched_obs$matched_code,
    unique(GERMAN_NAME_LOINC_PRIMARY)
  ]

  loinc_description <- paste(loinc_description, collapse = ", ")

  # Combine everything into a final description text
  match_description <- paste0(
    " (", loinc_description, " (",
    paste(unique(matched_obs$matched_code), collapse = ", "),
    "))\n",
    obs_values_by_reference_range,
    "\n"
  )

  return(match_description)
}

#' Generate a textual description of LOINC observations and matching threshold values
#'
#' This function builds a formatted description string summarizing all observation
#' values from a given data.table (`obs`), grouped by LOINC code. It includes
#' each observation’s original and converted values, associated units, timestamps,
#' and links them to a primary LOINC threshold.
#'
#' @param obs A data.table containing observation data. Must include columns:
#'   \code{code}, \code{value}, \code{unit}, \code{converted_value}, \code{start_datetime}.
#' @param loinc_mapping_table A data.table mapping LOINC codes to their German names.
#'   Must include columns \code{LOINC} and \code{GERMAN_NAME_LOINC_PRIMARY}.
#' @param primary_loinc The primary LOINC code (character) used as the reference.
#' @param cutoff_absolute Numeric value indicating the threshold or cutoff value.
#' @param cutoff_unit Character string specifying the unit of the cutoff value.
#'
#' @return A formatted character string describing all LOINC observations and their
#'   corresponding values relative to the specified cutoff.
generateMatchDescriptionAbsoluteCutoff <- function(obs, loinc_mapping_table, primary_loinc, cutoff_absolute, cutoff_unit) {
  # Build description entries for each LOINC code
  desc_list <- obs[, {
    loinc_name <- loinc_mapping_table[LOINC %in% code, GERMAN_NAME_LOINC_PRIMARY]

    converted_text <- ifelse(
      as.character(converted_value) != as.character(value),
      paste0(" (", converted_value, " ", cutoff_unit, ")"),
      ""
    )
    lines <- sprintf(
      "%s %s %s%s   (%s)",
      ifelse(seq_len(.N) == 1, "  ", " "),
      value, unit,
      converted_text,
      format(start_datetime, "%Y-%m-%d %H:%M:%S")
    )
    entry <- paste0(
      "\n (", loinc_name, ") ", cutoff_absolute, " ", cutoff_unit, ":\n",
      paste(lines, collapse = "\n ")
    )
    list(text = entry)
  }, by = code]

  # Combine all entries into one final formatted text block
  full_text <- paste0(paste(desc_list$text, collapse = "\n"), "\n")

  return(full_text)
}

#' Split Drug-Disease MRP Table into Lookup Structures
#'
#' Takes a full Drug-Disease MRP table and splits it into multiple lookup tables
#' to support efficient MRP evaluation. Splitting is done by relevant rule keys such as:
#' ATC codes, ICD codes, and proxy definitions (ATC and OPS).
#'
#' @param drug_disease# The complete MRP definition table for Drug-Disease interactions as a \code{data.table}.
#'
#' @return A list of named \code{data.table} lookup structures:
#' \describe{
#'   \item{by_atc}{Split by \code{ATC_FOR_CALCULATION}, used for direct ATC code matching.}
#'   \item{by_icd}{Split by \code{ICD}, used to match ICD codes from conditions.}
#'   \item{by_atc_proxy}{Split by \code{ICD_PROXY_ATC}, used for proxy rules based on medication.}
#'   \item{by_ops_proxy}{Split by \code{ICD_PROXY_OPS}, used for proxy rules based on procedures.}
#' }
#'
getSplittedMRPTablesDrugDisease <- function(mrp_pair_list) {

  # ensure the optional columns for the proxy validity days are present in the pair list table
  mrp_pair_list[, ICD_PROXY_ATC_VALIDITY_DAYS := if (!"ICD_PROXY_ATC_VALIDITY_DAYS" %in% names(mrp_pair_list)) NA_character_ else ICD_PROXY_ATC_VALIDITY_DAYS]
  mrp_pair_list[, ICD_PROXY_OPS_VALIDITY_DAYS := if (!"ICD_PROXY_OPS_VALIDITY_DAYS" %in% names(mrp_pair_list)) NA_character_ else ICD_PROXY_OPS_VALIDITY_DAYS]
  mrp_pair_list[, LOINC_VALIDITY_DAYS := if (!"LOINC_VALIDITY_DAYS" %in% names(mrp_pair_list)) NA_character_ else LOINC_VALIDITY_DAYS]

  splitted <- list(
    by_atc = etlutils::splitTableToList(mrp_pair_list, "ATC_FOR_CALCULATION", rm.na = TRUE),
    by_icd = etlutils::splitTableToList(mrp_pair_list, "ICD", rm.na = TRUE),
    by_atc_proxy = etlutils::splitTableToList(mrp_pair_list, "ICD_PROXY_ATC", rm.na = TRUE),
    by_ops_proxy = etlutils::splitTableToList(mrp_pair_list, "ICD_PROXY_OPS", rm.na = TRUE),
    by_loinc_proxy = etlutils::splitTableToList(mrp_pair_list, "LOINC_PRIMARY_PROXY", rm.na = TRUE)
  )

  splitted$by_atc_proxy   <- etlutils::renameColsInLists(splitted$by_atc_proxy,   c("ICD_PROXY_ATC",       "ICD_PROXY_ATC_VALIDITY_DAYS"), c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))
  splitted$by_ops_proxy   <- etlutils::renameColsInLists(splitted$by_ops_proxy,   c("ICD_PROXY_OPS",       "ICD_PROXY_OPS_VALIDITY_DAYS"), c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))
  splitted$by_loinc_proxy <- etlutils::renameColsInLists(splitted$by_loinc_proxy, c("LOINC_PRIMARY_PROXY", "LOINC_VALIDITY_DAYS"),         c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))

  return(splitted)
}

#' Calculate Drug-Disease Medication-Related Problems (MRPs)
#'
#' Detects MRPs by evaluating combinations of medications (ATC codes) and diseases (ICD codes).
#' If direct ICD matches are not found for an ATC, proxy rules are applied using medication
#' and procedure history to infer possible conditions.
#'
#' @param active_atcs A \code{data.table} of the patient's active medications (e.g. FHIR MedicationRequest).
#' @param mrp_pair_list MRP-Pair list to create a list of lookup tables created by \code{getSplittedMRPTablesDrugDisease()}.
#' @param resources A named list of all FHIR resource tables relevant to the encounter (conditions, medications, procedures, etc.).
#' @param patient_id A character string representing the internal patient ID.
#' @param meda_datetime A POSIXct timestamp representing the time of medication evaluation.
#'
#' @return A \code{data.table} containing matched Drug-Disease MRPs, including both direct and proxy-based findings.
#'
calculateMRPsDrugDisease <- function(active_atcs, mrp_pair_list, resources, patient_id, meda_datetime) {
  loinc_mapping_table <- getLOINCMapping()$processed_content
  match_atc_and_icd_codes <- data.table::data.table()
  splitted_mrp_tables <- getSplittedMRPTablesDrugDisease(mrp_pair_list)
  # Match ATC-codes between encounter data and MRP definitions
  match_atc_codes <- matchATCCodes(active_atcs, splitted_mrp_tables$by_atc)
  # Get and match ICD-codes of the patient
  if (nrow(match_atc_codes)) {
    # Get relevant conditions
    relevant_conditions <- getRelevantConditions(resources$conditions, patient_id, meda_datetime)
    # Match ICD codes against MRP definitions and ATC codes
    match_atc_and_icd_codes <- matchICDCodes(
      relevant_conditions = relevant_conditions,
      drug_disease_mrp_tables_by_icd = splitted_mrp_tables$by_icd,
      match_atc_codes = match_atc_codes,
      meda_datetime = meda_datetime,
      patient_id = patient_id
    )
    # check ATC and OPS Proxys for ICDs
    patient_ref <- paste0("Patient/", patient_id)
    match_icd_proxies <- matchICDProxies(
      medication_resources = list(
        medication_requests = resources$medication_requests[medreq_patient_ref %in% patient_ref],
        medication_statements = resources$medication_statements[medstat_patient_ref %in% patient_ref],
        medication_administrations = resources$medication_administrations[medadm_patient_ref %in% patient_ref]
      ),
      procedure_resources = resources$procedures[proc_patient_ref %in% patient_ref],
      observation_resources = resources$observations[obs_patient_ref %in% patient_ref],
      drug_disease_mrp_tables_by_atc_proxy = splitted_mrp_tables$by_atc_proxy,
      drug_disease_mrp_tables_by_ops_proxy = splitted_mrp_tables$by_ops_proxy,
      drug_disease_mrp_tables_by_loinc_proxy = splitted_mrp_tables$by_loinc_proxy,
      meda_datetime = meda_datetime,
      match_atc_codes = match_atc_codes,
      loinc_mapping_table = loinc_mapping_table,
      loinc_matching_function = matchLOINCCutoff
    )
    if (nrow(match_icd_proxies)) {
      match_atc_and_icd_codes <- rbind(match_atc_and_icd_codes, match_icd_proxies, fill = TRUE)
    }
  }
  return(match_atc_and_icd_codes)
}
