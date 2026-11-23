source("/runner/adapter.R")

prepareStudyRun <- function() {
  logProgress <- function(text) {
    # stderr is redirected to preparation.log; flush each step for live diagnostics.
    cat(sprintf("[%s] %s\n", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), text), file = stderr())
    flush(stderr())
  }
  logProgress("R-Vorbereitung gestartet: Konfiguration und Adaptervorlage lesen.")
  out <- "/run"
  dir.create(file.path(out, "private"), showWarnings = FALSE, mode = "0700")
  original_path <- file.path(out, "original.yml")
  periods <- readPeriods("/src/R-dataprocessor/dataprocessor_config.toml")
  original <- yaml::read_yaml(original_path, eval.expr = FALSE)
  condition <- yaml::read_yaml("/runner/icd-prefix.yml", eval.expr = FALSE)$condition
  adapter <- makeAdapter(original, condition, periods)
  yaml::write_yaml(adapter, file.path(out, "adapter.yml"))
  config <- etlutils::dbReadConfigWithOverrides(
    "/src/cds_hub_db_config.toml", "/runner/database.toml",
    mandatory_override_parameters = "DB_NAME"
  )
  logProgress("Adapter erzeugt. Datenbankverbindung aufbauen.")
  con <- DBI::dbConnect(
    RPostgres::Postgres(),
    host = config$DB_HOST, port = as.integer(config$DB_PORT),
    dbname = config$DB_NAME, user = config$DB_DATAPROCESSOR_USER,
    password = config$DB_DATAPROCESSOR_PASSWORD
  )
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  logProgress("Datenbankverbindung hergestellt. Sitzung und PostgreSQL-Version prüfen.")
  DBI::dbExecute(con, "SET default_transaction_read_only = on")
  DBI::dbExecute(con, "SET TIME ZONE 'Europe/Berlin'")
  DBI::dbExecute(con, "SET lock_timeout = '5s'")
  pg_version <- DBI::dbGetQuery(con, "SHOW server_version_num")[[1]][[1]]
  if (as.integer(pg_version) < 150000) stop("Die ICD-Präfixsuche benötigt PostgreSQL ab Version 15.")
  logProgress("Datenbanksitzung bereit. Fallauswahl und Zuordnungsprüfung starten.")
  # This checks selection integrity, not model results; no source IDs are exported.
  health <- DBI::dbGetQuery(con, preparationSql(periods))
  logProgress("Fallauswahl und Zuordnungsprüfung abgeschlossen.")
  health <- lapply(health, as.numeric)
  jsonlite::write_json(health, file.path(out, "preparation.json"), auto_unbox = TRUE, pretty = TRUE)
  if (health$ignored_missing_encounter_contacts > 0) {
    logProgress(paste("Hinweis: Ignorierte Stationszuordnungszeilen ohne Encounter:", health$ignored_missing_encounter_contacts))
  }
  # Missing encounters are already excluded by the inner join in scopeSql.
  if (health$invalid_contacts > health$ignored_missing_encounter_contacts || health$ambiguous_first_contacts > 0) {
    stop("Fallauswahl nicht eindeutig; aggregierte Angaben stehen in preparation.json.")
  }
  logProgress("Studienadapter und Versionsprotokoll schreiben.")
  # JDBC receives explicit read-only and local-time settings on each TOP connection.
  host <- config$DB_HOST
  if (grepl(":", host, fixed = TRUE) && !startsWith(host, "[")) host <- paste0("[", host, "]")
  adapter$connection <- list(
    url = paste0(
      "jdbc:postgresql://", host, ":", as.integer(config$DB_PORT), "/",
      utils::URLencode(config$DB_NAME, reserved = TRUE),
      "?options=-c%20default_transaction_read_only%3Don%20-c%20TimeZone%3DEurope%2FBerlin%20-c%20lock_timeout%3D5000"
    ),
    user = config$DB_DATAPROCESSOR_USER, password = config$DB_DATAPROCESSOR_PASSWORD
  )
  yaml::write_yaml(adapter, file.path(out, "private", "adapter.yml"))
  Sys.chmod(file.path(out, "private", "adapter.yml"), "0600")
  jsonlite::write_json(list(
    top_image = readLines("/runner/image.txt", warn = FALSE),
    original_adapter_sha256 = digest::digest(file = original_path, algo = "sha256"),
    icd_component_sha256 = digest::digest(file = "/runner/icd-prefix.yml", algo = "sha256"),
    generated_adapter_sha256 = digest::digest(file = file.path(out, "adapter.yml"), algo = "sha256"),
    postgresql = as.character(pg_version), r = as.character(getRversion()),
    population = "study", timezone = "Europe/Berlin",
    boundary = "first IP start >= phase_a_start date and < phase_b_end date"
  ), file.path(out, "versions.json"), auto_unbox = TRUE, pretty = TRUE)
  logProgress(paste("Vorbereitung abgeschlossen. Studienfälle:", health$study_cases))
}

prepareStudyRun()
