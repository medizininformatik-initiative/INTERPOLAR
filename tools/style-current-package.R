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

findPackageRoot <- function(start_path = getwd()) {
  current_path <- normalizePath(start_path, winslash = "/", mustWork = TRUE)

  repeat {
    if (file.exists(file.path(current_path, "DESCRIPTION"))) {
      return(current_path)
    }

    parent_path <- dirname(current_path)
    if (identical(parent_path, current_path)) {
      stop(
        "Could not find an R package DESCRIPTION above: ",
        start_path,
        call. = FALSE
      )
    }

    current_path <- parent_path
  }
}

getStartPath <- function() {
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    active_project <- rstudioapi::getActiveProject()
    if (!is.null(active_project) && nzchar(active_project)) {
      return(active_project)
    }

    document_context <- rstudioapi::getActiveDocumentContext()
    if (nzchar(document_context$path)) {
      return(dirname(document_context$path))
    }
  }

  getwd()
}

previous_wd <- getwd()
package_root <- findPackageRoot(getStartPath())
repo_root <- findInterpolarRoot(package_root)
old_autorun <- getOption("interpolar.style.autorun")

on.exit(setwd(previous_wd), add = TRUE)
on.exit(options(interpolar.style.autorun = old_autorun), add = TRUE)

setwd(repo_root)
options(interpolar.style.autorun = FALSE)
source(file.path("tools", "style.R"))

message("Formatting current package: ", package_root)
stylePath(package_root)
message("Restored working directory: ", previous_wd)
