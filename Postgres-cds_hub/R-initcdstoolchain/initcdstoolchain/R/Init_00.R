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
  table_description <- etlutils::getTableDescriptionSplittedByTableName(table_description_path, table_description_sheet_name)
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
