#' Filters the given resources table by the given filter patterns.
#'
#' This function filters a resources table based on the provided filter patterns.
#'
#' @param resources A data.table representing the resources table to be filtered.
#' @param filter_patterns A list of filter conditions. Each condition is a character string containing multiple
#' subconditions separated by '+'.
#' @param return_removed A logical value. If `TRUE`, the function returns a list with two elements:
#'   \itemize{
#'     \item \code{kept}: The rows that satisfy the filter conditions.
#'     \item \code{removed}: The rows that do not satisfy the filter conditions.
#'   }
#'   If `FALSE` (default), the function returns only the filtered rows (kept).
#'
#' @return A filtered data.table based on the given filter patterns.
#'
#' @details
#' This function applies an OR operation across the filter patterns, meaning that a row will be retained if at
#' least one condition is fulfilled.
#' However, within each individual condition (subconditions separated by '+'), an AND operation is applied,
#' requiring all subconditions to be met for the condition to be satisfied.
#'
#' @examples
#' library(data.table)
#'
#' # Create example resources table
#' resources <- data.table(
#'   id = 1:5,
#'   type = c("A", "B", "A", "C", "B"),
#'   serviceType = c("0100", "0200", "0500", "0100", "0500"),
#'   class = c("station", "IMP", "inpatient", "ACUTE", "NONAC")
#' )
#'
#' # Example 1: Filter resources where type = "A"
#' filter_patterns <- list(
#'   list(type = "A")
#' )
#' filtered_resources <- filterResources(resources, filter_patterns)
#' print(filtered_resources)
#'
#' # Example 2: Filter where serviceType is "0100" or "0500"
#' filter_patterns <- list(
#'   list(serviceType = "0100|0500")
#' )
#' filtered_resources <- filterResources(resources, filter_patterns)
#' print(filtered_resources)
#'
#' # Example 3: Filter where type = "B" AND serviceType = "0500"
#' filter_patterns <- list(
#'   list(type = "B", serviceType = "0500")
#' )
#' filtered_resources <- filterResources(resources, filter_patterns)
#' print(filtered_resources)
#'
#' # Example 4: Return removed rows as well
#' filter_patterns <- list(
#'   list(type = "A")
#' )
#' result <- filterResources(resources, filter_patterns, return_removed = TRUE)
#' print(result$kept_resources)    # Rows that match the filter
#' print(result$removed_resources) # Rows that do not match
#'
#' @export
#'
filterResources <- function(resources, filter_patterns, return_removed = FALSE) {

  # nothing todo
  if (!length(filter_patterns)) {
    return(resources)
  }

  # Temporarily stores which columns should be kept (initialized with FALSE, meaning all columns should be removed)
  resources[, Filter_Column_Keep := FALSE]

  # Check if a row fulfills a given condition
  #
  # This function checks if a row meets a given condition based on grep patterns for each column.
  #
  # @param row A row (list or data.frame) to be checked against the condition.
  # @param condition A list where each element is a grep pattern, and the name corresponds to the column in the row.
  # @return TRUE if the row fulfills the condition, FALSE otherwise.
  #
  fulfills_condition <- function(row, condition) {
    subConditionColumns <- names(condition)
    for (i in 1:length(condition)) { # i <- 1
      subConditionColumn <- subConditionColumns[[i]]
      subCondition <- condition[[i]]
      if (!grepl(subCondition, row[[subConditionColumn]], ignore.case = TRUE, perl = TRUE)) {
        return(FALSE)
      }
    }
    return(TRUE)
  }

  # filterPatterns can have a list of conditions in this style:
  # "type/coding/code = 'Abteilungskontakt' + serviceType/coding/code = '0100|0500' + class/code = 'station|IMP|inpatient|emer|ACUTE|NONAC'"
  # Such a condition means that 3 subconditions must be fulfilled (separated by '+').
  for (condition in filter_patterns) { # condition <- filter_patterns[[1]]
    resources[, Filter_Column_Keep_Subcondition := FALSE]
    for (i in seq_len(nrow(resources))) {
      resources[i, Filter_Column_Keep := resources[i, Filter_Column_Keep] || fulfills_condition(resources[i], condition)]
    }
  }

  # Split into kept and removed rows
  kept_resources <- resources[Filter_Column_Keep == TRUE]
  removed_resources <- resources[Filter_Column_Keep == FALSE]

  # Clean up temporary columns
  kept_resources[, c("Filter_Column_Keep", "Filter_Column_Keep_Subcondition") := NULL]
  removed_resources[, c("Filter_Column_Keep", "Filter_Column_Keep_Subcondition") := NULL]

  # Decide return type based on return_removed
  if (return_removed) {
    return(list(
      kept_resources = kept_resources,
      removed_resources = removed_resources
    ))
  } else {
    return(kept_resources)
  }
}
