#' Get the Operating System Name
#'
#' This function retrieves the name of the operating system and returns it in lowercase.
#'
#' @return A character string representing the operating system name.
#'
parallelGetOperationSystem <- function() {
  sysinf <- Sys.info()
  if (!is.null(sysinf)) {
    os <- sysinf[['sysname']]
    if (os == 'Darwin') os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  tolower(os)
}

#' Get the Number of Cores Available for Parallelization
#'
#' This function determines the number of CPU cores available for parallelization
#' based on the operating system.
#'
#' @param os A character string representing the operating system name.
#' @return An integer specifying the number of cores available for parallelization.
#'
#' @export
parallelGetAvailableCoreNumber <- function(os) {
  n_cores <- if (os %in% c("linux", "osx")) parallel::detectCores() else 1
  if (0 < MAX_CORES) min(n_cores, MAX_CORES) else n_cores
}
