test_that("frontend partitions preserve contents, duplicates and NULLs despite reused IDs", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  schema <- basename(tempfile("fe_history_"))
  snapshotEnsureSchema(connection, schema)
  on.exit(DBI::dbExecute(connection, paste0("DROP SCHEMA ", DBI::dbQuoteIdentifier(connection, schema), " CASCADE")), add = TRUE)
  bases <- c(
    "patient_fe", "fall_fe", "medikationsanalyse_fe", "mrpdokumentation_validierung_fe",
    "retrolektive_mrpbewertung_fe", "risikofaktor_fe", "trigger_fe"
  )
  for (base in bases) {
    rows <- data.frame(
      id = c(42L, 42L, 42L, 42L, 43L), record_id = c(rep("r1", 4), "r2"),
      last_processing_nr = c(10L, 10L, 20L, 20L, 20L), choice = c(NA, NA, 0L, 1L, 1L)
    )
    names(rows)[1L] <- paste0(base, "_id")
    DBI::dbWriteTable(connection, DBI::Id(schema = schema, table = base), rows)
    relation <- snapshotQualifiedName(connection, base, schema)
    for (suffix in c("", "_last_version")) {
      DBI::dbExecute(connection, paste0(
        "CREATE VIEW ", snapshotQualifiedName(connection, paste0("v_", base, suffix), schema),
        " AS SELECT * FROM ", relation, if (nzchar(suffix)) " WHERE last_processing_nr = 20" else ""
      ))
    }
    plan <- data.table::data.table(
      BASE_TABLE_NAME = base,
      SOURCE_RELATION = paste0("v_", base, c("", "_last_version")),
      SNAPSHOT_RELATION_TYPE = c("old_versions", "last_version")
    )
    keys <- prepareSnapshotVersionKeyTables(connection, plan, schema)
    old <- getSnapshotPartitionSource(connection, plan[1, ], schema, "v_", keys)
    last <- getSnapshotPartitionSource(connection, plan[2, ], schema, "v_", keys)
    old_rows <- DBI::dbGetQuery(connection, paste0("SELECT * FROM ", old$relation, " s"))
    last_rows <- DBI::dbGetQuery(connection, paste0("SELECT * FROM ", last$relation, " s"))
    expect_equal(nrow(old_rows), 2L, info = base)
    expect_true(all(is.na(old_rows$choice)), info = base)
    expect_equal(nrow(last_rows), 3L, info = base)
    expect_equal(sort(last_rows$choice), c(0L, 1L, 1L), info = base)
    difference <- DBI::dbGetQuery(connection, paste0(
      "SELECT COUNT(*) AS n FROM ((SELECT * FROM ", relation,
      " EXCEPT ALL (SELECT * FROM ", old$relation, " o UNION ALL SELECT * FROM ", last$relation, " l))",
      " UNION ALL ((SELECT * FROM ", old$relation, " o UNION ALL SELECT * FROM ", last$relation,
      " l) EXCEPT ALL SELECT * FROM ", relation, ")) differences"
    ))
    expect_equal(as.numeric(difference$n), 0, info = base)
    dropSnapshotVersionKeyTables(connection, keys)
  }
})
