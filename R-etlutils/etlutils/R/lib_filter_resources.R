#' Filters the given resources table by the given filter patterns.
#'
#' This function filters a resources table based on the provided filter patterns.
#'
#' @param resources A data.table representing the resources table to be filtered.
#' @param filter_patterns A list of filter conditions. Each condition is a character string containing multiple
#' subconditions separated by '+'.
#'
#' @return A filtered data.table based on the given filter patterns.
#'
#' @details
#' This function applies an OR operation across the filter patterns, meaning that a row will be retained if at
#' least one condition is fulfilled.
#' However, within each individual condition (subconditions separated by '+'), an AND operation is applied,
#' requiring all subconditions to be met for the condition to be satisfied.
#'
#' @export
#'
filterResources <- function(resources, filter_patterns) {

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

  resources[, Filter_Column_Keep_Subcondition := NULL]
  filtered_resources <- resources[Filter_Column_Keep == TRUE]
  filtered_resources[, Filter_Column_Keep := NULL]
  resources[, Filter_Column_Keep := NULL]
  return(filtered_resources)
}
