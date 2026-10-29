source("/runner/adapter.R")
source("/runner/plausibility-functions.R")

main <- function() {
  logProgress <- function(text) {
    cat(sprintf("[%s] %s\n", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), text), file = stderr())
    flush(stderr())
  }
  config <- etlutils::dbReadConfigWithOverrides(
    "/src/cds_hub_db_config.toml", "/runner/database.toml",
    mandatory_override_parameters = "DB_NAME"
  )
  logProgress("Plausibilitätsprüfung: Datenbankverbindung aufbauen.")
  con <- DBI::dbConnect(RPostgres::Postgres(),
    host = config$DB_HOST, port = as.integer(config$DB_PORT),
    dbname = config$DB_NAME, user = config$DB_DATAPROCESSOR_USER, password = config$DB_DATAPROCESSOR_PASSWORD
  )
  on.exit(DBI::dbDisconnect(con))
  DBI::dbExecute(con, "SET default_transaction_read_only = on")
  DBI::dbExecute(con, "SET TIME ZONE 'Europe/Berlin'")
  DBI::dbExecute(con, "SET lock_timeout = '5s'")
  runPlausibility(con, readPeriods("/src/R-dataprocessor/dataprocessor_config.toml"), "/run", logProgress)
}

main()
