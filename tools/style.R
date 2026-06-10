styler::cache_deactivate()

source("tools/styler-style.R")

style_transformer <- interpolarStylerStyle()

style_paths <- c(
  "R-cds2db",
  "R-cdstoolchain",
  "R-dataprocessor",
  "R-db2frontend",
  "R-etlutils",
  "Postgres-cds_hub/R-initcdstoolchain"
)

existing_style_paths <- style_paths[dir.exists(style_paths)]

normalizeMultilineCallFirstArgument <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  output <- character()
  index <- 1L

  while (index <= length(lines)) {
    line <- lines[[index]]
    next_line <- if (index < length(lines)) lines[[index + 1L]] else ""

    call_match <- regexec(
      "^(\\s*)(.*[[:alnum:]_.:]+)\\(([^,()]+),\\s*$",
      line,
      perl = TRUE
    )
    call_parts <- regmatches(line, call_match)[[1L]]

    should_split_first_argument <- length(call_parts) == 4L &&
      grepl("^\\s+[[:alpha:]_.][[:alnum:]_.]*\\s*=", next_line, perl = TRUE) &&
      !grepl("\\b(function|if|for|while|repeat)\\s*\\(", line, perl = TRUE)

    if (should_split_first_argument) {
      indent <- call_parts[[2L]]
      call_prefix <- call_parts[[3L]]
      first_argument <- trimws(call_parts[[4L]])
      output <- c(
        output,
        paste0(indent, call_prefix, "("),
        paste0(indent, "  ", first_argument, ",")
      )
    } else {
      output <- c(output, line)
    }

    index <- index + 1L
  }

  if (!identical(lines, output)) {
    writeLines(output, file_path, useBytes = TRUE)
  }
}

normalizeShortSingleArgumentCalls <- function(file_path, width = 100L) {
  lines <- readLines(file_path, warn = FALSE)
  output <- character()
  index <- 1L

  while (index <= length(lines)) {
    line <- lines[[index]]
    argument_line <- if (index + 1L <= length(lines)) lines[[index + 1L]] else ""
    closing_line <- if (index + 2L <= length(lines)) lines[[index + 2L]] else ""

    call_match <- regexec(
      "^(.+\\b[[:alnum:]_.:]+\\()\\s*$",
      line,
      perl = TRUE
    )
    closing_match <- regexec(
      "^\\s*\\)(.*)$",
      closing_line,
      perl = TRUE
    )

    call_parts <- regmatches(line, call_match)[[1L]]
    closing_parts <- regmatches(closing_line, closing_match)[[1L]]
    argument <- trimws(argument_line)

    should_collapse <- length(call_parts) == 2L &&
      length(closing_parts) == 2L &&
      nzchar(argument) &&
      !grepl("[,=]$", argument, perl = TRUE) &&
      !grepl("^\\s*#", line) &&
      nchar(paste0(call_parts[[2L]], argument, ")", closing_parts[[2L]]), type = "width") <= width

    if (should_collapse) {
      collapsed_line <- paste0(call_parts[[2L]], argument, ")", closing_parts[[2L]])
      output <- c(output, collapsed_line)
      index <- index + 3L
    } else {
      output <- c(output, line)
      index <- index + 1L
    }
  }

  if (!identical(lines, output)) {
    writeLines(output, file_path, useBytes = TRUE)
  }
}

normalizeShortDataTableListCalls <- function(file_path, width = 100L) {
  lines <- readLines(file_path, warn = FALSE)
  output <- character()
  index <- 1L

  while (index <= length(lines)) {
    line <- lines[[index]]
    argument_line <- if (index + 1L <= length(lines)) lines[[index + 1L]] else ""
    closing_line <- if (index + 2L <= length(lines)) lines[[index + 2L]] else ""

    call_match <- regexec("^(.*\\.\\()\\s*$", line, perl = TRUE)
    closing_match <- regexec("^\\s*\\)(.*)$", closing_line, perl = TRUE)

    call_parts <- regmatches(line, call_match)[[1L]]
    closing_parts <- regmatches(closing_line, closing_match)[[1L]]
    argument <- trimws(argument_line)
    collapsed_line <- if (length(call_parts) == 2L && length(closing_parts) == 2L) {
      paste0(call_parts[[2L]], argument, ")", closing_parts[[2L]])
    } else {
      ""
    }

    should_collapse <- length(call_parts) == 2L &&
      length(closing_parts) == 2L &&
      nzchar(argument) &&
      !grepl(",", argument, fixed = TRUE) &&
      nchar(collapsed_line, type = "width") <= width

    if (should_collapse) {
      output <- c(output, collapsed_line)
      index <- index + 3L
    } else {
      output <- c(output, line)
      index <- index + 1L
    }
  }

  if (!identical(lines, output)) {
    writeLines(output, file_path, useBytes = TRUE)
  }
}

runPostProcessors <- function(style_path) {
  style_files <- list.files(style_path, pattern = "[.]R$", recursive = TRUE, full.names = TRUE)
  invisible(lapply(style_files, normalizeMultilineCallFirstArgument))
  invisible(lapply(style_files, normalizeShortSingleArgumentCalls))
  invisible(lapply(style_files, normalizeShortDataTableListCalls))
}

styleProject <- function(style_path) {
  styler::style_dir(
    path = style_path,
    recursive = TRUE,
    transformers = style_transformer,
    filetype = "R",
    include_roxygen_examples = FALSE
  )

  runPostProcessors(style_path)

  styler::style_dir(
    path = style_path,
    recursive = TRUE,
    transformers = style_transformer,
    filetype = "R",
    include_roxygen_examples = FALSE
  )

  runPostProcessors(style_path)
}

invisible(lapply(existing_style_paths, styleProject))
