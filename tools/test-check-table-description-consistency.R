script_path <- normalizePath(
  sub(
    "^--file=",
    "",
    grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  )
)
source(file.path(dirname(script_path), "check-table-description-consistency.R"))

writeSnapshotExtension <- function(file_path, values) {
  workbook <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(workbook, "snapshot_extension")
  openxlsx::writeData(
    workbook,
    "snapshot_extension",
    values,
    colNames = FALSE
  )
  openxlsx::saveWorkbook(workbook, file_path, overwrite = TRUE)
}

runConsistencyCheckTests <- function() {
  temporary_directory <- tempfile("table-description-consistency-")
  dir.create(temporary_directory)
  on.exit(unlink(temporary_directory, recursive = TRUE), add = TRUE)
  definition_path <- file.path(temporary_directory, "definition.xlsx")
  generated_path <- file.path(temporary_directory, "generated.xlsx")

  matching_values <- data.table::data.table(
    c("TABLE_NAME", "observation"),
    c("COLUMN_NAME", "analysis_value")
  )
  writeSnapshotExtension(definition_path, matching_values)
  writeSnapshotExtension(generated_path, matching_values)
  checkTableDescriptionConsistency(definition_path, generated_path)

  different_values <- matching_values
  different_values[2L, 2L] <- "stale_value"
  writeSnapshotExtension(generated_path, different_values)
  error_message <- tryCatch(
    {
      checkTableDescriptionConsistency(definition_path, generated_path)
      NA_character_
    },
    error = conditionMessage
  )
  if (
    is.na(error_message) ||
      !grepl("differs from its definition at B2", error_message, fixed = TRUE)
  ) {
    stop("The consistency check did not report the changed cell.")
  }
}

runConsistencyCheckTests()
message("Table Description consistency check tests passed.")
