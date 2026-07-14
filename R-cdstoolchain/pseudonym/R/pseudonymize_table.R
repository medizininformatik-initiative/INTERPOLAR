normalizePseudonymizationRule <- function(rule) {
  rule <- trimws(as.character(rule))
  rule <- gsub("_x000D_", "\n", rule, fixed = TRUE)
  rule <- gsub("&#10;", "\n", rule, fixed = TRUE)
  rule[is.na(rule) | !nzchar(rule)] <- "keep"
  rule
}

stripRuleQuotes <- function(value) {
  value <- trimws(value)
  sub("^\"(.*)\"$", "\\1", value)
}

DEFAULT_CRYPTO_HASH_MAX_LENGTH <- 32L

splitRuleList <- function(rule) {
  chars <- strsplit(rule, "", fixed = TRUE)[[1]]
  depth <- 0L
  in_quotes <- FALSE
  current <- character()
  parts <- character()

  for (char in chars) {
    if (char == "\"") {
      in_quotes <- !in_quotes
    }
    if (!in_quotes && char == "(") {
      depth <- depth + 1L
    } else if (!in_quotes && char == ")") {
      depth <- depth - 1L
    }

    if (!in_quotes && depth == 0L && char == ";") {
      parts <- c(parts, paste0(current, collapse = ""))
      current <- character()
    } else {
      current <- c(current, char)
    }
  }

  c(parts, paste0(current, collapse = ""))
}

splitRuleArguments <- function(arguments) {
  chars <- strsplit(arguments, "", fixed = TRUE)[[1]]
  in_quotes <- FALSE
  current <- character()
  parts <- character()

  for (char in chars) {
    if (char == "\"") {
      in_quotes <- !in_quotes
    }

    if (!in_quotes && char == ";") {
      parts <- c(parts, paste0(current, collapse = ""))
      current <- character()
    } else {
      current <- c(current, char)
    }
  }

  trimws(c(parts, paste0(current, collapse = "")))
}

parsePseudonymizationRuleCall <- function(rule) {
  rule <- trimws(rule)
  match <- regexec("^([A-Za-z]+)(?:\\((.*)\\))?$", rule)
  parts <- regmatches(rule, match)[[1]]
  if (length(parts) == 0) {
    stop("Unsupported PSEUDONYMIZATION_RULE: ", rule)
  }

  action <- parts[2]
  arguments <- parts[3]
  if (is.na(arguments)) {
    arguments <- ""
  }

  list(action = action, arguments = splitRuleArguments(arguments))
}

getRuleArgument <- function(parsed_rule, name, default = NA_character_) {
  prefix <- paste0(name, "\\s*=")
  matches <- grep(prefix, parsed_rule$arguments, value = TRUE)
  if (length(matches) == 0) {
    return(default)
  }
  stripRuleQuotes(sub(prefix, "", matches[1]))
}

getRuleCondition <- function(parsed_rule) {
  if (parsed_rule$action %in% c("keepIf", "redactIf")) {
    return(paste(parsed_rule$arguments, collapse = "; "))
  }

  conditions <- parsed_rule$arguments[!grepl("^[A-Za-z]+\\s*=", parsed_rule$arguments)]
  conditions <- conditions[!grepl("^\\d+$", conditions)]
  conditions <- conditions[nzchar(conditions)]
  if (length(conditions) == 0) {
    return(NA_character_)
  }
  paste(conditions, collapse = "; ")
}

getTableDescriptionTableColumn <- function(table_description) {
  if ("TABLE_NAME" %in% names(table_description)) {
    return("TABLE_NAME")
  }
  if ("RESOURCE" %in% names(table_description)) {
    return("RESOURCE")
  }
  stop("table_description must contain TABLE_NAME or RESOURCE.")
}

getPseudonymizationColumnRules <- function(table_description, table_name = NULL) {
  required_columns <- c("COLUMN_NAME", PSEUDONYMIZATION_RULE_COLNAME)
  if (!all(required_columns %in% names(table_description))) {
    stop(
      "table_description must contain columns: ",
      paste(required_columns, collapse = ", ")
    )
  }

  table_description <- data.table::as.data.table(data.table::copy(table_description))
  if (!("FHIR_EXPRESSION" %in% names(table_description))) {
    table_description[["FHIR_EXPRESSION"]] <- NA_character_
  }
  table_column <- getTableDescriptionTableColumn(table_description)
  table_description[["TABLE_OR_RESOURCE_FILLED"]] <- table_description[[table_column]]
  etlutils::fillNAWithLastRowValue(table_description, "TABLE_OR_RESOURCE_FILLED")

  if (!is.null(table_name)) {
    table_description <- table_description[
      tolower(table_description[["TABLE_OR_RESOURCE_FILLED"]]) == tolower(table_name),
    ]
  }

  table_description <- table_description[
    !is.na(table_description[["COLUMN_NAME"]]) &
      nzchar(table_description[["COLUMN_NAME"]]),
    c("COLUMN_NAME", "FHIR_EXPRESSION", PSEUDONYMIZATION_RULE_COLNAME),
    with = FALSE
  ]
  table_description[[PSEUDONYMIZATION_RULE_COLNAME]] <-
    normalizePseudonymizationRule(table_description[[PSEUDONYMIZATION_RULE_COLNAME]])

  column_names <- table_description[["COLUMN_NAME"]]
  duplicated_columns <- unique(column_names[
    duplicated(column_names) | duplicated(column_names, fromLast = TRUE)
  ])
  if (length(duplicated_columns) > 0) {
    stop(
      "table_description contains duplicate COLUMN_NAME values after filtering: ",
      paste(duplicated_columns, collapse = ", ")
    )
  }

  table_description
}

pseudonymizationHash <- function(values, salt, namespace, max_length = NA_integer_) {
  if (is.null(salt) || is.na(salt) || !nzchar(salt)) {
    stop("salt must be provided for cryptoHash and pseudonymize rules.")
  }

  values_chr <- as.character(values)
  result <- rep(NA_character_, length(values_chr))
  has_value <- !is.na(values_chr)
  result[has_value] <- vapply(
    values_chr[has_value],
    function(value) {
      digest::digest(
        paste(namespace, salt, value, sep = "\n"),
        algo = "sha256",
        serialize = FALSE
      )
    },
    character(1)
  )
  if (!is.na(max_length)) {
    result[has_value] <- substr(result[has_value], 1, max_length)
  }
  result
}

redactVector <- function(values) {
  result <- values
  result[] <- NA
  result
}

generalizeDateLikeVector <- function(values, format) {
  if (format == "%Y-%m") {
    if (inherits(values, "Date") || inherits(values, "POSIXt")) {
      return(as.Date(paste0(format(values, "%Y-%m"), "-01")))
    }
  }

  values_chr <- as.character(values)
  result <- rep(NA, length(values_chr))
  has_value <- !is.na(values_chr)

  if (format == "%Y-%m") {
    matches <- regexec("^(\\d{2,4})-(\\d{2})", values_chr[has_value])
    parts <- regmatches(values_chr[has_value], matches)
    result[has_value] <- as.Date(vapply(parts, function(part) {
      if (length(part) >= 3) paste0(part[2], "-", part[3], "-01") else NA_character_
    }, character(1)))
  } else if (format == "%Y") {
    matches <- regexec("^(\\d{2,4})", values_chr[has_value])
    parts <- regmatches(values_chr[has_value], matches)
    result[has_value] <- vapply(parts, function(part) {
      if (length(part) >= 2) part[2] else NA_character_
    }, character(1))
  } else {
    stop("Unsupported date generalization format: ", format)
  }

  result
}

getConditionBaseExpression <- function(fhir_expression) {
  expression <- as.character(fhir_expression)
  if (grepl("(^|/)identifier(/|$)", expression)) {
    return(sub("identifier/.*$", "identifier/", expression))
  }
  ""
}

findConditionColumnName <- function(field_name, fhir_expression, table_description) {
  field_expression <- gsub("\\.", "/", field_name)
  condition_expression <- paste0(getConditionBaseExpression(fhir_expression), field_expression)
  matches <- table_description[["COLUMN_NAME"]][
    !is.na(table_description[["FHIR_EXPRESSION"]]) &
      table_description[["FHIR_EXPRESSION"]] == condition_expression
  ]
  if (length(matches) == 0) {
    return(NA_character_)
  }
  matches[1]
}

evaluateSingleCondition <- function(condition, table, table_description, fhir_expression) {
  condition <- trimws(condition)
  in_match <- regexec("^([A-Za-z0-9_.]+)\\s+in\\s+\\[(.*)\\]$", condition)
  in_parts <- regmatches(condition, in_match)[[1]]
  if (length(in_parts) > 0) {
    column_name <- findConditionColumnName(in_parts[2], fhir_expression, table_description)
    if (is.na(column_name) || !(column_name %in% names(table))) {
      return(rep(FALSE, nrow(table)))
    }
    values <- trimws(strsplit(in_parts[3], ",", fixed = TRUE)[[1]])
    values <- vapply(values, stripRuleQuotes, character(1))
    return(as.character(table[[column_name]]) %in% values)
  }

  equals_match <- regexec("^([A-Za-z0-9_.]+)\\s*==\\s*(.*)$", condition)
  equals_parts <- regmatches(condition, equals_match)[[1]]
  if (length(equals_parts) > 0) {
    column_name <- findConditionColumnName(equals_parts[2], fhir_expression, table_description)
    if (is.na(column_name) || !(column_name %in% names(table))) {
      return(rep(FALSE, nrow(table)))
    }
    value <- stripRuleQuotes(equals_parts[3])
    return(as.character(table[[column_name]]) == value)
  }

  stop("Unsupported PSEUDONYMIZATION_RULE condition: ", condition)
}

evaluateRuleCondition <- function(condition, table, table_description, fhir_expression) {
  if (is.na(condition) || !nzchar(condition)) {
    return(rep(TRUE, nrow(table)))
  }

  parts <- trimws(strsplit(condition, "&", fixed = TRUE)[[1]])
  Reduce(`&`, lapply(parts, evaluateSingleCondition,
    table = table,
    table_description = table_description,
    fhir_expression = fhir_expression
  ))
}

applyPseudonymizationRuleToVector <- function(values, rule, salt = NULL) {
  rule <- normalizePseudonymizationRule(rule)
  parsed_rule <- parsePseudonymizationRuleCall(rule)
  action <- parsed_rule$action
  if (action == "keepIf") action <- "keep"
  if (action == "redactIf") action <- "redact"

  if (action == "keep") {
    return(values)
  }
  if (action == "redact") {
    return(redactVector(values))
  }
  if (action == "cryptoHash") {
    max_length <- suppressWarnings(as.integer(getRuleArgument(parsed_rule, "maxLength")))
    if (is.na(max_length) && length(parsed_rule$arguments) > 0 &&
        grepl("^\\d+$", parsed_rule$arguments[1])) {
      max_length <- as.integer(parsed_rule$arguments[1])
    }
    if (is.na(max_length)) {
      max_length <- DEFAULT_CRYPTO_HASH_MAX_LENGTH
    }
    return(pseudonymizationHash(values, salt, "cryptoHash", max_length = max_length))
  }
  if (action == "pseudonymize") {
    domain <- getRuleArgument(parsed_rule, "domain")
    if (is.na(domain) || !nzchar(domain)) {
      domain <- "pseudonymize"
    }
    return(pseudonymizationHash(values, salt, paste0("pseudonymize:", domain)))
  }
  if (action == "generalize") {
    format <- getRuleArgument(parsed_rule, "format")
    if (is.na(format)) {
      format <- stripRuleQuotes(parsed_rule$arguments[1])
    }
    if (format == "postalCode2") {
      values_chr <- as.character(values)
      result <- substr(values_chr, 1, 2)
      result[is.na(values_chr)] <- NA_character_
      return(result)
    }
    if (format == "YYYY-MM") {
      return(generalizeDateLikeVector(values, "%Y-%m"))
    }
    if (format == "YYYY") {
      return(generalizeDateLikeVector(values, "%Y"))
    }
    return(redactVector(values))
  }

  if (rule == "generalize(postalCode2)") {
    values_chr <- as.character(values)
    result <- substr(values_chr, 1, 2)
    result[is.na(values_chr)] <- NA_character_
    return(result)
  }
  if (rule == "generalize(YYYY-MM)") {
    return(generalizeDateLikeVector(values, "%Y-%m"))
  }
  if (rule == "generalize(YYYY)") {
    return(generalizeDateLikeVector(values, "%Y"))
  }
  if (rule == "generalize") {
    return(redactVector(values))
  }

  stop("Unsupported PSEUDONYMIZATION_RULE: ", rule)
}

applyRuleListToColumn <- function(table, source_table, column_name, fhir_expression, rule, table_description, salt) {
  rule <- normalizePseudonymizationRule(rule)
  rule_list <- trimws(splitRuleList(rule))
  rule_list <- rule_list[nzchar(rule_list)]
  if (length(rule_list) == 0 || identical(rule_list, "keep")) {
    return(table[[column_name]])
  }

  result <- table[[column_name]]
  matched_rows <- rep(FALSE, nrow(table))
  has_conditional_rule <- FALSE

  for (single_rule in rule_list) {
    parsed_rule <- parsePseudonymizationRuleCall(single_rule)
    condition <- getRuleCondition(parsed_rule)
    has_condition <- !is.na(condition) && nzchar(condition)
    if (has_condition) {
      has_conditional_rule <- TRUE
    }
    rows <- evaluateRuleCondition(condition, source_table, table_description, fhir_expression) & !matched_rows
    if (any(rows)) {
      result[rows] <- applyPseudonymizationRuleToVector(table[[column_name]][rows], single_rule, salt)
      matched_rows[rows] <- TRUE
    }
    if (!has_condition) {
      break
    }
  }

  if (has_conditional_rule && any(!matched_rows)) {
    result[!matched_rows] <- redactVector(result[!matched_rows])
  }
  result
}

#' Pseudonymize a Table Using Table Description Rules
#'
#' Applies `PSEUDONYMIZATION_RULE` values from a table description to one
#' `data.table`. Empty or missing rules are treated as `keep`.
#'
#' @param table A `data.table` or `data.frame` containing the source data.
#' @param table_description Table description containing `COLUMN_NAME` and
#' `PSEUDONYMIZATION_RULE`. It may use either `RESOURCE` or `TABLE_NAME` to
#' group rows by table.
#' @param table_name Optional table/resource name used to filter
#' `table_description` before applying the rules.
#' @param salt Salt used for `cryptoHash` and `pseudonymize(...)` rules.
#'
#' @return A pseudonymized copy of `table`.
#' @export
pseudonymizeTable <- function(table, table_description, table_name = NULL, salt = NULL) {
  table <- data.table::as.data.table(data.table::copy(table))
  source_table <- data.table::copy(table)
  column_rules <- getPseudonymizationColumnRules(table_description, table_name)

  for (column_name in names(table)) {
    rule_row <- column_rules[column_rules[["COLUMN_NAME"]] == column_name, ]
    if (nrow(rule_row) > 0) {
      rule <- rule_row[[PSEUDONYMIZATION_RULE_COLNAME]][1]
      fhir_expression <- rule_row[["FHIR_EXPRESSION"]][1]
    } else {
      rule <- "keep"
      fhir_expression <- NA_character_
    }
    table[[column_name]] <- applyRuleListToColumn(
      table,
      source_table,
      column_name,
      fhir_expression,
      rule,
      column_rules,
      salt
    )
  }

  table
}
