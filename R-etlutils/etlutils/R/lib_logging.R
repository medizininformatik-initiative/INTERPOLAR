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
start_logging <- function(prefix) {
  log_file <- file(fhircrackr::paste_paths(polar_path_to_log_directory(), paste0(prefix, "-log.txt")), open = "wt")
  sink(log_file, append = TRUE, split = TRUE)
  sink(log_file, append = TRUE, type = "message")
}

#' End Logging
#'
#' This function finalizes the logging process by closing the log file.
#'
#' @return NULL
#'
#' @details
#' The function stops the redirection of console output and messages to the log file initiated by \code{start_logging}.
#' It closes the log file, ensuring that no further entries are appended to it.
#'
#' @export
end_logging <- function() {
  sink(type = "message")
  sink()
}

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
runProcess <- function(
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

  err <- PROCESS_CLOCK$measure_process_time(
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


#' Execute an outer script with a specified message and process
#'
#' This function runs an outer script with the provided message and process, controlling
#' the verbosity level.
#'
#' @param message A character string describing the purpose of the outer script.
#' @param process A function representing the outer script to be executed.
#'
#' @export
run_out <- function(message, process) {
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
run_in <- function(message, process) {
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
run_in_in <- function(message, process) {
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
run_in_in_ignore_error <- function(message, process) {
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
  runProcess(
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
runs_out <- function(message, process) {
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
runs_in <- function(message, process) {
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
runs_in_in <- function(message, process) {
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
  runProcess(
    message = message,
    process = process,
    verbose = VERBOSE - verbose + 1,
    single_line = TRUE
  )}

#' Start a Process with Error Handling
#'
#' This function initiates a process using the specified function and includes error handling.
#'
#' @param process The function representing the process to be executed.
#' @return None (prints clock information and handles errors)
#'
#' @seealso START__, printClock, END__, stopOnError
#'
#' @export
startProcess <- function(process) {
  START__()
  err <- try(process, silent = TRUE)
  printClock()
  warnings()
  END__()
  stopOnError(err)
}
