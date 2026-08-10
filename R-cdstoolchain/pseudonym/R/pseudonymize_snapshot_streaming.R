SNAPSHOT_STREAMING_BIRTHDATE_COLUMN <- ".snapshot_pseudonym_birthdate"
SNAPSHOT_STREAMING_PATIENT_KEY_COLUMN <- ".snapshot_pseudonym_patient_key"
SNAPSHOT_MEDICATION_REVIEW_DETAIL_LIMIT <- 1000L
SNAPSHOT_AGE_REVIEW_DETAIL_LIMIT <- 1000L
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

snapshotNormalizedReferenceExpression <- function(
  connection,
  column_name,
  alias = NULL,
  resource_type = "Medication"
) {
  quoted_reference <- snapshotQuotedColumn(connection, column_name, alias)
  paste0(
    "NULLIF(regexp_replace(regexp_replace(", quoted_reference,
    "::text, '^\\[[^]]+\\]', ''), '^", resource_type, "/', ''), '')"
  )
}

indentSql <- function(sql, spaces = 2L) {
  indentation <- strrep(" ", spaces)
  paste0(
    indentation,
    gsub("\n", paste0("\n", indentation), sql, fixed = TRUE)
  )
}

buildSnapshotMedicationResolutionQuery <- function(
  connection,
  source_root_queries,
  medication_relation,
  ingredient_reference_column =
    SNAPSHOT_MEDICATION_INGREDIENT_REFERENCE_COLUMN
) {
  quoted_med_id <- snapshotQuotedColumn(connection, "med_id")
  quoted_med_system <- snapshotQuotedColumn(connection, "med_code_system")
  quoted_med_code <- snapshotQuotedColumn(connection, "med_code_code")
  medication_nodes_query <- paste0(
    "SELECT DISTINCT ", quoted_med_id, "::text AS medication_id\n",
    "FROM ", medication_relation, "\n",
    "WHERE NULLIF(", quoted_med_id, "::text, '') IS NOT NULL"
  )
  medication_edges_query <- if (is.null(ingredient_reference_column)) {
    paste(
      "SELECT NULL::text AS source_medication_id,",
      "NULL::text AS target_medication_id",
      "WHERE FALSE"
    )
  } else {
    normalized_ingredient_reference <- snapshotNormalizedReferenceExpression(
      connection,
      ingredient_reference_column
    )
    paste0(
      "SELECT DISTINCT ", quoted_med_id,
      "::text AS source_medication_id,\n",
      "  ", normalized_ingredient_reference, " AS target_medication_id\n",
      "FROM ", medication_relation, "\n",
      "WHERE NULLIF(", quoted_med_id, "::text, '') IS NOT NULL\n",
      "  AND ", normalized_ingredient_reference, " IS NOT NULL"
    )
  }
  source_roots_query <- paste(
    "SELECT DISTINCT root_medication_id",
    "FROM (",
    indentSql(paste(source_root_queries, collapse = "\nUNION ALL\n")),
    ") medication_root_candidates",
    "WHERE root_medication_id IS NOT NULL",
    sep = "\n"
  )
  medication_walk_query <- paste(
    "SELECT root_medication_id, root_medication_id",
    "FROM source_roots",
    # UNION deduplicates every root/node pair, so cycles terminate naturally.
    "UNION",
    "SELECT medication_walk.root_medication_id,",
    "  medication_edges.target_medication_id",
    "FROM medication_walk",
    "JOIN medication_edges",
    "  ON medication_edges.source_medication_id = medication_walk.medication_id",
    sep = "\n"
  )
  medication_code_values_query <- paste0(
    "SELECT DISTINCT medication_walk.root_medication_id,\n",
    "  medication.", quoted_med_system, " AS medication_system,\n",
    "  medication.", quoted_med_code, " AS medication_code\n",
    "FROM medication_walk\n",
    "JOIN ", medication_relation, " medication\n",
    "  ON medication.", quoted_med_id,
    "::text = medication_walk.medication_id\n",
    "WHERE NULLIF(medication.", quoted_med_system,
    "::text, '') IS NOT NULL\n",
    "  AND NULLIF(medication.", quoted_med_code, "::text, '') IS NOT NULL"
  )
  medication_codes_query <- paste(
    "SELECT root_medication_id, medication_system, medication_code,",
    "  row_number() OVER (",
    "    PARTITION BY root_medication_id",
    "    ORDER BY medication_system, medication_code",
    "  ) AS code_number",
    "FROM medication_code_values",
    sep = "\n"
  )
  medication_issues_query <- paste(
    "SELECT DISTINCT medication_walk.root_medication_id,",
    "  'missing_medication'::text AS issue_type,",
    "  medication_walk.medication_id AS related_medication_id",
    "FROM medication_walk",
    "LEFT JOIN medication_nodes",
    "  ON medication_nodes.medication_id = medication_walk.medication_id",
    "WHERE medication_nodes.medication_id IS NULL",
    "UNION",
    "SELECT source_roots.root_medication_id,",
    "  'no_reachable_code'::text AS issue_type,",
    "  source_roots.root_medication_id AS related_medication_id",
    "FROM source_roots",
    "JOIN medication_nodes",
    "  ON medication_nodes.medication_id = source_roots.root_medication_id",
    "WHERE NOT EXISTS (",
    "  SELECT 1",
    "  FROM medication_code_values",
    paste0(
      "  WHERE medication_code_values.root_medication_id = ",
      "source_roots.root_medication_id"
    ),
    ")",
    sep = "\n"
  )
  medication_issue_summary_query <- paste(
    "SELECT root_medication_id,",
    "  string_agg(",
    "    issue_type || E'\\t' || related_medication_id,",
    "    E'\\n' ORDER BY issue_type, related_medication_id",
    "  ) AS issues",
    "FROM medication_issues",
    "GROUP BY root_medication_id",
    sep = "\n"
  )
  ctes <- c(
    paste0(
      "medication_nodes AS (\n",
      indentSql(medication_nodes_query),
      "\n)"
    ),
    paste0(
      "medication_edges AS (\n",
      indentSql(medication_edges_query),
      "\n)"
    ),
    paste0(
      "source_roots AS (\n",
      indentSql(source_roots_query),
      "\n)"
    ),
    paste0(
      "medication_walk(root_medication_id, medication_id) AS (\n",
      indentSql(medication_walk_query),
      "\n)"
    ),
    paste0(
      "medication_code_values AS (\n",
      indentSql(medication_code_values_query),
      "\n)"
    ),
    paste0(
      "medication_codes AS (\n",
      indentSql(medication_codes_query),
      "\n)"
    ),
    paste0(
      "medication_issues AS (\n",
      indentSql(medication_issues_query),
      "\n)"
    ),
    paste0(
      "medication_issue_summary AS (\n",
      indentSql(medication_issue_summary_query),
      "\n)"
    )
  )
  paste0(
    "WITH RECURSIVE\n",
    paste(ctes, collapse = ",\n"),
    "\nSELECT source_roots.root_medication_id,\n",
    "  medication_codes.medication_system,\n",
    "  medication_codes.medication_code,\n",
    # Issues are stored once per root, not once per resolved code.
    "  CASE WHEN COALESCE(medication_codes.code_number, 1) = 1\n",
    "    THEN medication_issue_summary.issues\n",
    "    ELSE NULL\n",
    "  END AS issues\n",
    "FROM source_roots\n",
    "LEFT JOIN medication_codes\n",
    "  ON medication_codes.root_medication_id = source_roots.root_medication_id\n",
    "LEFT JOIN medication_issue_summary\n",
    "  ON medication_issue_summary.root_medication_id = ",
    "source_roots.root_medication_id"
  )
}

buildSnapshotMedicationSourceQuery <- function(
  connection,
  source_relation,
  source_fields,
  medication_resolution_relation,
  spec,
  enrichment_columns = c(spec[["system_column"]], spec[["code_column"]])
) {
  source_alias <- "snapshot_source"
  resolution_alias <- "medication_resolution"
  reference_column <- spec[["reference_column"]]
  system_column <- spec[["system_column"]]
  code_column <- spec[["code_column"]]
  source_columns <- snapshotSelectColumns(
    connection,
    source_fields,
    source_alias,
    exclude = c(system_column, code_column)
  )
  normalized_reference <- snapshotNormalizedReferenceExpression(
    connection,
    reference_column,
    source_alias
  )
  enrichment_select <- c(
    if (system_column %in% enrichment_columns) {
      paste0(
        resolution_alias, ".medication_system AS ",
        snapshotQuotedColumn(connection, system_column)
      )
    },
    if (code_column %in% enrichment_columns) {
      paste0(
        resolution_alias, ".medication_code AS ",
        snapshotQuotedColumn(connection, code_column)
      )
    }
  )
  issue_select <- paste0(
    resolution_alias, ".issues AS ",
    snapshotQuotedColumn(connection, SNAPSHOT_MEDICATION_REFERENCE_ISSUES_COLUMN)
  )

  paste0(
    "SELECT ",
    paste(
      c(source_columns, enrichment_select, issue_select),
      collapse = ",\n  "
    ),
    "\nFROM ", source_relation, " ", source_alias, "\n",
    "LEFT JOIN ", medication_resolution_relation, " ", resolution_alias, "\n",
    "  ON ", resolution_alias, ".root_medication_id = ", normalized_reference
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
    exclude = c(
      SNAPSHOT_STREAMING_BIRTHDATE_COLUMN,
      SNAPSHOT_STREAMING_PATIENT_KEY_COLUMN
    )
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
  hidden_patient_key <- snapshotQuotedColumn(
    connection,
    SNAPSHOT_STREAMING_PATIENT_KEY_COLUMN
  )

  paste0(
    "WITH ", birthdate_alias, " AS (",
    "SELECT patient_key, MIN(birthdate) AS birthdate FROM (",
    paste(patient_key_queries, collapse = " UNION ALL "),
    ") patient_birthdate_candidates WHERE patient_key IS NOT NULL ",
    "GROUP BY patient_key)",
    " SELECT ", source_columns, ", ", birthdate_alias, ".birthdate AS ",
    hidden_birthdate, ", ", birthdate_alias, ".patient_key AS ",
    hidden_patient_key,
    " FROM ", source_relation, " ", source_alias,
    " LEFT JOIN ", birthdate_alias,
    " ON ", birthdate_alias, ".patient_key = ", source_key
  )
}

getSnapshotMedicationRootQueries <- function(
  connection,
  materialization_plan,
  rules,
  relation_type,
  source_schema
) {
  plan_rows <- which(materialization_plan[["SNAPSHOT_RELATION_TYPE"]] == relation_type)
  root_queries <- list()
  for (row_index in plan_rows) {
    plan_row <- materialization_plan[row_index, ]
    medication_spec <- getMedicationReferenceSpec(plan_row[["BASE_TABLE_NAME"]])
    if (is.null(medication_spec)) {
      next
    }

    table_rules <- getPseudonymizationRulesForTable(
      rules,
      plan_row[["RULE_TABLE_NAME"]],
      source = plan_row[["RULE_SOURCE"]]
    )
    described_columns <- unique(table_rules[["COLUMN_NAME"]])
    enrichment_columns <- intersect(
      c(
        medication_spec[["system_column"]],
        medication_spec[["code_column"]]
      ),
      described_columns
    )
    reference_column <- medication_spec[["reference_column"]]
    source_relation_name <- plan_row[["SOURCE_RELATION"]]
    source_fields <- snapshotRelationFields(
      connection,
      source_relation_name,
      source_schema
    )
    if (
      length(enrichment_columns) == 0 ||
      !reference_column %in% described_columns ||
      !reference_column %in% source_fields
    ) {
      next
    }

    normalized_reference <- snapshotNormalizedReferenceExpression(
      connection,
      reference_column,
      alias = "snapshot_source"
    )
    source_relation <- snapshotQualifiedName(
      connection,
      source_relation_name,
      source_schema
    )
    root_queries[[length(root_queries) + 1L]] <- paste0(
      "SELECT DISTINCT ", normalized_reference,
      " AS root_medication_id\n",
      "FROM ", source_relation, " snapshot_source\n",
      "WHERE ", normalized_reference, " IS NOT NULL"
    )
  }
  unname(unlist(root_queries, use.names = FALSE))
}

prepareSnapshotMedicationResolutionTables <- function(
  connection,
  materialization_plan,
  rules,
  source_schema,
  source_view_prefix,
  last_version_suffix
) {
  resolution_tables <- list()
  relation_types <- unique(materialization_plan[["SNAPSHOT_RELATION_TYPE"]])
  for (relation_type in relation_types) {
    source_root_queries <- getSnapshotMedicationRootQueries(
      connection,
      materialization_plan,
      rules,
      relation_type,
      source_schema
    )
    if (length(source_root_queries) == 0) {
      next
    }

    medication_suffix <- if (identical(relation_type, "last_version")) {
      last_version_suffix
    } else {
      ""
    }
    medication_relation_name <- paste0(
      source_view_prefix,
      "medication",
      medication_suffix
    )
    if (!snapshotRelationExists(
      connection,
      medication_relation_name,
      source_schema
    )) {
      next
    }
    medication_fields <- snapshotRelationFields(
      connection,
      medication_relation_name,
      source_schema
    )
    required_medication_fields <- c(
      "med_id",
      "med_code_system",
      "med_code_code"
    )
    if (!all(required_medication_fields %in% medication_fields)) {
      next
    }

    medication_relation <- snapshotQualifiedName(
      connection,
      medication_relation_name,
      source_schema
    )
    resolution_query <- buildSnapshotMedicationResolutionQuery(
      connection,
      source_root_queries,
      medication_relation,
      ingredient_reference_column = if (
        SNAPSHOT_MEDICATION_INGREDIENT_REFERENCE_COLUMN %in%
          medication_fields
      ) {
        SNAPSHOT_MEDICATION_INGREDIENT_REFERENCE_COLUMN
      } else {
        NULL
      }
    )
    resolution_table_name <- basename(tempfile(
      pattern = paste0("snapshot_medication_resolution_", relation_type, "_")
    ))
    resolution_table <- snapshotQualifiedName(
      connection,
      resolution_table_name
    )
    created_rows <- DBI::dbExecute(
      connection,
      paste0("CREATE TEMP TABLE ", resolution_table, " AS\n", resolution_query)
    )
    DBI::dbExecute(
      connection,
      paste0("CREATE INDEX ON ", resolution_table, " (root_medication_id)")
    )
    DBI::dbExecute(connection, paste0("ANALYZE ", resolution_table))
    message(
      "Prepared shared Medication resolution for ", relation_type,
      ": ", created_rows, " root/code rows"
    )
    resolution_tables[[relation_type]] <- resolution_table_name
  }
  resolution_tables
}

dropSnapshotMedicationResolutionTables <- function(connection, tables) {
  for (table_name in unname(unlist(tables, use.names = FALSE))) {
    DBI::dbExecute(
      connection,
      paste0("DROP TABLE IF EXISTS ", snapshotQualifiedName(connection, table_name))
    )
  }
  invisible()
}

getSnapshotStreamingSourceQuery <- function(
  connection,
  plan_row,
  source_schema,
  source_view_prefix,
  last_version_suffix,
  described_columns,
  medication_resolution_tables = list()
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
    reference_column <- medication_spec[["reference_column"]]
    relation_type <- plan_row[["SNAPSHOT_RELATION_TYPE"]]
    resolution_table_name <- medication_resolution_tables[[relation_type]]
    if (
      reference_column %in% described_columns &&
      reference_column %in% source_fields &&
      !is.null(resolution_table_name)
    ) {
      return(list(
        query = buildSnapshotMedicationSourceQuery(
          connection,
          source_relation,
          source_fields,
          snapshotQualifiedName(connection, resolution_table_name),
          medication_spec,
          medication_enrichment_columns
        ),
        medication_spec = medication_spec
      ))
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

newSnapshotStreamingContext <- function(
  input_repo_path,
  medication_resolution_tables = list()
) {
  context <- new.env(parent = emptyenv())
  context$input_repo_path <- input_repo_path
  context$medication_resolution_tables <- medication_resolution_tables
  context$loinc_mapping <- NULL
  context$mapping_context <- newPseudonymMappingContext(input_repo_path)
  context$medication_review <- newBoundedMedicationReferenceReview(
    SNAPSHOT_MEDICATION_REVIEW_DETAIL_LIMIT
  )
  context$age_review <- newBoundedAgeCalculationReview(SNAPSHOT_AGE_REVIEW_DETAIL_LIMIT)
  context$loinc_unit_review <- newLoincUnitConversionReview()
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
      SNAPSHOT_OBSERVATION_ANALYSIS_COLUMNS,
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
  table_name,
  strip_review_columns = identity
) {
  first_chunk <- TRUE
  chunk_number <- 0L
  summary <- NULL
  repeat {
    chunk <- fetch_chunk(chunk_size)
    chunk_number <- chunk_number + 1L
    chunk <- enrich_chunk(data.table::as.data.table(chunk))
    write_review_chunk(review_chunk(chunk))
    chunk <- strip_review_columns(chunk)
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

stripSnapshotStreamingReviewColumns <- function(table) {
  table <- data.table::as.data.table(table)
  review_columns <- intersect(
    c(
      SNAPSHOT_MEDICATION_REFERENCE_ISSUES_COLUMN,
      SNAPSHOT_LOINC_CONVERSION_ISSUE_COLUMN,
      SNAPSHOT_LOINC_MAPPING_UNIT_COLUMN,
      SNAPSHOT_LOINC_TARGET_UNIT_COLUMN
    ),
    names(table)
  )
  if (length(review_columns) > 0) {
    for (review_column in review_columns) {
      table[[review_column]] <- NULL
    }
  }
  table
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
    described_columns,
    medication_resolution_tables =
      streaming_context$medication_resolution_tables
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
      medication_review <- if (is.null(query_info[["medication_spec"]])) {
        emptyMedicationReferenceReport()
      } else {
        getUnmatchedMedicationReferencesFromEnrichedTable(
          chunk,
          materialized_table_name,
          query_info[["medication_spec"]]
        )
      }
      age_review <- if (base_table_name %in% c("fall_fe", "encounter")) {
        birthdates <- if (SNAPSHOT_STREAMING_BIRTHDATE_COLUMN %in% names(chunk)) {
          chunk[[SNAPSHOT_STREAMING_BIRTHDATE_COLUMN]]
        } else {
          rep(as.Date(NA), nrow(chunk))
        }
        matched_patient_keys <- if (
          SNAPSHOT_STREAMING_PATIENT_KEY_COLUMN %in% names(chunk)
        ) {
          chunk[[SNAPSHOT_STREAMING_PATIENT_KEY_COLUMN]]
        } else {
          rep(NA_character_, nrow(chunk))
        }
        getAgeCalculationReview(
          chunk,
          materialized_table_name,
          base_table_name,
          birthdates,
          matched_patient_keys
        )
      } else {
        emptyAgeCalculationReview()
      }
      loinc_unit_review <- if (identical(base_table_name, "observation")) {
        getLoincUnitConversionReview(chunk, materialized_table_name)
      } else {
        emptyLoincUnitConversionReview()
      }
      list(
        medication = medication_review,
        age = age_review,
        loinc_unit = loinc_unit_review
      )
    },
    write_review_chunk = function(review) {
      recordBoundedMedicationReferenceReview(
        streaming_context$medication_review,
        review[["medication"]]
      )
      recordBoundedAgeCalculationReview(
        streaming_context$age_review,
        review[["age"]]
      )
      recordLoincUnitConversionReview(
        streaming_context$loinc_unit_review,
        review[["loinc_unit"]]
      )
    },
    chunk_size = chunk_size,
    table_name = materialized_table_name,
    strip_review_columns = stripSnapshotStreamingReviewColumns
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
