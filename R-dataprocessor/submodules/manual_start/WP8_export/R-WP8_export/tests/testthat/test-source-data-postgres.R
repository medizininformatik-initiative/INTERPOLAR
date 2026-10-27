testthat::test_that("source query supports normal and pseudonymized snapshot schemas", {
  connection <- getOption("interpolar.test.postgres_connection")
  testthat::skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  testthat::skip_if_not_installed("DBI")
  mapping <- getTestFallvignetteMapping()
  record_ids <- paste0("record-", 1:6)
  case_ids <- paste0("case-", 1:6)
  tables <- list(
    patient_fe = data.frame(
      record_id = record_ids,
      pat_id = paste0("original-patient-", 1:6),
      pat_gebdat = as.Date(c("1980-06-15", "1950-01-01", NA, "1909-12-31", "2025-01-01", "1980-01-01"))
    ),
    fall_fe = data.frame(
      record_id = record_ids,
      fall_id = case_ids,
      fall_fhir_enc_id = paste0("original-encounter-", 1:6),
      fall_station = "Station 1",
      fall_aufn_dat = as.POSIXct(c(rep("2024-06-14 10:00:00", 5L), NA), tz = "UTC"),
      fall_ent_dat = as.POSIXct(NA, tz = "UTC"),
      redcap_data_access_group = NA_character_
    ),
    meda_fe = data.frame(
      record_id = record_ids,
      meda_id = paste0("analysis-", 1:6),
      meda_dat = as.POSIXct("2024-06-15 12:00:00", tz = "UTC"),
      fall_meda_id = case_ids,
      redcap_data_access_group = NA_character_
    ),
    ret_fe = data.frame(
      record_id = record_ids,
      ret_id = paste0("mrp-", 1:6),
      ret_meda_id = paste0("analysis-", 1:6),
      ret_kurzbeschr = "Test-MRP",
      ret_atc1 = "C09AA05",
      ret_ip_klasse_01 = "Drug-Disease",
      ret_gewiss_grund1_abl_01 = "MRP sachlich richtig, aber klinisch nicht relevant"
    )
  )
  aliases <- c(
    patient_fe = "patient_fe", fall_fe = "fall_fe",
    meda_fe = "medikationsanalyse_fe", ret_fe = "retrolektive_mrpbewertung_fe"
  )
  prefixes <- c(patient_fe = "pat_", meda_fe = "meda_", ret_fe = "ret_")
  source_fields <- unique(mapping$source_field[!is.na(mapping$source_field)])
  for (alias in names(prefixes)) {
    fields <- source_fields[startsWith(source_fields, prefixes[[alias]])]
    for (column_name in setdiff(fields, names(tables[[alias]]))) {
      tables[[alias]][[column_name]] <- rep(NA_character_, 6L)
    }
  }
  table_names <- paste0("v_", aliases, "_last_version")
  on.exit(
    {
      for (name in table_names) DBI::dbRemoveTable(connection, DBI::Id(schema = "pg_temp", table = name))
    },
    add = TRUE
  )
  for (alias in names(tables)) {
    DBI::dbWriteTable(connection, paste0("v_", aliases[[alias]], "_last_version"), tables[[alias]], temporary = TRUE)
  }
  query_fun <- function(query, lock_id = NULL) DBI::dbGetQuery(connection, query)
  normal <- getFallvignetteSourceData(mapping, query_fun = query_fun)
  testthat::expect_equal(normal$fall_age_at_admission, c(43L, 74L, rep(NA_integer_, 4L)))
  testthat::expect_equal(normal$fall_id, case_ids)
  testthat::expect_equal(normal$pat_id, tables$patient_fe$pat_id)
  testthat::expect_false("pat_gebdat" %in% names(normal))

  export <- createFallvignetteImportData(normal, mapping,
    ward_definitions = list(PHASES_WARD_1 = c(
      "ward_name = 'Station 1'", "department = '0100 Innere Medizin'"
    )),
    site_code = "UKB"
  )
  testthat::expect_equal(export$wp8_fv_alter, c("43", "74", rep(NA_character_, 4L)))
  testthat::expect_equal(attr(export, "fallvignette_id_mapping")$fall_id, case_ids)

  DBI::dbExecute(connection, "ALTER TABLE pg_temp.v_fall_fe_last_version ADD COLUMN fall_age_at_admission integer")
  DBI::dbExecute(connection, "UPDATE pg_temp.v_fall_fe_last_version SET fall_age_at_admission = 55 WHERE record_id = 'record-1'")
  DBI::dbExecute(connection, "ALTER TABLE pg_temp.v_patient_fe_last_version DROP COLUMN pat_gebdat")
  pseudonymized <- getFallvignetteSourceData(mapping, query_fun = query_fun)
  # Existing ages, including NULL, must be preserved without a birthdate column.
  testthat::expect_equal(pseudonymized$fall_age_at_admission, c(55L, rep(NA_integer_, 5L)))
  DBI::dbExecute(connection, "ALTER TABLE pg_temp.v_fall_fe_last_version DROP COLUMN fall_age_at_admission")
  missing_birthdates <- getFallvignetteSourceData(mapping, query_fun = query_fun)
  testthat::expect_true(all(is.na(missing_birthdates$fall_age_at_admission)))
})
