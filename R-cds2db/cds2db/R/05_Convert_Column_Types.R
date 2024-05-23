# Function to remove extra brackets from specific columns in a data.table
joinMultiValuesInCrackedFHIRData <- function(dt, columns, sep, brackets) {
  for (col in columns) {
    for (i in 1:nrow(dt)) {
      # Check if the cell is not empty
      if (length(dt[[col]][i])) {
        # Check if the cell starts with "["
        if (grepl("^\\[", dt[[col]][i])) {
          # Remove extra brackets and split the string by "|"
          split_string <- strsplit(gsub(paste0("\\", brackets[1], "\\d+\\", brackets[2]), "",
                                        dt[[col]][i], perl = TRUE), sep, fixed = TRUE)[[1]]
          # Initialize the index vector and previous index
          indices <- c()
          prev_index <- NULL
          # Iterate through the vector and find the first indices for each new pattern
          for (vec in seq_along(split_string)) {
            index <- as.numeric(gsub(paste0("\\", brackets[1], "|\\..*"), "", split_string[vec]))
            if (is.null(prev_index) || index != prev_index) {
              indices <- c(indices, vec)
              prev_index <- index
            }
          }
          # Remove "[]" for all subsequent elements except the first occurrence
          result <- paste(ifelse(seq_along(split_string) %in% indices, split_string,
                                 gsub(paste0("^\\", brackets[1], ".*\\", brackets[2]), "",
                                      split_string, perl = TRUE)), collapse = " ")
          # Replace the original cell value with the modified result
          dt[[col]][i] <- result
        }
      }
    }
  }
  return(dt)
}

# Function to split a vector of strings by common prefixes
# Each element of the input vector is split by periods, and then grouped by their common prefixes,
# resulting in a list of vectors where each vector contains strings with the same prefix.
splitStringsByPrefix <- function(strings, column_sep) {
  # Split each string by periods
  split_strings <- strsplit(strings, paste0("\\", column_sep))
  # Group strings by their common prefixes using split
  grouped_strings <- split(strings, sapply(split_strings, function(x) paste(x[-length(x)], collapse = column_sep)))
  return(grouped_strings)
}

# Function for selecting columns with the most column name separators based on the content of brackets in the first row entry
getColumnsWithMostDots <- function(melted_data, cols, brackets, column_sep) {
  # Extract columns with the specified prefix
  #cols <- grep(paste0("^", prefix, paste0("\\", column_sep)), names(melted_data), value = TRUE)

  if (length(cols)) {

    # Initialize a list to store the first non-NA row for each column
    first_non_na_rows <- vector("list", length(cols))

    # Find the first non-NA row for each column
    for (i in seq_along(cols)) {
      first_non_na_rows[[i]] <- which(!is.na(melted_data[[cols[i]]]))[1]
    }

    # Extract the content inside brackets for all columns with the specified prefix in the first non-NA row entry
    contents_in_brackets <- lapply(seq_along(cols), function(j) {
      col <- cols[j]
      x <- melted_data[[col]][first_non_na_rows[[j]]]
      regmatches(x, gregexpr(paste0("\\", brackets[1], "(.*?)\\", brackets[2]), x))[[1]]
    })

    # Selecting only the first element from each vector in the list
    first_elements <- lapply(contents_in_brackets, function(vec) vec[1])
    # Extract the content inside brackets and count the number of column name separators for each content
    num_sep <- sapply(first_elements, function(content) {
      sapply(content, function(x) {
        # Count the number of "." inside the brackets
        sum(grepl("\\.", unlist(strsplit(x, ""))))
      })
    })
    # Determine the maximum number of column name separators
    max_dots <- max(unlist(num_sep))
    # Select columns with the maximum number of column name separators
    max_dot_columns <- cols[sapply(num_sep, function(x) max(x) == max_dots)]

    return_list <- list(
      max_dot_columns = max_dot_columns,
      max_dots = max_dots)

    return(return_list)
  }
  return(NA)
}

# Function to check for brackets in the first row of each column
checkPointInBrackets <- function(dt, brackets) {
  for (row in seq_len(nrow(dt))) {
    for (column_name in names(dt)) {
      value <- dt[row, get(column_name)]
      if (!etlutils::isSimpleNA(value)) {
        if (grepl(paste0("^\\", brackets[1], "\\d+\\..*\\", brackets[2]), value)) {
          return(TRUE)
        }
      }
    }
  }
  return(FALSE)
}

# Function to count column separators in a string
countStringSeperator <- function(string, column_sep) {
  matches <- gregexpr(paste0("\\", column_sep), string)
  num_dots <- length(matches[[1]])
  if (length(matches) == 1 && matches[[1]][1] == -1) {
    return(0)
  }
  return(num_dots)
}

# Function to truncate column names by number of column name separator occurrences of
# non-column-name-separator strings followed by a column-name-separator, followed by
# another non-column-name-separator string
cutColumnNames <- function(column_name, count, column_sep) {
  pattern <- paste0("^((?:[^", column_sep, "]+\\", column_sep, "){", count, "}[^", column_sep, "]+).*")
  sub(pattern, "\\1", column_name)
}

# Function to extract the common prefix for column names in list
getCommonPrefix <- function(list, column_sep) {
  # Find the common prefix of all elements in the list
  common_prefix <- Reduce(function(x, y) {
    common <- intersect(strsplit(x, paste0("\\", column_sep))[[1]], strsplit(y, paste0("\\", column_sep))[[1]])  # Find the common prefix
    paste(common, collapse = column_sep)
  }, list)
  return(common_prefix)
}

# Function to melt the table according to a given schema
fhirMeltFull <- function(melted_data, fhir_table_description, column_sep = "/") {

  if (tolower(fhir_table_description@resource) %in% "patient") browser()

  brackets <- fhir_table_description@brackets
  sep <- fhir_table_description@sep
  all_fhir_column_names <- fhir_table_description@cols@.Data

  # Determine the prefixes for each column
  prefixes <- sapply(all_fhir_column_names, function(column_name) {
    # melt only columns with type character
    if (is.character(melted_data[[column_name]])) {
      # Extract the prefix until the first period for each column
      prefix <- unlist(strsplit(column_name, paste0("\\", column_sep)))[1]
      if (length(prefix) == 1) {
        return(prefix)  # Return the prefix if it's length is 1
      }
    }
    return(NA)  # Return NA if the prefix is not found (will be ignored/removed later)
  })
  unique_prefixes <- na.omit(unique(prefixes))  # Get unique prefixes

  # Melt for all columns with a number in brackets
  repeat {
    run_again <- FALSE
    full_melted_prefixes = c()
    for (prefix in unique_prefixes) {
      columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
      if (length(columns_with_prefix)) {
        # Select columns with the most dots based on content within square brackets
        result <- getColumnsWithMostDots(melted_data, columns_with_prefix, brackets, column_sep)
        if (!etlutils::isSimpleNA(result)) {
          max_dot_columns <- result$max_dot_columns
          # Split max_dot_columns by common prefixes
          max_dot_columns <- splitStringsByPrefix(max_dot_columns, column_sep)
          # Count the number of dots in each string of the list
          max_num_dots <- result$max_dots

          if (max_num_dots) {
            run_again <- TRUE
          } else {
            full_melted_prefixes <- c(full_melted_prefixes, prefix)
          }
          # Extract common prefix for each column name list
          max_cols <- lapply(max_dot_columns, getCommonPrefix, column_sep)
          # Count the number of dots in each string of the list
          min_num_dots <- min(sapply(max_cols, countStringSeperator, column_sep))
          # Truncate column names in the list
          max_cols <- unique(lapply(max_cols, function(x) cutColumnNames(x, min_num_dots, column_sep)))
          cat(paste0("Melt: ", fhir_table_description@resource, " -> ", max_cols, "\n"))
          for (col in seq_along(max_cols)) {
            # Apply common columns function
            columns_with_prefix <- grep(paste0("^", max_cols[[col]], "$|^", max_cols[[col]], "\\", column_sep), all_fhir_column_names, value = TRUE)
            # Melt the data based on selected columns
            melted_data <- fhircrackr::fhir_melt(melted_data, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
          }
        }
      }
    }
    if (!run_again) {
      break
    }
    unique_prefixes <- setdiff(unique_prefixes, full_melted_prefixes)
  }

    # Check for "[]" in the first row of each column
    #result <- checkPointInBrackets(melted_data, brackets)

    #if (!result) {
      # Check which column names in the first row contain the string with "[]" and a single number
      # columns_with_number_in_brackets <- names(melted_data)[sapply(melted_data[1, .SD, .SDcols = names(melted_data)],
      #                                                              function(x) grepl(paste0("\\", brackets[1], "\\d+\\", brackets[2]), x))]
      # cat(paste0("Melt: ", columns_with_number_in_brackets, "\n"))
      # for (columns in seq_along(columns_with_number_in_brackets)) {
      #   # melt for each column with a single number in brackets
      #   melted_data <- fhircrackr::fhir_melt(melted_data, columns = columns_with_number_in_brackets[[columns]],
      #                                        brackets = brackets, sep = sep, all_columns = TRUE)
      # }
      columns <- fhir_table_description@cols@.Data
      #browser()
      #melted_data <- fhircrackr::fhir_melt(melted_data, columns, brackets, sep, all_columns = TRUE)
      # remove brackets
      melted_data <- fhircrackr::fhir_rm_indices(melted_data, brackets, columns)
      # End the loop if no dots are left
  #    break
  #  }
  #}
  browser()
  return(melted_data)
}


getUntypedRAWDataFromDatabase <- function() {

  db_connection <- etlutils::dbConnect(
    user = DB_CDS2DB_USER,
    password = DB_CDS2DB_PASSWORD,
    dbname = DB_GENERAL_NAME,
    host = DB_GENERAL_HOST,
    port = DB_GENERAL_PORT,
    schema = DB_CDS2DB_SCHEMA_OUT
  )

  db_table_names <- etlutils::dbListTables(db_connection)
  # Display the table names
  print(paste("The following tables are found in database:", paste(db_table_names, collapse = ", ")))
  if (is.null(db_table_names)) {
    warning("There are no tables found in database")
  }

  resource_tables <- list()
  for (table_name in db_table_names) {
    # the database tables here are tables of a View. Per convention their prefix is "v_" -> remove this prefix
    resource_table_name <- sub("^v_", "", table_name)
    resource_tables[[resource_table_name]] <- etlutils::dbReadTable(db_connection, table_name)
  }
  return(resource_tables)
}

joinUnmeltableMultiEntries <- function(resource_tables, fhir_table_descriptions) {
  patient_fhir_table_description <- fhir_table_descriptions$Patient
  if (!is.null(patient_fhir_table_description)) {
    # These are constants! In all cases these columns must be joined and not melted if they are
    # present in the table description of the patients.
    patient_column_names_2_join <- c("name/given", "name/prefix", "name/suffix")
    # get the columns which are really present in the current patients table description
    patient_column_names_2_join <- intersect(patient_column_names_2_join, patient_fhir_table_description@cols@.Data)
    if (length(patient_column_names_2_join)) {
      resource_tables[["patient"]] <- joinMultiValuesInCrackedFHIRData(resource_tables[["patient"]], patient_column_names_2_join, SEP, BRACKETS)
    }
  }
  return(resource_tables)
}

meltCrackedFHIRData <- function(resource_tables, fhir_table_descriptions, BRACKETS, SEP) {
  names(fhir_table_descriptions) <- tolower(names(fhir_table_descriptions))
  for (i in seq_along(resource_tables)) {
    resource_name <- names(resource_tables)[i]
    fhir_table_description <- fhir_table_descriptions[[resource_name]]
    resource_tables[[i]] <- fhirMeltFull(resource_tables[[i]], fhir_table_description)
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
    convert_type_function(resource_tables[[tolower(resource)]], convert_columns[[resource]]$column_name)
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
resource_tables$patient[, `name/given` := paste0(`name/given`, SEP, "[1.2]Ernst-August")]
  #resource_tables <- joinUnmeltableMultiEntries(resource_tables, fhir_table_descriptions)
  resource_tables <- meltCrackedFHIRData(resource_tables, fhir_table_descriptions, BRACKETS, SEP)

  # undo the tables renaming
  resource_tables <- replaceTablesColumnNames(resource_tables, fhir_table_descriptions, FALSE)

  convert_type2function <- c(
    datetime = etlutils::convertDateTimeFormat,
    date = etlutils::convertDateFormat,
    time = etlutils::convertTimeFormat,
    int = etlutils::convertIntegerFormat,
    decimal = etlutils::convertDecimalFormat,
    boolean = etlutils::convertBooleanFormat
  )

  for (i in seq_along(convert_type2function)) {
    convertType(resource_tables, names(i), convert_type2function[i])
  }
#
#   convertType(resource_tables, "datetime", etlutils::convertDateTimeFormat)
#   convertType(resource_tables, "date", etlutils::convertDateFormat)
#   convertType(resource_tables, "time", etlutils::convertTimeFormat)
#   convertType(resource_tables, "int", etlutils::convertIntegerFormat)
#   convertType(resource_tables, "decimal", etlutils::convertDecimalFormat)
#   convertType(resource_tables, "boolean", etlutils::convertBooleanFormat)

  for (i in seq_along(resource_tables)) {
    polar_write_rdata(resource_tables[[i]], tolower(names(resource_tables)[i]))
  }
  return(resource_tables)
}

replaceColumnNames <- function(dt, old_names, new_names) {
  for (i in seq_along(old_names)) {
    old_name <- old_names[i]
    new_name <- new_names[i]
    names(dt)[which(names(dt) == old_name)] <- new_name
  }
  return(dt)
}

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
