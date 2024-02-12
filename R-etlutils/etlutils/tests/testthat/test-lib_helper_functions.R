##############
# isSimpleNA #
##############

# Test for simple NA
test_that("isSimpleNA returns TRUE for a simple NA", {
  x <- NA
  expect_true(isSimpleNA(x))
})

# Test for vector with multiple elements including NA
test_that("isSimpleNA returns FALSE for a vector with multiple elements", {
  y <- c(1, NA, 3)
  expect_false(isSimpleNA(y))
})

# Test for non-NA values
test_that("isSimpleNA returns FALSE for non-NA values", {
  z <- 1
  expect_false(isSimpleNA(z))
  a <- "Hello"
  expect_false(isSimpleNA(a))
})

# Test for other types of NA values
test_that("isSimpleNA handles other types of NA values correctly", {
  na_int <- NA_integer_
  expect_true(isSimpleNA(na_int))
  na_real <- NA_real_
  expect_true(isSimpleNA(na_real))
  na_char <- NA_character_
  expect_true(isSimpleNA(na_char))
})

# Test for empty values or NULL
test_that("isSimpleNA returns FALSE for empty values or NULL", {
  empty_vec <- numeric(0)
  expect_false(isSimpleNA(empty_vec))
  null_val <- NULL
  expect_false(isSimpleNA(null_val))
})

######################
# isSimpleTrueOrNot0 #
######################

# Test for simple TRUE
test_that("isSimpleTrueOrNot0 returns TRUE for a simple TRUE", {
  expect_true(isSimpleTrueOrNot0(TRUE))
})

# Test for non-zero numeric value
test_that("isSimpleTrueOrNot0 returns TRUE for a non-zero numeric value", {
  expect_true(isSimpleTrueOrNot0(1))
  expect_true(isSimpleTrueOrNot0(-1))
})

# Test for 0 as input value
test_that("isSimpleTrueOrNot0 returns FALSE for 0", {
  expect_false(isSimpleTrueOrNot0(0))
})

# Test for vector with multiple elements
test_that("isSimpleTrueOrNot0 returns FALSE for a vector with multiple elements", {
  expect_false(isSimpleTrueOrNot0(c(TRUE, TRUE)))
})

# Test for false values and other data types
test_that("isSimpleTrueOrNot0 returns FALSE for FALSE and other data types", {
  expect_false(isSimpleTrueOrNot0(FALSE))
  expect_false(isSimpleTrueOrNot0("TRUE"))
  expect_false(isSimpleTrueOrNot0(NA))
})

####################
# isSimpleFalseOr0 #
####################

# Test for simple FALSE
test_that("isSimpleFalseOr0 returns TRUE for a simple FALSE", {
  expect_true(isSimpleFalseOr0(FALSE))
})

# Test for 0 as input value
test_that("isSimpleFalseOr0 returns TRUE for 0", {
  expect_true(isSimpleFalseOr0(0))
})

# Test for non-zero numeric value
test_that("isSimpleFalseOr0 returns FALSE for a non-zero numeric value", {
  expect_false(isSimpleFalseOr0(1))
  expect_false(isSimpleFalseOr0(-1))
})

# Test for vector with multiple elements
test_that("isSimpleFalseOr0 returns FALSE for a vector with multiple elements", {
  expect_false(isSimpleFalseOr0(c(FALSE, FALSE)))
})

# Test for true values and other data types
test_that("isSimpleFalseOr0 returns FALSE for TRUE and other data types", {
  expect_false(isSimpleFalseOr0(TRUE))
  expect_false(isSimpleFalseOr0("FALSE"))
  expect_false(isSimpleFalseOr0(NA))
})

##########################
# isSimpleNotEmptyString #
##########################

# Test for non-empty character string
test_that("isSimpleNotEmptyString returns TRUE for a non-empty character string", {
  expect_true(isSimpleNotEmptyString("hello"))
})

# Test for empty character string
test_that("isSimpleNotEmptyString returns FALSE for an empty character string", {
  expect_false(isSimpleNotEmptyString(""))
})

# Test for NA value
test_that("isSimpleNotEmptyString returns FALSE for NA", {
  expect_false(isSimpleNotEmptyString(NA))
})

# Test for numeric value
test_that("isSimpleNotEmptyString returns FALSE for a numeric value", {
  expect_false(isSimpleNotEmptyString(123))
})

# Test for vector with multiple elements
test_that("isSimpleNotEmptyString returns FALSE for a vector with multiple elements", {
  expect_false(isSimpleNotEmptyString(c("hello", "world")))
})

###

 # Hier fehlen noch Tests für viele Funktionen

##

###########################
# replacePatternsInString #
###########################

# Test for case-insensitive replacement
test_that("replacePatternsInString performs case-insensitive replacement correctly", {
  patternsAndReplacements <- list("HELLO" = "hi", "WORLD" = "earth")
  result <- replacePatternsInString(patternsAndReplacements, "Hello World!", ignore.case = TRUE)
  expect_equal(result, "hi earth!")
})

# Test for case-sensitive replacement
test_that("replacePatternsInString performs case-sensitive replacement correctly", {
  patternsAndReplacements <- list("Hello" = "hi", "World" = "earth")
  result <- replacePatternsInString(patternsAndReplacements, "Hello World!", ignore.case = FALSE)
  expect_equal(result, "hi earth!")
})

# Test for Perl-compatible regex usage
test_that("replacePatternsInString handles Perl-compatible regexps correctly", {
  patternsAndReplacements <- list("\\bworld\\b" = "earth")
  result <- replacePatternsInString(patternsAndReplacements, "Hello world!", perl = TRUE)
  expect_equal(result, "Hello earth!")
})

# Test for combination of ignore.case and perl
test_that("replacePatternsInString handles combination of ignore.case and perl correctly", {
  patternsAndReplacements <- list("\\bWORLD\\b" = "earth")
  result <- replacePatternsInString(patternsAndReplacements, "Hello WORLD!", ignore.case = TRUE, perl = TRUE)
  expect_equal(result, "hello earth!")
})

# Test when no matches are found
test_that("replacePatternsInString returns the original string when no matches are found", {
  patternsAndReplacements <- list("xyz" = "abc")
  result <- replacePatternsInString(patternsAndReplacements, "hello world!", ignore.case = FALSE)
  expect_equal(result, "hello world!")
})
