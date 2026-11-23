testthat::test_that("source query supports current, legacy and mixed REDCap fields", {
  connection <- getOption("interpolar.test.postgres_connection")
  testthat::skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  testthat::skip_if_not_installed("DBI")
  mapping <- getTestFallvignetteMapping()
  eligible <- "MRP sachlich richtig, aber klinisch nicht relevant"
  tables <- list(
    patient_fe = data.frame(record_id = "record-1", pat_id = "patient-1"),
    fall_fe = data.frame(
      record_id = "record-1", fall_id = "case-1", fall_fhir_enc_id = "encounter-1",
      fall_station = "Station 1", fall_age_at_admission = 43L,
      fall_aufn_dat = as.POSIXct("2024-06-14 10:00:00", tz = "UTC"),
      fall_ent_dat = as.POSIXct(NA, tz = "UTC"), redcap_data_access_group = NA_character_
    ),
    meda_fe = data.frame(
      record_id = "record-1", meda_id = "analysis-1", fall_meda_id = "case-1",
      meda_dat = as.POSIXct("2024-06-15 12:00:00", tz = "UTC"),
      redcap_data_access_group = NA_character_
    ),
    ret_fe = data.frame(
      record_id = "record-1", ret_id = paste0("mrp-", 1:6), ret_meda_id = "analysis-1",
      ret_kurzbeschr = "Test-MRP", ret_atc1 = "C09AA05", ret_ip_klasse_01 = "Drug-Disease",
      ret_gewiss_grund1_abl_01 = c(eligible, NA, "other", eligible, "other", NA),
      ret_gewiss_grund2_abl_01 = c(NA, eligible, NA, eligible, NA, NA)
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
      tables[[alias]][[column_name]] <- rep(NA_character_, nrow(tables[[alias]]))
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
  current <- getFallvignetteSourceData(mapping, query_fun = query_fun)
  testthat::expect_equal(current$ret_id, c("mrp-1", "mrp-2", "mrp-4"))

  DBI::dbExecute(connection, paste(
    "ALTER TABLE pg_temp.v_retrolektive_mrpbewertung_fe_last_version",
    "RENAME COLUMN ret_gewiss_grund1_abl_01 TO ret_gewiss_grund1_abl"
  ))
  testthat::expect_equal(getFallvignetteSourceData(mapping, query_fun = query_fun), current)
  DBI::dbExecute(connection, paste(
    "ALTER TABLE pg_temp.v_retrolektive_mrpbewertung_fe_last_version",
    "RENAME COLUMN ret_gewiss_grund2_abl_01 TO ret_gewiss_grund2_abl"
  ))
  legacy <- getFallvignetteSourceData(mapping, query_fun = query_fun)
  testthat::expect_equal(legacy, current)
  export <- createFallvignetteImportData(legacy, mapping,
    ward_definitions = list(PHASES_WARD_1 = c(
      "ward_name = 'Station 1'", "department = '0100 Innere Medizin'"
    )),
    site_code = "UKB"
  )
  testthat::expect_equal(export$wp8_ret_id, c("mrp-1", "mrp-2", "mrp-4", "mrp-4"))

  DBI::dbExecute(connection, paste(
    "ALTER TABLE pg_temp.v_retrolektive_mrpbewertung_fe_last_version",
    "ADD COLUMN ret_gewiss_grund1_abl_01 text, ADD COLUMN ret_gewiss_grund2_abl_01 text"
  ))
  # Filled current values win; NULL and empty current values use legacy values.
  DBI::dbExecute(connection, paste(
    "UPDATE pg_temp.v_retrolektive_mrpbewertung_fe_last_version",
    "SET ret_gewiss_grund1_abl_01 = CASE WHEN ret_id IN ('mrp-1', 'mrp-5') THEN 'other' ELSE '' END,",
    "ret_gewiss_grund2_abl_01 = CASE WHEN ret_id = 'mrp-2' THEN NULL ELSE '' END,",
    "ret_gewiss_grund1_abl = CASE WHEN ret_id IN ('mrp-5', 'mrp-6')",
    "THEN 'MRP sachlich richtig, aber klinisch nicht relevant' ELSE ret_gewiss_grund1_abl END"
  ))
  mixed <- getFallvignetteSourceData(mapping, query_fun = query_fun)
  testthat::expect_equal(mixed$ret_id, c("mrp-2", "mrp-4", "mrp-6"))
  testthat::expect_equal(mixed$ret_gewiss_grund1_abl_01, c(NA_character_, eligible, eligible))
  testthat::expect_equal(mixed$ret_gewiss_grund2_abl_01, c(eligible, eligible, NA_character_))
})
