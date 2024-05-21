# avoid check warning for data.table syntax is described here:
# https://www.r-bloggers.com/2019/08/no-visible-binding-for-global-variable/


#' Check if a table is valid.
#'
#' This function checks whether a table is valid by verifying that it is not NULL,
#' not NA, and has at least one row.
#'
#' @param table The table to be checked.
#'
#' @return TRUE if the table is valid (not NULL, not NA, and has at least one row),
#'         otherwise FALSE.
#'
#' @examples
#' # Check if a data.table is valid
#' library(data.table)
#' dt <- data.table(A = 1:3, B = c('X', 'Y', 'Z'))
#' isValid <- isValidTable(dt)
#' print(isValid)  # Output: TRUE
#'
#' @export
isValidTable <- function(table) {
  !is.null(table) && !all(is.na(table)) && nrow(table)
}

#' Add a new row to a data table.
#'
#' This function appends a new row to the end of a data table by combining the existing table with a new row
#' created from the provided values. The 'dt' parameter is the data table (data.table) to which the new row
#' will be appended, and the '...' parameter allows you to specify the values for the new row.
#'
#' @param dt A data table (data.table) to which a new row will be appended.
#' @param ... All values to fill a new row in the table.
#'
#' @return The data table with the added row. Note: all rows are converted to character type.
#'
#' @examples
#' library(data.table)
#'
#' # Create a sample data table
#' dt <- data.table(
#'   ID = 1:5,
#'   Name = c("Alice", "Bob", "Charlie", "David", "Eve"),
#'   Score = c(85, 92, 78, 65, 97)
#' )
#'
#' # Add a new row to the data table
#' dt <- addTableRow(dt, 6, 'Frank', 88)
#' print(dt)
#'
#' @export
addTableRow <- function(dt, ...) {
  rbind(
    dt,
    cbind(...),
    use.names = FALSE
  )
}

#'
#' Convert a list into a matrix with specified column count and fill value.
#'
#' This function takes a list and converts it into a matrix with the specified column count.
#' If the number of elements in the list is not a multiple of the column count, the 'fill' value
#' is used to pad the last row of the matrix. The resulting matrix is created with 'colCount' columns
#' and the number of rows is determined by dividing the length of the list by 'colCount'.
#'
#' @param list A list that should be converted into a matrix.
#' @param colCount The number of columns in the resulting matrix.
#' @param fill The value to fill missing values in the last row if the element count is not a
#'             multiple of the column count (default is NA).
#'
#' @return A matrix with the specified column count and optional padding in the last row.
#'
#' @examples
#' # Example 1: Convert a list into a matrix with 2 columns
#' my_list <- c(1, 2, 3, 4, 5, 6)
#' toMatrix(my_list, 2)
#'
#' # Example 2: Convert a list into a matrix with 3 columns and use 0 as the fill value
#' another_list <- c(1, 2, 3, 4, 5, 6, 7)
#' toMatrix(another_list, 3, fill = 0)
#'
#' # Example 3: Convert a list into a matrix with 4 columns and use "NA" as the fill value
#' yet_another_list <- c(1, 2, 3, 4, 5, 6, 7, 8)
#' toMatrix(yet_another_list, 4, fill = "NA")
#'
#' @export
toMatrix <- function(list, colCount, fill = NA) {
  while(length(list) %% colCount != 0) list <- c(list, fill)
  matrix(list, nrow = length(list) / colCount, byrow = TRUE)
}

#' Transform a list into a data.table with specified column names.
#'
#' This function takes a list and a corresponding list of column names (colNames)
#' to create a data.table. The 'colNames' list indicates the column count and column names
#' for the resulting table. The number of rows in the table is determined by dividing the
#' length of the input list by the column count.
#'
#' @param list The list that should be transformed into a table.
#' @param colNames A list of names that indicates the column count and column names.
#'
#' @return A data.table with the specified column count, column names, and row count
#'         determined by length(list) / column count.
#'
#' @examples
#' library(data.table)
#'
#' # Example 1: Transform a list into a data.table with 2 columns and specific column names
#' my_list <- c(1, 2, 3, 4, 5, 6)
#' col_names <- c("ColumnA", "ColumnB")
#' getTableFromList(my_list, col_names)
#'
#' # Example 2: Transform a list into a data.table with 3 columns and specific column names
#' another_list <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)
#' more_col_names <- c("First", "Second", "Third")
#' getTableFromList(another_list, more_col_names)
#'
#' @export
getTableFromList <- function(list, colNames) {
  colCount <- length(colNames)
  table <- data.table::data.table(toMatrix(list, colCount), check.names = FALSE)
  colnames(table) <- colNames
  return(table)
}

#' Read an Excel file and import each sheet as a separate data.table.
#'
#' This function reads an Excel file specified by the 'excelFile' parameter
#' and imports each sheet as a separate data.table. It returns a list of
#' imported sheets.
#'
#' @param excelFile The file path to the Excel file.
#' @param maxSheetIndex Maximum number of sheets to be read (default is 1000).
#'
#' @return A list of imported sheets as data.tables.
#'
#' @export
readExcelFileAsTableList <- function(excelFile, maxSheetIndex = 1000) {
  tables <- list()
  for (excelSheetIndex in 1:maxSheetIndex) {
    excelSheet <- try(setDT(openxlsx::read.xlsx(excelFile, excelSheetIndex, skipEmptyRows = FALSE, colNames = TRUE)), silent = TRUE)
    if (isError(excelSheet)) break
    tables <- append(tables, list(excelSheet))
  }
  sheetNames <- try(openxlsx::getSheetNames(excelFile), silent = TRUE)
  if (!isError(sheetNames)) {
    names(tables) <- sheetNames
  }
  tables
}

#' Write data to an Excel file using `openxlsx` package
#'
#' This function allows writing a data.frame or a list of objects to an Excel file.
#' The objects in the list should be compatible with `writeData()` or `writeDataTable()`
#' functions from the `openxlsx` package. It uses `write.xlsx` from `openxlsx` to perform the write operation.
#'
#' @param tables A `data.frame` or a (named) list of objects that can be handled by `writeData()`
#' or `writeDataTable()` from the `openxlsx` package to write to an Excel file.
#' @param file_name A string specifying the file path where the xlsx file will be saved.
#'
#' @return None
#'
#' @seealso \code{\link[openxlsx]{write.xlsx}} for the underlying function used to write Excel files.
#' @export
writeExcelFile <- function(tables, file_name) {
  openxlsx::write.xlsx(tables, file_name)
}

#' Read the first Excel file that matches the specified name pattern in the given directory.
#'
#' This function searches for Excel files in the specified directory that match the provided name pattern.
#' It reads the first matching Excel file and returns its sheets as data.tables.
#'
#' @param path The directory path where Excel files are located.
#' @param namePattern The name pattern to match Excel file names.
#'
#' @return A list of imported sheets as data.tables from the first matching Excel file,
#'         or NA if no matching file is found.
#'
#' @export
readFirstExcelFileAsTableList <- function(path, namePattern) {
  pattern <- paste0('.*', namePattern, '.*\\.xlsx$')
  excelFileNames <- list.files(path)
  excelFileNames <- excelFileNames[grepl(pattern, excelFileNames, perl = TRUE)]

  if (length(excelFileNames)) {
    for (i in 1:length(excelFileNames)) {
      if (!startsWith(excelFileNames[i], '~')) {
        excelFile <- file.path(path, excelFileNames[i])
        return(readExcelFileAsTableList(excelFile))
      }
    }
  }
  return(NA)
}

#' Replace Multiple Patterns in a Specific Column of a Data.Table
#'
#' This function replaces multiple patterns with a single replacement string
#' in a specified column of a data.table.
#'
#' @param dt A data.table containing the target column.
#' @param column_name The name of the column to perform replacements in.
#' @param patterns_to_replace A vector of patterns to search for in the column's values.
#' @param replacement The single replacement string to replace all matched patterns.
#' @param perl logical. Should Perl-compatible regexps be used?
#'
#' @return The updated data.table with specified patterns replaced by the single replacement
#'         string in the specified column.
#'
#' @examples
#' library(data.table)
#'
#' dt <- data.table(
#'   TextColumn = c("Hello,123world!", "This.is+an_example$123."),
#'   AnotherExample = c("This is a test.", "Test 123.")
#' )
#'
#' # Print the original data.table
#' print(dt)
#'
#' # Define patterns to replace as a vector
#' patterns_to_replace <- c("[0-9]", "[.,+]")
#'
#' # Define a single replacement string
#' replacement <- "*"
#'
#' # Call the function to replace patterns in the "TextColumn" column
#' dt <- replacePatternsInColumn(dt, "TextColumn", patterns_to_replace, replacement)
#'
#' # Print the updated data.table
#' print(dt)
#'
#' @export
replacePatternsInColumn <- function(dt, column_name, patterns_to_replace, replacement, perl = FALSE) {
  # Check if the specified column exists in the data.table
  if (!column_name %in% colnames(dt)) {
    return(dt)
  }

  # Loop through each pattern to replace
  for (pattern in patterns_to_replace) {
    # Binding the variable .SD locally to the function, so the R CMD check has nothing to complain about
    .SD <- NULL
    # Use gsub() to replace the pattern with the replacement in the specified column
    dt[, (column_name) := lapply(.SD, function(x) gsub(pattern, replacement, x, perl = perl)), .SDcols = column_name]
  }

  # Return the updated data.table
  return(dt)
}

#' Trim whitespace from charachter type values in a data.table or data.frame column
#'
#' This function trims leading and trailing whitespace from all character values
#' in a specified column or multiple columns of a data.table.
#'
#' @param dt A data.table or data.frame containing the target column(s).
#' @param colnames (Optional) A character vector of column names to trim.
#'                 If not specified, all columns in the data.table will be trimmed.
#'
#' @return The updated data.table or data.frame with leading and trailing whitespace trimmed
#'         from the specified column(s). In case of data.table the table will be changed by
#'         reference.
#'
#' @examples
#' library(data.table)
#'
#' df <- data.frame(
#'   col1 = c(1:4, NA),
#'   col2 = c(' A', 'B ', ' C ', ' ', NA)
#' )
#' print(dt)
#' df <- trimTableValues(df) # data.frame with assignment (pass by copy)
#' print(dt)
#'
#' # Example data.table
#' dt <- data.table(
#'   col1 = c(1:4),
#'   col2 = c(' A', 'B ', ' C ', ' ')
#' )
#' print(dt)
#' trimTableValues(dt)  # data.table without assignment (pass by reference)
#' print(dt)
#'
#' dt <- data.table(
#'   Column1 = c("  Hello  ", "  World  "),
#'   Column2 = c("  Test  ", "  Example  ")
#' )
#'
#' # Call the function to trim values in the "Column1" column
#' print(dt)
#' trimTableValues(dt, colnames = "Column1")
#' print(dt)
#'
#' @export
trimTableValues <- function(dt, colnames = NA) {
  isDataFrame <- !'data.table' %in% class(dt)
  if (isDataFrame) {
    setDT(dt) # Convert to data.table if it's a data.frame
  }

  if (is.na(colnames)) {
    colnames <- names(dt)
  }

  # Apply trimws only on character columns
  for (col in colnames) {
    if (is.character(dt[[col]]))
    dt[, (col) := trimws(get(col))]
  }

  if (isDataFrame) {
    setDF(dt) # Convert back to data.frame if the original input was a data.frame
  }

  return(dt)
}

#' Split a column into separate rows.
#'
#' This function takes a data.table and a column name containing strings with whitespace-separated values
#' and splits each value into a separate row, while retaining all other columns.
#'
#' @param dt The input data.table.
#' @param name_of_column_to_split The name of the column to split.
#' @param split The regular expression used to split values (default is '\\s+' for whitespace).
#'
#' @return A new data.table with the specified column split into separate rows, while retaining all other columns.
#'
#' @examples
#' library(data.table)
#' table2 <- data.table(
#'   ATC = c('A',     'B',       'C',         'D',     'E'),
#'   ICD = c('I', 'I0 H0', 'I01 H01', 'I01. H01.', 'I01.2'),
#'   SOMETHING_ELSE = 1:5
#' )
#' print(table2)
#' splitColumnToRows(table2, "ICD")
#'
#' @export
splitColumnToRows <- function(dt, name_of_column_to_split, split = '\\s+') {
  if (isValidTable(dt) && is.character(dt[[name_of_column_to_split]])) { # works only for character columns
    colNames <- names(dt)
    splitted <- strsplit(dt[[name_of_column_to_split]], split)
    dt <- cbind(dt[rep(seq_len(nrow(dt)), lengths(splitted)), !(..name_of_column_to_split)], irrelevant_column_name = unlist(splitted))
    names(dt)[length(names(dt))] <- name_of_column_to_split
    data.table::setcolorder(dt, colNames)
  }
  dt
}

#' Combine a List of data.tables into a single large data.table
#'
#' This function takes a list of data.tables with the same column names
#' and combines them into a single large data.table. It ensures that only
#' common columns are included in the resulting data.table.
#'
#' @param dt_list A list of data.tables to be combined.
#' @return A single data.table containing the combined data from the input list.
#' @examples
#' # Create a list of data.tables with common columns
#' library(data.table)
#' dt1 <- data.table(ID = 1:3, Value = c(10, 20, 30))
#' dt2 <- data.table(ID = 4:6, Value = c(40, 50, 60))
#' dt_list <- list(dt1, dt2)
#'
#' # Combine the data.tables into a single data.table
#' big_dt <- combineDataTables(dt_list)
#' print(dt1)
#' print(dt2)
#' print(big_dt)
#'
#' @export
combineDataTables <- function(dt_list) {
  # remove NA tables from table list
  dt_list <-  Filter(function(x) !all(is.na(x)), dt_list)
  if (length(dt_list) == 0) {
    return(NULL)
  }
  if (length(dt_list) == 1) {
    return(dt_list[[1]])
  }
  common_cols <- Reduce(intersect, lapply(dt_list, names))
  if (length(common_cols) == 0) {
    stop("No common columns found in the data.tables.")
  }
  combined_dt <- data.table::rbindlist(lapply(dt_list, function(dt) dt[, common_cols, with = FALSE]))
  return(combined_dt)
}

#' Remove rows with NA or empty values in all (!) specified columns. Emtpy means also string
#' only consisting of whitespaces.
#'
#' This function takes a data.table and a vector of column names as input and returns
#' a data.table where rows containing NA or empty values in the specified columns are removed.
#'
#' @param dt A data.table to process.
#' @param columns_to_check A character vector of column names to check for NA or empty values. If NA
#'                         then all columns will be checked.
#'
#' @return A modified data.table with rows removed based on the specified condition.
#'
#' @examples
#' # Example data.table
#' library(data.table)
#' my_data <- data.table(
#'   Column1 = c("Hello", "   World   ",   NA, "Example"),
#'   Column2 = c(      1,            NA,  " ",        NA),
#'   Column3 = c(    "A",           "B",   "",       "D")
#' )
#'
#' # Names of columns to check
#' columns_to_check <- c("Column1", "Column2", "Column3")
#'
#' # Remove rows with NA or empty values in specified columns
#' result_data <- removeRowsWithNAorEmpty(my_data, columns_to_check)
#' print(my_data)
#' print(result_data)
#'
#' # Example data.table
#' my_data <- data.table(
#'   Column1 = c("A", NA, "World", ""),
#'   Column2 = c(1, NA, 2, NA),
#'   Column3 = c("A", " ", "", NA)
#' )
#' print(my_data)
#' # Names of columns to check
#' columns_to_check <- c("Column1", "Column3")
#' # Remove rows with NA or empty values in specified columns
#' result_data <- removeRowsWithNAorEmpty(my_data)
#' print(result_data)
#'
#' @export
removeRowsWithNAorEmpty <- function(dt, columns_to_check = NA) {
  # Check if the provided data.table is empty
  if (nrow(dt) == 0) {
    return(dt)
  }
  if (isSimpleNA(columns_to_check)) {
    columns_to_check <- names(dt)
  }
  # Check the condition for each row in the data.table
  rows_to_remove <- apply(dt[, ..columns_to_check, with = FALSE], 1, function(row) {
    all(is.na(row) | (nchar(trimws(row)) == 0))
  })

  # Remove the rows that satisfy the condition
  dt <- dt[!rows_to_remove]

  return(dt)
}

#' Get the index of the first row in a data table that matches specified patterns in its columns.
#'
#' This function searches for the first row in a data table that contains matches for a set of specified patterns
#' in its columns. If the number of patterns to be matched is greater than the number of columns, it returns -1.
#'
#' @param table A data table to search for matching rows.
#' @param patterns A character vector of patterns to be matched in the columns of the table.
#' @param grep Logical, indicating whether to use `grepl` for pattern matching. Default is FALSE.
#'
#' @return The index of the first row that matches all the specified patterns, or -1 if not found.
#'
#' @examples
#' library(data.table)
#' table <- data.table(
#'   col1 = c('AAAA', 'A', 'AA', 'AAA'),
#'   col2 = c('BBBB', 'B', 'BB', 'BBB'),
#'   col3 = c('CCCC', 'C', 'CC', 'CCC'),
#'   col4 = c('DDDD', 'D', 'DD', 'DDD')
#' )
#'
#' # Find the index of the first row that contains "BBB" and "DDD" in the data table
#' index <- getFirstRowWithPatterns(table, c('BBB', 'DDD'))
#' print(index) # Output should be 4
#'
#' # Find the index of the first row that contains "BBB" or "DDD" in the data table using grepl
#' index <- getFirstRowWithPatterns(table, c('BBB', 'DDD'), TRUE)
#' print(index) # Output should be 1
#'
#' @export
getFirstRowWithPatterns <- function(table, patterns, grep = FALSE) {
  numColumns <- ncol(table)
  numPatterns <- length(patterns)

  # Check if the number of patterns is greater than the number of columns
  if (numPatterns > numColumns) {
    return(-1)
  }

  matchesPatterns <- function(row) {
    rowMatchesCount <- 0 # number of patterns
    for (colIndex in seq_len(length(row))) {
      if ((grep && grepl(patterns[rowMatchesCount + 1], row[[colIndex]])) || (!grep && patterns[rowMatchesCount + 1] %in% row[[colIndex]])) {
        rowMatchesCount <- rowMatchesCount + 1
        if (rowMatchesCount == numPatterns) {
          return(TRUE)
        }
      } else if (numColumns - colIndex < numPatterns - rowMatchesCount) { # more patterns left than columns
        break
      }
    }
    return(FALSE)
  }

  if (matchesPatterns(names(table))) {
    return(0)
  }

  for (rowIndex in seq_len(nrow(table))) {
    if (matchesPatterns(c(table[rowIndex]))) {
      return(rowIndex)
    }
  }

  return(-1)
}

#' Remove rows in a data.table up to a specified index
#'
#' This function removes all rows in a data.table up to the specified index (inclusive).
#'
#' @param dt Data table.
#' @param index Index of the row up to which rows will be removed.
#' @return The data.table with rows removed up to the specified index.
#'
#' @examples
#' # Create a sample data.table
#' library(data.table)
#' dt <- data.table(
#'   ID = 1:6,
#'   Name = c("John", "Alice", "Bob", "Eve", "Mike", "Sara"),
#'   Age = c(25, 30, 22, 28, 32, 35)
#' )
#'
#' print(dt)
#' # Remove rows up to index 3
#' dt <- removeRowsUpToIndex(dt, 3)
#' print(dt)
#'
#' @export
removeRowsUpToIndex <- function(dt, index) {
  if (index >= 1 && index <= nrow(dt)) {
    dt <- dt[-seq_len(index)]
  }
  return(dt)
}

#' Remove the table header from a data table.
#'
#' This function removes the rows above the row containing column names
#' that match the specified patterns. It then updates the column names
#' in the data table.
#'
#' @param dt A data table with a header that needs to be removed.
#' @param pattern_list A list of patterns to identify the row with column names.
#'
#' @return The data table with the header removed and updated column names.
#'
#' @examples
#' library(data.table)
#'
#' # Create a sample data table with a header
#' dt <- data.table(
#'   X1 = c("Table XYZ", "", "Name", "John", "Alice", "Bob"),
#'   X2 = c("", "", "Age", "25", "30", "22"),
#'   X3 = c("", "", "Country", "USA", "Canada", "UK")
#' )
#' print(dt)
#'
#' # Define patterns for the header row
#' header_patterns <- c("Name", "Age", "Country")
#'
#' # Remove the header and update column names
#' dt <- removeTableHeader(dt, header_patterns)
#' print(dt)
#'
#' @export
removeTableHeader <- function(dt, pattern_list) {
  colNamesRowIndex <- getFirstRowWithPatterns(dt, pattern_list)
  if (colNamesRowIndex < 0) {
    return(NA)
  }
  if (colNamesRowIndex > 0) {
    colNames <- unlist(dt[colNamesRowIndex, ])
    dt <- removeRowsUpToIndex(dt, colNamesRowIndex)
    names(dt) <- colNames
  }
  return(dt)
}

#' Retain specified columns in a data table.
#'
#' This function retains only the columns in a data table that are listed in the
#' provided 'columnNames'. All other columns will be removed from the data table.
#'
#' @param table A data table from which columns will be retained.
#' @param columnNames A character vector containing the names of columns to be retained.
#' If NA (default) then no column will be removed and the full input table will be returned.
#'
#' @return The data table with only the specified columns retained. The object is changed
#' by reference.
#'
#' @examples
#' library(data.table)
#'
#' # Create a sample data table
#' dt <- data.table(
#'   ID = 1:3,
#'   Name = c("John", "Alice", "Bob"),
#'   Age = c(25, 30, 22),
#'   Country = c("USA", "Canada", "UK")
#' )
#'
#' # Specify the columns to be retained
#' columns_to_retain <- c("ID", "Name")
#'
#' # Retain only the specified columns
#' dt <- retainColumns(dt, columns_to_retain)
#' print(dt)
#'
#' @export
retainColumns <- function(table, columnNames = NA) {
  if (!isSimpleNA(columnNames)) {
    names <- names(table)
    names <- names[!(names %in% columnNames)]
    table[, (names) := NULL]
  }
  return(table)
}

#' Convert list or vector columns to character in a data.table
#'
#' This function takes a data.table and converts all list-type columns into
#' character columns by concatenating the list elements with a specified separator.
#'
#' @param dt The input data.table.
#' @param separator The separator to use when concatenating list elements (default is " ~ ").
#'
#' @return Returns the modified data.table with list columns converted to character columns.
#'
#' @examples
#' library(data.table)
#'
#' # Create example data
#' dt <- data.table(
#'   ID = 1:3,
#'   Names = list(c("Alice", "Bob"), c("Charlie", "David"), c("Eve", "Frank")),
#'   Scores = list(c(85, 92), c(78, 89), c(95, 88))
#' )
#' print(dt)
#'
#' # Convert list columns to character columns
#' dt <- convertListColumnsToString(dt)
#' print(dt)
#'
#' @export
convertListColumnsToString <- function(dt, separator = " ~ ") {
  # Loop through all columns in the data.table
  for (col_name in names(dt)) {
    # Check if the column has a "list" type
    if (is.list(dt[[col_name]])) {
      # Loop through the list elements and concatenate them
      for (i in seq_len(nrow(dt))) {
        if (!is.null(dt[[col_name]][[i]]) && !all(is.na(dt[[col_name]][[i]]))) {
          newValue <- as.character(paste(dt[[col_name]][[i]], collapse = separator))
          dt[i, (col_name) := newValue]
        }
      }
      # change column class to character
      dt[, (col_name) := as.character(get(col_name))]
    }
  }
  return(dt)
}

#' Get the index of a column in a data.table by its name.
#'
#' This function returns the index of the first column in a data.table that matches
#' the specified column name.
#'
#' @param table A data.table.
#' @param columnName The name of the column to search for.
#'
#' @return The index of the specified column, or 0 if the column is not found.
#'
#' @examples
#' library(data.table)
#'
#' # Create a sample data.table
#' dt <- data.table(ID = 1:5, Name = c("Alice", "Bob", "Charlie", "David", "Eve"))
#'
#' # Get the index of the "Name" column
#' index <- getcolumnIndex(dt, "Name")
#' print(index)  # Output: [1] 2
#'
#' # Try to get the index of a non-existing column
#' index <- getcolumnIndex(dt, "Age")
#' print(index)  # Output: [1] 0
#'
#' # Try to get the index of column name NA
#' index <- getcolumnIndex(dt, NA)
#' print(index)  # Output: [1] 0
#'
#' @export
getcolumnIndex <- function(table, columnName) {
  if (is.data.table(table) && is.character(columnName) && length(columnName) == 1) {
    names <- names(table)
    for (i in seq_len(length(names))) {
      if (names[i] %in% columnName) {
        return(i)
      }
    }
  }
  return(0)
}

#' Move a column in a data.table directly before another column based on indices
#'
#' This function takes a data.table, the name of the column to be moved, and
#' the name of the target column before which the first column should be placed.
#' It adjusts the order of the columns in the data.table accordingly by manipulating
#' column indices, without altering other columns' order unnecessarily.
#'
#' @param dt A data.table object.
#' @param column_to_move The name of the column to move.
#' @param target_column The name of the column before which to place the moved column.
#'
#' @return The data.table with adjusted column order. The original data.table is modified by reference.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(x = 1:3, y = 4:6, z = 7:9)
#' moveColumnBefore(dt, "y", "z")
#' print(dt) # Should show columns in the order x, z, y
#'
#' @export
moveColumnBefore <- function(dt, column_to_move, target_column) {
  # Find the current positions of the columns
  cols <- names(dt)
  move_index <- which(cols == column_to_move)
  target_index <- which(cols == target_column)

  new_order <- c(cols[-c(move_index)], cols[move_index])
  # Adjust if move_index is before target_index, considering direct placement before target
  if (move_index >= target_index) {
    # Correct the order for when the column is moved forward
    target_index <- target_index + (target_index > move_index)
    new_order <- c(new_order[1:(target_index - 1)], new_order[length(new_order)], new_order[target_index:(length(new_order) - 1)])
  }

  # Apply the new order
  setcolorder(dt, new_order)
}

#' Print a summary for a table
#'
#' This function prints a summary for the specified table, including information
#' about the class, type, number of available values, and number of missing values
#' for each column. The summary is displayed in a formatted table.
#'
#' @param table The input table to summarize. For example, you can use the mtcars dataset.
#' @param table_name An optional name for the table, used in the summary output.
#' @return This function does not explicitly return a value. It prints the summary to the console.
#'
#' @examples
#' # Load required packages
#' library(datasets)
#' library(data.table)
#'
#' # Load the mtcars dataset and convert it to a data.table
#' data(mtcars)
#' setDT(mtcars)
#'
#' # Print summary for the mtcars table
#' printTable_summary(table = mtcars, table_name = 'mtcars')
#'
#' @export
printTable_summary <- function(table, table_name = '') {
  dt <- data.table::as.data.table(
    cbind(
      class      = sapply(names(table), function(n) class(table[[n]])[1]), #shows only the first specified class
      type       = sapply(names(table), function(n) typeof(table[[n]])),
      available  = sapply(names(table), function(n) sum(!is.na(table[[n]]))),
      missing    = sapply(names(table), function(n) sum( is.na(table[[n]])))
    ),
    keep.rownames = TRUE
  )
  if (0 < nrow(dt)) {
    cat(
      createFrameString(
        text = paste0(
          'Table: ', table_name, '\n\n  # Rows:    ', nrow(table), '\n  # Columns: ', ncol(table), '\n\n',
          dataTableAsCharacter(
            data.table::setnames(
              x = dt,
              new = c('Column', 'Class', 'Type', 'Available', 'Missing')
            ),
            header = TRUE,
            footer = TRUE
          )
        ),
        edge = c('\u231c\u231d\u231e\u231f'),
        hori = ' ',
        vert = ' '
      )
    )
  } else {
    cat(
      createFrameString(
        text = paste0(
          'Table: ', table_name, '\n\n  # Rows:    ', nrow(table), '\n  # Columns: ', ncol(table), '\n\n'
        ),
        edge = c('\u231c\u231d\u231e\u231f'),
        hori = ' ',
        vert = ' '
      )
    )
  }
}

#' Convert Data.Table to Character String
#'
#' This function converts a data.table to a formatted character string with optional header and footer.
#'
#' @param dt A data.table to be converted.
#' @param header Logical, indicating whether to include a header with column names.
#' @param footer Logical, indicating whether to include a footer with column names.
#' @return A formatted character string representation of the data.table.
#'
#' @details
#' The function converts a data.table to a character string, aligning columns and optionally including a header and footer.
#' It pads each column to the maximum width of its elements for better alignment.
#'
#' @export
dataTableAsCharacter <- function(dt, header = FALSE, footer = FALSE) {
  # Binding the variable .SD locally to the function, so the R CMD check has nothing to complain about
  .SD <- NULL
  d <- if (header) rbind(as.list(names(dt)), dt) else dt
  if (footer) d <- rbind(d, as.list(names(dt)))
  l <- d[,lapply(.SD, function(x) max(nchar(x)))]
  d <- data.table::as.data.table(lapply(seq_along(d), function(i) stringr::str_pad(string = d[[i]], width = l[[i]], side = 'left', pad = ' ')))
  paste0(
    sapply(
      seq_len(nrow(d)),
      function(i) {
        paste0(d[i, ], collapse = '  ')
      }
    ),
    collapse = '\n'
  )
}

#' Complete Table with Missing Columns
#'
#' This function completes a table by adding missing columns based on the specified table description.
#'
#' @param table A data.table representing the table to be completed.
#' @param table_description A description of the expected table structure.
#'
#' @return A completed data.table with missing columns added.
#' @export
complete_table <- function(table, table_description) {
  # Binding the variable .SD locally to the function, so the R CMD check has nothing to complain about
  .SD <- NULL
  col_names <- names(table_description@cols)
  empty_table <- data.table::setnames(
    data.table::data.table(matrix(ncol = length(col_names), nrow = 0)),
    new = col_names
  )
  d <- data.table::rbindlist(list(empty_table, table), fill = TRUE, use.names = TRUE)
  d[, lapply(.SD, function(x) methods::as(x, 'character'))]
}

#' Fill NA Values with Last Observed Value in Specified Columns of a data.table
#'
#' This function fills NA values in a data.table by carrying forward the last observed value.
#' If an NA value is found, it is replaced by the most recent non-NA value in the column.
#' If the first value in a column is NA, it remains NA.
#'
#' @param dt A data.table object in which NA values need to be filled.
#' @param columns A vector of column names to be processed. If NA (default), all columns are processed.
#' @return A data.table with NA values filled.
#' @examples
#' library(data.table)
#' dt <- data.table(A = c(1, NA, NA, 4, 5), B = c("x", NA, "z", NA, NA))
#' fillNAWithLastRowValue(dt)
#' fillNAWithLastRowValue(dt, columns = "B")
#' @export
fillNAWithLastRowValue <- function(dt, columns = NA) {
  # if columns parameter is NA -> take all columns
  if (is.na(columns)) {
    columns <- names(dt)
  }

  # fill NA values
  dt[, (columns) := lapply(.SD, function(x) {
    for (i in 2:length(x)) {
      if (is.na(x[i])) {
        x[i] <- x[i-1]
      }
    }
    return(x)
  }), .SDcols = columns]

  return(dt)
}

#' Split a data.table into a List by a Specified Column
#'
#' This function splits a data.table into a list of data.tables based on the unique values in a
#' specified column. Each list element contains the rows where the value in the specified column
#' is the same.
#'
#' @param dt A data.table to be split.
#' @param split_columnname A character string specifying the column name by which to split the
#' data.table.
#' @param fill_na_in_split_columnname A logical value indicating whether to fill NA values in the
#' specified column with the last non-NA value. Default is TRUE.
#' @return A list of data.tables, with each element containing the rows with the same value in the
#' specified column. The names of the list elements are set to the unique values of the specified
#' column.
#' @examples
#' library(data.table)
#' dt <- data.table(
#'   SCRIPTNAME = c("A", "A", "B", "B", "C"),
#'   VALUE = 1:5
#' )
#' result <- splitTableToList(dt, "SCRIPTNAME")
#' print(result)
#' @export
splitTableToList <- function(dt, split_columnname, fill_na_in_split_columnname = TRUE) {
  if (fill_na_in_split_columnname) {
    fillNAWithLastRowValue(dt, split_columnname)
  }
  list <- split(dt, by = split_columnname, keep.by = TRUE)
  # set names for list elements
  names(list) <- sapply(list, function(x) x[[split_columnname]][1])
  return(list)
}
