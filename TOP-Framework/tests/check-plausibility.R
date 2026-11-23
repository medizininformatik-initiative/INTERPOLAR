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
  # Uneven multiplication must not weight the median; distinct resources with
  # equal values remain separate. Missing values and unsuccessful statuses count.
  observations <- "WITH observations(obs_id, enc_id, analysis_loinc_code,
    analysis_unit, analysis_value_status, analysis_value) AS (
    VALUES ('A','case1','59260-0','mmol/L','converted',2.0),
      ('A','case1','59260-0','mmol/L','converted',2.0),
      ('A','case1','59260-0','mmol/L','converted',2.0),
      ('B','case1','59260-0','mmol/L','converted',8.0),
      ('B','case1','59260-0','mmol/L','converted',8.0),
      ('C','case2','59260-0','mmol/L','converted',20.0),
      ('D','case2','59260-0','mmol/L','converted',8.0),
      ('E','case1','59260-0',NULL,'missing_value',NULL),
      ('E','case1','59260-0',NULL,'missing_value',NULL),
      ('F','case1','59260-0','g/dL','source_conversion_failed',9.0),
      ('G','case2','59260-0','g/dL',NULL,5.0)
  )"
  summary <- DBI::dbGetQuery(con, laboratorySummarySql(observations))
  valid <- summary[which(summary$analysis_value_status == "converted"), ]
  missing <- summary[which(summary$analysis_value_status == "missing_value"), ]
  failed <- summary[which(summary$analysis_value_status == "source_conversion_failed"), ]
  unknown <- summary[is.na(summary$analysis_value_status), ]
  stopifnot(
    nrow(summary) == 4, all(summary$invalid_resources == 0),
    valid$observations == 4, valid$cases == 2, valid$minimum == 2,
    valid$median == 8, valid$maximum == 20, valid$evaluable == "Ja",
    missing$observations == 1, missing$cases == 1, missing$evaluable == "Nein",
    is.na(missing$minimum), is.na(missing$median), is.na(missing$maximum),
    failed$observations == 1, failed$median == 9, failed$evaluable == "Nein",
    unknown$observations == 1, unknown$median == 5, unknown$evaluable == "Nein"
  )
  # Never silently choose among conflicting values or invent resource identities.
  for (invalid in c("NULL", "''", "'A'")) {
    conflicting <- sub("'G'", invalid, observations, fixed = TRUE)
    stopifnot(all(DBI::dbGetQuery(con, laboratorySummarySql(conflicting))$invalid_resources == 1))
  }
  # Exercise the generated adapter against flattened rows inside this rollback.
  DBI::dbExecute(con, "ALTER TABLE db2dataprocessor_out.v_observation_last_version DROP CONSTRAINT v_observation_last_version_pkey")
  DBI::dbExecute(con, "INSERT INTO db2dataprocessor_out.v_observation_last_version SELECT * FROM db2dataprocessor_out.v_observation_last_version WHERE obs_id='hb1'")
  original <- yaml::read_yaml("/baseline/original.yml", eval.expr = FALSE)
  condition <- yaml::read_yaml("/runner/icd-prefix.yml", eval.expr = FALSE)$condition
  adapter <- makeAdapter(original, condition, readPeriods("/src/R-dataprocessor/dataprocessor_config.toml"))
  sql <- gsub("{codes}", "'http://loinc.org|59260-0'", adapter$phenotypeQueries$observation$baseQuery, fixed = TRUE)
  actual <- DBI::dbGetQuery(con, sql)
  stopifnot(sum(actual$enc_id == "early_hospital") == 2)
  # Both distinct IDs survive, but the added row of hb1 does not.
  # Every unsuccessful or absent status must exclude even an extreme numeric value.
  for (status in c(
    "source_no_mapping", "source_no_mapping_missing_unit",
    "source_mapping_missing_unit", "source_missing_unit", "source_conversion_failed",
    "missing_value", "unexpected", "", NA_character_
  )) {
    DBI::dbExecute(con, "UPDATE db2dataprocessor_out.v_observation_last_version SET analysis_value_status=$1 WHERE obs_id='hb2'", params = list(status))
    stopifnot(!"at_start" %in% DBI::dbGetQuery(con, sql)$enc_id)
  }
  DBI::dbExecute(con, "UPDATE db2dataprocessor_out.v_observation_last_version SET analysis_value_status='source_conversion_failed' WHERE obs_id='hb2'")
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
    comparison$comparison_status == "difference", comparison$both_positive == 1,
    comparison$top_only == 1, comparison$control_only == 1, comparison$both_negative == 2
  )
  coverage <- auditTable(audit, "ANÄMIE: DATENABDECKUNG UND ZEITLICHE LAGE POSITIVER BEFUNDE (Fallzahlen, Zeitgruppen überlappen)")
  stopifnot(coverage$without_hb_values[coverage$sex == "female"] == 2)
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
  absent <- auditTable(audit, "LABORPARAMETER OHNE OBSERVATIONS")
  stopifnot(
    any(absent$LOINC == "14682-9" & absent$Modelle == "acute_kidney_injury"),
    !any(absent$LOINC == "29553-5"),
    any(grepl("Verwendende Modelle: hyperkalemia, hypokalemia", readLines(audit), fixed = TRUE))
  )
  cat("PASS: equal totals with differing case sets, missing Hb values and missing patient links are detected.\n")
}
main()
