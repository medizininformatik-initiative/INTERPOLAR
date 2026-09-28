test_that("last-version comments only target generated views in raw and typed schemas", {
  tables <- list(
    patient = data.table::data.table(
      TABLE_NAME = "patient",
      COLUMN_NAME = c("pat_id", "pat_meta_lastupdated"),
      COLUMN_DESCRIPTION = c("id", "meta/lastUpdated"),
      COLUMN_TYPE = c("varchar", "timestamp")
    ),
    pids_per_ward = data.table::data.table(
      TABLE_NAME = "pids_per_ward",
      COLUMN_NAME = c("ward_name", "patient_id", "encounter_id"),
      COLUMN_DESCRIPTION = c("ward_name", "patient_id", "encounter_id"),
      COLUMN_TYPE = "varchar"
    )
  )

  for (schema in c("cds2db_out", "db2dataprocessor_out")) {
    for (raw in c(TRUE, FALSE)) {
      rights <- data.table::data.table(
        OWNER_SCHEMA = schema,
        OWNER_USER = "test_user",
        TAGS = if (raw) "RAW" else "TYPED",
        TABLE_PREFIX = "v_",
        TABLE_POSTFIX = if (raw) "_raw_last_version" else "_last_version",
        SCHEMA_2 = "db_log",
        TABLE_POSTFIX_2 = if (raw) "_raw" else "",
        RIGHTS = "SELECT",
        GRANT_TARGET_USER = "test_user"
      )
      sql <- convertTemplate(
        tables, rights,
        template_name = "template_cre_view_last_version",
        recursion = 1
      )
      created <- regmatches(sql, gregexpr("CREATE VIEW [a-z0-9_.]+", sql))[[1]]
      created <- sub("CREATE VIEW ", "", created, fixed = TRUE)
      comments <- regmatches(sql, gregexpr("COMMENT ON COLUMN [a-z0-9_.]+", sql))[[1]]
      targets <- sub("\\.[^.]+$", "", sub("COMMENT ON COLUMN ", "", comments, fixed = TRUE))
      expect_length(created, 1L)
      expect_length(comments, 2L)
      expect_true(all(targets %in% created))
      expect_false(any(grepl("pids_per_ward", targets, fixed = TRUE)))
      expect_match(sql, if (raw) "meta/lastUpdated (varchar)" else "meta/lastUpdated (timestamp)", fixed = TRUE)
      expect_false(grepl("<%", sql, fixed = TRUE))
    }
  }
})
