#' Run and log a process
#'
#' @param message A character of length one. Has to be unique
#' @param process An expression
#' @param single_line A logical of length one
#' @param throw_exception A logical of length one. Should catched error throw again
#' @param verbose The verbose level
#'
#' @return The value process returns.
#'
#' @export
polar_run <- function(
    message,
    process,
    single_line = TRUE,
    throw_exception = TRUE,
    verbose = VERBOSE
) {
  if (0 < VERBOSE) {
    st <- Sys.time()
    cat("[TIME]", round(as.numeric(st), 0), format(st), "\n")

    cat(paste0(message, ':', if (single_line) ' ' else paste0(colourise(text = ' RUNNING ...', fg = 'blue'), '\n')))
  }

  err <- POLAR_CLOCK$measure_process_time(
    message = message,
    process = process
  )
  if (!single_line && 0 < VERBOSE) cat(paste0(message, ': ' ))
  if (0 < VERBOSE) {
    check_error(
      err = err,
      expr_ok = {
        if (single_line) cat_ok() else cat_colourised('OK\n', fg = 'light blue')
        err
      },
      expr_err = {
        cat_error()
        if (throw_exception) {
          stop(err)
        }
      }
    )
  }
}

#' Add Common Parameters to FHIR Resource Request
#'
#' This function adds common parameters, such as '_count' and '_sort', to a list of FHIR resource query parameters.
#'
#' @param parameters A list of FHIR resource query parameters.
#'
#' @return A modified list of FHIR resource query parameters with common parameters added.
#'
#' @export
polar_add_common_request_params <- function(parameters = NULL) {
  parameters <- parameters[!is.na(parameters)]
  if (!'_count' %in% names(parameters) && exists('COUNT_PER_BUNDLE') && !is.null(COUNT_PER_BUNDLE) && !is.na(COUNT_PER_BUNDLE) && COUNT_PER_BUNDLE != '') {
    parameters <- c(parameters, c('_count' = COUNT_PER_BUNDLE))
  }
  if (!'_sort' %in% names(parameters) && exists('SORT') && !is.null(SORT) && !is.na(SORT) && SORT != '') {
    parameters <- c(parameters, c('_sort' = SORT))
  }
  parameters
}

#' Check for Errors
#'
#' @param err Any Type. In case of an error occurred it must contain try-error as class
#' @param expr_ok An expression. This runs in case of no error.
#' @param expr_err An expression. This runs in case of an error.
#'
#' @return err
#' @export
check_error <- function(err, expr_ok = {cat_ok()}, expr_err = {cat_error()}) {

  if (!inherits(err, 'try-error')) {
    expr_ok
  } else {
    expr_err
  }
}

#' Convert Numbers to Verbose Number Representations
#'
#' This function converts numbers to verbose number representations, such as "1st," "2nd," "3rd," or "th."
#'
#' @param n Numeric vector to be converted.
#'
#' @return A character vector representing the verbose number representation.
#' @export
verbose_numbers <- function(n) {
  n[n < 1 | 3 < n] <- paste0(n[n < 1 | 3 < n], 'th')
  n[n == 1] <- '1st'
  n[n == 2] <- '2nd'
  n[n == 3] <- '3rd'
  n
}

#' Pluralize Suffix Based on Count
#'
#' This function returns an empty string for count 1 and 's' for any other count.
#'
#' @param counts Numeric vector of counts.
#'
#' @return
#' An empty string for count 1, 's' otherwise.
#' @export
plural_s <- function(counts) {
  ifelse(counts == 1, '', 's')
}

#' Complete Table with Missing Columns
#'
#' This function completes a table by adding missing columns based on the specified table description.
#'
#' @param table A data.table representing the table to be completed.
#' @param table_description A description of the expected table structure.
#'
#' @return A completed data.table with missing columns added.
#' @export
polar_complete_table <- function(table, table_description) {
  # Binding the variable .SD locally to the function, so the R CMD check has nothing to complain about
  .SD <- NULL
  col_names <- names(table_description@cols)
  empty_table <- data.table::setnames(
    data.table::data.table(matrix(ncol = length(col_names), nrow = 0)),
    new = col_names
  )
  d <- data.table::rbindlist(list(empty_table, table), fill = TRUE, use.names = TRUE)
  d[,lapply(.SD, function(x) methods::as(x, 'character'))]
}

#' Convert Data.Table to Character String
#'
#' This function converts a data.table to a formatted character string with optional header and footer.
#'
#' @param dt A data.table to be converted.
#' @param header Logical, indicating whether to include a header with column names.
#' @param footer Logical, indicating whether to include a footer with column names.
#' @return A formatted character string representation of the data.table.
#'
#' @details
#' The function converts a data.table to a character string, aligning columns and optionally including a header and footer.
#' It pads each column to the maximum width of its elements for better alignment.
#'
#' @export
data.table.as.character <- function(dt, header = FALSE, footer = FALSE) {
  # Binding the variable .SD locally to the function, so the R CMD check has nothing to complain about
  .SD <- NULL
  d <- if (header) rbind(as.list(names(dt)), dt) else dt
  if (footer) d <- rbind(d, as.list(names(dt)))
  l <- d[,lapply(.SD, function(x) max(nchar(x)))]
  d <- data.table::as.data.table(lapply(seq_along(d), function(i) stringr::str_pad(string = d[[i]], width = l[[i]], side = 'left', pad = ' ')))
  paste0(
    sapply(
      seq_len(nrow(d)),
      function(i) {
        paste0(d[i, ], collapse = '  ')
      }
    ),
    collapse = '\n'
  )
}

#' Create a Framed String
#'
#' This function creates a framed string with specified formatting parameters.
#'
#' @param text A character string to be framed.
#' @param pos The position of the framed text within the frame. It can be 'left', 'center', or 'right'.
#' @param edge The characters to be used for framing the top, bottom, left, and right edges.
#' @param hori The character to be used for horizontal framing.
#' @param vert The character to be used for vertical framing.
#' @return A character string representing the framed text.
#'
#' @details
#' The function creates a framed string by adding specified framing characters (edges, horizontal, and vertical) around the input text.
#' It allows customization of the frame's position, edge characters, and framing characters.
#' The resulting framed string is useful for creating visually appealing console outputs.
#'
#' @export
frame_string <- function(
    text = styled_string('\nHello !!!\n\n\nIs\nthere\n\nA N Y O N E\n\nout\nthere\n???\n '),
    pos  = c('left', 'center', 'right')[1],
    edge = ' ',
    hori = '-',
    vert = '|') {
  # own strpad function
  # strpad("Hello", 10, "right", "-")
  # "-----Hello"
  strpad <- function(string, width, pos = c('left', 'right'), pad) {
    # duplicate char count times
    n_chars <- function(char, count) paste0(rep_len(char, count), collapse = '')
    # remove utf codes from string and count characters
    w <- nchar(gsub('\033\\[[0-9;]*m', '', string))
    if (pos == 'left') {
      paste0(string, n_chars(pad, width - w))
    } else if (pos == 'right') {
      paste0(n_chars(pad, width - w), string)
    } else {
      paste0(n_chars(pad, (width - w) %/% 2), string, n_chars(pad, width - w - (width - w) %/% 2))
    }
  }
  # get all 4 edges strings
  edge <- rep_len(strsplit(edge, '')[[1]], 4)[1 : 4]
  r <- ''
  s <- strsplit(text, '\n')[[1]]
  # get height of frame
  h <- length(s)
  # get width of frame
  w <- max(sapply(s, function(x) nchar(gsub('\033\\[[0-9;]*m', '', x))))
  # build top and botton lines
  hbt <- paste0(edge[1], paste0(rep_len(hori, w + 2), collapse = ''), edge[2], '\n')
  hbb <- paste0(edge[3], paste0(rep_len(hori, w + 2), collapse = ''), edge[4], '\n')
  # construct frame with text in it
  r <- hbt
  for (s_ in s) {# s_ <- s
    r <- paste0(r, vert, ' ', strpad(string = s_, width = w, pos = pos, pad = ' '), ' ', vert, '\n')
  }
  r <- paste0(r, hbb)
  r
}

#' Print a Disclaimer Text
#'
#' This function prints a disclaimer text with detailed information about the project settings,
#' system details, hardware information, and request parameters.
#'
#' @return NULL
#'
#' @details
#' The disclaimer text includes information about the project name, time stamp, R version, system details,
#' hardware information, working directories, request parameters, and software versions.
#' It provides a comprehensive overview of the project configuration.
#'
#' @export
polar_disclaimer <- function() {
  vrbs <- function(v) {
    v <- min(max(0, v), 10)
    paste0('  PRINT\n',
           paste0('    ', sapply(0:10, function(i) {
             styled_string({
               s <- c(
                 '  0 nothing                       ',
                 '  1 only main info                ',
                 '  2 main scripts                  ',
                 '  3 sub scripts                   ',
                 '  4 sub scripts content           ',
                 '  5 result tables                 ',
                 '  6 all tables                    ',
                 '  7 download calls                ',
                 '  8 coi processing                ',
                 '  9 fhir response and cracks      ',
                 ' 10 everything                    '
               )[[i+1]]
               if (i == v) toupper(s) else s
             },
             bold   = i == v,
             italic = i != v,
             invert = i == v
             )
           }), collapse = '\n')
    )
  }
  mdctnrsrc <- function(v) {
    if (v == 50) v <- 3
    v <- min(max(0, v), 4)

    paste0('  PRINT\n',
           paste0('    ', sapply(0:4, function(i) {
             styled_string({
               s <- c(
                 '  0 medication administration and medication statement    ',
                 '  1 medication administration only                        ',
                 '  2 medication statement only                             ',
                 ' 50 default tp definition                             ',
                 ' 99 any medication statement or medication administration '
               )[[i+1]]
               if (i == v) toupper(s) else s
             },
             bold   = i == v,
             italic = i != v,
             invert = i == v
             )
           }), collapse = '\n')
    )
  }
  obsflt <- function(v) {
    v <- min(max(0, v), 1)

    paste0('  PRINT\n',
           paste0('    ', sapply(0:1, function(i) {
             styled_string({
               s <- c(
                 '  0 retrieve observations by patient-id    ',
                 '  1 retrieve observation by loinc-codes    '
               )[[i+1]]
               if (i == v) toupper(s) else s
             },
             bold   = i == v,
             italic = i != v,
             invert = i == v
             )
           }), collapse = '\n')
    )
  }

  encrsmrg <- function(v) {
    v <- min(max(0, v), 2)

    paste0('  PRINT\n',
           paste0('    ', sapply(0:2, function(i) {
             styled_string({
               s <- c(
                 '  0 merge encounter and resources via references or patient id/date ',
                 '  1 merge encounter and resources via references only               ',
                 '  2 merge encounter and resources via patient id/date only          '
               )[[i+1]]
               if (i == v) toupper(s) else s
             },
             bold   = i == v,
             italic = i != v,
             invert = i == v
             )
           }), collapse = '\n')
    )
  }
  encrspr <- function(v) {
    if (v == "full") {v <- 0}
    else if (v == "month") {v <- 1}
    else if (v == "year") {v <- 2}
    else {v <- 0}

    paste0('  PRINT\n',
           paste0('    ', sapply(0:2, function(i) {
             styled_string({
               s <- c(
                 '  full retrieve encounters for full period with one request                                     ',
                 '  month retrieve encounters for full period with multiple requests (range: 1 month per request) ',
                 '  year retrieve encounters for full period with multiple requests (range: 1 year per request)   '
               )[[i+1]]
               if (i == v) toupper(s) else s
             },
             bold   = i == v,
             italic = i != v,
             invert = i == v
             )
           }), collapse = '\n')
    )
  }

  frame_string(
    text = paste0(
      styled_string(PROJECT_NAME, PROJECT_TIME_STAMP, sep = '', fg = 4, underline = TRUE, bold = TRUE), '\n',
      frame_string(
        text = paste0(
          styled_string(' TIME                                                        ', fg = 7, bold = TRUE, underline = TRUE, invert = TRUE), '\n',
          styled_string('Project Time Stamp:  ', italic = TRUE), '\n',
          styled_string(gsub('^-', '', PROJECT_TIME_STAMP), bold = TRUE),
          '\n\n',
          styled_string(' SYSTEM                                                      ', fg = 7, bold = TRUE, underline = TRUE, invert = TRUE), '\n',
          paste0(
            sapply(
              names(R.version),
              function(x) {
                styled_string(paste0(x, ': ', R.version[[x]]), bold = TRUE)
              }
            ),
            collapse = '\n'
          ),
          '\n\n',
          styled_string(' HARDWARE                                                    ', fg = 7, bold = TRUE, underline = TRUE, invert = TRUE), '\n',
          styled_string('# of CPU Cores:      ', italic = TRUE),
          styled_string(as.character(get_ncores(get_os())), bold = TRUE), '\n',
          styled_string('Total RAM:           ', italic = TRUE),
          styled_string(as.character(memuse::Sys.meminfo()$totalram), bold = TRUE),
          '\n',
          styled_string('Free  RAM:           ', italic = TRUE),
          styled_string(as.character(memuse::Sys.meminfo()$freeram), bold = TRUE),
          '\n\n',
          styled_string(' SETTINGS                                                    ', fg = 7, bold = TRUE, underline = TRUE, invert = TRUE), '\n\n  ',
          styled_string(' WORKING DIRECTORIES                                     ', fg = 7, invert = TRUE), '\n  ',
          styled_string('private:             ', italic = TRUE),
          styled_string('outputLocal/', PROJECT_NAME, PROJECT_TIME_STAMP, sep = '', fg = 7, bold = TRUE), '\n  ',
          styled_string('public:              ', italic = TRUE),
          styled_string('outputGlobal/', PROJECT_NAME, PROJECT_TIME_STAMP, sep = '', fg = 7, bold = TRUE),
          '\n\n  ',
          styled_string(' REQUEST PARAMETERS                                      ', fg = 7, invert = TRUE), '\n  ',
          styled_string('MAX_ENCOUNTER_BUNDLES:         ', italic = TRUE), styled_string(MAX_ENCOUNTER_BUNDLES, bold = TRUE), '\n  ',
          styled_string('COUNT_PER_BUNDLE:               ', italic = TRUE),
          styled_string(if (is.na(COUNT_PER_BUNDLE)) 'Server Default' else COUNT_PER_BUNDLE, bold = TRUE), '\n  ',
          styled_string('BUNDLES_AT_ONCE:     ', italic = TRUE), styled_string(BUNDLES_AT_ONCE, bold = TRUE), '\n  ',
          styled_string('IDS_AT_ONCE:         ', italic = TRUE), styled_string(IDS_AT_ONCE, bold = TRUE), '\n  ',
          '\n\n  ',
          styled_string(' VERBOSE LEVEL                                           ', fg = 7, invert = TRUE), '\n',
          vrbs(VERBOSE), '\n\n',
          # styled_string(' MEDICATION RESOURCE                                     ', fg = 7, invert = TRUE), '\n',
          # mdctnrsrc(MEDICATION_RESOURCE), '\n\n',
          # styled_string(' OBS_BY_FILTER                                           ', fg = 7, invert = TRUE), '\n',
          # obsflt(OBS_BY_FILTER), '\n\n',
          # styled_string(' ENC_RES_MERGE                                           ', fg = 7, invert = TRUE), '\n',
          # encrsmrg(ENC_RES_MERGE), '\n\n',
          # styled_string(' ENC_REQ_PER                                ', fg = 7, invert = TRUE), '\n',
          # encrspr(ENC_REQ_PER), '\n\n',
          # styled_string(' ENC_REQ_TYPE                                            ', fg = 7, invert = TRUE), '\n',
          # ENC_REQ_TYPE, '\n\n',
          styled_string(' ENCOUNTER_IDENTIFIER_PATH                               ', fg = 7, invert = TRUE), '\n',
          ENCOUNTER_IDENTIFIER_PATH, '\n\n',
          styled_string(' ENCOUNTER_IDENTIFIER_VALUE_PATTERN                      ', fg = 7, invert = TRUE), '\n',
          ENCOUNTER_IDENTIFIER_VALUE_PATTERN, '\n\n',
          # styled_string(' SOFTWARE                                                ', fg = 7, bold = TRUE, underline = TRUE, invert = TRUE), '\n',
          # data.table.as.character(VERSIONS, TRUE), '\n'
        ),
        edge = '++++', hori = ' ', vert = ' '
      ),
      styled_string(PROJECT_NAME, PROJECT_TIME_STAMP, sep = '', fg = 4, underline = TRUE, bold = TRUE)
    ),
    pos = 'center', edge = ' ', hori = ' ', vert = ' '
  )
}
