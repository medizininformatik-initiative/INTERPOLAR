
##########################
# extractReplacePatterns #
##########################

# Test for correct extraction after the header
test_that("extractReplacePatterns correctly extracts patterns and replacements after header", {
  table_description_collapsed <- data.table(
    RESOURCE = c("Info", "More Info", NA, "PATTERN", "pattern1", "pattern2"),
    RESOURCE_PREFIX = c("Not a pattern", "Still not a pattern", NA, "REPLACEMENT", "replace1", "replace2")
  )
  result <- extractReplacePatterns(table_description_collapsed)
  expected_result <- list(pattern1 = "replace1", pattern2 = "replace2")
  expect_equal(result, expected_result)
})

# Test for table without matching header
test_that("extractReplacePatterns returns an empty list when no matching header is found", {
  table_description_collapsed <- data.table(
    RESOURCE = c("No pattern here", "Still no pattern"),
    RESOURCE_PREFIX = c("Not a replacement", "Still not a replacement")
  )
  result <- extractReplacePatterns(table_description_collapsed)
  expect_equal(result, list())
})

# Test for full extraction of patterns and replacements
test_that("extractReplacePatterns extracts all patterns and replacements after the found header", {
  table_description_collapsed <- data.table(
    RESOURCE = c("Header", "Header", "PATTERN", "pattern1", "pattern2", "Extra info"),
    RESOURCE_PREFIX = c("Header info", "Header info", "REPLACEMENT", "replace1", "replace2", "More extra info")
  )
  result <- extractReplacePatterns(table_description_collapsed)
  expected_result <- list(pattern1 = "replace1", pattern2 = "replace2", "Extra info" = "More extra info")
  expect_equal(result, expected_result)
})

#################################
# addEmptyRowsBeforeNewResource #
#################################

test_that("addEmptyRowsBeforeNewResource inserts empty rows correctly", {
  # Create a sample data.table
  # the function should insert 3 new full NA lines
  dt <- data.table(
    RESOURCE = c("Resource1", "Resource2", "Resource3", "Resource4"),
    VALUE = c(1, 2, 3, 4)
  )

  expected_result <- data.table(
    RESOURCE = c("Resource1", NA, "Resource2", NA, "Resource3", NA, "Resource4"),
    VALUE = c(1, NA, 2, NA, 3, NA, 4)
  )

  # Apply the function
  result <- addEmptyRowsBeforeNewResource(dt)

  expect_true(identical(result, expected_result))
})

test_that("addPseudonymizationRulesToTableDescription adds default YAML rules", {
  table_description <- data.table(
    RESOURCE = c("Patient", NA),
    COLUMN_NAME = c("pat_id", "pat_birthdate"),
    FHIR_EXPRESSION = c("id", "birthDate"),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )

  result <- addPseudonymizationRulesToTableDescription(table_description)

  expect_named(result, c(
    "RESOURCE",
    "COLUMN_NAME",
    "FHIR_EXPRESSION",
    "REFERENCE_TYPES",
    "FHIR_TYPE",
    "PSEUDONYMIZATION_RULE"
  ))
  expect_equal(result$PSEUDONYMIZATION_RULE, c("cryptoHash", "generalize(YYYY-MM)"))
})

test_that("setTableDescriptionColumnWidths stores readable widths", {
  table_description_file_name <- tempfile(fileext = ".xlsx")
  table_description <- data.table(
    RESOURCE = "Patient",
    COLUMN_NAME = "pat_id",
    FHIR_EXPRESSION = "id",
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_,
    FHIR_ID_COLUMN_NAME = NA_character_,
    REFERENCE_ID_COLUMN_NAME = NA_character_,
    PSEUDONYMIZATION_RULE = "cryptoHash"
  )
  etlutils::writeExcelFile(
    list("table_description" = table_description),
    table_description_file_name,
    with_column_names = TRUE
  )

  setTableDescriptionColumnWidths(table_description_file_name)

  sheet_xml <- readLines(
    unz(table_description_file_name, "xl/worksheets/sheet1.xml"),
    warn = FALSE
  )
  sheet_xml <- paste(sheet_xml, collapse = "")
  expected_widths <- c(18, 34, 60, 28, 22, 30, 34, 32)
  for (col_index in seq_along(expected_widths)) {
    expect_match(
      sheet_xml,
      paste0(
        "<col min=\"", col_index,
        "\" max=\"", col_index,
        "\" width=\"", expected_widths[col_index], "\\.71",
        "\""
      )
    )
  }
})
