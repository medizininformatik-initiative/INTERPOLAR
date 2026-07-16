writeSnapshotTestWorkbook <- function(table, sheet_name) {
  file <- tempfile(fileext = ".xlsx")
  table_with_header <- etlutils::addTextHeaderToTable(
    table,
    header = c("Hint", "snapshot pseudonymization test table"),
    insert_column_names_below_header = TRUE
  )
  etlutils::writeExcelFile(
    stats::setNames(list(table_with_header), sheet_name),
    file,
    with_column_names = FALSE
  )
  file
}

test_that("pseudonymizeSnapshotTables loads rules reviews and pseudonymizes tables", {
  table_description_file <- writeSnapshotTestWorkbook(
    data.table::data.table(
      TABLE_NAME = c("patient", NA_character_),
      COLUMN_NAME = c("id", "gender"),
      COLUMN_DESCRIPTION = c("Patient id", "Gender"),
      COLUMN_TYPE = c("varchar", "varchar"),
      PSEUDONYMIZATION_RULE = c("cryptoHash", "keep")
    ),
    "table_description"
  )
  report_file <- tempfile(fileext = ".xlsx")
  tables <- list(
    patient = data.table::data.table(
      id = c("p1", "p2"),
      gender = c("female", "male"),
      source_only = c("x", "y")
    ),
    internal = data.table::data.table(id = "admin")
  )

  result <- pseudonymizeSnapshotTables(
    tables = tables,
    table_descriptions = data.table::data.table(
      SOURCE = "manual",
      PATH = table_description_file,
      SHEET_NAME = "table_description"
    ),
    fail_on_review_problems = TRUE,
    write_review_report = TRUE,
    review_report_file = report_file,
    log_steps = FALSE
  )

  expect_true(file.exists(report_file))
  expect_named(result$tables, "patient")
  expect_named(result$tables$patient, c("id", "gender"))
  expect_false(identical(result$tables$patient$id, tables$patient$id))
  expect_equal(result$tables$patient$gender, tables$patient$gender)
  expect_equal(
    result$summary[result$summary$TABLE_NAME == "internal", ][["STATUS"]],
    "skipped_no_rules"
  )
  expect_equal(nrow(result$review_report$unsupported_rules), 0L)
})

test_that("pseudonymizeSnapshotTables can abort on blocking review problems", {
  table_description_file <- writeSnapshotTestWorkbook(
    data.table::data.table(
      TABLE_NAME = "patient",
      COLUMN_NAME = "id",
      COLUMN_DESCRIPTION = "Patient id",
      COLUMN_TYPE = "varchar",
      PSEUDONYMIZATION_RULE = "### TODO: NEW COLUMN ###"
    ),
    "table_description"
  )

  expect_error(
    pseudonymizeSnapshotTables(
      tables = list(patient = data.table::data.table(id = "p1")),
      table_descriptions = table_description_file,
      write_review_report = FALSE,
      log_steps = FALSE
    ),
    "blocking problems"
  )
})

test_that("pseudonymizeSnapshotTables can use preloaded rules", {
  rules <- data.table::data.table(
    SOURCE = "manual",
    SOURCE_TYPE = "table_description",
    SOURCE_FILE = "manual.xlsx",
    SOURCE_SHEET = "table_description",
    TABLE_NAME = "patient",
    RESOURCE = NA_character_,
    TABLE_OR_RESOURCE = "patient",
    COLUMN_NAME = c("id", "gender"),
    COLUMN_DESCRIPTION = c("Patient id", "Gender"),
    COLUMN_TYPE = c("varchar", "varchar"),
    FHIR_EXPRESSION = NA_character_,
    PSEUDONYMIZATION_RULE_RAW = c("cryptoHash", "keep"),
    PSEUDONYMIZATION_RULE = c("cryptoHash", "keep"),
    IMPLICIT_KEEP = c(FALSE, FALSE)
  )

  result <- pseudonymizeSnapshotTables(
    tables = list(patient = data.table::data.table(id = "p1", gender = "female")),
    table_descriptions = NULL,
    rules = rules,
    write_review_report = FALSE,
    log_steps = FALSE
  )

  expect_named(result$tables, "patient")
  expect_false(identical(result$tables$patient$id, "p1"))
  expect_equal(result$tables$patient$gender, "female")
})
