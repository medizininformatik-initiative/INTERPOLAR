#' Retrieve the first non-NA resource abbreviation
#'
#' This function searches for a given `resource_name` in the `RESOURCE` column
#' of `table_description_collapsed` and returns the first non-NA value from
#' the corresponding `RESOURCE_PREFIX` column.
#'
#' @param table_description_collapsed A data.table containing the columns
#'        `RESOURCE` and `RESOURCE_PREFIX`.
#' @param resource_name A character string specifying the resource name to search for.
#'
#' @return The first non-NA value from the `RESOURCE_PREFIX` column corresponding
#'         to the given `resource_name`, or `NA` if no match is found.
#'
getResourceAbbreviation <- function(table_description_collapsed, resource_name) {
  first_prefix <- na.omit(table_description_collapsed$RESOURCE_PREFIX[table_description_collapsed$RESOURCE == resource_name])[1]
}

#' Extract Replacement Patterns from a Table
#'
#' Extracts replacement patterns and their corresponding strings from a given table. This function
#' is designed to parse a table where specific rows indicate the start of pattern-replacement pairs.
#' Patterns are expected to be in the 'resource' column, and their corresponding replacement strings
#' in the 'resource_prefix' column. The function uses a helper function to find the first row that
#' contains the headers for patterns and replacements, and then iterates over the rows to collect
#' these pairs into a list.
#'
#' @param table_description_collapsed A data table that contains the patterns and their replacements.
#' The table must have at least 'resource' and 'resource_prefix' columns.
#' @return A named list where each name-value pair corresponds to a pattern and its replacement string.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#' # Implementing the function with simulated data
#' table_description_collapsed <- data.table(
#'   resource = c("Line 1", "pattern", "pattern1", "pattern2"),
#'   resource_prefix = c("Line 1", "replacement", "replace1", "replace2")
#' )
#' # Apply the function
#' result <- extractReplacePatterns(table_description_collapsed)
#' # Print the result
#' print(result)
#' }
#'
#' @seealso \code{\link[etlutils]{getFirstRowWithPatterns}}, \code{\link[etlutils]{isSimpleNotEmptyString}}
#'
extractReplacePatterns <- function(table_description_collapsed) {
  replace_patterns <- list()
  # find the row withe the table header for the replace patterns
  patterns_start_row <- etlutils::getFirstRowWithPatterns(table_description_collapsed, c("PATTERN", "REPLACEMENT")) + 1
  # found the header line?
  if (patterns_start_row > 0) {
    for(r in patterns_start_row:nrow(table_description_collapsed)) {
      pattern <- table_description_collapsed$RESOURCE[r] # patterns are in the column 'RESOURCE'
      replace <- table_description_collapsed$RESOURCE_PREFIX[r] # replaces strings are in the column 'RESOURCE_PREFIX'
      if (etlutils::isSimpleNotEmptyString(pattern)) {
        replace_patterns[[pattern]] <- replace
      }
    }
  }
  return(replace_patterns)
}

#' Add Empty Rows Before New Resource Entries in a Data Table
#'
#' This function inserts an empty row in a data table before each new resource entry,
#' except before the first row and where the first column (`resource`) is not NA.
#' It's useful for visually separating different resources in a data table.
#'
#' @param table A `data.table` object with a column named `resource`. The function
#'              will insert empty rows based on the conditions specified.
#' @return A modified `data.table` with empty rows inserted before new resource entries.
#' @examples
#' \dontrun{
#' # Assuming `table` is a data.table with a column `resource`
#' table <- data.table(resource = c(NA, 'Resource1', 'Resource1', NA, 'Resource2'),
#'                     value = 1:5)
#' table <- addEmptyRowsBeforeNewResource(table)
#' print(table)
#' }
addEmptyRowsBeforeNewResource <- function(table) {

  # Generate an index indicating where empty rows should be inserted
  # (before each row except the first and if 'RESOURCE' column is not NA)
  new_resource_start_rows <- which(!is.na(table$RESOURCE) & seq_len(nrow(table)) != 1)

  for (empty_row_insert_index in seq(length(new_resource_start_rows), 1, by = -1)) {
    index <- new_resource_start_rows[empty_row_insert_index]
    # Duplicate the row and insert it, then set all values in the first of the two rows to NA
    table <- rbind(
      table[1:index - 1, ],
      table[index, ][, lapply(.SD, function(x) NA)],
      table[index:.N, ]
    )
  }
  return(table)
}

#' Expand Table Description with Specified Expansion Tables
#'
#' This function expands a given table description by replacing certain rows with data from expansion tables.
#' It specifically targets rows with patterns and replaces them based on a set of rules, effectively expanding
#' the original table description. The expansion is guided by `RESOURCE_PREFIX` and `FHIR_EXPRESSION` columns.
#' Rows with `NA` in `FHIR_EXPRESSION` are removed. The function adjusts the expansion tables to match the
#' target table's structure, removing unnecessary columns and adding missing ones as `NA`. It generates full
#' column names by combining `RESOURCE_PREFIX` with modified `FHIR_EXPRESSION` values, replacing slashes with
#' underscores and appending prefixes. The expansion process might replace a single row with multiple rows
#' from an expansion table, adjusting `COUNT` values and column names accordingly.
#' Finally, all `COLUMN_NAME` entries are converted to lowercase.
#'
#' @param table_description_collapsed A `data.table` object that contains the initial table description to be
#' expanded.
#' @param expansion_tables A list of `data.table` objects, each representing an expansion table to be used for
#' replacing specific rows in the `table_description_collapsed`. The names of the list elements should match
#' the keys used in the `fhir_expression` column of `table_description_collapsed` to indicate which expansion
#' table to use.
#'
#' @return A `data.table` object with the expanded table description, where specific rows have been replaced
#' according to the rules defined by the expansion tables.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#'
#' # Assuming `table_description_collapsed` and `expansion_tables` are predefined
#' table_description_collapsed <- data.table(...) # Define your initial table description
#' expansion_tables <- list(...) # Define your expansion tables
#'
#' # Example function call
#' expanded_table <- expandTableDescriptionInternal(table_description_collapsed, expansion_tables)
#' print(expanded_table)
#' }
#'
#' @seealso \code{\link{extractReplacePatterns}}, \code{\link[etlutils]{getFirstRowWithPatterns}},
#' \code{\link[etlutils]{isSimpleNotEmptyString}}, \code{\link[etlutils]{getAfterLastSlash}},
#' \code{\link[etlutils]{getBeforeLastSlash}}, \code{\link[etlutils]{replacePatternsInString}}
expandTableDescriptionInternal <- function(table_description_collapsed, expansion_tables) {

  table <- data.table::copy(table_description_collapsed)

  replace_patterns <- extractReplacePatterns(table)

  # remove all rows with NA in column 'FHIR_EXPRESSION'
  table <- table[!is.na(FHIR_EXPRESSION), ]

  # prepare expand_table for rbind = add missing columns of target table and set same column order
  for (expand_table in expansion_tables) {
    for (col_name in colnames(table)) {
      if (!(col_name %in% colnames(expand_table))) {
        expand_table[, (col_name) := NA_character_]
      }
    }
    data.table::setcolorder(expand_table, names(table))
    # remove unnecessary columns in the expansion tables
    target_columns <- setdiff(names(expand_table), names(table))
    expand_table[, (target_columns) := NULL]
  }

  getFullColumnName <- function(resource_prefix, fhir_expression) {
    full_column_name <- gsub('/', '_', fhir_expression)
    full_column_name <- paste0(resource_prefix, full_column_name)
  }

  table[, COLUMN_NAME := NA_character_]
  table[, FHIR_ID_COLUMN_NAME := NA_character_]
  table[, REFERENCE_ID_COLUMN_NAME := NA_character_]
  resource_prefix <- NA

  expand_table_names <- names(expansion_tables)
  row <- 1
  last_row_index <- nrow(table)
  while (row <= last_row_index) {

    if (!is.na(table$RESOURCE[row])) {
      resource <- table$RESOURCE[row]
      if (!is.na(table$RESOURCE_PREFIX[row])) {
        resource_prefix <- paste0(table$RESOURCE_PREFIX[row], '_')
      } else {
        resource_prefix <- ""
      }
    }

    fhir_expression <- table$FHIR_EXPRESSION[row]
    stringAfterLastlash <- etlutils::getAfterLastSlash(fhir_expression)
    replace_table_index <- match(stringAfterLastlash, expand_table_names)
    if (!is.na(replace_table_index)) {
      fhir_expression <- substr(fhir_expression, 1, nchar(fhir_expression) - nchar(stringAfterLastlash))
      replace_prefix_column_name <- getFullColumnName(resource_prefix, fhir_expression)
      replace_prefix_fhir_expression <- etlutils::getBeforeLastSlash(table$FHIR_EXPRESSION[row])

      expansion_table <- data.table::copy(expansion_tables[[expand_table_names[replace_table_index]]])
      expansion_table[, COUNT := ifelse(is.na(COUNT), 1, COUNT) * table$COUNT[row]]

      # replace line with the content of the expansion table
      if (row == 1) {
        new_table <- expansion_table
      } else {
        new_table <- rbind(table[1:(row - 1)], expansion_table, fill = TRUE)
      }
      new_table <- rbind(new_table, table[(row + 1):nrow(table)], fill = TRUE)

      # Only for References: If the REFERENCE_TYPES column is filled for a Reference
      # which should be expanded -> write the REFERENCE_TYPES column value also to
      # the first column of the expanded reference
      new_table[row, REFERENCE_TYPES := table[row, REFERENCE_TYPES]]
      # same for the RESOURCE, RESOURCE_PREFIX
      new_table[row, RESOURCE := table[row, RESOURCE]]
      new_table[row, RESOURCE_PREFIX := table[row, RESOURCE_PREFIX]]

      for (expanded_row_index in 1:nrow(expansion_table)) {
        replaced_row_index <- as.integer(row + expanded_row_index - 1)
        if (nchar(replace_prefix_column_name)) {
          new_value <- paste0(replace_prefix_column_name, gsub("/", "_", expansion_table$FHIR_EXPRESSION[expanded_row_index]))
          data.table::set(new_table, replaced_row_index, "COLUMN_NAME", new_value)
        }
        if (nchar(replace_prefix_fhir_expression)) {
          data.table::set(new_table, replaced_row_index, 'FHIR_EXPRESSION', paste(replace_prefix_fhir_expression, new_table$FHIR_EXPRESSION[replaced_row_index], sep = "/"))
        }
      }

      last_row_index <- nrow(new_table)
      table <- new_table

    } else {
      # simple add the resource prefix to the fhir expression (with replaces slashes) and set it as column name
      full_column_name <- getFullColumnName(resource_prefix, fhir_expression)
      # replace strings in the resulting column names according to the given replace definition
      full_column_name <- etlutils::replacePatternsInString(replace_patterns, full_column_name, ignore.case = TRUE, perl = TRUE)
      # set the final trasformed column name for the fhir expression in this row
      table[row, COLUMN_NAME := full_column_name]
      row <- row + 1
    }

    reference_type <- new_table[row, REFERENCE_TYPES]
    if (!is.na(reference_type) && nchar(reference_type)) {
      new_table[row, FHIR_ID_COLUMN_NAME := paste0(resource_prefix, "id")]
      reference_prefix <- getResourceAbbreviation(table_description_collapsed, reference_type)
      new_table[row, REFERENCE_ID_COLUMN_NAME := paste0(reference_prefix, "_id")]
    }

  }

  # set the column 'COLUMN_NAME' directly in front of column 'FHIR_EXPRESSION'
  etlutils::moveColumnBefore(table, "COLUMN_NAME", "FHIR_EXPRESSION")
  # remove column RESOURCE_PREFIX
  table[, RESOURCE_PREFIX := NULL]
  # set all column_name entries to lower case
  table[, COLUMN_NAME := tolower(COLUMN_NAME)]
  # add empty row after every last entry of a resource (and before a new resource starts)
  table <- addEmptyRowsBeforeNewResource(table)

}

#' Expand Table Description from an Excel File
#'
#' This function reads a table description from an Excel file and expands it using specified expansion tables
#' also contained within the same Excel file. It is designed to facilitate the process of table expansion
#' by directly working with file-based inputs. The function automatically appends a '.xlsx' extension if not present,
#' determines the correct file path based on the execution context (interactive or package), reads the Excel file
#' into a list of tables, extracts the collapsed table description, and then applies the expansion logic.
#'
#' @param table_description_collapsed_excel_simple_filename The filename of the Excel file containing
#' the table description and expansion tables. The filename should not include the path or '.xlsx' extension.
#'
#' @return The function does not explicitly return a value but performs the expansion of the table description
#' as a side effect, utilizing other functions within the package to read the Excel file, extract relevant tables,
#' and expand the table description according to predefined rules.
#'
#' @seealso \code{\link[etlutils]{readExcelFileAsTableList}}, \code{\link{expandTableDescription}}
expandTableDescriptionFromFile <- function(table_description_collapsed_excel_simple_filename) {
  if (!grepl(".xlsx$", table_description_collapsed_excel_simple_filename)) {
    table_description_collapsed_excel_simple_filename <- paste0(table_description_collapsed_excel_simple_filename, ".xlsx")
  }
  if (interactive()) {
    table_description_file_path <- paste0("./R-cds2db/cds2db/inst/extdata/", table_description_collapsed_excel_simple_filename)
  } else {
    table_description_file_path <- system.file("extdata", table_description_collapsed_excel_simple_filename, package = "cds2db")
  }

  # Check if files exists
  if (!file.exists(table_description_file_path) || table_description_file_path == "") {
    current_dir <- getwd()
    stop("Error: The specified file path '", table_description_file_path,
         "' is invalid or the file does not exist.\nCurrent working directory: '",
         current_dir, "'")
  }

  tables <- etlutils::readExcelFileAsTableList(table_description_file_path)

  # extract the collapsed table description
  table_description_collapsed <- tables[["table_description_collapsed"]]
  # delete the extracted collapsed table description from tables list
  tables[["table_description_collapsed"]] <- NULL
  expandTableDescriptionInternal(table_description_collapsed, tables)
}

#' Expand Table Description from Definition File
#'
#' This function reads a table description from 'Table_Description_Definition.xlsx',
#' expands it, and then checks if any of the resulting column names exceed the maximum
#' length allowed for column names in Postgres databases (64 characters). If any column
#' names are too long, it prints a message with these column names. Otherwise, it writes
#' the expanded table description back to an Excel file named 'Table_Description.xlsx'.
#'
#' The function does not take any parameters and operates on a predefined Excel file.
#' It relies on 'expandTableDescriptionFromFile' for the initial table expansion and
#' uses 'etlutils::writeExcelFile' to save the expanded description.
#'
#' @details The function first expands the table description using
#' 'expandTableDescriptionFromFile', passing 'Table_Description_Definition.xlsx' as the
#' argument. It then checks the length of each column name in the expanded table
#' description. If any column names are longer than 64 characters, a message is printed
#' for each offending column name. If all column names are within the limit, a success
#' message is printed, and the expanded table description is saved to an Excel file.
#'
#' This function is particularly useful for preparing database schema definitions where
#' there are constraints on the length of column names, such as in Postgres databases.
#'
#' @return This function does not return a value but prints messages based on the length
#' of the column names in the expanded table description and may write the expanded table
#' description to an Excel file.
#'
#' @seealso \code{\link{expandTableDescriptionFromFile}}
expandTableDescription <- function() {
  expanded_table_description <- expandTableDescriptionFromFile("Table_Description_Definition.xlsx")
  if (checkResult(expanded_table_description)) {
    message("All result columns could be transformed or expanded.")
    # Add the "This file is generated..." header to the resut file
    header <- c(
      "Hint",
      "This file is generated by the R script 'Init_01_Expand_TableDescription'. Do not change it directly.",
      "If you want to add or remove columns for a resource or an entire table, change the Excel file",
      "'TableDescriptionDefinition' and execute the generation process via the init scripts in the cds2db module."
    )
    expanded_table_description <- etlutils::addTextHeaderToTable(expanded_table_description, header, insert_column_names_below_header = TRUE)

    table_description_file_name <- "./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx"
    etlutils::writeExcelFile(list("table_description" = expanded_table_description), "./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx", with_column_names = FALSE)
    message("Expanded Table Description is written to ", normalizePath(table_description_file_name))
  }
}

#' Check the Result of Expanded Table Description for Constraints
#'
#' Evaluates the expanded table description for specific constraints, such as the maximum length of column names
#' allowed in Postgres databases, and checks for duplicated column names. It prints error messages for violations
#' and provides suggestions for resolution.
#'
#' @param expanded_table_description A data.table object containing the expanded table description.
#' This table must include at least the columns 'column_name' and 'resource'.
#'
#' @return Logical value indicating whether the expanded table description passes the checks.
#' Returns `TRUE` if all checks pass (i.e., no column names exceed the maximum length and there are no duplicated column names),
#' otherwise `FALSE`.
#'
#' @details The function performs two main checks:
#' 1. It checks if any column names exceed 64 characters, which is the maximum allowed length for column names in Postgres databases.
#'    If any column names are too long, it prints an error message with the offending column names and suggests defining a replacement
#'    in the 'table_description_collapsed' section of the Table_Description_Definition.xlsx file to shorten these names.
#'
#' 2. It checks for duplicated column names within each 'resource' group. If duplicates are found, it prints an error message
#'    with the duplicated names and suggests checking the 'fhir_expression' entries in the Table_Description_Definition.xlsx file
#'    for potential duplicates.
#'
#' Error messages include specific solutions and notes to help address the identified issues.
#'
checkResult <- function(expanded_table_description) {
  isValid <- TRUE

  # check that there are no column names which exceeds the maximum length of 64 characters in Postgres DBs
  max_column_name_chars <- max(nchar(na.omit(expanded_table_description$COLUMN_NAME)))
  if (max_column_name_chars > 64) {
    message("ERROR: Some result column names are longer than the maximum of 64 chars, which are allowed for column names in Postgres databases.")
    for (s in expanded_table_description$COLUMN_NAME[which(nchar(na.omit(expanded_table_description$COLUMN_NAME)) > 64)]) {
      message(paste0("\t", s))
    }
    message(paste0("Solution: Define a replacement at the end of the table 'table_description_collapsed' in the ",
                   "Table_Description_Definition.xlsx file to shorten these column names.\n"))
    isValid <- FALSE
  }

  # Check that there are no duplicates in the defined columns
  column_names <- c()
  table_name <- NA
  for (row in seq_len(nrow(expanded_table_description))) {
    next_table_name <- expanded_table_description$RESOURCE[row]
    if (!is.na(table_name) && !is.na(next_table_name)) {
      duplicates <- column_names[which(duplicated(column_names))]
      if (length(duplicates)) {
        message("ERROR: Table ", table_name,  ": The following result column names (column 'COLUMN_NAMES') in Table_Description.xlsx are duplicated:")
        message(paste0("\t", duplicates, collapse = "\n"))
        message("Solution: Check entries in Table_Description_Definition.xlsx in column 'FHIR_EXPRESSION' for these duplicates.")
        message(paste0("Note: An entry such as 'subject/Reference' generates the entries 'subject/reference' and ",
                       "'subject/type', among others. If these then appear again in the list or 'subject/Reference' ",
                       "itself appears twice, this error occurs.\n"))
        isValid <- FALSE
      }
      resource <- expanded_table_description$RESOURCE[row]
      column_names <- c()
    }
    if (!is.na(next_table_name)) {
      table_name <- next_table_name
    }
    column_names[length(column_names) + 1] <- expanded_table_description$COLUMN_NAME[row]
  }

  # check that all entries have value in column 'SINGLE_LENGTH'
  invalid_rows <- which(!is.na(expanded_table_description$FHIR_EXPRESSION) & is.na(expanded_table_description$SINGLE_LENGTH))
  if (length(invalid_rows)) {
    message("ERROR: The following rows have no entry in column 'SINGLE_LENGTH'.")
    # Erfasse die Ausgabe von print() in einem Vektor
    message_data <- capture.output(print(expanded_table_description[invalid_rows]))
    # Verwende message(), um den Vektor Zeile für Zeile auszugeben
    message(paste(message_data, collapse = "\n"))
    message("SOLUTION: This may have the reason, that you forgot to set a single length in the description or a typo in the column 'FHIR_EXPRESSION' for a row that should be expanded.")
    isValid <- FALSE
  }
  return(isValid)
}
