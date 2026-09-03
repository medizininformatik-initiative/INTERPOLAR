#' Get the Operating System Name
#'
#' This function retrieves the name of the operating system and returns it in lowercase.
#'
#' @return A character string representing the operating system name.
#'
parallelGetOperationSystem <- function() {
  sysinf <- Sys.info()
  if (!is.null(sysinf)) {
    os <- sysinf[["sysname"]]
    if (os == "Darwin") os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  tolower(os)
}

#' Normalize a Detected Core Count
#'
#' This internal helper converts detected CPU counts and configured limits to a valid integer
#' `mc.cores` value. A `max_cores` value of `0` means all available cores minus one.
#'
#' @param n_cores Numeric value with the detected number of available cores.
#' @param max_cores Numeric value with the configured maximum number of cores.
#' @return An integer core count of at least one.
#'
parallelNormalizeCoreNumber <- function(n_cores, max_cores = 0) {
  n_cores <- floor(as.numeric(n_cores)[1])
  if (is.na(n_cores) || !is.finite(n_cores) || n_cores < 1) {
    n_cores <- 1L
  }

  max_cores <- floor(as.numeric(max_cores)[1])
  if (is.na(max_cores) || !is.finite(max_cores)) {
    max_cores <- 0L
  }

  if (0 < max_cores) {
    as.integer(max(1L, min(n_cores, max_cores)))
  } else {
    as.integer(max(1L, n_cores - 1L))
  }
}

#' Get the Number of Cores Available for Parallelization
#'
#' This function determines the number of CPU cores available for parallelization
#' based on the operating system. If `max_cores` is `0`, one detected core is reserved for
#' the operating system and other processes.
#'
#' @param os A character string representing the operating system name. If `NULL`, the
#' function will determine the operating system automatically.
#' @param max_cores Numeric value with the configured maximum number of cores. A value of
#' `0` means all available cores minus one.
#' @return An integer specifying the number of cores available for parallelization.
#'
#' @export
parallelGetAvailableCoreNumber <- function(os = NULL, max_cores = 0) {
  if (is.null(os)) {
    os <- parallelGetOperationSystem()
  }

  # Detect CPU limit inside Docker, supporting both cgroup v1 and v2
  getDockerCpuLimit <- function() {
    # cgroup v2 path
    cpu_max_path_v2 <- "/sys/fs/cgroup/cpu.max"

    # cgroup v1 paths
    cpu_quota_path_v1 <- "/sys/fs/cgroup/cpu/cpu.cfs_quota_us"
    cpu_period_path_v1 <- "/sys/fs/cgroup/cpu/cpu.cfs_period_us"

    if (file.exists(cpu_max_path_v2)) {
      # cgroup v2 logic
      cpu_max <- readLines(cpu_max_path_v2, warn = FALSE)
      parts <- strsplit(cpu_max, " ")[[1]]

      quota <- parts[1]
      period <- parts[2]

      if (quota == "max") {
        return(parallel::detectCores())
      }

      quota <- as.numeric(quota)
      period <- as.numeric(period)

      if (!is.na(quota) && !is.na(period) && period > 0) {
        return(quota / period)
      }
    } else if (file.exists(cpu_quota_path_v1) && file.exists(cpu_period_path_v1)) {
      # cgroup v1 logic
      quota <- as.numeric(readLines(cpu_quota_path_v1, warn = FALSE))
      period <- as.numeric(readLines(cpu_period_path_v1, warn = FALSE))

      if (quota > 0 && period > 0) {
        return(quota / period)
      }
    }

    # Fallback: return total detected cores
    return(parallel::detectCores())
  }

  n_cores <- if (os %in% c("linux", "osx")) getDockerCpuLimit() else 1
  parallelNormalizeCoreNumber(n_cores, max_cores)
}
