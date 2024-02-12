################
# isValidTable #
################
test_that('Test isValidTable()', {
  expect_false(isValidTable(NA))
  expect_false(isValidTable(NULL))
  expect_false(isValidTable(data.table()))
  expect_false(isValidTable(data.table(col1 = c(NA, NA))))
  expect_true(isValidTable(data.table(col1 = 'AAA')))
})

###############
# addTableRow #
###############

test_that('Test addTableRow', {
  # Create a sample data table
  dt <- data.table(
    ID = 1:5,
    Name = c("Alice", "Bob", "Charlie", "David", "Eve"),
    Score = c(85, 92, 78, 65, 97)
  )
  expect_equal(nrow(dt), 5)

  # Add a new row to the data table
  # addTableRow converts all columns to character
  dt <- addTableRow(dt, 6, 'Frank', 88)

  expect_equal(nrow(dt), 6)
  expect_equal(dt[6][[1]], '6')
  expect_equal(dt[6][[2]], 'Frank')
  expect_equal(dt[6][[3]], '88')
})

############
# toMatrix #
############

# Test 1: Checks whether the conversion to a matrix with 2 columns works correctly
test_that("toMatrix converts a list into a matrix with specified column count correctly", {
  my_list <- c(1, 2, 3, 4, 5, 6)
  result_matrix <- toMatrix(my_list, 2)
  expect_equal(dim(result_matrix), c(3, 2))
  expect_equal(result_matrix[3, 2], 6)
})

# Test 2: Checks whether the fill value is used correctly if the number of elements is not a multiple of the number of columns
test_that("toMatrix uses fill value correctly when list length is not a multiple of column count", {
  another_list <- c(1, 2, 3, 4, 5, 6, 7)
  result_matrix <- toMatrix(another_list, 3, fill = 0)
  expect_equal(dim(result_matrix), c(3, 3))
  expect_equal(result_matrix[3, 3], 0)
})

# Test 3: Checks whether the default fill value is used correctly
test_that("toMatrix uses default fill value correctly", {
  yet_another_list <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)
  result_matrix <- toMatrix(yet_another_list, 4)
  expect_equal(dim(result_matrix), c(3, 4))
  expect_true(is.na(result_matrix[3, 4]))
})

####################
# getTableFromList #
####################

# Assuming toMatrix is already correctly implemented and tested
# Test for getTableFromList function
test_that("getTableFromList transforms a list into a data.table with specified column names correctly", {
  # Test 1: Simple transformation with 2 columns
  my_list <- c(1, 2, 3, 4, 5, 6)
  col_names <- c("ColumnA", "ColumnB")
  result_table <- getTableFromList(my_list, col_names)

  # Verify the structure and content
  expect_true(is.data.table(result_table))
  expect_equal(colnames(result_table), col_names)
  expect_equal(nrow(result_table), length(my_list) / length(col_names))
  expect_equal(ncol(result_table), length(col_names))

  # Test 2: Transformation with 3 columns
  another_list <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)
  more_col_names <- c("First", "Second", "Third")
  result_table_2 <- getTableFromList(another_list, more_col_names)

  # Verify the structure and content for the second test
  expect_true(is.data.table(result_table_2))
  expect_equal(colnames(result_table_2), more_col_names)
  expect_equal(nrow(result_table_2), length(another_list) / length(more_col_names))
  expect_equal(ncol(result_table_2), length(more_col_names))
})

############################
# readExcelFileAsTableList #
############################

# integration test for readExcelFileAsTableList
test_that("readExcelFileAsTableList imports Excel sheets correctly", {
  # Setup: Use a predefined Excel file for testing
  test_file_path <- system.file("extdata", "test_excel_file.xlsx", package = "etlutils")

  # Action: Read the Excel file
  result <- try(readExcelFileAsTableList(test_file_path))

  # Verify: Check if the result is as expected
  expect_true(is.list(result), info = "The result should be a list.")
  expect_equal(length(result), 2, info = "The result list should contain two data.tables for the two sheets.")
  expect_equal(names(result), c('mtcars_with_description_lines', 'mtcars_without_description_line'))

  # reading non existing files returns an empty list
  result <- readExcelFileAsTableList('not_existing_file_path')
  expect_true(length(result) == 0 && is.list(result))
})

#################################
# readFirstExcelFileAsTableList #
#################################

# Test for readFirstExcelFileAsTableList function
test_that("readFirstExcelFileAsTableList reads the first matching Excel file correctly", {
  # Define the path to the test directory (assuming the working directory is the package root)
  test_path <- system.file("extdata", package = "etlutils")

  # Define the name pattern to search for
  name_pattern <- "test_excel_file"

  # Execute the function
  result <- readFirstExcelFileAsTableList(test_path, name_pattern)

  # Verify the result
  expect_true(is.list(result), info = "The result should be a list.")
  expect_equal(length(result), 2, info = "The result list should contain two data.tables for the two sheets.")

  # Further checks can be added to verify the content of the data.tables if needed
  # For example, checking the number of rows and columns of each data.table in the list
})

###########################
# replacePatternsInColumn #
###########################

# Test for basic functionality
test_that("replacePatternsInColumn replaces patterns correctly", {
  dt <- data.table(TextColumn = c("Hello,123world!", "This.is+an_example$123."))
  patterns_to_replace <- c("[0-9]", "[.,+_!]")
  replacement <- "*"

  expected <- data.table(TextColumn = c("Hello****world*", "This*is*an*example$****"))

  result <- replacePatternsInColumn(dt, "TextColumn", patterns_to_replace, replacement)

  expect_equal(result, expected)
})

# Test for column existence
test_that("replacePatternsInColumn handles non-existing columns correctly", {
  dt <- data.table(TextColumn = c("Hello,123world!"))
  result <- replacePatternsInColumn(dt, "NonExistingColumn", c("[0-9]"), "*")

  expect_equal(dt, result)
})

# Test to ensure other columns remain unchanged
test_that("replacePatternsInColumn does not alter other columns", {
  dt <- data.table(TextColumn = c("Hello,123world!"), UnchangedColumn = c("Unchanged 123 text"))
  patterns_to_replace <- c("[0-9]")
  replacement <- "*"

  result <- replacePatternsInColumn(dt, "TextColumn", patterns_to_replace, replacement)

  expect_equal(result$TextColumn, c("Hello,***world!"))
  expect_equal(result$UnchangedColumn, c("Unchanged 123 text"))
})

###################
# trimTableValues #
###################

# Test trimming functionality for data.frame
test_that("trimTableValues correctly trims all columns in a data.frame", {
  df <- data.frame(
    col1 = c("  A  ", "  B"),
    col2 = c("C  ", " D ")
  )
  expected_df <- data.frame(
    col1 = c("A", "B"),
    col2 = c("C", "D")
  )
  result_df <- trimTableValues(df)
  expect_equal(result_df, expected_df)
})

# Test trimming specified columns in a data.table
test_that("trimTableValues correctly trims specified columns in a data.table", {
  dt <- data.table(
    Column1 = c("  Hello  ", "  World  "),
    Column2 = c("  Test  ", "  Example  ")
  )
  expected_dt <- data.table(
    Column1 = c("Hello", "World"),
    Column2 = c("  Test  ", "  Example  ")
  )
  trimTableValues(dt, colnames = "Column1")
  expect_equal(dt, expected_dt)
})

# Test ignoring non-character columns
test_that("trimTableValues ignores non-character columns", {
  dt <- data.table(
    col1 = c(1, 2),
    col2 = c("  A  ", "  B  ")
  )
  expected_dt <- data.table(
    col1 = c(1, 2),
    col2 = c("A", "B")
  )
  trimTableValues(dt)
  expect_equal(dt, expected_dt)
})

# Test with NA and empty strings
test_that("trimTableValues handles NA and empty strings correctly", {
  dt <- data.table(
    col1 = c("  ", NA, "  C  ")
  )
  expected_dt <- data.table(
    col1 = c("", NA, "C")
  )
  trimTableValues(dt)
  expect_equal(dt, expected_dt)
})

#####################
# splitColumnToRows #
#####################

# Test for basic functionality with "~" as delimiter
test_that("splitColumnToRows splits column into separate rows correctly using ' ~ ' as delimiter", {
  dt <- data.table(
    ID = c(1, 2),
    Text = c("A ~ B", "C ~ D"),
    Other = c(100, 200)
  )
  result <- splitColumnToRows(dt, "Text", split = " ~ ")
  expected <- data.table(
    ID = c(1, 1, 2, 2),
    Text = c("A", "B", "C", "D"),
    Other = c(100, 100, 200, 200)
  )
  expect_equal(result, expected)
})

# Test for handling of columns with no "~" characters
test_that("splitColumnToRows handles columns with no ' ~ ' characters correctly", {
  dt <- data.table(
    ID = c(1, 2),
    Text = c("A", "B"),
    Other = c(100, 200)
  )
  result <- splitColumnToRows(dt, "Text", split = " ~ ")
  expect_equal(result, dt) # Should remain unchanged
})

# Test for preservation of other column values with "~" as delimiter
test_that("splitColumnToRows preserves other column values correctly using ' ~ ' as delimiter", {
  dt <- data.table(
    ID = c(1),
    Text = c("A ~ B"),
    Other = c(100)
  )
  result <- splitColumnToRows(dt, "Text", split = " ~ ")
  expect_equal(result$Other, rep(100, 2))
})

# Test for edge cases with " ~ " as delimiter
test_that("splitColumnToRows handles edge cases correctly using ' ~ ' as delimiter", {
  dt <- data.table(
    ID = c(1, 2, 3, 4),
    Text = c("  ", NA, "A ~ ~ B", "C ~  ~  ~ D"),
    Other = c(100, 200, 300, 400)
  )
  result <- splitColumnToRows(dt, "Text", split = " ~ ")
  expected <- data.table(
    ID = c(1, 2, 3, 3, 4, 4, 4, 4),
    Text = c("  ", NA, "A", "~ B", "C", "", "", "D"),
    Other = c(100, 200, 300, 300, 400, 400, 400, 400)
  )
  # The NA value remains unchanged, and "A ~ ~ B" correctly splits into "A" and "B",
  # considering the delimiter " ~ " and ignoring the empty string between two "~".
  expect_equal(result, expected)
})

#####################
# combineDataTables #
#####################

# Test for basic functionality
test_that("combineDataTables combines data.tables with common columns correctly", {
  dt1 <- data.table(ID = 1:3, Value = c(10, 20, 30))
  dt2 <- data.table(ID = 4:6, Value = c(40, 50, 60))
  dt_list <- list(dt1, dt2)
  result <- combineDataTables(dt_list)
  expected <- data.table(ID = 1:6, Value = c(10, 20, 30, 40, 50, 60))
  expect_equal(result, expected)
})

# Test for handling different columns
test_that("combineDataTables includes only common columns", {
  dt1 <- data.table(ID = 1:3, Value1 = c(10, 20, 30))
  dt2 <- data.table(ID = 4:6, Value2 = c(40, 50, 60))
  dt_list <- list(dt1, dt2)
  result <- combineDataTables(dt_list)
  expected <- data.table(ID = 1:6)
  expect_equal(result, expected)
  expect_false("Value1" %in% names(result))
  expect_false("Value2" %in% names(result))
})

# Test for empty list
test_that("combineDataTables returns NULL for empty list", {
  dt_list <- list()
  result <- combineDataTables(dt_list)
  expect_null(result)
})

# Test for list with one element
test_that("combineDataTables works correctly with a list of one data.table", {
  dt1 <- data.table(ID = 1:3, Value = c(10, 20, 30))
  dt_list <- list(dt1)
  result <- combineDataTables(dt_list)
  expect_equal(result, dt1)
})

# Test for list with NA or empty data.tables
test_that("combineDataTables handles list with NA or empty data.tables correctly", {
  dt1 <- data.table(ID = 1:3, Value = c(10, 20, 30))
  dt_list <- list(dt1, NA, data.table())
  result <- combineDataTables(dt_list)
  expect_equal(result, dt1)
})

###########################
# removeRowsWithNAorEmpty #
###########################

# Test for basic functionality: remove rows where all specified columns are NA or empty
test_that("removeRowsWithNAorEmpty correctly removes rows where all specified columns are NA or empty", {
  my_data <- data.table(
    Column1 = c("A", NA, "World", ""),
    Column2 = c(1, NA, 2, NA),
    Column3 = c("A", " ", "", NA)
  )
  columns_to_check <- c("Column1", "Column3") # Check these columns for NA or empty values
  result_data <- removeRowsWithNAorEmpty(my_data, columns_to_check)
  expected_data <- data.table(
    Column1 = c("A", "World"),
    Column2 = c(1, 2),
    Column3 = c("A", "")
  )
  expect_equal(result_data, expected_data)
})

# Test for no rows removed: when no row has all specified columns as NA or empty
test_that("removeRowsWithNAorEmpty does not remove rows if not all specified columns are NA or empty", {
  my_data <- data.table(
    Column1 = c("Hello", "World", "Again"),
    Column2 = c(1, NA, 3),
    Column3 = c("A", "B", "")
  )
  columns_to_check <- c("Column1", "Column2") # Column3 not considered for removal criteria
  result_data <- removeRowsWithNAorEmpty(my_data, columns_to_check)
  expect_equal(result_data, my_data) # Expect no rows to be removed
})

# Test for strings with whitespaces treated as empty
test_that("removeRowsWithNAorEmpty treats strings of whitespaces as empty", {
  my_data <- data.table(
    Column1 = c("Hello", "   ", NA),
    Column2 = c("World", "Universe", "Galaxy"),
    Column3 = c("A", " ", NA)
  )
  columns_to_check <- c("Column1", "Column3")
  result_data <- removeRowsWithNAorEmpty(my_data, columns_to_check)
  expected_data <- data.table(
    Column1 = c("Hello"),
    Column2 = c("World"),
    Column3 = c("A")
  )
  expect_equal(result_data, expected_data)
})

# Test for mixed data types with NA and empty values across specified columns
test_that("removeRowsWithNAorEmpty handles mixed data types and correctly removes rows with NA and empty values across specified columns", {
  my_data <- data.table(
    Column1 = c("Hello", NA, "World", NA),
    Column2 = c(1, 2, 3, 4),
    Column3 = c("A", NA, "B", " ")
  )
  columns_to_check <- c("Column1", "Column3")
  result_data <- removeRowsWithNAorEmpty(my_data, columns_to_check)
  expected_data <- data.table(
    Column1 = c("Hello", "World"),
    Column2 = c(1, 3),
    Column3 = c("A", "B")
  )
  expect_equal(result_data, expected_data)
})

###########################
# getFirstRowWithPatterns #
###########################

# Test for basic functionality with exact match (grep = FALSE)
test_that("getFirstRowWithPatterns returns correct index with exact match", {
  table <- data.table(
    col1 = c('AAAA', 'A', 'AA', 'AAA'),
    col2 = c('BBBB', 'B', 'BB', 'BBB'),
    col3 = c('CCCC', 'C', 'CC', 'CCC'),
    col4 = c('DDDD', 'D', 'DD', 'DDD')
  )
  index <- getFirstRowWithPatterns(table, c('BBB', 'DDD'), grep = FALSE)
  expect_equal(index, 4)
})

# Test for using grepl for pattern matching (grep = TRUE)
test_that("getFirstRowWithPatterns returns correct index using grepl", {
  table <- data.table(
    col1 = c('AAAA', 'A', 'AA', 'AAA'),
    col2 = c('BBBB', 'B', 'BB', 'BBB'),
    col3 = c('CCCC', 'C', 'CC', 'CCC'),
    col4 = c('DDDD', 'D', 'DD', 'DDD')
  )
  index <- getFirstRowWithPatterns(table, c('BB', 'DD'), grep = TRUE)
  expect_equal(index, 1)
})

# Test when no match is found
test_that("getFirstRowWithPatterns returns -1 when no match is found", {
  table <- data.table(
    col1 = c('AAAA', 'A', 'AA', 'AAA'),
    col2 = c('BBBB', 'B', 'BB', 'BBB'),
    col3 = c('CCCC', 'C', 'CC', 'CCC'),
    col4 = c('DDDD', 'D', 'DD', 'DDD')
  )
  index <- getFirstRowWithPatterns(table, c('ZZZ', 'XXX'), grep = FALSE)
  expect_equal(index, -1)
})

# Test when the number of patterns is greater than the number of columns
test_that("getFirstRowWithPatterns returns -1 when the number of patterns is greater than the number of columns", {
  table <- data.table(
    col1 = c('AAAA', 'A', 'AA', 'AAA'),
    col2 = c('BBBB', 'B', 'BB', 'BBB'),
    col3 = c('CCCC', 'C', 'CC', 'CCC')
  )
  index <- getFirstRowWithPatterns(table, c('A', 'B', 'C', 'D', 'E'), grep = FALSE)
  expect_equal(index, -1)
})

#######################
# removeRowsUpToIndex #
#######################

# Test for removing rows up to a valid index
test_that("removeRowsUpToIndex correctly removes rows up to a specified index", {
  dt <- data.table(ID = 1:6, Name = c("John", "Alice", "Bob", "Eve", "Mike", "Sara"), Age = c(25, 30, 22, 28, 32, 35))
  result_dt <- removeRowsUpToIndex(dt, 3)
  expected_dt <- data.table(ID = 4:6, Name = c("Eve", "Mike", "Sara"), Age = c(28, 32, 35))
  expect_equal(result_dt, expected_dt)
})

# Test for index out of bounds
test_that("removeRowsUpToIndex does nothing if index is out of bounds", {
  dt <- data.table(ID = 1:6, Name = c("John", "Alice", "Bob", "Eve", "Mike", "Sara"), Age = c(25, 30, 22, 28, 32, 35))
  result_dt <- removeRowsUpToIndex(dt, 7) # Index greater than nrow(dt)
  expect_equal(result_dt, dt)
  result_dt <- removeRowsUpToIndex(dt, 0) # Index less than 1
  expect_equal(result_dt, dt)
})

# Test for removing all rows
test_that("removeRowsUpToIndex removes all rows if index equals nrow(dt)", {
  dt <- data.table(ID = 1:6, Name = c("John", "Alice", "Bob", "Eve", "Mike", "Sara"), Age = c(25, 30, 22, 28, 32, 35))
  result_dt <- removeRowsUpToIndex(dt, 6)
  expect_equal(nrow(result_dt), 0)
})

#####################
# removeTableHeader #
#####################

# Test for correct removal of the header and updating column names
test_that("removeTableHeader correctly removes header and updates column names", {
  dt <- data.table(
    X1 = c("Table Info", "", "Name", "John", "Alice", "Bob"),
    X2 = c("", "", "Age", "25", "30", "22"),
    X3 = c("", "", "Country", "USA", "Canada", "UK")
  )
  pattern_list <- c("Name", "Age", "Country")
  result_dt <- removeTableHeader(dt, pattern_list)
  expected_dt <- data.table(
    Name = c("John", "Alice", "Bob"),
    Age = c("25", "30", "22"),
    Country = c("USA", "Canada", "UK")
  )
  expect_equal(result_dt, expected_dt)
})

# Test when header is not found
test_that("removeTableHeader returns NA when header is not found", {
  dt <- data.table(
    X1 = c("John", "Alice", "Bob"),
    X2 = c("25", "30", "22"),
    X3 = c("USA", "Canada", "UK")
  )
  pattern_list <- c("Name", "Age", "Country")
  result <- removeTableHeader(dt, pattern_list)
  expect_equal(result, NA)
})

# Test when header is the first row
test_that("removeTableHeader works correctly when header is the first row", {
  dt <- data.table(
    X1 = c("Name", "John", "Alice", "Bob"),
    X2 = c("Age", "25", "30", "22"),
    X3 = c("Country", "USA", "Canada", "UK")
  )
  pattern_list <- c("Name", "Age", "Country")
  result_dt <- removeTableHeader(dt, pattern_list)
  expected_dt <- data.table(
    Name = c("John", "Alice", "Bob"),
    Age = c("25", "30", "22"),
    Country = c("USA", "Canada", "UK")
  )
  expect_equal(result_dt, expected_dt)
})

#################
# retainColumns #
#################

# Test for retaining specified columns
test_that("retainColumns correctly retains only specified columns", {
  dt <- data.table(
    ID = 1:3,
    Name = c("John", "Alice", "Bob"),
    Age = c(25, 30, 22),
    Country = c("USA", "Canada", "UK")
  )
  columns_to_retain <- c("ID", "Name")
  result_dt <- retainColumns(dt, columns_to_retain)
  expected_dt <- data.table(
    ID = 1:3,
    Name = c("John", "Alice", "Bob")
  )
  expect_equal(result_dt, expected_dt)
})

# Test handling NA in columnNames
test_that("retainColumns does nothing if columnNames is NA", {
  dt <- data.table(
    ID = 1:3,
    Name = c("John", "Alice", "Bob"),
    Age = c(25, 30, 22)
  )
  result_dt <- retainColumns(dt, NA)
  expect_equal(result_dt, dt)
})

# Test column names not in data.table
test_that("retainColumns handles column names not present in the data.table", {
  dt <- data.table(
    ID = 1:3,
    Name = c("John", "Alice", "Bob")
  )
  columns_to_retain <- c("ID", "NonExistingColumn")
  result_dt <- retainColumns(dt, columns_to_retain)
  expected_dt <- data.table(
    ID = 1:3
  )
  expect_equal(result_dt, expected_dt)
})

# Test empty data.table
test_that("retainColumns handles empty data.table correctly", {
  dt <- data.table()
  columns_to_retain <- c("ID", "Name")
  result_dt <- retainColumns(dt, columns_to_retain)
  expect_equal(result_dt, data.table())
})

##############################
# convertListColumnsToString #
##############################

# Test for converting list columns to character columns
test_that("convertListColumnsToString correctly converts list columns to character columns", {
  dt <- data.table(
    ID = 1:3,
    Names = list(c("Alice", "Bob"), c("Charlie", "David"), c("Eve", "Frank")),
    Scores = list(c(85, 92), c(78, 89), c(95, 88))
  )
  result_dt <- convertListColumnsToString(dt)
  expected_dt <- data.table(
    ID = 1:3,
    Names = c("Alice ~ Bob", "Charlie ~ David", "Eve ~ Frank"),
    Scores = c("85 ~ 92", "78 ~ 89", "95 ~ 88")
  )
  expect_equal(result_dt, expected_dt)
})

# Test for handling non-list columns
test_that("convertListColumnsToString does not alter non-list columns", {
  dt <- data.table(
    ID = 1:2,
    Name = c("Alice", "Bob")
  )
  result_dt <- convertListColumnsToString(dt)
  expect_equal(result_dt, dt)
})

# Test for empty lists and lists with NA values
test_that("convertListColumnsToString handles empty lists and lists with NA values correctly", {
  dt <- data.table(
    ID = 1:2,
    Names = list(c(), c(NA, NA)) # will not be changed by convertListColumnsToString(dt)
  )
  result_dt <- convertListColumnsToString(dt)
  expect_equal(result_dt, dt)
})

# Test for custom separator
test_that("convertListColumnsToString works with custom separator", {
  dt <- data.table(
    ID = 1:2,
    Names = list(c("Alice", "Bob"), c("Charlie", "David"))
  )
  result_dt <- convertListColumnsToString(dt, separator = ", ")
  expected_dt <- data.table(
    ID = 1:2,
    Names = c("Alice, Bob", "Charlie, David")
  )
  expect_equal(result_dt, expected_dt)
})

##################
# getcolumnIndex #
##################

# Test for finding an existing column name
test_that("getcolumnIndex returns correct index for an existing column name", {
  dt <- data.table(ID = 1:5, Name = c("Alice", "Bob", "Charlie", "David", "Eve"))
  index <- getcolumnIndex(dt, "Name")
  expect_equal(index, 2)
})

# Test for handling a non-existing column name
test_that("getcolumnIndex returns 0 for a non-existing column name", {
  dt <- data.table(ID = 1:5, Name = c("Alice", "Bob", "Charlie", "David", "Eve"))
  index <- getcolumnIndex(dt, "Age")
  expect_equal(index, 0)
})

# Test for handling NA as column name
test_that("getcolumnIndex returns 0 for NA as column name", {
  dt <- data.table(ID = 1:5, Name = c("Alice", "Bob", "Charlie", "David", "Eve"))
  index <- getcolumnIndex(dt, NA)
  expect_equal(index, 0)
})

####################
# moveColumnBefore #
####################

test_that("moveColumnBefore correctly reorders columns", {
  dt <- data.table(a = 1:3, b = 4:6, c = 7:9)
  moveColumnBefore(dt, "b", "c")
  expect_equal(names(dt), c("a", "c", "b"))

  dt <- data.table(a = 1:3, b = 4:6, c = 7:9)
  moveColumnBefore(dt, "a", "c")
  expect_equal(names(dt), c("b", "c", "a"))
})

test_that("moveColumnBefore does not change the data", {
  dt <- data.table(a = 1:3, b = 4:6, c = 7:9)
  original_dt <- data.table::copy(dt)
  moveColumnBefore(dt, "b", "c")
  expect_equal(dt$a, original_dt$a)
  expect_equal(dt$b, original_dt$b)
  expect_equal(dt$c, original_dt$c)
})

test_that("moveColumnBefore handles non-existing columns", {
  dt <- data.table(a = 1:3, b = 4:6, c = 7:9)
  expect_error(moveColumnBefore(dt, "x", "c"))
  expect_error(moveColumnBefore(dt, "a", "y"))
})

test_that("moveColumnBefore with already correct order does nothing", {
  dt <- data.table(a = 1:3, b = 4:6, c = 7:9)
  original_order <- names(dt)
  moveColumnBefore(dt, "b", "c")
  expect_equal(names(dt), original_order)
})
