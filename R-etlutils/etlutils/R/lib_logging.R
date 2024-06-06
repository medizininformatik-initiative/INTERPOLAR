# Environment for saving the connections
.lib_logging_env <- new.env()

#' Start Logging to a File
#'
#' This function initializes logging by creating or opening a log file for writing.
#'
#' @param prefix A prefix to be used in the log file name.
#' @return NULL
#'
#' @details
#' The function creates or opens a log file with a name generated from the provided prefix and the current timestamp.
#' It redirects the console output and messages to the log file, allowing for systematic logging of activities.
#' The log file is stored in the log directory, and each log entry is appended to the existing file.
#'
#' @export
startLogging <- function(prefix) {
  log_filename <- fhircrackr::paste_paths(returnPathToLogDir(), paste0(prefix, "-log.txt"))
  # Make sure that the environment does not have an open connection to this file
  if (!is.null(.lib_logging_env[[log_filename]])) {
    warning("A log file is already open for '", log_filename, "'")
    return(invisible(NULL))
  }

  # Open logfile data connection
  log_file <- file(log_filename, open = "wt")
  sink(log_file, append = TRUE, split = TRUE)
  sink(log_file, append = TRUE, type = "message")
  .lib_logging_env[[log_filename]] <- log_file
  .lib_logging_env[["log_filename"]] <- log_filename
  invisible(log_file)
}

#' End Logging
#'
#' This function finalizes the logging process by closing the log file.
#'
#' @return NULL
#'
#' @details
#' The function stops the redirection of console output and messages to the log file initiated by \code{startLogging}.
#' It closes the log file, ensuring that no further entries are appended to it.
#'
#' @export
endLogging <- function() {
  sink(type = "message")
  sink()

  log_filename <- .lib_logging_env[["log_filename"]]
  log_file <- .lib_logging_env[[log_filename]]
  if (!is.null(log_file)) {
    close(log_file)
    .lib_logging_env[[log_filename]] <- NULL
    .lib_logging_env[["log_filename"]] <- NULL
  }
  removeAnsiEscapeSequences(log_filename)
}

#' Logs a Header for the Whole Process
#'
#' @description Log Header of Block
#'
#' @param verbose An integer of length 1, the verbose level. If verb is 0, no output will be produced.
#' @param len An integer of for the length of the underline.
#'
#' @export
logBlockHeader <- function(verbose = VERBOSE, len = 104) {
  # if verb greater than zero, print a underlined line of len spaces followed by the word START
  if (!verbose) {
    cat(paste0(
      # print a bold underlined line of len spaces
      formatStringStyle(paste0(rep(" ", len), collapse = ""), fg = 7, bold = TRUE, underline = TRUE), "\n",
      formatStringStyle("START", fg = 7, bold = TRUE), "\n"
    ))
  }
}

#' Logs a Footer for the Whole Process
#'
#' @param verbose An integer of length 1, the verbose level. If verb is 0, no output will be produced.
#' @param len An integer for the length of the underline.
#'
#' @export
logBlockFooter <- function(verbose = VERBOSE, len = 104) {
  # if verb greater than zero, print a underlined line of len spaces followed by the word START
  if (!verbose) {
    cat(paste0(
      # print bold underlined word END
      formatStringStyle("END", fg = 7, bold = TRUE, underline = TRUE),
      # fill up to length len with bold unerlined spaces
      formatStringStyle(paste0(rep(" ", len - 3), collapse = ""), fg = 7, bold = TRUE, underline = TRUE),"\n"
    ))
  }
}

#' Start a Process with Error Handling
#'
#' This function initiates a process using the specified function and includes error handling.
#'
#' @param process The function representing the process to be executed.
#' @return None (prints clock information and handles errors)
#'
#' @seealso logBlockHeader, printClock, logBlockFooter, stopOnError
#'
#' @export
runProcess <- function(process) {
  logBlockHeader()
  err <- try(process, silent = TRUE)
  printClock()
  warnings()
  logBlockFooter()
  stopOnError(err)
}

#' Finalzes the global process
#'
#' @export
finalize <- function() {
  printClock()
  warnings()
  savePerformance()
  logBlockFooter()
  ###
  # Save all console logs
  ###
  endLogging()
}

#' Stop execution with Error message
#'
#' This function stops execution and prints the concatenated error message.
#'
#' @param ... Character vectors to be concatenated and printed as an error message.
#'
#' @export
stopWithError <- function(...) {
  # do not change the paste(c(...), collapse = "") to paste0 !!! The result is not the same!
  err <- try(stop(catColorRed(paste(c(...), collapse = ""))), silent = TRUE)
  stopOnError(err)
}

#' Stop on Error
#'
#' This function checks if the provided argument is an error. If it is, the
#' function stops the execution.
#'
#' @param potential_error The object to check for being an error.
#'
#' @seealso stop
#' @export
stopOnError <- function(potential_error) {
  if (isError(potential_error)) {
    finalize()
    stop()
  }
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
runProcessInternal <- function(
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

  err <- getClock()$measure_process_time(
    message = message,
    process = process
  )
  if (!single_line && 0 < VERBOSE) cat(paste0(message, ': ' ))
  if (0 < VERBOSE) {
    checkError(
      err = err,
      expr_ok = {
        if (single_line) catOkMessage() else catColourised('OK\n', fg = 'light blue')
        err
      },
      expr_err = {
        catErrorMessage()
        if (throw_exception) {
          stop(err)
        }
      }
    )
  }
}

#' Execute an outer script with a specified message and process
#'
#' This function runs an outer script with the provided message and process, controlling
#' the verbosity level.
#'
#' @param message A character string describing the purpose of the outer script.
#' @param process A function representing the outer script to be executed.
#'
#' @export
runLevel1 <- function(message, process) {
  run(
    message = message,
    process = process,
    verbose = VL_20_OUTER_SCRIPTS
  )}

#' Execute an inner script with a specified message and process
#'
#' This function runs an inner script with the provided message and process, controlling
#' the verbosity level.
#'
#' @param message A character string describing the purpose of the inner script.
#' @param process A function representing the inner script to be executed.
#'
#' @export
runLevel2 <- function(message, process) {
  run(
    message = message,
    process = process,
    verbose = VL_30_INNER_SCRIPTS
  )}

#' Execute an inner script info with a specified message and process
#'
#' This function runs an inner script info with the provided message and process, controlling
#' the verbosity level.
#'
#' @param message A character string describing the purpose of the inner script info.
#' @param process A function representing the inner script info to be executed.
#'
#' @export
runLevel3 <- function(message, process) {
  run(
    message = message,
    process = process,
    verbose = VL_40_INNER_SCRIPTS_INFOS
  )}

#' Execute an inner script info with a specified message and process
#'
#' This function runs an inner script info with the provided message and process, controlling
#' the verbosity level. If an error occurs, it is ignored.
#'
#' @param message A character string describing the purpose of the inner script info.
#' @param process A function representing the inner script info to be executed.
#'
#' @export
runLevel3IgnoreError <- function(message, process) {
  run(
    message = message,
    process = process,
    verbose = VL_40_INNER_SCRIPTS_INFOS,
    throw_exception = FALSE
  )}

#' Execute a script with specified message, process, and verbosity level
#'
#' This function runs a script with the provided message and process, controlling
#' the verbosity level.
#'
#' @param message A character string describing the purpose of the script.
#' @param process A function representing the script to be executed.
#' @param verbose An integer specifying the verbosity level.
#' @param throw_exception if TRUE the execution of the current expression will be stopped
#'
#' @export
run <- function(message, process, verbose, throw_exception = TRUE) {
  runProcessInternal(
    message = message,
    process = process,
    verbose = VERBOSE - verbose + 1,
    single_line = VERBOSE <= verbose,
    throw_exception = throw_exception
  )}

#' Execute an outer script with specified message and process (single line)
#'
#' This function runs an outer script with the provided message and process, controlling
#' the verbosity level. Unlike `runs`, this function always displays output in a
#' single line, regardless of the global verbosity setting.
#'
#' @param message A character string describing the purpose of the outer script.
#' @param process A function representing the outer script to be executed.
#'
#' @export
runLevel1Line <- function(message, process) {
  runs(
    message = message,
    process = process,
    verbose = VL_20_OUTER_SCRIPTS
  )}

#' Execute an inner script with specified message and process (single line)
#'
#' This function runs an inner script with the provided message and process, controlling
#' the verbosity level. Unlike `runs`, this function always displays output in a
#' single line, regardless of the global verbosity setting.
#'
#' @param message A character string describing the purpose of the inner script.
#' @param process A function representing the inner script to be executed.
#'
#' @export
runLevel2Line <- function(message, process) {
  runs(
    message = message,
    process = process,
    verbose = VL_30_INNER_SCRIPTS
  )}

#' Execute an inner script info with specified message and process (single line)
#'
#' This function runs an inner script info with the provided message and process, controlling
#' the verbosity level. Unlike `runs`, this function always displays output in a
#' single line, regardless of the global verbosity setting.
#'
#' @param message A character string describing the purpose of the inner script info.
#' @param process A function representing the inner script info to be executed.
#'
#' @export
runLevel3Line <- function(message, process) {
  runs(
    message = message,
    process = process,
    verbose = VL_40_INNER_SCRIPTS_INFOS
  )}

#' Execute a script with specified message, process, and verbosity level (single line)
#'
#' This function runs a script with the provided message and process, controlling
#' the verbosity level. Unlike `run`, this function always displays output in a
#' single line, regardless of the global verbosity setting.
#'
#' @param message A character string describing the purpose of the script.
#' @param process A function representing the script to be executed.
#' @param verbose An integer specifying the verbosity level.
#'
#' @export
runs <- function(message, process, verbose) {
  runProcessInternal(
    message = message,
    process = process,
    verbose = VERBOSE - verbose + 1,
    single_line = TRUE
  )}

#' Remove ANSI Escape Sequences from a Log File
#'
#' This function reads a file, removes all ANSI escape sequences used for text formatting in
#' terminal outputs, and writes the cleaned text back to the same file. This can be useful for
#' cleaning up log files generated from console outputs.
#'
#' @param filename A string specifying the path to the log file from which ANSI escape sequences
#'        will be removed.
#'
#' @return This function does not return a value but writes directly to the file, overwriting the
#'         content with the cleaned text.
#'
#' @export
removeAnsiEscapeSequences <- function(filename) {
  # Now remove ANSI escape sequences:
  file <- file(filename, open = "rt")
  # Read the content of the log file
  content <- readLines(file, warn = FALSE)
  close(file)
  # append all single line strings to one large string
  content <- paste0(content, collapse = '\n')
  # Function to remove ANSI escape sequences from a text
  remove_ansi <- function(text) {
    gsub("\033\\[[0-9;]*m", "", text, perl = TRUE)
  }
  # Remove ANSI escape sequences from the content of the log file
  content <- lapply(content, remove_ansi)[[1]]
  # Write the cleaned content back to the log file, overwriting it
  file <- file(filename, open = "wt")
  writeLines(content, file, useBytes = TRUE)
  close(file)
}

#' Conditional Print to Console (for tables) based on verbosity level
#'
#' This function prints the provided content to the console only if the global
#' verbosity level is equal to or greater than `VL_50_TABLES`.
#'
#' @param ... Objects to be printed to the console.
#'
#' @export
catByVerbose <- function(...) {
  if (VL_50_TABLES <= VERBOSE) {
    cat(..., '\n')
  }
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
createFrameString <- function(
    text = formatStringStyle('\nHello !!!\n\n\nIs\nthere\n\nA N Y O N E\n\nout\nthere\n???\n '),
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

#' Print a table if VERBOSE level allows.
#'
#' This function prints a summary for the specified table if the VERBOSE level is
#' greater than or equal to VL_50_TABLES (= 5). It uses the `printTable_summary` function
#' for generating the summary.
#'
#' @param table The input table to print. For example, you can use the mtcars dataset.
#' @param table_name A table name to display in the output. If NA the variable name will be displayed.
#'
#' @details
#' This function checks the VERBOSE level (assumed to be a global variable) and
#' prints a summary for the specified table only if the VERBOSE level is greater than
#' or equal to VL_50_TABLES. The table_name is obtained from the calling function's name.
#'
#' @seealso
#' \code{\link{printTable_summary}}
#'
#' @export
#'
#' @examples
#' # Load required packages
#' library(datasets)
#' library(data.table)
#'
#' #' # Load the mtcars dataset and convert it to a data.table
#' data(mtcars)
#' setDT(mtcars)
#'
#' # Set VL_50_TABLES and VERBOSE to appropriate values
#' VL_50_TABLES <- 5
#' VERBOSE <- 7
#'
#' # Assuming VERBOSE and VL_50_TABLES are defined
#' printTable(mtcars)
#'
#' # Assuming VERBOSE and VL_60_ALL_TABLES are defined
#' printTable(mtcars, 'This is a table full of cars')
#'
printTable <- function(table, table_name = NA) {
  if (VERBOSE >= VL_50_TABLES) {
    if (is.na(table_name)) {
      table_name <- as.character(sys.call()[2]) # get parameter names
    }
    printTable_summary(table, table_name)
  }
}

#' Print a table if VERBOSE level allows.
#'
#' This function prints a summary for the specified table if the VERBOSE level is
#' greater than or equal to VL_60_ALL_TABLES (= 6). It uses the `printTable_summary` function
#' for generating the summary.
#'
#' @param table The input table to print. For example, you can use the mtcars dataset.
#' @param table_name A table name to display in the output. If NA the variable name will be displayed.
#'
#' @details
#' This function checks the VERBOSE level (assumed to be a global variable) and
#' prints a summary for the specified table only if the VERBOSE level is greater than
#' or equal to VL_60_ALL_TABLES The table_name is obtained from the calling function's name.
#'
#' @seealso
#' \code{\link{printTable_summary}}
#'
#' @export
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
#' # Set VL_60_ALL_TABLES and VERBOSE to appropriate values
#' VL_60_ALL_TABLES <- 6
#' VERBOSE <- 7
#'
#' # Assuming VERBOSE and VL_60_ALL_TABLES are defined
#' printAllTables(mtcars)
#'
#' # Assuming VERBOSE and VL_60_ALL_TABLES are defined
#' printAllTables(mtcars, 'This is a table full of cars')
#'
printAllTables <- function(table, table_name = NA) {
  if (VERBOSE >= VL_60_ALL_TABLES) {
    if (is.na(table_name)) {
      table_name <- as.character(sys.call()[2]) # get parameter names
    }
    printTable_summary(table, table_name)
  }
}
