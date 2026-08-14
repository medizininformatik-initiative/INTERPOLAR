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

quoteRuleValue <- function(value) {
  paste0("\"", gsub("\"", "\\\\\"", value), "\"")
}

generalizationFormatFromYamlRule <- function(rule) {
  case_expression <- paste(unlist(rule$cases, use.names = FALSE), collapse = " ")
  if (grepl("substring\\(0,2\\)", case_expression)) {
    return("postalCode2")
  }
  if (grepl("\\$\\{year\\}-\\$\\{month\\}", case_expression, fixed = FALSE)) {
    return("YYYY-MM")
  }
  if (grepl("\\$\\{year\\}", case_expression, fixed = FALSE)) {
    return("YYYY")
  }
  NA_character_
}

conditionTextFromFhirWhere <- function(where_expression) {
  if (is.na(where_expression) || !nzchar(where_expression)) {
    return(NA_character_)
  }

  coding_prefix <- if (grepl("type.coding.where", where_expression, fixed = TRUE)) {
    "type.coding."
  } else {
    ""
  }

  conditions <- character()
  system_match <- regexec("system='([^']+)'", where_expression)
  system_parts <- regmatches(where_expression, system_match)[[1]]
  if (length(system_parts) > 0) {
    conditions <- c(
      conditions,
      paste0(coding_prefix, "system == ", quoteRuleValue(system_parts[2]))
    )
  }

  code_matches <- gregexpr("code='([^']+)'", where_expression, perl = TRUE)
  code_values <- regmatches(where_expression, code_matches)[[1]]
  if (length(code_values) > 0 && !identical(code_values, character(0))) {
    code_values <- sub("^code='", "", code_values)
    code_values <- sub("'$", "", code_values)
    if (length(code_values) == 1) {
      conditions <- c(
        conditions,
        paste0(coding_prefix, "code == ", quoteRuleValue(code_values))
      )
    } else {
      conditions <- c(
        conditions,
        paste0(
          coding_prefix,
          "code in [",
          paste(vapply(code_values, quoteRuleValue, character(1)), collapse = ", "),
          "]"
        )
      )
    }
  }

  if (length(conditions) == 0) {
    return(NA_character_)
  }
  paste(conditions, collapse = " & ")
}

findMatchingParen <- function(text, open_pos) {
  chars <- strsplit(text, "", fixed = TRUE)[[1]]
  depth <- 0L
  in_quotes <- FALSE
  quote_char <- ""

  for (pos in seq.int(open_pos, length(chars))) {
    char <- chars[pos]
    if (char %in% c("'", "\"")) {
      if (!in_quotes) {
        in_quotes <- TRUE
        quote_char <- char
      } else if (char == quote_char) {
        in_quotes <- FALSE
        quote_char <- ""
      }
    }
    if (in_quotes) {
      next
    }
    if (char == "(") {
      depth <- depth + 1L
    } else if (char == ")") {
      depth <- depth - 1L
      if (depth == 0L) {
        return(pos)
      }
    }
  }

  NA_integer_
}

parseWhereSuffix <- function(suffix) {
  if (is.na(suffix) || !nzchar(suffix) || !grepl("where\\(", suffix)) {
    return(list(suffix = suffix, condition = NA_character_))
  }

  where_match <- regexpr("where\\(", suffix)
  where_pos <- as.integer(where_match[1])
  open_pos <- where_pos + nchar("where")
  close_pos <- findMatchingParen(suffix, open_pos)
  if (is.na(close_pos)) {
    return(list(suffix = suffix, condition = NA_character_))
  }

  prefix <- substring(suffix, 1, where_pos - 1L)
  prefix <- sub("\\.$", "", prefix)
  where_expression <- substring(suffix, open_pos + 1L, close_pos - 1L)
  suffix_after_where <- substring(suffix, close_pos + 1L)
  suffix_after_where <- sub("^\\.", "", suffix_after_where)

  rule_suffix <- paste(c(prefix, suffix_after_where)[nzchar(c(prefix, suffix_after_where))],
    collapse = "."
  )
  if (!nzchar(rule_suffix)) {
    rule_suffix <- NA_character_
  }

  list(
    suffix = rule_suffix,
    condition = conditionTextFromFhirWhere(where_expression)
  )
}

ruleTextFromYamlRule <- function(rule, condition = NA_character_) {
  method <- rule$method
  if (is.null(method) || is.na(method) || !nzchar(method)) {
    return(NA_character_)
  }

  condition <- as.character(condition)[1]
  has_condition <- !is.na(condition) && nzchar(condition)

  if (method == "pseudonymize") {
    domain <- rule$domain
    domain_text <- if (is.null(domain) || is.na(domain) || !nzchar(domain)) {
      "domain = \"default\""
    } else {
      paste0("domain = ", quoteRuleValue(domain))
    }
    if (has_condition) {
      return(paste0("pseudonymize(", domain_text, "; ", condition, ")"))
    }
    return(paste0("pseudonymize(", domain_text, ")"))
  }

  if (method == "cryptoHash") {
    max_length <- rule$truncateToMaxLength
    args <- character()
    if (
      !is.null(max_length) && !is.na(max_length) && nzchar(as.character(max_length)) &&
      as.integer(max_length) != 32L
    ) {
      args <- c(args, paste0("maxLength = ", as.integer(max_length)))
    }
    if (has_condition) {
      args <- c(args, condition)
    }
    if (length(args) > 0) {
      return(paste0("cryptoHash(", paste(args, collapse = "; "), ")"))
    }
    return("cryptoHash")
  }

  if (method == "keep" && has_condition) {
    return(paste0("keepIf(", condition, ")"))
  }

  if (method == "redact" && has_condition) {
    return(paste0("redactIf(", condition, ")"))
  }

  if (method == "pseudonymize") {
    domain <- rule$domain
    if (is.null(domain) || is.na(domain) || !nzchar(domain)) {
      return("pseudonymize")
    }
    return(paste0("pseudonymize(domain = ", quoteRuleValue(domain), ")"))
  }

  if (method == "generalize") {
    format <- generalizationFormatFromYamlRule(rule)
    if (!is.na(format)) {
      if (has_condition) {
        return(paste0("generalize(format = ", quoteRuleValue(format), "; ", condition, ")"))
      }
      return(paste0("generalize(format = ", quoteRuleValue(format), ")"))
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

  where_suffix <- parseWhereSuffix(suffix)

  list(
    type = parts[2],
    suffix = where_suffix$suffix,
    condition = where_suffix$condition
  )
}

nodeTypeMatches <- function(node_type, fhir_expression) {
  expression <- tolower(fhir_expression)
  switch(node_type,
    "Address" = grepl("(^|/)address(/|$)", expression),
    "Identifier" = grepl("(^|/)identifier(/|$)", expression),
    "Reference" = grepl(
      "(^|/)reference$|(^|/)reference(/|$)|(^|/)calculated_ref$|(^|/)calculated/ref$",
      expression
    ),
    "HumanName" = grepl("(^|/)name(/|$)", expression),
    "ContactPoint" = grepl("(^|/)telecom(/|$)", expression),
    "Annotation" = grepl("(^|/)annotation(/|$)|(^|/)note(/|$)", expression),
    "Age" = grepl("(^|/)age(/|$)", expression),
    "Narrative" = expression == "text",
    "base64Binary" = FALSE,
    FALSE
  )
}

getFhirNodeTypePrefixes <- function(node_type_paths, node_type) {
  if (is.na(node_type_paths) || !nzchar(node_type_paths)) {
    return(character())
  }

  entries <- strsplit(node_type_paths, "|", fixed = TRUE)[[1]]
  prefix <- paste0(tolower(node_type), "=")
  matching_entries <- entries[startsWith(tolower(entries), prefix)]
  sub("^[^=]*=", "", matching_entries)
}

provenanceNodeTypeMatches <- function(node_rule, table_description) {
  provenance_col <- "FHIR_NODE_TYPE_PATHS"
  if (!(provenance_col %in% names(table_description))) {
    return(NULL)
  }

  prefixes_by_row <- lapply(
    table_description[[provenance_col]],
    getFhirNodeTypePrefixes,
    node_type = node_rule$type
  )
  if (!any(lengths(prefixes_by_row) > 0)) {
    return(NULL)
  }

  suffix <- node_rule$suffix
  if (!is.na(suffix)) {
    suffix <- normalizeFhirPathExpression(suffix)
  }
  expression <- tolower(as.character(table_description[["FHIR_EXPRESSION"]]))

  vapply(seq_along(expression), function(row_index) {
    prefixes <- tolower(prefixes_by_row[[row_index]])
    if (length(prefixes) == 0) {
      return(FALSE)
    }
    if (is.na(suffix)) {
      return(TRUE)
    }
    target_expressions <- ifelse(
      nzchar(prefixes),
      paste0(prefixes, "/", tolower(suffix)),
      tolower(suffix)
    )
    any(expression[row_index] == target_expressions)
  }, logical(1))
}

isCalculatedReferenceExpression <- function(fhir_expression) {
  grepl(
    "(^|/)calculated_ref$|(^|/)calculated/ref$",
    tolower(fhir_expression)
  )
}

buildRuleMatchTable <- function(row_index, match_type = "direct", condition = NA_character_) {
  if (length(row_index) == 0) {
    return(data.table::data.table(
      row_index = integer(),
      match_type = character(),
      condition = character()
    ))
  }

  data.table::data.table(
    row_index = row_index,
    match_type = match_type,
    condition = rep(condition, length(row_index))
  )
}

getReferenceNodePrefixes <- function(fhir_expression) {
  expression <- as.character(fhir_expression)
  reference_expressions <- expression[grepl("(^|/)reference$", expression)]
  calculated_underscore_expressions <- expression[grepl("(^|/)calculated_ref$", expression)]
  calculated_path_expressions <- expression[grepl("(^|/)calculated/ref$", expression)]

  unique(c(
    sub("reference$", "", reference_expressions),
    sub("calculated_ref$", "", calculated_underscore_expressions),
    sub("calculated/ref$", "", calculated_path_expressions)
  ))
}

startsWithAny <- function(values, prefixes) {
  if (length(prefixes) == 0) {
    return(rep(FALSE, length(values)))
  }
  Reduce(`|`, lapply(prefixes, function(prefix) startsWith(values, prefix)))
}

appendReferenceSuffix <- function(prefixes, suffix) {
  if (length(prefixes) == 0) {
    return(character())
  }
  paste0(prefixes, suffix)
}

referenceSuffixMatches <- function(fhir_expression, suffix) {
  expression <- as.character(fhir_expression)
  prefixes <- getReferenceNodePrefixes(expression)
  if (!is.na(suffix)) {
    suffix <- normalizeFhirPathExpression(suffix)
  }

  if (is.na(suffix)) {
    return(startsWithAny(expression, prefixes))
  }
  if (suffix == "reference") {
    return(grepl("(^|/)reference$|(^|/)calculated_ref$|(^|/)calculated/ref$", expression))
  }
  if (suffix == "identifier") {
    return(
      startsWithAny(expression, appendReferenceSuffix(prefixes, "identifier/")) |
        expression %in% appendReferenceSuffix(prefixes, "identifier")
    )
  }

  expression %in% appendReferenceSuffix(prefixes, suffix)
}

nodesByTypeRuleMatches <- function(node_rule, table_description) {
  if (node_rule$type == "Reference") {
    type_matches <- referenceSuffixMatches(table_description$FHIR_EXPRESSION, node_rule$suffix)
    rows <- which(type_matches)
    match_type <- rep("direct", length(rows))
    match_type[isCalculatedReferenceExpression(table_description$FHIR_EXPRESSION[rows])] <-
      "calculatedReferenceAlias"
    return(buildRuleMatchTable(rows, match_type, node_rule$condition))
  }

  type_matches <- provenanceNodeTypeMatches(node_rule, table_description)
  uses_provenance <- !is.null(type_matches)
  if (!uses_provenance) {
    type_matches <- nodeTypeMatches(node_rule$type, table_description$FHIR_EXPRESSION)
  }
  match_type <- rep("direct", length(type_matches))
  if (!uses_provenance && !is.na(node_rule$suffix)) {
    suffix <- normalizeFhirPathExpression(node_rule$suffix)
    suffix <- sub("^where\\(.+\\)\\.", "", suffix)
    suffix_matches <- grepl(
      paste0("(^|/)", suffix, "$"),
      table_description$FHIR_EXPRESSION
    )
    type_matches <- type_matches & suffix_matches
  }
  rows <- which(type_matches)
  buildRuleMatchTable(rows, match_type[rows], node_rule$condition)
}

specificPathRuleMatches <- function(path, table_description) {
  if (!grepl("^[^.]+\\.", path)) {
    return(buildRuleMatchTable(integer()))
  }

  resource <- sub("\\..*$", "", path)
  expression <- sub("^[^.]+\\.", "", path)
  expression <- normalizeFhirPathExpression(expression)

  buildRuleMatchTable(which(
    table_description$RESOURCE_FILLED == resource &
      table_description$FHIR_EXPRESSION == expression
  ))
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
    return(buildRuleMatchTable(which(table_description$FHIR_EXPRESSION == expression)))
  }

  specificPathRuleMatches(path, table_description)
}

buildFhirPseudonymizationCandidates <- function(table_description, yaml_rules) {
  candidates <- data.table::data.table(
    row_index = integer(),
    rule_index = integer(),
    yaml_path = character(),
    pseudonymization_rule = character(),
    match_type = character(),
    condition = character()
  )

  for (rule_index in seq_along(yaml_rules)) {
    rule <- yaml_rules[[rule_index]]
    matched_rows <- matchYamlRuleToTableDescription(rule, table_description)
    if (nrow(matched_rows) == 0) {
      next
    }

    candidates <- data.table::rbindlist(list(
      candidates,
      data.table::data.table(
        row_index = matched_rows$row_index,
        rule_index = rule_index,
        yaml_path = rule$path,
        pseudonymization_rule = vapply(
          matched_rows$condition,
          function(condition) ruleTextFromYamlRule(rule, condition),
          character(1)
        ),
        match_type = matched_rows$match_type,
        condition = matched_rows$condition
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

isConditionalRedactRule <- function(rule_text) {
  grepl("^redactIf\\(", trimws(rule_text))
}

keepFirstRulePerCondition <- function(candidates) {
  condition <- candidates[["condition"]]
  if (length(condition) == 0) {
    return(candidates)
  }

  condition_key <- ifelse(is.na(condition) | !nzchar(condition), NA_character_, condition)
  candidates[!duplicated(condition_key), , drop = FALSE]
}

selectPseudonymizationCandidates <- function(candidates) {
  if (nrow(candidates) == 0) {
    return(candidates)
  }

  candidates <- candidates[order(
    candidates[["row_index"]],
    candidates[["rule_index"]]
  ), ]
  data.table::rbindlist(lapply(
    split(candidates, candidates[["row_index"]]),
    function(row_candidates) {
      row_candidates <- data.table::as.data.table(row_candidates)
      rule_text <- row_candidates[["pseudonymization_rule"]]
      conditional <- row_candidates[
        grepl("If\\(", rule_text) |
          grepl("; .+\\)", rule_text), ,
        drop = FALSE
      ]
      if (nrow(conditional) > 0) {
        selected <- conditional[order(as.vector(conditional[["rule_index"]])), , drop = FALSE]
        positive <- selected[
          !isConditionalRedactRule(selected[["pseudonymization_rule"]]), ,
          drop = FALSE
        ]
        if (nrow(positive) == 0) {
          selected <- keepFirstRulePerCondition(selected)
          return(data.table::data.table(
            row_index = selected$row_index[1],
            rule_index = selected$rule_index[1],
            yaml_path = paste(selected$yaml_path, collapse = " | "),
            pseudonymization_rule = paste0(
              paste(selected$pseudonymization_rule, collapse = "; "),
              "; keep"
            ),
            match_type = paste(unique(selected$match_type), collapse = " | "),
            condition = paste(unique(stats::na.omit(selected$condition)), collapse = " | ")
          ))
        }
        selected <- positive
        selected <- keepFirstRulePerCondition(selected)
        return(data.table::data.table(
          row_index = selected$row_index[1],
          rule_index = selected$rule_index[1],
          yaml_path = paste(selected$yaml_path, collapse = " | "),
          pseudonymization_rule = paste0(
            paste(selected$pseudonymization_rule, collapse = "; "),
            "; redact"
          ),
          match_type = paste(unique(selected$match_type), collapse = " | "),
          condition = paste(unique(stats::na.omit(selected$condition)), collapse = " | ")
        ))
      }

      row_candidates[1, , drop = FALSE]
    }
  ), use.names = TRUE)
}

getOverriddenPseudonymizationCandidates <- function(candidates, selected) {
  if (nrow(candidates) == 0) {
    return(candidates)
  }

  selected_keys <- paste(selected$row_index, selected$rule_index, sep = "\r")
  candidate_keys <- paste(candidates$row_index, candidates$rule_index, sep = "\r")
  candidates[!(candidate_keys %in% selected_keys), ]
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
  rule[is.na(rule) | !nzchar(rule)] <- "<empty>"
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
#' `selected_rules`, `overridden_rules`, `conflicts`, and `candidates`.
getFhirPseudonymizationRuleReport <- function(table_description) {
  candidates <- attr(table_description, "pseudonymization_candidates")
  selected <- attr(table_description, "pseudonymization_selected")
  conflicts <- attr(table_description, "pseudonymization_conflicts")
  yaml_rule_matches <- attr(table_description, "pseudonymization_yaml_rule_matches")

  overridden <- attr(table_description, "pseudonymization_overridden")

  if (
    is.null(candidates) || is.null(selected) || is.null(overridden) || is.null(conflicts) ||
    is.null(yaml_rule_matches)
  ) {
    stop("table_description must be processed with setFhirPseudonymizationRules() first.")
  }

  list(
    summary = getRuleSummary(table_description),
    yaml_rules = yaml_rule_matches,
    unmatched_table_rows = getUnmatchedTableDescriptionRows(table_description, candidates),
    selected_rules = withTableDescriptionContext(selected, table_description),
    overridden_rules = withTableDescriptionContext(
      attr(table_description, "pseudonymization_overridden"),
      table_description
    ),
    conflicts = withTableDescriptionContext(conflicts, table_description),
    candidates = withTableDescriptionContext(candidates, table_description)
  )
}

extractFhirPathRulesFromYaml <- function(yaml_config) {
  if (!is.null(yaml_config$fhirPathRules)) {
    return(yaml_config$fhirPathRules)
  }

  is_rule <- vapply(
    yaml_config,
    function(entry) is.list(entry) && !is.null(entry$path) && !is.null(entry$method),
    logical(1)
  )
  if (length(is_rule) > 0 && all(is_rule)) {
    return(yaml_config)
  }

  NULL
}

#' Add Pseudonymization Rules to a FHIR Table Description
#'
#' Adds a `PSEUDONYMIZATION_RULE` column to an expanded FHIR table description.
#' Rules are derived from a FHIR pseudonymizer YAML file. Column rows without
#' any match receive an explicit `keep` rule, which represents the YAML default
#' of leaving unmatched values unchanged. Structural rows remain empty.
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
  table_description <- data.table::as.data.table(data.table::copy(table_description))
  if (!all(c("RESOURCE", "COLUMN_NAME", "FHIR_EXPRESSION") %in% names(table_description))) {
    stop("table_description must contain RESOURCE, COLUMN_NAME, and FHIR_EXPRESSION columns.")
  }

  yaml_config <- yaml::read_yaml(yaml_path)
  yaml_rules <- extractFhirPathRulesFromYaml(yaml_config)
  if (is.null(yaml_rules) || length(yaml_rules) == 0) {
    stop("YAML file does not contain fhirPathRules or a top-level rule list.")
  }

  table_description[["RESOURCE_FILLED"]] <- table_description[["RESOURCE"]]
  etlutils::fillNAWithLastRowValue(table_description, "RESOURCE_FILLED")
  candidates <- buildFhirPseudonymizationCandidates(table_description, yaml_rules)
  selected <- selectPseudonymizationCandidates(candidates)
  overridden <- getOverriddenPseudonymizationCandidates(candidates, selected)
  yaml_rule_matches <- buildFhirYamlRuleMatches(yaml_rules, candidates)

  selected_rules <- rep(NA_character_, nrow(table_description))
  column_rows <- !is.na(table_description[["COLUMN_NAME"]]) &
    nzchar(trimws(table_description[["COLUMN_NAME"]]))
  selected_rules[column_rows] <- "keep"
  if (nrow(selected) > 0) {
    selected_rules[selected[["row_index"]]] <- selected[["pseudonymization_rule"]]
  }
  table_description[[PSEUDONYMIZATION_RULE_COLNAME]] <- selected_rules

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
  attr(table_description, "pseudonymization_overridden") <- overridden
  attr(table_description, "pseudonymization_conflicts") <- conflicts
  attr(table_description, "pseudonymization_yaml_rule_matches") <- yaml_rule_matches
  table_description
}
