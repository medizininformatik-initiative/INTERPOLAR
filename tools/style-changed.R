findRepoRoot <- function(start_path = getwd()) {
  current_path <- normalizePath(start_path, winslash = "/", mustWork = TRUE)

  repeat {
    if (dir.exists(file.path(current_path, ".git")) && file.exists(file.path(current_path, "tools", "style.R"))) {
      return(current_path)
    }

    parent_path <- dirname(current_path)
    if (identical(parent_path, current_path)) {
      stop("Could not find the INTERPOLAR repository root above: ", start_path, call. = FALSE)
    }

    current_path <- parent_path
  }
}

gitLines <- function(args) {
  output <- system2("git", args, stdout = TRUE, stderr = FALSE)
  if (identical(attr(output, "status"), 0L) || is.null(attr(output, "status"))) {
    output[nzchar(output)]
  } else {
    character()
  }
}

getMergeBase <- function(base_ref) {
  output <- system2("git", c("merge-base", base_ref, "HEAD"), stdout = TRUE, stderr = FALSE)
  if (identical(attr(output, "status"), 0L) || is.null(attr(output, "status"))) {
    output[[1L]]
  } else {
    character()
  }
}

changedFiles <- function(base_ref = Sys.getenv("INTERPOLAR_STYLE_BASE", "origin/develop")) {
  merge_base <- getMergeBase(base_ref)
  committed_files <- if (length(merge_base) == 1L && nzchar(merge_base)) {
    gitLines(c("diff", "--name-only", "--diff-filter=ACMR", paste0(merge_base, "...HEAD")))
  } else {
    character()
  }

  all_changed_files <- unique(c(
    committed_files,
    gitLines(c("diff", "--name-only", "--diff-filter=ACMR")),
    gitLines(c("diff", "--cached", "--name-only", "--diff-filter=ACMR"))
  ))

  all_changed_files[grepl("[.]R$", all_changed_files)]
}

isInStyleScope <- function(file_path, style_roots) {
  normalized_file <- normalizePath(file_path, winslash = "/", mustWork = TRUE)
  any(vapply(
    style_roots,
    function(style_root) startsWith(normalized_file, paste0(normalizePath(style_root, winslash = "/", mustWork = TRUE), "/")),
    logical(1L)
  ))
}

previous_wd <- getwd()
repo_root <- findRepoRoot(previous_wd)
old_autorun <- getOption("interpolar.style.autorun")

on.exit(setwd(previous_wd), add = TRUE)
on.exit(options(interpolar.style.autorun = old_autorun), add = TRUE)

setwd(repo_root)
options(interpolar.style.autorun = FALSE)
source(file.path("tools", "style.R"))

files_to_style <- changedFiles()
files_to_style <- files_to_style[file.exists(files_to_style)]
files_to_style <- files_to_style[vapply(files_to_style, isInStyleScope, logical(1L), existing_style_paths)]

if (length(files_to_style) == 0L) {
  message("No changed R files found in the configured style scope.")
} else {
  message("Formatting changed R files:")
  invisible(lapply(files_to_style, function(file_path) {
    message("  ", file_path)
    styleFile(file_path)
  }))
}

message("Restored working directory: ", previous_wd)
