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
#' library(data.table)
#' dt <- data.table(name.given = c("[1.1]Marie|[1.2]Anne|[1.3]Lea|[2.1]Marie2|[2.2]Anne2|[2.3]Lea2",
#' "[1]Kai|[2]Ingo", "[1.1]Mark|[1.3]Ben|[2.2]Tim"))
#' column_names <- c("name.given")
#' sep <- "|"
#' brackets <- c("[", "]")
#' joinMultiValuesInCrackedFHIRData(dt, column_names, sep, brackets)
#'
#' @export
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

#' Melt the Table According to a Given Schema
#'
#' This function melts the table according to a given schema.
#'
#' @param indexed_data_table A data.table containing the indexed data to be melted.
#' @param fhir_table_description An object describing the schema of the FHIR table.
#' @param column_name_separator A character string that separates the column names. Defaults to "/".
#'
#' @return A melted data.table.
#'
#' @export
fhirMeltFull <- function(indexed_data_table, fhir_table_description, column_name_separator = "/") {

  getEscaped <- function(string) {
    if (nchar(string) == 0) {
      return(string)
    } else if (nchar(string) == 1) {
      return(paste0("\\", string))
    } else {
      chars <- strsplit(string, "")[[1]]
      escaped_string <- paste0("\\", chars, collapse = "")
      return(escaped_string)
    }
  }

  getColumns <- function(prefix) {
    grep(paste0("^", prefix, "$|^", prefix, getEscaped(column_name_separator)), column_names, value = TRUE)
  }

  melted_data <- indexed_data_table
  column_names <- fhir_table_description@cols@.Data
  brackets <- fhir_table_description@brackets
  sep <- fhir_table_description@sep

  getUniquePrefixes <- function(step) {
    # Split each column name by the separator
    split_names <- strsplit(column_names, getEscaped(column_name_separator))

    # Initialize a vector to store the prefixes
    prefixes <- c()

    for (name_parts in split_names) {
      # Check if the number of parts is sufficient for the given step
      if (length(name_parts) >= step) {
        # Create the prefix by joining the first `step` parts with the separator
        prefix <- paste(name_parts[1:step], collapse = column_name_separator)
        prefixes <- c(prefixes, prefix)
      }
    }
    # Get unique prefixes
    prefixes <- unique(prefixes)
    return(prefixes)
  }

  step <- 1
  repeat {
    prefixes <- getUniquePrefixes(step)
    if (!rlang::is_empty(prefixes)) {
      for (prefix in prefixes) {
        columns <- getColumns(prefix)
        melted_data <- fhircrackr::fhir_melt(melted_data, columns, brackets, sep, all_columns = TRUE)
      }
    } else {
      break
    }
    step <- step + 1
  }

  melted_data <- fhircrackr::fhir_rm_indices(melted_data, brackets, column_names)
  melted_data[, resource_identifier := NULL]
  return(melted_data)
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
#' @param fhir_table_description An object containing the table description, including the brackets used for indexing.
#'
#' @return A logical value indicating whether the data table is indexed (`TRUE`) or not (`FALSE`).
#'
isIndexedTable <- function(dt, fhir_table_description) {
  brackets <- fhir_table_description@brackets
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
    if (isIndexedTable(resource_tables[[i]], fhir_table_description)) {
      print(paste0("Melt table ", resource_name))
      resource_tables[[i]] <- fhirMeltFull(resource_tables[[i]], fhir_table_description)
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
#' a table description table containing columns: "resource", "column_name", and "type".
#'
convertType <- function(resource_tables, convert_columns, convert_type_function) {
  # Get table description
  table_description <- getTableDescriptionsTable(c("resource", "column_name", "type"))
  # converting column types
  convert_columns <- table_description[type %in% convert_columns]
  convert_columns <- split(convert_columns, convert_columns$resource)
  for (resource in names(convert_columns)) {
    resource_table <- resource_tables[[tolower(resource)]]
    if (!is.null(resource_table)) {
      convert_type_function(resource_table, convert_columns[[resource]]$column_name)
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
convertTypes <- function(resource_tables, fhir_table_descriptions) {

  # rename the database column names in style of something like 'con_identifier_code' back
  # to 'identifier/code'. This we need for correct working of the following join and melt.
  resource_tables <- replaceTablesColumnNames(resource_tables, fhir_table_descriptions, TRUE)

  # the following commented codeline adds a second name to all patient names. So you can
  # 'test' the follwing join function
  #resource_tables$patient[, `name/given` := paste0(`name/given`, SEP, "[1.2]Ernst-August")]
  etlutils::run_in_in("Join string multi entries in cracked FHIR data", {
    resource_tables <- joinUnmeltableMultiEntries(resource_tables, fhir_table_descriptions)
  })
  etlutils::run_in_in("Melt cracked FHIR data", {
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
    polar_write_rdata(resource_tables[[i]], tolower(names(resource_tables)[i]))
  }
  return(resource_tables)
}

#' Replace Column Names in a Data Table
#'
#' This function replaces old column names with new column names in a data.table.
#' The columns are replaced by comparing the names, not by their index positions.
#' The same indices of the old and new names vectors indicate the old and new names respectively.
#'
#' @param dt A data.table where the column names will be replaced.
#' @param old_names A character vector of old column names.
#' @param new_names A character vector of new column names.
#'
#' @return A data.table with updated column names.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(f = 9:11, b = 4:6, g = 7:9, a = 1:3)
#' old_names <- c("a", "b")
#' new_names <- c("x", "y")
#' replaceColumnNames(dt, old_names, new_names)
#'
#' @export
replaceColumnNames <- function(dt, old_names, new_names) {
  for (i in seq_along(old_names)) {
    old_name <- old_names[i]
    new_name <- new_names[i]
    names(dt)[which(names(dt) == old_name)] <- new_name
  }
  return(dt)
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
    fhir_table_description <- fhir_table_descriptions[[table_description_index]]
    if (names_to_.Data) {
      old_names <- fhir_table_description@cols@names
      new_names <- fhir_table_description@cols@.Data
    } else {
      old_names <- fhir_table_description@cols@.Data
      new_names <- fhir_table_description@cols@names
    }
    resource_tables[[i]] <- replaceColumnNames(resource_tables[[i]], old_names, new_names)
  }
  return(resource_tables)
}
