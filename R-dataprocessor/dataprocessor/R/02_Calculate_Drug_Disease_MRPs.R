calculateDrugDiseaseMRPs <- function() {

  # clean and expand table
  cleanAndExpandDefinition <- function(drug_disease_mrp_definition) {

    # remove table without the needed column names
    columnnames <- c('ATC_WIRKSTOFF', 'Mit.ICD-10.codierbar', 'Mit.Drug.codierbar')

    if (!all(columnnames %in% names(drug_disease_mrp_definition))) {
      drug_disease_mrp_definition <- etlutils::removeTableHeader(drug_disease_mrp_definition, columnnames)
      if (!etlutils::isValidTable(drug_disease_mrp_definition)) {
        stop("drug_disease_mrp_definition table has invalid structure")
      }
    }
    # remove all unnecessary columns
    drug_disease_mrp_definition <- etlutils::retainColumns(drug_disease_mrp_definition, columnnames)
    # rename the columns
    new_columnnames <- c('ATC', 'ICD', 'ATC_FOR_ICD')
    for (i in seq_along(columnnames)) {
      old_col <- columnnames[i]
      new_col <- new_columnnames[i]
      if (old_col %in% names(drug_disease_mrp_definition)) {
        data.table::setnames(drug_disease_mrp_definition, old_col, new_col)
      }
    }
    # remove rows with empty ICD code and empty ATC_FOR_ICD codes
    drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, c('ICD', 'ATC_FOR_ICD'))
    # check column ATC for length 7
    if (sum(nchar(drug_disease_mrp_definition$ATC) != 7)) {
      warning("There are rows in column ATC in drug_disease_mrp_definition with more or less 7 digits. Please Check!")
    }

    # ICD column:
    # remove white spaces around plus signs
    etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\s*\\+\\s*', '+')
    # replace all invalid chars in the ICD codes by a simple whitespace -> can be trimmed and splitted
    # (lapply changes the type of the column to list. sapply leaves the type of the column to character.)
    drug_disease_mrp_definition[, ICD := sapply(ICD, function(text) gsub('[^0-9A-Za-z. +]', '', text))]

    # SPLIT and TRIM: ICD and ATC_FOR_ICD column:
    # split the whitespace separated lists in ICD column in a single row per ICD code
    drug_disease_mrp_definition <- etlutils::splitColumnToRows(drug_disease_mrp_definition, 'ICD')
    # split the whitespace separated lists in ATC_FOR_ICD column in a single row per ATC code
    drug_disease_mrp_definition <- etlutils::splitColumnToRows(drug_disease_mrp_definition, 'ATC_FOR_ICD')
    # trim all values in the whole table
    etlutils::trimTableValues(drug_disease_mrp_definition)

    # ICD column: remove tailing points from ICD codes
    etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\.$', '')

    # Remove rows with empty ICD code and empty ATC_FOR_ICD codes again.
    # After the replacing of special signs with an empty string their can be new empty rows in this both columns
    drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, c('ICD', 'ATC_FOR_ICD'))

    # Remove duplicate rows
    drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)

    # This loop Expand and concatenate ICD codes. If there are multiple
    # ICD codes separated by "+", each code is expanded separately, and combinations of expanded codes are concatenated.
    # ICD Codes must be have at least 3 digits.
    for (j in seq_len(nrow(drug_disease_mrp_definition))) {
      # Extract and split ICD codes, if there is a '+'
      icd <- drug_disease_mrp_definition$ICD[j]
      input_icds <- unlist(strsplit(icd, '\\+'))

      # Check if there is only one ICD code
      if (length(input_icds) == 1 && !is.na(input_icds)) {
        # Expand and concatenate ICD code
        icds <- paste(etlutils::interpolar_expandICDs(input_icds), collapse = ' ')
      }
      if (length(input_icds) > 1) {
        # Expand each ICD code separately and concatenate combinations
        icd_1 <- etlutils::interpolar_expandICDs(input_icds[[1]])
        icd_2 <- etlutils::interpolar_expandICDs(input_icds[[2]])
        icds <- ''
        for (r in 1:length(icd_1)) {
          icds <- paste0(icds, paste(icd_1[r], icd_2, sep = '+'), ' ')
        }
        icds <- trimws(paste0(icds, collapse = ''))
      }
      if (all(is.na(input_icds)) || length(input_icds) == 0) {
        icds <- NA_character_
      }
      # Assign the concatenated ICD codes back to the column 'ICD'
      drug_disease_mrp_definition$ICD[j] <- icds
    }
    # Split concatenated ICD codes into separate rows
    drug_disease_mrp_definition <- etlutils::splitColumnToRows(drug_disease_mrp_definition, "ICD")

    # Remove duplicate rows
    drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)

    return(drug_disease_mrp_definition)
  }

  # Check if drug_disease_mrp_definition must be expanded
  # set must_expand to FALSE
  must_expand <- FALSE
  # load file info for drug-disease-mrp excel
  file_info_drug_disease_mrp_definition <- file.info(readExcelFilePath(MRP_DEFINITION_FILE_DRUG_DISEASE))
  # check if .RData files not exists or modification time is not equal -> set must_expand to TRUE
  if (!etlutils::existsLocalRdataFile("mrp_definition_file_status") || !etlutils::existsLocalRdataFile("drug_disease_mrp_definition_expanded")) {
    must_expand <- TRUE
    mrp_definition_file_status <- list()
  } else {
    mrp_definition_file_status <- etlutils::polar_read_rdata("mrp_definition_file_status")
    drug_disease_last_update <- mrp_definition_file_status[["drug_disease_last_update"]]
    if (is.null(drug_disease_last_update) || file_info_drug_disease_mrp_definition$mtime != drug_disease_last_update) {
      must_expand <- TRUE
    }
  }
  if (must_expand) {
    # read drug-disease-mrp excel as table list
    drug_disease_mrp_definition <- readExcelFileAsTableListFromExtData(MRP_DEFINITION_FILE_DRUG_DISEASE)[["Drug_Disease_Pairs"]]
    # clean and expand table list
    drug_disease_mrp_definition_expanded <- cleanAndExpandDefinition(drug_disease_mrp_definition)
    polar_write_rdata(drug_disease_mrp_definition_expanded)
    # set modification date of drug-disease-mrp excel file to new list with drug_disease_last_update
    mrp_definition_file_status[["drug_disease_last_update"]] <- file_info_drug_disease_mrp_definition$mtime
    polar_write_rdata(mrp_definition_file_status)
  }
  if (!exists("drug_disease_mrp_definition_expanded")) {
    drug_disease_mrp_definition_expanded <- etlutils::polar_read_rdata("drug_disease_mrp_definition_expanded")
  }
}
