# Column name for table-description based pseudonymization rules
PSEUDONYMIZATION_RULE_COLNAME <- "PSEUDONYMIZATION_RULE"

getDefaultFhirPseudonymizationYamlPath <- function() {
  yaml_path <- system.file("extdata", "dimp_dup_base.yaml", package = "pseudonym")
  if (!nzchar(yaml_path)) {
    stop("Default FHIR pseudonymization YAML file not found in package extdata.")
  }
  yaml_path
}

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

buildFhirYamlRuleMatches <- function(yaml_rules, candidates) {
  rule_matches <- data.table::data.table(
    rule_index = seq_along(yaml_rules),
    yaml_path = vapply(yaml_rules, function(rule) rule$path, character(1)),
    pseudonymization_rule = vapply(yaml_rules, ruleTextFromYamlRule, character(1))
  )

  if (nrow(candidates) == 0) {
    rule_matches[["matched_rows"]] <- 0L
    return(rule_matches)
  }

  matched_rows_by_rule <- stats::aggregate(
    row_index ~ rule_index,
    data = unique(candidates[, c("rule_index", "row_index")]),
    FUN = length
  )
  names(matched_rows_by_rule)[names(matched_rows_by_rule) == "row_index"] <- "matched_rows"
  rule_matches <- merge(rule_matches, matched_rows_by_rule, by = "rule_index", all.x = TRUE)
  rule_matches[is.na(rule_matches[["matched_rows"]]), "matched_rows"] <- 0L
  rule_matches[order(rule_matches[["rule_index"]]), ]
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

getUnmatchedTableDescriptionRows <- function(table_description, candidates) {
  matched_rows <- unique(candidates[["row_index"]])
  unmatched_rows <- setdiff(seq_len(nrow(table_description)), matched_rows)
  if (length(unmatched_rows) == 0) {
    return(data.table::data.table(
      row_index = integer(),
      RESOURCE = character(),
      COLUMN_NAME = character(),
      FHIR_EXPRESSION = character()
    ))
  }

  context <- data.table::data.table(
    row_index = seq_len(nrow(table_description)),
    RESOURCE = table_description[["RESOURCE"]],
    COLUMN_NAME = table_description[["COLUMN_NAME"]],
    FHIR_EXPRESSION = table_description[["FHIR_EXPRESSION"]]
  )
  etlutils::fillNAWithLastRowValue(context, "RESOURCE")
  context[context[["row_index"]] %in% unmatched_rows, ]
}

withTableDescriptionContext <- function(rule_table, table_description) {
  if (nrow(rule_table) == 0) {
    rule_table[["RESOURCE"]] <- character()
    rule_table[["COLUMN_NAME"]] <- character()
    rule_table[["FHIR_EXPRESSION"]] <- character()
    return(rule_table)
  }

  resource <- table_description[["RESOURCE"]]
  context <- data.table::data.table(
    row_index = seq_len(nrow(table_description)),
    RESOURCE = resource,
    COLUMN_NAME = table_description[["COLUMN_NAME"]],
    FHIR_EXPRESSION = table_description[["FHIR_EXPRESSION"]]
  )
  etlutils::fillNAWithLastRowValue(context, "RESOURCE")
  merge(context, rule_table, by = "row_index", all.y = TRUE, sort = FALSE)
}

getRuleSummary <- function(table_description) {
  rule <- table_description[[PSEUDONYMIZATION_RULE_COLNAME]]
  rule[is.na(rule) | !nzchar(rule)] <- "<empty/default redact>"
  summary <- as.data.frame(table(rule), stringsAsFactors = FALSE)
  names(summary) <- c(PSEUDONYMIZATION_RULE_COLNAME, "N")
  data.table::as.data.table(summary[order(summary[[PSEUDONYMIZATION_RULE_COLNAME]]), ])
}

#' Build a FHIR Pseudonymization Rule Report
#'
#' Builds review tables from a FHIR table description previously processed with
#' `setFhirPseudonymizationRules()`.
#'
#' @param table_description Table description returned by
#' `setFhirPseudonymizationRules()`.
#'
#' @return A named list with `summary`, `yaml_rules`, `unmatched_table_rows`,
#' `selected_rules`, `conflicts`, and `candidates`.
#' @export
getFhirPseudonymizationRuleReport <- function(table_description) {
  candidates <- attr(table_description, "pseudonymization_candidates")
  selected <- attr(table_description, "pseudonymization_selected")
  conflicts <- attr(table_description, "pseudonymization_conflicts")
  yaml_rule_matches <- attr(table_description, "pseudonymization_yaml_rule_matches")

  if (is.null(candidates) || is.null(selected) || is.null(conflicts) ||
      is.null(yaml_rule_matches)) {
    stop("table_description must be processed with setFhirPseudonymizationRules() first.")
  }

  list(
    summary = getRuleSummary(table_description),
    yaml_rules = yaml_rule_matches,
    unmatched_table_rows = getUnmatchedTableDescriptionRows(table_description, candidates),
    selected_rules = withTableDescriptionContext(selected, table_description),
    conflicts = withTableDescriptionContext(conflicts, table_description),
    candidates = withTableDescriptionContext(candidates, table_description)
  )
}

#' Add Pseudonymization Rules to a FHIR Table Description
#'
#' Adds a `PSEUDONYMIZATION_RULE` column to an expanded FHIR table description.
#' Rules are derived from a FHIR pseudonymizer YAML file. Explicit YAML `redact`
#' matches are written as `redact`; rows without any match remain empty, which
#' is interpreted as redact by the later DB pseudonymization process.
#'
#' @param table_description Expanded FHIR table description as a data.table.
#' @param yaml_path Path to a FHIR pseudonymizer YAML file. Defaults to the
#' packaged DIMP-DUP base YAML.
#'
#' @return The table description with a `PSEUDONYMIZATION_RULE` column. Match
#' details are attached as attributes `pseudonymization_candidates`,
#' `pseudonymization_selected`, `pseudonymization_conflicts`, and
#' `pseudonymization_yaml_rule_matches`.
#' @export
setFhirPseudonymizationRules <- function(
    table_description,
    yaml_path = getDefaultFhirPseudonymizationYamlPath()) {
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
  yaml_rule_matches <- buildFhirYamlRuleMatches(yaml_rules, candidates)

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
  attr(table_description, "pseudonymization_yaml_rule_matches") <- yaml_rule_matches
  table_description
}
