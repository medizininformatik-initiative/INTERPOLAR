
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

test_that("expandTableDescriptionInternal retains nested FHIR node type provenance", {
  table_description_collapsed <- data.table(
    RESOURCE = c("Condition", "Observation"),
    RESOURCE_PREFIX = c("con", "obs"),
    FHIR_EXPRESSION = c("abatementAge/Age", "referenceRange/age/Range"),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )
  expansion_tables <- list(
    Age = data.table(
      FHIR_EXPRESSION = c("value", "unit"),
      FHIR_TYPE = c("decimal", NA_character_)
    ),
    Range = data.table(
      FHIR_EXPRESSION = c("low/SimpleQuantity", "high/SimpleQuantity"),
      FHIR_TYPE = NA_character_
    ),
    SimpleQuantity = data.table(
      FHIR_EXPRESSION = c("value", "unit"),
      FHIR_TYPE = c("decimal", NA_character_)
    )
  )

  result <- expandTableDescriptionInternal(table_description_collapsed, expansion_tables)

  expect_equal(
    result[COLUMN_NAME == "con_abatementage_value", FHIR_NODE_TYPE_PATHS],
    "Age=abatementAge"
  )
  expect_equal(
    result[COLUMN_NAME == "obs_referencerange_age_low_value", FHIR_NODE_TYPE_PATHS],
    "Range=referenceRange/age|SimpleQuantity=referenceRange/age/low"
  )
  expect_equal(
    getExpandedFhirNodePath(
      "",
      "Identifier",
      data.table(FHIR_EXPRESSION = c("identifier/system", "identifier/value"))
    ),
    "identifier"
  )
})

test_that("addPseudonymizationRulesToTableDescription adds default YAML rules", {
  table_description <- data.table(
    RESOURCE = c("Patient", NA, NA),
    COLUMN_NAME = c("pat_id", "pat_birthdate", "pat_deceaseddatetime"),
    FHIR_EXPRESSION = c("id", "birthDate", "deceasedDateTime"),
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
  expect_equal(
    result$PSEUDONYMIZATION_RULE,
    c("cryptoHash", "generalize(format = \"YYYY-MM\")", "generalize(format = \"YYYY-MM\")")
  )
})

test_that("expandTableDescriptionFromFile handles table and snapshot extensions", {
  table_description_file_name <- tempfile(fileext = ".xlsx")
  table_description_collapsed <- data.table(
    RESOURCE = c("Patient", "Observation"),
    RESOURCE_PREFIX = c("pat", "obs"),
    FHIR_EXPRESSION = c("id", "id"),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_
  )
  table_description_extension <- data.table(
    V1 = c("Hint", "Additional tables", NA, "TABLE_NAME", "pids_per_ward", NA),
    V2 = c(NA, NA, NA, "COLUMN_NAME", "ward_name", "patient_id"),
    V3 = c(NA, NA, NA, "COLUMN_DESCRIPTION", "Station name", "Patient ID"),
    V4 = c(NA, NA, NA, "COLUMN_TYPE", "varchar", "varchar"),
    V5 = c(NA, NA, NA, "PSEUDONYMIZATION_RULE", "keep", "cryptoHash")
  )
  snapshot_extension <- data.table(
    V1 = c("Hint", "Snapshot-only columns", NA, "TABLE_NAME", "observation"),
    V2 = c(NA, NA, NA, "COLUMN_NAME", "analysis_loinc_code"),
    V3 = c(NA, NA, NA, "COLUMN_DESCRIPTION", "Analysis LOINC Code"),
    V4 = c(NA, NA, NA, "COLUMN_TYPE", "varchar"),
    V5 = c(NA, NA, NA, "PSEUDONYMIZATION_RULE", "keep")
  )
  workbook <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(workbook, "table_description_collapsed")
  openxlsx::writeData(
    workbook,
    "table_description_collapsed",
    table_description_collapsed,
    colNames = TRUE
  )
  openxlsx::addWorksheet(workbook, "table_description_extension")
  openxlsx::writeData(
    workbook,
    "table_description_extension",
    table_description_extension,
    colNames = FALSE
  )
  openxlsx::addWorksheet(workbook, "snapshot_extension")
  openxlsx::writeData(
    workbook,
    "snapshot_extension",
    snapshot_extension,
    colNames = FALSE
  )
  openxlsx::saveWorkbook(workbook, table_description_file_name, overwrite = TRUE)

  with_mocked_bindings(
    system.file = function(..., package = NULL) table_description_file_name,
    {
      result <- expandTableDescriptionFromFile("Table_Description_Definition.xlsx")
    },
    .package = "initcdstoolchain"
  )

  additional_output_sheets <- attr(result, "additional_output_sheets")
  expect_named(additional_output_sheets, "snapshot_extension")
  expect_equal(additional_output_sheets$snapshot_extension[4, 1], "TABLE_NAME")
  expect_equal(additional_output_sheets$snapshot_extension[5, 2], "analysis_loinc_code")

  extension <- attr(result, "table_description_extension")
  expect_equal(extension$RESOURCE, c("pids_per_ward", NA_character_))
  expect_equal(extension$COLUMN_NAME, c("ward_name", "patient_id"))
  expect_equal(extension$FHIR_EXPRESSION, c("Station name", "Patient ID"))
  expect_equal(extension$FHIR_TYPE, c("varchar", "varchar"))
  expect_equal(extension$PSEUDONYMIZATION_RULE, c("keep", "cryptoHash"))
})

test_that("expandTableDescriptionFromFile allows missing extension sheets", {
  table_description_file_name <- tempfile(fileext = ".xlsx")
  workbook <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(workbook, "table_description_collapsed")
  openxlsx::writeData(
    workbook,
    "table_description_collapsed",
    data.table(
      RESOURCE = c("Patient", "Observation"),
      RESOURCE_PREFIX = c("pat", "obs"),
      FHIR_EXPRESSION = c("id", "id"),
      REFERENCE_TYPES = c(NA_character_, NA_character_),
      FHIR_TYPE = c(NA_character_, NA_character_)
    ),
    colNames = TRUE
  )
  openxlsx::saveWorkbook(workbook, table_description_file_name, overwrite = TRUE)

  with_mocked_bindings(
    system.file = function(..., package = NULL) table_description_file_name,
    {
      result <- expandTableDescriptionFromFile("Table_Description_Definition.xlsx")
    },
    .package = "initcdstoolchain"
  )

  expect_length(attr(result, "additional_output_sheets"), 0L)
  extension <- attr(result, "table_description_extension")
  expect_s3_class(extension, "data.table")
  expect_equal(nrow(extension), 0L)
  expect_named(
    extension,
    c(
      "RESOURCE",
      "COLUMN_NAME",
      "FHIR_EXPRESSION",
      "REFERENCE_TYPES",
      "FHIR_TYPE",
      "FHIR_ID_COLUMN_NAME",
      "REFERENCE_ID_COLUMN_NAME",
      "PSEUDONYMIZATION_RULE"
    )
  )
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

test_that("setTableDescriptionColumnWidths fits the longest first rule line", {
  table_description_file_name <- tempfile(fileext = ".xlsx")
  first_rule <- paste0(strrep("x", 40), ";")
  table_description <- data.table(
    RESOURCE = "Patient",
    COLUMN_NAME = "pat_id",
    FHIR_EXPRESSION = "id",
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_,
    FHIR_ID_COLUMN_NAME = NA_character_,
    REFERENCE_ID_COLUMN_NAME = NA_character_,
    PSEUDONYMIZATION_RULE = paste(first_rule, "keep")
  )
  etlutils::writeExcelFile(
    list("table_description" = table_description),
    table_description_file_name,
    with_column_names = TRUE
  )

  setTableDescriptionColumnWidths(table_description_file_name)

  sheet_xml <- paste(
    readLines(unz(table_description_file_name, "xl/worksheets/sheet1.xml"), warn = FALSE),
    collapse = ""
  )
  expect_match(sheet_xml, '<col min="8" max="8" width="43\\.71"')
})

test_that("splitPseudonymizationRuleChain only splits top-level rule separators", {
  rule <- paste0(
    "pseudonymize(domain = \"a\"; type.coding.code == \"VN\"); ",
    "keepIf(system == \"x\")"
  )

  expect_equal(
    splitPseudonymizationRuleChain(rule),
    paste0(
      "pseudonymize(domain = \"a\"; type.coding.code == \"VN\");",
      intToUtf8(10),
      "keepIf(system == \"x\")"
    )
  )
})

test_that("formatTableDescriptionPseudonymizationRules writes hard line breaks and row heights", {
  table_description_file_name <- tempfile(fileext = ".xlsx")
  table_description <- data.table(
    RESOURCE = c("Patient", NA),
    COLUMN_NAME = c("pat_identifier_value", "pat_identifier_value_short"),
    FHIR_EXPRESSION = c("identifier/value", "identifier/value"),
    REFERENCE_TYPES = NA_character_,
    FHIR_TYPE = NA_character_,
    FHIR_ID_COLUMN_NAME = NA_character_,
    REFERENCE_ID_COLUMN_NAME = NA_character_,
    PSEUDONYMIZATION_RULE = c(
      paste0(
        "pseudonymize(domain = \"a\"; type.coding.code == \"VN\"); ",
        "keepIf(system == \"x\")"
      ),
      "pseudonymize(domain = \"a\"; type.coding.code == \"VN\")"
    )
  )
  etlutils::writeExcelFile(
    list("table_description" = table_description),
    table_description_file_name,
    with_column_names = TRUE
  )

  formatTableDescriptionPseudonymizationRules(table_description_file_name)

  shared_strings_connection <- unz(table_description_file_name, "xl/sharedStrings.xml", open = "rb")
  shared_strings_xml <- rawToChar(readBin(
    shared_strings_connection,
    what = "raw",
    n = 1e6
  ))
  close(shared_strings_connection)
  sheet_xml <- readLines(
    unz(table_description_file_name, "xl/worksheets/sheet1.xml"),
    warn = FALSE
  )
  sheet_xml <- paste(sheet_xml, collapse = "")
  styles_xml <- readLines(
    unz(table_description_file_name, "xl/styles.xml"),
    warn = FALSE
  )
  styles_xml <- paste(styles_xml, collapse = "")

  expect_match(shared_strings_xml, paste0("VN&quot;\\);", intToUtf8(10), "keepIf"))
  expect_match(sheet_xml, "<row r=\"2\" ht=\"32\" customHeight=\"1\"")
  expect_match(sheet_xml, '<c r="A2" s="[1-9][0-9]*"')
  expect_no_match(sheet_xml, "<row r=\"3\" ht=")
  expect_match(styles_xml, "vertical=\"top\"")
  expect_match(styles_xml, "wrapText=\"1\"")
})
