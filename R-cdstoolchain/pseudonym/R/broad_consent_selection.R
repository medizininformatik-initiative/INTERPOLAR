BROAD_CONSENT_MASKED_TABLE <- "broad_consent_masked_reference"

# Patient ownership and the patientless Medication graph use logical IDs.
# A valid relative version reference retains that identity; masking still
# checks the explicitly referenced version separately.
broadConsentReferenceIdExpression <- function(connection, column, alias = NULL, resource_type = "Medication") {
  normalized <- snapshotNormalizedReferenceExpression(connection, column, alias, resource_type)
  raw <- paste0("regexp_replace(", snapshotQuotedColumn(connection, column, alias), "::text, '^\\[[^]]+\\]', '')")
  paste0(
    "CASE WHEN ", raw, " ~ '^", resource_type, "/[A-Za-z0-9.-]+/_history/[A-Za-z0-9.-]+$' ",
    "THEN split_part(", normalized, ", '/', 1) ELSE ", normalized, " END"
  )
}

# Non-FHIR rows use patient permission only. Resolve their owner against the
# source, before any Encounter is removed by the resource date selection.
buildBroadConsentNonFhirDecisionQuery <- function(connection, relation, base_table, fields, source_schema,
  source_view_prefix, interval_table, owner_tables, materialized_names) {
  owner <- function(table, source_key) paste0(
    "(SELECT owner.patient_id FROM ", snapshotQualifiedName(connection, owner_tables[[table]]),
    " owner WHERE owner.owner_key = s.", source_key, "::text)"
  )
  patient <- if (base_table == "patient_fe") {
    broadConsentReferenceIdExpression(connection, "pat_id", "s", "Patient")
  } else if (endsWith(base_table, "_fe")) {
    owner("patient_fe", "record_id")
  } else if (base_table == "dp_mrp_calculations") {
    owner("encounter", "enc_id")
  } else if (base_table == "pids_per_ward") {
    broadConsentReferenceIdExpression(connection, "patient_id", "s", "Patient")
  } else {
    "NULL::text"
  }
  prior_view <- paste0(source_view_prefix, BROAD_CONSENT_MASKED_TABLE)
  if (base_table == "dp_mrp_calculations" && snapshotRelationExists(connection, prior_view, source_schema)) {
    prior_owner <- paste0(
      "(SELECT MIN(e.patient_id) FROM ",
      snapshotQualifiedName(connection, prior_view, source_schema),
      " e WHERE e.row_id = s.dp_mrp_calculations_id::text AND e.column_name = 'enc_id' AND e.reason = 'masked' ",
      "AND e.table_name IN (", paste(DBI::dbQuoteString(connection, materialized_names), collapse = ", "), ") ",
      "HAVING COUNT(DISTINCT e.patient_id) = 1 AND bool_and(e.patient_id IS NOT NULL))"
    )
    patient <- paste0("CASE WHEN s.enc_id IS NULL THEN ", prior_owner, " ELSE ", patient, " END")
  }
  consistency <- if (base_table == "fall_fe" && "fall_pat_id" %in% fields) {
    " AND (s.fall_pat_id IS NULL OR s.fall_pat_id::text = s.bc_patient_id)"
  } else ""
  paste0(
    "SELECT ", snapshotQuotedColumn(connection, snapshotTechnicalRowIdColumn(base_table), "s"),
    "::text AS row_id, NULL::text AS resource_id, NULL::text AS version_id, s.bc_patient_id AS patient_id, ",
    "CASE WHEN s.bc_patient_id IS NULL THEN 'unresolved_patient' ",
    "WHEN EXISTS (SELECT 1 FROM ", interval_table, " i WHERE i.patient_id = s.bc_patient_id)", consistency,
    " THEN 'included' ELSE 'patient_not_permitted' END AS reason ",
    "FROM (SELECT s.*, ", patient, " AS bc_patient_id FROM ", relation, " s) s"
  )
}

# Query only the already materialized decisions, and only after index failure.
# Never return source identifiers or the PostgreSQL DETAIL (which contains keys).
getBroadConsentDecisionConflictDiagnostic <- function(connection, table) {
  reasons <- c(
    "included", "invalid_resource_identity", "unresolved_patient", "patient_not_permitted",
    "invalid_resource_date", "outside_consent_period", "missing_resource_date_mapping"
  )
  safe_reason <- paste0(
    "CASE WHEN d.reason IN (", paste(DBI::dbQuoteString(connection, reasons), collapse = ", "),
    ") THEN d.reason ELSE 'other' END"
  )
  query <- paste0(
    "WITH conflicts AS (SELECT row_id, COUNT(*) AS decisions, ",
    "COUNT(DISTINCT jsonb_build_array(resource_id)) AS resources, ",
    "COUNT(DISTINCT jsonb_build_array(version_id)) AS versions, ",
    "COUNT(DISTINCT jsonb_build_array(patient_id)) AS patients, ",
    "COUNT(DISTINCT jsonb_build_array(reason)) AS reasons, ",
    "bool_and(reason IS NOT NULL AND reason <> 'included') AS all_excluded, ",
    "bool_or(reason = 'included') AND bool_or(reason <> 'included') AS mixed ",
    "FROM ", table, " GROUP BY row_id HAVING COUNT(*) > 1) ",
    "SELECT COUNT(*) AS conflicting_row_ids, COALESCE(SUM(decisions), 0) AS distinct_decisions, ",
    "COUNT(*) FILTER (WHERE resources > 1) AS resource_id_conflicts, ",
    "COUNT(*) FILTER (WHERE versions > 1) AS version_id_conflicts, ",
    "COUNT(*) FILTER (WHERE patients > 1) AS patient_id_conflicts, ",
    "COUNT(*) FILTER (WHERE reasons > 1) AS reason_conflicts, ",
    "COUNT(*) FILTER (WHERE all_excluded) AS all_excluded_conflicts, ",
    "COUNT(*) FILTER (WHERE mixed) AS mixed_included_excluded_conflicts, ",
    "(SELECT string_agg(DISTINCT ", safe_reason, ", ', ' ORDER BY ", safe_reason, ") ",
    "FROM ", table, " d JOIN conflicts c ON c.row_id = d.row_id) AS decision_reasons FROM conflicts"
  )
  result <- DBI::dbGetQuery(connection, query)
  paste(paste0(names(result), "=", vapply(result, function(value) {
    if (is.na(value[1])) "none" else as.character(value[1])
  }, character(1))), collapse = "\n")
}

createBroadConsentDecisionTable <- function(connection, query, source_relation = "source") {
  name <- basename(tempfile("broad_consent_rows_"))
  table <- snapshotQualifiedName(connection, name)
  complete <- FALSE
  on.exit(if (!complete) DBI::dbExecute(connection, paste0("DROP TABLE IF EXISTS ", table)), add = TRUE)
  # Medication enrichment can repeat a source row ID for different code pairs.
  # Only identical decisions collapse; the source data rows remain untouched.
  DBI::dbExecute(connection, paste0("CREATE TEMP TABLE ", table, " AS SELECT DISTINCT * FROM (", query, ") decisions"))
  DBI::dbExecute(connection, paste0("ALTER TABLE ", table, " ALTER COLUMN row_id SET NOT NULL"))
  tryCatch(
    DBI::dbExecute(connection, paste0("CREATE UNIQUE INDEX ON ", table, " (row_id)")),
    error = function(error) {
      diagnostic <- tryCatch(getBroadConsentDecisionConflictDiagnostic(connection, table),
        error = function(diagnostic_error) "Conflict diagnostic unavailable; no source values logged."
      )
      stop(
        "Could not create unique Broad Consent decision index for source relation ", source_relation,
        ".\nBroad Consent decision conflict diagnostic (counts after deduplication):\n", diagnostic,
        call. = FALSE
      )
    }
  )
  DBI::dbExecute(connection, paste0("CREATE INDEX ON ", table, " (resource_id, version_id, reason)"))
  DBI::dbExecute(connection, paste0("ANALYZE ", table))
  complete <- TRUE
  name
}

prepareBroadConsentResourceSelection <- function(connection, materialization_plan, rules,
  source_schema, source_view_prefix, interval_table) {
  owner_tables <- list()
  on.exit(dropSnapshotVersionKeyTables(connection, owner_tables), add = TRUE)
  needed_tables <- materialization_plan$BASE_TABLE_NAME
  for (base in c("patient_fe", "encounter")) {
    needed <- if (base == "patient_fe") any(endsWith(needed_tables, "_fe") & needed_tables != "patient_fe") else
      "dp_mrp_calculations" %in% needed_tables
    if (!needed) next
    relation <- snapshotQualifiedName(connection, paste0(source_view_prefix, base), source_schema)
    key <- if (base == "patient_fe") "record_id" else "enc_id"
    patient <- broadConsentReferenceIdExpression(connection,
      if (base == "patient_fe") "pat_id" else "enc_patient_ref",
      resource_type = "Patient"
    )
    name <- basename(tempfile("broad_consent_owners_"))
    table <- snapshotQualifiedName(connection, name)
    owner_tables[[base]] <- name
    DBI::dbExecute(connection, paste0(
      "CREATE TEMP TABLE ", table, " AS SELECT ", key, "::text AS owner_key, ",
      "CASE WHEN COUNT(DISTINCT ", patient, ") = 1 AND bool_and(", patient,
      " IS NOT NULL) THEN MIN(", patient, ") END AS patient_id FROM ", relation, " GROUP BY ", key, "::text"
    ))
    DBI::dbExecute(connection, paste0("CREATE UNIQUE INDEX ON ", table, " (owner_key)"))
    DBI::dbExecute(connection, paste0("ANALYZE ", table))
  }
  selections <- list()
  complete <- FALSE
  on.exit(if (!complete) dropSnapshotVersionKeyTables(connection, lapply(selections, `[[`, "table_name")), add = TRUE)
  base_rows <- materialization_plan[!duplicated(materialization_plan$BASE_TABLE_NAME), ]
  for (i in seq_len(nrow(base_rows))) {
    plan <- base_rows[i, ]
    base <- plan$BASE_TABLE_NAME
    relation_name <- paste0(source_view_prefix, base)
    relation <- snapshotQualifiedName(connection, relation_name, source_schema)
    fields <- snapshotRelationFields(connection, relation_name, source_schema)
    if (any(fields == "bc_patient_id" | startsWith(fields, ".broad_consent_"))) {
      stop("Reserved Consent processing columns in source relation: ", base)
    }
    row_column <- snapshotTechnicalRowIdColumn(base)
    if (!row_column %in% fields) stop("Missing technical row identity for Consent selection: ", base)
    table_rules <- getPseudonymizationRulesForTable(rules, plan$RULE_TABLE_NAME, plan$RULE_SOURCE)
    is_fhir <- identical(plan$RULE_SOURCE, "fhir") && base != "pids_per_ward"
    spec <- if (is_fhir) getBroadConsentResourceSpec(table_rules, fields) else NULL
    if (is_fhir && is.na(spec$id)) stop("Missing FHIR resource identity: ", base)
    query <- if (is_fhir) {
      buildBroadConsentFhirDecisionQuery(connection, relation, row_column, spec, interval_table)
    } else {
      buildBroadConsentNonFhirDecisionQuery(
        connection, relation, base, fields,
        source_schema, source_view_prefix, interval_table, owner_tables,
        materialization_plan$MATERIALIZED_TABLE_NAME[materialization_plan$BASE_TABLE_NAME == base]
      )
    }
    selections[[base]] <- list(
      table_name = createBroadConsentDecisionTable(connection, query, relation),
      relation = relation, row_column = row_column, fields = fields, spec = spec, rules = table_rules
    )
  }
  # Medication has no patient field. Keep the graph reachable from retained
  # medication events, reusing the existing event/reference specifications.
  if ("medication" %in% names(selections)) {
    medication <- selections$medication
    roots <- character()
    for (base in names(selections)) {
      reference_spec <- getMedicationReferenceSpec(base)
      if (is.null(reference_spec)) next
      selection <- selections[[base]]
      reference <- reference_spec$reference_column
      if (!reference %in% selection$fields) next
      roots <- c(roots, paste0(
        "SELECT ", broadConsentReferenceIdExpression(connection, reference, "s"),
        " AS resource_id FROM ", selection$relation, " s WHERE EXISTS (SELECT 1 FROM ",
        snapshotQualifiedName(connection, selection$table_name), " d WHERE d.row_id = ",
        snapshotQuotedColumn(connection, selection$row_column, "s"), "::text AND d.reason = 'included')"
      ))
    }
    if (length(roots)) {
      ingredient <- SNAPSHOT_MEDICATION_INGREDIENT_REFERENCE_COLUMN
      edges <- if (ingredient %in% medication$fields) paste0(
        "SELECT med_id::text AS resource_id, ", broadConsentReferenceIdExpression(connection, ingredient),
        " AS ingredient_id FROM ", medication$relation
      ) else "SELECT NULL::text AS resource_id, NULL::text AS ingredient_id WHERE FALSE"
      table <- snapshotQualifiedName(connection, medication$table_name)
      DBI::dbExecute(connection, paste0(
        "WITH RECURSIVE roots AS (", paste(roots, collapse = " UNION "),
        "), edges AS (", edges, "), reachable(resource_id) AS (SELECT resource_id FROM roots ",
        "WHERE resource_id IS NOT NULL UNION SELECT e.ingredient_id FROM edges e JOIN reachable r ",
        "ON e.resource_id = r.resource_id WHERE e.ingredient_id IS NOT NULL) ",
        "UPDATE ", table, " d SET reason = 'included' WHERE d.resource_id IN (SELECT resource_id FROM reachable) ",
        "AND d.resource_id ~ '^[A-Za-z0-9.-]+$'"
      ))
    }
  }
  complete <- TRUE
  selections
}
