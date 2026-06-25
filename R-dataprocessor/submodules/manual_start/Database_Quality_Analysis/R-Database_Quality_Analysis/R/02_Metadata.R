normalizeViewName <- function(view_name, config) {
  table_name <- view_name
  if (startsWith(table_name, config$view_prefix)) {
    table_name <- substring(table_name, nchar(config$view_prefix) + 1L)
  }
  if (endsWith(table_name, config$view_postfix)) {
    table_name <- substr(table_name, 1L, nchar(table_name) - nchar(config$view_postfix))
  }
  table_name
}

normalizeColumnDescription <- function(column_description) {
  ifelse(
    is.na(column_description),
    NA_character_,
    sub("\\s+\\([A-Za-z0-9_ ]+\\)$", "", column_description, perl = TRUE)
  )
}

getTableFamily <- function(table_name) {
  if (endsWith(table_name, "_fe")) {
    return("Frontend")
  }
  if (identical(table_name, "pids_per_ward")) {
    return("Other")
  }
  "FHIR"
}

isIncludedView <- function(view_name, config) {
  matches_pattern <- any(vapply(
    config$included_view_patterns,
    grepl,
    logical(1),
    x = view_name,
    perl = TRUE
  ))
  excluded <- any(vapply(
    config$excluded_view_patterns,
    grepl,
    logical(1),
    x = view_name,
    perl = TRUE
  ))
  (matches_pattern || view_name %in% config$additional_views) && !excluded
}

loadViewMetadata <- function(config) {
  logProgress("Loading view metadata from schema ", config$view_schema, ".")
  query <- paste0(
    "SELECT c.table_schema,\n",
    "       c.table_name AS view_name,\n",
    "       c.column_name,\n",
    "       c.ordinal_position,\n",
    "       c.data_type,\n",
    "       col_description((quote_ident(c.table_schema) || '.' || ",
    "quote_ident(c.table_name))::regclass::oid, c.ordinal_position) AS column_description\n",
    "FROM information_schema.columns c\n",
    "JOIN information_schema.views v\n",
    "  ON v.table_schema = c.table_schema\n",
    " AND v.table_name = c.table_name\n",
    "WHERE c.table_schema = $1\n",
    "ORDER BY c.table_name, c.ordinal_position"
  )

  metadata <- etlutils::dbGetReadOnlyQuery(
    query,
    params = list(config$view_schema),
    lock_id = "load database quality analysis view metadata"
  )
  metadata <- normalizeMetadata(metadata, config)
  table_counts <- unique(metadata[, .(TABLE_FAMILY, TABLE_NAME)])[, .N, by = TABLE_FAMILY]
  logProgress(
    "Loaded metadata for ",
    data.table::uniqueN(metadata$TABLE_NAME),
    " tables and ",
    nrow(metadata),
    " report columns: ",
    paste(paste(table_counts$TABLE_FAMILY, table_counts$N, sep = "="), collapse = ", "),
    "."
  )
  metadata
}

loadHistoryMetadata <- function(config) {
  logProgress("Loading historical view metadata for value datetime columns.")
  query <- paste0(
    "SELECT c.table_schema,\n",
    "       c.table_name AS view_name,\n",
    "       c.column_name,\n",
    "       c.data_type\n",
    "FROM information_schema.columns c\n",
    "JOIN information_schema.views v\n",
    "  ON v.table_schema = c.table_schema\n",
    " AND v.table_name = c.table_name\n",
    "WHERE c.table_schema = $1\n",
    "ORDER BY c.table_name, c.ordinal_position"
  )

  metadata <- etlutils::dbGetReadOnlyQuery(
    query,
    params = list(config$view_schema),
    lock_id = "load database quality analysis history metadata"
  )
  metadata <- data.table::as.data.table(metadata)
  data.table::setnames(
    metadata,
    old = c("table_schema", "view_name", "column_name", "data_type"),
    new = c("VIEW_SCHEMA", "VIEW_NAME", "COLUMN_NAME", "DATA_TYPE"),
    skip_absent = TRUE
  )
  metadata[]
}

loadDatabaseMetadata <- function() {
  logProgress("Loading neutral database metadata.")
  query <- paste0(
    "SELECT 'PostgreSQL' AS dbms,\n",
    "       current_setting('server_version') AS server_version,\n",
    "       current_setting('server_encoding') AS server_encoding"
  )

  metadata <- etlutils::dbGetReadOnlyQuery(
    query,
    lock_id = "load database quality analysis database metadata"
  )
  data.table::as.data.table(metadata)
}

normalizeMetadata <- function(metadata, config) {
  metadata <- data.table::as.data.table(metadata)
  if (!nrow(metadata)) {
    return(data.table::data.table(
      VIEW_SCHEMA = character(),
      VIEW_NAME = character(),
      TABLE_NAME = character(),
      TABLE_FAMILY = character(),
      COLUMN_NAME = character(),
      COLUMN_DESCRIPTION = character(),
      ORDINAL_POSITION = integer(),
      DATA_TYPE = character()
    ))
  }

  data.table::setnames(
    metadata,
    old = c("table_schema", "view_name", "column_name", "ordinal_position", "data_type", "column_description"),
    new = c("VIEW_SCHEMA", "VIEW_NAME", "COLUMN_NAME", "ORDINAL_POSITION", "DATA_TYPE", "COLUMN_DESCRIPTION"),
    skip_absent = TRUE
  )

  metadata <- metadata[
    vapply(VIEW_NAME, isIncludedView, logical(1), config = config)
  ]
  metadata[, TABLE_NAME := vapply(VIEW_NAME, normalizeViewName, character(1), config = config)]
  metadata[, TABLE_FAMILY := vapply(TABLE_NAME, getTableFamily, character(1))]
  metadata[, COLUMN_DESCRIPTION := normalizeColumnDescription(COLUMN_DESCRIPTION)]
  metadata <- metadata[!isTechnicalColumn(TABLE_NAME, COLUMN_NAME, config)]
  metadata[]
}

getHistoryViewName <- function(table_name, config) {
  paste0(config$view_prefix, table_name)
}

getDateSources <- function(table_metadata, history_table_metadata, config) {
  sources <- data.table::data.table(
    source_name = character(),
    column_name = character(),
    first_result_column = character(),
    last_result_column = character()
  )

  if (config$value_import_datetime_column %in% history_table_metadata$COLUMN_NAME) {
    sources <- rbind(
      sources,
      data.table::data.table(
        source_name = "import",
        column_name = config$value_import_datetime_column,
        first_result_column = DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[["first_import"]],
        last_result_column = DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[["last_import"]]
      )
    )
  }

  if (identical(table_metadata$TABLE_FAMILY[[1]], "FHIR")) {
    meta_last_updated_column <- grep("_meta_lastupdated$", history_table_metadata$COLUMN_NAME, value = TRUE)
    if (length(meta_last_updated_column)) {
      sources <- rbind(
        sources,
        data.table::data.table(
          source_name = "meta_last_updated",
          column_name = meta_last_updated_column[[1]],
          first_result_column = DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[["first_meta_last_updated"]],
          last_result_column = DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS[["last_meta_last_updated"]]
        )
      )
    }
  }

  sources
}

isTechnicalColumn <- function(table_name, column_name, config) {
  column_name %in% config$technical_columns |
    endsWith(column_name, "_raw_id") |
    column_name == paste0(table_name, "_id")
}
