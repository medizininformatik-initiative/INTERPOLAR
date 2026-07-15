writeRuleInputTestWorkbook <- function(table, sheet_name) {
  file <- tempfile(fileext = ".xlsx")
  table_with_header <- etlutils::addTextHeaderToTable(
    table,
    header = c("Hint", "test table description"),
    insert_column_names_below_header = TRUE
  )
  etlutils::writeExcelFile(
    stats::setNames(list(table_with_header), sheet_name),
    file,
    with_column_names = FALSE
  )
  file
}

test_that("loadPseudonymizationRules loads table descriptions and snapshot extensions", {
  table_description_file <- writeRuleInputTestWorkbook(
    data.table::data.table(
      TABLE_NAME = c("observation", NA_character_),
      COLUMN_NAME = c("obs_id", "obs_value"),
      COLUMN_DESCRIPTION = c("Observation id", "Observation value"),
      COLUMN_TYPE = c("varchar", "double precision"),
      PSEUDONYMIZATION_RULE = c("cryptoHash", NA_character_)
    ),
    "table_description"
  )
  extension_file <- writeRuleInputTestWorkbook(
    data.table::data.table(
      TABLE_NAME = "observation",
      COLUMN_NAME = "value_ref_unit",
      COLUMN_DESCRIPTION = "Wert in Referenzeinheit",
      COLUMN_TYPE = "double precision",
      PSEUDONYMIZATION_RULE = "keep"
    ),
    "snapshot_extensions"
  )

  rules <- loadPseudonymizationRules(
    table_descriptions = data.table::data.table(
      SOURCE = "fhir",
      PATH = table_description_file,
      SHEET_NAME = "table_description"
    ),
    snapshot_extensions = data.table::data.table(
      SOURCE = "observation_extensions",
      PATH = extension_file,
      SHEET_NAME = "snapshot_extensions"
    )
  )

  expect_equal(nrow(rules), 3)
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_id", "SOURCE_TYPE", drop = TRUE],
    "table_description"
  )
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_id", "PSEUDONYMIZATION_RULE", drop = TRUE],
    "cryptoHash"
  )
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_value", "TABLE_OR_RESOURCE", drop = TRUE],
    "observation"
  )
  expect_equal(
    rules[rules$COLUMN_NAME == "obs_value", "PSEUDONYMIZATION_RULE", drop = TRUE],
    "keep"
  )
  expect_true(rules[rules$COLUMN_NAME == "obs_value", "IMPLICIT_KEEP", drop = TRUE])
  expect_equal(
    rules[rules$COLUMN_NAME == "value_ref_unit", "SOURCE_TYPE", drop = TRUE],
    "snapshot_extension"
  )
})

test_that("loadPseudonymizationRules keeps snapshot-only TODO markers visible", {
  extension_file <- writeRuleInputTestWorkbook(
    data.table::data.table(
      TABLE_NAME = "observation",
      COLUMN_NAME = "primary_loinc_code",
      COLUMN_DESCRIPTION = "Primary LOINC",
      COLUMN_TYPE = "varchar",
      PSEUDONYMIZATION_RULE = "### TODO: NEW COLUMN ###"
    ),
    "snapshot_extensions"
  )

  rules <- loadPseudonymizationRules(
    table_descriptions = NULL,
    snapshot_extensions = extension_file
  )

  expect_equal(rules$SOURCE_TYPE, "snapshot_extension")
  expect_equal(rules$PSEUDONYMIZATION_RULE, "### TODO: NEW COLUMN ###")
  expect_false(rules$IMPLICIT_KEEP)
})
