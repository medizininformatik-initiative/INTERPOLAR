test_that("masking distinguishes excluded current and explicitly referenced historical versions", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  targets <- basename(tempfile("bc_targets_"))
  sources <- basename(tempfile("bc_references_"))
  on.exit(DBI::dbRemoveTable(connection, targets), add = TRUE)
  on.exit(DBI::dbRemoveTable(connection, sources), add = TRUE)
  DBI::dbWriteTable(connection, targets, data.frame(
    resource_type = "Encounter", resource_id = "e",
    version_id = c("1", "2"), retained = c(TRUE, FALSE), is_current = c(FALSE, TRUE)
  ), temporary = TRUE)
  values <- c(
    NA, "invalid", "Encounter/absent", "Encounter/e", "e", "[1]Encounter/e",
    "Encounter/e/_history/1", "Encounter/e/_history/2", "Encounter/e/_history/2/invalid"
  )
  DBI::dbWriteTable(connection, sources, data.frame(row = seq_along(values), obs_encounter_ref = values), temporary = TRUE)
  predicate <- buildBroadConsentReferenceMaskPredicate(
    connection, "obs_encounter_ref", "Observation",
    snapshotQualifiedName(connection, targets)
  )
  masked <- DBI::dbGetQuery(connection, paste0(
    "SELECT ", predicate, " AS masked FROM ",
    snapshotQualifiedName(connection, sources), " s ORDER BY s.row"
  ))$masked
  expect_equal(which(masked %in% TRUE), c(4L, 5L, 6L, 8L))
  expect_equal(DBI::dbReadTable(connection, sources)$obs_encounter_ref, values)
})

test_that("calculated hierarchy references use the same target types", {
  expect_equal(getBroadConsentReferenceType("enc_main_encounter_calculated_ref", "Encounter"), "Encounter")
  expect_equal(getBroadConsentReferenceType("enc_partof_calculated_ref", "Encounter"), "Encounter")
  expect_equal(getBroadConsentReferenceType("enc_diagnosis_condition_calculated_ref", "Encounter"), "Condition")
  expect_equal(getBroadConsentReferenceType("obs_encounter_calculated_ref", "Observation"), "Encounter")
})

test_that("reference catalog resolves flattened current rows with bounded query memory", {
  connection <- getOption("interpolar.test.postgres_connection")
  skip_if(is.null(connection), "An isolated PostgreSQL test connection was not supplied.")
  decisions <- basename(tempfile("bc_decisions_"))
  current <- basename(tempfile("bc_current_"))
  on.exit(DBI::dbRemoveTable(connection, decisions), add = TRUE)
  on.exit(DBI::dbRemoveTable(connection, current), add = TRUE)
  # Each resource has one historical row and two flattened current rows.
  ids <- seq_len(30000L)
  resources <- (ids + 2L) %/% 3L
  DBI::dbWriteTable(connection, decisions, data.frame(
    row_id = as.character(ids), resource_id = paste0("obs", resources),
    version_id = ifelse(ids %% 3L == 1L, "1", "2"),
    reason = ifelse(resources %% 2L == 0L, "included", "outside_consent_period")
  ), temporary = TRUE)
  current_ids <- ids[ids %% 3L != 1L]
  DBI::dbWriteTable(connection, current, data.frame(
    observation_id = c(current_ids, current_ids)
  ), temporary = TRUE)
  for (table in c(decisions, current)) {
    DBI::dbExecute(connection, paste("ANALYZE", snapshotQualifiedName(connection, table)))
  }
  old_memory <- DBI::dbGetQuery(connection, "SHOW work_mem")[[1L]]
  old_timeout <- DBI::dbGetQuery(connection, "SHOW statement_timeout")[[1L]]
  on.exit(DBI::dbExecute(connection, paste("SET work_mem TO", DBI::dbQuoteString(connection, old_memory))), add = TRUE)
  on.exit(DBI::dbExecute(connection, paste("SET statement_timeout TO", DBI::dbQuoteString(connection, old_timeout))), add = TRUE)
  # Reproduce the large-input planner boundary without millions of test rows.
  # A spilling join remains bounded; a repeated full scan exceeds this guard.
  DBI::dbExecute(connection, "SET work_mem TO '64kB'")
  DBI::dbExecute(connection, "SET statement_timeout TO '10s'")
  selections <- list(observation = list(
    spec = list(resource = "Observation"), row_column = "observation_id", table_name = decisions
  ))
  plan <- data.frame(
    BASE_TABLE_NAME = "observation", SNAPSHOT_RELATION_TYPE = SNAPSHOT_RELATION_TYPE_LAST,
    SOURCE_RELATION = current
  )
  targets <- prepareBroadConsentReferenceTargets(connection, selections, plan, "pg_temp")
  on.exit(DBI::dbRemoveTable(connection, targets), add = TRUE)
  actual <- DBI::dbReadTable(connection, targets)
  expect_equal(nrow(actual), 20000L)
  expect_equal(sum(actual$is_current), 10000L)
  expect_true(all(actual$is_current == (actual$version_id == "2")))
  expect_true(all(actual$retained == (as.integer(sub("obs", "", actual$resource_id)) %% 2L == 0L)))
  expect_equal(unique(actual$resource_type), "Observation")
  # Relations without a separate current-version view retain the existing default.
  fallback <- prepareBroadConsentReferenceTargets(connection, selections, plan[0, ], "pg_temp")
  on.exit(DBI::dbRemoveTable(connection, fallback), add = TRUE)
  expect_true(all(DBI::dbReadTable(connection, fallback)$is_current))
})
