#' Create a data.table with ward and patient ID per date.
#'
#' This function takes a list of patient IDs per ward and constructs a data.table
#' with columns for date_time, ward, and pid. Each row represents a unique combination
#' of date, ward, and patient ID extracted from the provided list.
#'
#' @param pids_splitted_by_ward A list of patient IDs, where each element corresponds to a ward.
#'
#' @return A data.table with columns date_time, ward, and pid, representing the date, ward,
#'   and patient ID for each combination extracted from the provided list.
#'
#' @examples
#' library(data.table)
#' # Example: A list of patient IDs per ward
#' pids_splitted_by_ward <- list(
#'   Ward_A = c("PID_A001", "PID_A002", "PID_A003"),
#'   Ward_B = c("PID_B001", "PID_B002"),
#'   Ward_C = c("PID_C001", "PID_C002", "PID_C003", "PID_C004")
#' )
#'
#' # Applying the function
#' result_table <- rbindPidsSplittedByWard(pids_splitted_by_ward)
#'
#' # Displaying the result
#' print(result_table)
#'
rbindPidsSplittedByWard <- function(pids_splitted_by_ward) {
  # Combine all ward tables into one data.table
  pids_per_ward <- data.table::rbindlist(
    lapply(names(pids_splitted_by_ward), function(ward) {
      dt <- pids_splitted_by_ward[[ward]]
      if (nrow(dt) > 0) {
        return(dt[, ward_name := ward])  # Add ward column
      }
      return(NULL)  # Skip empty tables
    }),
    use.names = TRUE, fill = TRUE
  )
  return(pids_per_ward)
}
