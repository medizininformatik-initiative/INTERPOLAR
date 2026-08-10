normalizeWorksheetCells <- function(file_path, sheet_name) {
  if (!file.exists(file_path)) {
    stop("Table Description file not found: ", file_path, call. = FALSE)
  }
  if (!sheet_name %in% openxlsx::getSheetNames(file_path)) {
    stop(
      "Table Description sheet '", sheet_name, "' not found in ", file_path,
      call. = FALSE
    )
  }

  cells <- openxlsx::read.xlsx(
    file_path,
    sheet = sheet_name,
    colNames = FALSE,
    skipEmptyRows = FALSE,
    skipEmptyCols = FALSE,
    check.names = FALSE
  )
  cells <- as.data.frame(
    lapply(cells, as.character),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  cells[] <- lapply(cells, function(column) {
    column[is.na(column) | column == ""] <- NA_character_
    column
  })
  cells
}

formatWorksheetValue <- function(value) {
  if (length(value) == 0L || is.na(value)) {
    return("<empty>")
  }
  paste0('"', value, '"')
}

assertWorksheetConsistency <- function(definition_path, generated_path, sheet_name) {
  definition <- normalizeWorksheetCells(definition_path, sheet_name)
  generated <- normalizeWorksheetCells(generated_path, sheet_name)
  row_count <- max(nrow(definition), nrow(generated))
  column_count <- max(ncol(definition), ncol(generated))
  padWorksheet <- function(cells) {
    result <- matrix(NA_character_, nrow = row_count, ncol = column_count)
    if (nrow(cells) > 0L && ncol(cells) > 0L) {
      result[seq_len(nrow(cells)), seq_len(ncol(cells))] <- as.matrix(cells)
    }
    result
  }
  definition <- padWorksheet(definition)
  generated <- padWorksheet(generated)
  same_cells <- (is.na(definition) & is.na(generated)) |
    (!is.na(definition) & !is.na(generated) & definition == generated)
  differences <- which(!same_cells, arr.ind = TRUE)
  if (nrow(differences) == 0L) {
    return(invisible(TRUE))
  }

  first_difference <- differences[1L, ]
  cell_reference <- paste0(
    openxlsx::int2col(first_difference[["col"]]),
    first_difference[["row"]]
  )
  definition_value <- definition[
    first_difference[["row"]],
    first_difference[["col"]]
  ]
  generated_value <- generated[
    first_difference[["row"]],
    first_difference[["col"]]
  ]
  stop(
    "Generated Table Description sheet '", sheet_name,
    "' differs from its definition at ", cell_reference,
    ": definition = ",
    formatWorksheetValue(definition_value),
    ", generated = ",
    formatWorksheetValue(generated_value),
    ". Regenerate it with initcdstoolchain::initTableDescription().",
    call. = FALSE
  )
}

checkTableDescriptionConsistency <- function(
  definition_path,
  generated_path,
  sheet_names = "snapshot_extension"
) {
  for (sheet_name in sheet_names) {
    assertWorksheetConsistency(definition_path, generated_path, sheet_name)
  }
  message(
    "Generated Table Description sheets match their definition: ",
    paste(sheet_names, collapse = ", ")
  )
  invisible(TRUE)
}

getCurrentScriptPath <- function() {
  file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_argument) != 1L) {
    stop("Could not determine the current script path.", call. = FALSE)
  }
  normalizePath(sub("^--file=", "", file_argument))
}

if (sys.nframe() == 0L) {
  script_path <- getCurrentScriptPath()
  project_root <- normalizePath(file.path(dirname(script_path), ".."))
  arguments <- commandArgs(trailingOnly = TRUE)
  definition_path <- if (length(arguments) >= 1L) {
    arguments[[1L]]
  } else {
    file.path(
      project_root,
      "R-cds2db/cds2db/inst/extdata/Table_Description_Definition.xlsx"
    )
  }
  generated_path <- if (length(arguments) >= 2L) {
    arguments[[2L]]
  } else {
    file.path(
      project_root,
      "R-cds2db/cds2db/inst/extdata/Table_Description.xlsx"
    )
  }
  checkTableDescriptionConsistency(definition_path, generated_path)
}
