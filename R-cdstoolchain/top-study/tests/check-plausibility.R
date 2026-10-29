source("/runner/adapter.R")
source("/runner/plausibility-functions.R")
source("/runner/tests/read-audit.R")

main <- function() {
  config <- etlutils::dbReadConfigWithOverrides("/src/cds_hub_db_config.toml", "/runner/database.toml",
    mandatory_override_parameters = "DB_NAME"
  )
  con <- DBI::dbConnect(RPostgres::Postgres(),
    host = config$DB_HOST, port = as.integer(config$DB_PORT),
    dbname = config$DB_NAME, user = config$DB_DATAPROCESSOR_USER, password = config$DB_DATAPROCESSOR_PASSWORD
  )
  on.exit(DBI::dbDisconnect(con))
  DBI::dbExecute(con, "SET TIME ZONE 'Europe/Berlin'")
  DBI::dbBegin(con)
  on.exit(DBI::dbRollback(con), add = TRUE, after = FALSE)
  # Equal total counts but different case sets must be reported as a mismatch.
  DBI::dbExecute(con, "DELETE FROM db2dataprocessor_out.v_observation_last_version WHERE obs_id IN ('hb1','hb1_duplicate')")
  DBI::dbExecute(con, "UPDATE db2dataprocessor_out.v_observation_last_version SET analysis_value=7 WHERE obs_id='hb4'")
  out <- tempfile()
  dir.create(out)
  stopifnot(file.copy("/baseline/models", out, recursive = TRUE), file.copy("/baseline/results", out, recursive = TRUE))
  runPlausibility(con, readPeriods("/src/R-dataprocessor/dataprocessor_config.toml"), out, function(...) NULL)
  audit <- file.path(out, "plausibility.txt")
  comparison <- auditTable(audit, "ANÄMIE-KONTROLLVERGLEICH: Algorithmus 1")
  stopifnot(
    comparison$comparison_status == "difference", comparison$both_positive == 2,
    comparison$top_only == 1, comparison$control_only == 1, comparison$both_negative == 1
  )
  coverage <- auditTable(audit, "ANÄMIE: DATENABDECKUNG UND ZEITLICHE LAGE POSITIVER BEFUNDE (Fallzahlen, Zeitgruppen überlappen)")
  stopifnot(coverage$without_hb_values[coverage$sex == "female"] == 1)
  # Read the actual image's complete model inventory, including unspecified units.
  stopifnot(all(file.copy(list.files("/reference-models", full.names = TRUE), file.path(out, "models"), overwrite = TRUE)))
  # Cohort audit must also explain hospital cases with a missing patient record.
  DBI::dbExecute(con, "UPDATE db2dataprocessor_out.v_encounter_last_version SET enc_patient_ref='Patient/absent' WHERE enc_id='multiple'")
  runPlausibility(con, readPeriods("/src/R-dataprocessor/dataprocessor_config.toml"), out, function(...) NULL)
  cohort <- auditTable(audit, "ABGLEICH DER FALLAUSWAHL")
  selection <- auditTable(audit, "FALLAUSWAHL NACH ERSTER IP-STATION (Studienende exklusiv)")
  stopifnot(
    cohort$independent_cases == 4, cohort$adapter_cases == 4,
    selection$cases[selection$selection == "within_study_missing_patient"] == 1
  )
  labs <- auditTable(audit, "LABORABDECKUNG (Modellparameter, auch wenn nicht jeder Algorithmus sie verwendet)")
  stopifnot(
    any(labs$model == "acute_kidney_injury" & labs$expected_unit == "not_declared"),
    !any(labs$analysis_loinc_code == "29553-5")
  )
  cat("PASS: equal totals with differing case sets, missing Hb values and missing patient links are detected.\n")
}
main()
