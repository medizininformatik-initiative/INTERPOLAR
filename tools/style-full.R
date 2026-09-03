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

previous_wd <- getwd()
repo_root <- findInterpolarRoot(previous_wd)

on.exit(setwd(previous_wd), add = TRUE)
setwd(repo_root)

message("Formatting complete INTERPOLAR R scope from: ", repo_root)
source(file.path("tools", "style.R"))
message("Restored working directory: ", previous_wd)
