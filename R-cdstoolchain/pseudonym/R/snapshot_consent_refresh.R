# Refresh only during pseudonymization, while original patient identifiers are available.
readSnapshotConsentConfig <- function(project_root) {
  path <- file.path(project_root, "R-cdstoolchain", "consent_config.toml")
  if (!file.exists(path)) return(NULL)
  config <- etlutils::readTomlAsNamedList(path)
  endpoint <- config[["FHIR_SERVER_ENDPOINT"]]
  if (is.null(endpoint) || !nzchar(trimws(endpoint))) return(NULL)
  if (!grepl("^https?://", endpoint) || grepl("[@?#]", endpoint)) {
    stop("Consent FHIR endpoint must be an HTTP(S) base URL without credentials, query or fragment.")
  }
  config
}

searchSnapshotConsentFHIR <- function(config, resource, parameters) {
  request <- fhircrackr::fhir_url(
    url = config[["FHIR_SERVER_ENDPOINT"]], resource = resource,
    parameters = parameters, url_enc = TRUE
  )
  # Explicit credentials prevent this separate source from inheriting CDS2DB credentials.
  arguments <- list(request = request, max_bundles = Inf, verbose = 0)
  token <- config[["FHIR_TOKEN"]]
  if (!is.null(token) && nzchar(token)) {
    arguments$token <- token
  } else {
    arguments$username <- config[["FHIR_SERVER_USER"]]
    arguments$password <- config[["FHIR_SERVER_PASS"]]
  }
  do.call(fhircrackr::fhir_search, arguments)
}

snapshotConsentPatientMap <- function(connection, source_schema, source_view_prefix, config) {
  system <- config[["PATIENT_IDENTIFIER_SYSTEM"]]
  use_identifier <- !is.null(system) && nzchar(system)
  relation <- snapshotQualifiedName(connection, paste0(source_view_prefix, "patient_last_version"), source_schema)
  columns <- if (use_identifier) "pat_id, pat_identifier_system, pat_identifier_value" else "pat_id"
  patients <- data.table::as.data.table(DBI::dbGetQuery(connection, paste0(
    "SELECT DISTINCT ", columns, " FROM ", relation, " WHERE pat_id IS NOT NULL"
  )))
  patients$pat_id <- etlutils::getAfterLastSlash(patients$pat_id)
  ids <- unique(patients$pat_id)
  if (any(!grepl("^[A-Za-z0-9.-]+$", ids))) stop("Invalid source patient IDs for Consent refresh.")
  if (!use_identifier) return(data.table::data.table(pat_id = ids, remote_id = ids))

  selected <- !is.na(patients$pat_identifier_system) & patients$pat_identifier_system == system &
    !is.na(patients$pat_identifier_value) & nzchar(patients$pat_identifier_value)
  identifiers <- unique(data.frame(
    pat_id = patients$pat_id[selected],
    pat_identifier_value = patients$pat_identifier_value[selected]
  ))
  mappings <- list()
  # Identifier searches use exact FHIR tokens, not the frontend's display regexes.
  escapeToken <- function(value) {
    for (character in c("\\", "$", ",", "|")) {
      value <- gsub(character, paste0("\\", character), value, fixed = TRUE)
    }
    value
  }
  description <- fhircrackr::fhir_table_description(
    resource = "Patient", brackets = c("[", "]"), sep = " ~ ",
    cols = c(remote_id = "id", identifier_system = "identifier/system", identifier_value = "identifier/value")
  )
  values <- unique(identifiers$pat_identifier_value)
  for (value_index in seq_along(values)) {
    value <- values[[value_index]]
    if (value_index %% 100L == 1L) snapshotProgress("Resolve Consent patient identifiers: ", value_index, " of ", length(values))
    bundles <- searchSnapshotConsentFHIR(config, "Patient", c(identifier = paste0(escapeToken(system), "|", escapeToken(value))))
    found <- fhircrackr::fhir_crack(bundles, description, data.table = TRUE, verbose = 0)
    if (is.null(found) || !nrow(found)) next
    # Melt with FHIR paths so paired Identifier.system/value remain associated.
    data.table::setnames(found, c("identifier_system", "identifier_value"), c("identifier/system", "identifier/value"))
    found <- fhircrackr::fhir_melt_all(found, description@brackets, description@sep, column_name_separator = "/")
    selected <- !is.na(found[["identifier/system"]]) & !is.na(found[["identifier/value"]]) &
      found[["identifier/system"]] == system & found[["identifier/value"]] == value
    remote_ids <- unique(found$remote_id[selected])
    if (length(remote_ids) > 1L) stop("Consent patient identifier matches multiple remote patients.")
    if (length(remote_ids)) mappings[[length(mappings) + 1L]] <- data.table::data.table(
      pat_id = identifiers$pat_id[identifiers$pat_identifier_value == value], remote_id = remote_ids
    )
  }
  mapping <- unique(data.table::rbindlist(mappings))
  if (!nrow(mapping)) return(data.table::data.table(pat_id = character(), remote_id = character()))
  if (anyDuplicated(mapping$pat_id) || anyDuplicated(mapping$remote_id)) {
    stop("Consent patient mapping is ambiguous between source and remote patients.")
  }
  snapshotProgress("Resolved Consent identifiers for ", nrow(mapping), " of ", length(ids), " patients")
  mapping
}

fetchSnapshotConsentRows <- function(config, patient_map) {
  rows <- list()
  remote_ids <- unique(patient_map$remote_id)
  groups <- split(remote_ids, ceiling(seq_along(remote_ids) / 100L))
  for (group_index in seq_along(groups)) {
    group <- groups[[group_index]]
    snapshotProgress("Download Consents for patient batch ", group_index, " of ", length(groups))
    bundles <- searchSnapshotConsentFHIR(config, "Consent", c(patient = paste(group, collapse = ",")))
    chunk <- cds2db::convertSnapshotConsentBundles(bundles)
    if (!nrow(chunk)) next
    remote_patient <- etlutils::getAfterLastSlash(chunk$cons_patient_ref)
    if (anyNA(remote_patient) || any(!remote_patient %in% group)) {
      stop("Consent response contains an unexpected or missing patient reference.")
    }
    chunk$cons_patient_ref <- paste0("Patient/", patient_map$pat_id[match(remote_patient, patient_map$remote_id)])
    rows[[length(rows) + 1L]] <- chunk
  }
  data.table::rbindlist(rows, fill = TRUE)
}

# Prepare replacement queries on the source connection using TEMP tables only.
# No downloaded original data is persisted outside the regular pseudonymization path.
prepareSnapshotConsentRefresh <- function(connection, source_schema, source_view_prefix,
  version_key_tables, plan, rows) {
  consent_plan <- plan[plan$BASE_TABLE_NAME == "consent", ]
  if (!nrow(consent_plan)) stop("Consent refresh requires Consent in the snapshot materialization plan.")
  if (!nrow(rows)) return(list(queries = list(), tables = list(), patients = 0L, rows = 0L))
  if (anyNA(rows$cons_id) || any(!nzchar(rows$cons_id))) stop("Downloaded Consent document IDs are missing.")
  owner <- etlutils::getAfterLastSlash(rows$cons_patient_ref)
  if (anyNA(owner)) stop("Downloaded Consents have missing patient references.")
  selected_patients <- unique(owner)
  source <- snapshotQualifiedName(connection, paste0(source_view_prefix, "consent"), source_schema)
  prototype <- DBI::dbGetQuery(connection, paste0("SELECT * FROM ", source, " WHERE FALSE"))
  unknown_fields <- setdiff(names(rows), names(prototype))
  if (length(unknown_fields)) stop("Consent source schema is missing downloaded columns: ", paste(unknown_fields, collapse = ", "))
  refreshed <- prototype[rep(NA_integer_, nrow(rows)), , drop = FALSE]
  for (column in names(rows)) refreshed[[column]] <- rows[[column]]
  if ("last_check_datetime" %in% names(refreshed)) refreshed$last_check_datetime <- Sys.time()
  if ("input_datetime" %in% names(refreshed)) refreshed$input_datetime <- Sys.time()
  name <- basename(tempfile("snapshot_consent_refresh_"))
  table <- snapshotQualifiedName(connection, name)
  DBI::dbExecute(connection, paste0("CREATE TEMP TABLE ", table, " AS SELECT * FROM ", source, " WHERE FALSE"))
  complete <- FALSE
  on.exit(if (!complete) DBI::dbExecute(connection, paste0("DROP TABLE IF EXISTS ", table)), add = TRUE)
  # Technical keys and raw-import hashes have no identity across these two imports.
  # Reserve new row IDs above all original rows; preserve the schema, leaving raw provenance NULL.
  refreshed$consent_id <- NULL
  DBI::dbAppendTable(connection, name, refreshed)
  DBI::dbExecute(connection, paste0(
    "UPDATE ", table, " t SET consent_id = n.id FROM (SELECT ctid, ",
    "(SELECT COALESCE(MAX(consent_id), 0) FROM ", source, ") + row_number() OVER () AS id FROM ",
    table, ") n WHERE t.ctid = n.ctid"
  ))
  DBI::dbExecute(connection, paste0("ANALYZE ", table))
  ref <- broadConsentReferenceIdExpression(connection, "cons_patient_ref", "s", "Patient")
  replacement_ref <- broadConsentReferenceIdExpression(connection, "cons_patient_ref", "r", "Patient")
  # The FHIR ID namespace can differ between servers. A collision with a retained
  # patient's document must not silently merge the two documents in the current view.
  collisions <- DBI::dbGetQuery(connection, paste0(
    "SELECT COUNT(*) AS n FROM ", source, " s JOIN ", table, " r ON s.cons_id = r.cons_id ",
    "WHERE ", ref, " IS DISTINCT FROM ", replacement_ref,
    " AND NOT EXISTS (SELECT 1 FROM ", table, " replaced WHERE ", ref, " = ",
    broadConsentReferenceIdExpression(connection, "cons_patient_ref", "replaced", "Patient"), ")"
  ))$n
  if (as.numeric(collisions) > 0) stop("Consent document IDs collide across patients in the two sources.")
  queries <- list()
  for (i in seq_len(nrow(consent_plan))) {
    row <- consent_plan[i, ]
    original <- getSnapshotPartitionSource(connection, row, source_schema, source_view_prefix, version_key_tables)$relation
    query <- paste0(
      "SELECT s.* FROM ", original, " s WHERE NOT EXISTS (SELECT 1 FROM ", table,
      " r WHERE ", ref, " = ", replacement_ref, ")"
    )
    if (row$SNAPSHOT_RELATION_TYPE != SNAPSHOT_RELATION_TYPE_OLD) {
      query <- paste0(query, " UNION ALL SELECT * FROM ", table)
    }
    queries[[row$MATERIALIZED_TABLE_NAME]] <- query
  }
  complete <- TRUE
  list(queries = queries, tables = list(name), patients = length(selected_patients), rows = nrow(rows))
}
