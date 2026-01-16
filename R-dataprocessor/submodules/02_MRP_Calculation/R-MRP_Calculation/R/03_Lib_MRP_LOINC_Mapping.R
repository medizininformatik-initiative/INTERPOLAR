# Environment for caching
.loinc_mapping_env <- new.env()

#' Load LOINC Mapping Definition from Excel
#'
#' Retrieves and expands the LOINC mapping definition from the corresponding Excel file
#' using \code{getExpandedExcelContent}. This function is typically used in MRP pipelines
#' to load mapping data for LOINC codes.
#'
#' Internally wrapped in a level 3 logging block for structured ETL logging.
#'
#' @return A \code{data.frame} (or compatible object) containing the expanded LOINC mapping definition.
#'
getLOINCMapping <- function() {
  loinc_mapping <- .loinc_mapping_env[["LOINC_MAPPING"]]
  if (is.null(loinc_mapping)) {
    loinc_mapping <- getExpandedExcelContent("LOINC_Mapping")
    .loinc_mapping_env[["LOINC_MAPPING"]] <- loinc_mapping
  }
  return(loinc_mapping)
}

#' Get Relevant Column Names for LOINC Mapping Table
#'
#' This function returns a named vector of selected column names that are relevant
#' for processing or analyzing the \code{LOINC_Mapping} table.
#'
#' Only a curated subset of columns is included; many other columns commonly found in
#' LOINC mapping tables are excluded for simplicity or irrelevance to the current use case.
#'
#' @return A named character vector containing relevant column names for the LOINC mapping table.
#'
getRelevantColumnNamesLOINCMapping <- function() {
  etlutils::namedVectorByValue(
    #"SORT_NUM",
    "LOINC",
    "LOINC_PRIMARY",
    "COMPARABILITY_TO_LOINC_PRIMARY",
    #"COMMENT_COMPARABILITY",
    #"MII_TOP_300",
    "GERMAN_NAME_LOINC_PRIMARY",
    #"SEARCH_NAME",
    "UNIT",
    #"EXPECTED_VALUES_HEALTHY",
    "CONVERSION_FACTOR",
    "CONVERSION_UNIT"
    #"LONG_COMMON_NAME",
    #"in_IP_Mapping_since",
    #"EXAMPLE_UNITS",
    #"EXAMPLE_UCUM_UNITS",
    #"COMMON_TEST_RANK",
    #"ComMaps",
    #"ComInst",
    #"COMPONENT",
    #"PROPERTY",
    #"TIME_ASPCT",
    #"SYSTEM",
    #"SCALE_TYP",
    #"METHOD_TYP",
    #"CLASS",
    #"DefinitionDescription",
    #"STATUS",
    #"CLASSTYPE",
    #"FORMULA",
    #"EXMPL_ANSWERS",
    #"UNITSREQUIRED",
    #"RELATEDNAMES2",
    #"SHORTNAME",
    #"ORDER_OBS",
    #"COMMON_ORDER_RANK",
    #"COMMON_SI_TEST_RANK",
    #"PanelType",
    #"AssociatedObservations",
    #"DisplayName"
  )
}

#' Process Excel Content for LOINC Mapping
#'
#' This function processes the raw Excel content for the \code{LOINC_Mapping} table
#' by selecting only the relevant columns and filtering out rows without a valid
#' \code{LOINC_PRIMARY} value.
#'
#' @param processExcelContent A \code{data.table} containing the raw content of the Excel file.
#' @param table_name A \code{character} string specifying the table name (e.g., \code{"LOINC_Mapping"}).
#'
#' @return A cleaned \code{data.table} with only the relevant columns and valid entries.
#'
processExcelContentLOINCMapping <- function(processExcelContent, table_name) {
  # Remove not nesessary columns
  columnnames <- getRelevantColumnNames(table_name)
  processExcelContent <- processExcelContent[, ..columnnames]
  processExcelContent <- processExcelContent[!is.na(LOINC_PRIMARY) & trimws(LOINC_PRIMARY) != ""]

  # Filter for only the primary LOINC codes that are quantitativ
  processExcelContent <- processExcelContent[COMPARABILITY_TO_LOINC_PRIMARY == "1 - quantitativ"]

  return(processExcelContent)
}

