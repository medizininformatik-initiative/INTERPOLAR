test_that("database quality analysis metadata is normalized from view columns", {
  config <- list(
    view_prefix = "v_",
    view_postfix = "_last_version",
    included_view_patterns = c("^v_[a-z0-9_]+_last_version$"),
    excluded_view_patterns = "_raw_",
    additional_views = "v_pids_per_ward",
    technical_columns = c("input_datetime", "last_version_date", "id"),
    grouping_overrides = parseGroupingOverrides(character()),
    count_batch_size = 100
  )

  metadata <- data.table::data.table(
    table_schema = "db2dataprocessor_out",
    view_name = c(
      "v_observation_last_version",
      "v_observation_last_version",
      "v_observation_last_version",
      "v_observation_last_version",
      "v_observation_last_version",
      "v_observation_last_version",
      "v_observation_raw_last_version",
      "v_pids_per_ward",
      "v_not_relevant"
    ),
    column_name = c(
      "observation_id",
      "observation_raw_id",
      "obs_id",
      "input_datetime",
      "last_version_date",
      "id",
      "obs_id",
      "patient_id",
      "ignored"
    ),
    ordinal_position = 1:9,
    data_type = "text",
    column_description = c("primary", "raw", "id (varchar)", "technical", "technical", "technical", "raw", "", "")
  )

  result <- normalizeMetadata(metadata, config)

  expect_equal(result$TABLE_NAME, c("observation", "pids_per_ward"))
  expect_equal(result$TABLE_FAMILY, c("FHIR", "Other"))
  expect_equal(result$COLUMN_NAME, c("obs_id", "patient_id"))
  expect_equal(result$COLUMN_DESCRIPTION[[1]], "id")
})

test_that("database quality analysis column descriptions remove only trailing type suffixes", {
  result <- normalizeColumnDescription(c(
    "Observation.component (FHIR) (varchar)",
    "effectiveDateTime (timestamp)",
    "value (double precision)",
    "",
    NA_character_
  ))

  expect_equal(result, c(
    "Observation.component (FHIR)",
    "effectiveDateTime",
    "value",
    "",
    NA_character_
  ))
})

test_that("database quality analysis grouping overrides are parsed", {
  result <- parseGroupingOverrides(c(
    "patient_fe|pat_id|record_id|",
    "fall_fe|fall_id|record_id|fall_id"
  ))

  expect_equal(result$TABLE_NAME, c("patient_fe", "fall_fe"))
  expect_equal(result$resource_id, c("pat_id", "fall_id"))
  expect_equal(result$pid, c("record_id", "record_id"))
  expect_true(is.na(result[TABLE_NAME == "patient_fe", case_id]))
  expect_equal(result[TABLE_NAME == "fall_fe", case_id], "fall_id")
})

test_that("database quality analysis config can skip datetime columns by command-line flags", {
  envir <- new.env(parent = emptyenv())
  assign("INCLUDE_VALUE_DATETIME_COLUMNS", TRUE, envir = envir)
  command_arguments <- list(
    c("database-quality-analysis", "--skip-value-datetime-columns"),
    c("database-quality-analysis", "-s"),
    c("database-quality-analysis", "skip-value-datetime-columns"),
    c("database-quality-analysis", "skipValueDatetimeColumns")
  )

  results <- lapply(command_arguments, function(arguments) {
    getConfig(envir = envir, command_arguments = arguments)
  })

  expect_true(all(vapply(results, function(result) {
    isFALSE(result$include_value_datetime_columns)
  }, logical(1))))
})

test_that("database quality analysis grouping columns are inferred by convention", {
  config <- list(grouping_overrides = parseGroupingOverrides(character()))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "observation",
    COLUMN_NAME = c(
      "obs_id",
      "obs_patient_ref",
      "obs_encounter_ref",
      "obs_value"
    )
  )

  result <- inferGroupingColumns(table_metadata, config)

  expect_equal(result[["resource_id"]], "obs_id")
  expect_equal(result[["pid"]], "obs_patient_ref")
  expect_equal(result[["case_id"]], "obs_encounter_ref")
})

test_that("database quality analysis grouping columns use override for FHIR patient", {
  config <- list(grouping_overrides = parseGroupingOverrides("patient|pat_id|pat_id|"))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "patient",
    COLUMN_NAME = c(
      "pat_id",
      "pat_birthdate"
    )
  )

  result <- inferGroupingColumns(table_metadata, config)

  expect_equal(result[["resource_id"]], "pat_id")
  expect_equal(result[["pid"]], "pat_id")
  expect_true(is.na(result[["case_id"]]))
})

test_that("database quality analysis grouping columns allow FHIR tables without PID", {
  config <- list(grouping_overrides = parseGroupingOverrides(character()))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "location",
    COLUMN_NAME = c(
      "loc_id",
      "loc_name"
    )
  )

  result <- inferGroupingColumns(table_metadata, config)

  expect_equal(result[["resource_id"]], "loc_id")
  expect_true(is.na(result[["pid"]]))
  expect_true(is.na(result[["case_id"]]))
})

test_that("database quality analysis grouping columns infer frontend IDs by convention", {
  config <- list(grouping_overrides = parseGroupingOverrides(character()))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "mrpdokumentation_validierung_fe",
    COLUMN_NAME = c(
      "record_id",
      "mrp_id",
      "mrp_score"
    )
  )

  result <- inferGroupingColumns(table_metadata, config)

  expect_equal(result[["resource_id"]], "mrp_id")
  expect_equal(result[["pid"]], "record_id")
  expect_true(is.na(result[["case_id"]]))
})

test_that("database quality analysis grouping columns use override for frontend case IDs", {
  config <- list(grouping_overrides = parseGroupingOverrides("fall_fe|fall_id|record_id|fall_id"))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "fall_fe",
    COLUMN_NAME = c(
      "record_id",
      "fall_id",
      "fall_status"
    )
  )

  result <- inferGroupingColumns(table_metadata, config)

  expect_equal(result[["resource_id"]], "fall_id")
  expect_equal(result[["pid"]], "record_id")
  expect_equal(result[["case_id"]], "fall_id")
})

test_that("database quality analysis grouping columns add encounter hierarchy counts", {
  config <- list(grouping_overrides = parseGroupingOverrides(character()))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "encounter",
    COLUMN_NAME = c(
      "enc_id",
      "enc_patient_ref",
      "enc_main_encounter_calculated_ref",
      "enc_type_system",
      "enc_type_code",
      "enc_class_system",
      "enc_class_code",
      "enc_status"
    )
  )

  result <- inferGroupingColumns(table_metadata, config)

  expect_equal(result[["resource_id"]], "enc_id")
  expect_equal(result[["pid"]], "enc_patient_ref")
  expect_equal(result[["case_id"]], "enc_main_encounter_calculated_ref")
  expect_equal(result[["encounter_einrichtungskontakt"]], "enc_id")
  expect_equal(result[["encounter_abteilungskontakt"]], "enc_id")
  expect_equal(result[["encounter_versorgungsstellenkontakt"]], "enc_id")
  expect_equal(result[["encounter_einrichtungskontakt_amb"]], "enc_id")
  expect_equal(result[["encounter_versorgungsstellenkontakt_other"]], "enc_id")

  report_rows <- data.table::data.table(
    COLUMN_NAME = c("enc_id", "enc_type_system", "enc_type_code", "enc_class_system", "enc_class_code", "enc_status")
  )
  report_rows <- addGroupingRoles(report_rows, result)
  expect_match(
    report_rows[COLUMN_NAME == "enc_id", USED_AS_GROUPING_FOR],
    "count per Einrichtungskontakt",
    fixed = TRUE
  )
  expect_match(
    report_rows[COLUMN_NAME == "enc_type_system", USED_AS_GROUPING_FOR],
    "count per Abteilungskontakt",
    fixed = TRUE
  )
  expect_match(
    report_rows[COLUMN_NAME == "enc_type_code", USED_AS_GROUPING_FOR],
    "count per Versorgungsstellenkontakt",
    fixed = TRUE
  )
  expect_match(
    report_rows[COLUMN_NAME == "enc_class_system", USED_AS_GROUPING_FOR],
    "count per Einrichtungskontakt class AMB",
    fixed = TRUE
  )
  expect_match(
    report_rows[COLUMN_NAME == "enc_class_code", USED_AS_GROUPING_FOR],
    "count per Einrichtungskontakt class AMB",
    fixed = TRUE
  )
})

test_that("database quality analysis grouping columns infer frontend patient IDs by convention", {
  config <- list(grouping_overrides = parseGroupingOverrides(character()))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "patient_fe",
    COLUMN_NAME = c(
      "record_id",
      "pat_id",
      "pat_birth_date"
    )
  )

  result <- inferGroupingColumns(table_metadata, config)

  expect_equal(result[["resource_id"]], "pat_id")
  expect_equal(result[["pid"]], "record_id")
  expect_true(is.na(result[["case_id"]]))
})

test_that("database quality analysis grouping columns require frontend PID convention", {
  config <- list(grouping_overrides = parseGroupingOverrides(character()))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "patient_fe",
    COLUMN_NAME = c(
      "pat_id",
      "pat_birth_date"
    )
  )

  expect_error(
    inferGroupingColumns(table_metadata, config),
    "Could not infer pid grouping column for table patient_fe"
  )
})

test_that("database quality analysis grouping columns validate override columns", {
  config <- list(grouping_overrides = parseGroupingOverrides("patient_fe|missing_id|record_id|"))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "patient_fe",
    COLUMN_NAME = c(
      "record_id",
      "pat_id"
    )
  )

  expect_error(
    inferGroupingColumns(table_metadata, config),
    "Configured grouping column 'missing_id' for resource_id does not exist in table patient_fe"
  )
})

test_that("database quality analysis count query uses non-empty values and quoted identifiers", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    COLUMN_NAME = c("obs_id", "obs_patient_ref", "obs_value"),
    DATA_TYPE = c("character varying", "character varying", "character varying")
  )
  grouping_columns <- c(resource_id = "obs_id", pid = "obs_patient_ref", case_id = NA_character_)

  result <- buildCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("obs_value")
  )

  expect_match(result$query, '"obs_value" IS NOT NULL', fixed = TRUE)
  expect_match(result$query, '"obs_value"::text <> \'\'', fixed = TRUE)
  expect_match(result$query, 'FROM "db2dataprocessor_out"."v_observation_last_version"', fixed = TRUE)
  expect_equal(result$alias_map$count_column, c("count per resource_id", "count per PID"))
})

test_that("database quality analysis count query ignores invalid calculated refs", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    COLUMN_NAME = c("obs_id", "obs_patient_ref", "obs_encounter_calculated_ref"),
    DATA_TYPE = c("character varying", "character varying", "character varying")
  )
  grouping_columns <- c(resource_id = "obs_id", pid = "obs_patient_ref", case_id = NA_character_)

  result <- buildCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("obs_encounter_calculated_ref")
  )

  expect_match(result$query, '"obs_encounter_calculated_ref" IS NOT NULL', fixed = TRUE)
  expect_match(result$query, '"obs_encounter_calculated_ref"::text <> \'\'', fixed = TRUE)
  expect_match(result$query, '"obs_encounter_calculated_ref"::text <> \'invalid\'', fixed = TRUE)
})

test_that("database quality analysis count query avoids text casts for non-text columns", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    COLUMN_NAME = c("obs_id", "obs_value_quantity", "obs_effective_datetime"),
    DATA_TYPE = c("character varying", "double precision", "timestamp without time zone")
  )
  grouping_columns <- c(resource_id = "obs_id", pid = NA_character_, case_id = NA_character_)

  result <- buildCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("obs_value_quantity", "obs_effective_datetime")
  )

  expect_match(result$query, '"obs_value_quantity" IS NOT NULL', fixed = TRUE)
  expect_match(result$query, '"obs_effective_datetime" IS NOT NULL', fixed = TRUE)
  expect_false(grepl('"obs_value_quantity"::text', result$query, fixed = TRUE))
  expect_false(grepl('"obs_effective_datetime"::text', result$query, fixed = TRUE))
  expect_match(result$query, '"obs_id"::text <> \'\'', fixed = TRUE)
})

test_that("database quality analysis count query filters encounter hierarchy counts", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_encounter_last_version",
    TABLE_NAME = "encounter",
    COLUMN_NAME = c(
      "enc_id",
      "enc_patient_ref",
      "enc_main_encounter_calculated_ref",
      "enc_type_system",
      "enc_type_code",
      "enc_class_system",
      "enc_class_code",
      "enc_status"
    ),
    DATA_TYPE = "character varying"
  )
  encounter_grouping_columns <- stats::setNames(
    rep("enc_id", length(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS)),
    names(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS)
  )
  grouping_columns <- c(
    resource_id = "enc_id",
    pid = "enc_patient_ref",
    case_id = "enc_main_encounter_calculated_ref",
    encounter_grouping_columns
  )

  result <- buildCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("enc_status")
  )

  expect_match(result$query, '"enc_type_system" = \'http://fhir.de/CodeSystem/Kontaktebene\'', fixed = TRUE)
  expect_match(result$query, '"enc_type_code" = \'einrichtungskontakt\'', fixed = TRUE)
  expect_match(result$query, '"enc_type_code" = \'abteilungskontakt\'', fixed = TRUE)
  expect_match(result$query, '"enc_type_code" = \'versorgungsstellenkontakt\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_system" = \'http://terminology.hl7.org/CodeSystem/v3-ActCode\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" = \'AMB\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" = \'IMP\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" = \'SS\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" IS NOT NULL', fixed = TRUE)
  expect_match(result$query, '"enc_class_code"::text <> \'\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" NOT IN (\'AMB\', \'IMP\', \'SS\')', fixed = TRUE)
  expect_equal(result$alias_map$count_column, c(
    unname(DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS),
    unname(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS)
  ))
})

test_that("database quality analysis count query treats configured frontend checkboxes as checked groups", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_mrpdokumentation_validierung_fe_last_version",
    TABLE_NAME = "mrpdokumentation_validierung_fe",
    COLUMN_NAME = c(
      "mrp_id",
      "record_id",
      "mrp_pigrund___1",
      "mrp_pigrund___2",
      "mrp_pigrund___3"
    ),
    DATA_TYPE = "character varying"
  )
  grouping_columns <- c(resource_id = "mrp_id", pid = "record_id", case_id = NA_character_)

  result <- buildCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("mrp_pigrund___1")
  )

  expect_match(result$query, '"mrp_pigrund___1" = \'Checked\'', fixed = TRUE)
  expect_match(result$query, '"mrp_pigrund___2" = \'Checked\'', fixed = TRUE)
  expect_match(result$query, '"mrp_pigrund___3" = \'Checked\'', fixed = TRUE)
  expect_false(grepl('"mrp_pigrund___1"::text <> \'\'', result$query, fixed = TRUE))
})

test_that("database quality analysis counts are mapped back to normalized result rows", {
  config <- list(
    count_batch_size = 100,
    grouping_overrides = parseGroupingOverrides(character()),
    view_prefix = "v_",
    value_import_datetime_column = "input_datetime",
    include_value_datetime_columns = TRUE
  )
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    TABLE_NAME = "observation",
    TABLE_FAMILY = "FHIR",
    COLUMN_NAME = c("obs_id", "obs_patient_ref", "obs_value"),
    COLUMN_DESCRIPTION = c("id", "patient", "value"),
    ORDINAL_POSITION = 1:3
  )
  query_fun <- function(query, lock_id = NULL) {
    aliases <- unique(regmatches(query, gregexpr("count_[0-9]+", query))[[1]])
    data.table::as.data.table(as.list(stats::setNames(seq_along(aliases), aliases)))
  }

  result <- calculateCounts(metadata, config, query_fun = query_fun)

  expect_equal(names(result)[1:11], c(
    "TABLE_NAME",
    "COLUMN_NAME",
    "COLUMN_DESCRIPTION",
    "USED_AS_GROUPING_FOR",
    "count per resource_id",
    "count per PID",
    "count per Fall-Id",
    "first value import datetime",
    "last value import datetime",
    "first value meta last updated",
    "last value meta last updated"
  ))
  expect_equal(names(result)[12:26], unname(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS))
  expect_equal(result[COLUMN_NAME == "obs_id", USED_AS_GROUPING_FOR], "count per resource_id")
  expect_equal(result[COLUMN_NAME == "obs_patient_ref", USED_AS_GROUPING_FOR], "count per PID")
  expect_true(all(is.na(result[["count per Fall-Id"]])))
  expect_equal(result[COLUMN_NAME == "obs_value", "count per resource_id"][[1]], 5L)
})

test_that("database quality analysis counts can skip value datetime columns", {
  config <- list(
    count_batch_size = 100,
    grouping_overrides = parseGroupingOverrides(character()),
    view_prefix = "v_",
    value_import_datetime_column = "input_datetime",
    include_value_datetime_columns = FALSE
  )
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    TABLE_NAME = "observation",
    TABLE_FAMILY = "FHIR",
    COLUMN_NAME = c("obs_id", "obs_patient_ref", "obs_value"),
    COLUMN_DESCRIPTION = c("id", "patient", "value"),
    ORDINAL_POSITION = 1:3
  )
  history_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation",
    COLUMN_NAME = c("obs_id", "obs_patient_ref", "obs_value", "input_datetime"),
    DATA_TYPE = "character varying"
  )
  query_fun <- function(query, lock_id = NULL) {
    expect_false(grepl('FROM "db2dataprocessor_out"."v_observation"', query, fixed = TRUE))
    aliases <- unique(regmatches(query, gregexpr("count_[0-9]+", query))[[1]])
    data.table::as.data.table(as.list(stats::setNames(seq_along(aliases), aliases)))
  }

  result <- calculateCounts(
    metadata,
    config,
    query_fun = query_fun,
    history_metadata = history_metadata
  )

  expect_false(any(DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS %in% names(result)))
  expect_equal(result[COLUMN_NAME == "obs_value", "count per resource_id"][[1]], 5L)
})

test_that("database quality analysis date range query uses historical views without suffix", {
  config <- list(
    view_prefix = "v_",
    value_import_datetime_column = "input_datetime"
  )
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    TABLE_NAME = "observation",
    TABLE_FAMILY = "FHIR",
    COLUMN_NAME = c("obs_id", "obs_value_quantity"),
    DATA_TYPE = c("character varying", "double precision")
  )
  history_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation",
    COLUMN_NAME = c("obs_id", "obs_value_quantity", "input_datetime", "obs_meta_lastupdated"),
    DATA_TYPE = c(
      "character varying",
      "double precision",
      "timestamp without time zone",
      "timestamp without time zone"
    )
  )

  result <- buildValueDateRangeQuery(
    table_metadata,
    history_metadata,
    config,
    data_columns = c("obs_value_quantity")
  )

  expect_match(result$query, 'FROM "db2dataprocessor_out"."v_observation"', fixed = TRUE)
  expect_false(grepl("_last_version", result$query, fixed = TRUE))
  expect_match(result$query, 'MIN(CASE WHEN "obs_value_quantity" IS NOT NULL', fixed = TRUE)
  expect_match(result$query, '"input_datetime"', fixed = TRUE)
  expect_match(result$query, '"obs_meta_lastupdated"', fixed = TRUE)
  expect_equal(result$alias_map$COLUMN_NAME, c("obs_value_quantity", "obs_value_quantity"))
  expect_equal(result$alias_map$first_result_column, c(
    "first value import datetime",
    "first value meta last updated"
  ))
  expect_equal(result$alias_map$last_result_column, c(
    "last value import datetime",
    "last value meta last updated"
  ))
})

test_that("database quality analysis date range query ignores invalid calculated refs", {
  config <- list(
    view_prefix = "v_",
    value_import_datetime_column = "input_datetime"
  )
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    TABLE_NAME = "observation",
    TABLE_FAMILY = "FHIR",
    COLUMN_NAME = c("obs_id", "obs_encounter_calculated_ref"),
    DATA_TYPE = "character varying"
  )
  history_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation",
    COLUMN_NAME = c("obs_id", "obs_encounter_calculated_ref", "input_datetime"),
    DATA_TYPE = "character varying"
  )

  result <- buildValueDateRangeQuery(
    table_metadata,
    history_metadata,
    config,
    data_columns = c("obs_encounter_calculated_ref")
  )

  expect_match(result$query, '"obs_encounter_calculated_ref" IS NOT NULL', fixed = TRUE)
  expect_match(result$query, '"obs_encounter_calculated_ref"::text <> \'\'', fixed = TRUE)
  expect_match(result$query, '"obs_encounter_calculated_ref"::text <> \'invalid\'', fixed = TRUE)
})

test_that("database quality analysis date range query treats configured frontend checkboxes as checked groups", {
  config <- list(
    view_prefix = "v_",
    value_import_datetime_column = "input_datetime"
  )
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_retrolektive_mrpbewertung_fe_last_version",
    TABLE_NAME = "retrolektive_mrpbewertung_fe",
    TABLE_FAMILY = "Frontend",
    COLUMN_NAME = c("ret_id", "ret_massn_am1___1", "ret_massn_am1___2"),
    DATA_TYPE = "character varying"
  )
  history_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_retrolektive_mrpbewertung_fe",
    COLUMN_NAME = c("ret_id", "ret_massn_am1___1", "ret_massn_am1___2", "input_datetime"),
    DATA_TYPE = "character varying"
  )

  result <- buildValueDateRangeQuery(
    table_metadata,
    history_metadata,
    config,
    data_columns = c("ret_massn_am1___1")
  )

  expect_match(result$query, '"ret_massn_am1___1" = \'Checked\'', fixed = TRUE)
  expect_match(result$query, '"ret_massn_am1___2" = \'Checked\'', fixed = TRUE)
  expect_false(grepl('"ret_massn_am1___1"::text <> \'\'', result$query, fixed = TRUE))
})

test_that("database quality analysis metadata sheet contains neutral run metadata", {
  config <- list(
    view_schema = "db2dataprocessor_out",
    view_prefix = "v_",
    view_postfix = "_last_version",
    included_view_patterns = c("^v_[a-z0-9_]+_last_version$"),
    excluded_view_patterns = "_raw_",
    additional_views = "v_pids_per_ward",
    count_batch_size = 100,
    include_value_datetime_columns = FALSE,
    value_import_datetime_column = "input_datetime",
    grouping_overrides = parseGroupingOverrides(c("patient_fe|pat_id|record_id|"))
  )
  result <- data.table::data.table(
    TABLE_FAMILY = c("FHIR", "Frontend"),
    TABLE_NAME = c("observation", "patient_fe"),
    COLUMN_NAME = c("obs_id", "pat_id"),
    COLUMN_DESCRIPTION = c("id", NA_character_)
  )
  source_metadata <- data.table::data.table(
    VIEW_NAME = c("v_observation_last_version", "v_patient_fe_last_version"),
    COLUMN_DESCRIPTION = c("id", NA_character_)
  )
  database_metadata <- data.table::data.table(
    dbms = "PostgreSQL",
    server_version = "16.0",
    server_encoding = "UTF8"
  )

  sheet <- createMetadataSheet(
    result,
    source_metadata,
    config,
    as.POSIXct("2026-06-19 08:00:00", tz = "UTC"),
    as.POSIXct("2026-06-19 08:00:02", tz = "UTC"),
    database_metadata = database_metadata
  )

  expect_equal(sheet[PROPERTY == "analysis duration seconds", VALUE], "2")
  expect_equal(sheet[PROPERTY == "value datetime columns enabled", VALUE], "FALSE")
  expect_equal(sheet[PROPERTY == "database system", VALUE], "PostgreSQL")
  expect_false(any(tolower(sheet$PROPERTY) %in% c(
    "database host",
    "database port",
    "database name",
    "database user"
  )))
})

test_that("database quality analysis excel sheets only contain report columns", {
  result <- data.table::data.table(
    TABLE_NAME = "observation",
    COLUMN_NAME = "obs_id",
    COLUMN_DESCRIPTION = "id",
    USED_AS_GROUPING_FOR = "count per resource_id",
    "count per resource_id" = 1L,
    "count per PID" = 1L,
    "count per Fall-Id" = NA_integer_,
    "first value import datetime" = as.POSIXct(NA),
    "last value import datetime" = as.POSIXct(NA),
    "first value meta last updated" = as.POSIXct(NA),
    "last value meta last updated" = as.POSIXct(NA),
    "count per Einrichtungskontakt" = NA_integer_,
    "count per Einrichtungskontakt class IMP" = NA_integer_,
    "count per Einrichtungskontakt class SS" = NA_integer_,
    "count per Einrichtungskontakt class AMB" = NA_integer_,
    "count per Einrichtungskontakt class Andere" = NA_integer_,
    "count per Abteilungskontakt" = NA_integer_,
    "count per Abteilungskontakt class IMP" = NA_integer_,
    "count per Abteilungskontakt class SS" = NA_integer_,
    "count per Abteilungskontakt class AMB" = NA_integer_,
    "count per Abteilungskontakt class Andere" = NA_integer_,
    "count per Versorgungsstellenkontakt" = NA_integer_,
    "count per Versorgungsstellenkontakt class IMP" = NA_integer_,
    "count per Versorgungsstellenkontakt class SS" = NA_integer_,
    "count per Versorgungsstellenkontakt class AMB" = NA_integer_,
    "count per Versorgungsstellenkontakt class Andere" = NA_integer_,
    TABLE_FAMILY = "FHIR",
    ORDINAL_POSITION = 1L,
    check.names = FALSE
  )

  sheets <- splitResultForExcel(result)

  expect_named(sheets, "FHIR")
  expect_equal(names(sheets$FHIR), c(
    "TABLE_NAME",
    "COLUMN_NAME",
    "COLUMN_DESCRIPTION",
    "USED_AS_GROUPING_FOR",
    "count per resource_id",
    "count per PID",
    "count per Fall-Id",
    "first value import datetime",
    "last value import datetime",
    "first value meta last updated",
    "last value meta last updated",
    unname(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS)
  ))
})

test_that("database quality analysis excel sheets hide FHIR-only meta dates for non-FHIR tables", {
  result <- data.table::data.table(
    TABLE_NAME = c("observation", "patient_fe", "pids_per_ward"),
    COLUMN_NAME = c("obs_id", "pat_id", "patientid"),
    COLUMN_DESCRIPTION = c("id", "Patient ID", "Patient ID"),
    USED_AS_GROUPING_FOR = "count per resource_id",
    "count per resource_id" = 1L,
    "count per PID" = 1L,
    "count per Fall-Id" = NA_integer_,
    "first value import datetime" = as.POSIXct(NA),
    "last value import datetime" = as.POSIXct(NA),
    "first value meta last updated" = as.POSIXct(NA),
    "last value meta last updated" = as.POSIXct(NA),
    "count per Einrichtungskontakt" = NA_integer_,
    "count per Einrichtungskontakt class IMP" = NA_integer_,
    "count per Einrichtungskontakt class SS" = NA_integer_,
    "count per Einrichtungskontakt class AMB" = NA_integer_,
    "count per Einrichtungskontakt class Andere" = NA_integer_,
    "count per Abteilungskontakt" = NA_integer_,
    "count per Abteilungskontakt class IMP" = NA_integer_,
    "count per Abteilungskontakt class SS" = NA_integer_,
    "count per Abteilungskontakt class AMB" = NA_integer_,
    "count per Abteilungskontakt class Andere" = NA_integer_,
    "count per Versorgungsstellenkontakt" = NA_integer_,
    "count per Versorgungsstellenkontakt class IMP" = NA_integer_,
    "count per Versorgungsstellenkontakt class SS" = NA_integer_,
    "count per Versorgungsstellenkontakt class AMB" = NA_integer_,
    "count per Versorgungsstellenkontakt class Andere" = NA_integer_,
    TABLE_FAMILY = c("FHIR", "Frontend", "Other"),
    ORDINAL_POSITION = 1L,
    check.names = FALSE
  )

  sheets <- splitResultForExcel(result)

  expect_true(all(c(
    "first value meta last updated",
    "last value meta last updated"
  ) %in% names(sheets$FHIR)))
  expect_false(any(c(
    "first value meta last updated",
    "last value meta last updated"
  ) %in% names(sheets$Frontend)))
  expect_false(any(c(
    "first value meta last updated",
    "last value meta last updated"
  ) %in% names(sheets$Other)))
  expect_false(any(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS %in% names(sheets$Frontend)))
  expect_false(any(DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS %in% names(sheets$Other)))
  expect_true(all(c(
    "first value import datetime",
    "last value import datetime"
  ) %in% names(sheets$Frontend)))
})

test_that("database quality analysis excel sheets leave zero counts empty", {
  result <- data.table::data.table(
    TABLE_NAME = "observation",
    COLUMN_NAME = "obs_id",
    COLUMN_DESCRIPTION = "id",
    USED_AS_GROUPING_FOR = "count per resource_id",
    "count per resource_id" = 0L,
    "count per PID" = 1L,
    "count per Fall-Id" = NA_integer_,
    "first value import datetime" = as.POSIXct(NA),
    "last value import datetime" = as.POSIXct(NA),
    "first value meta last updated" = as.POSIXct(NA),
    "last value meta last updated" = as.POSIXct(NA),
    TABLE_FAMILY = "FHIR",
    ORDINAL_POSITION = 1L,
    check.names = FALSE
  )

  sheets <- splitResultForExcel(result)

  expect_true(is.na(sheets$FHIR[["count per resource_id"]][[1]]))
  expect_equal(sheets$FHIR[["count per PID"]][[1]], 1L)
  expect_true(is.na(sheets$FHIR[["count per Fall-Id"]][[1]]))
})

test_that("database quality analysis excel sheets visually group table rows", {
  sheet <- data.table::data.table(
    TABLE_NAME = c("condition", "condition", "observation"),
    COLUMN_NAME = c("con_id", "con_code", "obs_id"),
    COLUMN_DESCRIPTION = c("id", "code", "id"),
    USED_AS_GROUPING_FOR = c("count per resource_id", NA_character_, "count per resource_id"),
    "count per resource_id" = c(1L, 2L, 3L),
    "count per PID" = c(1L, 2L, 3L),
    "count per Fall-Id" = c(NA_integer_, NA_integer_, NA_integer_),
    "first value import datetime" = as.POSIXct(NA),
    "last value import datetime" = as.POSIXct(NA),
    "first value meta last updated" = as.POSIXct(NA),
    "last value meta last updated" = as.POSIXct(NA),
    check.names = FALSE
  )

  formatted_sheet <- formatSheetForExcel(sheet)

  expect_equal(formatted_sheet$TABLE_NAME, c("condition", NA_character_, NA_character_, "observation", NA_character_))
  expect_equal(formatted_sheet$COLUMN_NAME, c("con_id", "con_code", NA_character_, "obs_id", NA_character_))
})

test_that("database quality analysis excel writer uses readable column widths", {
  old_module_dirs <- if (exists("MODULE_DIRS", envir = .GlobalEnv, inherits = FALSE)) {
    get("MODULE_DIRS", envir = .GlobalEnv)
  } else {
    NULL
  }
  on.exit(
    {
      if (is.null(old_module_dirs)) {
        rm("MODULE_DIRS", envir = .GlobalEnv)
      } else {
        assign("MODULE_DIRS", old_module_dirs, envir = .GlobalEnv)
      }
    },
    add = TRUE
  )
  assign(
    "MODULE_DIRS",
    data.frame(local_dir = tempdir(), global_dir = tempdir()),
    envir = .GlobalEnv
  )

  sheets <- list(
    FHIR = data.table::data.table(
      TABLE_NAME = "observation",
      COLUMN_NAME = "obs_extremely_long_column_name",
      COLUMN_DESCRIPTION = "a deliberately long column description",
      USED_AS_GROUPING_FOR = NA_character_,
      "count per resource_id" = 1L,
      "count per PID" = 1L,
      "count per Fall-Id" = NA_integer_,
      "first value import datetime" = as.POSIXct(NA),
      "last value import datetime" = as.POSIXct(NA),
      "first value meta last updated" = as.POSIXct(NA),
      "last value meta last updated" = as.POSIXct(NA),
      check.names = FALSE
    ),
    Metadata = data.table::data.table(
      PROPERTY = "analysis duration seconds",
      VALUE = "2",
      check.names = FALSE
    )
  )

  file_name <- writeExcelFile(
    sheets,
    "Database_Quality_Analysis_Test",
    timestamp = as.POSIXct("2026-06-19 08:00:02", tz = "UTC")
  )
  sheet_xml_dir <- tempfile("database-quality-analysis-xlsx")
  dir.create(sheet_xml_dir)
  unzip(file_name, files = "xl/worksheets/sheet1.xml", exdir = sheet_xml_dir)
  sheet_xml <- paste(
    readLines(file.path(sheet_xml_dir, "xl/worksheets/sheet1.xml"), warn = FALSE),
    collapse = "\n"
  )

  expect_true(file.exists(file_name))
  expect_equal(basename(dirname(file_name)), "reports")
  expect_match(
    basename(file_name),
    "Database_Quality_Analysis_Test_2026-06-19_08-00-02.xlsx",
    fixed = TRUE
  )
  expect_equal(openxlsx::getSheetNames(file_name), c("FHIR", "Metadata"))
  expect_match(sheet_xml, "customWidth=\"1\"", fixed = TRUE)
})
