#' Join and Clean Multi-Value Fields in an indexed Data Table
#'
#' This function processes specific columns in a data.table, removing extra brackets from multi-value fields and joining the values.
#'
#' @param dt A data.table containing the data to be processed.
#' @param column_names A character vector of column names to be processed.
#' @param sep A character string to split the multi-value fields.
#' @param brackets A character vector of length 2, where the first element is the opening bracket and the second element is the closing bracket.
#' @param collapse A character string specifying the separator used to collapse the joined values. Default is a space (" ").
#'
#' @return The modified data.table with cleaned and joined multi-value fields.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#' dt <- data.table(name.given = c("[1.1]Marie|[1.2]Anne|[1.3]Lea|[2.1]Marie2|[2.2]Anne2|[2.3]Lea2",
#' "[1]Kai|[2]Ingo", "[1.1]Mark|[1.3]Ben|[2.2]Tim"))
#' column_names <- c("name.given")
#' sep <- "|"
#' brackets <- c("[", "]")
#' joinMultiValuesInCrackedFHIRData(dt, column_names, sep, brackets)
#' }
#'
joinMultiValuesInCrackedFHIRData <- function(dt, column_names, sep, brackets, collapse = " ") {
  for (column_name in column_names) {
    for (i in 1:nrow(dt)) {
      # Check if the cell is not empty
      if (length(dt[[column_name]][i])) {
        # Check if the cell starts with sep
        if (grepl("^\\[", dt[[column_name]][i])) {
          #split the string by sep
          split_string <- strsplit(dt[[column_name]][i], sep, fixed = TRUE)[[1]]
          # Initialize the index vector and previous index
          indices <- c()
          prev_index <- NULL
          # Iterate through the vector and find the first indices for each new pattern
          for (vec in seq_along(split_string)) {
            index <- as.numeric(stringr::str_extract(split_string[vec], paste0("(?<=\\", brackets[1], ")\\d")))
            if (is.null(prev_index) || is.na(prev_index) || index != prev_index) {
              indices <- c(indices, vec)
              prev_index <- index
            }
          }
          # Remove brackets for all subsequent elements except the first occurrence an collapse values
          result <- paste(ifelse(seq_along(split_string) %in% indices, split_string,
                                 gsub(paste0("^\\", brackets[1], ".*\\", brackets[2]), "",
                                      split_string, perl = TRUE)), collapse = " ")
          # Replace the original cell value with the modified result
          dt[[column_name]][i] <- result
        }
      }
    }
  }
  return(dt)
}

#' Join Unmeltable Multi-Entries in Resource Tables
#'
#' This function joins specific multi-entry columns in the patient resource table
#' according to the provided FHIR table descriptions.
#'
#' @param resource_tables A list of data.tables containing the resource tables.
#' @param fhir_table_descriptions A list of FHIR table description objects.
#'
#' @return A list of data.tables with joined multi-entry columns.
#'
joinUnmeltableMultiEntries <- function(resource_tables, fhir_table_descriptions) {
  patient_fhir_table_description <- fhir_table_descriptions$Patient
  if (!is.null(patient_fhir_table_description)) {
    # These are constants! In all cases these columns must be joined and not melted if they are
    # present in the table description of the patients.
    patient_column_names_2_join <- c("name/given", "name/prefix", "name/suffix", "adress/line")
    # get the columns which are really present in the current patients table description
    patient_column_names_2_join <- intersect(patient_column_names_2_join, patient_fhir_table_description@cols@.Data)
    if (length(patient_column_names_2_join)) {
      resource_tables[["patient"]] <- joinMultiValuesInCrackedFHIRData(resource_tables[["patient"]], patient_column_names_2_join, SEP, BRACKETS)
    }
  }
  return(resource_tables)
}

#' Check if Data Table is Indexed
#'
#' This function checks if a data table contains indexed columns based on a specified pattern in the
#' `fhir_table_description` object. It returns `TRUE` if any character column contains values matching the
#' index pattern, otherwise `FALSE`.
#'
#' @param dt A `data.table` object to be checked.
#' @param brackets A character vector of length two, defining the brackets used for the indices.
#'
#' @return A logical value indicating whether the data table is indexed (`TRUE`) or not (`FALSE`).
#'
isIndexedTable <- function(dt, brackets) {
  indices_pattern <- paste0("^\\", brackets[1], ".*\\", brackets[2])
  for (col in seq_len(ncol(dt))) {
    if (is.character(dt[[col]])) {
      for (row in seq_len(nrow(dt))) {
        value <- dt[[col]][row]
        if (grepl(indices_pattern, value)) {
          return(TRUE)
        }
      }
    }
  }
  return(FALSE)
}

#' Melt Cracked FHIR Data
#'
#' This function melts cracked FHIR data in the resource tables according to the provided FHIR table descriptions.
#'
#' @param resource_tables A list of data.tables containing the resource tables.
#' @param fhir_table_descriptions A list of FHIR table description objects.
#'
#' @return A list of melted data.tables.
#'
meltCrackedFHIRData <- function(resource_tables, fhir_table_descriptions) {
  names(fhir_table_descriptions) <- tolower(names(fhir_table_descriptions))
  for (i in seq_along(resource_tables)) {
    resource_name <- names(resource_tables)[i]
    fhir_table_description <- fhir_table_descriptions[[resource_name]]
    if (!is.null(fhir_table_description)) {
      brackets <- fhir_table_description@brackets
      if (isIndexedTable(resource_tables[[i]], brackets)) {
        nrow_before_melt <- nrow(resource_tables[[i]])
        print(paste0("Melt table ", resource_name, " with ", nrow_before_melt, " rows."))
        sep <- fhir_table_description@sep
        time0 <- Sys.time()
        resource_tables[[i]] <- fhircrackr::fhir_melt_all(resource_tables[[i]], brackets, sep, column_name_separator = "/")
        duration <- difftime(Sys.time(), time0, units = 'secs')
        nrow_after_melt <- nrow(resource_tables[[i]])
        print(paste("Resource table", resource_name, nrow_before_melt, "rows to", nrow_after_melt, "rows in", duration, "seconds."))
      }
    }
  }
  return(resource_tables)
}

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
#' a table description table containing columns: "RESOURCE", "COLUMN_NAME", and "FHIR_TYPE".
#'
convertType <- function(resource_tables, convert_columns, convert_type_function) {
  # Get table description
  table_description <- getTableDescriptionsTable(c("RESOURCE", "COLUMN_NAME", "FHIR_TYPE"))
  # converting column types
  convert_columns <- table_description[FHIR_TYPE %in% convert_columns]
  convert_columns <- split(convert_columns, convert_columns$RESOURCE)
  for (resource in names(convert_columns)) {
    resource_table <- resource_tables[[tolower(resource)]]
    if (!is.null(resource_table)) {
      convert_type_function(resource_table, convert_columns[[resource]]$COLUMN_NAME)
    }
  }
}

#' Convert Types
#'
#' This function converts data types of columns in the provided resource tables.
#'
#' @param resource_tables A list of data tables representing resources.
#' @param fhir_table_descriptions A named list of all relevant FHIR table descriptions (named with
#'                                resource name).
#' @param resource_tables_suffix A suffix for resource_tables, default: "_raw_diff".
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
convertTypes <- function(resource_tables, fhir_table_descriptions, resource_tables_suffix = "_raw_diff") {
  # remove _raw_diff suffix in resource_table names
  names(resource_tables) <- sub(resource_tables_suffix, "", names(resource_tables))
  # rename the database column names in style of something like 'con_identifier_code' back
  # to 'identifier/code'. This we need for correct working of the following join and melt.
  resource_tables <- replaceTablesColumnNames(resource_tables, fhir_table_descriptions, TRUE)

  # the following commented codeline adds a second name to all patient names. So you can
  # 'test' the follwing join function
  #resource_tables$patient[, `name/given` := paste0(`name/given`, SEP, "[1.2]Ernst-August")]
  etlutils::runLevel3("Join string multi entries in cracked FHIR data", {
    resource_tables <- joinUnmeltableMultiEntries(resource_tables, fhir_table_descriptions)
  })
  etlutils::runLevel3("Melt cracked FHIR data", {
    resource_tables <- meltCrackedFHIRData(resource_tables, fhir_table_descriptions)
  })

  # undo the tables renaming
  resource_tables <- replaceTablesColumnNames(resource_tables, fhir_table_descriptions, FALSE)

  convertType(resource_tables, "datetime", etlutils::convertDateTimeFormat)
  convertType(resource_tables, "date", etlutils::convertDateFormat)
  convertType(resource_tables, "time", etlutils::convertTimeFormat)
  convertType(resource_tables, "int", etlutils::convertIntegerFormat)
  convertType(resource_tables, "decimal", etlutils::convertDecimalFormat)
  convertType(resource_tables, "boolean", etlutils::convertBooleanFormat)

  for (i in seq_along(resource_tables)) {

    # rename the id column from the raw tables from tablename_id to tablename_raw_id
    tablename <- tolower(names(resource_tables)[i])
    pattern <- paste0("^", tablename, "_id$")
    raw_id_column <- grep(pattern, colnames(resource_tables[[i]])) # should be only 1 column
    colnames(resource_tables[[i]])[raw_id_column] <- paste0(tablename, "_raw_id")

    writeRData(resource_tables[[i]], tolower(names(resource_tables)[i]))
  }
  return(resource_tables)
}

#' Replace Column Names in Resource Tables
#'
#' This function replaces column names in the resource tables based on the provided FHIR table
#' descriptions.
#'
#' @param resource_tables A list of data.tables containing the resource tables.
#' @param fhir_table_descriptions A list of FHIR table description objects.
#' @param names_to_.Data A logical value indicating the direction of the replacement.
#' If TRUE, replace names with .Data; if FALSE, replace .Data with names.
#'
#' @return A list of data.tables with updated column names.
#'
replaceTablesColumnNames <- function(resource_tables, fhir_table_descriptions, names_to_.Data) {
  for (i in seq_along(resource_tables)) {
    resource_name <- names(resource_tables)[i]
    table_description_index <- which(tolower(names(fhir_table_descriptions)) == resource_name)
    if (length(table_description_index)) {
      fhir_table_description <- fhir_table_descriptions[[table_description_index]]
      if (names_to_.Data) {
        old_names <- fhir_table_description@cols@names
        new_names <- fhir_table_description@cols@.Data
      } else {
        old_names <- fhir_table_description@cols@.Data
        new_names <- fhir_table_description@cols@names
      }
      resource_tables[[i]] <- data.table::setnames(resource_tables[[i]], old_names, new_names)
    }
  }
  return(resource_tables)
}
