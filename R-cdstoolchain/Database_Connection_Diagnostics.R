# These diagnostics use independent sessions and never retry a failed statement.
# Fork workers before opening connections; inherited libpq sockets are unsafe.
redactDatabaseDiagnostic <- function(text, config) {
  secrets <- unlist(config[grepl("PASSWORD|TOKEN|SECRET", names(config))], use.names = FALSE)
  secrets <- as.character(secrets[!is.na(secrets) & nzchar(secrets)])
  secrets <- secrets[order(nchar(secrets), decreasing = TRUE)]
  for (secret in secrets) text <- gsub(secret, "[REDACTED]", text, fixed = TRUE)
  text
}

runDatabaseDiagnosticJobs <- function(tasks, timeout, poll_seconds = 0.2) {
  jobs <- list()
  # SIGKILL also interrupts a worker blocked inside libpq. Only our child PIDs
  # are targeted. The server observes the closed diagnostic connection later.
  on.exit(
    {
      for (job in jobs) try(tools::pskill(job$pid, signal = 9L), silent = TRUE)
      if (length(jobs)) suppressWarnings(parallel::mccollect(jobs, wait = TRUE))
    },
    add = TRUE
  )
  for (name in names(tasks)) {
    task <- tasks[[name]]
    jobs[[name]] <- parallel::mcparallel(
      {
        started <- proc.time()[["elapsed"]]
        result <- tryCatch(list(status = "ok", value = task()),
          error = function(error) list(status = "error", message = conditionMessage(error))
        )
        result$elapsed_seconds <- proc.time()[["elapsed"]] - started
        result$finished_at_utc <- format(Sys.time(), tz = "UTC")
        result
      },
      silent = TRUE
    )
  }
  results <- list()
  deadline <- proc.time()[["elapsed"]] + timeout
  while (length(jobs) && proc.time()[["elapsed"]] < deadline) {
    for (name in names(jobs)) {
      collected <- suppressWarnings(parallel::mccollect(jobs[[name]], wait = FALSE))
      if (is.null(collected)) next
      value <- collected[[1L]]
      results[[name]] <- if (is.list(value) && !is.null(value$status)) value else {
        list(status = "error", message = "Diagnoseprozess ohne Ergebnis beendet.")
      }
      jobs[[name]] <- NULL
    }
    if (length(jobs)) Sys.sleep(poll_seconds)
  }
  for (name in names(jobs)) {
    results[[name]] <- list(
      status = "timeout", message = "Zeitgrenze erreicht; Diagnoseprozess beendet.",
      elapsed_seconds = timeout, finished_at_utc = format(Sys.time(), tz = "UTC")
    )
  }
  results[names(tasks)]
}

databaseDiagnosticConnection <- function(config, target = FALSE,
                                         execute = DBI::dbExecute, disconnect = DBI::dbDisconnect) {
  # Keep the snapshot connection path; change only the diagnostic session's
  # server-side TCP keepalive idle interval for this controlled comparison.
  connection <- connectSnapshotPseudonymizationDatabase(
    command_arguments = list(), db_config = config,
    dbname = snapshotPseudonymizationConfigValue(list(), config, "db_name", "cds_hub_db"),
    user_argument = if (target) "target_db_user" else "source_db_user",
    password_argument = if (target) "target_db_password" else "source_db_password"
  )
  ready <- FALSE
  on.exit(
    {
      if (!ready) try(disconnect(connection), silent = TRUE)
    },
    add = TRUE
  )
  execute(connection, "SET tcp_keepalives_idle = 600")
  ready <- TRUE
  connection
}

probeDatabaseDiagnosticConnection <- function(connection) {
  DBI::dbGetQuery(connection, paste(
    "SELECT clock_timestamp() AS server_time, pg_backend_pid() AS backend_pid,",
    "inet_server_addr()::text AS server_address, inet_server_port() AS server_port,",
    "inet_client_addr()::text AS client_address, current_user AS db_user,",
    "current_database() AS database"
  ))
}

readDatabaseDiagnosticSettings <- function(config) {
  connection <- databaseDiagnosticConnection(config)
  on.exit(try(DBI::dbDisconnect(connection), silent = TRUE), add = TRUE)
  settings <- paste(
    "'statement_timeout', 'lock_timeout', 'idle_session_timeout',",
    "'idle_in_transaction_session_timeout', 'transaction_timeout',",
    "'tcp_keepalives_idle', 'tcp_keepalives_interval', 'tcp_keepalives_count',",
    "'tcp_user_timeout', 'client_connection_check_interval'"
  )
  list(
    connection = probeDatabaseDiagnosticConnection(connection),
    settings = DBI::dbGetQuery(connection, paste0(
      "SELECT name, setting, unit, source FROM pg_settings WHERE name IN (",
      settings, ", 'server_version', 'work_mem', 'TimeZone') ORDER BY name"
    )),
    overrides = tryCatch(DBI::dbGetQuery(connection, paste0(
      "SELECT COALESCE(d.datname, '*') AS database, COALESCE(r.rolname, '*') AS role, s.setting ",
      "FROM pg_db_role_setting c LEFT JOIN pg_database d ON d.oid = c.setdatabase ",
      "LEFT JOIN pg_roles r ON r.oid = c.setrole ",
      "CROSS JOIN LATERAL unnest(c.setconfig) AS s(setting) ",
      "WHERE split_part(s.setting, '=', 1) IN (", settings, ") ORDER BY 1, 2, 3"
    )), error = function(error) paste("Nicht verfügbar:", conditionMessage(error)))
  )
}

readDatabaseDiagnosticQuery <- function(connection, sql) {
  result <- DBI::dbSendQuery(connection, sql)
  on.exit(
    {
      if (DBI::dbIsValid(result)) DBI::dbClearResult(result)
    },
    add = TRUE
  )
  rows <- 0L
  repeat {
    chunk <- DBI::dbFetch(result, n = getFromNamespace("DEFAULT_SNAPSHOT_CHUNK_SIZE", "pseudonym"))
    rows <- rows + nrow(chunk)
    if (DBI::dbHasCompleted(result)) break
  }
  rows
}

streamDatabaseDiagnostic <- function(source, config, wait_seconds) {
  target <- databaseDiagnosticConnection(config, target = TRUE)
  on.exit(try(DBI::dbDisconnect(target), silent = TRUE), add = TRUE)
  target_before <- probeDatabaseDiagnosticConnection(target)
  chunk_size <- getFromNamespace("DEFAULT_SNAPSHOT_CHUNK_SIZE", "pseudonym")
  expected_rows <- 2L * chunk_size + 1L
  result <- DBI::dbSendQuery(source, paste0(
    "SELECT i AS id, repeat('x', 1024) AS payload FROM generate_series(1, ", expected_rows, ") AS i"
  ))
  on.exit(
    {
      if (DBI::dbIsValid(result)) DBI::dbClearResult(result)
    },
    add = TRUE
  )
  table_name <- "interpolar_connection_diagnostic"
  rows <- 0L
  chunks <- 0L
  repeat {
    chunk <- DBI::dbFetch(result, n = chunk_size)
    chunks <- chunks + 1L
    if (chunks == 1L) {
      # Only synthetic data is written, into a session-local temporary table.
      DBI::dbWriteTable(target, table_name, chunk, overwrite = FALSE, temporary = TRUE)
    } else if (nrow(chunk) > 0L) {
      DBI::dbAppendTable(target, table_name, chunk)
    }
    rows <- rows + nrow(chunk)
    rm(chunk)
    if (DBI::dbHasCompleted(result)) break
    if (chunks == 1L) Sys.sleep(wait_seconds)
  }
  DBI::dbClearResult(result)
  written_rows <- DBI::dbGetQuery(target, paste0(
    "SELECT count(*) AS n FROM ", DBI::dbQuoteIdentifier(target, table_name)
  ))$n
  if (rows != expected_rows || written_rows != expected_rows) stop("Streaming row count mismatch.")
  list(
    rows = rows, chunks = chunks, target_before = target_before,
    target_after = probeDatabaseDiagnosticConnection(target)
  )
}

testDatabaseDiagnosticConnection <- function(config, mode, wait_seconds,
                                             connect = databaseDiagnosticConnection,
                                             probe = probeDatabaseDiagnosticConnection,
                                             disconnect = DBI::dbDisconnect,
                                             query = readDatabaseDiagnosticQuery) {
  connection <- connect(config)
  on.exit(try(disconnect(connection), silent = TRUE), add = TRUE)
  before <- probe(connection)
  stream <- NULL
  if (mode == "idle") {
    Sys.sleep(wait_seconds)
  } else if (mode == "query") {
    query(connection, paste0("SELECT 1 AS ok FROM pg_sleep(", as.integer(wait_seconds), ")"))
  } else if (mode == "stream") {
    stream <- streamDatabaseDiagnostic(connection, config, wait_seconds)
  } else if (mode != "fresh") {
    stop("Unknown diagnostic mode.")
  }
  list(before = before, after = probe(connection), stream = stream)
}

readDatabaseDiagnosticNetwork <- function(config) {
  host <- snapshotPseudonymizationConfigValue(list(), config, "db_host", "cds_hub")
  dns <- if (nzchar(Sys.which("getent"))) {
    suppressWarnings(system2("getent", c("ahosts", shQuote(host)), stdout = TRUE, stderr = TRUE))
  } else "getent nicht verfügbar; DNS-Auflösung nicht separat erfasst."
  kernel <- vapply(c("tcp_keepalive_time", "tcp_keepalive_intvl", "tcp_keepalive_probes"), function(name) {
    path <- file.path("/proc/sys/net/ipv4", name)
    if (file.exists(path)) paste(readLines(path, warn = FALSE), collapse = " ") else "nicht verfügbar"
  }, character(1))
  list(host = host, dns = dns, client_kernel_keepalives = kernel)
}

summarizeDatabaseDiagnostic <- function(tests, fresh) {
  statuses <- vapply(tests, `[[`, character(1), "status")
  if (all(statuses == "ok") && fresh$status == "ok") {
    return("Alle Langzeittests und die neue Verbindung erfolgreich. Abbruch hier nicht reproduziert.")
  }
  if (fresh$status == "ok") {
    return(paste(
      "Mindestens ein Langzeittest fehlgeschlagen, neue Verbindung erfolgreich.",
      "Fehlertexte unterscheiden Abfrage-Timeout und Verbindungsverlust; Swarm-Ursache nicht bewiesen."
    ))
  }
  "Auch die neue Verbindung fehlgeschlagen. Erreichbarkeit und DB-/Servicezustand zum Testzeitpunkt prüfen."
}

runDatabaseConnectionDiagnostics <- function(project_root, wait_seconds = 1020L) {
  report_dir <- file.path(project_root, "outputLocal", "database_connection_diagnostics")
  dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)
  report_file <- file.path(report_dir, paste0(
    "connection-diagnostic-", format(Sys.time(), "%Y%m%d-%H%M%S", tz = "UTC"), "-", Sys.getpid(), ".txt"
  ))
  report <- file(report_file, open = "wt", encoding = "UTF-8")
  on.exit(close(report), add = TRUE)
  config <- list()
  writeReport <- function(title, value = NULL) {
    lines <- c("", title, if (!is.null(value)) capture.output(print(value)))
    writeLines(redactDatabaseDiagnostic(lines, config), report)
    flush(report)
  }
  cat("Diagnosebericht:", report_file, "\n")
  writeReport("INTERPOLAR – Datenbank-Verbindungsdiagnose")
  writeReport("Beginn (UTC)", format(Sys.time(), tz = "UTC"))
  writeReport("R-Version", R.version.string)
  writeReport("Testvariante", "tcp_keepalives_idle = 600 Sekunden auf jeder Diagnoseverbindung (Sitzungseinstellung).")
  writeReport("Grenzen", c(
    "Test verwendet DB_NAME und Dataprocessor-Zugang aus der vorhandenen DB-Konfiguration.",
    "Snapshot-spezifische CLI-Verbindungsparameter werden nicht übernommen.",
    "Abweichende DB-/Rollen-Timeouts werden separat aufgeführt, nicht in allen Datenbanken getestet.",
    "DNS/Backend-Adressen allein beweisen keinen Swarm-VIP-Pfad; Docker-Verwaltungsdaten fehlen.",
    "Client-Kernelwerte sind keine Messung der Socketoptionen oder der Server-Kernelwerte.",
    "pg_sleep simuliert eine lange stille Abfrage, keine hohe Datenbanklast.",
    "Streaming verwendet getrennte Quell-/Zielverbindungen und synthetische Daten in einer TEMP-Zieltabelle.",
    "Snapshot-Verbindungshelfer mit tcp_keepalives_idle = 600 für diesen Test; Zeitgrenze im Überwachungsprozess.",
    "Bericht enthält interne Adressen, Rollen und DB-Namen; keine fachlichen Daten."
  ))
  tryCatch(
    {
      if (Sys.info()[["sysname"]] != "Linux") stop("Diagnose im Linux-R-Container ausführen.")
      config_path <- "./cds_hub_db_config.toml"
      module_path <- file.path(project_root, "R-dataprocessor", "dataprocessor_config.toml")
      if (file.exists(module_path)) {
        module_config <- etlutils::readTomlAsNamedList(module_path)
        if (!is.null(module_config$PATH_TO_DB_CONFIG_TOML)) config_path <- module_config$PATH_TO_DB_CONFIG_TOML
      }
      if (!grepl("^/", config_path)) config_path <- file.path(project_root, config_path)
      if (!file.exists(config_path)) stop("DB-Konfigurationsdatei nicht gefunden: ", config_path)
      config <- readSnapshotPseudonymizationDbConfig(list(path_to_db_config_toml = config_path))
      for (name in c("DB_DATAPROCESSOR_USER", "DB_DATAPROCESSOR_PASSWORD")) {
        if (is.null(config[[name]]) || !nzchar(config[[name]])) stop("Konfigurationswert fehlt: ", name)
      }
      metadata <- runDatabaseDiagnosticJobs(list(
        network = function() readDatabaseDiagnosticNetwork(config),
        database = function() readDatabaseDiagnosticSettings(config)
      ), timeout = 30)
      writeReport("Netzwerk", metadata$network)
      writeReport("Wirksame Sitzungseinstellungen und DB-/Rollen-Vorgaben", metadata$database)
      cat("Ruhetest, lange Abfrage und Snapshot-Streamingtest starten parallel. Dauer etwa 17–20 Minuten.\n")
      flush.console()
      writeReport("Langzeittests gestartet (UTC)", format(Sys.time(), tz = "UTC"))
      tests <- runDatabaseDiagnosticJobs(list(
        idle = function() testDatabaseDiagnosticConnection(config, "idle", wait_seconds),
        query = function() testDatabaseDiagnosticConnection(config, "query", wait_seconds),
        stream = function() testDatabaseDiagnosticConnection(config, "stream", wait_seconds)
      ), timeout = wait_seconds + 90)
      writeReport("Ruhetest – dieselbe Verbindung vor/nach der Pause", tests$idle)
      writeReport("Lange SQL-Abfrage – dieselbe Verbindung vor/nach pg_sleep", tests$query)
      writeReport("Snapshot-Streaming – Fetch/Write/Append mit Pause nach dem ersten Chunk", tests$stream)
      fresh <- runDatabaseDiagnosticJobs(list(
        fresh = function() testDatabaseDiagnosticConnection(config, "fresh", 0)
      ), timeout = 30)$fresh
      writeReport("Neue Verbindung nach den Langzeittests", fresh)
      summary <- summarizeDatabaseDiagnostic(tests, fresh)
      writeReport("Ergebnis", summary)
      writeReport("Ende (UTC)", format(Sys.time(), tz = "UTC"))
      cat(summary, "\nErgebnisdatei zum Zurücksenden:", report_file, "\n")
      invisible(report_file)
    },
    error = function(error) {
      writeReport("Diagnose konnte nicht vollständig ausgeführt werden", conditionMessage(error))
      cat("Diagnose unvollständig. Details und Ergebnisdatei:", report_file, "\n")
      invisible(report_file)
    }
  )
}
