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
#'
#' @export
processExcelContentDrugNiereninsuffizienz <- function(drug_niereninsuffizienz_mrp_definition, mrp_type) {

  # Remove not nesessary columns
  mrp_columnnames <- getRelevantColumnNames(mrp_type)
  drug_niereninsuffizienz_mrp_definition <- drug_niereninsuffizienz_mrp_definition[,  ..mrp_columnnames]

  code_column_names <- names(drug_niereninsuffizienz_mrp_definition)[
    (grepl("LOINC|ATC", names(drug_niereninsuffizienz_mrp_definition))) &
      !grepl("DISPLAY|INCLUSION|VALIDITY_DAYS|CUTOFF", names(drug_niereninsuffizienz_mrp_definition))
  ]
  #code_column_names <- c("ATC_PRIMARY", "LOINC_PRIMARY", "LOINC_PROXY_ICD")
  drug_niereninsuffizienz_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_niereninsuffizienz_mrp_definition, code_column_names)

  # ICD column:
  # remove white spaces around plus signs
  etlutils::replacePatternsInColumn(drug_niereninsuffizienz_mrp_definition, 'LOINC_PROXY_ICD', '\\s*\\+\\s*', '+')
  # replace all invalid chars in the ICD codes by a simple whitespace -> can be trimmed and splitted
  drug_niereninsuffizienz_mrp_definition[, LOINC_PROXY_ICD := sapply(LOINC_PROXY_ICD, function(text) gsub('[^0-9A-Za-z. +]', '', text))]

  computeATCForCalculation(
    data_table = drug_niereninsuffizienz_mrp_definition,
    primary_col = "ATC_PRIMARY",
    inclusion_col = "ATC_INCLUSION",
    output_col = "ATC_FOR_CALCULATION",
    secondary_cols = c("ATC_SYSTEMIC_SY", "ATC_DERMATIKA_D", "ATC_OPHTHALMIKA_O", "ATC_INHALANDA_I", "ATC_SONSTIGE_SO")
  )

  code_column_names <- c(code_column_names[!startsWith(code_column_names, "ATC")], "ATC_FOR_CALCULATION")
  # SPLIT and TRIM: ICD and proxy column:
  # split the whitespace separated lists in ICD and proxy columns in a single row per code
  drug_niereninsuffizienz_mrp_definition <- etlutils::splitColumnsToRows(drug_niereninsuffizienz_mrp_definition, code_column_names)
  # trim all values in the whole table
  etlutils::trimTableValues(drug_niereninsuffizienz_mrp_definition)
  # ICD column: remove tailing points from ICD codes
  etlutils::replacePatternsInColumn(drug_niereninsuffizienz_mrp_definition, 'ICD', '\\.$', '')
  # After the replacing of special signs with an empty string their can be new empty rows in this both columns
  drug_niereninsuffizienz_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_niereninsuffizienz_mrp_definition, code_column_names)
  # Remove duplicate rows
  drug_niereninsuffizienz_mrp_definition <- unique(drug_niereninsuffizienz_mrp_definition)

  # Clean rows with NA or empty values in relevant columns
  for (col in code_column_names) {
    drug_niereninsuffizienz_mrp_definition[[col]] <- ifelse(
      is.na(drug_niereninsuffizienz_mrp_definition[[col]]) |
        !nzchar(trimws(drug_niereninsuffizienz_mrp_definition[[col]])),
      NA_character_,
      drug_niereninsuffizienz_mrp_definition[[col]]
    )
  }

  # check column ATC and ATC_PROXY for correct ATC codes
  invalid_atcs <- etlutils::getInvalidCodes(drug_niereninsuffizienz_mrp_definition, "ATC_FOR_CALCULATION", etlutils::isATC)
  # check column LOINC_PROXY for correct LOINC codes
  invalid_loincs <- etlutils::getInvalidCodes(drug_niereninsuffizienz_mrp_definition, "LOINC_PRIMARY", etlutils::isLOINC)

  error_messages <- c(
    formatCodeErrors(invalid_atcs, "ATC"),
    formatCodeErrors(invalid_loincs, "LOINC")
  )

  if (length(error_messages) > 0) {
    stop(paste(error_messages, collapse = "\n"))
  }

  # Apply the function to the 'ICD' column
  drug_niereninsuffizienz_mrp_definition$LOINC_PROXY_ICD <- expandAndConcatenateICDs(drug_niereninsuffizienz_mrp_definition$LOINC_PROXY_ICD)
  # Split concatenated ICD codes into separate rows
  drug_niereninsuffizienz_mrp_definition <- etlutils::splitColumnsToRows(drug_niereninsuffizienz_mrp_definition, "LOINC_PROXY_ICD")
  # Remove duplicate rows
  drug_niereninsuffizienz_mrp_definition <- unique(drug_niereninsuffizienz_mrp_definition)

  return(drug_niereninsuffizienz_mrp_definition)
}
