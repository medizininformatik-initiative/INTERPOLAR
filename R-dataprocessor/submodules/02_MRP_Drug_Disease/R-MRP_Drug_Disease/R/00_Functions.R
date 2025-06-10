#' Clean and Expand Drug_Disease_MRP Definition Table
#'
#' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#' splitting and trimming values, and expanding concatenated ICD codes.
#'
#' @param drug_disease_mrp_definition A data.table containing the MRP definition table.
#'
#' @return A cleaned and expanded data.table containing the MRP definition table.
#'
#' @export
cleanAndExpandDefinitionDrugDisease <- function(drug_disease_mrp_definition) {

  # Remove not nesessary columns
  drug_disease_mrp_definition <- drug_disease_mrp_definition[, c("SMPC_NAME", "SMPC_VERSION") := NULL]

  # Remove rows with all empty code columns
  proxy_column_names <- names(drug_disease_mrp_definition)[
    (grepl("PROXY|ATC", names(drug_disease_mrp_definition))) &
      !grepl("DISPLAY|INCLUSION|VALIDITY_DAYS", names(drug_disease_mrp_definition))
  ]
  relevant_column_names <- c("ICD", proxy_column_names)
  drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, relevant_column_names)

  # ICD column:
  # remove white spaces around plus signs
  etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\s*\\+\\s*', '+')
  # replace all invalid chars in the ICD codes by a simple whitespace -> can be trimmed and splitted
  drug_disease_mrp_definition[, ICD := sapply(ICD, function(text) gsub('[^0-9A-Za-z. +]', '', text))]

  # SPLIT and TRIM: ICD and proxy column:
  # split the whitespace separated lists in ICD and proxy columns in a single row per code
  drug_disease_mrp_definition <- etlutils::splitColumnsToRows(drug_disease_mrp_definition, relevant_column_names)
  # trim all values in the whole table
  etlutils::trimTableValues(drug_disease_mrp_definition)

  # ICD column: remove tailing points from ICD codes
  etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\.$', '')

  # remove rows with empty ICD code and empty proxy codes (ATC, LOINC, OPS) again.
  # After the replacing of special signs with an empty string their can be new empty rows in this both columns
  drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, relevant_column_names)

  # Remove duplicate rows
  drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)

  # Clean rows with NA or empty values in relevant columns
  for (col in relevant_column_names) {
    drug_disease_mrp_definition[[col]] <- ifelse(
      is.na(drug_disease_mrp_definition[[col]]) |
        !nzchar(trimws(drug_disease_mrp_definition[[col]])),
      NA_character_,
      drug_disease_mrp_definition[[col]]
    )
  }

  # check column ATC and ATC_PROXY for correct ATC codes
  atc_columns <- grep("ATC(?!.*(DISPLAY|INCLUSION|VALIDITY_DAYS))", names(drug_disease_mrp_definition), value = TRUE, perl = TRUE)
  atc_errors <- validateATCCodes(drug_disease_mrp_definition, atc_columns)

  # check column LOINC_PROXY for correct LOINC codes
  loinc_errors <- validateLOINCCodes(drug_disease_mrp_definition, "LOINC_PRIMARY_PROXY")

  error_messages <- c(
    formatCodeErrors(atc_errors, "ATC"),
    formatCodeErrors(loinc_errors, "LOINC")
  )

  if (length(error_messages) > 0) {
    stop(paste(error_messages, collapse = "\n"))
  }

  # Expand and concatenate ICD codes in a vectorized manner.
  # If there are multiple ICD codes separated by "+", each code is expanded separately, and
  # combinations of expanded codes are concatenated. ICD Codes must be have at least 3 digits.
  expandAndConcatenateICDs <- function(icd_column) {
    # Function to process a single ICD code
    processICD <- function(icd) {
      if (is.na(icd) || icd == "") {
        return(NA_character_)
      }
      if (!grepl("+", icd, fixed = TRUE)) {
        # Handle single ICD code case
        return(paste(etlutils::expandICDs(icd), collapse = ' '))

      }
      # Handle multiple ICD codes separated by '+'
      input_icds <- unlist(strsplit(icd, '\\+'))
      icd_1 <- etlutils::expandICDs(input_icds[[1]])
      icd_2 <- etlutils::expandICDs(input_icds[[2]])
      # Create combinations and concatenate
      combinations <- outer(icd_1, icd_2, paste, sep = '+')
      return(trimws(paste(c(combinations), collapse = ' ')))

    }
    # Apply the function to the entire column
    sapply(icd_column, processICD)
  }

  # Apply the function to the 'ICD' column
  drug_disease_mrp_definition$ICD <- expandAndConcatenateICDs(drug_disease_mrp_definition$ICD)

  # Split concatenated ICD codes into separate rows
  drug_disease_mrp_definition <- etlutils::splitColumnsToRows(drug_disease_mrp_definition, "ICD")

  # Remove duplicate rows
  drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)

  return(drug_disease_mrp_definition)
}
