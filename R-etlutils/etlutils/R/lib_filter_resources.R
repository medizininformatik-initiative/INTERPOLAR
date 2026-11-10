#' Validate encounter filter pattern definitions
#'
#' This function validates encounter filter pattern definitions. It checks that
#' every subcondition has a valid formal structure, that each definition contains
#' exactly one non-empty `ward_name`, that `ward_name` is not combined with other
#' subconditions using `+`, and that all ward names are globally unique.
#'
#' @param encounter_filter_patterns A list of named lists containing encounter
#'   filter pattern definitions.
#'
#' @return Invisibly returns `TRUE` if all definitions are valid. Otherwise, the
#'   function stops with an error describing the first invalid definition found.
#'
#' @examples
#' encounter_filter_patterns <- list(
#'   list(
#'     ENCOUNTER_FILTER_PATTERN_1 = c(
#'       "ward_name = 'Station 1'",
#'       "location/location/reference = 'Location/location_id_1'"
#'     )
#'   ),
#'   list(
#'     ENCOUNTER_FILTER_PATTERN_2 = c(
#'       "ward_name = 'Station 2'",
#'       "location/location/reference = 'Location/location_id_2' + type/coding/code = 'Y'"
#'     )
#'   )
#' )
#'
#' validateEncounterFilterPatterns(encounter_filter_patterns)
#'
#' @export
validateEncounterFilterPatterns <- function(encounter_filter_patterns) {
  parsed_records <- parseStructuredConfigDefinitions(
    definitions = encounter_filter_patterns,
    allowed_key_pattern = "ward_name|[A-Za-z/]+",
    allow_plus = TRUE
  )

  if (length(parsed_records) == 0L) {
    return(invisible(TRUE))
  }

  definition_names <- unique(vapply(parsed_records, `[[`, "", "definition_name"))
  ward_names <- character()

  for (definition_name in definition_names) {
    definition_records <- parsed_records[
      vapply(parsed_records, `[[`, "", "definition_name") == definition_name
    ]

    keys <- vapply(definition_records, `[[`, "", "key")
    ward_name_records <- definition_records[keys == "ward_name"]
    ward_name_count <- length(ward_name_records)

    if (ward_name_count != 1L) {
      stop("Definition ", definition_name, " must contain exactly one ward_name, but contains ", ward_name_count, ".", call. = FALSE)
    }

    ward_name_record <- ward_name_records[[1]]

    if (trimws(ward_name_record$value) == "") {
      stop("ward_name must not be empty in ", ward_name_record$definition_name, " / ", ward_name_record$entry_name, " / line ", ward_name_record$line_index, call. = FALSE)
    }

    if (ward_name_record$part_count_in_line > 1L) {
      stop("ward_name must not be combined with other subconditions using '+' in ", ward_name_record$definition_name, " / ", ward_name_record$entry_name, " / line ", ward_name_record$line_index, call. = FALSE)
    }

    if (ward_name_record$value %in% ward_names) {
      stop("Duplicate ward_name found: '", ward_name_record$value, "'.", call. = FALSE)
    }

    ward_names <- c(ward_names, ward_name_record$value)
  }

  invisible(TRUE)
}

#' Convert encounter filter definitions to executable conditions
#'
#' Groups conditions by ward. Conditions on one definition line are AND-connected;
#' separate lines are OR-connected. Validate definitions with
#' validateEncounterFilterPatterns() before conversion.
#'
#' @param encounter_filter_patterns Named list of encounter filter definitions.
#'
#' @return A named list of wards, each containing lists of AND-connected conditions.
#'
#' @export
convertFilterPatterns <- function(encounter_filter_patterns) {
  if (!length(encounter_filter_patterns)) {
    stop("No encounter filter definitions supplied.", call. = FALSE)
  }

  # Initializes an empty list to store the final converted filter patterns. Each element in this list
  # corresponds to a ward, with the ward name as the key. The value for each ward is another list that
  # contains the AND-connected filter conditions (sub-conditions). Multiple groups of such conditions
  # are stored as separate elements, representing the OR-connected groups of filters for the ward.
  parsed_filter_patterns <- parseStructuredConfigDefinitions(
    definitions = encounter_filter_patterns,
    allowed_key_pattern = "ward_name|[A-Za-z/]+",
    allow_plus = TRUE
  )
  converted_filter_patterns <- list()
  definition_names <- unique(vapply(parsed_filter_patterns, `[[`, "", "definition_name"))

  for (definition_name in definition_names) {
    definition_filter_patterns <- parsed_filter_patterns[
      vapply(parsed_filter_patterns, `[[`, "", "definition_name") == definition_name
    ]
    single_ward_converted_filter_patterns <- list()
    ward_name <- definition_filter_patterns[[which(
      vapply(definition_filter_patterns, `[[`, "", "key") == "ward_name"
    )[1]]]$value
    condition_line_ids <- unique(vapply(definition_filter_patterns, function(filter_pattern) {
      paste(filter_pattern$entry_name, filter_pattern$line_index, sep = "\r")
    }, ""))

    for (condition_line_id in condition_line_ids) {
      line_filter_patterns <- definition_filter_patterns[
        vapply(definition_filter_patterns, function(filter_pattern) {
          paste(filter_pattern$entry_name, filter_pattern$line_index, sep = "\r") == condition_line_id
        }, logical(1))
      ]

      if (line_filter_patterns[[1]]$key == "ward_name") {
        next
      }

      and_conditions <- list()
      for (filter_pattern in line_filter_patterns) {
        and_conditions[[filter_pattern$key]] <- filter_pattern$value
      }
      single_ward_converted_filter_patterns[[paste0("Condition_", length(single_ward_converted_filter_patterns) + 1)]] <- and_conditions
    }

    converted_filter_patterns[[length(converted_filter_patterns) + 1]] <- single_ward_converted_filter_patterns
    names(converted_filter_patterns)[length(converted_filter_patterns)] <- ward_name
  }

  converted_filter_patterns
}

#' Filters the given resources table by the given filter patterns.
#'
#' This function filters a resources table based on the provided filter patterns.
#'
#' @param resources A data.table representing the resources table to be filtered.
#' @param filter_patterns A list of OR-connected conditions. Each condition is a named list
#'   of AND-connected regular expressions; names identify columns in resources.
#' @param return_removed A logical value. If `TRUE`, the function returns a list with two elements:
#'   \itemize{
#'     \item \code{kept_resources}: The rows that satisfy the filter conditions.
#'     \item \code{removed_resources}: The rows that do not satisfy the filter conditions.
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

  # Evaluate each expression once for the rows that can still match. Preserve
  # short-circuiting across OR groups and within each AND group.
  keep <- rep(FALSE, nrow(resources))
  for (condition in filter_patterns) {
    resources[, Filter_Column_Keep_Subcondition := FALSE]
    candidates <- which(!keep)
    # Preserve rejection of an empty AND group when unclassified rows remain.
    for (i in seq_len(max(1L, length(condition)))) {
      if (!length(candidates)) break
      column_name <- names(condition)[[i]]
      if (!column_name %in% names(resources)) {
        stop("Filter column not found: ", column_name, call. = FALSE)
      }
      candidates <- candidates[grepl(
        condition[[i]], resources[[column_name]][candidates],
        ignore.case = TRUE, perl = TRUE
      )]
    }
    keep[candidates] <- TRUE
    resources[, Filter_Column_Keep := keep]
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
