#' Build the fallvignette source query
#'
#' Builds the database query for retrospective MRPs that are eligible for the
#' WP8 fallvignette export. Source fields are derived from the mapping workbook.
#'
#' @param mapping Normalized mapping returned by [loadFallvignetteMapping()].
#'
#' @return A SQL query as one character string.
buildFallvignetteSourceQuery <- function(mapping) {
  if (
    !data.table::is.data.table(mapping) ||
    !all(c("source_field", "target_field") %in% names(mapping))
  ) {
    stop("mapping must be a normalized fallvignette mapping.")
  }

  directly_mapped_rows <- !mapping[["target_field"]] %in% c(
    "record_id",
    "wp8_standort_id",
    "wp8_mrp_fachbereich"
  )
  source_fields <- unique(mapping[["source_field"]][directly_mapped_rows])
  source_fields <- source_fields[
    !is.na(source_fields) & nzchar(source_fields)
  ]
  invalid_source_fields <- source_fields[
    !grepl("^[a-z][a-z0-9_]*$", source_fields)
  ]
  if (length(invalid_source_fields)) {
    stop(
      "Fallvignette mapping contains invalid source fields: ",
      paste(invalid_source_fields, collapse = ", ")
    )
  }

  supported_source_fields <- grepl("^(pat|meda|ret)_", source_fields) |
    source_fields == "fall_age_at_admission"
  unsupported_source_fields <- source_fields[!supported_source_fields]
  if (length(unsupported_source_fields)) {
    stop(
      "Fallvignette mapping contains unsupported source fields: ",
      paste(unsupported_source_fields, collapse = ", ")
    )
  }

  get_source_expression <- function(source_field) {
    if (source_field == "fall_age_at_admission") {
      return("fall_fe.fall_age_at_admission AS fall_age_at_admission")
    }

    source_alias <- if (startsWith(source_field, "pat_")) {
      "patient_fe"
    } else if (startsWith(source_field, "meda_")) {
      "meda_fe"
    } else {
      "ret_fe"
    }
    paste0(source_alias, ".", source_field, " AS ", source_field)
  }

  mapped_select <- vapply(
    source_fields,
    get_source_expression,
    character(1)
  )
  identifier_select <- c(
    "ret_fe.record_id AS source_record_id",
    "patient_fe.pat_id",
    "fall_fe.fall_fhir_enc_id",
    "fall_fe.fall_id",
    "fall_fe.fall_station",
    "fall_fe.fall_aufn_dat",
    "fall_fe.fall_ent_dat",
    "meda_fe.meda_id",
    "meda_fe.meda_dat",
    "ret_fe.ret_id",
    "ret_fe.ret_meda_id"
  )
  select_expressions <- unique(c(identifier_select, mapped_select))

  paste0(
    "SELECT DISTINCT\n  ",
    paste(select_expressions, collapse = ",\n  "),
    "\nFROM v_retrolektive_mrpbewertung_fe_last_version AS ret_fe\n",
    "INNER JOIN v_medikationsanalyse_fe_last_version AS meda_fe\n",
    "  ON meda_fe.record_id = ret_fe.record_id\n",
    "  AND meda_fe.meda_id = ret_fe.ret_meda_id\n",
    "INNER JOIN v_fall_fe_last_version AS fall_fe\n",
    "  ON fall_fe.record_id = meda_fe.record_id\n",
    "  AND fall_fe.fall_id = meda_fe.fall_meda_id\n",
    "  AND fall_fe.redcap_data_access_group IS NOT DISTINCT FROM ",
    "meda_fe.redcap_data_access_group\n",
    "INNER JOIN v_patient_fe_last_version AS patient_fe\n",
    "  ON patient_fe.record_id = ret_fe.record_id\n",
    "WHERE ret_fe.ret_id IS NOT NULL\n",
    "  AND ret_fe.ret_meda_id IS NOT NULL\n",
    "  AND (\n",
    "    ret_fe.ret_gewiss_grund1_abl_01 = ",
    "'MRP sachlich richtig, aber klinisch nicht relevant'\n",
    "    OR ret_fe.ret_gewiss_grund2_abl_01 = ",
    "'MRP sachlich richtig, aber klinisch nicht relevant'\n",
    "  )\n",
    "  AND ret_fe.ret_id NOT LIKE '%-TEST-%'\n",
    "  AND COALESCE(ret_fe.ret_kurzbeschr, '') NOT ILIKE '%*TEST*%'\n",
    "  AND EXISTS (\n",
    "    SELECT 1\n",
    "    FROM v_mrpdokumentation_validierung_fe_last_version AS mrp_fe\n",
    "    WHERE mrp_fe.record_id = ret_fe.record_id\n",
    "      AND mrp_fe.mrp_meda_id = ret_fe.ret_meda_id\n",
    "      AND mrp_fe.mrp_id IS NOT NULL\n",
    "  )\n",
    "ORDER BY source_record_id, ret_fe.ret_meda_id, ret_fe.ret_id"
  )
}

#' Retrieve eligible fallvignette source rows
#'
#' @param mapping Normalized mapping returned by [loadFallvignetteMapping()].
#' @param lock_id Database lock identifier passed to the query function.
#' @param query_fun Function used to execute the read-only database query.
#'
#' @return A data.table with one row per eligible retrospective MRP and fall
#'   assignment.
getFallvignetteSourceData <- function(
  mapping,
  lock_id = "Fallvignette_Process_Evaluation",
  query_fun = etlutils::dbGetReadOnlyQuery
) {
  if (!is.function(query_fun)) {
    stop("query_fun must be a function.")
  }

  query <- buildFallvignetteSourceQuery(mapping)
  result <- query_fun(query, lock_id = lock_id)
  if (!is.data.frame(result)) {
    stop("The fallvignette source query must return a data.frame or data.table.")
  }

  data.table::as.data.table(result)
}
