#' Filter raw resource tables based on patient IDs
#'
#' This function filters resource tables from `resource_tables` based on patient IDs provided as input.
#' It extracts the actual patient identifiers from the input using `etlutils::getAfterLastSlash()`
#' and constructs different reference formats depending on the resource type. The function supports
#' different types of patient identifier columns and applies filtering accordingly.
#'
#' - **Patient references (`patient_ref`)** are matched against `"[1.1]Patient/"` followed by the
#'   patient ID.
#' - **Patient tables (`pat_id`)** use a different reference format `"[1]"` followed by the patient ID.
#' - **Ward PID tables (`pid`)** are matched directly against the extracted patient IDs.
#' - **Non-patient referencing tables** (e.g., `Location`, `Medication`) are returned unfiltered.
#'
#' @param patient_ids A character vector representing patient IDs (e.g., `c("UKB-0001", "UKB-0002")`).
#'
#' @return A named list of `data.table` objects, where each table is filtered based on patient
#'         identifiers if applicable.
#'
getFilteredRAWResources <- function(patient_ids) {
  filtered_resources <- list()
  ids <- etlutils::getAfterLastSlash(patient_ids)
  refs <- paste0("[1.1]Patient/", ids)

  for (resource_name in names(resource_tables)) {
    pid_column <- if (resource_name == "pids_per_ward") "patient_id" else etlutils::fhirdbGetPIDColumn(resource_name)
    resource_table <- resource_tables[[resource_name]]
    if (pid_column %in% names(resource_table)) {
      filtered_resources[[resource_name]] <- if (endsWith(pid_column, "patient_ref")) {
        resource_table[get(pid_column) %in% refs]
      } else if (pid_column == "pat_id") { # Patient table
        resource_table[get(pid_column) %in% paste0("[1]", ids)]
      } else if (pid_column == "patient_id") { # pids_per_war_table
        resource_table[get(pid_column) %in% ids]
      }
    } else { # non patient referencing tables (Location, Medication...)
      filtered_resources[[resource_name]] <- resource_table
    }
  }

  return(filtered_resources)
}
#' Retain specific resource tables while clearing others
#'
#' This function retains only the specified tables from `resource_tables`, while all other tables
#' are cleared by removing all rows but keeping the structure. The table `"pids_per_ward"` is
#' always retained by default.
#'
#' @param ... Character strings representing table names that should be retained.
#'
#' @return A modified named list of `data.table` objects, where only the specified tables remain
#'         unchanged, and all others are cleared (empty but with the same structure).
#'
retainRAWTables <- function(...) {
  table_names <- c(..., "pids_per_ward")
  for (name in names(resource_tables)) {
    if (!(name %in% table_names)) {
      resource_tables[[name]] <- resource_tables[[name]][0]  # Remove all rows, keep structure
    }
  }
  return(resource_tables)
}

#' Format a datetime as RAW timestamp with a fixed offset
#'
#' This function formats a given datetime into the RAW timestamp format used in the system.
#' If no datetime is provided, the current system time (`Sys.time()`) is used.
#' The function subtracts the specified number of days from the given datetime and returns it
#' in the format: `"[1.1]YYYY-MM-DDTHH:MM:SS+02:00"`, where the offset represents the system's timezone.
#'
#' @param datetime A `POSIXct` object representing the datetime to be formatted.
#'                 Defaults to the current system time (`Sys.time()`).
#' @param offset_days_minus An integer specifying how many days should be subtracted from `datetime`.
#'                    Defaults to `2`.
#'
#' @return A character string with the formatted datetime.
#'
getFormattedRAWDateTime <- function(datetime = DEBUG_DATES[DEBUG_DAY], offset_days_minus = 1) {
  datetime <- as.POSIXct(datetime)
  # Subtract the specified number of days from the given datetime
  datetime <- datetime - offset_days_minus * 86400

  # Format as "[1.1]YYYY-MM-DDTHH:MM:SS+02:00"
  format(datetime, "[1.1]%Y-%m-%dT%H:%M:%S%z")
}

#' Get a RAW-formatted datetime from DEBUG_DATES with additive offset
#'
#' Returns a RAW-formatted datetime string based on \code{DEBUG_DATES[debug_date_index]} and an
#' additive day offset. Internally delegates to \code{getFormattedRAWDateTime()} and passes the
#' negated offset so that positive values in \code{offset_days} shift the datetime forward.
#'
#' @param offset_days Integer number of days to add to the selected debug date. Defaults to \code{0}.
#' @param debug_date_index Integer index into \code{DEBUG_DATES} selecting the base datetime.
#'
#' @return Character string in the RAW datetime format produced by
#'   \code{getFormattedRAWDateTime()}.
#'
#' @examples
#' \dontrun{
#' # Shift DEBUG_DATES[1] by +2 days and format as RAW timestamp
#' getDebugDatesRAWDateTime(offset_days = 0.2, debug_date_index = 1)
#'
#' # Use the date as-is (no shift)
#' getDebugDatesRAWDateTime(debug_date_index = 2)
#' }
#'
#' @export
getDebugDatesRAWDateTime <- function(offset_days = 0, debug_date_index = DEBUG_DAY) {
  datetime <- DEBUG_DATES[debug_date_index]
  # Get the formatted RAW datetime
  raw_datetime <- getFormattedRAWDateTime(datetime, -as.numeric(offset_days))
  # Return the formatted datetime
  return(raw_datetime)
}


#' Update values in a data.table based on patient ID and column name pattern
#'
#' This function updates one or more columns in a `data.table` (`table`) based on a given patient ID (`pid`).
#' The row selection criteria depend on the structure of the table:
#'
#' - If the table contains a `pat_id` column, rows are selected where `pat_id` matches `pid` or `"[1]"` followed by `pid`.
#' - Otherwise, if a column ending in `_patient_ref` exists, rows are selected where the extracted patient ID
#'   (obtained via `etlutils::getAfterLastSlash()`) matches `pid`.
#' - If no such identifying columns exist, the table remains unchanged.
#'
#' The function allows updating multiple columns that match a given pattern, including exact column names.
#'
#' @param table A `data.table` containing patient data.
#' @param pid A character string representing the patient ID to match.
#' @param pattern A character string specifying a pattern or exact column name to match.
#' @param new_value The new value to assign to the selected rows in the matching columns.
#'
#' @return The modified `data.table` with updated values in the specified columns.
#'
#' @export
changeDataForPID <- function(table, pid, pattern, new_value) {
  colnames <- names(table)

  # Identify rows to update
  rows_to_update <- NULL

  if ("pat_id" %in% colnames) {
    rows_to_update <- which(table$pat_id == pid | table$pat_id == paste0("[1]", pid))
  } else {
    ref_col <- colnames[endsWith(colnames, "_patient_ref")]

    if (length(ref_col) > 0) {
      ref_col <- ref_col[1]  # Take the first matching column if multiple exist
      extracted_pid <- etlutils::getAfterLastSlash(table[[ref_col]])
      rows_to_update <- which(extracted_pid == pid)
    } else {
      return(table) # No matching column found, return unchanged data.table
    }
  }

  # Identify columns matching the pattern (supporting exact names)
  matching_columns <- colnames[colnames == pattern | grepl(pattern, colnames)]

  if (length(matching_columns) > 0 && length(rows_to_update) > 0) {
    # Update matching columns
    table[rows_to_update, (matching_columns) := lapply(.SD, function(x) new_value), .SDcols = matching_columns]
  }
}

#' Get column names from a data.table matching a given pattern
#'
#' This function returns all column names from a \code{data.table} that match a given
#' regular expression pattern.
#'
#' @param dt A \code{data.table} from which the column names will be extracted.
#' @param pattern A character string containing a regular expression to match against
#'   column names.
#'
#' @return A character vector containing the names of all matching columns.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(enc_diagnosis_a = 1, enc_diagnosis_b = 2, enc_servicetype_x = 3)
#' getColNames(dt, "^enc_diagnosis_")
#' getColNames(dt, "^enc_servicetype_")
#'
#' @export
getColNames <- function(dt, pattern) {
  grep(pattern, names(dt), value = TRUE)
}

#' Extract values from a RAW-formatted column
#'
#' This function extracts the part of each string value that comes **after** the first closing
#' square bracket (`]`). If there is no closing bracket in a value, the value is returned unchanged.
#'
#' Typical RAW values may look like `"[1.2]2024-08-13T10:15:00+02:00"`, where the prefix in square
#' brackets contains numeric components separated by dots. The shortest valid form could be
#' a single digit in square brackets (e.g., `"[5]"`).
#'
#' @param dt_raw A \code{data.table} containing the column to be processed.
#' @param column_name A character string with the name of the column to process.
#'
#' @return A character vector with the extracted values.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(raw_col = c("[1.2]2024-08-13", "[5]", "no_brackets"))
#' extractValueFromRAW(dt, "raw_col")
#' # Returns: c("2024-08-13", "", "no_brackets")
#'
#' @export
extractValueFromRAW <- function(dt_raw, column_name) {
  values <- dt_raw[[column_name]]
  sub("^\\[[0-9]+(\\.[0-9]+)*\\](.*)$", "\\2", values)
}
