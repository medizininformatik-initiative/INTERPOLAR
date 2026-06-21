# Column name for table-description based pseudonymization rules
PSEUDONYMIZATION_RULE_COLNAME <- "PSEUDONYMIZATION_RULE"

normalizeFhirPathExpression <- function(path) {
  path <- gsub("\\.ofType\\(dateTime\\)", "DateTime", path)
  path <- gsub("\\.ofType\\(boolean\\)", "Boolean", path)
  gsub("\\.", "/", path)
}

ruleTextFromYamlRule <- function(rule) {
  method <- rule$method
  if (is.null(method) || is.na(method) || !nzchar(method)) {
    return(NA_character_)
  }

  if (method == "pseudonymize") {
    domain <- rule$domain
    if (is.null(domain) || is.na(domain) || !nzchar(domain)) {
      return("pseudonymize")
    }
    return(paste0("pseudonymize(", domain, ")"))
  }

  if (method == "generalize") {
    case_expression <- paste(unlist(rule$cases, use.names = FALSE), collapse = " ")
    if (grepl("substring\\(0,2\\)", case_expression)) {
      return("generalize(postalCode2)")
    }
    if (grepl("\\$\\{year\\}-\\$\\{month\\}", case_expression, fixed = FALSE)) {
      return("generalize(YYYY-MM)")
    }
    if (grepl("\\$\\{year\\}", case_expression, fixed = FALSE)) {
      return("generalize(YYYY)")
    }
    return("generalize")
  }

  method
}

extractNodesByTypeRule <- function(path) {
  match <- regexec("^nodesByType\\('([^']+)'\\)(?:\\.(.*))?$", path)
  parts <- regmatches(path, match)[[1]]
  if (length(parts) == 0) {
    return(NULL)
  }

  suffix <- parts[3]
  if (is.na(suffix) || !nzchar(suffix)) {
    suffix <- NA_character_
  }

  list(type = parts[2], suffix = suffix)
}

nodeTypeMatches <- function(node_type, fhir_expression) {
  expression <- tolower(fhir_expression)
  switch(node_type,
    "Address" = grepl("(^|/)address(/|$)", expression),
    "Identifier" = grepl("(^|/)identifier(/|$)", expression),
    "Reference" = grepl("(^|/)reference$|(^|/)reference(/|$)", expression),
    "HumanName" = grepl("(^|/)name(/|$)", expression),
    "ContactPoint" = grepl("(^|/)telecom(/|$)", expression),
    "Annotation" = grepl("(^|/)annotation(/|$)|(^|/)note(/|$)", expression),
    "Age" = grepl("(^|/)age(/|$)", expression),
    "Narrative" = expression == "text",
    "base64Binary" = FALSE,
    FALSE
  )
}

nodesByTypeRuleMatches <- function(node_rule, table_description) {
  type_matches <- nodeTypeMatches(node_rule$type, table_description$FHIR_EXPRESSION)
  if (!is.na(node_rule$suffix)) {
    suffix <- normalizeFhirPathExpression(node_rule$suffix)
    suffix <- sub("^where\\(.+\\)\\.", "", suffix)
    suffix_matches <- grepl(
      paste0("(^|/)", suffix, "$"),
      table_description$FHIR_EXPRESSION
    )
    type_matches <- type_matches & suffix_matches
  }
  which(type_matches)
}

specificPathRuleMatches <- function(path, table_description) {
  if (!grepl("^[^.]+\\.", path)) {
    return(integer())
  }

  resource <- sub("\\..*$", "", path)
  expression <- sub("^[^.]+\\.", "", path)
  expression <- normalizeFhirPathExpression(expression)

  which(
    table_description$RESOURCE_FILLED == resource &
      table_description$FHIR_EXPRESSION == expression
  )
}

matchYamlRuleToTableDescription <- function(rule, table_description) {
  path <- rule$path
  if (is.null(path) || is.na(path) || !nzchar(path)) {
    return(integer())
  }

  node_rule <- extractNodesByTypeRule(path)
  if (!is.null(node_rule)) {
    return(nodesByTypeRuleMatches(node_rule, table_description))
  }

  if (grepl("^Resource\\.", path)) {
    expression <- normalizeFhirPathExpression(sub("^Resource\\.", "", path))
    return(which(table_description$FHIR_EXPRESSION == expression))
  }

  specificPathRuleMatches(path, table_description)
}

buildFhirPseudonymizationCandidates <- function(table_description, yaml_rules) {
  candidates <- data.table::data.table(
    row_index = integer(),
    rule_index = integer(),
    yaml_path = character(),
    pseudonymization_rule = character()
  )

  for (rule_index in seq_along(yaml_rules)) {
    rule <- yaml_rules[[rule_index]]
    matched_rows <- matchYamlRuleToTableDescription(rule, table_description)
    if (length(matched_rows) == 0) {
      next
    }

    candidates <- data.table::rbindlist(list(
      candidates,
      data.table::data.table(
        row_index = matched_rows,
        rule_index = rule_index,
        yaml_path = rule$path,
        pseudonymization_rule = ruleTextFromYamlRule(rule)
      )
    ), use.names = TRUE)
  }

  candidates
}

selectPseudonymizationCandidates <- function(candidates) {
  if (nrow(candidates) == 0) {
    return(candidates)
  }

  candidates[["specificity"]] <- ifelse(
    grepl("^nodesByType", candidates[["yaml_path"]]),
    1L,
    ifelse(grepl("^Resource\\.", candidates[["yaml_path"]]), 2L, 3L)
  )
  candidates <- candidates[order(
    candidates[["row_index"]],
    -candidates[["specificity"]],
    candidates[["rule_index"]]
  ), ]
  candidates[!duplicated(candidates[["row_index"]]), ]
}

#' Add Pseudonymization Rules to a FHIR Table Description
#'
#' Adds a `PSEUDONYMIZATION_RULE` column to an expanded FHIR table description.
#' Rules are derived from a FHIR pseudonymizer YAML file. Explicit YAML `redact`
#' matches are written as `redact`; rows without any match remain empty, which
#' is interpreted as redact by the later DB pseudonymization process.
#'
#' @param table_description Expanded FHIR table description as a data.table.
#' @param yaml_path Path to a FHIR pseudonymizer YAML file.
#'
#' @return The table description with a `PSEUDONYMIZATION_RULE` column. Match
#' details are attached as attributes `pseudonymization_candidates`,
#' `pseudonymization_selected`, and `pseudonymization_conflicts`.
#' @export
setFhirPseudonymizationRules <- function(table_description, yaml_path) {
  table_description <- data.table::copy(table_description)
  if (!all(c("RESOURCE", "COLUMN_NAME", "FHIR_EXPRESSION") %in% names(table_description))) {
    stop("table_description must contain RESOURCE, COLUMN_NAME, and FHIR_EXPRESSION columns.")
  }

  yaml_config <- yaml::read_yaml(yaml_path)
  yaml_rules <- yaml_config$fhirPathRules
  if (is.null(yaml_rules) || length(yaml_rules) == 0) {
    stop("YAML file does not contain fhirPathRules.")
  }

  table_description[["RESOURCE_FILLED"]] <- table_description[["RESOURCE"]]
  etlutils::fillNAWithLastRowValue(table_description, "RESOURCE_FILLED")
  candidates <- buildFhirPseudonymizationCandidates(table_description, yaml_rules)
  selected <- selectPseudonymizationCandidates(candidates)

  table_description[[PSEUDONYMIZATION_RULE_COLNAME]] <- NA_character_
  if (nrow(selected) > 0) {
    data.table::set(
      table_description,
      i = selected$row_index,
      j = PSEUDONYMIZATION_RULE_COLNAME,
      value = selected$pseudonymization_rule
    )
  }

  conflicts <- data.table::data.table()
  if (nrow(candidates) > 0) {
    conflicts <- data.table::rbindlist(lapply(
      split(candidates, candidates[["row_index"]]),
      function(row_candidates) {
        row_index <- row_candidates[["row_index"]][1]
        selected_rule <- selected[["pseudonymization_rule"]][
          match(row_index, selected[["row_index"]])
        ]
        all_rules <- paste(unique(row_candidates[["pseudonymization_rule"]]), collapse = " | ")
        if (nrow(row_candidates) <= 1 || identical(all_rules, selected_rule)) {
          return(NULL)
        }

        data.table::data.table(
          row_index = row_index,
          rule_count = nrow(row_candidates),
          selected_rule = selected_rule,
          all_rules = all_rules,
          yaml_paths = paste(unique(row_candidates[["yaml_path"]]), collapse = " | ")
        )
      }
    ), use.names = TRUE)
  }

  table_description[["RESOURCE_FILLED"]] <- NULL
  attr(table_description, "pseudonymization_candidates") <- candidates
  attr(table_description, "pseudonymization_selected") <- selected
  attr(table_description, "pseudonymization_conflicts") <- conflicts
  table_description
}

#' Generate FHIR Table Description with Pseudonymization Rules
#'
#' Reads an expanded FHIR table-description workbook and a FHIR pseudonymizer
#' YAML file, adds `PSEUDONYMIZATION_RULE`, and writes a new workbook. The input
#' workbook is not modified.
#'
#' @param table_description_path Path to the expanded FHIR table-description xlsx.
#' @param yaml_path Path to the FHIR pseudonymizer YAML file.
#' @param output_path Path of the generated xlsx file.
#' @param sheet_name Name of the table-description sheet.
#'
#' @return Invisibly returns the generated table description.
#' @export
generateFhirPseudonymizationTableDescription <- function(table_description_path,
                                                         yaml_path,
                                                         output_path,
                                                         sheet_name = "table_description") {
  table_description <- etlutils::loadTableDescriptionFile(table_description_path, sheet_name)
  table_description <- setFhirPseudonymizationRules(table_description, yaml_path)

  header <- c(
    "Hint",
    paste(
      "This file is generated for snapshot pseudonymization.",
      "Do not change the source table description directly."
    ),
    paste0(
      "Column ",
      PSEUDONYMIZATION_RULE_COLNAME,
      " controls DB pseudonymization for each expanded FHIR column."
    ),
    paste0("Empty values in ", PSEUDONYMIZATION_RULE_COLNAME, " are interpreted as redact."),
    "Explicit redact values originate from matched YAML redact rules."
  )
  table_with_header <- etlutils::addTextHeaderToTable(
    table_description,
    header,
    insert_column_names_below_header = TRUE
  )
  etlutils::writeExcelFile(
    stats::setNames(list(table_with_header), sheet_name),
    output_path,
    with_column_names = FALSE
  )

  invisible(table_description)
}
