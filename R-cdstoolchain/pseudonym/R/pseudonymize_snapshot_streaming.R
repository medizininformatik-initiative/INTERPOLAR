SNAPSHOT_STREAMING_BIRTHDATE_COLUMN <- ".snapshot_pseudonym_birthdate"
SNAPSHOT_MEDICATION_REVIEW_DETAIL_LIMIT <- 1000L
DEFAULT_SNAPSHOT_CHUNK_SIZE <- 25000L

snapshotRelationId <- function(name, schema = NULL) {
  if (!is.null(schema) && !is.na(schema) && nzchar(schema)) {
    return(DBI::Id(schema = schema, table = name))
  }
  name
}

snapshotRelationFields <- function(connection, name, schema = NULL) {
  DBI::dbListFields(connection, snapshotRelationId(name, schema))
}

snapshotQuotedColumn <- function(connection, name, alias = NULL) {
  column <- as.character(DBI::dbQuoteIdentifier(connection, name))
  if (is.null(alias)) {
    return(column)
  }
  paste0(alias, ".", column)
}

snapshotSelectColumns <- function(connection, fields, alias, exclude = character()) {
  fields <- fields[!fields %in% exclude]
  paste(vapply(
    fields,
    snapshotQuotedColumn,
    character(1),
    connection = connection,
    alias = alias
  ), collapse = ", ")
}

snapshotDependencySuffix <- function(plan_row, last_version_suffix) {
  if (identical(plan_row[["SNAPSHOT_RELATION_TYPE"]], "last_version")) {
    return(last_version_suffix)
  }
  ""
}

buildSnapshotMedicationSourceQuery <- function(
  connection,
  source_relation,
  source_fields,
  medication_relation,
  spec,
  enrichment_columns = c(spec[["system_column"]], spec[["code_column"]])
) {
  source_alias <- "snapshot_source"
  medication_alias <- "medication_codes"
  reference_column <- spec[["reference_column"]]
  system_column <- spec[["system_column"]]
  code_column <- spec[["code_column"]]
  source_columns <- snapshotSelectColumns(
    connection,
    source_fields,
    source_alias,
    exclude = c(system_column, code_column)
  )
  quoted_reference <- snapshotQuotedColumn(connection, reference_column, source_alias)
  quoted_med_id <- snapshotQuotedColumn(connection, "med_id")
  quoted_med_system <- snapshotQuotedColumn(connection, "med_code_system")
  quoted_med_code <- snapshotQuotedColumn(connection, "med_code_code")
  normalized_reference <- paste0(
    "regexp_replace(regexp_replace(", quoted_reference,
    "::text, '^\\[[^]]+\\]', ''), '^Medication/', '')"
  )

  enrichment_select <- c(
    if (system_column %in% enrichment_columns) {
      paste0(
        medication_alias, ".medication_system AS ",
        snapshotQuotedColumn(connection, system_column)
      )
    },
    if (code_column %in% enrichment_columns) {
      paste0(
        medication_alias, ".medication_code AS ",
        snapshotQuotedColumn(connection, code_column)
      )
    }
  )

  paste0(
    "WITH ", medication_alias, " AS (",
    "SELECT DISTINCT ", quoted_med_id, "::text AS medication_id, ",
    quoted_med_system, " AS medication_system, ",
    quoted_med_code, " AS medication_code FROM ", medication_relation, " ",
    "WHERE NULLIF(", quoted_med_id, "::text, '') IS NOT NULL ",
    "AND NULLIF(", quoted_med_system, "::text, '') IS NOT NULL ",
    "AND NULLIF(", quoted_med_code, "::text, '') IS NOT NULL)",
    " SELECT ", source_columns, ", ", paste(enrichment_select, collapse = ", "),
    " FROM ", source_relation, " ", source_alias,
    " LEFT JOIN ", medication_alias,
    " ON ", medication_alias, ".medication_id = ", normalized_reference
  )
}

buildSnapshotBirthdateMapQuery <- function(
  connection,
  source_relation,
  source_fields,
  patient_relation,
  source_key_columns,
  patient_key_columns,
  patient_birthdate_column,
  source_reference_type = NULL
) {
  source_alias <- "snapshot_source"
  birthdate_alias <- "patient_birthdates"
  source_columns <- snapshotSelectColumns(
    connection,
    source_fields,
    source_alias,
    exclude = SNAPSHOT_STREAMING_BIRTHDATE_COLUMN
  )
  patient_birthdate <- snapshotQuotedColumn(connection, patient_birthdate_column)
  patient_key_queries <- vapply(patient_key_columns, function(column_name) {
    patient_key <- snapshotQuotedColumn(connection, column_name)
    paste0(
      "SELECT NULLIF(", patient_key, "::text, '') AS patient_key, ",
      patient_birthdate, " AS birthdate FROM ", patient_relation
    )
  }, character(1))
  source_keys <- vapply(source_key_columns, function(column_name) {
    key <- snapshotQuotedColumn(connection, column_name, source_alias)
    if (!is.null(source_reference_type)) {
      return(paste0(
        "NULLIF(regexp_replace(regexp_replace(", key,
        "::text, '^\\[[^]]+\\]', ''), '^", source_reference_type, "/', ''), '')"
      ))
    }
    paste0("NULLIF(", key, "::text, '')")
  }, character(1))
  source_key <- if (length(source_keys) == 1) {
    source_keys
  } else {
    paste0("COALESCE(", paste(source_keys, collapse = ", "), ")")
  }
  hidden_birthdate <- snapshotQuotedColumn(
    connection,
    SNAPSHOT_STREAMING_BIRTHDATE_COLUMN
  )

  paste0(
    "WITH ", birthdate_alias, " AS (",
    "SELECT patient_key, MIN(birthdate) AS birthdate FROM (",
    paste(patient_key_queries, collapse = " UNION ALL "),
    ") patient_birthdate_candidates WHERE patient_key IS NOT NULL ",
    "GROUP BY patient_key)",
    " SELECT ", source_columns, ", ", birthdate_alias, ".birthdate AS ",
    hidden_birthdate,
    " FROM ", source_relation, " ", source_alias,
    " LEFT JOIN ", birthdate_alias,
    " ON ", birthdate_alias, ".patient_key = ", source_key
  )
}

getSnapshotStreamingSourceQuery <- function(
  connection,
  plan_row,
  source_schema,
  source_view_prefix,
  last_version_suffix,
  described_columns
) {
  source_relation_name <- plan_row[["SOURCE_RELATION"]]
  source_relation <- snapshotQualifiedName(
    connection,
    source_relation_name,
    source_schema
  )
  source_fields <- snapshotRelationFields(
    connection,
    source_relation_name,
    source_schema
  )
  base_table_name <- plan_row[["BASE_TABLE_NAME"]]
  dependency_suffix <- snapshotDependencySuffix(plan_row, last_version_suffix)
  medication_spec <- getMedicationReferenceSpec(base_table_name)
  medication_enrichment_columns <- if (!is.null(medication_spec)) {
    intersect(
      c(medication_spec[["system_column"]], medication_spec[["code_column"]]),
      described_columns
    )
  } else {
    character()
  }
  if (!is.null(medication_spec) && length(medication_enrichment_columns) > 0) {
    medication_relation_name <- paste0(
      source_view_prefix,
      "medication",
      dependency_suffix
    )
    required_source_fields <- medication_spec[["reference_column"]]
    required_medication_fields <- c("med_id", "med_code_system", "med_code_code")
    if (
      required_source_fields %in% described_columns &&
      required_source_fields %in% source_fields &&
      snapshotRelationExists(connection, medication_relation_name, source_schema)
    ) {
      medication_fields <- snapshotRelationFields(
        connection,
        medication_relation_name,
        source_schema
      )
      if (all(required_medication_fields %in% medication_fields)) {
        return(list(
          query = buildSnapshotMedicationSourceQuery(
            connection,
            source_relation,
            source_fields,
            snapshotQualifiedName(
              connection,
              medication_relation_name,
              source_schema
            ),
            medication_spec,
            medication_enrichment_columns
          ),
          medication_spec = medication_spec
        ))
      }
    }
  }

  if (
    identical(base_table_name, "fall_fe") &&
    "fall_age_at_admission" %in% described_columns
  ) {
    patient_relation_name <- paste0(
      source_view_prefix,
      "patient_fe",
      dependency_suffix
    )
    source_key_columns <- intersect(
      intersect(c("patient_id_fk", "fall_pat_id"), source_fields),
      described_columns
    )
    if (
      length(source_key_columns) > 0 &&
      "fall_aufn_dat" %in% described_columns &&
      "fall_aufn_dat" %in% source_fields &&
      snapshotRelationExists(connection, patient_relation_name, source_schema)
    ) {
      patient_fields <- snapshotRelationFields(
        connection,
        patient_relation_name,
        source_schema
      )
      patient_key_columns <- intersect(c("record_id", "pat_id"), patient_fields)
      if (length(patient_key_columns) > 0 && "pat_gebdat" %in% patient_fields) {
        return(list(
          query = buildSnapshotBirthdateMapQuery(
            connection,
            source_relation,
            source_fields,
            snapshotQualifiedName(
              connection,
              patient_relation_name,
              source_schema
            ),
            source_key_columns,
            patient_key_columns,
            "pat_gebdat"
          ),
          medication_spec = NULL
        ))
      }
    }
  }

  if (
    identical(base_table_name, "encounter") &&
    "enc_age_at_admission" %in% described_columns
  ) {
    patient_relation_name <- paste0(source_view_prefix, "patient", dependency_suffix)
    if (
      all(c("enc_patient_ref", "enc_period_start") %in% described_columns) &&
      all(c("enc_patient_ref", "enc_period_start") %in% source_fields) &&
      snapshotRelationExists(connection, patient_relation_name, source_schema)
    ) {
      patient_fields <- snapshotRelationFields(
        connection,
        patient_relation_name,
        source_schema
      )
      if (all(c("pat_id", "pat_birthdate") %in% patient_fields)) {
        return(list(
          query = buildSnapshotBirthdateMapQuery(
            connection,
            source_relation,
            source_fields,
            snapshotQualifiedName(
              connection,
              patient_relation_name,
              source_schema
            ),
            "enc_patient_ref",
            "pat_id",
            "pat_birthdate",
            source_reference_type = "Patient"
          ),
          medication_spec = NULL
        ))
      }
    }
  }

  list(
    query = paste0("SELECT * FROM ", source_relation),
    medication_spec = NULL
  )
}

newSnapshotStreamingContext <- function(input_repo_path) {
  context <- new.env(parent = emptyenv())
  context$input_repo_path <- input_repo_path
  context$loinc_mapping <- NULL
  context$mapping_context <- newPseudonymMappingContext(input_repo_path)
  context$medication_review <- newBoundedMedicationReferenceReview(
    SNAPSHOT_MEDICATION_REVIEW_DETAIL_LIMIT
  )
  context
}

enrichSnapshotStreamingChunk <- function(
  table,
  base_table_name,
  context,
  described_columns = names(table)
) {
  table <- data.table::as.data.table(table)
  birthdates <- NULL
  if (SNAPSHOT_STREAMING_BIRTHDATE_COLUMN %in% names(table)) {
    birthdates <- table[[SNAPSHOT_STREAMING_BIRTHDATE_COLUMN]]
    table[[SNAPSHOT_STREAMING_BIRTHDATE_COLUMN]] <- NULL
  }

  if (identical(base_table_name, "fall_fe")) {
    enrichment_columns <- intersect(
      c("fall_age_at_admission", "fall_bmi"),
      described_columns
    )
    return(enrichSnapshotFallChunk(
      table,
      birthdates,
      enrichment_columns,
      described_columns
    ))
  }
  if (identical(base_table_name, "encounter")) {
    enrichment_columns <- intersect("enc_age_at_admission", described_columns)
    return(enrichSnapshotEncounterChunk(
      table,
      birthdates,
      enrichment_columns,
      described_columns
    ))
  }
  if (identical(base_table_name, "observation")) {
    enrichment_columns <- intersect(
      SNAPSHOT_OBSERVATION_ENRICHMENT_COLUMNS,
      described_columns
    )
    has_source_columns <- all(
      SNAPSHOT_OBSERVATION_SOURCE_COLUMNS %in% described_columns
    ) && all(SNAPSHOT_OBSERVATION_SOURCE_COLUMNS %in% names(table))
    if (
      length(enrichment_columns) > 0 &&
      has_source_columns &&
      is.null(context$loinc_mapping)
    ) {
      context$loinc_mapping <- loadSnapshotLoincMapping(context$input_repo_path)
    }
    return(enrichObservationWithLoincMapping(
      table,
      context$loinc_mapping,
      enrichment_columns,
      described_columns
    ))
  }
  medication_spec <- getMedicationReferenceSpec(base_table_name)
  if (!is.null(medication_spec)) {
    enrichment_columns <- intersect(
      c(medication_spec[["system_column"]], medication_spec[["code_column"]]),
      described_columns
    )
    for (column_name in enrichment_columns) {
      if (!column_name %in% names(table)) {
        table[[column_name]] <- NA_character_
      }
    }
  }
  table
}

validateSnapshotChunkSize <- function(chunk_size) {
  if (is.null(chunk_size)) {
    chunk_size <- DEFAULT_SNAPSHOT_CHUNK_SIZE
  }
  chunk_size <- suppressWarnings(as.integer(chunk_size))
  if (length(chunk_size) != 1 || is.na(chunk_size) || chunk_size < 1) {
    stop("chunk_size must be a positive integer.")
  }
  chunk_size
}

processSnapshotChunkStream <- function(
  fetch_chunk,
  has_completed,
  enrich_chunk,
  pseudonymize_chunk,
  write_chunk,
  review_chunk,
  write_review_chunk,
  chunk_size,
  table_name
) {
  first_chunk <- TRUE
  chunk_number <- 0L
  summary <- NULL
  repeat {
    chunk <- fetch_chunk(chunk_size)
    chunk_number <- chunk_number + 1L
    chunk <- enrich_chunk(data.table::as.data.table(chunk))
    write_review_chunk(review_chunk(chunk))
    table_result <- pseudonymize_chunk(chunk, chunk_number)
    output <- table_result[["table"]]
    write_chunk(output, first_chunk)
    first_chunk <- FALSE
    if (is.null(summary)) {
      summary <- table_result[["summary"]]
      summary[["INPUT_ROWS"]] <- 0L
      summary[["OUTPUT_ROWS"]] <- 0L
    }
    summary[["INPUT_ROWS"]] <- summary[["INPUT_ROWS"]] + nrow(chunk)
    summary[["OUTPUT_ROWS"]] <- summary[["OUTPUT_ROWS"]] + nrow(output)
    message(
      "Processed snapshot chunk ", chunk_number,
      " for ", table_name,
      ": ", nrow(chunk), " input rows, ", nrow(output), " output rows"
    )
    rm(chunk, output, table_result)
    if (has_completed()) {
      break
    }
  }

  list(
    summary = summary,
    chunks = chunk_number
  )
}

streamSnapshotMaterializedTable <- function(
  source_connection,
  target_connection,
  plan_row,
  rules,
  input_repo_path,
  source_schema,
  target_table_schema,
  source_view_prefix,
  last_version_suffix,
  chunk_size,
  streaming_context,
  log_steps
) {
  materialized_table_name <- plan_row[["MATERIALIZED_TABLE_NAME"]]
  source_relation_name <- plan_row[["SOURCE_RELATION"]]
  base_table_name <- plan_row[["BASE_TABLE_NAME"]]
  rule_table_name <- plan_row[["RULE_TABLE_NAME"]]
  rule_source <- plan_row[["RULE_SOURCE"]]
  table_rules <- getPseudonymizationRulesForTable(
    rules,
    rule_table_name,
    source = rule_source
  )
  described_columns <- unique(table_rules[["COLUMN_NAME"]])
  if (snapshotRelationExists(
    target_connection,
    materialized_table_name,
    target_table_schema
  )) {
    stop(
      "Target table already exists: ",
      snapshotQualifiedName(
        target_connection,
        materialized_table_name,
        target_table_schema
      )
    )
  }

  query_info <- getSnapshotStreamingSourceQuery(
    source_connection,
    plan_row,
    source_schema,
    source_view_prefix,
    last_version_suffix,
    described_columns
  )
  message(
    "Streaming snapshot source relation ",
    snapshotQualifiedName(source_connection, source_relation_name, source_schema),
    " as ", materialized_table_name,
    " in chunks of ", chunk_size, " rows"
  )
  source_result <- tryCatch(
    DBI::dbSendQuery(source_connection, query_info[["query"]]),
    error = function(error) {
      stop(
        "Failed to open snapshot source relation ", source_relation_name,
        " as ", materialized_table_name, ": ", conditionMessage(error),
        call. = FALSE
      )
    }
  )
  on.exit(
    {
      if (DBI::dbIsValid(source_result)) {
        DBI::dbClearResult(source_result)
      }
    },
    add = TRUE
  )

  target <- snapshotRelationId(materialized_table_name, target_table_schema)
  stream_result <- processSnapshotChunkStream(
    fetch_chunk = function(fetch_size) {
      tryCatch(
        DBI::dbFetch(source_result, n = fetch_size),
        error = function(error) {
          stop(
            "Failed to fetch snapshot source relation ", source_relation_name,
            " as ", materialized_table_name, ": ", conditionMessage(error),
            call. = FALSE
          )
        }
      )
    },
    has_completed = function() DBI::dbHasCompleted(source_result),
    enrich_chunk = function(chunk) {
      enrichSnapshotStreamingChunk(
        chunk,
        base_table_name,
        streaming_context,
        described_columns
      )
    },
    pseudonymize_chunk = function(chunk, chunk_number) {
      runPseudonymizationLogStep(
        3L,
        paste0("Pseudonymize chunk ", chunk_number, " of ", materialized_table_name),
        pseudonymizeTableForSnapshot(
          chunk,
          rules,
          rule_table_name,
          rule_source,
          input_repo_path,
          mapping_context = streaming_context$mapping_context
        ),
        log_steps = log_steps
      )
    },
    write_chunk = function(output, first_chunk) {
      if (isTRUE(first_chunk)) {
        DBI::dbWriteTable(
          target_connection,
          target,
          output,
          overwrite = FALSE,
          temporary = FALSE
        )
      } else if (nrow(output) > 0) {
        DBI::dbAppendTable(target_connection, target, output)
      }
    },
    review_chunk = function(chunk) {
      if (is.null(query_info[["medication_spec"]])) {
        return(emptyMedicationReferenceReport())
      }
      getUnmatchedMedicationReferencesFromEnrichedTable(
        chunk,
        materialized_table_name,
        query_info[["medication_spec"]]
      )
    },
    write_review_chunk = function(review) {
      recordBoundedMedicationReferenceReview(
        streaming_context$medication_review,
        review
      )
    },
    chunk_size = chunk_size,
    table_name = materialized_table_name
  )
  summary <- stream_result[["summary"]]

  summary[["TABLE_NAME"]] <- materialized_table_name
  summary[["BASE_TABLE_NAME"]] <- base_table_name
  summary[["RULE_TABLE_NAME"]] <- rule_table_name
  summary[["RULE_SOURCE"]] <- rule_source
  summary[["SNAPSHOT_RELATION_TYPE"]] <- plan_row[["SNAPSHOT_RELATION_TYPE"]]
  summary[["ORIGINAL_COLUMNS_REMOVED"]] <- 0L
  summary[["DUPLICATE_ROWS_REMOVED"]] <- 0L
  summary[["POSTPROCESSING_ACTION"]] <- "none"

  list(
    summary = summary,
    write_summary = data.table::data.table(
      TABLE_NAME = materialized_table_name,
      ROWS = summary[["OUTPUT_ROWS"]],
      COLUMNS = summary[["OUTPUT_COLUMNS"]],
      STATUS = "written"
    )
  )
}

getExistingSnapshotMaterializationPlan <- function(
  connection,
  rules,
  source_schema,
  source_view_prefix,
  last_version_suffix,
  tables
) {
  plan <- getSnapshotSourceViewPlan(
    rules,
    source_view_prefix = source_view_prefix,
    last_version_suffix = last_version_suffix,
    tables = tables
  )
  existing_rows <- rep(FALSE, nrow(plan))
  for (i in seq_len(nrow(plan))) {
    relation_exists <- snapshotRelationExists(
      connection,
      plan[["SOURCE_RELATION"]][i],
      source_schema
    )
    if (!relation_exists && plan[["SNAPSHOT_RELATION_TYPE"]][i] == "all") {
      stop("Required source relation does not exist: ", plan[["SOURCE_RELATION"]][i])
    }
    existing_rows[i] <- relation_exists
  }
  plan[existing_rows, , drop = FALSE]
}
