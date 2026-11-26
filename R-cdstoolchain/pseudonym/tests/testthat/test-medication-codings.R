test_that("direct medication codings are planned without reference dependencies", {
  for (i in seq_len(nrow(SNAPSHOT_MEDICATION_REFERENCE_SPECS))) {
    spec <- SNAPSHOT_MEDICATION_REFERENCE_SPECS[i, ]
    fields <- c("row_id", spec$direct_system_column, spec$direct_code_column)
    testthat::local_mocked_bindings(
      snapshotRelationFields = function(connection, name, schema = NULL) fields
    )
    for (relation_type in c("all", "last_version")) {
      plan <- data.table::data.table(
        BASE_TABLE_NAME = spec$table_name,
        SOURCE_RELATION = paste0("v_", spec$table_name, "_", relation_type),
        SNAPSHOT_RELATION_TYPE = relation_type
      )
      result <- getSnapshotStreamingSourceQuery(
        DBI::ANSI(), plan, NULL, "v_", "_last_version",
        c(fields, spec$system_column, spec$code_column)
      )
      expect_match(result$query, spec$direct_system_column, fixed = TRUE)
      expect_match(result$query, spec$direct_code_column, fixed = TRUE)
      expect_match(result$query, paste0('END AS "', spec$code_column, '"'), fixed = TRUE)
      expect_false(grepl("LEFT JOIN", result$query, fixed = TRUE))
      expect_equal(result$medication_spec, spec)
    }
  }
})

test_that("PostgreSQL enriches direct and referenced medication coding pairs", {
  # Use standard libpq connection variables for an isolated test database.
  skip_if(Sys.getenv("PGHOST") == "", "Set PGHOST to run PostgreSQL regression tests")
  skip_if_not_installed("RPostgres")
  connection <- DBI::dbConnect(RPostgres::Postgres())
  on.exit(DBI::dbDisconnect(connection), add = TRUE)
  specs <- SNAPSHOT_MEDICATION_REFERENCE_SPECS
  plans <- list()
  rules <- list()
  for (i in seq_len(nrow(specs))) {
    spec <- specs[i, ]
    source <- data.frame(
      row_id = 1:7,
      resource_id = c("direct", "direct", "reference", "ingredient", "missing-system", "missing-code", "empty"),
      reference = c(NA, NA, "Medication/leaf", "Medication/root", NA, NA, NA),
      system = c("atc", "snomed", NA, NA, NA, "atc", ""),
      code = c("P01BC01", "12345", NA, NA, "M04AA01", NA, "")
    )
    names(source)[3:5] <- c(spec$reference_column, spec$direct_system_column, spec$direct_code_column)
    for (relation_type in c("all", "last_version")) {
      relation <- paste0("v_", spec$table_name, if (relation_type == "last_version") "_last_version")
      DBI::dbWriteTable(connection, relation, source, temporary = TRUE)
      plans[[length(plans) + 1L]] <- data.table::data.table(
        BASE_TABLE_NAME = spec$table_name, RULE_TABLE_NAME = spec$table_name,
        RULE_SOURCE = NA_character_, SOURCE_RELATION = relation,
        SNAPSHOT_RELATION_TYPE = relation_type
      )
    }
    rules[[i]] <- data.table::data.table(
      TABLE_OR_RESOURCE = spec$table_name, SOURCE = NA_character_,
      COLUMN_NAME = c(names(source), spec$system_column, spec$code_column),
      PSEUDONYMIZATION_RULE = "keep"
    )
  }
  plan <- data.table::rbindlist(plans)
  rules <- data.table::rbindlist(rules)
  medication <- data.frame(
    med_id = c("root", "leaf", "leaf"),
    med_code_system = c(NA, "atc", "snomed"),
    med_code_code = c(NA, "N06AA09", "67890"),
    med_ingredient_itemreference_ref = c("Medication/leaf", NA, NA)
  )
  for (suffix in c("", "_last_version")) {
    version_medication <- medication
    if (suffix == "_last_version") {
      version_medication$med_code_code[2] <- "N06AA10"
    }
    DBI::dbWriteTable(connection, paste0("v_medication", suffix), version_medication, temporary = TRUE)
  }
  resolutions <- prepareSnapshotMedicationResolutionTables(connection, plan, rules, NULL, "v_", "_last_version")
  expect_setequal(names(resolutions), c("all", "last_version"))
  for (i in seq_len(nrow(plan))) {
    spec <- getMedicationReferenceSpec(plan$BASE_TABLE_NAME[i])
    described <- rules$COLUMN_NAME[rules$TABLE_OR_RESOURCE == spec$table_name]
    query <- getSnapshotStreamingSourceQuery(
      connection, plan[i, ], NULL, "v_", "_last_version", described, resolutions
    )$query
    result <- DBI::dbGetQuery(connection, paste0(query, " ORDER BY row_id, ", spec$system_column))
    expect_equal(result$row_id, c(1L, 2L, 3L, 3L, 4L, 4L, 5L, 6L, 7L))
    reference_code <- if (plan$SNAPSHOT_RELATION_TYPE[i] == "last_version") "N06AA10" else "N06AA09"
    expect_equal(result[[spec$code_column]], c("P01BC01", "12345", reference_code, "67890", reference_code, "67890", "M04AA01", NA, NA))
    expect_equal(result[[spec$system_column]], c("atc", "snomed", "atc", "snomed", "atc", "snomed", NA, "atc", NA))
    expect_equal(nrow(getUnmatchedMedicationReferencesFromEnrichedTable(result, spec$table_name, spec)), 0L)

    # Missing Medication tables or individual optional source columns retain direct values.
    fields <- DBI::dbListFields(connection, plan$SOURCE_RELATION[i])
    for (omitted in c("", spec$reference_column, spec$direct_system_column, spec$direct_code_column)) {
      available <- setdiff(fields, omitted)
      relation <- paste0(
        "(SELECT ", paste(DBI::dbQuoteIdentifier(connection, available), collapse = ", "),
        " FROM ", DBI::dbQuoteIdentifier(connection, plan$SOURCE_RELATION[i]), ")"
      )
      query <- buildSnapshotMedicationSourceQuery(connection, relation, available, NULL, spec)
      direct <- DBI::dbGetQuery(connection, paste0(query, " ORDER BY row_id"))
      expect_equal(nrow(direct), 7L)
      expect_equal(direct[[spec$code_column]][1:2], if (omitted == spec$direct_code_column) c(NA_character_, NA_character_) else c("P01BC01", "12345"))
      expect_equal(direct[[spec$system_column]][1:2], if (omitted == spec$direct_system_column) c(NA_character_, NA_character_) else c("atc", "snomed"))
    }
  }
})
