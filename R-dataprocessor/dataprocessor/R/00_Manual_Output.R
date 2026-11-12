#' Read provenance for a manual analysis run
#'
#' Uses the running toolchain version, rather than the source database version.
#' Snapshot dates follow ip-snapshot.sh's YYYYMMDD database-name convention.
getManualOutputContext <- function() {
  metadata <- etlutils::dbGetReadOnlyQuery(
    paste0(
      "SELECT current_database() AS database_name, ",
      "(SELECT parameter_value FROM v_db_parameter ",
      "WHERE parameter_name = 'database_content_type') AS database_content_type"
    ),
    lock_id = NULL
  )
  buildManualOutputContext(
    database_name = metadata$database_name[[1]],
    database_content_type = metadata$database_content_type[[1]],
    release_version = etlutils::getReleaseVersion(),
    run_time = Sys.time()
  )
}

#' Build filename-safe provenance without exporting a site-specific database name
#'
#' Explicit metadata takes precedence over the conventional database-name suffix.
#' Old or custom databases retain unknown fields rather than being labelled live.
buildManualOutputContext <- function(database_name, database_content_type,
                                     release_version, run_time) {
  snapshot_pattern <- "^ip_.+_([0-9]{8})(_pseud)?(_broad_consent)?(_build)?$"
  snapshot_name <- grepl(snapshot_pattern, database_name)
  content_type <- database_content_type
  if (is.null(content_type) || is.na(content_type) || !nzchar(content_type)) {
    content_type <- if (identical(database_name, "cds_hub_db")) {
      "live"
    } else if (snapshot_name) {
      if (grepl("_pseud(_broad_consent)?(_build)?$", database_name)) {
        "pseudonymized_snapshot"
      } else {
        "unpseudonymized_snapshot"
      }
    } else {
      "unknown"
    }
  }
  if (!content_type %in% c("live", "pseudonymized_snapshot", "unpseudonymized_snapshot")) {
    content_type <- "unknown"
  }
  snapshot_date <- "unknown"
  if (snapshot_name && grepl("snapshot$", content_type)) {
    date_text <- sub(snapshot_pattern, "\\1", database_name)
    parsed_date <- as.Date(date_text, format = "%Y%m%d")
    if (!is.na(parsed_date) && identical(format(parsed_date, "%Y%m%d"), date_text)) {
      snapshot_date <- format(parsed_date, "%Y-%m-%d")
    }
  }
  if (!grepl("^[[:alnum:]][[:alnum:].+-]*$", release_version)) {
    stop("Invalid toolchain release version for output naming.", call. = FALSE)
  }
  paste0(
    "run-", format(run_time, "%Y-%m-%d_%H-%M-%SZ", tz = "UTC"),
    "_toolchain-", release_version, "_", content_type,
    if (grepl("snapshot$", content_type)) paste0("_snapshot-", snapshot_date) else ""
  )
}

#' Record report files without reading potentially large exports
#'
#' Logs, caches and performance measurements are not release reports. The existing
#' writers place reports in reports/tables and WP8's local mapping in data.
getManualOutputFiles <- function(module_dirs) {
  output_dirs <- as.vector(outer(
    c(module_dirs$global_dir, module_dirs$local_dir),
    c("reports", "tables", "data"), file.path
  ))
  files <- unlist(lapply(output_dirs, list.files,
    pattern = "\\.(xlsx|html|csv|zip)$", full.names = TRUE, recursive = TRUE
  ), use.names = FALSE)
  file.info(files)[, c("size", "mtime", "ctime"), drop = FALSE]
}

#' Apply provenance to newly created or overwritten manual report files
#'
#' Run only after successful completion so partially written reports are not
#' presented as completed exports. Archive members keep their existing CSV schema.
nameManualOutputs <- function(previous_outputs, module_dirs, output_context) {
  current_outputs <- getManualOutputFiles(module_dirs)
  changed <- vapply(rownames(current_outputs), function(path) {
    !path %in% rownames(previous_outputs) ||
      !identical(current_outputs[path, ], previous_outputs[path, ])
  }, logical(1))
  paths <- rownames(current_outputs)[changed]
  if (!length(paths)) {
    return(invisible(character()))
  }
  extensions <- tools::file_ext(paths)
  destinations <- file.path(dirname(paths), paste0(
    tools::file_path_sans_ext(basename(paths)), "_", output_context, ".", extensions
  ))
  # Check the entire batch first: never silently overwrite an earlier run.
  if (any(file.exists(destinations)) || anyDuplicated(destinations)) {
    stop("Manual output filename collision; reports retain their original names.", call. = FALSE)
  }
  for (index in seq_along(paths)) {
    if (!file.rename(paths[[index]], destinations[[index]])) {
      stop("Could not name manual output: ", paths[[index]], call. = FALSE)
    }
    message("Manual output: ", destinations[[index]])
  }
  invisible(destinations)
}
