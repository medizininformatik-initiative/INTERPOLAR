withEnvvar <- function(new, code) {
  old <- Sys.getenv(names(new), unset = NA_character_)
  on.exit(
    {
      for (name in names(new)) {
        if (is.na(old[[name]])) {
          Sys.unsetenv(name)
        } else {
          Sys.setenv(stats::setNames(old[[name]], name))
        }
      }
    },
    add = TRUE
  )
  do.call(Sys.setenv, as.list(new))
  force(code)
}

findTestProjectRoot <- function(start_dir = getwd()) {
  current_dir <- normalizePath(start_dir, mustWork = TRUE)
  marker <- file.path("Postgres-cds_hub", "sql", "template", "User_Schema_Rights_Definition.xlsx")
  repeat {
    if (file.exists(file.path(current_dir, marker))) {
      return(current_dir)
    }
    parent_dir <- dirname(current_dir)
    if (identical(parent_dir, current_dir)) {
      return(NA_character_)
    }
    current_dir <- parent_dir
  }
}

test_that("parseIFExpression supports multiline quoted results with nested placeholders", {
  expression <- paste0(
    "<%IF NOT TABLE_DESCRIPTION:TAGS \"pattern\" \"",
    "SELECT <%TABLE_NAME%>\n",
    "FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%>\n",
    "WHERE <%COLUMN_NAME%> IS NOT NULL",
    "\"%>"
  )

  result <- parseIFExpression(expression)

  expect_identical(result$source, "TABLE_DESCRIPTION")
  expect_identical(result$field, "TAGS")
  expect_true(result$invert)
  expect_identical(result$pattern, "pattern")
  expect_match(result$result, "SELECT <%TABLE_NAME%>", fixed = TRUE)
  expect_match(result$result, "WHERE <%COLUMN_NAME%> IS NOT NULL", fixed = TRUE)
})

test_that("parseIFExpression supports subtemplate results", {
  expression <- '<%IF NOT TABLE_DESCRIPTION:TABLE_NAME "^patient$" SUB_LOOP_TABS_SUB_adding_historical_records%>'

  result <- parseIFExpression(expression)

  expect_identical(result$source, "TABLE_DESCRIPTION")
  expect_identical(result$field, "TABLE_NAME")
  expect_true(result$invert)
  expect_identical(result$pattern, "^patient$")
  expect_identical(result$result, "SUB_LOOP_TABS_SUB_adding_historical_records")
})

test_that("convertTemplate expands multiline IF results with nested placeholders", {
  tables <- list(
    patient = data.table::data.table(
      TABLE_NAME = "patient",
      COLUMN_NAME = "pat_id",
      COLUMN_DESCRIPTION = "id",
      COLUMN_TYPE = "varchar",
      TAGS = "keep"
    )
  )
  rights <- data.table::data.table(
    SCRIPTNAME = "test.sql",
    TEMPLATE = "test",
    OWNER_SCHEMA = "db",
    OWNER_USER = "db_user",
    TAGS = "",
    TABLE_PREFIX = "",
    TABLE_POSTFIX = "",
    RIGHTS = "SELECT",
    GRANT_TARGET_USER = "db_user"
  )
  template <- paste0(
    "<%IF TABLE_DESCRIPTION:TAGS \"keep\" \"",
    "SELECT <%TABLE_NAME%>\n",
    "FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%>",
    "\"%>"
  )

  result <- convertTemplate(
    tables,
    rights,
    template_content = template,
    table_name = "patient",
    column_prefix = "pat",
    loop_row = 1,
    recursion = 1
  )

  expect_identical(result, "SELECT patient\nFROM db.patient")
})

test_that("convertTemplate removes multiline IF blocks when condition is false", {
  tables <- list(
    patient = data.table::data.table(
      TABLE_NAME = "patient",
      COLUMN_NAME = "pat_id",
      COLUMN_DESCRIPTION = "id",
      COLUMN_TYPE = "varchar",
      TAGS = "skip"
    )
  )
  rights <- data.table::data.table(
    SCRIPTNAME = "test.sql",
    TEMPLATE = "test",
    OWNER_SCHEMA = "db",
    OWNER_USER = "db_user",
    TAGS = "",
    TABLE_PREFIX = "",
    TABLE_POSTFIX = "",
    RIGHTS = "SELECT",
    GRANT_TARGET_USER = "db_user"
  )
  template <- paste0(
    "before\n",
    "<%IF TABLE_DESCRIPTION:TAGS \"keep\" \"",
    "SELECT <%TABLE_NAME%>\n",
    "FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%>",
    "\"%>\n",
    "after"
  )

  result <- convertTemplate(
    tables,
    rights,
    template_content = template,
    table_name = "patient",
    column_prefix = "pat",
    loop_row = 1,
    recursion = 1
  )

  expect_identical(result, "before\nafter")
})

test_that("convertTemplate normalizes multiline table values before replacement", {
  tables <- list(
    medikationsanalyse = data.table::data.table(
      TABLE_NAME = "medikationsanalyse",
      COLUMN_NAME = "fall_meda_id",
      COLUMN_DESCRIPTION = paste(
        "Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu Fall",
        "(Fall-ID Encounter-Identifier (KIS))",
        sep = "\n"
      ),
      COLUMN_TYPE = "varchar",
      TAGS = ""
    )
  )
  rights <- data.table::data.table(
    SCRIPTNAME = "test.sql",
    TEMPLATE = "test",
    OWNER_SCHEMA = "db2dataprocessor_in",
    OWNER_USER = "db_user",
    TAGS = "",
    TABLE_PREFIX = "",
    TABLE_POSTFIX = "_fe",
    RIGHTS = "SELECT",
    GRANT_TARGET_USER = "db_user"
  )
  template <- "<%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES_HASH%>"

  result <- convertTemplate(
    tables,
    rights,
    template_content = template,
    table_name = "medikationsanalyse",
    column_prefix = "meda",
    loop_row = 1,
    recursion = 1
  )

  expect_no_match(result, "\n\\(Fall-ID Encounter-Identifier", perl = TRUE)
  expect_no_match(result, "Dynamische SQL-Abfrage", fixed = TRUE)
  expect_match(result, "COALESCE(db.to_char_immutable(fall_meda_id), '#NULL#')", fixed = TRUE)
})

test_that("convertTemplate permits missing column descriptions", {
  tables <- list(
    retrolektive_mrpbewertung = data.table::data.table(
      TABLE_NAME = "retrolektive_mrpbewertung",
      COLUMN_NAME = "ret_bewerter3",
      COLUMN_DESCRIPTION = NA_character_,
      COLUMN_TYPE = "varchar",
      TAGS = ""
    )
  )
  rights <- data.table::data.table(
    SCRIPTNAME = "test.sql",
    TEMPLATE = "test",
    OWNER_SCHEMA = "db_log",
    OWNER_USER = "db_user",
    TAGS = "",
    TABLE_PREFIX = "",
    TABLE_POSTFIX = "",
    RIGHTS = "SELECT",
    GRANT_TARGET_USER = "db_user"
  )

  result <- convertTemplate(
    tables,
    rights,
    template_content = "<%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_COMMENTS%>",
    table_name = "retrolektive_mrpbewertung",
    column_prefix = "ret",
    loop_row = 1,
    recursion = 1
  )

  expect_identical(
    result,
    "COMMENT ON COLUMN db_log.retrolektive_mrpbewertung.ret_bewerter3 IS ' (varchar)';"
  )
})

test_that("create table column templates do not inline free-text descriptions", {
  tables <- list(
    medikationsanalyse = data.table::data.table(
      TABLE_NAME = "medikationsanalyse",
      COLUMN_NAME = "fall_meda_id",
      COLUMN_DESCRIPTION = paste(
        "Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu Fall",
        "(Fall-ID Encounter-Identifier (KIS))",
        sep = "\n"
      ),
      COLUMN_TYPE = "varchar",
      TAGS = ""
    )
  )
  rights <- data.table::data.table(
    SCRIPTNAME = "test.sql",
    TEMPLATE = "test",
    OWNER_SCHEMA = "db2dataprocessor_in",
    OWNER_USER = "db_user",
    TAGS = "",
    TABLE_PREFIX = "",
    TABLE_POSTFIX = "_fe",
    RIGHTS = "SELECT",
    GRANT_TARGET_USER = "db_user"
  )
  template <- "<%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES%>"

  result <- convertTemplate(
    tables,
    rights,
    template_content = template,
    table_name = "medikationsanalyse",
    column_prefix = "meda",
    loop_row = 1,
    recursion = 1
  )

  expect_no_match(result, "Dynamische SQL-Abfrage", fixed = TRUE)
  expect_match(
    result,
    "ALTER TABLE db2dataprocessor_in.medikationsanalyse_fe ADD fall_meda_id varchar;",
    fixed = TRUE
  )
  expect_match(result, "-- column (fall_meda_id)", fixed = TRUE)
})

test_that("isContentChanged ignores volatile generated header lines", {
  existing_file <- tempfile(fileext = ".sql")
  writeLines(
    c(
      "-- This file is generated",
      "-- Rights definition file             : Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx",
      "-- Rights definition file last update : 2026-06-12 09:00:00",
      "-- Rights definition file size        : 12345 Byte",
      "-- Create time: 2026-06-12 09:00:01",
      "SELECT 1;"
    ),
    existing_file
  )

  new_content <- paste(
    c(
      "-- This file is generated",
      "-- Rights definition file             : Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx",
      "-- Rights definition file last update : 2026-06-12 10:00:00",
      "-- Rights definition file size        : 12399 Byte",
      "-- Create time: 2026-06-12 10:00:01",
      "SELECT 1;"
    ),
    collapse = "\n"
  )

  expect_false(isContentChanged(existing_file, new_content))
})

test_that("isContentChanged treats blank line formatting as content", {
  existing_file <- tempfile(fileext = ".sql")
  writeLines(c("SELECT 1;", "", "SELECT 2;"), existing_file)

  new_content <- paste(c("SELECT 1;", "SELECT 2;"), collapse = "\n")

  expect_true(isContentChanged(existing_file, new_content))
})

test_that("database script generation writes all scripts defined in the rights matrix", {
  testthat::skip_if_not(
    identical(tolower(Sys.getenv("RUN_DB_SQL_GOLDEN_TESTS", unset = "false")), "true"),
    "Set RUN_DB_SQL_GOLDEN_TESTS=true to run the full SQL generator test."
  )

  project_root <- findTestProjectRoot()
  testthat::skip_if(is.na(project_root), "INTERPOLAR project root not available")

  source_sql_dir <- file.path(project_root, "Postgres-cds_hub", "sql")
  temp_sql_dir <- file.path(tempdir(), "generated-sql")
  dir.create(temp_sql_dir, recursive = TRUE, showWarnings = FALSE)

  expected_files <- withEnvvar(
    c(
      INTERPOLAR_PROJECT_ROOT = project_root,
      INTERPOLAR_DB_SQL_SOURCE_DIR = source_sql_dir,
      INTERPOLAR_DB_SQL_TARGET_DIR = temp_sql_dir
    ),
    {
      rights_definition <- loadDatabaseRightsAndConvertDefinition()$rights_definition
      unique(unlist(lapply(rights_definition, function(script_definitions) {
        unlist(lapply(script_definitions, function(script_rights_definition) {
          copy_func_scriptname <- if (!is.na(script_rights_definition[1]$COPY_FUNC_TEMPLATE)) {
            script_rights_definition[1]$COPY_FUNC_SCRIPTNAME
          } else {
            NA_character_
          }
          c(
            script_rights_definition[1]$SCRIPTNAME,
            copy_func_scriptname
          )
        }))
      })))
    }
  )
  expected_files <- sort(expected_files[!is.na(expected_files) & nzchar(expected_files)])

  withEnvvar(
    c(
      INTERPOLAR_PROJECT_ROOT = project_root,
      INTERPOLAR_DB_SQL_SOURCE_DIR = source_sql_dir,
      INTERPOLAR_DB_SQL_TARGET_DIR = temp_sql_dir
    ),
    {
      capture.output(createDatabaseScriptsFromTemplates())
    }
  )

  temp_relative_files <- sort(list.files(temp_sql_dir, pattern = "\\.sql$", recursive = TRUE))

  expect_setequal(temp_relative_files, expected_files)

  for (relative_file in temp_relative_files) {
    actual_file <- file.path(temp_sql_dir, relative_file)
    expect_false(
      any(grepl("<%.*%>", readLines(actual_file, warn = FALSE))),
      info = paste("Unreplaced placeholder in", relative_file)
    )
  }
})
