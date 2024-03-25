#' Convert columns of specific types in tables
#'
#' This function converts columns of specific types in tables using a given conversion function.
#'
#' @param resource_tables A named list of data.table objects to be written to the database.
#' Each element in the list represents a dataset intended for a corresponding table in the database.
#' @param convert_columns A character vector specifying the types of columns to be converted.
#' @param convert_type_function A function used to convert the columns.
#'
#' @details This function takes a list of tables, where each table is represented by a data frame,
#' and converts columns of specific types specified by \code{convert_columns}. The conversion is
#' performed using the provided \code{convert_type_function}. The function assumes that there is
#' a table description table containing columns: "resource", "column_name", and "type".
#'
#' @export
convertType <- function(resource_tables, convert_columns, convert_type_function) {
  # Get table description
  table_description <- getTableDescriptionsTable(c("resource", "column_name", "type"))
  # Remove all rows with NA or string in column 'type'
  table_description <- table_description[!is.na(type)]
  # Internal function for converting column types
  convertDateInternal <- function() {
    convert_columns <- table_description[type %in% convert_columns]
    last_table_name <- NA
    table_names <- convert_columns[["resource"]]
    for (i in seq_len(nrow(convert_columns))) {
      table_name <- convert_columns[["resource"]][i]
      column_name <- convert_columns[["column_name"]][i]
      if (table_name %in% last_table_name) {
        datetime_columns <- c(datetime_columns, column_name)
      } else {
        datetime_columns <- c(column_name)
      }
      # Check if the table is present in resource_tables and perform conversion
      if (!is.null(resource_tables[[table_name]]) && (!(table_name %in% last_table_name) || i == nrow(convert_columns))) {
        convert_type_function(resource_tables[[table_name]], datetime_columns)
        #cat("Converted column ", datetime_columns, " in table", table_name, "\n")
        table_name <- last_table_name
      }
    }
  }
  convertDateInternal()
}

#' Convert Types
#'
#' This function converts data types of columns in the provided resource tables.
#'
#' @param resource_tables A list of data tables representing resources.
#'
#' @details This function takes a list of data tables \code{resource_tables} as input.
#' It converts the data types of columns in these tables based on predefined mappings:
#' - Columns marked as "datetime" are converted to POSIXct objects using \code{etlutils::convertDateTimeFormat}.
#' - Columns marked as "date" are converted to date objects using \code{etlutils::convertDateFormat}.
#' - Columns marked as "time" are converted to character objects representing time of the day using \code{etlutils::convertTimeFormat}.
#' - Columns marked as "int" are converted to integer values using \code{etlutils::convertIntegerFormat}.
#' - Columns marked as "decimal" are converted to numeric (floating-point) values using \code{etlutils::convertDecimalFormat}.
#' - Columns marked as "boolean" are converted to logical (TRUE/FALSE) values using \code{etlutils::convertBooleanFormat}.
#'
#' @return This function modifies the input resource tables by converting the data types of columns.
#'
#' @export
convertTypes <- function(resource_tables) {
  convertType(resource_tables, c("datetime"), etlutils::convertDateTimeFormat)
  convertType(resource_tables, c("date"), etlutils::convertDateFormat)
  convertType(resource_tables, c("time"), etlutils::convertTimeFormat)
  convertType(resource_tables, c("int"), etlutils::convertIntegerFormat)
  convertType(resource_tables, c("decimal"), etlutils::convertDecimalFormat)
  convertType(resource_tables, c("boolean"), etlutils::convertBooleanFormat)
}
