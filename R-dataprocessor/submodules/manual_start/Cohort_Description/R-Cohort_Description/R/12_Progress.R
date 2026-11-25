#' Log a cohort step and its duration through the existing console logging utilities
#'
#' Console output is captured by the normal manual-submodule log. Progress remains
#' visible at the default verbosity; the enclosing runLevel2 handles errors.
#' @param label Aggregate step description, without patient identifiers.
#' @param process Expression evaluated in its caller's environment.
#' @return The expression result, preserving visibility. Errors propagate unchanged.
runCohortStep <- function(label, process) {
  started <- proc.time()[["elapsed"]]
  status <- "failed"
  etlutils::catColourised(paste0("Cohort Description: ", label, " — starting"))
  flush.console()
  on.exit(
    {
      duration <- sprintf("%.1f s", proc.time()[["elapsed"]] - started)
      etlutils::catColourised(paste0("Cohort Description: ", label, " — ", status, " (", duration, ")"))
      flush.console()
    },
    add = TRUE
  )
  result <- withVisible(force(process))
  status <- "completed"
  if (result$visible) result$value else invisible(result$value)
}
