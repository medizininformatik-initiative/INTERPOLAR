prepareBroadConsentReferenceTargets <- function(connection, selections, materialization_plan, source_schema) {
  queries <- character()
  for (base in names(selections)) {
    selection <- selections[[base]]
    if (is.null(selection$spec)) next
    last <- materialization_plan[materialization_plan$BASE_TABLE_NAME == base &
      materialization_plan$SNAPSHOT_RELATION_TYPE == SNAPSHOT_RELATION_TYPE_LAST, ]
    # Join current row identities once. A correlated text-cast lookup can
    # degrade to a full source scan per row when its hash subplan no longer fits.
    current_join <- if (nrow(last)) paste0(
      " LEFT JOIN (SELECT DISTINCT ",
      snapshotQuotedColumn(connection, selection$row_column), "::text AS row_id FROM ",
      snapshotQualifiedName(connection, last$SOURCE_RELATION, source_schema),
      ") current_rows ON current_rows.row_id = d.row_id"
    ) else ""
    current <- if (nrow(last)) "current_rows.row_id IS NOT NULL" else "TRUE"
    queries <- c(queries, paste0(
      "SELECT ", DBI::dbQuoteString(connection, selection$spec$resource),
      "::text AS resource_type, resource_id, version_id, reason = 'included' AS retained, ",
      current, " AS is_current FROM ", snapshotQualifiedName(connection, selection$table_name), " d", current_join
    ))
  }
  name <- basename(tempfile("broad_consent_targets_"))
  table <- snapshotQualifiedName(connection, name)
  query <- if (length(queries)) paste(queries, collapse = " UNION ALL ") else
    "SELECT NULL::text AS resource_type, NULL::text AS resource_id, NULL::text AS version_id, FALSE AS retained, FALSE AS is_current WHERE FALSE"
  complete <- FALSE
  on.exit(if (!complete) DBI::dbExecute(connection, paste0("DROP TABLE IF EXISTS ", table)), add = TRUE)
  DBI::dbExecute(connection, paste0("CREATE TEMP TABLE ", table, " AS SELECT DISTINCT * FROM (", query, ") targets"))
  DBI::dbExecute(connection, paste0("CREATE INDEX ON ", table, " (resource_type, resource_id, version_id)"))
  DBI::dbExecute(connection, paste0("ANALYZE ", table))
  complete <- TRUE
  name
}

getBroadConsentReferenceType <- function(column, resource) {
  if (column %in% c("enc_id", "encounter_id", "fall_fhir_enc_id")) return("Encounter")
  if (column == "atc1_medreq_fhir_id") return("MedicationRequest")
  if (grepl("_patient_ref$", column)) return("Patient")
  if (grepl("_encounter_(calculated_)?ref$", column)) return("Encounter")
  if (resource == "Encounter" && grepl("_partof_(calculated_)?ref$", column)) return("Encounter")
  if (grepl("_diagnosis_condition_(calculated_)?ref$", column)) return("Condition")
  if (grepl("_medicationreference_ref$|_ingredient_itemreference_ref$", column)) return("Medication")
  NA_character_
}

buildBroadConsentReferenceMaskPredicate <- function(connection, column, resource, targets) {
  value <- paste0("regexp_replace(", snapshotQuotedColumn(connection, column, "s"), "::text, '^\\[[^]]+\\]', '')")
  expected <- getBroadConsentReferenceType(column, resource)
  type <- paste0("split_part(", value, ", '/', 1)")
  id <- paste0("split_part(", value, ", '/', 2)")
  version <- paste0("CASE WHEN split_part(", value, ", '/', 3) = '_history' THEN split_part(", value, ", '/', 4) END")
  if (!is.na(expected)) {
    type <- paste0("CASE WHEN strpos(", value, ", '/') = 0 THEN ", DBI::dbQuoteString(connection, expected), " ELSE ", type, " END")
    id <- paste0("CASE WHEN strpos(", value, ", '/') = 0 THEN ", value, " ELSE ", id, " END")
  }
  # Only a target demonstrably excluded by this selection receives 'masked'.
  # Empty, invalid and already dangling source references have no invented reason.
  paste0(
    "(", value, " <> 'invalid' AND ", value,
    " ~ '^[A-Za-z0-9.-]+(/[A-Za-z0-9.-]+(/_history/[A-Za-z0-9.-]+)?)?$' AND ",
    "EXISTS (SELECT 1 FROM ", targets, " t WHERE t.resource_type = ", type,
    " AND t.resource_id = ", id, " AND ((", version, " IS NULL AND t.is_current) OR t.version_id = ", version,
    ") HAVING COUNT(*) > 0 AND bool_and(NOT t.retained)))"
  )
}

emptyBroadConsentMaskedReferences <- function() {
  data.table::data.table(
    table_name = character(), row_id = character(), resource_type = character(),
    resource_id = character(), version_id = character(), patient_id = character(), column_name = character(), reason = character()
  )
}

maskBroadConsentChunkReferences <- function(chunk, selection, table_name, mask_columns) {
  evidence <- list()
  for (column in names(mask_columns)) {
    flagged <- which(chunk[[mask_columns[[column]]]] %in% TRUE)
    if (length(flagged)) {
      spec <- selection$spec
      if (is.null(spec)) spec <- list(resource = table_name, id = selection$row_column, version = NA_character_)
      evidence[[length(evidence) + 1L]] <- data.table::data.table(
        table_name = table_name, row_id = as.character(chunk[[selection$row_column]][flagged]),
        resource_type = spec$resource,
        resource_id = as.character(chunk[[spec$id]][flagged]),
        version_id = if (is.na(spec$version)) NA_character_ else as.character(chunk[[spec$version]][flagged]),
        patient_id = as.character(chunk[[".broad_consent_patient_id"]][flagged]),
        column_name = column, reason = "masked"
      )
      data.table::set(chunk, i = flagged, j = column, value = NA_character_)
    }
    data.table::set(chunk, j = mask_columns[[column]], value = NULL)
  }
  data.table::set(chunk, j = ".broad_consent_patient_id", value = NULL)
  list(chunk = chunk, evidence = if (length(evidence)) data.table::rbindlist(evidence) else emptyBroadConsentMaskedReferences())
}

copyBroadConsentPriorEvidence <- function(source_connection, target_connection, selections,
  materialization_plan, source_schema, target_table_schema, source_view_prefix, chunk_size) {
  view_name <- paste0(source_view_prefix, BROAD_CONSENT_MASKED_TABLE)
  if (!snapshotRelationExists(source_connection, view_name, source_schema)) return(invisible(NULL))
  for (i in seq_len(nrow(materialization_plan))) {
    plan <- materialization_plan[i, ]
    selection <- selections[[plan$BASE_TABLE_NAME]]
    query <- paste0(
      "SELECT evidence.* FROM ", snapshotQualifiedName(source_connection, view_name, source_schema),
      " evidence WHERE evidence.table_name = ", DBI::dbQuoteString(source_connection, plan$MATERIALIZED_TABLE_NAME),
      " AND EXISTS (SELECT 1 FROM ", snapshotQualifiedName(source_connection, selection$table_name),
      " d WHERE d.row_id = evidence.row_id AND d.reason = 'included')"
    )
    result <- DBI::dbSendQuery(source_connection, query)
    tryCatch(copyBroadConsentChunkStream(
      function(n) DBI::dbFetch(result, n = n), function() DBI::dbHasCompleted(result),
      function(chunk, first_chunk) {
        if (nrow(chunk)) DBI::dbAppendTable(
          target_connection,
          snapshotRelationId(BROAD_CONSENT_MASKED_TABLE, target_table_schema), chunk
        )
      }, chunk_size, BROAD_CONSENT_MASKED_TABLE
    ), finally = DBI::dbClearResult(result))
  }
  invisible(NULL)
}
