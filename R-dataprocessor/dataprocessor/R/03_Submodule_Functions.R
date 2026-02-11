# Paths to the submodule directory and the manual start submodule directory
DATAPROCESSOR_SUBMODULES_PATH <- "./R-dataprocessor/submodules"
DATAPROCESSOR_MANUAL_START_PATH <- "./R-dataprocessor/submodules/manual_start"

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

sourceAllSubmodules <- function() {
  submodule_dirs <- list.dirs(DATAPROCESSOR_SUBMODULES_PATH, recursive = FALSE)
  for (dir in submodule_dirs) {
    sourceSubmoduleRFiles(dir)
  }
}
