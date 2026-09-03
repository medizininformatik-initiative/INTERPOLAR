getTestResourceDetailSheets <- function() {
  detail_values <- list(
    RESOURCE_DETAIL_SHEET_NAMES = "FHIR Encounter",
    RESOURCE_DETAIL_TABLE_NAMES = "encounter",
    RESOURCE_DETAIL_ROW_GROUP_SYSTEM_COLUMNS = "enc_type_system",
    RESOURCE_DETAIL_ROW_GROUP_SYSTEMS = "http://fhir.de/CodeSystem/Kontaktebene",
    RESOURCE_DETAIL_ROW_GROUP_VALUE_COLUMNS = "enc_type_code",
    RESOURCE_DETAIL_ROW_GROUP_VALUES = c(
      "Einrichtungskontakt=einrichtungskontakt",
      "Abteilungskontakt=abteilungskontakt",
      "Versorgungsstellenkontakt=versorgungsstellenkontakt"
    ),
    RESOURCE_DETAIL_COUNT_GROUP_SYSTEM_COLUMNS = "enc_class_system",
    RESOURCE_DETAIL_COUNT_GROUP_SYSTEMS = "http://terminology.hl7.org/CodeSystem/v3-ActCode",
    RESOURCE_DETAIL_COUNT_GROUP_VALUE_COLUMNS = "enc_class_code",
    RESOURCE_DETAIL_COUNT_GROUP_VALUES = c(
      "count class IMP=IMP",
      "count class SS=SS",
      "count class AMB=AMB",
      "count class Andere=OTHER"
    )
  )
  get_config_value <- function(name, default) {
    if (is.null(detail_values[[name]])) {
      return(default)
    }
    detail_values[[name]]
  }

  parseResourceDetailSheets(get_config_value)
}

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

test_that("database quality analysis resource detail sheets are parsed", {
  result <- getTestResourceDetailSheets()
  detail_config <- result$encounter

  expect_equal(detail_config$sheet_name, "FHIR Encounter")
  expect_equal(names(detail_config$row_group_values), c(
    "Einrichtungskontakt",
    "Abteilungskontakt",
    "Versorgungsstellenkontakt"
  ))
  expect_equal(unname(detail_config$row_group_values), c(
    "einrichtungskontakt",
    "abteilungskontakt",
    "versorgungsstellenkontakt"
  ))
  expect_equal(unname(detail_config$count_group_count_columns), c(
    "count class IMP",
    "count class SS",
    "count class AMB",
    "count class Andere"
  ))
  expect_equal(unname(detail_config$count_group_values), c("IMP", "SS", "AMB", "OTHER"))
})


test_that("database quality analysis database locks are optional", {
  config <- getConfig(envir = new.env(parent = emptyenv()))

  expect_false(config$use_database_locks)
  expect_null(getDatabaseQualityAnalysisLockId(config, "test lock"))

  envir <- new.env(parent = emptyenv())
  assign("USE_DATABASE_LOCKS", TRUE, envir = envir)
  config <- getConfig(envir = envir)

  expect_equal(getDatabaseQualityAnalysisLockId(config, "test lock"), "test lock")
})


test_that("database quality analysis config defaults value summary controls", {
  config <- getConfig(envir = new.env(parent = emptyenv()))

  expect_false("view_schema" %in% names(config))
  expect_equal(config$value_summary_table_families, c("FHIR", "Frontend"))
  expect_equal(config$value_summary_suppressed_column_patterns, list(
    FHIR = character(),
    Frontend = character()
  ))
  expect_false(config$include_value_summary_values_columns)
})

test_that("database quality analysis config controls filtered scope sheets", {
  envir <- new.env(parent = emptyenv())
  assign("FILTERED_SCOPE_SHEET_NAMES", c("FHIR", "FHIR Encounter"), envir = envir)
  assign("FILTERED_SCOPE_DETAIL_SHEET_SUFFIX", "IP", envir = envir)
  assign("VALUE_SUMMARY_FHIR_SUPPRESSED_COLUMN_PATTERNS", c("_id$", "_ref$"), envir = envir)
  assign("VALUE_SUMMARY_FRONTEND_SUPPRESSED_COLUMN_PATTERNS", "_pid$", envir = envir)

  config <- getConfig(envir = envir)

  expect_true(isFilteredScopeSheetsEnabled(config))
  expect_equal(getFilteredScopeSheetNames(config), c("FHIR", "FHIR Encounter"))
  expect_true(isFilteredScopeSheetConfigured("FHIR", config))
  expect_true(isFilteredScopeSheetConfigured("FHIR Encounter", config))
  expect_false(isFilteredScopeSheetConfigured("Other", config))
  expect_equal(getFilteredScopeLabel(config), "IP")
  expect_equal(getFilteredScopeSheetName("FHIR", config), "FHIR IP")
  expect_equal(getFilteredScopeSheetName("FHIR Encounter", config), "FHIR Encounter IP")
  expect_equal(config$value_summary_suppressed_column_patterns, list(
    FHIR = c("_id$", "_ref$"),
    Frontend = "_pid$"
  ))
})


test_that("database quality analysis config can include values columns by command-line flags", {
  envir <- new.env(parent = emptyenv())
  command_arguments <- list(
    c("database-quality-analysis", "--include-value-summary-values-columns"),
    c("database-quality-analysis", "includeValuesColumns")
  )

  results <- lapply(command_arguments, function(arguments) {
    getConfig(envir = envir, command_arguments = arguments)
  })

  expect_true(all(vapply(results, function(result) {
    isTRUE(result$include_value_summary_values_columns)
  }, logical(1))))
})

test_that("database quality analysis value summary can include values columns explicitly", {
  config <- list(
    value_summary_suppressed_column_patterns = "_values$",
    include_value_summary_values_columns = FALSE
  )

  expect_true(shouldSuppressValueSummaryValues("obs_component_values", config))

  config$include_value_summary_values_columns <- TRUE
  expect_false(shouldSuppressValueSummaryValues("obs_component_values", config))
})

test_that("database quality analysis value summary suppression uses table family", {
  config <- list(
    value_summary_suppressed_column_patterns = list(
      FHIR = "_ref$",
      Frontend = "_pid$"
    ),
    include_value_summary_values_columns = FALSE
  )

  expect_true(shouldSuppressValueSummaryValues("obs_patient_ref", config, "FHIR"))
  expect_false(shouldSuppressValueSummaryValues("obs_patient_ref", config, "Frontend"))
  expect_true(shouldSuppressValueSummaryValues("record_pid", config, "Frontend"))
  expect_false(shouldSuppressValueSummaryValues("record_pid", config, "FHIR"))
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

test_that("database quality analysis resource reference scopes are inferred from grouping columns", {
  expect_equal(
    getResourceReferenceScope(c(resource_id = "pat_id", pid = "pat_id", case_id = NA_character_)),
    "patient_dependent"
  )
  expect_equal(
    getResourceReferenceScope(c(resource_id = "obs_id", pid = "obs_patient_ref", case_id = "obs_encounter_ref")),
    "case_dependent"
  )
  expect_equal(
    getResourceReferenceScope(c(resource_id = "loc_id", pid = NA_character_, case_id = NA_character_)),
    "case_patient_independent"
  )
})

test_that("database quality analysis grouping columns infer encounter hierarchy columns", {
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

  report_rows <- data.table::data.table(
    COLUMN_NAME = c("enc_id", "enc_type_system", "enc_type_code", "enc_class_system", "enc_class_code", "enc_status")
  )
  report_rows <- addGroupingRoles(report_rows, result)
  expect_equal(report_rows[COLUMN_NAME == "enc_id", USED_AS_GROUPING_FOR], "count per resource_id")
  expect_true(is.na(report_rows[COLUMN_NAME == "enc_type_system", USED_AS_GROUPING_FOR]))
  expect_true(is.na(report_rows[COLUMN_NAME == "enc_class_code", USED_AS_GROUPING_FOR]))
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

test_that("database quality analysis text value summary query counts values", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    TABLE_FAMILY = "FHIR",
    TABLE_NAME = "observation",
    COLUMN_NAME = c("obs_id", "obs_code_code"),
    COLUMN_DESCRIPTION = c("id", "code"),
    ORDINAL_POSITION = 1:2,
    DATA_TYPE = "character varying"
  )

  result <- buildTextValueSummaryQuery(table_metadata, c("obs_id", "obs_code_code"), "obs_id")

  expect_match(result, "COUNT(DISTINCT \"resource_values\".\"resource_id\")::integer", fixed = TRUE)
  expect_match(result, "'FHIR' AS \"TABLE_FAMILY\"", fixed = TRUE)
  expect_match(result, "'observation' AS \"TABLE_NAME\"", fixed = TRUE)
  expect_match(result, "CROSS JOIN LATERAL", fixed = TRUE)
  expect_match(result, "('obs_id', CASE WHEN \"source_row\".\"obs_id\" IS NULL", fixed = TRUE)
  expect_match(result, "('obs_code_code', CASE WHEN \"source_row\".\"obs_code_code\" IS NULL", fixed = TRUE)
  expect_match(result, "FROM \"db2dataprocessor_out\".\"v_observation_last_version\"", fixed = TRUE)
  expect_match(result, "GROUP BY \"resource_values\".\"column_name\", \"resource_values\".\"value\"", fixed = TRUE)
})

test_that("database quality analysis statistic value summary query batches aggregates", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    TABLE_FAMILY = "FHIR",
    TABLE_NAME = "observation",
    COLUMN_NAME = c("obs_id", "obs_value_quantity", "obs_effective_datetime"),
    COLUMN_DESCRIPTION = c("id", "value", "effective"),
    ORDINAL_POSITION = 1:3,
    DATA_TYPE = c("character varying", "double precision", "timestamp without time zone")
  )

  numeric_result <- buildStatisticValueSummaryQuery(
    table_metadata,
    "obs_value_quantity",
    "numeric",
    "obs_id"
  )
  datetime_result <- buildStatisticValueSummaryQuery(
    table_metadata,
    "obs_effective_datetime",
    "datetime",
    "obs_id"
  )

  expect_match(numeric_result$query, "MIN(\"source_row\".\"obs_value_quantity\"::double precision)", fixed = TRUE)
  expect_match(numeric_result$query, "PERCENTILE_CONT(0.5) WITHIN GROUP", fixed = TRUE)
  expect_match(numeric_result$query, "STDDEV_SAMP", fixed = TRUE)
  expect_match(numeric_result$query, "(COUNT(DISTINCT \"source_row\".\"obs_id\") - COUNT(DISTINCT \"source_row\".\"obs_id\") FILTER (WHERE \"source_row\".\"obs_value_quantity\" IS NOT NULL))::integer", fixed = TRUE)
  expect_equal(unique(numeric_result$alias_map$COLUMN_NAME), "obs_value_quantity")
  expect_equal(numeric_result$alias_map$result_column, c("MIN", "MAX", "AVG", "SE", "MEDIAN", "Q1", "Q3", "DISTINCT_VALUES", "EMPTY"))

  expect_match(datetime_result$query, "EXTRACT(EPOCH FROM \"source_row\".\"obs_effective_datetime\")", fixed = TRUE)
  expect_match(datetime_result$query, "'epoch'::timestamp", fixed = TRUE)
  expect_match(datetime_result$query, "PERCENTILE_CONT(0.75) WITHIN GROUP", fixed = TRUE)
})

test_that("database quality analysis creates value summary reports", {
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    TABLE_FAMILY = "FHIR",
    TABLE_NAME = "observation",
    COLUMN_NAME = c("obs_id", "obs_code_code", "obs_value_quantity", "obs_effective_datetime"),
    COLUMN_DESCRIPTION = c("id", "code", "value", "effective"),
    ORDINAL_POSITION = 1:4,
    DATA_TYPE = c("character varying", "character varying", "double precision", "timestamp without time zone")
  )
  config <- list(
    count_batch_size = 2,
    grouping_overrides = parseGroupingOverrides(character()),
    value_summary_suppressed_column_patterns = c("_id$", "_ref$")
  )
  query_state <- new.env(parent = emptyenv())
  query_state$seen_queries <- character()
  query_fun <- function(query, lock_id = NULL) {
    query_state$seen_queries <- c(query_state$seen_queries, query)
    aliases <- unique(regmatches(query, gregexpr("value_summary_[0-9]+", query))[[1]])
    if (grepl("CROSS JOIN LATERAL", query, fixed = TRUE)) {
      return(data.table::data.table(
        TABLE_FAMILY = "FHIR",
        TABLE_NAME = "observation",
        COLUMN_NAME = "obs_code_code",
        VALUE = c("AMB", "IMP", "rare-a", "rare-b", NA_character_),
        COUNT = c(20L, 10L, 2L, 3L, 4L)
      ))
    }
    if (grepl("obs_id", query, fixed = TRUE) && !grepl("PERCENTILE_CONT", query, fixed = TRUE)) {
      return(data.table::as.data.table(as.list(stats::setNames(c(3L, 0L)[seq_along(aliases)], aliases))))
    }
    if (grepl("EXTRACT(EPOCH", query, fixed = TRUE)) {
      values <- c(
        as.POSIXct("2026-01-01 08:00:00", tz = "UTC"),
        as.POSIXct("2026-01-03 08:00:00", tz = "UTC"),
        as.POSIXct("2026-01-02 08:00:00", tz = "UTC"),
        3600,
        as.POSIXct("2026-01-02 08:00:00", tz = "UTC"),
        as.POSIXct("2026-01-01 20:00:00", tz = "UTC"),
        as.POSIXct("2026-01-02 20:00:00", tz = "UTC"),
        3L,
        1L
      )
      return(data.table::as.data.table(as.list(stats::setNames(values[seq_along(aliases)], aliases))))
    }
    values <- c(1, 9, 5, 0.5, 5, 3, 7, 4, 2)
    data.table::as.data.table(as.list(stats::setNames(values[seq_along(aliases)], aliases)))
  }

  result <- createValueSummaryReports(
    metadata,
    config = config,
    query_fun = query_fun
  )

  expect_equal(names(result), "observation")
  observation <- result$observation
  expect_equal(names(observation), DATABASE_QUALITY_ANALYSIS_VALUE_SUMMARY_COLUMNS)
  expect_equal(observation$COLUMN_NAME, c("obs_id", "obs_code_code", "obs_value_quantity", "obs_effective_datetime"))
  expect_equal(observation[COLUMN_NAME == "obs_id", DISTINCT_VALUES], 3L)
  expect_true(is.na(observation[COLUMN_NAME == "obs_id", VALUE_COUNTS]))
  expect_equal(observation[COLUMN_NAME == "obs_id", EMPTY], 0L)
  expect_equal(observation[COLUMN_NAME == "obs_code_code", VALUE_TYPE], "text")
  expect_equal(observation[COLUMN_NAME == "obs_code_code", DISTINCT_VALUES], 4L)
  expect_equal(
    observation[COLUMN_NAME == "obs_code_code", VALUE_COUNTS],
    "'AMB': 20; 'IMP': 10; Other (count < 5): 5"
  )
  expect_equal(observation[COLUMN_NAME == "obs_code_code", EMPTY], 4L)
  expect_equal(observation[COLUMN_NAME == "obs_value_quantity", VALUE_TYPE], "numeric")
  expect_equal(observation[COLUMN_NAME == "obs_value_quantity", MIN], "1")
  expect_equal(observation[COLUMN_NAME == "obs_value_quantity", Q3], "7")
  expect_equal(observation[COLUMN_NAME == "obs_value_quantity", DISTINCT_VALUES], 4L)
  expect_equal(observation[COLUMN_NAME == "obs_value_quantity", EMPTY], 2L)
  expect_equal(observation[COLUMN_NAME == "obs_effective_datetime", VALUE_TYPE], "datetime")
  expect_equal(observation[COLUMN_NAME == "obs_effective_datetime", MIN], "2026-01-01 08:00:00")
  expect_equal(observation[COLUMN_NAME == "obs_effective_datetime", SE], 3600)
  expect_equal(observation[COLUMN_NAME == "obs_effective_datetime", DISTINCT_VALUES], 3L)
  expect_equal(observation[COLUMN_NAME == "obs_effective_datetime", EMPTY], 1L)
  expect_length(query_state$seen_queries, 4L)
})

test_that("database quality analysis value summary reports use configured table families", {
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = c("v_observation_last_version", "v_patient_fe_last_version", "v_pids_per_ward"),
    TABLE_FAMILY = c("FHIR", "Frontend", "Other"),
    TABLE_NAME = c("observation", "patient_fe", "pids_per_ward"),
    COLUMN_NAME = c("obs_id", "pat_id", "patientid"),
    COLUMN_DESCRIPTION = NA_character_,
    ORDINAL_POSITION = 1L,
    DATA_TYPE = "character varying"
  )
  query_state <- new.env(parent = emptyenv())
  query_state$seen_queries <- character()
  query_fun <- function(query, lock_id = NULL) {
    query_state$seen_queries <- c(query_state$seen_queries, query)
    aliases <- unique(regmatches(query, gregexpr("value_summary_[0-9]+", query))[[1]])
    data.table::as.data.table(as.list(stats::setNames(c(1L, 0L)[seq_along(aliases)], aliases)))
  }

  result <- createValueSummaryReports(
    metadata,
    config = list(
      grouping_overrides = parseGroupingOverrides(character()),
      value_summary_table_families = c("FHIR", "Frontend"),
      value_summary_suppressed_column_patterns = "_id$"
    ),
    query_fun = query_fun
  )

  expect_equal(names(result), c("observation", "patient_fe"))
  expect_false("TABLE_FAMILY" %in% names(result$observation))
  expect_false("TABLE_NAME" %in% names(result$observation))
  expect_false("TABLE_FAMILY" %in% names(result$patient_fe))
  expect_false("TABLE_NAME" %in% names(result$patient_fe))
  expect_length(query_state$seen_queries, 1L)
  expect_match(query_state$seen_queries[[1]], "v_observation_last_version", fixed = TRUE)
  expect_false(any(grepl("pids_per_ward", query_state$seen_queries, fixed = TRUE)))
})

test_that("database quality analysis count query applies optional row filters", {
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
    data_columns = c("obs_value"),
    row_filter_condition = '"obs_encounter_calculated_ref" IN (SELECT "enc_id" FROM "encounter")'
  )

  expect_match(
    result$query,
    'WHERE "obs_encounter_calculated_ref" IN (SELECT "enc_id" FROM "encounter")',
    fixed = TRUE
  )
  expect_match(result$query, 'CASE WHEN "obs_value" IS NOT NULL', fixed = TRUE)
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

test_that("database quality analysis filtered case sheets can be disabled", {
  config <- list(filtered_scope_sheet_names = character())

  expect_equal(
    createFilteredScopeFhirSheets(data.table::data.table(), data.table::data.table(), config),
    list()
  )
  expect_equal(
    createFilteredScopeResourceDetailSheets(data.table::data.table(), data.table::data.table(), config),
    list()
  )
})

test_that("database quality analysis filtered scope filter uses calculated encounter refs", {
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = c(
      rep("v_encounter_last_version", 2),
      rep("v_pids_per_ward", 1),
      rep("v_observation_last_version", 3),
      rep("v_patient_last_version", 2)
    ),
    TABLE_NAME = c(
      rep("encounter", 2),
      "pids_per_ward",
      rep("observation", 3),
      rep("patient", 2)
    ),
    TABLE_FAMILY = c(rep("FHIR", 2), "Other", rep("FHIR", 3), rep("FHIR", 2)),
    COLUMN_NAME = c(
      "enc_id",
      "enc_main_encounter_calculated_ref",
      "encounter_id",
      "obs_id",
      "obs_patient_ref",
      "obs_encounter_calculated_ref",
      "pat_id",
      "pat_birth_date"
    ),
    COLUMN_DESCRIPTION = NA_character_,
    ORDINAL_POSITION = c(1:2, 1, 1:3, 1:2),
    DATA_TYPE = "character varying"
  )
  config <- list(grouping_overrides = parseGroupingOverrides(character()))
  observation_metadata <- getTableMetadata(metadata, "observation")
  observation_grouping <- inferGroupingColumns(observation_metadata, config)
  patient_metadata <- getTableMetadata(metadata, "patient")
  patient_grouping <- inferGroupingColumns(patient_metadata, config)
  main_encounter_subquery <- getFilteredScopeMainEncounterSubquery(metadata)

  observation_filter <- getFilteredScopeCaseFilterCondition(
    observation_metadata,
    observation_grouping,
    main_encounter_subquery
  )
  patient_filter <- getFilteredScopeCaseFilterCondition(
    patient_metadata,
    patient_grouping,
    main_encounter_subquery
  )

  expect_match(main_encounter_subquery, 'FROM "db2dataprocessor_out"."v_encounter_last_version"', fixed = TRUE)
  expect_match(main_encounter_subquery, 'JOIN "db2dataprocessor_out"."v_pids_per_ward"', fixed = TRUE)
  expect_match(observation_filter, '"obs_encounter_calculated_ref" IS NOT NULL', fixed = TRUE)
  expect_match(observation_filter, '"obs_encounter_calculated_ref"::text <> \'invalid\'', fixed = TRUE)
  expect_match(observation_filter, '"obs_encounter_calculated_ref" IN', fixed = TRUE)
  expect_true(is.na(patient_filter))
})

test_that("database quality analysis creates filtered scope sheet for encounter-related FHIR tables", {
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = c(
      rep("v_encounter_last_version", 3),
      "v_pids_per_ward",
      rep("v_observation_last_version", 4),
      rep("v_patient_last_version", 2)
    ),
    TABLE_NAME = c(
      rep("encounter", 3),
      "pids_per_ward",
      rep("observation", 4),
      rep("patient", 2)
    ),
    TABLE_FAMILY = c(rep("FHIR", 3), "Other", rep("FHIR", 4), rep("FHIR", 2)),
    COLUMN_NAME = c(
      "enc_id",
      "enc_patient_ref",
      "enc_main_encounter_calculated_ref",
      "encounter_id",
      "obs_id",
      "obs_patient_ref",
      "obs_encounter_calculated_ref",
      "obs_value",
      "pat_id",
      "pat_birth_date"
    ),
    COLUMN_DESCRIPTION = c(
      "id",
      "patient",
      "case",
      "case",
      "id",
      "patient",
      "case",
      "value",
      "id",
      "birth date"
    ),
    ORDINAL_POSITION = c(1:3, 1, 1:4, 1:2),
    DATA_TYPE = "character varying"
  )
  result <- data.table::data.table(
    TABLE_NAME = metadata[TABLE_FAMILY == "FHIR", TABLE_NAME],
    COLUMN_NAME = metadata[TABLE_FAMILY == "FHIR", COLUMN_NAME],
    COLUMN_DESCRIPTION = metadata[TABLE_FAMILY == "FHIR", COLUMN_DESCRIPTION],
    USED_AS_GROUPING_FOR = NA_character_,
    "count per resource_id" = 99L,
    "count per PID" = 99L,
    "count per Fall-Id" = 99L,
    TABLE_FAMILY = "FHIR",
    RESOURCE_REFERENCE_SCOPE = c(rep("case_dependent", 3), rep("case_dependent", 4), rep("patient_dependent", 2)),
    ORDINAL_POSITION = metadata[TABLE_FAMILY == "FHIR", ORDINAL_POSITION],
    check.names = FALSE
  )
  result <- orderByResourceReferenceScope(result)
  config <- list(
    count_batch_size = 100,
    filtered_scope_sheet_names = "FHIR",
    grouping_overrides = parseGroupingOverrides("patient|pat_id|pat_id|")
  )
  query_state <- new.env(parent = emptyenv())
  query_state$seen_queries <- character()
  query_fun <- function(query, lock_id = NULL) {
    query_state$seen_queries <- c(query_state$seen_queries, query)
    aliases <- unique(regmatches(query, gregexpr("count_[0-9]+", query))[[1]])
    data.table::as.data.table(as.list(stats::setNames(rep(1L, length(aliases)), aliases)))
  }

  sheet <- createFilteredScopeFhirSheet(metadata, result, config, query_fun = query_fun)

  expect_equal(unique(sheet$TABLE_NAME), c("patient", "encounter", "observation"))
  expect_true("patient" %in% sheet$TABLE_NAME)
  expect_equal(sheet[TABLE_NAME == "observation" & COLUMN_NAME == "obs_value", "count per resource_id"][[1]], 1L)
  expect_true(any(grepl('"obs_encounter_calculated_ref" IN', query_state$seen_queries, fixed = TRUE)))
  expect_true(any(grepl('"enc_main_encounter_calculated_ref" IN', query_state$seen_queries, fixed = TRUE)))
  expect_true(any(grepl('"pat_id" IN', query_state$seen_queries, fixed = TRUE)))
  expect_true(any(grepl("regexp_replace", query_state$seen_queries, fixed = TRUE)))
})

test_that("database quality analysis filtered scope sheet fills value datetime columns", {
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = c(
      rep("v_encounter_last_version", 3),
      "v_pids_per_ward",
      rep("v_observation_last_version", 4)
    ),
    TABLE_NAME = c(
      rep("encounter", 3),
      "pids_per_ward",
      rep("observation", 4)
    ),
    TABLE_FAMILY = c(rep("FHIR", 3), "Other", rep("FHIR", 4)),
    COLUMN_NAME = c(
      "enc_id",
      "enc_patient_ref",
      "enc_main_encounter_calculated_ref",
      "encounter_id",
      "obs_id",
      "obs_patient_ref",
      "obs_encounter_calculated_ref",
      "obs_value"
    ),
    COLUMN_DESCRIPTION = c("id", "patient", "case", "case", "id", "patient", "case", "value"),
    ORDINAL_POSITION = c(1:3, 1, 1:4),
    DATA_TYPE = "character varying"
  )
  history_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation",
    COLUMN_NAME = c(
      "obs_id",
      "obs_patient_ref",
      "obs_encounter_calculated_ref",
      "obs_value",
      "input_datetime",
      "obs_meta_lastupdated"
    ),
    DATA_TYPE = c(
      rep("character varying", 4),
      "timestamp without time zone",
      "timestamp without time zone"
    )
  )
  result <- data.table::data.table(
    TABLE_NAME = metadata[TABLE_FAMILY == "FHIR", TABLE_NAME],
    COLUMN_NAME = metadata[TABLE_FAMILY == "FHIR", COLUMN_NAME],
    COLUMN_DESCRIPTION = metadata[TABLE_FAMILY == "FHIR", COLUMN_DESCRIPTION],
    USED_AS_GROUPING_FOR = NA_character_,
    "count per resource_id" = NA_integer_,
    "count per PID" = NA_integer_,
    "count per Fall-Id" = NA_integer_,
    "first value import datetime" = as.POSIXct(NA),
    "last value import datetime" = as.POSIXct(NA),
    "first value meta last updated" = as.POSIXct(NA),
    "last value meta last updated" = as.POSIXct(NA),
    TABLE_FAMILY = "FHIR",
    ORDINAL_POSITION = metadata[TABLE_FAMILY == "FHIR", ORDINAL_POSITION],
    check.names = FALSE
  )
  config <- list(
    count_batch_size = 100,
    filtered_scope_sheet_names = "FHIR",
    grouping_overrides = parseGroupingOverrides(character()),
    include_value_datetime_columns = TRUE,
    view_prefix = "v_",
    value_import_datetime_column = "input_datetime"
  )
  query_fun <- function(query, lock_id = NULL) {
    count_aliases <- unique(regmatches(query, gregexpr("count_[0-9]+", query))[[1]])
    if (length(count_aliases)) {
      return(data.table::as.data.table(as.list(stats::setNames(
        rep(1L, length(count_aliases)),
        count_aliases
      ))))
    }

    first_aliases <- unique(regmatches(query, gregexpr("first_value_datetime_[a-z0-9_]+", query))[[1]])
    last_aliases <- unique(regmatches(query, gregexpr("last_value_datetime_[a-z0-9_]+", query))[[1]])
    datetime_values <- c(
      stats::setNames(
        rep(as.POSIXct("2026-01-01 00:00:00", tz = "UTC"), length(first_aliases)),
        first_aliases
      ),
      stats::setNames(
        rep(as.POSIXct("2026-01-02 00:00:00", tz = "UTC"), length(last_aliases)),
        last_aliases
      )
    )
    data.table::as.data.table(as.list(datetime_values))
  }

  sheet <- createFilteredScopeFhirSheet(
    metadata,
    result,
    config,
    history_metadata = history_metadata,
    query_fun = query_fun
  )

  value_row <- sheet[TABLE_NAME == "observation" & COLUMN_NAME == "obs_value"]
  expect_equal(
    as.numeric(value_row[["first value import datetime"]][[1]]),
    as.numeric(as.POSIXct("2026-01-01 00:00:00", tz = "UTC"))
  )
  expect_equal(
    as.numeric(value_row[["last value import datetime"]][[1]]),
    as.numeric(as.POSIXct("2026-01-02 00:00:00", tz = "UTC"))
  )
  expect_equal(
    as.numeric(value_row[["first value meta last updated"]][[1]]),
    as.numeric(as.POSIXct("2026-01-01 00:00:00", tz = "UTC"))
  )
  expect_equal(
    as.numeric(value_row[["last value meta last updated"]][[1]]),
    as.numeric(as.POSIXct("2026-01-02 00:00:00", tz = "UTC"))
  )
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

test_that("database quality analysis resource detail query filters block and split counts", {
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
  grouping_columns <- c(
    resource_id = "enc_id",
    pid = "enc_patient_ref",
    case_id = "enc_main_encounter_calculated_ref"
  )

  detail_config <- getTestResourceDetailSheets()$encounter
  result <- buildResourceDetailCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("enc_status"),
    detail_config = detail_config,
    row_group_value = "einrichtungskontakt"
  )

  expect_match(result$query, '"enc_type_system" = \'http://fhir.de/CodeSystem/Kontaktebene\'', fixed = TRUE)
  expect_match(result$query, '"enc_type_code" = \'einrichtungskontakt\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_system" = \'http://terminology.hl7.org/CodeSystem/v3-ActCode\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" = \'AMB\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" = \'IMP\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" = \'SS\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" IS NOT NULL', fixed = TRUE)
  expect_match(result$query, '"enc_class_code"::text <> \'\'', fixed = TRUE)
  expect_match(result$query, '"enc_class_code" NOT IN (\'AMB\', \'IMP\', \'SS\')', fixed = TRUE)
  expect_match(result$query, '"enc_main_encounter_calculated_ref"::text <> \'invalid\'', fixed = TRUE)
  expect_equal(result$alias_map$count_column, c(
    unname(DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS),
    unname(detail_config$count_group_count_columns)
  ))
})

test_that("database quality analysis resource detail query applies optional row filters", {
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
  grouping_columns <- c(
    resource_id = "enc_id",
    pid = "enc_patient_ref",
    case_id = "enc_main_encounter_calculated_ref"
  )

  result <- buildResourceDetailCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("enc_status"),
    detail_config = getTestResourceDetailSheets()$encounter,
    row_group_value = "einrichtungskontakt",
    row_filter_condition = "enc_main_encounter_calculated_ref IN (SELECT enc_id FROM ip_cases)"
  )

  expect_match(
    result$query,
    "WHERE enc_main_encounter_calculated_ref IN (SELECT enc_id FROM ip_cases)",
    fixed = TRUE
  )
})

test_that("database quality analysis creates resource detail sheet blocks", {
  config <- list(grouping_overrides = parseGroupingOverrides(character()))
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_encounter_last_version",
    TABLE_NAME = "encounter",
    TABLE_FAMILY = "FHIR",
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
    COLUMN_DESCRIPTION = c("id", "patient", "case", "type system", "type code", "class system", "class code", "status"),
    ORDINAL_POSITION = 1:8,
    DATA_TYPE = "character varying"
  )
  result <- data.table::data.table(
    TABLE_NAME = "encounter",
    COLUMN_NAME = metadata$COLUMN_NAME,
    COLUMN_DESCRIPTION = metadata$COLUMN_DESCRIPTION,
    USED_AS_GROUPING_FOR = NA_character_,
    "count per resource_id" = NA_integer_,
    "count per PID" = NA_integer_,
    "count per Fall-Id" = NA_integer_,
    TABLE_FAMILY = "FHIR",
    ORDINAL_POSITION = metadata$ORDINAL_POSITION,
    check.names = FALSE
  )
  query_fun <- function(query, lock_id = NULL) {
    aliases <- unique(regmatches(query, gregexpr("count_[0-9]+", query))[[1]])
    data.table::as.data.table(as.list(stats::setNames(seq_along(aliases), aliases)))
  }

  detail_config <- getTestResourceDetailSheets()$encounter
  sheet <- createResourceDetailSheet(metadata, result, config, detail_config, query_fun = query_fun)

  expect_equal(unique(sheet$TABLE_NAME), paste(
    "encounter",
    names(detail_config$row_group_values),
    sep = " - "
  ))
  expect_equal(nrow(sheet), 3L * nrow(metadata))
  expect_equal(
    tail(names(sheet), length(detail_config$count_group_count_columns)),
    unname(detail_config$count_group_count_columns)
  )
  expect_true(all(unname(DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS) %in% names(sheet)))
  expect_false(any(grepl("count per Einrichtungskontakt", names(sheet), fixed = TRUE)))
  expect_false(is.na(sheet[TABLE_NAME == "encounter - Einrichtungskontakt" & COLUMN_NAME == "enc_status", "count class IMP"][[1]]))
})

test_that("database quality analysis creates filtered scope resource detail sheets", {
  config <- list(
    filtered_scope_sheet_names = "FHIR Encounter",
    filtered_scope_detail_sheet_suffix = "IP",
    grouping_overrides = parseGroupingOverrides(character()),
    resource_detail_sheets = getTestResourceDetailSheets()
  )
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = c(rep("v_encounter_last_version", 8), "v_pids_per_ward"),
    TABLE_NAME = c(rep("encounter", 8), "pids_per_ward"),
    TABLE_FAMILY = c(rep("FHIR", 8), "Other"),
    COLUMN_NAME = c(
      "enc_id",
      "enc_patient_ref",
      "enc_main_encounter_calculated_ref",
      "enc_type_system",
      "enc_type_code",
      "enc_class_system",
      "enc_class_code",
      "enc_status",
      "encounter_id"
    ),
    COLUMN_DESCRIPTION = c(
      "id",
      "patient",
      "case",
      "type system",
      "type code",
      "class system",
      "class code",
      "status",
      "case"
    ),
    ORDINAL_POSITION = c(1:8, 1),
    DATA_TYPE = "character varying"
  )
  result <- data.table::data.table(
    TABLE_NAME = "encounter",
    COLUMN_NAME = metadata[TABLE_NAME == "encounter", COLUMN_NAME],
    COLUMN_DESCRIPTION = metadata[TABLE_NAME == "encounter", COLUMN_DESCRIPTION],
    USED_AS_GROUPING_FOR = NA_character_,
    "count per resource_id" = NA_integer_,
    "count per PID" = NA_integer_,
    "count per Fall-Id" = NA_integer_,
    TABLE_FAMILY = "FHIR",
    RESOURCE_REFERENCE_SCOPE = "case_dependent",
    ORDINAL_POSITION = metadata[TABLE_NAME == "encounter", ORDINAL_POSITION],
    check.names = FALSE
  )
  query_state <- new.env(parent = emptyenv())
  query_state$seen_queries <- character()
  query_fun <- function(query, lock_id = NULL) {
    query_state$seen_queries <- c(query_state$seen_queries, query)
    aliases <- unique(regmatches(query, gregexpr("count_[0-9]+", query))[[1]])
    data.table::as.data.table(as.list(stats::setNames(rep(1L, length(aliases)), aliases)))
  }

  sheets <- createFilteredScopeResourceDetailSheets(metadata, result, config, query_fun = query_fun)

  expect_equal(names(sheets), "FHIR Encounter IP")
  expect_equal(
    unique(sheets[["FHIR Encounter IP"]]$TABLE_NAME),
    paste("encounter", names(config$resource_detail_sheets$encounter$row_group_values), sep = " - ")
  )
  expect_true(any(grepl('"enc_main_encounter_calculated_ref" IN', query_state$seen_queries, fixed = TRUE)))
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
    data_columns = c("mrp_pigrund___1"),
    config = list(
      boolean_group_table_families = "Frontend",
      boolean_group_column_pattern = "___[0-9]+$",
      boolean_true_values = "Checked"
    )
  )

  expect_match(result$query, '"mrp_pigrund___1" = \'Checked\'', fixed = TRUE)
  expect_match(result$query, '"mrp_pigrund___2" = \'Checked\'', fixed = TRUE)
  expect_match(result$query, '"mrp_pigrund___3" = \'Checked\'', fixed = TRUE)
  expect_match(
    result$query,
    '("mrp_pigrund___1" = \'Checked\' OR "mrp_pigrund___2" = \'Checked\' OR "mrp_pigrund___3" = \'Checked\')',
    fixed = TRUE
  )
  expect_false(grepl('"mrp_pigrund___1"::text <> \'\'', result$query, fixed = TRUE))
})

test_that("database quality analysis boolean groups are configurable by pattern and values", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_example_fe_last_version",
    TABLE_NAME = "example_fe",
    TABLE_FAMILY = "Frontend",
    COLUMN_NAME = c("example_id", "record_id", "field___1", "field___2", "field_other"),
    DATA_TYPE = "character varying"
  )
  grouping_columns <- c(resource_id = "example_id", pid = "record_id", case_id = NA_character_)
  config <- list(
    boolean_group_table_families = "Frontend",
    boolean_group_column_pattern = "___[0-9]+$",
    boolean_true_values = c("Checked", "TRUE")
  )

  result <- buildCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("field___1"),
    config = config
  )

  expect_match(result$query, "field___1", fixed = TRUE)
  expect_match(result$query, "field___2", fixed = TRUE)
  expect_match(result$query, " IN (", fixed = TRUE)
  expect_match(result$query, "Checked", fixed = TRUE)
  expect_match(result$query, "TRUE", fixed = TRUE)
  expect_false(grepl("field_other", result$query, fixed = TRUE))
})

test_that("database quality analysis boolean groups are limited to configured families", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    TABLE_NAME = "observation",
    TABLE_FAMILY = "FHIR",
    COLUMN_NAME = c("obs_id", "obs_patient_ref", "obs_field___1", "obs_field___2"),
    DATA_TYPE = "character varying"
  )
  grouping_columns <- c(resource_id = "obs_id", pid = "obs_patient_ref", case_id = NA_character_)

  result <- buildCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("obs_field___1"),
    config = list(boolean_group_table_families = "Frontend")
  )

  expect_match(result$query, "obs_field___1", fixed = TRUE)
  expect_match(result$query, "IS NOT NULL", fixed = TRUE)
  expect_false(grepl("obs_field___2", result$query, fixed = TRUE))
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
  expect_equal(result[COLUMN_NAME == "obs_id", USED_AS_GROUPING_FOR], "count per resource_id")
  expect_equal(result[COLUMN_NAME == "obs_patient_ref", USED_AS_GROUPING_FOR], "count per PID")
  expect_true(all(is.na(result[["count per Fall-Id"]])))
  expect_equal(result[COLUMN_NAME == "obs_value", "count per resource_id"][[1]], 5L)
})

test_that("database quality analysis FHIR rows are sorted by reference scope", {
  config <- list(
    count_batch_size = 100,
    grouping_overrides = parseGroupingOverrides("patient|pat_id|pat_id|"),
    view_prefix = "v_",
    value_import_datetime_column = "input_datetime",
    include_value_datetime_columns = FALSE
  )
  metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = c(
      rep("v_location_last_version", 2),
      rep("v_observation_last_version", 3),
      rep("v_patient_last_version", 2)
    ),
    TABLE_NAME = c(rep("location", 2), rep("observation", 3), rep("patient", 2)),
    TABLE_FAMILY = "FHIR",
    COLUMN_NAME = c(
      "loc_id",
      "loc_name",
      "obs_id",
      "obs_patient_ref",
      "obs_encounter_ref",
      "pat_id",
      "pat_birth_date"
    ),
    COLUMN_DESCRIPTION = NA_character_,
    ORDINAL_POSITION = c(1:2, 1:3, 1:2),
    DATA_TYPE = "character varying"
  )
  query_fun <- function(query, lock_id = NULL) {
    aliases <- unique(regmatches(query, gregexpr("count_[0-9]+", query))[[1]])
    data.table::as.data.table(as.list(stats::setNames(rep(1L, length(aliases)), aliases)))
  }

  result <- calculateCounts(metadata, config, query_fun = query_fun)

  expect_equal(unique(result$TABLE_NAME), c("patient", "observation", "location"))
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
    value_import_datetime_column = "input_datetime",
    boolean_group_table_families = "Frontend",
    boolean_group_column_pattern = "___[0-9]+$",
    boolean_true_values = "Checked"
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

test_that("database quality analysis sheet description explains generated sheets", {
  config <- list(
    filtered_scope_sheet_names = c("FHIR", "FHIR Encounter"),
    filtered_scope_detail_sheet_suffix = "IP"
  )
  sheet <- createSheetDescriptionSheet(c(
    "FHIR",
    "FHIR IP",
    "FHIR Encounter",
    "FHIR Encounter IP",
    "Frontend",
    "Other",
    "Metadata"
  ), config)

  expect_equal(names(sheet), c("SHEET_NAME", "DESCRIPTION", "FILTER_SCOPE", "COUNT_LOGIC"))
  expect_equal(sheet$SHEET_NAME, c(
    "FHIR",
    "FHIR IP",
    "FHIR Encounter",
    "FHIR Encounter IP",
    "Frontend",
    "Other",
    "Metadata"
  ))
  expect_true(all(nzchar(sheet$DESCRIPTION)))
  expect_match(
    sheet[SHEET_NAME == "FHIR IP", FILTER_SCOPE],
    "Patient-dependent resources",
    fixed = TRUE
  )
  expect_match(
    sheet[SHEET_NAME == "FHIR Encounter IP", FILTER_SCOPE],
    "filtered scope",
    fixed = TRUE
  )
  expect_equal(sheet[SHEET_NAME == "Metadata", COUNT_LOGIC], "Contains runtime, configuration and source metadata values.")

  custom_config <- list(
    filtered_scope_sheet_names = c("FHIR", "FHIR Encounter"),
    filtered_scope_detail_sheet_suffix = "IP"
  )
  custom_sheet <- createSheetDescriptionSheet(c("FHIR IP", "FHIR Encounter IP"), custom_config)

  expect_match(custom_sheet[SHEET_NAME == "FHIR IP", DESCRIPTION], "IP scope", fixed = TRUE)
  expect_match(custom_sheet[SHEET_NAME == "FHIR Encounter IP", DESCRIPTION], "IP scope", fixed = TRUE)
})

test_that("database quality analysis sheet description is prepended", {
  sheets <- list(
    FHIR = data.table::data.table(TABLE_NAME = "patient"),
    "FHIR IP" = data.table::data.table(TABLE_NAME = "patient")
  )
  config <- list(
    filtered_scope_sheet_names = "FHIR",
    filtered_scope_detail_sheet_suffix = "IP"
  )

  result <- prependSheetDescriptionSheet(sheets, config)

  expect_equal(names(result), c("Sheet Description", "FHIR", "FHIR IP"))
  expect_equal(result[["Sheet Description"]]$SHEET_NAME, c("FHIR", "FHIR IP", "Metadata"))
})

test_that("database quality analysis metadata sheet contains neutral run metadata", {
  config <- list(
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
    VIEW_SCHEMA = "db2dataprocessor_out",
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
  expect_equal(sheet[PROPERTY == "view schema", VALUE], "db2dataprocessor_out")
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
    "last value meta last updated"
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

  sheet[, TABLE_NAME := c("observation", "observation", "condition")]
  formatted_sheet <- formatSheetForExcel(sheet)

  expect_equal(formatted_sheet$TABLE_NAME, c("observation", NA_character_, NA_character_, "condition", NA_character_))
})

test_that("database quality analysis count summary filename uses suffix", {
  expect_equal(
    getCountSummaryOutputFilename(list(output_filename = "Database_Quality_Analysis_Test")),
    "Database_Quality_Analysis_Test_Count_Summary"
  )
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

test_that("database quality analysis value summary writer creates zip archive", {
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

  value_summaries <- list(
    observation = data.table::data.table(
      COLUMN_NAME = "obs_code_code",
      DATA_TYPE = "character varying",
      VALUE_TYPE = "text",
      DISTINCT_VALUES = 2L,
      VALUE_COUNTS = "'AMB': 20; 'IMP': 10",
      MIN = NA_character_,
      MAX = NA_character_,
      AVG = NA_character_,
      MEDIAN = NA_character_,
      Q1 = NA_character_,
      Q3 = NA_character_,
      SE = NA_real_,
      EMPTY = 4L,
      check.names = FALSE
    )
  )

  value_summaries$patient_fe <- data.table::copy(value_summaries$observation)
  attr(value_summaries$patient_fe, "table_family") <- "Frontend"

  file_name <- writeValueSummaryArchive(
    value_summaries,
    "Database_Quality_Analysis_Test",
    timestamp = as.POSIXct("2026-06-19 08:00:02", tz = "UTC")
  )

  expect_true(file.exists(file_name))
  expect_match(
    basename(file_name),
    "Database_Quality_Analysis_Test_Value_Summary_2026-06-19_08-00-02.zip",
    fixed = TRUE
  )
  archive_files <- utils::unzip(file_name, list = TRUE)
  expect_equal(sort(archive_files$Name), c("FHIR/observation.csv", "Frontend/patient_fe.csv"))
  extract_dir <- tempfile("value-summary-unzip-")
  dir.create(extract_dir)
  utils::unzip(file_name, exdir = extract_dir)
  written_values <- data.table::fread(file.path(extract_dir, "FHIR", "observation.csv"), sep = ",")
  frontend_values <- data.table::fread(file.path(extract_dir, "Frontend", "patient_fe.csv"), sep = ",")
  expect_equal(written_values$DISTINCT_VALUES, 2L)
  expect_equal(written_values$VALUE_COUNTS, "'AMB': 20; 'IMP': 10")
  expect_equal(written_values$EMPTY, 4L)
  expect_equal(frontend_values$VALUE_COUNTS, "'AMB': 20; 'IMP': 10")
})

test_that("database quality analysis value summary writer handles relative output dirs", {
  old_module_dirs <- if (exists("MODULE_DIRS", envir = .GlobalEnv, inherits = FALSE)) {
    get("MODULE_DIRS", envir = .GlobalEnv)
  } else {
    NULL
  }
  old_wd <- getwd()
  relative_root <- tempfile("value-summary-relative-root-")
  dir.create(relative_root)
  on.exit(
    {
      setwd(old_wd)
      if (is.null(old_module_dirs)) {
        rm("MODULE_DIRS", envir = .GlobalEnv)
      } else {
        assign("MODULE_DIRS", old_module_dirs, envir = .GlobalEnv)
      }
    },
    add = TRUE
  )
  setwd(relative_root)
  assign(
    "MODULE_DIRS",
    data.frame(local_dir = "outputLocal/dataprocessor", global_dir = "outputGlobal/dataprocessor"),
    envir = .GlobalEnv
  )

  value_summaries <- list(
    observation = data.table::data.table(
      COLUMN_NAME = "obs_code_code",
      DATA_TYPE = "character varying",
      VALUE_TYPE = "text",
      DISTINCT_VALUES = 2L,
      VALUE_COUNTS = "'AMB': 20",
      MIN = NA_character_,
      MAX = NA_character_,
      AVG = NA_character_,
      MEDIAN = NA_character_,
      Q1 = NA_character_,
      Q3 = NA_character_,
      SE = NA_real_,
      EMPTY = 0L,
      check.names = FALSE
    )
  )

  file_name <- writeValueSummaryArchive(
    value_summaries,
    "Database_Quality_Analysis_Test",
    timestamp = as.POSIXct("2026-06-19 08:00:02", tz = "UTC")
  )

  expect_true(file.exists(file_name))
  expect_true(grepl(normalizePath(relative_root, mustWork = TRUE), file_name, fixed = TRUE))
  expect_equal(utils::unzip(file_name, list = TRUE)$Name, "FHIR/observation.csv")
})
