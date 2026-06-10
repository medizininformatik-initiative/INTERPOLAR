# Paths to the submodule directory and the manual start submodule directory
DATAPROCESSOR_SUBMODULES_PATH <- "./R-dataprocessor/submodules"
DATAPROCESSOR_MANUAL_START_PATH <- "./R-dataprocessor/submodules/manual_start"

#' Source all R files in a package submodule directory
#'
#' Recursively scans the top-level subdirectories of a project directory for
#' an R/ folder and sources all R scripts found there, except for the
#' optional ignore file. It also sources R files directly in the given
#' directory itself, again skipping the ignore file.
#'
#' @param dir Character string specifying the project or package directory
#'   to scan.
#' @param ignore_file Character string with the file name to skip during
#'   sourcing. Defaults to "Start.R".
#'
#' @return Invisible NULL. The function is used for its side effect of
#'   sourcing R files.
#'
sourceSubmoduleRFiles <- function(dir, ignore_file = "Start.R") {
  # Source all R scripts in R subdirectory of an package project
  submodule_subdirs <- list.dirs(dir, recursive = FALSE)
  for (subdir in submodule_subdirs) {
    subdir_rpath <- paste0(subdir, "/R")
    if (dir.exists(subdir_rpath)) {
      r_scripts <- list.files(subdir_rpath, pattern = "\\.R$", full.names = TRUE)
      for (script in r_scripts) {
        if (basename(script) != ignore_file) {
          source(script)
        }
      }
    }
  }

  # Source all R files in the subdirectory itself (but not Start.R)
  r_scripts <- list.files(dir, pattern = "\\.R$", full.names = TRUE)
  for (script in r_scripts) {
    # Source each R script except Start.R
    if (basename(script) != ignore_file) {
      source(script)
    }
  }
}

#' Source all R files from all submodules
#'
#' Iterates over all top-level submodule directories below
#' DATAPROCESSOR_SUBMODULES_PATH and sources their R files via
#' sourceSubmoduleRFiles().
#'
#' @return Invisible NULL. The function is used for its side effect of
#'   sourcing R files from all available submodules.
sourceAllSubmodules <- function() {
  submodule_dirs <- list.dirs(DATAPROCESSOR_SUBMODULES_PATH, recursive = FALSE)
  for (dir in submodule_dirs) {
    sourceSubmoduleRFiles(dir)
  }
}
