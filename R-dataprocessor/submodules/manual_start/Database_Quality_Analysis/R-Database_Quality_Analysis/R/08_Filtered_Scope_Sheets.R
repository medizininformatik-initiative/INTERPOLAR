getTableMetadata <- function(metadata, table_name) {
  metadata[TABLE_NAME == table_name][order(ORDINAL_POSITION)]
}

getFilteredScopeEncounterWardMetadata <- function(metadata, required_encounter_columns) {
  encounter_metadata <- getTableMetadata(metadata, "encounter")
  pids_per_ward_metadata <- getTableMetadata(metadata, "pids_per_ward")
  if (!nrow(encounter_metadata) || !nrow(pids_per_ward_metadata)) {
    return(NULL)
  }
  if (
    !all(required_encounter_columns %in% encounter_metadata$COLUMN_NAME) ||
    !"encounter_id" %in% pids_per_ward_metadata$COLUMN_NAME
  ) {
    return(NULL)
  }

  list(
    encounter_metadata = encounter_metadata,
    pids_per_ward_metadata = pids_per_ward_metadata
  )
}

getInvalidAwareQualifiedCondition <- function(qualified_column) {
  paste(
    qualified_column,
    "IS NOT NULL AND",
    qualified_column,
    "::text <> '' AND",
    qualified_column,
    "::text <>",
    quoteSqlString("invalid")
  )
}

getFilteredScopeEncounterWardJoinClause <- function(
  encounter_metadata,
  pids_per_ward_metadata,
  encounter_alias,
  ward_alias
) {
  paste0(
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
    quoteQualifiedIdentifier(ward_alias, "encounter_id")
  )
}

getFilteredScopeMainEncounterSubquery <- function(metadata) {
  scope_metadata <- getFilteredScopeEncounterWardMetadata(
    metadata,
    c("enc_id", "enc_main_encounter_calculated_ref")
  )
  if (is.null(scope_metadata)) {
    return(NA_character_)
  }

  encounter_alias <- "filtered_scope_enc"
  ward_alias <- "filtered_scope_ward"
  main_encounter_column <- quoteQualifiedIdentifier(
    encounter_alias,
    "enc_main_encounter_calculated_ref"
  )

  paste0(
    "SELECT DISTINCT ",
    main_encounter_column,
    getFilteredScopeEncounterWardJoinClause(
      scope_metadata$encounter_metadata,
      scope_metadata$pids_per_ward_metadata,
      encounter_alias,
      ward_alias
    ),
    "\n   WHERE ",
    getInvalidAwareQualifiedCondition(main_encounter_column)
  )
}
getFilteredScopePatientSubquery <- function(metadata) {
  scope_metadata <- getFilteredScopeEncounterWardMetadata(
    metadata,
    c("enc_id", "enc_patient_ref", "enc_main_encounter_calculated_ref")
  )
  if (is.null(scope_metadata)) {
    return(NA_character_)
  }

  encounter_alias <- "filtered_scope_enc"
  ward_alias <- "filtered_scope_ward"
  patient_column <- quoteQualifiedIdentifier(encounter_alias, "enc_patient_ref")
  main_encounter_column <- quoteQualifiedIdentifier(
    encounter_alias,
    "enc_main_encounter_calculated_ref"
  )
  from_join_clause <- paste0(
    getFilteredScopeEncounterWardJoinClause(
      scope_metadata$encounter_metadata,
      scope_metadata$pids_per_ward_metadata,
      encounter_alias,
      ward_alias
    ),
    "\n   WHERE ",
    getInvalidAwareQualifiedCondition(patient_column),
    " AND ",
    getInvalidAwareQualifiedCondition(main_encounter_column)
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
getFilteredScopeEncounterCalculatedRefColumn <- function(table_metadata, grouping_columns) {
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

getFilteredScopeCaseFilterCondition <- function(table_metadata, grouping_columns, main_encounter_subquery) {
  if (is.na(main_encounter_subquery)) {
    return(NA_character_)
  }

  encounter_column <- getFilteredScopeEncounterCalculatedRefColumn(table_metadata, grouping_columns)
  if (is.na(encounter_column)) {
    return(NA_character_)
  }

  data_types <- getMetadataDataTypes(table_metadata)
  paste0(
    getValueAvailableCondition(encounter_column, table_metadata, data_types),
    " AND ",
    quoteIdentifier(encounter_column),
    " IN (\n    ",
    main_encounter_subquery,
    "\n  )"
  )
}

getFilteredScopePatientFilterCondition <- function(table_metadata, grouping_columns, patient_subquery) {
  if (is.na(patient_subquery) || is.na(grouping_columns[["pid"]])) {
    return(NA_character_)
  }

  patient_column <- grouping_columns[["pid"]]
  data_types <- getMetadataDataTypes(table_metadata)
  paste0(
    getValueAvailableCondition(patient_column, table_metadata, data_types),
    " AND ",
    quoteIdentifier(patient_column),
    " IN (\n    ",
    patient_subquery,
    "\n  )"
  )
}

getFilteredScopeFilterCondition <- function(
  table_metadata,
  grouping_columns,
  main_encounter_subquery,
  patient_subquery
) {
  reference_scope <- getResourceReferenceScope(grouping_columns, table_metadata)
  if (identical(reference_scope, "case_dependent")) {
    return(getFilteredScopeCaseFilterCondition(
      table_metadata,
      grouping_columns,
      main_encounter_subquery
    ))
  }
  if (identical(reference_scope, "patient_dependent")) {
    return(getFilteredScopePatientFilterCondition(
      table_metadata,
      grouping_columns,
      patient_subquery
    ))
  }
  NA_character_
}

initializeFilteredScopeSheet <- function(result, table_names) {
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

createFilteredScopeFhirSheet <- function(
  metadata,
  result,
  config,
  history_metadata = NULL,
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  if (!isFilteredScopeSheetConfigured("FHIR", config)) {
    return(NULL)
  }

  main_encounter_subquery <- getFilteredScopeMainEncounterSubquery(metadata)
  patient_subquery <- getFilteredScopePatientSubquery(metadata)
  if (is.na(main_encounter_subquery)) {
    logProgress(
      "Skipping ",
      getFilteredScopeSheetName("FHIR", config),
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
          getFilteredScopeSheetName("FHIR", config),
          " sheet: ",
          conditionMessage(error)
        )
        NULL
      }
    )
    if (is.null(grouping_columns)) {
      next
    }

    row_filter_condition <- getFilteredScopeFilterCondition(
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

  sheet <- initializeFilteredScopeSheet(result, names(table_configs))
  for (table_name in names(table_configs)) {
    table_config <- table_configs[[table_name]]
    data_columns <- table_config$table_metadata$COLUMN_NAME
    column_batches <- split(data_columns, ceiling(seq_along(data_columns) / config$count_batch_size))
    for (data_column_batch in column_batches) {
      fillCountAndDateRangeColumns(
        sheet,
        table_name,
        table_config$table_metadata,
        table_config$grouping_columns,
        data_column_batch,
        config,
        history_metadata = history_metadata,
        query_fun = query_fun,
        row_filter_condition = table_config$row_filter_condition,
        lock_label = paste(getFilteredScopeLabel(config), table_name)
      )
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

createFilteredScopeResourceDetailSheet <- function(
  metadata,
  result,
  config,
  detail_config,
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  if (!isFilteredScopeSheetConfigured(detail_config$sheet_name, config)) {
    return(NULL)
  }

  main_encounter_subquery <- getFilteredScopeMainEncounterSubquery(metadata)
  patient_subquery <- getFilteredScopePatientSubquery(metadata)
  if (is.na(main_encounter_subquery)) {
    return(NULL)
  }

  table_metadata <- getTableMetadata(metadata, detail_config$table_name)
  if (!nrow(table_metadata)) {
    return(NULL)
  }

  grouping_columns <- tryCatch(
    inferGroupingColumns(table_metadata, config),
    error = function(error) {
      logProgress(
        "Skipping ",
        detail_config$sheet_name,
        " ",
        getFilteredScopeLabel(config),
        " detail sheet: ",
        conditionMessage(error)
      )
      NULL
    }
  )
  if (is.null(grouping_columns)) {
    return(NULL)
  }

  row_filter_condition <- getFilteredScopeFilterCondition(
    table_metadata,
    grouping_columns,
    main_encounter_subquery,
    patient_subquery
  )
  if (is.na(row_filter_condition)) {
    return(NULL)
  }

  createResourceDetailSheet(
    metadata,
    result,
    config,
    detail_config,
    query_fun = query_fun,
    row_filter_condition = row_filter_condition
  )
}

createFilteredScopeResourceDetailSheets <- function(
  metadata,
  result,
  config,
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  sheets <- list()
  resource_detail_sheets <- config$resource_detail_sheets
  if (is.null(resource_detail_sheets) || !length(resource_detail_sheets)) {
    return(sheets)
  }

  for (detail_config in resource_detail_sheets) {
    detail_sheet <- createFilteredScopeResourceDetailSheet(
      metadata,
      result,
      config,
      detail_config,
      query_fun = query_fun
    )
    if (!is.null(detail_sheet) && nrow(detail_sheet)) {
      sheets[[getFilteredScopeSheetName(detail_config$sheet_name, config)]] <- detail_sheet
    }
  }

  sheets
}

createFilteredScopeFhirSheets <- function(
  metadata,
  result,
  config,
  history_metadata = NULL,
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  sheet <- createFilteredScopeFhirSheet(
    metadata,
    result,
    config,
    history_metadata = history_metadata,
    query_fun = query_fun
  )
  if (is.null(sheet) || !nrow(sheet)) {
    return(list())
  }

  stats::setNames(list(sheet), getFilteredScopeSheetName("FHIR", config))
}
