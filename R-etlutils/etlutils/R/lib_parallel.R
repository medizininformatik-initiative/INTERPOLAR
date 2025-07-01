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
#' @param os A character string representing the operating system name. If `NULL`, the function will
#' determine the operating system automatically.
#' @return An integer specifying the number of cores available for parallelization.
#'
#' @export
parallelGetAvailableCoreNumber <- function(os = NULL) {

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
  if (0 < MAX_CORES) min(n_cores, MAX_CORES) else n_cores
}
