# Test-specific configuration for StartDebugDataImport.R.
DEBUG_DATA_IMPORT_TARGETS <- list(
  list(resource = "location", columns = c("loc_physicaltype_code", "loc_name")),
  list(resource = "condition", columns = c("con_code_code"))
)
DEBUG_DATA_IMPORT_RUN_ONLY_CDS2DB <- TRUE

# When this file is sourced by StartDebugDataImport.R there is no local
# resource_tables variable yet. In that case the file only provides the
# configuration variables above and returns immediately.
if (exists("resource_tables")) {
  normalizeDebugDataImportTargets <- function() {
    if (!exists("DEBUG_DATA_IMPORT_TARGETS", envir = .GlobalEnv)) {
      stop("DEBUG_DATA_IMPORT_TARGETS must be defined.")
    }

    targets <- get("DEBUG_DATA_IMPORT_TARGETS", envir = .GlobalEnv)
    if (!is.list(targets) || !length(targets)) {
      stop("DEBUG_DATA_IMPORT_TARGETS must be a non-empty list.")
    }

    normalized_targets <- lapply(seq_along(targets), function(i) {
      target <- targets[[i]]
      if (!is.list(target) || is.null(target$resource) || is.null(target$columns)) {
        stop("Each DEBUG_DATA_IMPORT_TARGETS entry must define 'resource' and 'columns'. Invalid entry index: ", i)
      }
      resource <- as.character(target$resource)[1]
      columns <- unique(as.character(target$columns))
      columns <- columns[nzchar(columns)]
      if (!nzchar(resource) || !length(columns)) {
        stop("Each DEBUG_DATA_IMPORT_TARGETS entry must contain one non-empty resource and at least one non-empty column. Invalid entry index: ", i)
      }
      list(resource = resource, columns = columns)
    })
    normalized_targets
  }

  if (
    etlutils::isProcess("DataImport") ||
    etlutils::isSubProcess("DataImport.All") ||
    etlutils::isSubProcess("DataImport.ResourceTypes")
  ) {
    etlutils::catInfoMessage(
      "Info: Skip RAW column blanking during DataImport so the backfill can be reloaded.\n"
    )
  } else {
    targets <- normalizeDebugDataImportTargets()

    for (target in targets) {
      resource_match_index <- match(
        tolower(target$resource),
        tolower(names(resource_tables))
      )

      if (is.na(resource_match_index)) {
        stop(
          "Resource '", target$resource, "' not found in resource_tables. Available: ",
          paste(names(resource_tables), collapse = ", "),
          ". This check runs during the initial full cds2db import. ",
          "DATA_IMPORT_RESOURCE_TYPES from cds2db_config.toml only affects the second StartDataImport run."
        )
      }

      resource_name <- names(resource_tables)[resource_match_index]
      resource_table <- resource_tables[[resource_name]]

      missing_columns <- setdiff(target$columns, names(resource_table))
      if (length(missing_columns)) {
        stop(
          "Column(s) '", paste(
            missing_columns,
            collapse = ", "
          ),
          "' not found in resource ", resource_name, "."
        )
      }

      if (!nrow(resource_table)) {
        stop(
          "Resource '", resource_name, "' was loaded with 0 rows. ",
          "The configured target columns exist, but there is no RAW data to blank out. ",
          "Choose another resource/column or narrow the test to a resource type that is actually present in this run."
        )
      }

      resource_table[, (target$columns) := lapply(target$columns, function(x) NA_character_)]
      resource_tables[[resource_name]] <- resource_table

      etlutils::catInfoMessage(paste0(
        "Info: Set ", resource_name, "$", paste(
          target$columns,
          collapse = ", "
        ),
        " to NA in ", nrow(resource_table),
        " RAW row(s) to prepare the data-import backfill test.\n"
      ))
    }
  }
}
