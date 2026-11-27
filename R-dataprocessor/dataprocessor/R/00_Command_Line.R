# Run the full cohort command with fresh R heaps and reuse the existing
# single-source command in each worker.
processDataCommandLine <- function(
  script_path,
  args = commandArgs(trailingOnly = TRUE)
) {
  project <- validateManualStartInvocation(args, list.dirs(DATAPROCESSOR_MANUAL_START_PATH, recursive = FALSE))
  if (
    !identical(basename(project), "Cohort_Description") ||
    any(startsWith(args, "database-source="))
  ) {
    return(processData(command_line_args = args))
  }

  config_path <- file.path(project, DATAPROCESSOR_PROJECT_DATABASE_CONFIG)
  sources <- if (file.exists(config_path)) names(RcppTOML::parseToml(config_path)$sources) else NULL
  if (!setequal(sources, c("regular", "broad_consent"))) {
    return(processData(command_line_args = args))
  }

  # Validate both connections before any worker can write results.
  tryCatch(
    configureManualStartDatabase(init(), args),
    finally = etlutils::dbCloseAllConnections()
  )
  for (source in sources) {
    message("Cohort Description: starting ", source, " in a fresh R process.")
    status <- runDataProcessorWorker(script_path, c(args, paste0("database-source=", source)))
    if (status != 0L) {
      message("Cohort Description: ", source, " failed with exit code ", status, ".")
      return(status)
    }
  }
  0L
}

runDataProcessorWorker <- function(script_path, args) {
  system2(file.path(R.home("bin"), "Rscript"), shQuote(c(script_path, args)))
}
