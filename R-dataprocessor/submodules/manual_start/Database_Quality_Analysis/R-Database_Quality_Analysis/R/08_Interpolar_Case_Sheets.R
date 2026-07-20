DATABASE_QUALITY_ANALYSIS_INTERPOLAR_SHEET_NAME <- "FHIR INTERPOLAR"

quoteQualifiedIdentifier <- function(alias, identifier) {
  paste(quoteIdentifier(alias), quoteIdentifier(identifier), sep = ".")
}

getTableMetadata <- function(metadata, table_name) {
  metadata[TABLE_NAME == table_name][order(ORDINAL_POSITION)]
}

getInterpolarMainEncounterSubquery <- function(metadata) {
  encounter_metadata <- getTableMetadata(metadata, "encounter")
  pids_per_ward_metadata <- getTableMetadata(metadata, "pids_per_ward")
  if (!nrow(encounter_metadata) || !nrow(pids_per_ward_metadata)) {
    return(NA_character_)
  }

  required_encounter_columns <- c("enc_id", "enc_main_encounter_calculated_ref")
  if (!all(required_encounter_columns %in% encounter_metadata$COLUMN_NAME) ||
      !"encounter_id" %in% pids_per_ward_metadata$COLUMN_NAME) {
    return(NA_character_)
  }

  encounter_alias <- "interpolar_enc"
  ward_alias <- "interpolar_ward"
  main_encounter_column <- quoteQualifiedIdentifier(
    encounter_alias,
    "enc_main_encounter_calculated_ref"
  )
  main_encounter_condition <- paste(
    main_encounter_column,
    "IS NOT NULL AND",
    main_encounter_column,
    "::text <> '' AND",
    main_encounter_column,
    "::text <>",
    quoteSqlString("invalid")
  )

  paste0(
    "SELECT DISTINCT ",
    main_encounter_column,
    "\n    FROM ",
    quoteTable(encounter_metadata$VIEW_SCHEMA[[1]], encounter_metadata$VIEW_NAME[[1]]),
    " ",
    quoteIdentifier(encounter_alias),
    "\n    JOIN ",
    quoteTable(pids_per_ward_metadata$VIEW_SCHEMA[[1]], pids_per_ward_metadata$VIEW_NAME[[1]]),
    " ",
    quoteIdentifier(ward_alias),
    "\n      ON ",
    quoteQualifiedIdentifier(encounter_alias, "enc_id"),
    " = ",
    quoteQualifiedIdentifier(ward_alias, "encounter_id"),
    "\n   WHERE ",
    main_encounter_condition
  )
}

getInterpolarPatientSubquery <- function(metadata) {
  encounter_metadata <- getTableMetadata(metadata, "encounter")
  pids_per_ward_metadata <- getTableMetadata(metadata, "pids_per_ward")
  if (!nrow(encounter_metadata) || !nrow(pids_per_ward_metadata)) {
    return(NA_character_)
  }

  required_encounter_columns <- c(
    "enc_id",
    "enc_patient_ref",
    "enc_main_encounter_calculated_ref"
  )
  if (
    !all(required_encounter_columns %in% encounter_metadata$COLUMN_NAME) ||
    !"encounter_id" %in% pids_per_ward_metadata$COLUMN_NAME
  ) {
    return(NA_character_)
  }

  encounter_alias <- "interpolar_enc"
  ward_alias <- "interpolar_ward"
  patient_column <- quoteQualifiedIdentifier(encounter_alias, "enc_patient_ref")
  main_encounter_column <- quoteQualifiedIdentifier(
    encounter_alias,
    "enc_main_encounter_calculated_ref"
  )
  patient_condition <- paste(
    patient_column,
    "IS NOT NULL AND",
    patient_column,
    "::text <> '' AND",
    patient_column,
    "::text <>",
    quoteSqlString("invalid")
  )
  main_encounter_condition <- paste(
    main_encounter_column,
    "IS NOT NULL AND",
    main_encounter_column,
    "::text <> '' AND",
    main_encounter_column,
    "::text <>",
    quoteSqlString("invalid")
  )
  from_join_clause <- paste0(
    "\n    FROM ",
    quoteTable(encounter_metadata$VIEW_SCHEMA[[1]], encounter_metadata$VIEW_NAME[[1]]),
    " ",
    quoteIdentifier(encounter_alias),
    "\n    JOIN ",
    quoteTable(pids_per_ward_metadata$VIEW_SCHEMA[[1]], pids_per_ward_metadata$VIEW_NAME[[1]]),
    " ",
    quoteIdentifier(ward_alias),
    "\n      ON ",
    quoteQualifiedIdentifier(encounter_alias, "enc_id"),
    " = ",
    quoteQualifiedIdentifier(ward_alias, "encounter_id"),
    "\n   WHERE ",
    patient_condition,
    " AND ",
    main_encounter_condition
  )

  paste0(
    "SELECT DISTINCT ",
    patient_column,
    from_join_clause,
    "\n  UNION\n  SELECT DISTINCT regexp_replace(",
    patient_column,
    "::text, '^.*Patient/', '')",
    from_join_clause
  )
}

getInterpolarEncounterCalculatedRefColumn <- function(table_metadata, grouping_columns) {
  table_name <- table_metadata$TABLE_NAME[[1]]
  if (!identical(table_metadata$TABLE_FAMILY[[1]], "FHIR")) {
    return(NA_character_)
  }

  if (identical(table_name, "encounter")) {
    encounter_column <- "enc_main_encounter_calculated_ref"
    if (encounter_column %in% table_metadata$COLUMN_NAME) {
      return(encounter_column)
    }
    return(NA_character_)
  }

  grouping_prefix <- getGroupingPrefix(grouping_columns[["resource_id"]])
  encounter_column <- paste0(grouping_prefix, "_encounter_calculated_ref")
  if (encounter_column %in% table_metadata$COLUMN_NAME) {
    return(encounter_column)
  }

  NA_character_
}

getInterpolarCaseFilterCondition <- function(table_metadata, grouping_columns, main_encounter_subquery) {
  if (is.na(main_encounter_subquery)) {
    return(NA_character_)
  }

  encounter_column <- getInterpolarEncounterCalculatedRefColumn(table_metadata, grouping_columns)
  if (is.na(encounter_column)) {
    return(NA_character_)
  }

  data_types <- stats::setNames(
    if ("DATA_TYPE" %in% names(table_metadata)) table_metadata$DATA_TYPE else rep(NA_character_, nrow(table_metadata)),
    table_metadata$COLUMN_NAME
  )
  paste0(
    getValueAvailableCondition(encounter_column, table_metadata, data_types),
    " AND ",
    quoteIdentifier(encounter_column),
    " IN (\n    ",
    main_encounter_subquery,
    "\n  )"
  )
}

getInterpolarPatientFilterCondition <- function(table_metadata, grouping_columns, patient_subquery) {
  if (is.na(patient_subquery) || is.na(grouping_columns[["pid"]])) {
    return(NA_character_)
  }

  patient_column <- grouping_columns[["pid"]]
  data_types <- stats::setNames(
    if ("DATA_TYPE" %in% names(table_metadata)) table_metadata$DATA_TYPE else rep(NA_character_, nrow(table_metadata)),
    table_metadata$COLUMN_NAME
  )
  paste0(
    getValueAvailableCondition(patient_column, table_metadata, data_types),
    " AND ",
    quoteIdentifier(patient_column),
    " IN (\n    ",
    patient_subquery,
    "\n  )"
  )
}

getInterpolarFilterCondition <- function(
  table_metadata,
  grouping_columns,
  main_encounter_subquery,
  patient_subquery
) {
  reference_scope <- getResourceReferenceScope(grouping_columns, table_metadata)
  if (identical(reference_scope, "case_dependent")) {
    return(getInterpolarCaseFilterCondition(
      table_metadata,
      grouping_columns,
      main_encounter_subquery
    ))
  }
  if (identical(reference_scope, "patient_dependent")) {
    return(getInterpolarPatientFilterCondition(
      table_metadata,
      grouping_columns,
      patient_subquery
    ))
  }
  NA_character_
}

initializeInterpolarCaseSheet <- function(result, table_names) {
  output_columns <- setdiff(names(result), c("TABLE_FAMILY", "RESOURCE_REFERENCE_SCOPE", "ORDINAL_POSITION"))
  sheet <- data.table::copy(result[TABLE_NAME %in% table_names])
  if (!nrow(sheet)) {
    return(sheet[, ..output_columns])
  }

  for (count_column in DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS) {
    if (count_column %in% names(sheet)) {
      sheet[, (count_column) := NA_integer_]
    }
  }
  for (datetime_column in DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS) {
    if (datetime_column %in% names(sheet)) {
      sheet[, (datetime_column) := as.POSIXct(NA)]
    }
  }

  sheet[, ..output_columns]
}

createInterpolarCaseSheet <- function(
  metadata,
  result,
  config,
  history_metadata = NULL,
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  main_encounter_subquery <- getInterpolarMainEncounterSubquery(metadata)
  patient_subquery <- getInterpolarPatientSubquery(metadata)
  if (is.na(main_encounter_subquery)) {
    logProgress(
      "Skipping ",
      DATABASE_QUALITY_ANALYSIS_INTERPOLAR_SHEET_NAME,
      " sheet because pids_per_ward or encounter metadata is incomplete."
    )
    return(NULL)
  }

  table_names <- unique(metadata[TABLE_FAMILY == "FHIR", TABLE_NAME])
  table_configs <- list()
  for (table_name in table_names) {
    table_metadata <- getTableMetadata(metadata, table_name)
    grouping_columns <- tryCatch(
      inferGroupingColumns(table_metadata, config),
      error = function(error) {
        logProgress(
          "Skipping ",
          table_name,
          " for ",
          DATABASE_QUALITY_ANALYSIS_INTERPOLAR_SHEET_NAME,
          " sheet: ",
          conditionMessage(error)
        )
        NULL
      }
    )
    if (is.null(grouping_columns)) {
      next
    }

    row_filter_condition <- getInterpolarFilterCondition(
      table_metadata,
      grouping_columns,
      main_encounter_subquery,
      patient_subquery
    )
    if (is.na(row_filter_condition)) {
      next
    }

    table_configs[[table_name]] <- list(
      table_metadata = table_metadata,
      grouping_columns = grouping_columns,
      row_filter_condition = row_filter_condition
    )
  }

  if (!length(table_configs)) {
    return(NULL)
  }

  sheet <- initializeInterpolarCaseSheet(result, names(table_configs))
  for (table_name in names(table_configs)) {
    table_config <- table_configs[[table_name]]
    data_columns <- table_config$table_metadata$COLUMN_NAME
    column_batches <- split(data_columns, ceiling(seq_along(data_columns) / config$count_batch_size))
    for (data_column_batch in column_batches) {
      count_query <- buildCountQuery(
        table_config$table_metadata,
        table_config$grouping_columns,
        data_column_batch,
        row_filter_condition = table_config$row_filter_condition
      )
      if (is.na(count_query$query)) {
        next
      }

      count_result <- query_fun(
        count_query$query,
        lock_id = paste0("calculate database quality analysis INTERPOLAR counts for ", table_name)
      )
      for (row_index in seq_len(nrow(count_query$alias_map))) {
        alias_row <- count_query$alias_map[row_index]
        sheet[
          TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
          (alias_row$count_column) := as.integer(count_result[[alias_row$alias]][[1]])
        ]
      }

      if (isTRUE(config$include_value_datetime_columns)) {
        date_range_query <- buildValueDateRangeQuery(
          table_config$table_metadata,
          history_metadata,
          config,
          data_column_batch,
          row_filter_condition = table_config$row_filter_condition
        )
        if (!is.na(date_range_query$query)) {
          date_range_result <- query_fun(
            date_range_query$query,
            lock_id = paste0(
              "calculate database quality analysis INTERPOLAR value date ranges for ",
              table_name
            )
          )
          for (row_index in seq_len(nrow(date_range_query$alias_map))) {
            alias_row <- date_range_query$alias_map[row_index]
            sheet[
              TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
              (alias_row$first_result_column) := date_range_result[[alias_row$first_alias]][[1]]
            ]
            sheet[
              TABLE_NAME == table_name & COLUMN_NAME == alias_row$COLUMN_NAME,
              (alias_row$last_result_column) := date_range_result[[alias_row$last_alias]][[1]]
            ]
          }
        }
      }
    }
  }

  for (count_column in DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS) {
    if (!count_column %in% names(sheet)) {
      next
    }
    data.table::set(
      sheet,
      i = which(!is.na(sheet[[count_column]]) & sheet[[count_column]] == 0L),
      j = count_column,
      value = NA_integer_
    )
  }
  sheet
}

createInterpolarCaseSheets <- function(
  metadata,
  result,
  config,
  history_metadata = NULL,
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  sheet <- createInterpolarCaseSheet(
    metadata,
    result,
    config,
    history_metadata = history_metadata,
    query_fun = query_fun
  )
  if (is.null(sheet) || !nrow(sheet)) {
    return(list())
  }

  stats::setNames(list(sheet), DATABASE_QUALITY_ANALYSIS_INTERPOLAR_SHEET_NAME)
}
