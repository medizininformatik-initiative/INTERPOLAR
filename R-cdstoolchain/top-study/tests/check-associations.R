source("/runner/adapter.R")

checkAssociations <- function() {
  config <- etlutils::readTomlAsNamedList("/src/cds_hub_db_config.toml")
  con <- DBI::dbConnect(RPostgres::Postgres(),
    host = config$DB_HOST, port = as.integer(config$DB_PORT),
    dbname = config$DB_NAME, user = config$DB_DATAPROCESSOR_USER, password = config$DB_DATAPROCESSOR_PASSWORD
  )
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  DBI::dbBegin(con)
  on.exit(DBI::dbRollback(con), add = TRUE, after = FALSE)
  # Roll back all fixture changes before the normal end-to-end run.
  DBI::dbExecute(con, "TRUNCATE db2dataprocessor_out.v_pids_per_ward,
    db2dataprocessor_out.v_encounter_last_version, db2dataprocessor_out.v_patient_last_version")
  DBI::dbExecute(con, "ALTER TABLE db2dataprocessor_out.v_encounter_last_version
    DROP CONSTRAINT v_encounter_last_version_pkey")
  DBI::dbExecute(con, "INSERT INTO db2dataprocessor_out.v_patient_last_version(pat_id) VALUES ('p')")
  DBI::dbExecute(con, "INSERT INTO db2dataprocessor_out.v_encounter_last_version
    (enc_id, enc_type_code, enc_patient_ref, enc_period_start, enc_main_encounter_calculated_ref) VALUES
    ('h','einrichtungskontakt','Patient/p','2026-01-01',NULL),
    ('h','einrichtungskontakt','Patient/p','2026-01-01',NULL),
    ('not_hospital','station','Patient/p','2026-01-01',NULL),
    ('good','station','Patient/p','2026-01-15','Encounter/h'),
    ('no_start','station','Patient/p',NULL,'Encounter/h'),
    ('no_ref','station','Patient/p','2026-01-15',NULL),
    ('missing_main','station','Patient/p','2026-01-15','Encounter/missing'),
    ('wrong_type','station','Patient/p','2026-01-15','Encounter/not_hospital'),
    ('malformed','station','Patient/p','2026-01-15','h'),
    ('empty_ref','station','Patient/p','2026-01-15',''),
    ('duplicate_bad','station','Patient/p','2026-01-15','Encounter/missing'),
    ('duplicate_bad','station','Patient/p','2026-01-15','Encounter/missing')")
  periods <- data.frame(ward_name = c("A", "B"), start = "2026-01-10", end = "2026-02-01")
  old_sql <- paste0(scopeSql(periods), paste(readLines("/runner/tests/legacy-health.sql"), collapse = "\n"))
  new_sql <- preparationSql(periods)
  # Every failure category is checked independently, then with repeated imports.
  cases <- data.frame(
    encounter_id = c("good", "absent", "no_start", "no_ref", "missing_main", "wrong_type", "malformed", "empty_ref", "duplicate_bad", "good", "good", NA),
    ward_name = c(rep("A", 9), "unknown", NA, "A"),
    invalid = c(0, rep(1, 7), 2, 1, 1, 1)
  )
  check <- function(expected_invalid) {
    old <- DBI::dbGetQuery(con, old_sql)
    new <- DBI::dbGetQuery(con, new_sql)
    stopifnot(identical(old, new), as.numeric(new$invalid_contacts) == expected_invalid)
  }
  for (i in seq_len(nrow(cases))) {
    DBI::dbExecute(con, "TRUNCATE db2dataprocessor_out.v_pids_per_ward")
    DBI::dbAppendTable(con, DBI::Id(schema = "db2dataprocessor_out", table = "v_pids_per_ward"), cases[i, c("encounter_id", "ward_name")])
    check(cases$invalid[i])
  }
  DBI::dbExecute(con, "TRUNCATE db2dataprocessor_out.v_pids_per_ward")
  repeated <- cases[rep(seq_len(nrow(cases)), each = 3), c("encounter_id", "ward_name")]
  DBI::dbAppendTable(con, DBI::Id(schema = "db2dataprocessor_out", table = "v_pids_per_ward"), repeated)
  check(3 * sum(cases$invalid))
  # Conflicting wards must remain visible, despite duplicate imported rows.
  DBI::dbExecute(con, "INSERT INTO db2dataprocessor_out.v_pids_per_ward VALUES ('good','B'), ('good','B')")
  check(3 * sum(cases$invalid))
  stopifnot(as.numeric(DBI::dbGetQuery(con, new_sql)$ambiguous_first_contacts) == 1)
  cat("PASS: equal counts for missing, malformed, unknown and duplicate associations; conflicting wards preserved.\n")
}

checkAssociations()
