# TORCH mappings/type_to_consent.json at b12757d09a525ae1a3309e4aded999b209b1d600.
# Missing entries must never acquire the meaning of an explicitly empty entry.
BROAD_CONSENT_RESOURCE_DATES <- c(
  MedicationStatement = "effective", List = "date", MedicationRequest = "authoredOn",
  Medication = "", MedicationAdministration = "effective", Observation = "effective",
  Procedure = "performed", Device = "", Substance = "", Organization = "",
  Specimen = "collection/collected", Condition = "recordedDate", DocumentReference = "date",
  Questionnaire = "", Consent = "dateTime", ResearchStudy = "", QuestionnaireResponse = "",
  Provenance = "recorded", Patient = "", Encounter = "period", Task = "authoredOn",
  FamilyMemberHistory = "date", DiagnosticReport = "effective", ServiceRequest = "authoredOn",
  RiskAssessment = "occurrence"
)

getBroadConsentResourceSpec <- function(table_rules, fields) {
  resource <- unique(stats::na.omit(table_rules$RESOURCE))
  resource <- resource[nzchar(resource)]
  if (length(resource) != 1L) stop("Expected one FHIR resource type in table metadata.")
  column <- function(path) {
    matches <- unique(table_rules$COLUMN_NAME[which(table_rules$FHIR_EXPRESSION == path)])
    matches <- intersect(matches, fields)
    if (length(matches) > 1L) stop("Ambiguous FHIR column mapping: ", resource, ".", path)
    if (length(matches)) matches else NA_character_
  }
  date_path <- unname(BROAD_CONSENT_RESOURCE_DATES[resource])
  point <- start <- end <- NA_character_
  if (!is.na(date_path) && nzchar(date_path)) {
    point <- column(date_path)
    if (is.na(point)) point <- column(paste0(date_path, "DateTime"))
    start <- column(paste0(date_path, "/start"))
    end <- column(paste0(date_path, "/end"))
    if (is.na(start) && is.na(end)) {
      start <- column(paste0(date_path, "Period/start"))
      end <- column(paste0(date_path, "Period/end"))
    }
  }
  patient <- column(if (resource == "Consent") "patient/reference" else "subject/reference")
  if (resource == "Patient") patient <- column("id")
  list(
    resource = resource, id = column("id"), version = column("meta/versionId"),
    patient = patient, date_path = date_path, point = point, start = start, end = end
  )
}

buildBroadConsentDatePredicate <- function(connection, spec, interval_table) {
  if (is.na(spec$date_path)) return(list(valid = "FALSE", covered = "FALSE"))
  if (!nzchar(spec$date_path)) return(list(valid = "TRUE", covered = "TRUE"))
  column <- function(name) {
    if (is.na(name)) return("NULL::timestamp")
    snapshotQuotedColumn(connection, name, "s")
  }
  point <- column(spec$point)
  start <- column(spec$start)
  end <- column(spec$end)
  # A FHIR choice must contain exactly one usable date or complete period.
  # Missing period bounds and conflicting choices cannot grant permission.
  point_valid <- paste0(point, " IS NOT NULL AND ", start, " IS NULL AND ", end, " IS NULL")
  period_valid <- paste0(
    point, " IS NULL AND ", start, " IS NOT NULL AND ", end,
    " IS NOT NULL AND ", start, "::date <= ", end, "::date"
  )
  contains <- function(from, to) paste0(
    "EXISTS (SELECT 1 FROM ", interval_table, " i WHERE i.patient_id = s.bc_patient_id ",
    "AND i.start <= ", from, "::date AND i.\"end\" >= ", to, "::date)"
  )
  list(
    valid = paste0("((", point_valid, ") OR (", period_valid, "))"),
    covered = paste0(
      "((", point_valid, " AND ", contains(point, point), ") OR (",
      period_valid, " AND ", contains(start, end), "))"
    )
  )
}

# A decision covers the entire resource version, not an arbitrary flattened row.
# Window aggregates keep repeated resource fields and contradictory rows together.
buildBroadConsentFhirDecisionQuery <- function(connection, relation, row_column, spec, interval_table) {
  quoted <- function(name, alias = "s") {
    if (is.na(name)) return("NULL::text")
    paste0(snapshotQuotedColumn(connection, name, alias), "::text")
  }
  patient <- if (is.na(spec$patient)) "NULL::text" else snapshotNormalizedReferenceExpression(
    connection, spec$patient, "source", "Patient"
  )
  id <- quoted(spec$id)
  version <- quoted(spec$version)
  identity <- paste0(id, " IS NOT NULL AND ", id, " ~ '^[A-Za-z0-9.-]+$'")
  permitted <- paste0(
    "EXISTS (SELECT 1 FROM ", interval_table,
    " i WHERE i.patient_id = s.bc_patient_id)"
  )
  date_valid <- buildBroadConsentDatePredicate(connection, spec, interval_table)
  reason <- if (is.na(spec$date_path)) "'missing_resource_date_mapping'" else paste0(
    "CASE WHEN NOT COALESCE(bool_and(", identity, ") OVER w, FALSE) THEN 'invalid_resource_identity' ",
    "WHEN NOT COALESCE(bool_and(s.bc_patient_id IS NOT NULL) OVER w, FALSE) ",
    "OR MIN(s.bc_patient_id) OVER w <> MAX(s.bc_patient_id) OVER w THEN 'unresolved_patient' ",
    "WHEN NOT bool_and(", permitted, ") OVER w THEN 'patient_not_permitted' ",
    "WHEN NOT COALESCE(bool_and(", date_valid$valid, ") OVER w, FALSE) THEN 'invalid_resource_date' ",
    "WHEN NOT COALESCE(bool_and(", date_valid$covered, ") OVER w, FALSE) THEN 'outside_consent_period' ",
    "ELSE 'included' END"
  )
  paste0(
    "SELECT ", quoted(row_column), " AS row_id, ", id, " AS resource_id, ",
    version, " AS version_id, s.bc_patient_id AS patient_id, ", reason, " AS reason FROM (SELECT source.*, ",
    patient, " AS bc_patient_id FROM ", relation, " source) s ",
    "WINDOW w AS (PARTITION BY ", id, ", ", version, ")"
  )
}
