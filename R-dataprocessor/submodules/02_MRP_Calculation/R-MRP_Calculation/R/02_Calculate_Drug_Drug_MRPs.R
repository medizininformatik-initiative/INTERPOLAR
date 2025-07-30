#' Get Column Names for Drug-Drug MRP Pair List
#'
#' Returns a named character vector of relevant column names used in the
#' Drug-Drug medication-related problem (MRP) pair list.
#' These columns define the structure of the MRP rule table.
#'
#' @return A named character vector of column names relevant to Drug-Drug MRP definitions.
getPairListColumnNamesDrugDrug <- function() {
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
cleanAndExpandDefinitionDrugDrug <- function(drug_drug_mrp_definition, mrp_type) {

  # Remove not nesessary columns
  mrp_columnnames <- getPairListColumnNames(mrp_type)
  drug_drug_mrp_definition <- drug_drug_mrp_definition[,  ..mrp_columnnames]

  code_column_names <- c("ATC_PRIMARY", "ATC2_PRIMARY")
  drug_drug_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_drug_mrp_definition, code_column_names)

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
  matchATCandATC2Codes(active_requests, splitted_mrp_tables$by_atc)
}
