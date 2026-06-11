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

normalizeMultilineIfOpening <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  output <- character()
  index <- 1L

  while (index <= length(lines)) {
    line <- lines[[index]]
    next_line <- if (index < length(lines)) lines[[index + 1L]] else ""

    if_match <- regexec("^(\\s*)if \\((.+(?:&&|\\|\\|)\\s*)$", line, perl = TRUE)
    if_parts <- regmatches(line, if_match)[[1L]]

    should_split <- length(if_parts) == 3L &&
      grepl("^\\s+", next_line, perl = TRUE) &&
      !grepl("^\\s*\\)", next_line, perl = TRUE)

    if (should_split) {
      indent <- if_parts[[2L]]
      condition_start <- trimws(if_parts[[3L]])
      output <- c(
        output,
        paste0(indent, "if ("),
        paste0(indent, "  ", condition_start)
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

removeBlankLinesAroundBraces <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  output <- character()

  for (index in seq_along(lines)) {
    line <- lines[[index]]
    previous_line <- if (length(output)) output[[length(output)]] else ""
    next_line <- if (index < length(lines)) lines[[index + 1L]] else ""
    is_blank <- !nzchar(trimws(line))

    should_drop <- is_blank &&
      (
        grepl("\\{\\s*$", previous_line, perl = TRUE) ||
          grepl("^\\s*\\}+\\)*\\s*$", next_line, perl = TRUE)
      )

    if (!should_drop) {
      output <- c(output, line)
    }
  }

  if (!identical(lines, output)) {
    writeLines(output, file_path, useBytes = TRUE)
  }
}

stripQuotedText <- function(line) {
  line <- gsub('"([^"\\\\]|\\\\.)*"', '""', line, perl = TRUE)
  gsub("'([^'\\\\]|\\\\.)*'", "''", line, perl = TRUE)
}

parenBalance <- function(line) {
  line_without_strings <- stripQuotedText(line)
  opens <- gregexpr("(", line_without_strings, fixed = TRUE)[[1L]]
  closes <- gregexpr(")", line_without_strings, fixed = TRUE)[[1L]]
  open_count <- if (identical(opens, -1L)) 0L else length(opens)
  close_count <- if (identical(closes, -1L)) 0L else length(closes)
  open_count - close_count
}

removeLastClosingParen <- function(line) {
  sub("\\)([^)]*)$", "\\1", line, perl = TRUE)
}

formatIfConditionLines <- function(condition_lines, indent) {
  group_depth <- 0L
  condition_indent <- paste0(indent, "  ")

  vapply(condition_lines, function(condition_line) {
    condition_line <- trimws(condition_line)
    line_balance <- parenBalance(condition_line)
    extra_indent <- if (group_depth > 0L) 2L * (group_depth + 1L) else 0L

    if (startsWith(condition_line, "(") && line_balance > 0L) {
      extra_indent <- extra_indent + 2L
    }

    group_depth <<- max(0L, group_depth + line_balance)
    paste0(condition_indent, strrep(" ", extra_indent), condition_line)
  }, character(1L), USE.NAMES = FALSE)
}

normalizeMultilineIfBlock <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  output <- character()
  index <- 1L

  while (index <= length(lines)) {
    line <- lines[[index]]
    if_match <- regexec("^(\\s*)if \\(\\s*$", line, perl = TRUE)
    if_parts <- regmatches(line, if_match)[[1L]]

    if (length(if_parts) != 2L || index == length(lines)) {
      output <- c(output, line)
      index <- index + 1L
      next
    }

    indent <- if_parts[[2L]]
    condition_lines <- character()
    cursor <- index + 1L

    while (cursor <= length(lines)) {
      condition_line <- trimws(lines[[cursor]])

      if (grepl("^\\)\\s*\\{\\s*$", condition_line, perl = TRUE)) {
        break
      }

      if (grepl("\\)\\s*\\{\\s*$", condition_line, perl = TRUE)) {
        condition_without_if_close <- trimws(removeLastClosingParen(trimws(sub("\\{\\s*$", "", condition_line, perl = TRUE))))
        if (nzchar(condition_without_if_close)) {
          condition_lines <- c(condition_lines, condition_without_if_close)
        }
        break
      }

      condition_lines <- c(condition_lines, condition_line)
      cursor <- cursor + 1L
    }

    if (cursor <= length(lines) && length(condition_lines) > 0L) {
      output <- c(
        output,
        paste0(indent, "if ("),
        formatIfConditionLines(condition_lines, indent),
        paste0(indent, ") {")
      )
      index <- cursor + 1L
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
  invisible(lapply(style_files, normalizeMultilineIfOpening))
  invisible(lapply(style_files, normalizeMultilineIfBlock))
  invisible(lapply(style_files, removeBlankLinesAroundBraces))
  invisible(lapply(style_files, normalizeShortSingleArgumentCalls))
  invisible(lapply(style_files, normalizeShortDataTableListCalls))
  invisible(lapply(style_files, normalizeShortStringFunctionCalls))
}

normalizeShortStringFunctionCalls <- function(file_path, width = 100L) {
  lines <- readLines(file_path, warn = FALSE)
  output <- character()
  index <- 1L

  while (index <= length(lines)) {
    line <- lines[[index]]
    next_line <- if (index < length(lines)) lines[[index + 1L]] else ""

    open_match <- regexec('^(\\s*)"([^"]*\\()\\s*$', line, perl = TRUE)
    continuation_match <- regexec('^\\s*([^"]*\\)[^"]*)"(.*)$', next_line, perl = TRUE)

    open_parts <- regmatches(line, open_match)[[1L]]
    continuation_parts <- regmatches(next_line, continuation_match)[[1L]]
    collapsed_line <- if (length(open_parts) == 3L && length(continuation_parts) == 3L) {
      paste0(open_parts[[2L]], '"', open_parts[[3L]], trimws(continuation_parts[[2L]]), '"', continuation_parts[[3L]])
    } else {
      ""
    }

    should_collapse <- length(open_parts) == 3L &&
      length(continuation_parts) == 3L &&
      nchar(collapsed_line, type = "width") <= width

    if (should_collapse) {
      output <- c(output, collapsed_line)
      index <- index + 2L
    } else {
      output <- c(output, line)
      index <- index + 1L
    }
  }

  if (!identical(lines, output)) {
    writeLines(output, file_path, useBytes = TRUE)
  }
}

styleFile <- function(file_path) {
  styler::style_file(
    path = file_path,
    transformers = style_transformer,
    include_roxygen_examples = FALSE
  )

  normalizeMultilineCallFirstArgument(file_path)
  normalizeMultilineIfOpening(file_path)
  normalizeMultilineIfBlock(file_path)
  removeBlankLinesAroundBraces(file_path)
  normalizeShortSingleArgumentCalls(file_path)
  normalizeShortDataTableListCalls(file_path)
  normalizeShortStringFunctionCalls(file_path)

  styler::style_file(
    path = file_path,
    transformers = style_transformer,
    include_roxygen_examples = FALSE
  )

  normalizeMultilineCallFirstArgument(file_path)
  normalizeMultilineIfOpening(file_path)
  normalizeMultilineIfBlock(file_path)
  removeBlankLinesAroundBraces(file_path)
  normalizeShortSingleArgumentCalls(file_path)
  normalizeShortDataTableListCalls(file_path)
  normalizeShortStringFunctionCalls(file_path)
}

stylePath <- function(style_path) {
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

if (isTRUE(getOption("interpolar.style.autorun", TRUE))) {
  invisible(lapply(existing_style_paths, stylePath))
}
