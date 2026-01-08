#' Get Column Names for Drug-Niereninsuffizienz MRP Pair List
#'
#' Returns a named character vector of relevant column names used in the
#' Drug-Niereninsuffizienz medication-related problem (MRP) pair list.
#' These columns define the structure of the MRP rule table.
#'
#' @return A named character vector of column names relevant to Drug-Niereninsuffizienz MRP definitions.
getRelevantColumnNamesDrugNiereninsuffizienz <- function() {
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
    "LOINC_PRIMARY_PROXY",
    "LOINC_UNIT",
    "LOINC_DISPLAY",
    "LOINC_CUTOFF_REFERENCE",
    "LOINC_CUTOFF_ABSOLUTE"#,
    #"ursprünglicher Grenzwert (hart)"
  )
}

#' Get Category Display Name for Drug-Niereninsuffizienz MRPs
#'
#' Returns the display label for the MRP category "Drug-Niereninsuffizienz", used for
#' tagging or labeling MRPs in evaluation outputs.
#'
#' @return A character string: \code{"Drug-Niereninsuffizienz"}
getCategoryDisplayDrugNiereninsuffizienz <- function() {"Drug-Niereninsuffizienz"}

#' Clean and Expand Drug_Niereninsuffizienz_MRP Definition Table
#'
#' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#' splitting and trimming values, and expanding concatenated ICD codes.
#'
#' @param drug_drug_mrp_definition A data.table containing the MRP definition table.
#' @param mrp_type A character string representing the base name of the MRP definition (e.g., `"Drug_Disease"`).
#'
#' @return A cleaned and expanded data.table containing the MRP definition table.
processExcelContentDrugNiereninsuffizienz <- function(drug_niereninsuffizienz_mrp_definition, mrp_type) {

  drug_niereninsuffizienz_mrp_definition <- processExcelContentDrugCondition(drug_niereninsuffizienz_mrp_definition, mrp_type)

  return(drug_niereninsuffizienz_mrp_definition)
}

#' Split Drug-Niereninsuffizienz MRP Table into Lookup Structures
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
#'   \item{by_loinc_proxy}{Split by \code{ICD_PROXY_ATC}, used for proxy rules based on medication.}
#' }
#'
getSplittedMRPTablesDrugNiereninsuffizienz <- function(mrp_pair_list) {

  mrp_pair_list[, LOINC_VALIDITY_DAYS := if (!"LOINC_VALIDITY_DAYS" %in% names(mrp_pair_list)) NA_character_ else LOINC_VALIDITY_DAYS]

  splitted <- list(
    by_atc = etlutils::splitTableToList(mrp_pair_list, "ATC_FOR_CALCULATION", rm.na = TRUE),
    by_icd = etlutils::splitTableToList(mrp_pair_list, "ICD", rm.na = TRUE),
    by_loinc_proxy = etlutils::splitTableToList(mrp_pair_list, "LOINC_PRIMARY_PROXY", rm.na = TRUE)
  )

  splitted$by_loinc_proxy <- etlutils::renameColsInLists(splitted$by_loinc_proxy, c("LOINC_PRIMARY_PROXY", "LOINC_VALIDITY_DAYS"), c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))

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
calculateMRPsDrugNiereninsuffizienz <- function(active_atcs, mrp_pair_list, resources, patient_id, meda_datetime) {
  loinc_mapping_table <- getLOINCMapping()$processed_content
  match_atc_and_icd_codes <- data.table::data.table()
  splitted_mrp_tables <- getSplittedMRPTablesDrugNiereninsuffizienz(mrp_pair_list)
  # Match ATC-codes between encounter data and MRP definitions
  match_atc_codes <- matchATCCodes(active_atcs, splitted_mrp_tables$by_atc)
  # Get and match ICD-codes of the patient
  if (nrow(match_atc_codes)) {
    # Get relevant conditions
    relevant_conditions <- getRelevantConditions(resources$conditions, patient_id, meda_datetime)
    # Match ICD codes against MRP definitions and ATC codes
    match_atc_and_icd_codes <- matchICDCodes(
      relevant_conditions = relevant_conditions,
      mrp_tables_by_icd = splitted_mrp_tables$by_icd,
      match_atc_codes = match_atc_codes,
      meda_datetime = meda_datetime,
      patient_id = patient_id
    )
    # check ATC and OPS Proxys for ICDs
    patient_ref <- paste0("Patient/", patient_id)
    match_icd_proxies <- matchICDProxies(
      observation_resources = resources$observations[obs_patient_ref %in% patient_ref],
      drug_condition_mrp_tables_by_loinc_proxy = splitted_mrp_tables$by_loinc_proxy,
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
