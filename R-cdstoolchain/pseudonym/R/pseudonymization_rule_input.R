DEFAULT_SNAPSHOT_EXTENSION_SHEET <- "snapshot_extensions"
DEFAULT_FHIR_TABLE_DESCRIPTION_PATH <- "R-cds2db/cds2db/inst/extdata/Table_Description.xlsx"
DEFAULT_DATAPROCESSOR_TABLE_DESCRIPTION_PATH <-
  "R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx"
DEFAULT_FRONTEND_TABLE_DESCRIPTION_PATH <-
  "R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx"
DEFAULT_FHIR_TABLE_DESCRIPTION_DEFINITION_PATH <-
  "R-cds2db/cds2db/inst/extdata/Table_Description_Definition.xlsx"

emptyRuleSourceSpec <- function() {
  data.table::data.table(
    SOURCE = character(),
    PATH = character(),
    SHEET_NAME = character()
  )
}

#' Get Default INTERPOLAR Snapshot Pseudonymization Rule Sources
#'
#' The defaults collect the rule-bearing table descriptions that are currently
#' relevant for a pseudonymized snapshot: FHIR/CDS tables, Dataprocessor
#' submodule tables, frontend tables, and snapshot-only extensions.
#'
#' @param project_root Repository root used to resolve the default relative
#'   paths.
#'
#' @return A list with `table_descriptions` and `snapshot_extensions` source
#'   specifications suitable for `loadPseudonymizationRules()` and
#'   `pseudonymizeSnapshotTables()`.
#' @export
getDefaultSnapshotPseudonymizationRuleSources <- function(project_root = ".") {
  table_descriptions <- data.table::data.table(
    SOURCE = c("fhir", "dataprocessor_submodules", "frontend"),
    PATH = file.path(
      project_root,
      c(
        DEFAULT_FHIR_TABLE_DESCRIPTION_PATH,
        DEFAULT_DATAPROCESSOR_TABLE_DESCRIPTION_PATH,
        DEFAULT_FRONTEND_TABLE_DESCRIPTION_PATH
      )
    ),
    SHEET_NAME = c("table_description", "table_description", "frontend_table_description")
  )
  snapshot_extensions <- data.table::data.table(
    SOURCE = "snapshot_extensions",
    PATH = file.path(project_root, DEFAULT_FHIR_TABLE_DESCRIPTION_DEFINITION_PATH),
    SHEET_NAME = DEFAULT_SNAPSHOT_EXTENSION_SHEET
  )

  list(
    table_descriptions = table_descriptions,
    snapshot_extensions = snapshot_extensions
  )
}

normalizeRuleSourceSpec <- function(sources, default_sheet_name) {
  if (is.null(sources)) {
    return(emptyRuleSourceSpec())
  }

  if (is.character(sources)) {
    result <- data.table::data.table(
      SOURCE = names(sources),
      PATH = unname(sources),
      SHEET_NAME = default_sheet_name
    )
    missing_source <- is.na(result$SOURCE) | result$SOURCE == ""
    result$SOURCE[missing_source] <- tools::file_path_sans_ext(basename(result$PATH[missing_source]))
    return(result)
  }

  result <- data.table::as.data.table(data.table::copy(sources))
  data.table::setnames(result, names(result), toupper(names(result)))

  if (!"PATH" %in% names(result) && "FILE_PATH" %in% names(result)) {
    data.table::setnames(result, "FILE_PATH", "PATH")
  }
  if (!"SHEET_NAME" %in% names(result) && "SHEET" %in% names(result)) {
    data.table::setnames(result, "SHEET", "SHEET_NAME")
  }
  if (!"SOURCE" %in% names(result) && "NAME" %in% names(result)) {
    data.table::setnames(result, "NAME", "SOURCE")
  }

  if (!"PATH" %in% names(result)) {
    stop("Rule source specifications must contain a PATH or FILE_PATH column.")
  }
  if (!"SOURCE" %in% names(result)) {
    result$SOURCE <- tools::file_path_sans_ext(basename(result$PATH))
  }
  if (!"SHEET_NAME" %in% names(result)) {
    result$SHEET_NAME <- default_sheet_name
  }
  missing_sheet <- is.na(result$SHEET_NAME) | result$SHEET_NAME == ""
  result$SHEET_NAME[missing_sheet] <- default_sheet_name
  missing_source <- is.na(result$SOURCE) | result$SOURCE == ""
  result$SOURCE[missing_source] <- tools::file_path_sans_ext(basename(result$PATH[missing_source]))

  data.table::as.data.table(as.data.frame(result)[
    ,
    c("SOURCE", "PATH", "SHEET_NAME"),
    drop = FALSE
  ])
}

fillTableOrResourceNames <- function(table_description) {
  for (colname in c("TABLE_NAME", "RESOURCE")) {
    if (colname %in% names(table_description)) {
      table_description[[colname]][table_description[[colname]] == ""] <- NA_character_
      table_description <- etlutils::fillNAWithLastRowValue(table_description, columns = colname)
    }
  }
  table_description
}

normalizePseudonymizationRuleInput <- function(table_description, source, path, sheet_name, source_type) {
  table_description <- data.table::as.data.table(data.table::copy(table_description))
  table_description <- fillTableOrResourceNames(table_description)

  if (!"TABLE_NAME" %in% names(table_description)) {
    table_description[["TABLE_NAME"]] <- NA_character_
  }
  if (!"RESOURCE" %in% names(table_description)) {
    table_description[["RESOURCE"]] <- NA_character_
  }
  if (!"COLUMN_TYPE" %in% names(table_description)) {
    table_description[["COLUMN_TYPE"]] <- NA_character_
  }
  if (!"COLUMN_DESCRIPTION" %in% names(table_description)) {
    table_description[["COLUMN_DESCRIPTION"]] <- NA_character_
  }
  if (!"FHIR_EXPRESSION" %in% names(table_description)) {
    table_description[["FHIR_EXPRESSION"]] <- NA_character_
  }
  if (!PSEUDONYMIZATION_RULE_COLNAME %in% names(table_description)) {
    table_description[[PSEUDONYMIZATION_RULE_COLNAME]] <- NA_character_
  }
  keep_rows <-
    !is.na(table_description[["COLUMN_NAME"]]) &
      table_description[["COLUMN_NAME"]] != "" &
      (!is.na(table_description[["TABLE_NAME"]]) | !is.na(table_description[["RESOURCE"]]))
  table_description <- table_description[keep_rows, , drop = FALSE]

  table_description[["TABLE_OR_RESOURCE"]] <- data.table::fifelse(
    !is.na(table_description[["TABLE_NAME"]]) & table_description[["TABLE_NAME"]] != "",
    table_description[["TABLE_NAME"]],
    table_description[["RESOURCE"]]
  )
  table_description[["PSEUDONYMIZATION_RULE_RAW"]] <-
    table_description[[PSEUDONYMIZATION_RULE_COLNAME]]
  table_description[["PSEUDONYMIZATION_RULE"]] <- normalizePseudonymizationRule(
    table_description[["PSEUDONYMIZATION_RULE_RAW"]]
  )
  table_description[["IMPLICIT_KEEP"]] <-
    is.na(table_description[["PSEUDONYMIZATION_RULE_RAW"]]) |
      trimws(table_description[["PSEUDONYMIZATION_RULE_RAW"]]) == ""
  table_description[["SOURCE"]] <- source
  table_description[["SOURCE_TYPE"]] <- source_type
  table_description[["SOURCE_FILE"]] <- path
  table_description[["SOURCE_SHEET"]] <- sheet_name

  output_columns <- c(
    "SOURCE",
    "SOURCE_TYPE",
    "SOURCE_FILE",
    "SOURCE_SHEET",
    "TABLE_NAME",
    "RESOURCE",
    "TABLE_OR_RESOURCE",
    "COLUMN_NAME",
    "COLUMN_DESCRIPTION",
    "COLUMN_TYPE",
    "FHIR_EXPRESSION",
    "PSEUDONYMIZATION_RULE_RAW",
    "PSEUDONYMIZATION_RULE",
    "IMPLICIT_KEEP"
  )
  for (output_column in output_columns) {
    if (!output_column %in% names(table_description)) {
      table_description[[output_column]] <- NA_character_
    }
  }
  data.table::as.data.table(as.data.frame(table_description)[
    ,
    output_columns,
    drop = FALSE
  ])
}

loadPseudonymizationRuleSources <- function(sources, source_type, default_sheet_name) {
  specs <- normalizeRuleSourceSpec(sources, default_sheet_name)
  if (nrow(specs) == 0) {
    return(data.table::data.table())
  }

  tables <- vector("list", nrow(specs))
  for (i in seq_len(nrow(specs))) {
    source <- specs[["SOURCE"]][i]
    path <- specs[["PATH"]][i]
    sheet_name <- specs[["SHEET_NAME"]][i]
    table_description <- etlutils::loadTableDescriptionFile(
      path,
      sheet_name
    )
    tables[[i]] <- normalizePseudonymizationRuleInput(
      table_description,
      source = source,
      path = path,
      sheet_name = sheet_name,
      source_type = source_type
    )
  }

  data.table::rbindlist(tables, fill = TRUE)
}

#' Load pseudonymization rules from table descriptions and snapshot extensions.
#'
#' Normal table descriptions describe columns that already exist in the source
#' database. Snapshot extensions describe derived columns that are added only
#' while building a pseudonymized snapshot, for example analysis columns on
#' `observation`. Keeping those extensions separate prevents normal toolchain
#' database initialization from creating snapshot-only columns.
#'
#' @param table_descriptions Character vector or data.frame/data.table with table
#'   description files. Data frames must contain `PATH` or `FILE_PATH` and may
#'   contain `SOURCE`/`NAME` and `SHEET_NAME`/`SHEET`.
#' @param snapshot_extensions Optional character vector or data.frame/data.table
#'   with snapshot-extension table descriptions.
#' @param default_table_description_sheet Default sheet for entries in
#'   `table_descriptions`.
#' @param default_snapshot_extension_sheet Default sheet for entries in
#'   `snapshot_extensions`.
#'
#' @return A data.table with normalized source metadata, table/resource,
#'   column metadata, raw and normalized `PSEUDONYMIZATION_RULE`, and
#'   `SOURCE_TYPE` set to `table_description` or `snapshot_extension`.
#'
#' @export
loadPseudonymizationRules <- function(
  table_descriptions,
  snapshot_extensions = NULL,
  default_table_description_sheet = "table_description",
  default_snapshot_extension_sheet = DEFAULT_SNAPSHOT_EXTENSION_SHEET) {
  table_rules <- loadPseudonymizationRuleSources(
    table_descriptions,
    source_type = "table_description",
    default_sheet_name = default_table_description_sheet
  )
  extension_rules <- loadPseudonymizationRuleSources(
    snapshot_extensions,
    source_type = "snapshot_extension",
    default_sheet_name = default_snapshot_extension_sheet
  )

  data.table::rbindlist(list(table_rules, extension_rules), fill = TRUE)
}

emptyRuleReviewTable <- function(extra_columns = character()) {
  columns <- c(
    "SOURCE",
    "SOURCE_TYPE",
    "SOURCE_FILE",
    "SOURCE_SHEET",
    "TABLE_OR_RESOURCE",
    "COLUMN_NAME",
    "PSEUDONYMIZATION_RULE",
    extra_columns
  )
  result <- data.table::data.table()
  for (column in columns) {
    result[[column]] <- character()
  }
  result
}

getRuleReviewBaseColumns <- function(rules) {
  columns <- c(
    "SOURCE",
    "SOURCE_TYPE",
    "SOURCE_FILE",
    "SOURCE_SHEET",
    "TABLE_OR_RESOURCE",
    "COLUMN_NAME",
    "PSEUDONYMIZATION_RULE"
  )
  rules <- data.table::as.data.table(data.table::copy(rules))
  for (column in columns) {
    if (!column %in% names(rules)) {
      rules[[column]] <- NA_character_
    }
  }
  data.table::as.data.table(as.data.frame(rules)[, columns, drop = FALSE])
}

getRulePartReview <- function(rules) {
  if (nrow(rules) == 0) {
    return(emptyRuleReviewTable(c("RULE_PART", "ACTION", "ERROR")))
  }

  rows <- list()
  for (i in seq_len(nrow(rules))) {
    rule_parts <- splitRuleList(rules[["PSEUDONYMIZATION_RULE"]][i])
    rule_parts <- trimws(rule_parts)
    rule_parts <- rule_parts[nzchar(rule_parts)]
    for (rule_part in rule_parts) {
      parsed_rule <- tryCatch(
        parsePseudonymizationRuleCall(rule_part),
        error = function(error) error
      )
      action <- NA_character_
      error_message <- NA_character_
      if (inherits(parsed_rule, "error")) {
        error_message <- conditionMessage(parsed_rule)
      } else {
        action <- parsed_rule$action
      }
      rows[[length(rows) + 1L]] <- data.table::as.data.table(cbind(
        getRuleReviewBaseColumns(rules[i, ]),
        data.table::data.table(
          RULE_PART = rule_part,
          ACTION = action,
          ERROR = error_message
        )
      ))
    }
  }

  data.table::rbindlist(rows, fill = TRUE)
}

getUnsupportedRuleParts <- function(rule_parts) {
  supported_actions <- c(
    "keep",
    "redact",
    "cryptoHash",
    "pseudonymize",
    "pseudonym",
    "generalize",
    "keepIf",
    "redactIf"
  )
  is_unsupported <- is.na(rule_parts[["ACTION"]]) |
    !(rule_parts[["ACTION"]] %in% supported_actions) |
    grepl("^###\\s*TODO", rule_parts[["RULE_PART"]])
  is_unsupported[is.na(is_unsupported)] <- TRUE
  unsupported <- rule_parts[which(is_unsupported), ]
  if (nrow(unsupported) == 0) {
    return(emptyRuleReviewTable(c("RULE_PART", "ACTION", "ERROR")))
  }
  unsupported
}

getDuplicateRuleColumns <- function(rules) {
  if (nrow(rules) == 0) {
    return(data.table::data.table(
      SOURCE = character(),
      SOURCE_TYPE = character(),
      SOURCE_FILE = character(),
      SOURCE_SHEET = character(),
      TABLE_OR_RESOURCE = character(),
      COLUMN_NAME = character(),
      N = integer()
    ))
  }

  group_columns <- c(
    "SOURCE",
    "SOURCE_TYPE",
    "SOURCE_FILE",
    "SOURCE_SHEET",
    "TABLE_OR_RESOURCE",
    "COLUMN_NAME"
  )
  duplicates <- stats::aggregate(
    x = list(N = rep(1L, nrow(rules))),
    by = as.data.frame(rules)[, group_columns, drop = FALSE],
    FUN = sum
  )
  duplicates <- data.table::as.data.table(duplicates[duplicates$N > 1, , drop = FALSE])
  data.table::setorder(
    duplicates,
    SOURCE_TYPE,
    SOURCE,
    TABLE_OR_RESOURCE,
    COLUMN_NAME
  )
  duplicates
}

getPseudonymMappingRuleSheets <- function(rule_parts) {
  is_pseudonym_rule <- rule_parts[["ACTION"]] == "pseudonym"
  is_pseudonym_rule[is.na(is_pseudonym_rule)] <- FALSE
  pseudonym_rules <- rule_parts[which(is_pseudonym_rule), ]
  if (nrow(pseudonym_rules) == 0) {
    return(emptyRuleReviewTable(c("RULE_PART", "SHEET_NAME", "MAPPING_STATUS", "ERROR")))
  }

  result <- data.table::copy(pseudonym_rules)
  result[["SHEET_NAME"]] <- NA_character_
  result[["MAPPING_STATUS"]] <- NA_character_
  result[["ERROR"]] <- NA_character_
  for (i in seq_len(nrow(result))) {
    parsed_rule <- parsePseudonymizationRuleCall(result[["RULE_PART"]][i])
    sheet_name <- getRuleArgument(parsed_rule, "sheet")
    if (is.na(sheet_name) || !nzchar(sheet_name)) {
      sheet_name <- stripRuleQuotes(parsed_rule$arguments[1])
    }
    if (is.na(sheet_name) || !nzchar(sheet_name)) {
      result[["MAPPING_STATUS"]][i] <- "invalid_rule"
      result[["ERROR"]][i] <- "pseudonym(...) rules require a sheet argument."
    } else {
      result[["SHEET_NAME"]][i] <- sheet_name
    }
  }
  result
}

validatePseudonymMappingRuleSheets <- function(mapping_rules, input_repo_path) {
  if (nrow(mapping_rules) == 0) {
    return(mapping_rules)
  }

  needs_mapping <- !is.na(mapping_rules[["SHEET_NAME"]]) &
    nzchar(mapping_rules[["SHEET_NAME"]])
  if (!any(needs_mapping)) {
    return(mapping_rules)
  }

  if (is.null(input_repo_path) || is.na(input_repo_path) || !nzchar(input_repo_path)) {
    mapping_rules[["MAPPING_STATUS"]][needs_mapping] <- "missing_input_repo_path"
    mapping_rules[["ERROR"]][needs_mapping] <-
      "input_repo_path is required to validate pseudonym(sheet = ...) rules."
    return(mapping_rules)
  }

  mapping_file_path <- file.path(input_repo_path, PSEUDONYM_MAPPING_FILE_NAME)
  if (!file.exists(mapping_file_path)) {
    mapping_rules[["MAPPING_STATUS"]][needs_mapping] <- "missing_file"
    mapping_rules[["ERROR"]][needs_mapping] <-
      paste("Pseudonym mapping file not found:", mapping_file_path)
    return(mapping_rules)
  }

  for (sheet_name in unique(mapping_rules[["SHEET_NAME"]][needs_mapping])) {
    validation <- tryCatch(
      {
        loadPseudonymMappingSheet(input_repo_path, sheet_name)
        list(status = "ok", error = NA_character_)
      },
      error = function(error) {
        list(status = "invalid_sheet", error = conditionMessage(error))
      }
    )
    rows <- mapping_rules[["SHEET_NAME"]] == sheet_name
    rows[is.na(rows)] <- FALSE
    mapping_rules[["MAPPING_STATUS"]][rows] <- validation$status
    mapping_rules[["ERROR"]][rows] <- validation$error
  }

  mapping_rules
}

#' Review loaded pseudonymization rules before building a snapshot.
#'
#' The report is intentionally metadata-focused. It checks loaded table
#' descriptions and snapshot extensions for unresolved TODO markers, implicit
#' `keep` rules, unsupported rule actions, duplicate column definitions, and
#' mapping-rule references to `pseudo_mapping.xlsx`. Missing concrete mapping
#' keys are collected later while applying the rules to actual data.
#'
#' @param rules A data.table returned by `loadPseudonymizationRules()`.
#' @param input_repo_path Optional TOML-configured input repository directory
#'   used to validate `pseudonym(sheet = ...)` mapping rules.
#'
#' @return A named list of data.tables: `summary`, `todo_rules`,
#'   `implicit_keep_rules`, `unsupported_rules`, `duplicate_columns`, and
#'   `mapping_rules`.
#'
#' @export
getPseudonymizationRuleReviewReport <- function(rules, input_repo_path = NULL) {
  rules <- data.table::as.data.table(data.table::copy(rules))
  if (!PSEUDONYMIZATION_RULE_COLNAME %in% names(rules)) {
    stop("rules must contain PSEUDONYMIZATION_RULE.")
  }
  if (!"IMPLICIT_KEEP" %in% names(rules)) {
    rules[["IMPLICIT_KEEP"]] <- FALSE
  }
  if (!"PSEUDONYMIZATION_RULE_RAW" %in% names(rules)) {
    rules[["PSEUDONYMIZATION_RULE_RAW"]] <- rules[[PSEUDONYMIZATION_RULE_COLNAME]]
  }
  rules[["HAS_TODO_RULE"]] <-
    grepl("^###\\s*TODO", rules[[PSEUDONYMIZATION_RULE_COLNAME]]) |
      grepl("TODO", rules[["PSEUDONYMIZATION_RULE_RAW"]])
  rules[["HAS_TODO_RULE"]][is.na(rules[["HAS_TODO_RULE"]])] <- FALSE
  rules[["HAS_MAPPING_RULE"]] <-
    grepl("\\bpseudonym\\s*\\(", rules[[PSEUDONYMIZATION_RULE_COLNAME]])
  rules[["HAS_MAPPING_RULE"]][is.na(rules[["HAS_MAPPING_RULE"]])] <- FALSE

  rule_parts <- getRulePartReview(rules)
  todo_rules <- rules[which(rules[["HAS_TODO_RULE"]] == TRUE), ]
  if (nrow(todo_rules) == 0) {
    todo_rules <- emptyRuleReviewTable()
  } else {
    todo_rules <- getRuleReviewBaseColumns(todo_rules)
  }
  implicit_keep_rules <- rules[which(rules[["IMPLICIT_KEEP"]] == TRUE), ]
  if (nrow(implicit_keep_rules) == 0) {
    implicit_keep_rules <- emptyRuleReviewTable()
  } else {
    implicit_keep_rules <- getRuleReviewBaseColumns(implicit_keep_rules)
  }

  unsupported_rules <- getUnsupportedRuleParts(rule_parts)
  mapping_rules <- validatePseudonymMappingRuleSheets(
    getPseudonymMappingRuleSheets(rule_parts),
    input_repo_path
  )

  summary <- stats::aggregate(
    x = list(
      N = rep(1L, nrow(rules)),
      IMPLICIT_KEEP_N = as.integer(rules[["IMPLICIT_KEEP"]] == TRUE),
      TODO_N = as.integer(rules[["HAS_TODO_RULE"]] == TRUE),
      MAPPING_RULE_N = as.integer(rules[["HAS_MAPPING_RULE"]] == TRUE)
    ),
    by = as.data.frame(rules)[, c("SOURCE", "SOURCE_TYPE"), drop = FALSE],
    FUN = sum
  )
  summary <- data.table::as.data.table(summary)
  if (nrow(unsupported_rules) == 0) {
    unsupported_counts <- data.table::data.table(
      SOURCE = character(),
      SOURCE_TYPE = character(),
      UNSUPPORTED_RULE_N = integer()
    )
  } else {
    unsupported_counts <- stats::aggregate(
      x = list(UNSUPPORTED_RULE_N = rep(1L, nrow(unsupported_rules))),
      by = as.data.frame(unsupported_rules)[, c("SOURCE", "SOURCE_TYPE"), drop = FALSE],
      FUN = sum
    )
    unsupported_counts <- data.table::as.data.table(unsupported_counts)
  }
  mapping_problem_rows <- is.na(mapping_rules[["MAPPING_STATUS"]]) |
    mapping_rules[["MAPPING_STATUS"]] != "ok"
  mapping_problem_rules <- mapping_rules[which(mapping_problem_rows), ]
  if (nrow(mapping_problem_rules) == 0) {
    mapping_problem_counts <- data.table::data.table(
      SOURCE = character(),
      SOURCE_TYPE = character(),
      MAPPING_PROBLEM_N = integer()
    )
  } else {
    mapping_problem_counts <- stats::aggregate(
      x = list(MAPPING_PROBLEM_N = rep(1L, nrow(mapping_problem_rules))),
      by = as.data.frame(mapping_problem_rules)[, c("SOURCE", "SOURCE_TYPE"), drop = FALSE],
      FUN = sum
    )
    mapping_problem_counts <- data.table::as.data.table(mapping_problem_counts)
  }
  summary <- merge(summary, unsupported_counts, by = c("SOURCE", "SOURCE_TYPE"), all.x = TRUE)
  summary <- merge(summary, mapping_problem_counts, by = c("SOURCE", "SOURCE_TYPE"), all.x = TRUE)
  summary[["UNSUPPORTED_RULE_N"]][is.na(summary[["UNSUPPORTED_RULE_N"]])] <- 0L
  summary[["MAPPING_PROBLEM_N"]][is.na(summary[["MAPPING_PROBLEM_N"]])] <- 0L
  data.table::setorder(summary, SOURCE_TYPE, SOURCE)

  list(
    summary = summary,
    todo_rules = todo_rules,
    implicit_keep_rules = implicit_keep_rules,
    unsupported_rules = unsupported_rules,
    duplicate_columns = getDuplicateRuleColumns(rules),
    mapping_rules = mapping_rules
  )
}

#' Write a pseudonymization rule review report to an Excel workbook.
#'
#' @param rules A data.table returned by `loadPseudonymizationRules()`.
#' @param file_name Optional output `.xlsx` file path. If `NA`, the report is
#'   written to `outputLocal/<MODULE>/reports` via `etlutils::writeExcelFileLocal()`.
#' @param input_repo_path Optional TOML-configured input repository directory
#'   used to validate `pseudonym(sheet = ...)` mapping rules.
#' @param filename_without_extension File name used for the default
#'   `outputLocal/<MODULE>/reports` output.
#'
#' @return The report returned by `getPseudonymizationRuleReviewReport()`,
#'   invisibly.
#'
#' @export
writePseudonymizationRuleReviewReport <- function(
  rules,
  file_name = NA,
  input_repo_path = NULL,
  filename_without_extension = "pseudonymization_rule_review") {
  report <- getPseudonymizationRuleReviewReport(
    rules,
    input_repo_path = input_repo_path
  )
  if (is.na(file_name)) {
    etlutils::writeExcelFileLocal(
      report,
      filename_without_extension = filename_without_extension,
      with_column_names = TRUE,
      subdir = "reports"
    )
  } else {
    output_dir <- dirname(file_name)
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    }
    etlutils::writeExcelFile(
      report,
      file_name,
      with_column_names = TRUE
    )
  }
  invisible(report)
}
