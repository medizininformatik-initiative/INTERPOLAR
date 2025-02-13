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
  # Remove all sinks
  while (sink.number() > 0) {
    sink()
  }

  log_filename <- .lib_logging_env[["log_filename"]]
  log_file <- .lib_logging_env[[log_filename]]
  if (!is.null(log_file)) {
    close(log_file)
    .lib_logging_env[[log_filename]] <- NULL
    .lib_logging_env[["log_filename"]] <- NULL
  }
  closeAllConnections()

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
  if (verbose) {
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
  if (verbose) {
    cat(paste0(
      # print bold underlined word END
      formatStringStyle("END", fg = 7, bold = TRUE, underline = TRUE),
      # fill up to length len with bold unerlined spaces
      formatStringStyle(paste0(rep(" ", len - 3), collapse = ""), fg = 7, bold = TRUE, underline = TRUE),"\n"
    ))
  }
}

#' Finalizes the global process
#'
#' This function performs several tasks to finalize the global process.
#' It prints the processes runtimes, shows warnings, saves performance metrics, logs a footer
#' message, optionally prints a final log message, and saves all console logs.
#'
#' @param lastLogMessage A character string containing the final log message to be printed. Defaults to NA.
#' @export
finalize <- function(lastLogMessage = NA) {
  printClock()
  warnings()
  savePerformance()
  if (!isSimpleNA(lastLogMessage)) {
    cat(lastLogMessage)
  }
  ###
  # Save all console logs
  ###
  endLogging()
}

#' Check if an error has occurred
#'
#' This function checks if an error message exists in the logging environment.
#'
#' @return Logical value indicating whether an error message exists.
#'
#' @export
isErrorOccured <- function() {
  exists("ERROR_MESSAGE", envir = .lib_logging_env)
}

#' Check if the Error Message Indicates an Intentional Debug Test Error
#'
#' This function checks whether the provided error message, or the error message retrieved
#' by `getErrorMessage()` if none is provided, contains the string "DEBUG_TEST_". This indicates
#' that the error is an intentional debug test error.
#'
#' @param err An optional character string representing the error message to check. If not
#' provided, the function retrieves the error message using `getErrorMessage()`.
#'
#' @return A logical value: \code{TRUE} if the error message contains "DEBUG_TEST_";
#' \code{FALSE} otherwise.
#'
#' @export
isDebugTestError <- function(err = NA) {
  if (all(is.na(err))) {
    err <- getErrorMessage()
  }
  grepl("DEBUG_ENCOUNTER_REQUEST_TEST", err)
}

#' Check for Debug Test Error
#'
#' This function checks if a specified debug test variable is defined and set to \code{TRUE}.
#' If so, it raises an error with the provided debug message and the variable name.
#'
#' @param debug_test_variable_name A character string representing the name of the debug
#' test variable to check.
#' @param debug_message A character string representing the debug message to include in the
#' error output if the condition is met.
#'
#' @return None. The function stops execution and throws an error if the debug test variable
#' is defined and set to \code{TRUE}.
#'
#' @export
checkDebugTestError <- function(debug_test_variable_name, debug_message) {
  if (etlutils::isDefinedAndTrue(debug_test_variable_name)) {
    stop(paste0(debug_test_variable_name, ":\n", debug_message, "\n"))
  }
}

#' Print the error message if an error has occurred
#'
#' This function prints the error message stored in the logging environment if an error has occurred.
#'
#' @export
catErrorOccured <- function() {
  if (isErrorOccured()) {
    catErrorMessage(get("ERROR_MESSAGE", envir = .lib_logging_env))
  }
}

#' Retrieve the error message if an error has occurred
#'
#' This function checks if an error message exists in the logging environment and returns it.
#' If no error message exists, an empty string is returned.
#'
#' @return A character string containing the error message if an error has occurred, otherwise an
#' empty string.
#'
#' @export
getErrorMessage <- function() {
  if (isErrorOccured()) {
    return(get("ERROR_MESSAGE", envir = .lib_logging_env))
  }
  return("")
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
  # This function is called recursively when the functions runLevel1(), runLevel2() and runLevel3()
  # are nested within each other. If an inner function generates an error, no further runLevelX()
  # function is executed afterwards. The same error that the inner function had is always set for
  # the outer function of the inner function.
  if (!isErrorOccured()) {
    logBlockHeader()
    if (VERBOSE) {
      st <- Sys.time()
      cat("[TIME]", round(as.numeric(st), 0), format(st), "\n")

      cat(paste0(message, ':', if (single_line) ' ' else paste0(colourise(text = ' RUNNING ...', fg = 'blue'), '\n')))
    }
    # This is the return value of the transferred process. This can be an error or a regular process
    # result.
    process_result <- getClock()$measure_process_time(
      message = message,
      process = process
    )
    if (!single_line && VERBOSE) cat(paste0(message, ': ' ))

    # Check whether the process result is an error or a regular (non-error) result
    checkError(
      potencial_error = process_result,
      expr_ok = {
        if (single_line) catOkMessage() else catColourised('OK\n', fg = 'light blue')
        logBlockFooter()
        return(process_result)
      },
      expr_err = {
        if (!isDebugTestError(process_result)) {
          error_message <- catErrorMessage(process_result)
        } else if (single_line) catOkMessage() else catColourised('OK\n', fg = 'light blue')
        error_message <- process_result
        logBlockFooter()
        if (throw_exception) {
          # This process was the very first to generate an error
          if (!exists("ERROR_MESSAGE", envir = .lib_logging_env)) {
            # write this error to .lib_logging_env
            .lib_logging_env[["ERROR_MESSAGE"]] <- error_message
          } else {
            # A sub-process of this process had already generated an error ->
            # Replace the error of the current superprocess with the original error of the
            # subprocess (otherwise the error messages will be a bit confusing)
            error_message <- .lib_logging_env[["ERROR_MESSAGE"]]
          }
          stop(error_message)
        }
        return(error_message)
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
#' greater than or equal to VL_50_TABLES (= 5). It uses the `printTableSummary` function
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
#' \code{\link{printTableSummary}}
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
    printTableSummary(table, table_name)
  }
}

#' Print a table if VERBOSE level allows.
#'
#' This function prints a summary for the specified table if the VERBOSE level is
#' greater than or equal to VL_60_ALL_TABLES (= 6). It uses the `printTableSummary` function
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
#' \code{\link{printTableSummary}}
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
    printTableSummary(table, table_name)
  }
}

#' Append a Warning if DEBUG_ Variables are Active
#'
#' This function checks for global variables starting with "DEBUG_" and appends
#' a warning message to the given `finish_message` if any are found.
#'
#' @param finish_message A character string representing the current finish message.
#' @return A modified finish message including a warning if DEBUG_ variables are active.
#'
#' @export
appendDebugWarning <- function(finish_message) {
  # Check if any DEBUG_ variables exist
  debug_variables <- getGlobalVariablesByPrefix("DEBUG_", astype = "vector")

  # If there are active DEBUG variables, append a warning message
  if (length(debug_variables) > 0) {
    debug_variable_string <- paste(names(debug_variables), collapse = ", ")
    finish_message <- paste0(
      finish_message,
      "\nAdditional Warning: The following DEBUG parameters are activated: ", debug_variable_string,
      "\nThese parameters are only accepted for test cases!"
    )
  }

  return(finish_message)
}

#' Generate a Finish Message for a Module
#'
#' This function generates a finish message for a given module based on the error state.
#' If an error has occurred, it extracts the relevant error message and appends it to the finish message.
#' If no error has occurred, it returns a success message.
#'
#' @param PROJECT_NAME A character string specifying the name of the module.
#'
#' @return A character string containing the generated finish message.
#'
#' @examples
#' PROJECT_NAME <- "cds2db"
#' finish_message <- generateFinishMessage(PROJECT_NAME)
#' cat(finish_message)
#'
#' @export
generateFinishMessage <- function(PROJECT_NAME) {
  if (etlutils::isErrorOccured()) {
    if (etlutils::isDebugTestError()) {
      finish_message <- paste0("\nModule '", PROJECT_NAME, "' Debug Test Message:\n")
    } else {
      finish_message <- paste0("\nModule '", PROJECT_NAME, "' finished with ERRORS (see details above).\n")
    }

    # Remove irrelevant part from the error message
    error_message <- sub("^[^:]*: \n  ", "", etlutils::getErrorMessage())
    finish_message <- paste0(finish_message, error_message)

  } else {
    finish_message <- paste0("\nModule '", PROJECT_NAME, "' finished with no errors.\n")
  }

  return(finish_message)
}
