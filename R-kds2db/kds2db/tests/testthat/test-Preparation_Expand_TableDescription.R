
##########################
# extractReplacePatterns #
##########################
# Test for correct extraction after the header
test_that("extractReplacePatterns correctly extracts patterns and replacements after header", {
  table_description_collapsed <- data.table(
    resource = c("Info", "More Info", "pattern", "pattern1", "pattern2"),
    resource_prefix = c("Not a pattern", "Still not a pattern", "replacement", "replace1", "replace2")
  )
  result <- extractReplacePatterns(table_description_collapsed)
  expected_result <- list(pattern1 = "replace1", pattern2 = "replace2")
  expect_equal(result, expected_result)
})

# Test for table without matching header
test_that("extractReplacePatterns returns an empty list when no matching header is found", {
  table_description_collapsed <- data.table(
    resource = c("No pattern here", "Still no pattern"),
    resource_prefix = c("Not a replacement", "Still not a replacement")
  )
  result <- extractReplacePatterns(table_description_collapsed)
  expect_equal(result, list())
})

# Test for full extraction of patterns and replacements
test_that("extractReplacePatterns extracts all patterns and replacements after the found header", {
  table_description_collapsed <- data.table(
    resource = c("Header", "Header", "pattern", "pattern1", "pattern2", "Extra info"),
    resource_prefix = c("Header info", "Header info", "replacement", "replace1", "replace2", "More extra info")
  )
  result <- extractReplacePatterns(table_description_collapsed)
  expected_result <- list(pattern1 = "replace1", pattern2 = "replace2", 'Extra info' = "More extra info")
  expect_equal(result, expected_result)
})
