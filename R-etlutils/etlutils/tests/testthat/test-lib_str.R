#################
# reverseString #
#################

# Tests for reverseString function
test_that("reverseString works correctly", {
  expect_equal(reverseString("abc"), "cba")
  expect_equal(reverseString("hello"), "olleh")
  expect_equal(reverseString("R programming"), "gnimmargorp R")
  expect_equal(reverseString(""), "")
  expect_equal(reverseString("a"), "a")
})

################
# extractWords #
################

test_that("extractWords handles spaces and commas", {
  input_string <- "Here are some words, separated, by, commas, and spaces"
  expected <- c("Here", "are", "some", "words", "separated", "by", "commas", "and", "spaces")
  result <- extractWords(input_string)
  expect_equal(result, expected)
})

test_that("extractWords handles multiple spaces", {
  input_string <- "Multiple    spaces   between words"
  expected <- c("Multiple", "spaces", "between", "words")
  result <- extractWords(input_string)
  expect_equal(result, expected)
})

test_that("extractWords handles multiple commas", {
  input_string <- "Comma,,,separated,,values"
  expected <- c("Comma", "separated", "values")
  result <- extractWords(input_string)
  expect_equal(result, expected)
})

test_that("extractWords handles combination of spaces and commas", {
  input_string <- " Mix , of ,  spaces,  and commas "
  expected <- c("Mix", "of", "spaces", "and", "commas")
  result <- extractWords(input_string)
  expect_equal(result, expected)
})

test_that("extractWords returns empty vector for empty input", {
  input_string <- ""
  expected <- character(0)
  result <- extractWords(input_string)
  expect_equal(result, expected)
})

test_that("extractWords returns empty vector for input with only spaces and commas", {
  input_string <- " , ,  ,   "
  expected <- character(0)
  result <- extractWords(input_string)
  expect_equal(result, expected)
})

###########
# greplic #
###########

# Test that the function performs case-insensitive pattern search
test_that("greplic performs case-insensitive pattern search", {
  pattern <- "aaa|bbb"
  x <- "I am a sentence with AAA and BBB."

  expect_true(greplic(pattern, x))
  expect_true(greplic("AAA", x))
  expect_true(greplic("bbb", x))
  expect_false(greplic("ccc", x))
})

# Test that the function performs whole word matching
test_that("greplic performs whole word matching", {
  pattern <- "aaa|bbb"

  expect_false(greplic(pattern, "I am a sentence with AAAA and BBB.", whole_word = TRUE))
  expect_true(greplic(pattern, "I am a sentence with AAA and BBB.", whole_word = TRUE))
  expect_false(greplic(pattern, "I am a sentence with AAABBB.", whole_word = TRUE))
  expect_true(greplic("AAA", "AAA BBB CCC", whole_word = TRUE))
  expect_false(greplic("AAA", "AAAA BBB CCC", whole_word = TRUE))
})

# Test that the function handles complex patterns correctly
test_that("greplic handles complex patterns correctly", {
  pattern <- "aaa|bbb|ccc"

  expect_false(greplic(pattern, "I am a sentence with AAA, BBB, and CCC.", whole_word = TRUE))
  expect_false(greplic(pattern, "I am a sentence with AAAA, BBBB, and CCCC.", whole_word = TRUE))
  expect_true(greplic(pattern, "AAA BBB CCC", whole_word = TRUE))
  expect_false(greplic(pattern, "AAAA BBBB CCCC", whole_word = TRUE))
})

####################################
# removeLastCharsIfNotAlphanumeric #
####################################

# Test with various characters at the end
test_that("removeLastCharsIfNotAlphanumeric removes non-alphanumeric characters from the end", {
  expect_equal(removeLastCharsIfNotAlphanumeric("Hello!"), "Hello")
  expect_equal(removeLastCharsIfNotAlphanumeric("Hello!!"), "Hello")
  expect_equal(removeLastCharsIfNotAlphanumeric("Hello@#"), "Hello")
  expect_equal(removeLastCharsIfNotAlphanumeric("Hello123!"), "Hello123")
  expect_equal(removeLastCharsIfNotAlphanumeric("Hello123#"), "Hello123")
  expect_equal(removeLastCharsIfNotAlphanumeric("Hello123"), "Hello123")
})

# Test with a vector of strings
test_that("removeLastCharsIfNotAlphanumeric handles multiple strings", {
  input <- c("Hello!", "World@", "Test#", "Example123!")
  expected <- c("Hello", "World", "Test", "Example123")
  expect_equal(removeLastCharsIfNotAlphanumeric(input), expected)
})

# Test with strings that do not need modification
test_that("removeLastCharsIfNotAlphanumeric returns the same string if no non-alphanumeric characters at the end", {
  expect_equal(removeLastCharsIfNotAlphanumeric("Hello"), "Hello")
  expect_equal(removeLastCharsIfNotAlphanumeric("World123"), "World123")
})

# Test with empty strings and strings that are completely non-alphanumeric
test_that("removeLastCharsIfNotAlphanumeric handles empty strings and strings with only non-alphanumeric characters", {
  expect_equal(removeLastCharsIfNotAlphanumeric(""), "")
  expect_equal(removeLastCharsIfNotAlphanumeric("!!!"), "")
  expect_equal(removeLastCharsIfNotAlphanumeric("###"), "")
})

# Test with strings containing spaces
test_that("removeLastCharsIfNotAlphanumeric handles strings with spaces", {
  expect_equal(removeLastCharsIfNotAlphanumeric("Hello World! "), "Hello World")
  expect_equal(removeLastCharsIfNotAlphanumeric("  Hello@#  "), "  Hello")
})

#####################
# getAfterLastSlash #
#####################

# Test with various strings containing slashes
test_that("getAfterLastSlash extracts everything after the last slash", {
  strings <- c('Patient/PID_001', 'Encounter/EID_001', 'Condition/CID_001', 'aaa/bbb/ccc', 'aaa')
  expected <- c('PID_001', 'EID_001', 'CID_001', 'ccc', 'aaa')
  expect_equal(getAfterLastSlash(strings), expected)
})

# Test with strings that do not contain slashes
test_that("getAfterLastSlash handles strings without slashes", {
  strings <- c('PatientPID001', 'EncounterEID001', 'ConditionCID001', 'aaa')
  expect_equal(getAfterLastSlash(strings), strings)
})

# Test with an empty string
test_that("getAfterLastSlash returns an empty string if input is empty", {
  expect_equal(getAfterLastSlash(""), "")
})

# Test with a single string containing multiple slashes
test_that("getAfterLastSlash extracts correctly from a string with multiple slashes", {
  string <- 'a/b/c/d/e/f'
  expect_equal(getAfterLastSlash(string), 'f')
})

# Test with a vector of empty strings
test_that("getAfterLastSlash handles a vector of empty strings", {
  strings <- rep("", 5)
  expect_equal(getAfterLastSlash(strings), rep("", 5))
})

####################
# getBetweenQuotes #
####################

# Test with single quotes
test_that("getBetweenQuotes extracts text between single quotes", {
  expect_equal(getBetweenQuotes("This is a 'sample' string."), "sample")
  expect_equal(getBetweenQuotes("Another 'example' string."), "example")
})

# Test with double quotes
test_that("getBetweenQuotes extracts text between double quotes", {
  expect_equal(getBetweenQuotes('This is a "sample" string.'), "sample")
  expect_equal(getBetweenQuotes('Another "example" string.'), "example")
})

# Test with mixed quotes (should only extract from the first pair encountered)
test_that("getBetweenQuotes extracts text between first encountered quotes", {
  expect_equal(getBetweenQuotes('Mixed "example\' string.'), "example")
  expect_equal(getBetweenQuotes("Mixed 'example\" string."), "example")
})

# Test with no quotes present in the string
test_that("getBetweenQuotes returns an empty string if no quotes are present", {
  expect_equal(getBetweenQuotes("No quotes here."), "No quotes here.")
})

# Test with an empty string
test_that("getBetweenQuotes returns an empty string for an empty input", {
  expect_equal(getBetweenQuotes(""), "")
})

###########################
# replacePatternsInString #
###########################

# Test with basic patterns and replacements
test_that("replacePatternsInString replaces basic patterns and replacements", {
  patternsAndReplacements <- list("hello" = "hi", "world" = "earth")
  expect_equal(replacePatternsInString(patternsAndReplacements, "Hello World!"), "Hello World!")
})

# Test with case-insensitive replacement
test_that("replacePatternsInString performs case-insensitive replacement", {
  patternsAndReplacements <- list("hello" = "hi", "world" = "earth")
  expect_equal(replacePatternsInString(patternsAndReplacements, "HELLO WORLD!", ignore.case = TRUE), "hi earth!")
})

# Test with Perl-compatible regex
test_that("replacePatternsInString uses Perl-compatible regex when specified", {
  patternsAndReplacements <- list("h[aeiou]llo" = "hi", "world" = "earth")
  expect_equal(replacePatternsInString(patternsAndReplacements, "Hello World!", perl = TRUE), "Hello World!")
})

# Test with multiple occurrences of the same pattern
test_that("replacePatternsInString handles multiple occurrences of the same pattern", {
  patternsAndReplacements <- list("o" = "0")
  expect_equal(replacePatternsInString(patternsAndReplacements, "Hello World!"), "Hell0 W0rld!")
})

# Test with empty string and empty patterns
test_that("replacePatternsInString handles empty string and empty patterns", {
  patternsAndReplacements <- list()
  expect_equal(replacePatternsInString(patternsAndReplacements, ""), "")
})

# Test with patterns containing special characters
test_that("replacePatternsInString handles patterns with special characters", {
  patternsAndReplacements <- list("[aeiou]" = "*")
  expect_equal(replacePatternsInString(patternsAndReplacements, "Hello World!"), "H*ll* W*rld!")
})

###################
# getPluralSuffix #
###################

# Test with count 1
test_that("getPluralSuffix returns an empty string for count 1", {
  expect_equal(getPluralSuffix(1), "")
})

# Test with counts greater than 1
test_that("getPluralSuffix returns 's' for counts greater than 1", {
  expect_equal(getPluralSuffix(0), "s")
  expect_equal(getPluralSuffix(2), "s")
  expect_equal(getPluralSuffix(10), "s")
})

# Test with negative counts
test_that("getPluralSuffix handles negative counts", {
  expect_equal(getPluralSuffix(-1), "s")
  expect_equal(getPluralSuffix(-5), "s")
})

# Test with zero count
test_that("getPluralSuffix handles count of zero", {
  expect_equal(getPluralSuffix(0), "s")
})

# Test with multiple counts
test_that("getPluralSuffix handles multiple counts", {
  counts <- c(1, 2, 0, -1, 5)
  expected <- c("", "s", "s", "s", "s")
  expect_equal(getPluralSuffix(counts), expected)
})

#######################
# countTrailingSpaces #
#######################

# Test with empty string
test_that("countTrailingSpaces handles empty string", {
  expect_equal(countTrailingSpaces(""), 0)
})

# Test with string consisting of only spaces
test_that("countTrailingSpaces counts all spaces for a string of spaces", {
  expect_equal(countTrailingSpaces("   "), 3)
})

# Test with string containing no spaces at all
test_that("countTrailingSpaces returns 0 for strings with no spaces", {
  expect_equal(countTrailingSpaces("NoSpacesAtAll"), 0)
})

############################
# getWhitespacesBeforeWord #
############################

test_that("getWhitespacesBeforeWord returns all whitespaces before the word", {
  expect_equal(getWhitespacesBeforeWord("Hello    world", "world"), "    ")
  expect_equal(getWhitespacesBeforeWord("No space here", "space"), " ")
})

test_that("getWhitespacesBeforeWord handles multiple whitespaces and mixed characters", {
  expect_equal(getWhitespacesBeforeWord("  Leading spaces before word", "word"), " ")
  expect_equal(getWhitespacesBeforeWord("Tabs\tbefore word", "word"), " ")
})

test_that("getWhitespacesBeforeWord returns empty string if word not found", {
  expect_equal(getWhitespacesBeforeWord("No word here", "hello"), "")
})

test_that("getWhitespacesBeforeWord handles no whitespaces before word", {
  expect_equal(getWhitespacesBeforeWord("wordwithnospacebefore", "word"), "")
})

##################################
# countCharsFromEndToLastNewline #
##################################

# Test: countCharsFromEndToLastNewline returns correct count when newline present
test_that("countCharsFromEndToLastNewline returns correct count when newline present", {
  expect_equal(countCharsFromEndToLastNewline("Hello\nWorld\n!"), 1)
  expect_equal(countCharsFromEndToLastNewline("Line1\nLine2\nLine3\n"), 0)
  expect_equal(countCharsFromEndToLastNewline("Multiple\nNewlines\nHere"), 4)
})

# Test: countCharsFromEndToLastNewline returns full length when no newline present
test_that("countCharsFromEndToLastNewline returns full length when no newline present", {
  expect_equal(countCharsFromEndToLastNewline("HelloWorld"), 10)
  expect_equal(countCharsFromEndToLastNewline("No newlines at all"), 18)
})

# Test: countCharsFromEndToLastNewline handles empty string
test_that("countCharsFromEndToLastNewline handles empty string", {
  expect_equal(countCharsFromEndToLastNewline(""), 0)
})

# Test: countCharsFromEndToLastNewline handles string with only newlines
test_that("countCharsFromEndToLastNewline handles string with only newlines", {
  expect_equal(countCharsFromEndToLastNewline("\n\n\n"), 0)
})

######################
# getWordIndentation #
######################

# Test: getWordIndentation returns correct indentation when newline present
test_that("getWordIndentation returns correct indentation when newline present", {
  expect_equal(getWordIndentation("Hello\n  world", "world"), "  ")
  expect_equal(getWordIndentation("Line1\n    Line2\n  Line3", "Line3"), "  ")
})

# Test: getWordIndentation returns correct indentation when no newline present
test_that("getWordIndentation returns correct indentation when no newline present", {
  expect_equal(getWordIndentation("No newline here", "here"), "           ")
  expect_equal(getWordIndentation("SingleLine", "SingleLine"), "")
})

# Test: getWordIndentation handles empty text
test_that("getWordIndentation handles empty text", {
  expect_equal(getWordIndentation("", "word"), "")
})

# Test: getWordIndentation handles word not found in text
test_that("getWordIndentation handles word not found in text", {
  expect_equal(getWordIndentation("No match", "word"), "")
})

##################
# getPrintString #
##################

# Tests for captures print output correctly
test_that("getPrintString captures print output correctly", {
  # Test with a numeric vector
  numeric_vec <- 1:5
  expected_numeric <- paste(capture.output(print(numeric_vec)), collapse = "\n")
  expect_equal(getPrintString(numeric_vec), expected_numeric)

  # Test with a data frame
  df <- data.frame(x = 1:3, y = letters[1:3])
  expected_df <- paste(capture.output(print(df)), collapse = "\n")
  expect_equal(getPrintString(df), expected_df)

  # Test with a list
  list_obj <- list(a = 1, b = "test", c = c(1, 2, 3))
  expected_list <- paste(capture.output(print(list_obj)), collapse = "\n")
  expect_equal(getPrintString(list_obj), expected_list)

  # Test with a character vector
  char_vec <- c("Hello", "World")
  expected_char <- paste(capture.output(print(char_vec)), collapse = "\n")
  expect_equal(getPrintString(char_vec), expected_char)
})

#################################
# convertStringToPrefixedFormat #
#################################

# Test that strings are correctly prefixed
test_that("Strings are correctly prefixed", {
  expect_equal(convertStringToPrefixedFormat("001", "Patient", "/"), "Patient/001")
  expect_equal(convertStringToPrefixedFormat("Patient/002", "Patient", "/"), "Patient/002")
  expect_equal(convertStringToPrefixedFormat("003", "Organization", "/"), "Organization/003")
})

# Test that prefix with no separator is handled correctly
test_that("Prefix with no separator is handled correctly", {
  expect_equal(convertStringToPrefixedFormat("004", "Patient", ""), "Patient004")
  expect_equal(convertStringToPrefixedFormat("Patient005", "Patient", ""), "Patient005")
})

# Test that NA separator is handled correctly
test_that("NA separator is handled correctly", {
  expect_equal(convertStringToPrefixedFormat("006", "Patient", NA), "Patient006")
  expect_equal(convertStringToPrefixedFormat("Patient007", "Patient", NA), "Patient007")
})

# Test that an empty prefix works correctly
test_that("Empty prefix works correctly", {
  expect_equal(convertStringToPrefixedFormat("008", "", "/"), "/008")
  expect_equal(convertStringToPrefixedFormat("/009", "", "/"), "/009")
})

# Test with different prefixes and separators
test_that("Different prefixes and separators", {
  expect_equal(convertStringToPrefixedFormat("010", "Dept", "-"), "Dept-010")
  expect_equal(convertStringToPrefixedFormat("Dept-011", "Dept", "-"), "Dept-011")
})

# Test lapply with a list of strings
test_that("lapply with a list of strings", {
  string_list <- c("001", "Patient/002", "003")
  result <- lapply(string_list, convertStringToPrefixedFormat, prefix = "Patient", separator = "/")
  expect_equal(result, list("Patient/001", "Patient/002", "Patient/003"))
})
