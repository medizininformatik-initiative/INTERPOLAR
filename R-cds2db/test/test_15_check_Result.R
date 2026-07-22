pid <- "UKB-0001"
main_encounter_id <- paste0(pid, "-E-1")

if (TOOLCHAIN_DAY == 1) {
  etlutils::dbInitModuleContext(
    module_name = "dataprocessor",
    path_to_db_toml = config_dataprocessor[["PATH_TO_DB_CONFIG_TOML"]],
    log = FALSE
  )
  recovery_pids <- etlutils::fhirdbGetIncompleteCasesPidsPerWard()
  recovery_rows <- data.table::rbindlist(recovery_pids, idcol = "ward_name")

  if (!pid %in% recovery_rows$patient_id) {
    stop(
      "Issue #813 recovery test failed after day 1: ",
      pid,
      " was not found as an incomplete case."
    )
  }

  cat("Issue #813 day 1 check passed: incomplete case detected.\n")
}

if (TOOLCHAIN_DAY == 2) {
  etlutils::dbInitModuleContext(
    module_name = "dataprocessor",
    path_to_db_toml = config_dataprocessor[["PATH_TO_DB_CONFIG_TOML"]],
    log = FALSE
  )
  recovery_pids <- etlutils::fhirdbGetIncompleteCasesPidsPerWard()
  recovery_rows <- data.table::rbindlist(recovery_pids, idcol = "ward_name")

  if (nrow(recovery_rows) && pid %in% recovery_rows$patient_id) {
    stop(
      "Issue #813 recovery test failed after day 2: ",
      pid,
      " is still reported as incomplete."
    )
  }

  etlutils::dbInitModuleContext(
    module_name = "dataprocessor",
    path_to_db_toml = config_dataprocessor[["PATH_TO_DB_CONFIG_TOML"]],
    log = FALSE
  )
  pids_per_ward <- etlutils::dbGetReadOnlyQuery(
    paste0(
      "SELECT patient_id, encounter_id\n",
      "FROM v_pids_per_ward_last_import\n",
      "WHERE patient_id = '", pid, "';"
    ),
    lock_id = "test_15_check_Result.pids_per_ward"
  )
  fall_fe <- etlutils::dbGetReadOnlyQuery(
    paste0(
      "SELECT fall_pat_id, fall_fhir_enc_id\n",
      "FROM v_fall_fe\n",
      "WHERE fall_pat_id = '", pid, "'\n",
      "  AND fall_fhir_enc_id = '", main_encounter_id, "';"
    ),
    lock_id = "test_15_check_Result.fall_fe"
  )
  etlutils::dbCloseAllConnections()

  if (!nrow(pids_per_ward)) {
    stop(
      "Issue #813 recovery test failed after day 2: ",
      pid,
      " is missing from the last pids_per_ward import."
    )
  }
  if (!nrow(fall_fe)) {
    stop(
      "Issue #813 recovery test failed after day 2: ",
      main_encounter_id,
      " is missing from fall_fe."
    )
  }

  cat("Issue #813 day 2 check passed: case recovered into fall_fe.\n")
}
