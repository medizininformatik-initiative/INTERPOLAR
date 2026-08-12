getPseudonymMappingCoverageRequests <- function(rules, materialization_plan) {
  rule_parts <- getRulePartReview(rules)
  mapping_rules <- getPseudonymMappingRuleSheets(rule_parts)
  mapping_rules <- mapping_rules[
    !is.na(mapping_rules[["SHEET_NAME"]]) &
      nzchar(mapping_rules[["SHEET_NAME"]]), ,
    drop = FALSE
  ]
  if (nrow(mapping_rules) == 0) {
    return(data.table::data.table(
      SOURCE_RELATION = character(),
      RULE_TABLE_NAME = character(),
      RULE_SOURCE = character(),
      COLUMN_NAME = character(),
      SHEET_NAME = character()
    ))
  }

  unsupported_sources <- mapping_rules[
    mapping_rules[["SOURCE_TYPE"]] != "table_description", ,
    drop = FALSE
  ]
  if (nrow(unsupported_sources) > 0) {
    stop(
      "pseudonym(sheet = ...) rules are only supported for columns that already ",
      "exist in normal snapshot source tables. Unsupported rule sources: ",
      paste(unique(unsupported_sources[["SOURCE"]]), collapse = ", ")
    )
  }

  mapping_rules[["RULE_TABLE_NAME"]] <-
    tolower(mapping_rules[["TABLE_OR_RESOURCE"]])
  mapping_rules[["RULE_SOURCE"]] <- mapping_rules[["SOURCE"]]
  mapping_rules <- unique(mapping_rules[
    ,
    c("RULE_TABLE_NAME", "RULE_SOURCE", "COLUMN_NAME", "SHEET_NAME"),
    with = FALSE
  ])
  plan <- data.table::as.data.table(data.table::copy(materialization_plan))
  plan <- plan[plan[["SNAPSHOT_RELATION_TYPE"]] == "all", ]
  requests <- merge(
    plan[
      ,
      c("SOURCE_RELATION", "RULE_TABLE_NAME", "RULE_SOURCE"),
      with = FALSE
    ],
    mapping_rules,
    by = c("RULE_TABLE_NAME", "RULE_SOURCE"),
    allow.cartesian = TRUE
  )
  unique(requests[
    ,
    c("SOURCE_RELATION", "RULE_TABLE_NAME", "RULE_SOURCE", "COLUMN_NAME", "SHEET_NAME"),
    with = FALSE
  ])
}

readDistinctPseudonymMappingValues <- function(
  connection,
  source_relation,
  column_name,
  source_schema = NULL,
  fetch_size = 10000L
) {
  quoted_column <- as.character(DBI::dbQuoteIdentifier(connection, column_name))
  relation <- snapshotQualifiedName(connection, source_relation, source_schema)
  query <- paste0(
    "SELECT DISTINCT ", quoted_column, " AS mapping_value ",
    "FROM ", relation, " ",
    "WHERE ", quoted_column, " IS NOT NULL"
  )
  result <- tryCatch(
    DBI::dbSendQuery(connection, query),
    error = function(error) {
      stop(
        "Could not read distinct mapping values from ",
        source_relation, ".", column_name, ": ",
        conditionMessage(error),
        call. = FALSE
      )
    }
  )
  on.exit(
    {
      if (DBI::dbIsValid(result)) {
        DBI::dbClearResult(result)
      }
    },
    add = TRUE
  )

  value_chunks <- list()
  repeat {
    chunk <- DBI::dbFetch(result, n = fetch_size)
    if (nrow(chunk) > 0) {
      value_chunks[[length(value_chunks) + 1L]] <-
        as.character(chunk[["mapping_value"]])
    }
    if (DBI::dbHasCompleted(result)) {
      break
    }
  }
  unique(unlist(value_chunks, use.names = FALSE))
}

sortPseudonymMappingKeys <- function(keys) {
  keys <- unique(as.character(keys))
  keys <- keys[!is.na(keys)]
  keys[order(tolower(keys), keys, method = "radix")]
}

readPseudonymMappingSheetForUpdate <- function(file_name, sheet_name) {
  raw <- openxlsx::read.xlsx(
    file_name,
    sheet = sheet_name,
    colNames = FALSE,
    skipEmptyRows = FALSE,
    skipEmptyCols = FALSE
  )
  if (nrow(raw) == 0 || ncol(raw) < 2) {
    stop("Pseudonym mapping sheet has no KEY/PSEUDONYM header: ", sheet_name)
  }

  header_row <- NA_integer_
  key_col <- NA_integer_
  pseudonym_col <- NA_integer_
  for (row_index in seq_len(nrow(raw))) {
    row_values <- trimws(as.character(raw[row_index, , drop = TRUE]))
    key_match <- which(row_values == PSEUDONYM_MAPPING_KEY_COLNAME)
    pseudonym_match <- which(row_values == PSEUDONYM_MAPPING_VALUE_COLNAME)
    if (length(key_match) > 0 && length(pseudonym_match) > 0) {
      header_row <- row_index
      key_col <- key_match[1]
      pseudonym_col <- pseudonym_match[1]
      break
    }
  }
  if (is.na(header_row)) {
    stop("Pseudonym mapping sheet has no KEY/PSEUDONYM header: ", sheet_name)
  }

  if (header_row == nrow(raw)) {
    mapping <- data.table::data.table(KEY = character(), PSEUDONYM = character())
  } else {
    data_rows <- seq.int(header_row + 1L, nrow(raw))
    mapping <- data.table::data.table(
      KEY = as.character(raw[data_rows, key_col, drop = TRUE]),
      PSEUDONYM = as.character(raw[data_rows, pseudonym_col, drop = TRUE])
    )
    mapping <- mapping[
      !(is.na(mapping[["KEY"]]) | !nzchar(trimws(mapping[["KEY"]]))) |
        !(
          is.na(mapping[["PSEUDONYM"]]) |
            !nzchar(trimws(mapping[["PSEUDONYM"]]))
        ), ,
      drop = FALSE
    ]
  }
  empty_keys <- is.na(mapping[["KEY"]]) | !nzchar(trimws(mapping[["KEY"]]))
  if (any(empty_keys)) {
    stop("Pseudonym mapping sheet contains an empty KEY: ", sheet_name)
  }
  duplicated_keys <- unique(mapping[["KEY"]][
    duplicated(mapping[["KEY"]]) |
      duplicated(mapping[["KEY"]], fromLast = TRUE)
  ])
  if (length(duplicated_keys) > 0) {
    stop(
      "Pseudonym mapping sheet contains duplicate KEY values. Sheet: ",
      sheet_name,
      ". Duplicate keys: ",
      paste(duplicated_keys, collapse = ", ")
    )
  }
  attr(mapping, "header_row") <- header_row
  mapping
}

writePseudonymMappingSheet <- function(
  workbook,
  file_name,
  sheet_name,
  mapping,
  sheet_exists
) {
  if (isTRUE(sheet_exists)) {
    raw <- openxlsx::read.xlsx(
      file_name,
      sheet = sheet_name,
      colNames = FALSE,
      skipEmptyRows = FALSE,
      skipEmptyCols = FALSE
    )
    openxlsx::deleteData(
      workbook,
      sheet = sheet_name,
      cols = seq_len(max(2L, ncol(raw))),
      rows = seq_len(max(1L, nrow(raw))),
      gridExpand = TRUE
    )
  } else {
    openxlsx::addWorksheet(workbook, sheet_name)
  }

  openxlsx::writeData(
    workbook,
    sheet = sheet_name,
    x = mapping,
    startRow = 1,
    startCol = 1,
    colNames = TRUE,
    withFilter = nrow(mapping) > 0
  )
  header_style <- openxlsx::createStyle(
    fontName = "Calibri",
    textDecoration = "bold",
    fgFill = "#D9EAF7",
    border = "Bottom"
  )
  openxlsx::addStyle(
    workbook,
    sheet = sheet_name,
    style = header_style,
    rows = 1,
    cols = 1:2,
    gridExpand = TRUE,
    stack = TRUE
  )
  openxlsx::freezePane(workbook, sheet = sheet_name, firstRow = TRUE)
  openxlsx::setColWidths(workbook, sheet = sheet_name, cols = 1:2, widths = c(40, 40))
}

savePseudonymMappingWorkbook <- function(workbook, file_name) {
  temporary_file <- tempfile(
    pattern = "pseudo_mapping_",
    tmpdir = dirname(file_name),
    fileext = ".xlsx"
  )
  on.exit(unlink(temporary_file), add = TRUE)
  openxlsx::saveWorkbook(workbook, temporary_file, overwrite = TRUE)
  if (!file.copy(temporary_file, file_name, overwrite = TRUE)) {
    stop("Could not write pseudonym mapping workbook: ", file_name)
  }
}

ensurePseudonymMappingCoverage <- function(
  connection,
  rules,
  materialization_plan,
  input_repo_path,
  source_schema = NULL,
  distinct_value_reader = readDistinctPseudonymMappingValues
) {
  requests <- getPseudonymMappingCoverageRequests(rules, materialization_plan)
  if (nrow(requests) == 0) {
    return(invisible(data.table::data.table()))
  }
  if (
    is.null(input_repo_path) || is.na(input_repo_path) ||
    !nzchar(input_repo_path) || !dir.exists(input_repo_path)
  ) {
    stop("Configured INPUT_REPO_PATH does not exist: ", input_repo_path)
  }

  mapping_file <- getPseudonymMappingFilePath(input_repo_path)
  file_exists <- file.exists(mapping_file)
  workbook <- if (file_exists) {
    openxlsx::loadWorkbook(mapping_file)
  } else {
    openxlsx::createWorkbook()
  }
  existing_sheets <- if (file_exists) openxlsx::getSheetNames(mapping_file) else character()
  required_sheets <- sort(unique(requests[["SHEET_NAME"]]))
  missing_summary <- list()
  workbook_changed <- !file_exists

  for (sheet_name in required_sheets) {
    sheet_exists <- sheet_name %in% existing_sheets
    existing <- if (sheet_exists) {
      readPseudonymMappingSheetForUpdate(mapping_file, sheet_name)
    } else {
      data.table::data.table(KEY = character(), PSEUDONYM = character())
    }
    sheet_requests <- requests[requests[["SHEET_NAME"]] == sheet_name, ]
    database_key_sets <- vector("list", nrow(sheet_requests))
    for (request_index in seq_len(nrow(sheet_requests))) {
      database_key_sets[[request_index]] <- distinct_value_reader(
        connection = connection,
        source_relation = sheet_requests[["SOURCE_RELATION"]][request_index],
        column_name = sheet_requests[["COLUMN_NAME"]][request_index],
        source_schema = source_schema
      )
    }
    database_keys <- unlist(database_key_sets, use.names = FALSE)
    database_keys <- sortPseudonymMappingKeys(splitPseudonymMappingValues(database_keys))
    if (any(!nzchar(database_keys))) {
      stop(
        "Empty strings cannot be added as pseudonym mapping keys. Sheet: ",
        sheet_name,
        ". Check the mapped source columns."
      )
    }

    new_keys <- setdiff(database_keys, existing[["KEY"]])
    if (length(new_keys) > 0) {
      existing <- data.table::rbindlist(list(
        existing,
        data.table::data.table(
          KEY = new_keys,
          PSEUDONYM = rep(NA_character_, length(new_keys))
        )
      ))
    }
    sorted_order <- order(tolower(existing[["KEY"]]), existing[["KEY"]], method = "radix")
    sorted_mapping <- existing[sorted_order, ]
    needs_rewrite <- !sheet_exists ||
      length(new_keys) > 0 ||
      !identical(existing[["KEY"]], sorted_mapping[["KEY"]]) ||
      !identical(attr(existing, "header_row"), 1L)
    if (needs_rewrite) {
      writePseudonymMappingSheet(
        workbook,
        mapping_file,
        sheet_name,
        sorted_mapping,
        sheet_exists
      )
      workbook_changed <- TRUE
    }

    empty_pseudonyms <- is.na(sorted_mapping[["PSEUDONYM"]]) |
      !nzchar(trimws(sorted_mapping[["PSEUDONYM"]]))
    if (any(empty_pseudonyms)) {
      missing_summary[[length(missing_summary) + 1L]] <- data.table::data.table(
        SHEET_NAME = sheet_name,
        MISSING_PSEUDONYM_N = sum(empty_pseudonyms),
        NEW_KEY_N = length(new_keys)
      )
    }
  }

  if (workbook_changed) {
    savePseudonymMappingWorkbook(workbook, mapping_file)
  }
  if (length(missing_summary) > 0) {
    summary <- data.table::rbindlist(missing_summary)
    stop(getIncompletePseudonymMappingMessage(
      summary[["SHEET_NAME"]],
      input_repo_path
    ), call. = FALSE)
  }

  invisible(data.table::data.table(
    SHEET_NAME = required_sheets,
    STATUS = "complete"
  ))
}
