# Rotate TOP outputs with the same helper used by the R modules.
# Both output roots are mounted below /outputs, independently of the host path.
initializeTopOutput <- function(max_dir_count) {
  if (
    length(max_dir_count) != 1L || is.na(max_dir_count) ||
    !is.numeric(max_dir_count) || max_dir_count < 1 || max_dir_count != trunc(max_dir_count)
  ) {
    stop("MAX_DIR_COUNT muss eine positive ganze Zahl sein.")
  }
  directories <- file.path(c("outputLocal", "outputGlobal"), "top-study")
  # Check both destinations before rotating either side. The shared helper uses
  # ctime with second precision, so a rapid restart can otherwise overwrite a run.
  for (directory in directories) {
    if (!is.na(Sys.readlink(directory)) && nzchar(Sys.readlink(directory))) {
      stop("Der Ausgabeordner darf kein symbolischer Link sein: ", directory)
    }
    if (file.exists(directory) && !dir.exists(directory)) {
      stop("Der Ausgabepfad ist kein Ordner: ", directory)
    }
    if (dir.exists(directory)) {
      timestamp <- format(
        etlutils::as.POSIXctWithTimezone(file.info(directory)$ctime), "%Y-%m-%d_%H-%M-%S"
      )
      archive <- paste0(directory, "_", timestamp)
      if (file.exists(archive)) stop("Der vorherige Laufordner existiert bereits: ", archive)
    }
  }
  for (directory in directories) {
    etlutils::renameWithCreationTimeIfDirExists(directory, max_dir_count)
    if (dir.exists(directory)) stop("Der bisherige Laufordner konnte nicht umbenannt werden: ", directory)
    if (!dir.create(directory, recursive = TRUE)) stop("Ausgabeordner konnte nicht angelegt werden: ", directory)
  }
}

if (sys.nframe() == 0L) {
  config <- etlutils::readTomlAsNamedList("/src/R-dataprocessor/dataprocessor_config.toml")
  max_dir_count <- config$MAX_DIR_COUNT
  if (is.null(max_dir_count)) max_dir_count <- 5L
  setwd("/outputs")
  initializeTopOutput(max_dir_count)
}
