# Validate an explicit export selection without initializing the toolchain or a database.
loadGlobalAnalysisInputs <- function(config_file, input_dir) {
  if (!file.exists(config_file)) {
    stop("Export selection not found: ", config_file,
      ". Copy config/sites_example.csv to config/sites.csv and select the exports.",
      call. = FALSE
    )
  }
  selection <- utils::read.csv(
    config_file,
    colClasses = "character", check.names = FALSE, na.strings = ""
  )
  required_columns <- c("site_id", "export_id", "mrp_check_file")
  if (!identical(names(selection), required_columns) || !nrow(selection)) {
    stop("Export selection must contain rows and exactly these columns: ",
      paste(required_columns, collapse = ", "),
      call. = FALSE
    )
  }
  selection[] <- lapply(selection, trimws)
  if (anyNA(selection) || any(!nzchar(as.matrix(selection)))) {
    stop("Export selection contains missing or blank values.", call. = FALSE)
  }
  if (anyDuplicated(selection$site_id)) {
    stop("Select exactly one export per site_id.", call. = FALSE)
  }
  for (column_name in c("site_id", "export_id")) {
    if (any(!grepl("^[A-Za-z0-9][A-Za-z0-9_-]*$", selection[[column_name]]))) {
      stop(column_name, " must contain only letters, digits, underscores or hyphens",
        " and start with a letter or digit.",
        call. = FALSE
      )
    }
  }
  if (!dir.exists(input_dir)) {
    stop("Input directory not found: ", input_dir, call. = FALSE)
  }
  input_root <- normalizePath(input_dir, winslash = "/", mustWork = TRUE)
  selection$source_file <- vapply(seq_len(nrow(selection)), function(row_index) {
    relative_file <- selection$mrp_check_file[row_index]
    path_parts <- strsplit(relative_file, "/", fixed = TRUE)[[1L]]
    if (grepl("^/|[:\\\\]", relative_file) || any(path_parts %in% c("", ".", ".."))) {
      stop("mrp_check_file must be a relative path within outputGlobal: ",
        relative_file,
        call. = FALSE
      )
    }
    export_dir <- file.path(
      input_root, selection$site_id[row_index], selection$export_id[row_index], "outputGlobal"
    )
    source_file <- file.path(export_dir, relative_file)
    if (!file.exists(source_file) || dir.exists(source_file)) {
      stop("MRP export file not found: ", source_file, call. = FALSE)
    }
    source_file <- normalizePath(source_file, winslash = "/", mustWork = TRUE)
    # Reject links resolving outside the selected export as well as outside the input root.
    export_root <- normalizePath(export_dir, winslash = "/", mustWork = TRUE)
    if (
      !startsWith(export_root, paste0(input_root, "/")) ||
      !startsWith(source_file, paste0(export_root, "/"))
    ) {
      stop("MRP export file resolves outside the selected input export.", call. = FALSE)
    }
    if (file.access(source_file, 4L) != 0L || file.info(source_file)$size == 0) {
      stop("MRP export file is unreadable or has zero bytes: ", source_file, call. = FALSE)
    }
    source_file
  }, character(1L))
  selection$source_md5 <- unname(tools::md5sum(selection$source_file))
  if (anyNA(selection$source_md5)) {
    stop("Could not calculate all input checksums.", call. = FALSE)
  }
  selection
}
