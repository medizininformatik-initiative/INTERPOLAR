test_that("database quality analysis metadata is normalized from view columns", {
  config <- list(
    view_prefix = "v_",
    view_postfix = "_last_version",
    included_view_patterns = c("^v_[a-z0-9_]+_last_version$"),
    excluded_view_patterns = "_raw_",
    additional_views = "v_pids_per_ward",
    technical_columns = c("input_datetime", "last_version_date", "id"),
    grouping_overrides = parseDatabaseQualityAnalysisGroupingOverrides(character()),
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

  result <- normalizeDatabaseQualityAnalysisMetadata(metadata, config)

  expect_equal(result$TABLE_NAME, c("observation", "pids_per_ward"))
  expect_equal(result$TABLE_FAMILY, c("FHIR", "Other"))
  expect_equal(result$COLUMN_NAME, c("obs_id", "patient_id"))
  expect_equal(result$COLUMN_DESCRIPTION[[1]], "id")
})

test_that("database quality analysis column descriptions remove only trailing type suffixes", {
  result <- normalizeDatabaseQualityAnalysisColumnDescription(c(
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
  result <- parseDatabaseQualityAnalysisGroupingOverrides(c(
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
    getDatabaseQualityAnalysisConfig(envir = envir, command_arguments = arguments)
  })

  expect_true(all(vapply(results, function(result) {
    isFALSE(result$include_value_datetime_columns)
  }, logical(1))))
})

test_that("database quality analysis grouping columns are inferred by convention", {
  config <- list(grouping_overrides = parseDatabaseQualityAnalysisGroupingOverrides(character()))
  table_metadata <- data.table::data.table(
    TABLE_NAME = "observation",
    COLUMN_NAME = c(
      "obs_id",
      "obs_patient_ref",
      "obs_encounter_calculated_ref",
      "obs_value"
    )
  )

  result <- inferDatabaseQualityAnalysisGroupingColumns(table_metadata, config)

  expect_equal(result[["resource_id"]], "obs_id")
  expect_equal(result[["pid"]], "obs_patient_ref")
  expect_equal(result[["case_id"]], "obs_encounter_calculated_ref")
})

test_that("database quality analysis count query uses non-empty values and quoted identifiers", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    COLUMN_NAME = c("obs_id", "obs_patient_ref", "obs_value"),
    DATA_TYPE = c("character varying", "character varying", "character varying")
  )
  grouping_columns <- c(resource_id = "obs_id", pid = "obs_patient_ref", case_id = NA_character_)

  result <- buildDatabaseQualityAnalysisCountQuery(
    table_metadata,
    grouping_columns,
    data_columns = c("obs_value")
  )

  expect_match(result$query, '"obs_value" IS NOT NULL', fixed = TRUE)
  expect_match(result$query, '"obs_value"::text <> \'\'', fixed = TRUE)
  expect_match(result$query, 'FROM "db2dataprocessor_out"."v_observation_last_version"', fixed = TRUE)
  expect_equal(result$alias_map$count_column, c("count per resource_id", "count per PID"))
})

test_that("database quality analysis count query avoids text casts for non-text columns", {
  table_metadata <- data.table::data.table(
    VIEW_SCHEMA = "db2dataprocessor_out",
    VIEW_NAME = "v_observation_last_version",
    COLUMN_NAME = c("obs_id", "obs_value_quantity", "obs_effective_datetime"),
    DATA_TYPE = c("character varying", "double precision", "timestamp without time zone")
  )
  grouping_columns <- c(resource_id = "obs_id", pid = NA_character_, case_id = NA_character_)

  result <- buildDatabaseQualityAnalysisCountQuery(
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

test_that("database quality analysis counts are mapped back to normalized result rows", {
  config <- list(
    count_batch_size = 100,
    grouping_overrides = parseDatabaseQualityAnalysisGroupingOverrides(character()),
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

  result <- calculateDatabaseQualityAnalysisCounts(metadata, config, query_fun = query_fun)

  expect_equal(names(result)[1:9], c(
    "TABLE_NAME",
    "COLUMN_NAME",
    "COLUMN_DESCRIPTION",
    "USED_AS_GROUPING_FOR",
    "count per resource_id",
    "count per PID",
    "count per Fall-Id",
    "first value import datetime",
    "last value import datetime"
  ))
  expect_equal(names(result)[10:11], c(
    "first value meta last updated",
    "last value meta last updated"
  ))
  expect_equal(result[COLUMN_NAME == "obs_id", USED_AS_GROUPING_FOR], "count per resource_id")
  expect_equal(result[COLUMN_NAME == "obs_patient_ref", USED_AS_GROUPING_FOR], "count per PID")
  expect_true(all(is.na(result[["count per Fall-Id"]])))
  expect_equal(result[COLUMN_NAME == "obs_value", "count per resource_id"][[1]], 5L)
})

test_that("database quality analysis counts can skip value datetime columns", {
  config <- list(
    count_batch_size = 100,
    grouping_overrides = parseDatabaseQualityAnalysisGroupingOverrides(character()),
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

  result <- calculateDatabaseQualityAnalysisCounts(
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

  result <- buildDatabaseQualityAnalysisValueDateRangeQuery(
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
    grouping_overrides = parseDatabaseQualityAnalysisGroupingOverrides(c("patient_fe|pat_id|record_id|"))
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

  sheet <- createDatabaseQualityAnalysisMetadataSheet(
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
    TABLE_FAMILY = "FHIR",
    ORDINAL_POSITION = 1L,
    check.names = FALSE
  )

  sheets <- splitDatabaseQualityAnalysisResultForExcel(result)

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

  sheets <- splitDatabaseQualityAnalysisResultForExcel(result)

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

  sheets <- splitDatabaseQualityAnalysisResultForExcel(result)

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

  formatted_sheet <- formatDatabaseQualityAnalysisSheetForExcel(sheet)

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

  file_name <- writeDatabaseQualityAnalysisExcelFile(
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
