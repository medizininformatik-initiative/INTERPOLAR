#' Creates the full expanded Table Description and all Database Scripts.
#'
#' Expands the Table Description Definition Excel file of the FHIR resources to the
#' Table Description Excel file, which is the basis for the fhirckrackr to flatten
#' the FHIR resources into tables and is the basis for the database tables. In a
#' further step this funtion creates the full database scripts for this tables.
#'
#' @export
initTableDescriptionAndDatabaseScripts <- function() {
  expandTableDescription()
  createDatabaseScriptsFromTemplates()
}

#' Creates the full expanded Table Description but not the Database Scripts.
#'
#' Expands the Table Description Definition Excel file of the FHIR resources to the
#' Table Description Excel file, which is the basis for the fhirckrackr to flatten
#' the FHIR resources into tables and is the basis for the database tables.
#'
#' @export
initTableDescription <- function() {
  expandTableDescription()
}

#' Creates all Database Scrpts
#'
#' The prerequisite is that the Table_Description_Definition Excel file is available in the
#' 'inst/extdata' directory.
#'
#' @export
initDatabaseScripts <- function() {
  createDatabaseScriptsFromTemplates()
}

#' First 2 column names to identify a the beginning of the "real" content of the FHIR table description.
#' The first name in this vector must be the column with the resource/table names.
#'
#' This constant vector contains the first two column names used to identify a FHIR table description.
#'
#' @export
FHIR_TABLE_DESCRIPTION_COLNAMES <- c("RESOURCE", "COLUMN_NAME")

#' First 2 column names to identify a the beginning of the "real" content of the database table description.
#' The first name in this vector must be the column with the table names.
#'
#' This constant vector contains the first two column names used to identify a database table description.
#'
#' @export
DB_TABLE_DESCRIPTION_COLNAMES <- c("TABLE_NAME", "COLUMN_NAME")

#' Check if a table description is a FHIR table description
#'
#' This function checks if a given table description matches the expected FHIR table description format.
#'
#' @param table_description A data.table containing the table description to be checked.
#'
#' @return TRUE if the table description matches the FHIR table description format, otherwise FALSE.
#'
#' @examples
#' table_description <- data.table::data.table(
#'   RESOURCE = c("Patient", "Observation"),
#'   COLUMN_NAME = c("id", "status")
#' )
#' isFHIRTableDescription(table_description)
#' # Returns: TRUE
#'
#' @export
isFHIRTableDescription <- function(table_description) {
  etlutils::getFirstRowWithPatterns(table_description, FHIR_TABLE_DESCRIPTION_COLNAMES) >= 0
}

#' Check if a table description is a database table description
#'
#' This function checks if a given table description matches the expected database table description format.
#'
#' @param table_description A data.table containing the table description to be checked.
#'
#' @return TRUE if the table description matches the database table description format, otherwise FALSE.
#'
#' @examples
#' table_description <- data.table::data.table(
#'   TABLE_NAME = c("patients", "observations"),
#'   COLUMN_NAME = c("id", "status")
#' )
#' isDBTableDescription(table_description)
#' # Returns: TRUE
#'
#' @export
isDBTableDescription <- function(table_description) {
  etlutils::getFirstRowWithPatterns(table_description, DB_TABLE_DESCRIPTION_COLNAMES) >= 0
}

#' Load Table Description Excel File
#'
#' This function loads a table description excel file.
#'
#' @param table_description_path A character string specifying the path to the table description file.
#' If NA (default), it uses the file from the package's extdata directory.
#' @param table_description_sheet_name name of the sheet with the table description in the Excel file.
#' Default is "table_description".
#'
#' @return A data.table with table descriptions.
#'
loadTableDescriptionFile <- function(table_description_path = NA, table_description_sheet_name = "table_description") {
  if (etlutils::isSimpleNA(table_description_path)) {
    table_description_path <- system.file("extdata", "Table_Description.xlsx", package = "cds2db")
  }

  table_description <- etlutils::readExcelFileAsTableList(table_description_path)[[table_description_sheet_name]]
  if (isFHIRTableDescription(table_description)) {
    table_description_without_header <- try(etlutils::removeTableHeader(table_description, FHIR_TABLE_DESCRIPTION_COLNAMES), silent = TRUE)
  } else if (isDBTableDescription(table_description)) {
    table_description_without_header <- try(etlutils::removeTableHeader(table_description, DB_TABLE_DESCRIPTION_COLNAMES), silent = TRUE)
  }

  if (!exists("table_description_without_header") || etlutils::isError(table_description_without_header)) {
    stop("Invalid table description.\nFile: ", table_description_path, "\nSheet: ", table_description_sheet_name, "\n",
         "Can not find row with ", paste0(FHIR_TABLE_DESCRIPTION_COLNAMES, collapse = ", "), " or ",
         paste0(DB_TABLE_DESCRIPTION_COLNAMES, collapse = ", "), " in any colums.")
  }

  table_description <- table_description_without_header
  table_description <- etlutils::removeRowsWithNAorEmpty(table_description)
  return(table_description)
}

#' Get Table Description Split by Table Name
#'
#' This function loads a table description from an Excel file, removes rows that are fully NA, and splits
#' the table description by table names. The result is a list where each element is a subset of the table
#' description corresponding to a specific table name.
#'
#' @param table_description_path A character string specifying the path to the table description file.
#' If NA (default), it uses the file from the package's extdata directory.
#' @param table_description_sheet_name name of the sheet with the table description in the Excel file.
#' Default is "table_description".
#'
#' @return A list of data.tables, each containing the table description for a specific resource.
#'
getTableDescriptionSplittedByTableName <- function(table_description_path = NA, table_description_sheet_name = "table_description") {
  table_description <- loadTableDescriptionFile(table_description_path, table_description_sheet_name)
  # first columns
  table_description_table_names_column <- if (isFHIRTableDescription(table_description)) FHIR_TABLE_DESCRIPTION_COLNAMES[1] else DB_TABLE_DESCRIPTION_COLNAMES[1]
  table_description[, (table_description_table_names_column) := tolower(get(table_description_table_names_column))]
  table_description <- etlutils::splitTableToList(table_description, table_description_table_names_column)
  return(table_description)
}

#' Get Converted Table Description Split by Resource
#'
#' This function loads a table description from an Excel file, removes rows that are fully NA, and splits
#' the table description by resource. It then converts the table description based on a provided convert
#' definition table, renaming columns and replacing types accordingly.
#'
#' @param table_description_path A character string specifying the path to the table description file.
#' If NA (default), it uses the file from the package's extdata directory.
#' @param table_description_sheet_name name of the sheet with the table description in the Excel file.
#' Default is "table_description".
#' @param table_description_convert_definition A data.table containing the conversion definitions for
#' renaming columns and replacing types.
#'
#' @return A list of data.tables, each containing the converted table description for a specific resource.
#'
getConvertedTableDescriptionSplittedByTableName <- function(table_description_path = NA, table_description_sheet_name = "table_description", table_description_convert_definition = NA) {
  table_description <- getTableDescriptionSplittedByTableName(table_description_path, table_description_sheet_name)
  if (etlutils::isValidTable(table_description_convert_definition)) {
    table_description_backup <- data.table::copy(table_description)
    table_description_convert_definition_backup <- data.table::copy(table_description_convert_definition)
    for (i in seq_along(table_description)) {
      single_table_description <- table_description[[i]]

      # rename columns in the table description according to the convert definition
      for (r in seq_len(nrow(table_description_convert_definition))) {
        convert_def_row <- table_description_convert_definition[r]
        old_name <- convert_def_row$SOURCE_COLUMN_NAME
        new_name <- convert_def_row$TARGET_COLUMN_NAME
        if (!any(is.na(c(old_name, new_name)))) {
          data.table::setnames(single_table_description, old_name, new_name)
        }
      }

      # replace the types in the table description according to the convert definition
      # this step must be done after the renaming to ensure the "TYPE" column exists
      for (r in seq_len(nrow(table_description_convert_definition))) {
        convert_def_row <- table_description_convert_definition[r]
        old_type <- convert_def_row$SOURCE_TYPE
        new_type <- convert_def_row$TARGET_TYPE
        if (!all(is.na(c(old_type, new_type)))) {
          etlutils::replaceColumnValues(single_table_description, "COLUMN_TYPE", old_type, new_type)
        }
      }
    }
  }
  return(table_description)
}
