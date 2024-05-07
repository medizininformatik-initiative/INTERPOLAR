
getFullTableName <- function(table_name, table_name_suffix = "") {
  if (nchar(table_name_suffix)) {
    paste0(table_name, "_", table_name_suffix)
  } else {
    table_name
  }
}

getTableStatmentEndRows <- function() {
  end_rows <- ''
  end_rows <- paste0(end_rows, "  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted\n")
  end_rows <- paste0(end_rows, "  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked\n")
  end_rows <- paste0(end_rows, "  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record\n")
  end_rows <- paste0(end_rows, ");\n\n")
}

getCreateTableStatementColumnLine <- function(table_description_row, table_name_suffix= "") {
  fhir_expression <- table_description_row$fhir_expression
  column_type <- NA
  # in the raw table all types are varchar
  if (table_name_suffix != "raw") {
    # map from fhir type to Postgres type
    fhir_column_type <- table_description_row$type
    if (fhir_column_type %in% "integer") {
      column_type <- "int"
    } else if (fhir_column_type %in% "decimal") {
      column_type <- "numeric"
    } else if (fhir_column_type %in% "boolean") {
      column_type <- "boolean"
    } else if (fhir_column_type %in% "datetime") {
      column_type <- "timestamp"
    } else if (fhir_column_type %in% "date") {
      column_type <- "date"
    } else if (fhir_column_type %in% "time") {
      column_type <- "time"
    }
  }
  column_type_with_length <- column_type
  single_length <- as.integer(table_description_row$single_length)
  # the count is needed only in the raw table
  count <- as.integer(table_description_row$count)
  # an empty count in the defnition means 1
  if (is.na(count)) count <- 1
  full_length <- single_length
  # only the raw tables have list values in the same row (it's before the fhir_melt()
  # step to split multiple values in single rows)
  if (table_name_suffix == "raw") {
    full_length  <- full_length * count
  }
  # if there is no type information -> set varchar = string
  if (is.na(column_type)) {
    column_type <- "varchar"
  }
  # only for string/varchar and numeric values add the column width
  if (column_type %in% "varchar") {
    column_type_with_length <- paste0(column_type, " (", full_length, ")")
  } else if (column_type %in% "numeric") {
    # decimal/numeric needs a length for the places before and after the decimal point -> set same
    # value before and after decimal point
    column_type_with_length <- paste0(column_type, " (", full_length, ", ", full_length, ")")
  }
  column_line <- paste0(table_description_row$column_name, " ", column_type_with_length, ",   -- ", fhir_expression, " (", single_length, " x ", count, " ", column_type, ")\n")
  return(column_line)
}

createTableStatements <- function(table_description, schema_name, table_name_suffix= "") {
  statements <- ''
  last_table_name <- NA
  for (row in 1:nrow(table_description)) {
    table_name <- table_description$resource[row]
    if (!is.na(table_name)) {
      if (!is.na(last_table_name)) {
        statements <- paste0(statements, getTableStatmentEndRows())
      }
      last_table_name <- table_name
      full_table_name <- getFullTableName(table_name, table_name_suffix)
      statements <- paste0(statements, "CREATE TABLE IF NOT EXISTS ", schema_name, ".", full_table_name, " (\n")
      statements <- paste0(statements, "  ", full_table_name, "_id serial PRIMARY KEY not null, -- Primary key of the entity\n")
    }
    table_description_row <- table_description[row]
    if (!all(is.na(table_description_row))) {
      statements <- paste0(statements, getCreateTableStatementColumnLine(table_description_row, table_name_suffix))
    }

  }
  statements <- paste0(statements, getTableStatmentEndRows())
}


getContentFromFile <- function(file_path) {
  # read the content of the file
  content <- readLines(file_path)
  # append all single line strings to one large string
  content <- paste0(content, collapse = '\n')
}


getGrantStatements <- function(table_names, schema_name, table_name_suffix = "") {
  grant_statements <- ''
  for (table_name in table_names) {
    full_table_name <- getFullTableName(table_name, table_name_suffix)
    # load grant template
    grant <- getContentFromFile('./Postgres-cds_hub/init/template/sub_template_grant.sql')
    # replace placeholders in grant template
    grant <- gsub('<%GRANT_SCHEMA_NAME%>', schema_name, grant)
    grant <- gsub('<%GRANT_TABLE_NAME%>', full_table_name, grant)
    #grant_statements <- paste0(grant_statements, grant, '\n\n\n')
    grant_statements <- paste0(grant_statements, grant, '\n\n')
  }
  return(grant_statements)
}


getCommentStatements <- function(table_description, schema_name, table_name_suffix = "") {
  comment <- ''
  table_name <- NA
  for (row in 1:nrow(table_description)) {
    if (!all(is.na(table_description[row]))) {
      new_table_name <- table_description$resource[row]
      if (!is.na(new_table_name)) {
        if (!is.na(table_name)) {
          comment <- paste0(comment, '\n')
        }
        table_name <- new_table_name
      }
      single_length <- as.integer(table_description$single_length[row])
      count <- as.integer(table_description$count[row])
      if (is.na(count)) count <- 1
      full_table_name <- getFullTableName(table_name, table_name_suffix)
      # generates something like this:
      # comment on column cds2db_in.condition.con_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (70 x 18 1260)';
      comment <- paste0(comment, "comment on column ", schema_name, ".", full_table_name, ".", table_description$column_name[row],
                        " is '", table_description$fhir_expression[row], " (", single_length, " x ", count, " ",
                        single_length * count, ")';\n")
    }
  }
  return(comment)
}


convert_create_tables_cds2db_in <- function(table_description, sql_filename, table_name_suffix = "") {
  table_description$resource <- tolower(table_description$resource)
  table_names <- na.omit(table_description$resource)
  # Load sql template
  content <- getContentFromFile(paste0("./Postgres-cds_hub/init/template/", sql_filename))

  # replace placeholder for create table statements for schema cds2db
  content <- gsub('<%CREATE_TABLE_STATEMENTS_CDS2DB_IN%>', createTableStatements(table_description, "cds2db_in", table_name_suffix), content)
  # # replace placeholder for grant statements for schema cds2db
  content <- gsub('<%GRANT_STATEMENTS_CDS2DB_IN%>', getGrantStatements(table_names, "cds2db_in", table_name_suffix), content)
  # replace placeholder for comment statements for schema cds2db
  content <- gsub('<%COMMENT_STATEMENTS_CDS2DB_IN%>', getCommentStatements(table_description, "cds2db_in", table_name_suffix), content)

  # Write the modified content to the file
  writeLines(content, paste0("./Postgres-cds_hub/init/", sql_filename), useBytes = TRUE)
}

createDatabaseScriptsFromTemplates <- function() {
  table_description <- etlutils::readExcelFileAsTableList('./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx')[['table_description']]
  convert_create_tables_cds2db_in(table_description, "10_cre_table_raw_cds2db_in.sql", "raw")
  convert_create_tables_cds2db_in(table_description, "16_cre_table_typ_cds2db_in.sql")

  # table_description$resource <- tolower(table_description$resource)
  # table_names <- na.omit(table_description$resource)
  #
  # # Load sql template
  # content <- getContentFromFile('./Postgres-cds_hub/init/template/init-db_template.sql')
  #
  # # replace placeholder for create table statements for schema cds2db
  # content <- gsub('<%CREATE_TABLE_STATEMENTS_CDS2DB_IN%>', createTableStatements(table_description, "cds2db_in"), content)
  #
  # # replace placeholder for grant statements for schema cds2db
  # content <- gsub('<%GRANT_STATEMENTS_CDS2DB_IN%>', getGrantStatements(table_names, "cds2db_in"), content)
  #
  # # replace placeholder for comment statements for schema cds2db
  # content <- gsub('<%COMMENT_STATEMENTS_CDS2DB_IN%>', getCommentStatements(table_description, "cds2db_in"), content)
  #
  # # replace placeholder for create table statements for schema db
  # content <- gsub('<%CREATE_TABLE_STATEMENTS_DB%>', createTableStatements(table_description, "db"), content)
  #
  # # replace placeholder for grant statements for schema db
  # content <- gsub('<%GRANT_STATEMENTS_DB%>', getGrantStatements(table_names, "db"), content)
  #
  # # replace placeholder for comment statements for schema db
  # content <- gsub('<%COMMENT_STATEMENTS_DB%>', getCommentStatements(table_description, "db"), content)
  #
  # # Write the modified content to the file
  # writeLines(content, './Postgres-cds_hub/init/init-db.sql', useBytes = TRUE)
}
