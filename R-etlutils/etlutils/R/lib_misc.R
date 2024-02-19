#' START__
#' @description Print Header of Block
#'
#' @param verbose An integer of length 1, the verbose level. If verb is 0, no output will be produced.
#' @param len An integer of length 1, the length of the underline.
#'
#' @return NULL
#'
#' @export
START__ <- function(verbose = VERBOSE - 4, len = 104) {

  # if verb greater than zero, print a underlined line of len spaces followed by the word START
  if (0 < verbose) {
    cat(paste0(
      # print a bold underlined line of len spaces
      styled_string(paste0(rep(' ', len), collapse = ''), fg = 7, bold = TRUE, underline = TRUE),
      '\n',
      styled_string('START', fg = 7, bold = TRUE),
      '\n'
    ))
  }
}

#' Print Footer of a Block
#'
#' @param verbose An integer of length 1, the verbose level. If verb is 0, no output will be produced.
#' @param len An integer of length 1, the length of the underline.
#'
#' @return NULL
#'
#' @export
END__ <- function(verbose = VERBOSE - 4, len = 104) {

  # if verb greater than zero, print a underlined line of len spaces followed by the word START
  if (0 < verbose) {
    cat(paste0(
      # print bold underlined word END
      styled_string('END', fg = 7, bold = TRUE, underline = TRUE),
      # fill up to length len with bold unerlined spaces
      styled_string(paste0(rep(' ', len - 3), collapse = ''), fg = 7, bold = TRUE, underline = TRUE),
      '\n'
    ))
  }
}

#' Print Footer for a Block followed by a Header for the next Block
#'
#' @param verbose An integer of length 1, the verbose level. If verb is 0, no output will be produced.
#' @param len An integer of length 1, the length of the underline.
#'
#' @return NULL
#'
#' @export
END__START__ <- function(verbose = VERBOSE - 4, len = 104) {
  if (0 < verbose) {
    END__(len)
    cat('\n\n') # two empty lines between END and next START
    START__(len)
  }
}

#'
#' Runs the given function surrounded with [START__()] and [END__()].
#'
#' @param process a function
#' @param verbose An integer of length 1, the verbose level. If verb is 0, no output will be produced.
#' @param len An integer of length 1, the length of the underline.
#'
#' @return NULL
#'
#' @export
log_run <- function(process, verbose = VERBOSE - 4, len = 104) {
  START__(verbose, len)
  process()
  END__(verbose, len)
}

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
  d[, lapply(.SD, function(x) methods::as(x, 'character'))]
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

#' Print a summary for a table
#'
#' This function prints a summary for the specified table, including information
#' about the class, type, number of available values, and number of missing values
#' for each column. The summary is displayed in a formatted table.
#'
#' @param table The input table to summarize. For example, you can use the mtcars dataset.
#' @param table_name An optional name for the table, used in the summary output.
#' @return This function does not explicitly return a value. It prints the summary to the console.
#'
#' @examples
#' # Load required packages
#' library(datasets)
#' library(data.table)
#'
#' # Load the mtcars dataset and convert it to a data.table
#' data(mtcars)
#' setDT(mtcars)
#'
#' # Print summary for the mtcars table
#' print_table_summary(table = mtcars, table_name = 'mtcars')
#'
#' @export
print_table_summary <- function(table=table_enc, table_name = '') {
  dt <- data.table::as.data.table(
    cbind(
      class      = sapply(names(table), function(n) class(table[[n]])[1]), #shows only the first specified class
      type       = sapply(names(table), function(n) typeof(table[[n]])),
      available  = sapply(names(table), function(n) sum(!is.na(table[[n]]))),
      missing    = sapply(names(table), function(n) sum( is.na(table[[n]])))
    ),
    keep.rownames = TRUE
  )
  if (0 < nrow(dt)) {
    cat(
      frame_string(
        text = paste0(
          'Table: ', table_name, '\n\n  # Rows:    ', nrow(table), '\n  # Columns: ', ncol(table), '\n\n',
          data.table.as.character(
            data.table::setnames(
              x = dt,
              new = c('Column', 'Class', 'Type', 'Available', 'Missing')
            ),
            header = TRUE,
            footer = TRUE
          )
        ),
        edge = c('\u231c\u231d\u231e\u231f'),
        hori = ' ',
        vert = ' '
      )
    )
  } else {
    cat(
      frame_string(
        text = paste0(
          'Table: ', table_name, '\n\n  # Rows:    ', nrow(table), '\n  # Columns: ', ncol(table), '\n\n'
        ),
        edge = c('\u231c\u231d\u231e\u231f'),
        hori = ' ',
        vert = ' '
      )
    )
  }
}

#' Convert a polar time representation to POSIXct format
#'
#' This function takes a time column in a polar format, extracts the time part,
#' and converts it to POSIXct format with a default date of "2020-01-01". The input
#' time_column is expected to be in a format containing hours, minutes, and seconds.
#' NA and an empty string will return NA.
#'
#' @param time_column A column containing time information in a polar format.
#' @return A character vector representing the time in POSIXct format ("%H:%M:%S").
#'
#' @examples
#' # Test case 1: Valid time representation
#' time_column_valid <- c("12:30:45", "08:15:00", "23:59:59")
#' result_valid <- polar_as_time(time_column_valid)
#' cat("Result for valid time representations:\n", result_valid, "\n\n")
#'
#' # Test case 2: NA input, should return NA
#' time_column_na <- c(NA, NA, NA)
#' result_na <- polar_as_time(time_column_na)
#' cat("Result for NA input:\n", result_na, "\n\n")
#'
#' # Test case 3: Empty string input, should throw an error
#' time_column_empty <- c("", "", "")
#' tryCatch(
#'   {
#'     result_empty <- polar_as_time(time_column_empty)
#'     cat("Result for empty string input:\n", result_empty, "\n\n")
#'   },
#'   error = function(e) cat("Error for empty string input:\n", e$message, "\n\n")
#' )
#'
#' @export
polar_as_time <- function(time_column) {
  dc <- time_column
  dc <- ifelse(nzchar(dc), dc, NA) # empty string is the same as NA
  if (!all(is.na(dc))) {
    pat <- '^.*?([0-9]+:[0-9]+:[0-9]+).*?$'
    # Remove date or return midnight
    dc <- ifelse (grepl(pat, dc), gsub(pat, "\\1", as.character(dc)), "00:00:00")
    # Any day will work
    dc <- paste("2020-01-01", dc)
  }
  # as.POSIXct returns NA, if it is not a valid date
  format(as.POSIXct(dc, optional = TRUE), "%H:%M:%S")
}

#' Get a regular expression pattern for matching YYYY format
#'
#' This function returns a regular expression pattern for matching the YYYY format
#' (four-digit year). It can be used for validating and extracting year information
#' from strings.
#'
#' @return A character vector representing the regular expression pattern for YYYY format.
#'
#' @examples
#' get_pattern_YYYY()
#'
#' @export
#'
get_pattern_YYYY <- function() '^[0-9]{4}$'

#' Get a regular expression pattern for matching YYYY-MM format
#'
#' This function returns a regular expression pattern for matching the YYYY-MM format
#' (four-digit year followed by a hyphen and two-digit month). It can be used for
#' validating and extracting year and month information from strings.
#'
#' @return A character vector representing the regular expression pattern for YYYY-MM format.
#'
#' @examples
#' get_pattern_YYYY_MM()
#'
#' @export
#'
get_pattern_YYYY_MM <- function() '^[0-9]{4}-[0-9]{2}$'


#' Convert a date representation to Date format
#'
#' This function takes a date column in a polar format, cleans and standardizes
#' the format, and converts it to Date format. The input date_column is expected
#' to be in a format containing year, month, and day information. The function
#' supports patterns for YYYY and YYYY-MM. It utilizes the functions
#' \code{\link{get_pattern_YYYY}} and \code{\link{get_pattern_YYYY_MM}} for obtaining
#' regular expression patterns.
#'
#' @param date_column A column containing date information in a polar format.
#' @return A Date vector representing the converted date information.
#'
#' @examples
#' library(lubridate)
#'
#' # Test case 1: YYYY format
#' date_column_YYYY <- c("2022", "1990", "1980")
#' result_YYYY <- polar_as_date(date_column_YYYY)
#'
#' # Test case 2: YYYY-MM format
#' date_column_YYYY_MM <- c("2022-12", "1990-05", "1980-11")
#' result_YYYY_MM <- polar_as_date(date_column_YYYY_MM)
#'
#' # Test case 3: Date with time, should be cleaned
#' date_column_with_time <- c("2022-12-01T15:30:00", "1990-05-01T08:45:00")
#' result_with_time <- polar_as_date(date_column_with_time)
#'
#' # Test case 4: Date with '/' separator, should be replaced with '-'
#' date_column_slash_separator <- c("2022/12/01", "1990/05/01")
#' result_slash_separator <- polar_as_date(date_column_slash_separator)
#'
#' @seealso
#' \code{\link{get_pattern_YYYY}}, \code{\link{get_pattern_YYYY_MM}}
#'
#' @export
#'
polar_as_date <- function(date_column) {

  dc <- as.character(date_column)
  dc <- gsub('T.+$', '', dc)
  dc <- gsub('/', '-', dc)

  incomplete_date_pattern <- get_pattern_YYYY()
  years <- grepl(incomplete_date_pattern, dc)
  dc[years] <- paste0(dc[years], '-01-01')

  incomplete_date_pattern <- get_pattern_YYYY_MM()
  years <- grepl(incomplete_date_pattern, dc)
  dc[years] <- paste0(dc[years], '-01')

  lubridate::as_date(dc)
}

#'
#' Fix uncommon date formats
#'
#' This function takes a data.table (`dt`), a set of date columns (`date_columns`),
#' and an optional parameter (`preserve_time`) to fix uncommon date formats.
#' It performs the following tasks:
#'
#' - If `preserve_time` is TRUE, it extracts the time part from each date column
#'   and saves it into respective TimeSpec columns by appending ".TimeSpec" to the
#'   original date column names.
#'
#' - It then converts the original date columns to Date format using the
#'   `polar_as_date` function.
#'
#' @param dt A data.table containing the data to be processed.
#' @param date_columns A character vector specifying the names of the date columns to be fixed.
#' @param preserve_time A logical value indicating whether to preserve time information. Default is TRUE.
#' @return The modified data.table with fixed date formats.
#'
#' @examples
#' # Create an example data.table
#' dt <- data.table::data.table(
#'   date1 = c("2022", "1990-05", "1980-11"),
#'   date2 = c("2022-12", "1990-05", "1980-11"),
#'   value = c(1, 2, 3)
#' )
#'
#' # Fix uncommon date formats with time preservation
#' polar_fix_dates(dt, c("date1", "date2"), preserve_time = TRUE)
#'
#' # The resulting data.table will have additional columns date1_timespec and date2_timespec
#' # containing the extracted time information, and the original date columns date1 and date2
#' # will be converted to Date format.
#' dt
#'
#' # Expected output:
#' #    date1      date2 value date1_timespec date2_timespec
#' # 1: 2022-01-01 2022-12-01     1       00:00:00       00:00:00
#' # 2: 1990-05-01 1990-05-01     2       00:00:00       00:00:00
#' # 3: 1980-11-01 1980-11-01     3       00:00:00       00:00:00
#'
#' @seealso
#' \code{\link{polar_as_time}}, \code{\link{polar_as_date}}
#'
#' @export
#'
polar_fix_dates <- function(dt, date_columns, preserve_time = TRUE) {

  #preserve time information
  if (preserve_time) {

    time_columns <- paste0(date_columns, "_timespec") #add suffix HourMinutesSeconds

    #col by col
    for (dc in date_columns) {

      tc <- paste0(dc, "_timespec")
      if (0 < nrow(dt)) {

        #extract time from any datetime column and save it into the respecive TimeSpec column
        dt[, (tc) := sapply(dt[[dc]], polar_as_time)]
      } else {
        #avoid columns of type list, which will be generated from empty resource
        dt[, (tc) := character()]
      }
    }
  }
  dt[, (date_columns) := lapply(.SD, polar_as_date), .SDcols = date_columns]
}

