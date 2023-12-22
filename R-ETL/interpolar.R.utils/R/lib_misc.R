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
