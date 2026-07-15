DEFAULT_SNAPSHOT_EXTENSION_SHEET <- "snapshot_extensions"

emptyRuleSourceSpec <- function() {
  data.table::data.table(
    SOURCE = character(),
    PATH = character(),
    SHEET_NAME = character()
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
