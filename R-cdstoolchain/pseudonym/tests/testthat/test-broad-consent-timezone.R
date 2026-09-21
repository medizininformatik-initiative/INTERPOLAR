test_that("Consent dates keep the Berlin calendar through standard FHIR conversion", {
  rows <- broadConsentSnapshotFixtureTables()$consent
  days <- c("2026-01-01", "2026-03-29", "2026-07-01", "2026-10-25")
  rows <- rows[rep(1:2, 2), ]
  columns <- c("cons_provision_provision_period_start", "cons_provision_provision_period_end")
  rows <- data.table::as.data.table(rows)
  for (column in columns) data.table::set(rows, j = column, value = days)
  etlutils::convertDateTimeFormat(rows, columns)
  result <- readBroadConsentProvisions(as.data.frame(rows))
  expect_equal(result$start, as.Date(days))
  expect_equal(result$end, as.Date(days))
})

test_that("resource day boundaries use Berlin independently of the database timezone", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  original_timezone <- DBI::dbGetQuery(connection, "SHOW timezone")[[1]]
  on.exit(DBI::dbExecute(connection, paste0("SET TIME ZONE ", DBI::dbQuoteString(connection, original_timezone))))
  interval_table <- basename(tempfile("bc_timezone_"))
  on.exit(DBI::dbRemoveTable(connection, interval_table), add = TRUE)
  spec <- list(date_path = "effective", point = "point", start = "start", end = "end")
  predicate <- buildBroadConsentDatePredicate(connection, spec, DBI::dbQuoteIdentifier(connection, interval_table))
  for (day in c("2026-01-01", "2026-03-29", "2026-07-01", "2026-10-25")) {
    DBI::dbWriteTable(connection, interval_table,
      data.frame(patient_id = "p", start = as.Date(day), end = as.Date(day)),
      temporary = TRUE, overwrite = TRUE
    )
    first <- as.POSIXct(paste(day, "00:00:00"), tz = "Europe/Berlin")
    next_day <- as.POSIXct(paste(as.Date(day) + 1, "00:00:00"), tz = "Europe/Berlin")
    times <- c(first - 1, first, next_day - 1, next_day)
    for (storage_type in c("TIMESTAMP", "TIMESTAMPTZ")) {
      timestamps <- paste0(storage_type, " '", format(
        times,
        tz = if (storage_type == "TIMESTAMP") "Europe/Berlin" else "UTC",
        format = if (storage_type == "TIMESTAMP") "%Y-%m-%d %H:%M:%S" else "%Y-%m-%d %H:%M:%S+00"
      ), "'")
      for (timezone in c("UTC", "America/Los_Angeles", "Europe/Berlin")) {
        DBI::dbExecute(connection, paste0("SET TIME ZONE ", DBI::dbQuoteString(connection, timezone)))
        for (period in c(FALSE, TRUE)) {
          values <- if (period) {
            paste0("('p', NULL::timestamptz, ", timestamps, ", ", timestamps, ")")
          } else {
            paste0("('p', ", timestamps, ", NULL::timestamptz, NULL::timestamptz)")
          }
          result <- DBI::dbGetQuery(connection, paste0(
            "SELECT ", predicate$covered, " AS covered FROM (VALUES ", paste(values, collapse = ","),
            ') AS s(bc_patient_id, point, start, "end")'
          ))
          expect_identical(result$covered, c(FALSE, TRUE, TRUE, FALSE), info = paste(day, timezone, period, storage_type))
        }
      }
    }
  }
})
