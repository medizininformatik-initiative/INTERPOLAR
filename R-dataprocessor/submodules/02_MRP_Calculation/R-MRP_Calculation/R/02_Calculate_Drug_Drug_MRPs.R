#' Get Column Names for Drug-Drug MRP Pair List
#'
#' Returns a named character vector of relevant column names used in the
#' Drug-Drug medication-related problem (MRP) pair list.
#' These columns define the structure of the MRP rule table.
#'
#' @return A named character vector of column names relevant to Drug-Drug MRP definitions.
getRelevantColumnNamesDrugDrug <- function() {
  etlutils::namedVectorByValue(
    "ATC_DISPLAY",
    #"SMPC_NAME",
    #"SMPC_VERSION",
    "ATC_PRIMARY",
    "ATC_SYSTEMIC_SY",
    "ATC_DERMATIKA_D",
    "ATC_OPHTHALMIKA_O",
    "ATC_INHALANDA_I",
    "ATC_SONSTIGE_SO",
    "ATC_INCLUSION",
    #"DRUG_DRUG_KI",
    "ATC2_DISPLAY",
    "ATC2_PRIMARY",
    "ATC2_SYSTEMIC_SY",
    "ATC2_DERMATIKA_D",
    "ATC2_OPHTHALMIKA_O",
    "ATC2_INHALANDA_I",
    "ATC2_SONSTIGE_SO",
    "ATC2_INCLUSION")
}

#' Get Category Display Name for Drug-Drug MRPs
#'
#' Returns the display label for the MRP category "Drug-Drug", used for
#' tagging or labeling MRPs in evaluation outputs.
#'
#' @return A character string: \code{"Drug-Drug"}
getCategoryDisplayDrugDrug <- function() {"Drug-Drug"}

#' Clean and Expand Drug_Drug_MRP Definition Table
#'
#' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#' splitting and trimming values, and expanding concatenated ICD codes.
#'
#' @param drug_drug_mrp_definition A data.table containing the MRP definition table.
#' @param mrp_type A character string representing the base name of the MRP definition (e.g., `"Drug_Disease"`).
#'
#' @return A cleaned and expanded data.table containing the MRP definition table.
#'
#' @export
processExcelContentDrugDrug <- function(drug_drug_mrp_definition, mrp_type) {

  # Remove not nesessary columns
  mrp_columnnames <- getRelevantColumnNames(mrp_type)
  drug_drug_mrp_definition <- drug_drug_mrp_definition[,  ..mrp_columnnames]

  code_column_names <- c("ATC_PRIMARY", "ATC2_PRIMARY")
  drug_drug_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_drug_mrp_definition, code_column_names)

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

  code_column_names <- c("ATC_FOR_CALCULATION", "ATC2_FOR_CALCULATION")

  # SPLIT and TRIM: ICD and proxy column:
  # split the whitespace separated lists in ICD and proxy columns in a single row per code
  drug_drug_mrp_definition <- etlutils::splitColumnsToRows(drug_drug_mrp_definition, code_column_names)
  # trim all values in the whole table
  etlutils::trimTableValues(drug_drug_mrp_definition)
  # After the replacing of special signs with an empty string their can be new empty rows in this both columns
  drug_drug_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_drug_mrp_definition, code_column_names)

  # Remove duplicate rows
  drug_drug_mrp_definition <- unique(drug_drug_mrp_definition)

  # Clean rows with NA or empty values in relevant columns
  for (col in code_column_names) {
    drug_drug_mrp_definition[[col]] <- ifelse(
      is.na(drug_drug_mrp_definition[[col]]) |
        !nzchar(trimws(drug_drug_mrp_definition[[col]])),
      NA_character_,
      drug_drug_mrp_definition[[col]]
    )
  }

  # check column ATC_PRIMARY and ATC2_PRIMARY for correct ATC codes
  invalid_atcs <- etlutils::getInvalidCodes(drug_drug_mrp_definition, code_column_names, etlutils::isATC)
  error_messages <- formatCodeErrors(invalid_atcs, "ATC")

  if (length(error_messages) > 0) {
    stop(paste(error_messages, collapse = "\n"))
  }

  # Remove rows where ATC_PRIMARY and ATC2_PRIMARY are the same
  drug_drug_mrp_definition <- drug_drug_mrp_definition[
    get(code_column_names[1]) != get(code_column_names[2])
  ]

  return(drug_drug_mrp_definition)
}

#' Split Drug-Drug MRP Table into Lookup Structures
#'
#' Takes a full Drug-Drug MRP table and splits it into a list of lookup tables
#' for more efficient evaluation during MRP calculation. Currently, the table is split
#' by the column \code{ATC_FOR_CALCULATION}, enabling fast matching during runtime.
#'
#' @param drug_drug_mrp_tables A named list containing the key \code{processed_content}, which holds
#'   the full MRP definition table for Drug-Drug interactions as a \code{data.table}.
#'
#' @return A list with named elements containing split tables. Specifically:
#' \describe{
#'   \item{by_atc}{A list of data.tables indexed by \code{ATC_FOR_CALCULATION}.}
#' }
#'
getSplittedMRPTablesDrugDrug <- function(drug_drug_mrp_tables) {
  drug_drug_mrp_table_content <- drug_drug_mrp_tables$processed_content
  list(
    # Split drug_drug_mrp_tables by ATC
    by_atc = etlutils::splitTableToList(drug_drug_mrp_table_content, "ATC_FOR_CALCULATION")
  )
}

#' Calculate Drug-Drug Medication-Related Problems (MRPs)
#'
#' Evaluates potential drug-drug interactions based on a patient's active
#' \code{MedicationRequest} resources. For each medication, it checks against
#' predefined interaction rules indexed by \code{ATC_FOR_CALCULATION}.
#'
#' @param active_requests A \code{data.table} of active medications for the encounter,
#'   expected to contain ATC codes.
#' @param splitted_mrp_tables A list of split MRP tables as returned by \code{getSplittedMRPTablesDrugDrug()}.
#' @param resources A list of all patient-related FHIR resources (not used here, but required by interface).
#' @param patient_id The internal patient ID (not used here, but required by interface).
#' @param meda_datetime The datetime of medication analysis (not used here, but required by interface).
#'
#' @return A \code{data.table} with matched Drug-Drug MRP results. The format is
#'   compatible with downstream processing for MRP reporting and audit.
#'
calculateMRPsDrugDrug <- function(active_requests, splitted_mrp_tables, resources, patient_id, meda_datetime) { # don't remove the unused parameters!
  matchATCCodePairs(active_requests, splitted_mrp_tables$by_atc)
}
