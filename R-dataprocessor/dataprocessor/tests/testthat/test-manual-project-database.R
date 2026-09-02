test_that("manual project names use the existing command convention", {
  project_dirs <- file.path(
    "/manual_start",
    c("Database_Quality_Analysis", "Statistical_Reports", "WP8_export")
  )

  expect_equal(
    getCalledManualStartSubmoduleDirs(
      "statistical-reports",
      project_dirs
    ),
    project_dirs[[2]]
  )
  expect_length(
    getCalledManualStartSubmoduleDirs(
      c("--force", "start-date=2026-01-01"),
      project_dirs
    ),
    0L
  )
})

test_that("unknown manual project arguments fail instead of starting regular processing", {
  project_dirs <- file.path(
    "/manual_start",
    c("Database_Quality_Analysis", "WP8_export")
  )

  expect_error(
    validateManualStartInvocation("wp8-expotr", project_dirs),
    paste0(
      "Unknown manual Data Processor project argument: wp8-expotr.*",
      "Available projects: database-quality-analysis, wp8-export"
    )
  )
  expect_error(
    validateManualStartInvocation("--force", project_dirs),
    "--force is only valid"
  )
})

test_that("manual projects require database.toml", {
  project_dir <- file.path(tempdir(), "WP8_export")
  dir.create(project_dir, showWarnings = FALSE)

  expect_error(
    configureManualStartDatabase(
      config = list(PATH_TO_DB_CONFIG_TOML = "unused.toml"),
      command_line_args = "wp8-export",
      manual_start_submodule_dirs = project_dir
    ),
    "require a database.toml file"
  )
})

test_that("automatic processing does not require a project database config", {
  project_dir <- file.path(tempdir(), "WP8_export")

  expect_null(configureManualStartDatabase(
    config = list(PATH_TO_DB_CONFIG_TOML = "unused.toml"),
    command_line_args = "start-date=2026-01-01",
    manual_start_submodule_dirs = project_dir
  ))
})

test_that("project database selection precedes module startup", {
  calls <- character()
  config <- list(PATH_TO_DB_CONFIG_TOML = "base.toml")
  testthat::local_mocked_bindings(
    init = function(validate_config) {
      calls <<- c(calls, "init")
      expect_true(validate_config)
      config
    },
    configureManualStartDatabase = function(module_config, command_line_args) {
      calls <<- c(calls, "database")
      expect_equal(module_config, config)
      expect_equal(command_line_args, "statistical-reports")
    },
    .package = "dataprocessor"
  )
  testthat::local_mocked_bindings(
    startModule = function(module_config) {
      calls <<- c(calls, "start")
      expect_equal(module_config, config)
    },
    .package = "etlutils"
  )

  result <- startDataprocessorModule(
    validate_config = TRUE,
    command_line_args = "statistical-reports"
  )

  expect_equal(calls, c("init", "database", "start"))
  expect_equal(result, config)
})

test_that("manual projects inherit the normal connection and select DB_NAME", {
  test_dir <- file.path(tempdir(), "manual-project-config")
  project_dir <- file.path(test_dir, "WP8_export")
  dir.create(project_dir, recursive = TRUE, showWarnings = FALSE)
  base_config_path <- file.path(test_dir, "cds_hub_db_config.toml")
  project_config_path <- file.path(project_dir, "database.toml")
  writeLines(c(
    "DB_NAME = \"cds_hub_db\"",
    "DB_HOST = \"cds_hub\"",
    "DB_PORT = 5432",
    "DB_DATAPROCESSOR_USER = \"dataprocessor\"",
    "DB_DATAPROCESSOR_PASSWORD = \"password\"",
    "DB_DATAPROCESSOR_SCHEMA_IN = \"db2dataprocessor_in\"",
    "DB_DATAPROCESSOR_SCHEMA_OUT = \"db2dataprocessor_out\""
  ), base_config_path)
  writeLines("DB_NAME = \"ip_snapshot_pseud\"", project_config_path)
  effective_config <- list(
    DB_NAME = "ip_snapshot_pseud",
    DB_HOST = "cds_hub",
    DB_PORT = 5432,
    DB_DATAPROCESSOR_USER = "dataprocessor",
    DB_DATAPROCESSOR_PASSWORD = "password",
    DB_DATAPROCESSOR_SCHEMA_IN = "db2dataprocessor_in",
    DB_DATAPROCESSOR_SCHEMA_OUT = "db2dataprocessor_out"
  )
  selected_config <- NULL
  testthat::local_mocked_bindings(
    readManualStartDatabaseConfig = function(actual_base_path, actual_project_path) {
      expect_equal(actual_base_path, base_config_path)
      expect_equal(actual_project_path, project_config_path)
      effective_config
    },
    setManualStartDatabaseContext = function(db_config) {
      selected_config <<- db_config
    },
    validateManualStartDatabaseConnection = function(db_config, project_name) {
      expect_equal(db_config$DB_NAME, "ip_snapshot_pseud")
      expect_equal(project_name, "WP8_export")
    },
    getManualStartDatabaseContentType = function() "pseudonymized_snapshot",
    .package = "dataprocessor"
  )

  result <- configureManualStartDatabase(
    config = list(PATH_TO_DB_CONFIG_TOML = base_config_path),
    command_line_args = "wp8-export",
    manual_start_submodule_dirs = project_dir
  )

  expect_equal(result$DB_NAME, "ip_snapshot_pseud")
  expect_equal(result$DB_HOST, "cds_hub")
  expect_equal(result$DB_DATAPROCESSOR_USER, "dataprocessor")
  expect_equal(selected_config, result)
})

test_that("non-pseudonymized databases require an explicit force flag for manual projects", {
  test_dir <- file.path(tempdir(), "manual-project-force")
  project_dir <- file.path(test_dir, "MRP_Check")
  dir.create(project_dir, recursive = TRUE, showWarnings = FALSE)
  base_config_path <- file.path(test_dir, "cds_hub_db_config.toml")
  writeLines(c(
    "DB_NAME = \"cds_hub_db\"",
    "DB_HOST = \"cds_hub\"",
    "DB_PORT = 5432",
    "DB_DATAPROCESSOR_USER = \"dataprocessor\"",
    "DB_DATAPROCESSOR_PASSWORD = \"password\"",
    "DB_DATAPROCESSOR_SCHEMA_IN = \"db2dataprocessor_in\"",
    "DB_DATAPROCESSOR_SCHEMA_OUT = \"db2dataprocessor_out\""
  ), base_config_path)
  writeLines(
    "DB_NAME = \"ip_snapshot\"",
    file.path(project_dir, "database.toml")
  )
  context_calls <- 0L
  effective_config <- list(
    DB_NAME = "ip_snapshot",
    DB_HOST = "cds_hub",
    DB_PORT = 5432,
    DB_DATAPROCESSOR_USER = "dataprocessor",
    DB_DATAPROCESSOR_PASSWORD = "password",
    DB_DATAPROCESSOR_SCHEMA_IN = "db2dataprocessor_in",
    DB_DATAPROCESSOR_SCHEMA_OUT = "db2dataprocessor_out"
  )
  testthat::local_mocked_bindings(
    readManualStartDatabaseConfig = function(...) effective_config,
    setManualStartDatabaseContext = function(...) {
      context_calls <<- context_calls + 1L
    },
    validateManualStartDatabaseConnection = function(...) NULL,
    getManualStartDatabaseContentType = function() NA_character_,
    .package = "dataprocessor"
  )

  expect_error(
    configureManualStartDatabase(
      config = list(PATH_TO_DB_CONFIG_TOML = base_config_path),
      command_line_args = "mrp-check",
      manual_start_submodule_dirs = project_dir
    ),
    "must run on a pseudonymized snapshot database by default"
  )
  expect_equal(context_calls, 1L)

  result <- configureManualStartDatabase(
    config = list(PATH_TO_DB_CONFIG_TOML = base_config_path),
    command_line_args = c("mrp-check", "--force"),
    manual_start_submodule_dirs = project_dir
  )
  expect_equal(result$DB_NAME, "ip_snapshot")
  expect_equal(context_calls, 2L)
})

test_that("manual database configuration reports missing inherited values", {
  expect_error(
    validateManualStartDatabaseConfig(
      list(DB_NAME = "snapshot", DB_HOST = "", DB_PORT = 5432),
      "WP8_export"
    ),
    paste0(
      "effective database configuration.*Missing or empty parameters: ",
      "DB_HOST, DB_DATAPROCESSOR_USER, DB_DATAPROCESSOR_PASSWORD, ",
      "DB_DATAPROCESSOR_SCHEMA_IN, DB_DATAPROCESSOR_SCHEMA_OUT"
    )
  )
})

test_that("manual database configuration validates the port", {
  db_config <- list(
    DB_NAME = "snapshot",
    DB_HOST = "database-host",
    DB_PORT = 70000,
    DB_DATAPROCESSOR_USER = "dataprocessor",
    DB_DATAPROCESSOR_PASSWORD = "password",
    DB_DATAPROCESSOR_SCHEMA_IN = "db2dataprocessor_in",
    DB_DATAPROCESSOR_SCHEMA_OUT = "db2dataprocessor_out"
  )

  expect_error(
    validateManualStartDatabaseConfig(db_config, "WP8_export"),
    "DB_PORT.*between 1 and 65535.*70000"
  )

  db_config$DB_PORT <- 5432.5
  expect_error(
    validateManualStartDatabaseConfig(db_config, "WP8_export"),
    "DB_PORT.*between 1 and 65535.*5432.5"
  )
})

test_that("manual database preflight validates the selected database", {
  db_config <- list(
    DB_NAME = "snapshot",
    DB_HOST = "database-host",
    DB_PORT = 5432,
    DB_DATAPROCESSOR_USER = "dataprocessor",
    DB_DATAPROCESSOR_SCHEMA_OUT = "db2dataprocessor_out"
  )
  connection_details <- data.table::data.table(
    database_name = "snapshot",
    database_user = "dataprocessor",
    output_schema = "db2dataprocessor_out",
    has_version_view = TRUE,
    can_read_version_view = TRUE
  )
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(query, lock_id) {
      expect_match(query, "current_database", fixed = TRUE)
      expect_match(query, "v_db_parameter", fixed = TRUE)
      expect_null(lock_id)
      connection_details
    },
    .package = "etlutils"
  )

  expect_equal(
    validateManualStartDatabaseConnection(db_config, "WP8_export"),
    connection_details
  )

  connection_details$output_schema <- NA_character_
  expect_error(
    validateManualStartDatabaseConnection(db_config, "WP8_export"),
    "does not provide the configured Data Processor output schema"
  )

  connection_details$output_schema <- "db2dataprocessor_out"
  connection_details$database_user <- "unexpected_user"
  expect_error(
    validateManualStartDatabaseConnection(db_config, "WP8_export"),
    "connected as database user 'unexpected_user'.*configured.*'dataprocessor'"
  )

  connection_details$database_user <- "dataprocessor"
  connection_details$has_version_view <- FALSE
  expect_error(
    validateManualStartDatabaseConnection(db_config, "WP8_export"),
    "required view 'db2dataprocessor_out.v_db_parameter' is missing"
  )

  connection_details$has_version_view <- TRUE
  connection_details$can_read_version_view <- FALSE
  expect_error(
    validateManualStartDatabaseConnection(db_config, "WP8_export"),
    "cannot read required view.*Check the user's database permissions"
  )
})

test_that("manual database content type is read from v_db_parameter", {
  content_type <- data.table::data.table(parameter_value = "pseudonymized_snapshot")
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(query, lock_id) {
      expect_match(query, "v_db_parameter", fixed = TRUE)
      expect_match(query, "database_content_type", fixed = TRUE)
      expect_null(lock_id)
      content_type
    },
    .package = "etlutils"
  )

  expect_equal(getManualStartDatabaseContentType(), "pseudonymized_snapshot")

  content_type <- data.table::data.table(parameter_value = character())
  expect_true(is.na(getManualStartDatabaseContentType()))

  content_type <- data.table::data.table(parameter_value = c("a", "b"))
  expect_error(getManualStartDatabaseContentType(), "multiple database_content_type rows")
})

test_that("manual database connection errors include project and connection context", {
  db_config <- list(
    DB_NAME = "missing_snapshot",
    DB_HOST = "database-host",
    DB_PORT = 5432,
    DB_DATAPROCESSOR_USER = "dataprocessor"
  )
  testthat::local_mocked_bindings(
    dbGetReadOnlyQuery = function(...) {
      stop(paste0(
        "Database call failed permanently after 8 attempts.\n",
        "Last error:\nFATAL: database missing_snapshot does not exist\n",
        "SQL:\nSELECT current_database()"
      ))
    },
    .package = "etlutils"
  )

  expect_error(
    validateManualStartDatabaseConnection(db_config, "WP8_export"),
    paste0(
      "project 'WP8_export' cannot connect to selected database ",
      "'missing_snapshot'.*database-host:5432.*user 'dataprocessor'.*",
      "database name is not available on the selected server.*",
      "Database error: FATAL: database missing_snapshot does not exist"
    )
  )
  expect_equal(
    getManualStartDatabaseError(simpleError(paste0(
      "Database call failed permanently after 8 attempts.\n",
      "Last error:\nFATAL: database missing_snapshot does not exist\n",
      "SQL:\nSELECT current_database()"
    ))),
    "FATAL: database missing_snapshot does not exist"
  )
})

test_that("one invocation cannot select multiple manual projects", {
  project_dirs <- file.path(
    tempdir(),
    c("Database_Quality_Analysis", "WP8_export")
  )

  expect_error(
    configureManualStartDatabase(
      config = list(PATH_TO_DB_CONFIG_TOML = "unused.toml"),
      command_line_args = c("database-quality-analysis", "wp8-export"),
      manual_start_submodule_dirs = project_dirs
    ),
    "Start exactly one manual Data Processor project"
  )
})
