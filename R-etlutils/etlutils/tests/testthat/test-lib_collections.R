####################
# namedListByParam #
####################

# Test case 1: Basic Named List Creation
test_that("namedListByParam creates a named list with simple numeric variables", {
  a <- 1
  b <- 2
  c <- 3
  result <- namedListByParam(a, b, c)
  expected <- list(a = 1, b = 2, c = 3)
  expect_equal(result, expected)
})

# Test case 2: Multiple Types
test_that("namedListByParam handles variables of different types", {
  x <- 42
  y <- "hello"
  z <- TRUE
  result <- namedListByParam(x, y, z)
  expected <- list(x = 42, y = "hello", z = TRUE)
  expect_equal(result, expected)
})

# Test case 3: Data Tables
test_that("namedListByParam handles data table variables", {
  table1 <- data.table(column1 = 1:5, column2 = letters[1:5])
  table2 <- data.table(column1 = 6:10, column2 = letters[6:10])
  result <- namedListByParam(table1, table2)
  expected <- list(table1 = table1, table2 = table2)
  expect_equal(result, expected)
})

# Test case 4: Empty Input
test_that("namedListByParam handles empty input correctly", {
  result <- namedListByParam()
  expected <- list()
  expect_equal(result, expected)
})

####################
# namedListByValue #
####################

# Test case 1: Simple character vector
test_that("namedListByValue creates a named list with simple character vector", {
  values <- c("apple", "banana", "cherry")
  result <- namedListByValue(values)
  expected <- list(apple = "apple", banana = "banana", cherry = "cherry")
  expect_equal(result, expected)
})

# Test case 2: Vector with duplicated values
test_that("namedListByValue handles duplicated values correctly", {
  values <- c("apple", "banana", "apple")
  result <- namedListByValue(values)
  expected <- list(apple = "apple", banana = "banana", apple = "apple")
  expect_equal(result, expected)
})

# Test case 3: Numeric vector
test_that("namedListByValue handles numeric vector correctly", {
  values <- c(1, 2, 3)
  result <- namedListByValue(values)
  expected <- list(`1` = 1, `2` = 2, `3` = 3)
  expect_equal(result, expected)
})

###################
# sortListByValue #
###################

# Test case 1: Simple case with character values
test_that("sortListByValue sorts a list with character values", {
  unsorted_list <- list(b = "pear", a = "apple", c = "banana")
  result <- sortListByValue(unsorted_list)
  expected <- list(a = "apple", c = "banana", b = "pear")
  expect_equal(result, expected)
})

# Test case 2: List with numeric values
test_that("sortListByValue sorts a list with numeric values", {
  unsorted_list <- list(b = 3, a = 1, c = 2)
  result <- sortListByValue(unsorted_list)
  expected <- list(a = 1, c = 2, b = 3)
  expect_equal(result, expected)
})

# Test case 3: List with mixed types
test_that("sortListByValue sorts a list with mixed types", {
  unsorted_list <- list(b = "banana", a = 1, c = "apple")
  result <- sortListByValue(unsorted_list)
  expected <- list(a = 1, c = "apple", b = "banana")
  expect_equal(result, expected)
})

# Test case 4: Handle empty list
test_that("sortListByValue handles an empty list", {
  unsorted_list <- list()
  result <- sortListByValue(unsorted_list)
  expected <- list()
  expect_equal(result, expected)
})

# Test case 5: List with duplicated values
test_that("sortListByValue sorts a list with duplicated values", {
  unsorted_list <- list(b = "apple", a = "banana", c = "apple")
  result <- sortListByValue(unsorted_list)
  expected <- list(b = "apple", c = "apple", a = "banana")
  expect_equal(result, expected)
})

##################
# sortListByName #
##################

# Test case 1: Simple case with character values
test_that("sortListByName sorts a list with character values by names", {
  unsorted_list <- list(b = "pear", a = "apple", c = "banana")
  result <- sortListByName(unsorted_list)
  expected <- list(a = "apple", b = "pear", c = "banana")
  expect_equal(result, expected)
})

# Test case 2: List with numeric values
test_that("sortListByName sorts a list with numeric values by names", {
  unsorted_list <- list(b = 3, a = 1, c = 2)
  result <- sortListByName(unsorted_list)
  expected <- list(a = 1, b = 3, c = 2)
  expect_equal(result, expected)
})

# Test case 3: List with mixed types
test_that("sortListByName sorts a list with mixed types by names", {
  unsorted_list <- list(b = "banana", a = 1, c = "apple")
  result <- sortListByName(unsorted_list)
  expected <- list(a = 1, b = "banana", c = "apple")
  expect_equal(result, expected)
})

# Test case 4: Handle empty list
test_that("sortListByName handles an empty list", {
  unsorted_list <- list()
  result <- sortListByName(unsorted_list)
  expected <- list()
  expect_equal(result, expected)
})

# Test case 5: List with duplicated values
test_that("sortListByName sorts a list with duplicated values by names", {
  unsorted_list <- list(c = "apple", a = "banana", b = "apple")
  result <- sortListByName(unsorted_list)
  expected <- list(a = "banana", b = "apple", c = "apple")
  expect_equal(result, expected)
})

###########
# catList #
###########

my_list <- list(a = 1, b = list(x = 10, y = NA), c = 3, d = "")

# Test to check if catList correctly prints a simple list without any prefix or suffix
test_that("catList prints simple list without prefix or suffix", {
  expected_output <- "a = 1\nb = 10, NA\nc = 3\nd = "
  output <- capture.output(catList(my_list))
  expect_equal(paste(output, collapse = "\n"), expected_output)
})

# Test to verify that catList works with a specified prefix and suffix
test_that("catList works with prefix and suffix", {
  expected_output <- "Start:\na = 1\nb = 10, NA\nc = 3\nd = \nEnd"
  output <- capture.output(catList(my_list, prefix = "Start:\n", suffix = "End\n"))
  expect_equal(paste(output, collapse = "\n"), expected_output)
})

# Test to ensure catList hides values based on the specified pattern
test_that("catList hides values based on pattern", {
  expected_output <- "a = 1\nb = <Not empty list>\nc = 3\nd = "
  output <- capture.output(catList(my_list, hide_value_pattern = "b"))
  expect_equal(paste(output, collapse = "\n"), expected_output)
})

# Test to check that catList behaves normally with an empty hide_value_pattern
test_that("catList works with empty hide_value_pattern", {
  expected_output <- "a = 1\nb = 10, NA\nc = 3\nd = "
  output <- capture.output(catList(my_list, hide_value_pattern = ""))
  expect_equal(paste(output, collapse = "\n"), expected_output)
})

# Test to verify how catList handles lists containing NA and empty strings
test_that("catList handles list with NA and empty string", {
  expected_output <- "a = 1\nb = $x\n[1] 10\n\n$y\n[1] NA\n\nc = <Not empty double value>\nd = "
  output <- capture.output(catList(my_list, hide_value_pattern = "c"))
  expect_equal(paste(output, collapse = "\n"), expected_output)
})

# Test to verify behavior with complex nested lists
test_that("catList handles complex nested lists", {
  complex_list <- list(a = 1, b = list(x = 10, y = list(z = 20)), c = 3)
  expected_output <- "a = 1\nb = 10, list(z = 20)\nc = 3"
  output <- capture.output(catList(complex_list))
  expect_equal(paste(output, collapse = "\n"), expected_output)
})

# Test to verify that empty lists are handled correctly
test_that("catList handles empty lists", {
  empty_list <- list()
  expected_output <- ""
  output <- capture.output(catList(empty_list))
  expect_equal(paste(output, collapse = "\n"), expected_output)
})
