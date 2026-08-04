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
PSEUDONYM_MAPPING_FILE_NAME <- "pseudo_mapping.xlsx"
PSEUDONYM_MAPPING_KEY_COLNAME <- "KEY"
PSEUDONYM_MAPPING_VALUE_COLNAME <- "PSEUDONYM"

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
  if (
    parsed_rule$action == "pseudonym" && length(conditions) > 0 &&
    grepl("^\".*\"$", conditions[1])
  ) {
    conditions <- conditions[-1]
  }
  conditions <- conditions[!grepl("^\\d+$", conditions)]
  conditions <- conditions[nzchar(conditions)]
  if (length(conditions) == 0) {
    return(NA_character_)
  }
  paste(conditions, collapse = "; ")
}

getTableDescriptionTableColumn <- function(table_description) {
  if ("TABLE_OR_RESOURCE" %in% names(table_description)) {
    return("TABLE_OR_RESOURCE")
  }
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

pseudonymizationHash <- function(values, max_length = NA_integer_) {
  values_chr <- as.character(values)
  result <- rep(NA_character_, length(values_chr))
  has_value <- !is.na(values_chr)
  result[has_value] <- vapply(
    values_chr[has_value],
    function(value) {
      digest::digest(
        value,
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

isFhirReferenceExpression <- function(fhir_expression) {
  expression <- as.character(fhir_expression)
  if (is.na(expression) || !nzchar(expression)) {
    return(FALSE)
  }
  grepl("(^|/)reference$|(^|/)calculated_ref$|(^|/)calculated/ref$", expression)
}

pseudonymizationHashReference <- function(values, max_length = NA_integer_) {
  values_chr <- as.character(values)
  result <- rep(NA_character_, length(values_chr))
  has_value <- !is.na(values_chr)
  if (!any(has_value)) {
    return(result)
  }

  relative_reference_match <- regexec("^([A-Za-z][A-Za-z0-9]*/)(.+)$", values_chr[has_value])
  reference_parts <- regmatches(values_chr[has_value], relative_reference_match)
  result[has_value] <- vapply(seq_along(reference_parts), function(i) {
    parts <- reference_parts[[i]]
    value <- values_chr[has_value][i]
    if (length(parts) < 3) {
      return(pseudonymizationHash(value, max_length = max_length))
    }
    paste0(
      parts[2],
      pseudonymizationHash(parts[3], max_length = max_length)
    )
  }, character(1))
  result
}

getPseudonymMappingFilePath <- function(input_repo_path) {
  if (is.null(input_repo_path) || is.na(input_repo_path) || !nzchar(input_repo_path)) {
    stop("input_repo_path must be provided for pseudonym(sheet = ...) rules.")
  }
  file.path(input_repo_path, PSEUDONYM_MAPPING_FILE_NAME)
}

loadPseudonymMappingSheet <- function(input_repo_path, sheet_name) {
  mapping_file_path <- getPseudonymMappingFilePath(input_repo_path)
  if (!file.exists(mapping_file_path)) {
    stop("Pseudonym mapping file not found: ", mapping_file_path)
  }

  mapping_sheets <- etlutils::readExcelFileAsTableList(mapping_file_path)
  if (!sheet_name %in% names(mapping_sheets)) {
    stop(
      "Pseudonym mapping sheet not found: ", sheet_name,
      " in ", mapping_file_path
    )
  }

  mapping <- data.table::as.data.table(mapping_sheets[[sheet_name]])
  required_columns <- c(PSEUDONYM_MAPPING_KEY_COLNAME, PSEUDONYM_MAPPING_VALUE_COLNAME)
  mapping <- etlutils::removeTableHeader(mapping, required_columns)
  mapping <- as.data.frame(mapping, stringsAsFactors = FALSE)
  if (!all(required_columns %in% names(mapping))) {
    stop(
      "Pseudonym mapping sheet must contain columns: ",
      paste(required_columns, collapse = ", "),
      ". Sheet: ", sheet_name
    )
  }

  mapping <- mapping[
    !(is.na(mapping[[PSEUDONYM_MAPPING_KEY_COLNAME]]) &
      is.na(mapping[[PSEUDONYM_MAPPING_VALUE_COLNAME]])), ,
    drop = FALSE
  ]
  empty_key_rows <- is.na(mapping[[PSEUDONYM_MAPPING_KEY_COLNAME]]) |
    !nzchar(trimws(as.character(mapping[[PSEUDONYM_MAPPING_KEY_COLNAME]])))
  empty_value_rows <- is.na(mapping[[PSEUDONYM_MAPPING_VALUE_COLNAME]]) |
    !nzchar(trimws(as.character(mapping[[PSEUDONYM_MAPPING_VALUE_COLNAME]])))
  if (any(empty_key_rows | empty_value_rows)) {
    stop(
      "Pseudonym mapping sheet contains empty KEY or PSEUDONYM values. Sheet: ",
      sheet_name
    )
  }

  mapping[[PSEUDONYM_MAPPING_KEY_COLNAME]] <-
    as.character(mapping[[PSEUDONYM_MAPPING_KEY_COLNAME]])
  mapping[[PSEUDONYM_MAPPING_VALUE_COLNAME]] <-
    as.character(mapping[[PSEUDONYM_MAPPING_VALUE_COLNAME]])

  duplicated_keys <- unique(mapping[[PSEUDONYM_MAPPING_KEY_COLNAME]][
    duplicated(mapping[[PSEUDONYM_MAPPING_KEY_COLNAME]]) |
      duplicated(mapping[[PSEUDONYM_MAPPING_KEY_COLNAME]], fromLast = TRUE)
  ])
  if (length(duplicated_keys) > 0) {
    stop(
      "Pseudonym mapping sheet contains duplicate KEY values. Sheet: ",
      sheet_name,
      ". Duplicate keys: ",
      paste(duplicated_keys, collapse = ", ")
    )
  }

  data.table::as.data.table(mapping[, required_columns, drop = FALSE])
}

getPseudonymMappingSheet <- function(mapping_context, sheet_name) {
  if (is.null(mapping_context)) {
    stop("mapping_context must be provided for pseudonym(sheet = ...) rules.")
  }
  if (is.null(mapping_context$cache[[sheet_name]])) {
    mapping_context$cache[[sheet_name]] <- loadPseudonymMappingSheet(
      mapping_context$input_repo_path,
      sheet_name
    )
  }
  mapping_context$cache[[sheet_name]]
}

newPseudonymMappingContext <- function(input_repo_path) {
  mapping_context <- new.env(parent = emptyenv())
  mapping_context$input_repo_path <- input_repo_path
  mapping_context$cache <- new.env(parent = emptyenv())
  mapping_context$missing <- list()
  mapping_context
}

recordMissingPseudonymMappingValues <- function(mapping_context, sheet_name, column_name, values) {
  if (is.null(mapping_context) || length(values) == 0) {
    return(invisible())
  }
  mapping_context$missing[[length(mapping_context$missing) + 1L]] <- data.table::data.table(
    SHEET_NAME = sheet_name,
    COLUMN_NAME = column_name,
    KEY = sort(unique(as.character(values)))
  )
}

assertNoMissingPseudonymMappingValues <- function(mapping_context) {
  if (is.null(mapping_context) || length(mapping_context$missing) == 0) {
    return(invisible())
  }
  missing_values <- data.table::rbindlist(mapping_context$missing)
  missing_values <- unique(missing_values)
  data.table::setorder(missing_values, SHEET_NAME, COLUMN_NAME, KEY)
  details <- paste(
    apply(missing_values, 1, function(row) {
      paste0(
        "sheet=", row[["SHEET_NAME"]],
        ", column=", row[["COLUMN_NAME"]],
        ", key=", row[["KEY"]]
      )
    }),
    collapse = "\n"
  )
  stop(
    "Missing pseudonym mapping values in ",
    PSEUDONYM_MAPPING_FILE_NAME,
    ":\n",
    details
  )
}

splitPseudonymMappingValues <- function(values) {
  values_chr <- as.character(values)
  values_chr <- values_chr[!is.na(values_chr)]
  unlist(
    strsplit(values_chr, "\r\n|\r|\n", perl = TRUE),
    use.names = FALSE
  )
}

applyPseudonymMapping <- function(values, sheet_name, column_name, mapping_context) {
  mapping <- getPseudonymMappingSheet(mapping_context, sheet_name)
  values_chr <- as.character(values)
  result <- rep(NA_character_, length(values_chr))
  has_value <- !is.na(values_chr)
  value_parts <- lapply(
    values_chr[has_value],
    splitPseudonymMappingValues
  )
  match_indices <- lapply(
    value_parts,
    match,
    table = mapping[[PSEUDONYM_MAPPING_KEY_COLNAME]]
  )
  missing_values <- unlist(
    Map(
      function(parts, match_index) parts[is.na(match_index)],
      value_parts,
      match_indices
    ),
    use.names = FALSE
  )
  recordMissingPseudonymMappingValues(
    mapping_context,
    sheet_name,
    column_name,
    missing_values
  )
  result[has_value] <- vapply(
    match_indices,
    function(match_index) {
      if (anyNA(match_index)) {
        return(NA_character_)
      }
      paste(
        mapping[[PSEUDONYM_MAPPING_VALUE_COLNAME]][match_index],
        collapse = "\n"
      )
    },
    character(1)
  )
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

applyHashRuleToVector <- function(
  values,
  max_length = NA_integer_,
  fhir_expression = NA_character_
) {
  if (isFhirReferenceExpression(fhir_expression)) {
    return(pseudonymizationHashReference(
      values,
      max_length = max_length
    ))
  }
  pseudonymizationHash(values, max_length = max_length)
}

applyPseudonymizationRuleToVector <- function(
  values,
  rule,
  column_name = NA_character_,
  mapping_context = NULL,
  fhir_expression = NA_character_
) {
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
    if (
      is.na(max_length) && length(parsed_rule$arguments) > 0 &&
      grepl("^\\d+$", parsed_rule$arguments[1])
    ) {
      max_length <- as.integer(parsed_rule$arguments[1])
    }
    if (is.na(max_length)) {
      max_length <- DEFAULT_CRYPTO_HASH_MAX_LENGTH
    }
    return(applyHashRuleToVector(
      values,
      max_length = max_length,
      fhir_expression = fhir_expression
    ))
  }
  if (action == "pseudonymize") {
    max_length <- suppressWarnings(as.integer(getRuleArgument(parsed_rule, "maxLength")))
    if (
      is.na(max_length) && length(parsed_rule$arguments) > 0 &&
      grepl("^\\d+$", parsed_rule$arguments[1])
    ) {
      max_length <- as.integer(parsed_rule$arguments[1])
    }
    if (is.na(max_length)) {
      max_length <- DEFAULT_CRYPTO_HASH_MAX_LENGTH
    }
    return(applyHashRuleToVector(
      values,
      max_length = max_length,
      fhir_expression = fhir_expression
    ))
  }
  if (action == "pseudonym") {
    sheet_name <- getRuleArgument(parsed_rule, "sheet")
    if (is.na(sheet_name) || !nzchar(sheet_name)) {
      sheet_name <- stripRuleQuotes(parsed_rule$arguments[1])
    }
    if (is.na(sheet_name) || !nzchar(sheet_name)) {
      stop("pseudonym(...) rules require a sheet argument.")
    }
    return(applyPseudonymMapping(values, sheet_name, column_name, mapping_context))
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

applyRuleListToColumn <- function(table, source_table, column_name, fhir_expression, rule, table_description, mapping_context = NULL) {
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
    rows[is.na(rows)] <- FALSE
    if (any(rows)) {
      result[rows] <- applyPseudonymizationRuleToVector(
        table[[column_name]][rows],
        single_rule,
        column_name = column_name,
        mapping_context = mapping_context,
        fhir_expression = fhir_expression
      )
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
#' `pseudonymize(...)` is executed as an alias of `cryptoHash`; the optional
#' `domain` argument remains a readable table-description annotation but does
#' not change the generated hash.
#'
#' @param table A `data.table` or `data.frame` containing the source data.
#' @param table_description Table description containing `COLUMN_NAME` and
#' `PSEUDONYMIZATION_RULE`. It may use either `RESOURCE` or `TABLE_NAME` to
#' group rows by table.
#' @param table_name Optional table/resource name used to filter
#' `table_description` before applying the rules.
#' @param input_repo_path Path to the TOML-configured input repository directory
#'   for the pseudonymization run. If `pseudonym(sheet = ...)` rules are used,
#'   `<input_repo_path>/pseudo_mapping.xlsx` is read and the `sheet` argument
#'   selects the mapping sheet.
#' @param mapping_context Optional reusable pseudonym-mapping cache. This is
#'   primarily used by incremental snapshot processing so mapping sheets are
#'   loaded once across chunks.
#'
#' @return A pseudonymized copy of `table`.
pseudonymizeTable <- function(
  table,
  table_description,
  table_name = NULL,
  input_repo_path = NULL,
  mapping_context = NULL
) {
  table <- data.table::as.data.table(data.table::copy(table))
  source_table <- data.table::copy(table)
  column_rules <- getPseudonymizationColumnRules(table_description, table_name)
  if (is.null(mapping_context)) {
    mapping_context <- newPseudonymMappingContext(input_repo_path)
  }

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
      mapping_context = mapping_context
    )
  }

  assertNoMissingPseudonymMappingValues(mapping_context)
  table
}

runPseudonymizationLogStep <- function(level = 2L, message, process, log_steps = TRUE) {
  process_clock <- try(etlutils::getClock(), silent = TRUE)
  logging_available <- exists("VERBOSE", envir = .GlobalEnv) &&
    !inherits(process_clock, "try-error") &&
    !is.null(process_clock)
  if (!isTRUE(log_steps) || !logging_available) {
    return(force(process))
  }
  if (level == 3L) {
    return(etlutils::runLevel3Line(message, {
      force(process)
    }))
  }
  etlutils::runLevel2(message, {
    force(process)
  })
}

normalizePseudonymizationRulesForTables <- function(rules) {
  rules <- data.table::as.data.table(data.table::copy(rules))
  if (!"TABLE_OR_RESOURCE" %in% names(rules)) {
    table_column <- getTableDescriptionTableColumn(rules)
    rules[["TABLE_OR_RESOURCE"]] <- rules[[table_column]]
    etlutils::fillNAWithLastRowValue(rules, "TABLE_OR_RESOURCE")
  }
  rules <- rules[
    !is.na(rules[["TABLE_OR_RESOURCE"]]) &
      nzchar(rules[["TABLE_OR_RESOURCE"]]) &
      !is.na(rules[["COLUMN_NAME"]]) &
      nzchar(rules[["COLUMN_NAME"]]),
  ]
  rules
}

getPseudonymizationRulesForTable <- function(rules, table_name, source = NULL) {
  rules <- normalizePseudonymizationRulesForTables(rules)
  table_rules <- rules[tolower(rules[["TABLE_OR_RESOURCE"]]) == tolower(table_name), ]
  if (!is.null(source) && !is.na(source) && nzchar(source) && "SOURCE" %in% names(table_rules)) {
    is_snapshot_extension <- "SOURCE_TYPE" %in% names(table_rules) &
      table_rules[["SOURCE_TYPE"]] == "snapshot_extension"
    source_matches <- table_rules[["SOURCE"]] == source
    source_matches[is.na(source_matches)] <- FALSE
    table_rules <- table_rules[source_matches | is_snapshot_extension, ]
  }
  table_rules
}

pseudonymizeTableForSnapshot <- function(
  table,
  rules,
  table_name,
  rule_source = NULL,
  input_repo_path,
  mapping_context = NULL
) {
  table_rules <- getPseudonymizationRulesForTable(rules, table_name, source = rule_source)
  described_columns <- unique(table_rules[["COLUMN_NAME"]])
  missing_columns <- described_columns[!(described_columns %in% names(table))]

  result <- pseudonymizeTable(
    table,
    table_rules,
    table_name = table_name,
    input_repo_path = input_repo_path,
    mapping_context = mapping_context
  )

  list(
    table = result,
    summary = data.table::data.table(
      TABLE_NAME = table_name,
      INPUT_ROWS = nrow(table),
      OUTPUT_ROWS = nrow(result),
      INPUT_COLUMNS = length(names(table)),
      DESCRIBED_COLUMNS = length(described_columns),
      OUTPUT_COLUMNS = length(names(result)),
      MISSING_COLUMNS = paste(missing_columns, collapse = ", "),
      STATUS = "pseudonymized"
    )
  )
}
