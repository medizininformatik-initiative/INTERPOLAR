#' Classify main cases in SQL using one Encounter scan
#'
#' Read age from the main Encounter's own ID, not from a ward Encounter's age.
#' The ward join is deduplicated before classifying cases. Two compact markers
#' per Encounter combine main-case age and IP membership in one grouped lookup.
#' Only aggregated reports leave SQL; no case lists are loaded into R.
buildCodeSummaryCaseGroupsQuery <- function(metadata, exports, include_filtered = FALSE, table_description = NULL) {
  age_column <- exports$age_column
  encounter <- getTableMetadata(metadata[TABLE_FAMILY == "FHIR"], "encounter")
  if (!"enc_id" %in% encounter$COLUMN_NAME) return(NA_character_)
  field <- function(column) codeSummaryFieldSql(stats::setNames(column, "field"), "field", "e")
  case_id <- codeSummaryReferenceSql(paste0("'Encounter/' || ", field("enc_id")), "Encounter")
  age <- paste0("CASE WHEN ", field(age_column), " ~ '^[0-9]+([.][0-9]+)?$' THEN (", field(age_column), ")::numeric END")
  patient_join <- ""
  age_source <- paste0("main Encounter.", age_column)
  if (!age_column %in% encounter$COLUMN_NAME) {
    if (!isTRUE(exports$fallback_to_birthdate) || is.null(table_description)) return(NA_character_)
    description <- data.table::copy(table_description)
    etlutils::fillNAWithLastRowValue(description, "RESOURCE")
    patient <- metadata[TABLE_FAMILY == "FHIR" & TABLE_NAME == "patient"]
    start_column <- resolveCodeSummaryPath(description[RESOURCE == "Encounter"], encounter, "period/start")
    reference_column <- resolveCodeSummaryPath(description[RESOURCE == "Encounter"], encounter, "subject/reference")
    birth_column <- resolveCodeSummaryPath(description[RESOURCE == "Patient"], patient, "birthDate")
    id_column <- resolveCodeSummaryPath(description[RESOURCE == "Patient"], patient, "id")
    if (anyNA(c(start_column, reference_column, birth_column, id_column))) return(NA_character_)
    # Typed FHIR views supply valid dates. Do not cast arbitrary strings from raw
    # views; invalid or partial birthdates there must not abort a site report.
    date_types <- c(encounter[COLUMN_NAME == start_column, DATA_TYPE], patient[COLUMN_NAME == birth_column, DATA_TYPE])
    if (length(date_types) != 2L || anyNA(date_types) || !all(grepl("^(date$|timestamp)", date_types))) return(NA_character_)
    birth <- quoteQualifiedIdentifier("p", "birthdate")
    start <- quoteQualifiedIdentifier("e", start_column)
    age <- paste0(
      "CASE WHEN isfinite(", start, ") AND isfinite(", birth, ") AND ", start,
      "::date >= ", birth, " THEN EXTRACT(YEAR FROM age(", start, "::date,", birth, ")) END"
    )
    patient_id <- codeSummaryFieldSql(c(id = id_column), "id", "p_source")
    patient_birth <- paste0(quoteQualifiedIdentifier("p_source", birth_column), "::date")
    patient_join <- paste0(
      " LEFT JOIN (SELECT ", patient_id, " AS own_id, CASE WHEN COUNT(DISTINCT ", patient_birth,
      ")=1 THEN MIN(", patient_birth, ") END AS birthdate FROM ",
      quoteTable(patient$VIEW_SCHEMA[[1]], patient$VIEW_NAME[[1]]), " p_source GROUP BY ", patient_id,
      ") p ON 'Patient/' || p.own_id = ", codeSummaryReferenceSql(field(reference_column), "Patient")
    )
    age_source <- paste0("completed calendar years from main Encounter.", start_column, " and Patient.", birth_column)
  }
  ward_join <- ""
  main_case_id <- "NULL::text"
  ip <- "false"
  if (include_filtered) {
    ward <- getTableMetadata(metadata, "pids_per_ward")
    if (
      !all(c("enc_id", "enc_main_encounter_calculated_ref") %in% encounter$COLUMN_NAME) ||
      !"encounter_id" %in% ward$COLUMN_NAME
    ) {
      return(NA_character_)
    }
    main_case_id <- codeSummaryReferenceSql(field("enc_main_encounter_calculated_ref"), "Encounter")
    ward_join <- paste0(
      " LEFT JOIN (SELECT DISTINCT ", quoteIdentifier("encounter_id"), " FROM ",
      quoteTable(ward$VIEW_SCHEMA[[1]], ward$VIEW_NAME[[1]]), ") w ON ",
      quoteQualifiedIdentifier("e", "enc_id"), " = ", quoteQualifiedIdentifier("w", "encounter_id")
    )
    ip <- paste0(quoteQualifiedIdentifier("w", "encounter_id"), " IS NOT NULL")
  }
  query <- paste0(
    "SELECT marker.case_id, CASE WHEN COUNT(DISTINCT marker.age_group)=1 THEN MIN(marker.age_group) END AS age_group, ",
    "BOOL_OR(marker.is_filtered) AS is_filtered FROM (SELECT ", case_id, " AS case_id, ",
    main_case_id, " AS main_case_id, CASE WHEN (", age, ") >= 18 THEN 'ge18' WHEN (", age,
    ") < 18 THEN 'lt18' END AS age_group, ", ip, " AS is_filtered FROM ",
    quoteTable(encounter$VIEW_SCHEMA[[1]], encounter$VIEW_NAME[[1]]), " e", patient_join, ward_join,
    ") classified CROSS JOIN LATERAL (VALUES (classified.case_id,classified.age_group,false), ",
    "(classified.main_case_id,NULL,classified.is_filtered)) marker(case_id,age_group,is_filtered) ",
    "WHERE marker.case_id IS NOT NULL GROUP BY marker.case_id"
  )
  attr(query, "age_source") <- age_source
  query
}
