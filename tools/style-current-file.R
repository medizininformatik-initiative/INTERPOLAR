findInterpolarRoot <- function(start_path = getwd()) {
  current_path <- normalizePath(start_path, winslash = "/", mustWork = TRUE)

  repeat {
    has_formatter <- file.exists(file.path(current_path, "tools", "style.R"))
    has_editorconfig <- file.exists(file.path(current_path, ".editorconfig"))

    if (has_formatter && has_editorconfig) {
      return(current_path)
    }

    parent_path <- dirname(current_path)
    if (identical(parent_path, current_path)) {
      stop(
        "Could not find the INTERPOLAR repository root above: ",
        start_path,
        call. = FALSE
      )
    }

    current_path <- parent_path
  }
}

getCurrentRStudioFile <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE) || !rstudioapi::isAvailable()) {
    stop("`tools/style-current-file.R` must be run from RStudio.", call. = FALSE)
  }

  document_context <- rstudioapi::getActiveDocumentContext()
  file_path <- document_context$path

  if (!nzchar(file_path)) {
    stop("The active RStudio document must be saved before it can be styled.", call. = FALSE)
  }

  normalizePath(file_path, winslash = "/", mustWork = TRUE)
}

previous_wd <- getwd()
file_path <- getCurrentRStudioFile()
repo_root <- findInterpolarRoot(dirname(file_path))
old_autorun <- getOption("interpolar.style.autorun")

on.exit(setwd(previous_wd), add = TRUE)
on.exit(options(interpolar.style.autorun = old_autorun), add = TRUE)

setwd(repo_root)
options(interpolar.style.autorun = FALSE)
source(file.path("tools", "style.R"))

message("Formatting current file: ", file_path)
styleFile(file_path)
message("Restored working directory: ", previous_wd)
