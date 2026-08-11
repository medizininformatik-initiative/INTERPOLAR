#' Get the WP8 fallvignette mapping path
#'
#' @param mapping_file_name File name of the mapping workbook packaged in
#'   `inst/extdata`.
#'
#' @return Absolute path to the packaged mapping workbook.
#'
getFallvignetteMappingPath <- function(mapping_file_name) {
  if (
    !is.character(mapping_file_name) ||
      length(mapping_file_name) != 1L ||
      !nzchar(mapping_file_name) ||
      basename(mapping_file_name) != mapping_file_name
  ) {
    stop("mapping_file_name must be one non-empty file name without a path.")
  }

  mapping_path <- system.file(
    "extdata",
    mapping_file_name,
    package = "FallvignetteProcessEvaluation"
  )
  if (!nzchar(mapping_path) || !file.exists(mapping_path)) {
    stop(
      mapping_file_name,
      " not found in FallvignetteProcessEvaluation/inst/extdata."
    )
  }
  normalizePath(mapping_path, winslash = "/")
}

#' Load the WP8 fallvignette mapping
#'
#' Reads and validates the mapping workbook. Rows without a target field in the
#' `Fallvignette` column are treated as notes and are not returned. Duplicate
#' target fields are retained because the workbook maps up to two MRP
#' evaluations to separate output rows.
#'
#' @param mapping_path Path to the WP8 mapping workbook.
#'
#' @return A `data.table` with normalized mapping columns.
#'
loadFallvignetteMapping <- function(
  mapping_path
) {
  if (!file.exists(mapping_path)) {
    stop("Fallvignette mapping file not found: ", mapping_path)
  }

  sheets <- etlutils::readExcelFileAsTableList(mapping_path)
  if (length(sheets) != 1L) {
    stop("Fallvignette mapping must contain exactly one sheet.")
  }

  mapping <- data.table::copy(sheets[[1]])
  required_columns <- c("Fallvignette", "Quelle", "Value", "Kommentar")
  missing_columns <- setdiff(required_columns, names(mapping))
  if (length(missing_columns)) {
    stop(
      "Fallvignette mapping is missing columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }

  mapping <- mapping[, required_columns, with = FALSE]
  data.table::setnames(
    mapping,
    required_columns,
    c("target_field", "source_field", "fixed_value", "comment")
  )
  for (column_name in names(mapping)) {
    data.table::set(
      mapping,
      j = column_name,
      value = trimws(mapping[[column_name]])
    )
  }
  target_fields <- mapping[["target_field"]]
  mapping <- mapping[
    !is.na(target_fields) & nzchar(target_fields),
    ,
    with = FALSE
  ]

  target_fields <- mapping[["target_field"]]
  invalid_target_fields <- unique(
    target_fields[!grepl("^[a-z][a-z0-9_]*$", target_fields)]
  )
  if (length(invalid_target_fields)) {
    stop(
      "Fallvignette mapping contains invalid target fields: ",
      paste(invalid_target_fields, collapse = ", ")
    )
  }

  data.table::set(
    mapping,
    j = "mapping_row",
    value = seq_len(nrow(mapping))
  )
  mapping[]
}

#' Create an empty fallvignette export table
#'
#' @param mapping Normalized mapping returned by [loadFallvignetteMapping()].
#'
#' @return An empty `data.table` with the ordered WP8 export columns.
#'
createEmptyFallvignetteExport <- function(
  mapping
) {
  columns <- unique(mapping$target_field)
  data.table::as.data.table(
    stats::setNames(rep(list(character()), length(columns)), columns)
  )
}

#' Write the WP8 fallvignette import files
#'
#' Validates and orders a completed export table and writes the same content to
#' an UTF-8 CSV file and an XLSX control workbook.
#'
#' @param fallvignettes A `data.frame` or `data.table` containing all mapped WP8
#'   output columns.
#' @param output_dir Directory in which both files are written.
#' @param file_name File name without extension.
#' @param mapping Normalized mapping returned by [loadFallvignetteMapping()].
#'
#' @return Invisibly returns a named list with `csv` and `xlsx` paths.
#'
writeFallvignetteImportFiles <- function(
  fallvignettes,
  output_dir,
  mapping,
  file_name = "WP8_Fallvignetten_Import"
) {
  if (!is.data.frame(fallvignettes)) {
    stop("fallvignettes must be a data.frame or data.table.")
  }
  if (anyDuplicated(names(fallvignettes))) {
    stop("fallvignettes must not contain duplicate column names.")
  }
  if (!is.character(output_dir) || length(output_dir) != 1L || !nzchar(output_dir)) {
    stop("output_dir must be one non-empty path.")
  }
  if (!is.character(file_name) || length(file_name) != 1L || !nzchar(file_name)) {
    stop("file_name must be one non-empty string.")
  }
  if (basename(file_name) != file_name) {
    stop("file_name must not contain a directory path.")
  }

  required_columns <- unique(mapping$target_field)
  missing_columns <- setdiff(required_columns, names(fallvignettes))
  unexpected_columns <- setdiff(names(fallvignettes), required_columns)
  if (length(missing_columns)) {
    stop("Fallvignette export is missing columns: ", paste(missing_columns, collapse = ", "))
  }
  if (length(unexpected_columns)) {
    stop(
      "Fallvignette export contains unexpected columns: ",
      paste(unexpected_columns, collapse = ", ")
    )
  }

  export_data <- data.table::as.data.table(fallvignettes)[
    , required_columns,
    with = FALSE
  ]
  if (nrow(export_data)) {
    if (any(is.na(export_data$record_id) | !nzchar(trimws(export_data$record_id)))) {
      stop("Every fallvignette export row must contain a non-empty record_id.")
    }
    if (anyDuplicated(export_data$record_id)) {
      stop("record_id must be unique in the fallvignette export.")
    }
  }

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  csv_path <- file.path(output_dir, paste0(file_name, ".csv"))
  xlsx_path <- file.path(output_dir, paste0(file_name, ".xlsx"))

  data.table::fwrite(
    export_data,
    csv_path,
    na = "",
    bom = TRUE,
    quote = TRUE
  )
  etlutils::writeExcelFile(
    list(Fallvignetten = data.table::copy(export_data)),
    xlsx_path,
    with_column_names = TRUE
  )

  invisible(list(
    csv = normalizePath(csv_path, winslash = "/"),
    xlsx = normalizePath(xlsx_path, winslash = "/")
  ))
}
