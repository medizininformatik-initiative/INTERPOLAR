# Run from the repository root with Rscript.
source("TOP-Framework/initialize-output.R")

checkOutputRotation <- function() {
  previous_directory <- getwd()
  workspace <- tempfile("top-output-")
  dir.create(workspace)
  on.exit({
    setwd(previous_directory)
    unlink(workspace, recursive = TRUE)
  })
  setwd(workspace)
  initializeTopOutput(5L)
  stopifnot(dir.exists("outputLocal/top-study"), dir.exists("outputGlobal/top-study"))
  # Existing run collections must survive the first rotation intact.
  dir.create("outputLocal/top-study/previous-run")
  writeLines("private", "outputLocal/top-study/previous-run/result.txt")
  writeLines("aggregate", "outputGlobal/top-study/report.txt")
  initializeTopOutput(5L)
  local_archive <- list.files("outputLocal", "^top-study_", full.names = TRUE)
  global_archive <- list.files("outputGlobal", "^top-study_", full.names = TRUE)
  stopifnot(
    length(local_archive) == 1L, length(global_archive) == 1L,
    identical(readLines(file.path(local_archive, "previous-run/result.txt")), "private"),
    identical(readLines(file.path(global_archive, "report.txt")), "aggregate"),
    length(list.files("outputLocal/top-study")) == 0L,
    length(list.files("outputGlobal/top-study")) == 0L
  )
  # A colliding destination must stop before either current directory is moved.
  timestamp <- format(
    etlutils::as.POSIXctWithTimezone(file.info("outputGlobal/top-study")$ctime),
    "%Y-%m-%d_%H-%M-%S"
  )
  collision <- paste0("outputGlobal/top-study_", timestamp)
  dir.create(collision, showWarnings = FALSE)
  writeLines("keep", "outputLocal/top-study/current.txt")
  stopifnot(inherits(try(initializeTopOutput(5L), silent = TRUE), "try-error"))
  stopifnot(identical(readLines("outputLocal/top-study/current.txt"), "keep"))
  # Verify the shared retention rule without a timestamp collision.
  unlink(c(local_archive, global_archive, collision), recursive = TRUE)
  for (parent in c("outputLocal", "outputGlobal")) {
    for (day in 1:3) dir.create(file.path(parent, sprintf("top-study_2000-01-%02d_00-00-00", day)))
  }
  initializeTopOutput(2L)
  for (parent in c("outputLocal", "outputGlobal")) {
    stopifnot(length(list.files(parent, "^top-study_")) == 2L)
    stopifnot(!dir.exists(file.path(parent, "top-study_2000-01-01_00-00-00")))
  }
  stopifnot(inherits(try(initializeTopOutput(0L), silent = TRUE), "try-error"))
  cat("PASS: current outputs, preserved history, collision protection and retention.\n")
}

checkOutputRotation()
