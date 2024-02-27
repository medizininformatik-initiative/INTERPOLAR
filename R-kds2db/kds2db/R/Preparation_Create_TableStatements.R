
getTableStatmentEndRows <- function() {
  end_rows <- ''
  end_rows <- paste0(end_rows, "  input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted\n")
  end_rows <- paste0(end_rows, "  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked\n")
  end_rows <- paste0(end_rows, "  current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record\n")
  end_rows <- paste0(end_rows, ");\n\n")
}


createTableStatements <- function(table_description, schema_name) {
  statements <- ''
  last_table_name <- NA
  for (row in 1:nrow(table_description)) {
    table_name <- table_description$table[row]
    if (!is.na(table_name)) {
      if (!is.na(last_table_name)) {
        statements <- paste0(statements, getTableStatmentEndRows())
      }
      last_table_name <- table_name
      statements <- paste0(statements, "CREATE TABLE IF NOT EXISTS ", schema_name, ".", table_name, " (\n")
      statements <- paste0(statements, "  ", table_name, "_id serial PRIMARY KEY not null, -- Primary key of the entity\n")
    }
    if (!all(is.na(table_description[row]))) {
      count <- as.integer(table_description$count[row])
      if (is.na(count)) count <- 1
      single_length <- as.integer(table_description$single_length[row])
      full_length <- single_length * count
      fhir_expression <- table_description$fhir_expression[row]
      statements <- paste0(statements, "  ", table_description$column_name[row], " varchar (", full_length, "),   -- ", fhir_expression, " (", single_length, " x ", count, " varchar)\n")
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


getGrantStatements <- function(table_names, schema_name) {
  grant_statements <- ''
  for (table_name in table_names) {
    # load grant template
    grant <- getContentFromFile('./Postgres-amts_db/init/template/init-db_template_sub_grant.sql')
    # replace placeholders in grant template
    grant <- gsub('<%GRANT_SCHEMA_NAME%>', schema_name, grant)
    grant <- gsub('<%GRANT_TABLE_NAME%>', table_name, grant)
    grant_statements <- paste0(grant_statements, grant, '\n\n\n')
  }
  return(grant_statements)
}


getCommentStatements <- function(table_description, schema_name) {
  comment <- ''
  table_name <- NA
  for (row in 1:nrow(table_description)) {
    if (!all(is.na(table_description[row]))) {
      new_table_name <- table_description$table[row]
      if (!is.na(new_table_name)) {
        if (!is.na(table_name)) {
          comment <- paste0(comment, '\n')
        }
        table_name <- new_table_name
      }
      single_length <- as.integer(table_description$single_length[row])
      count <- as.integer(table_description$count[row])
      if (is.na(count)) count <- 1
      # generates something like this:
      # comment on column kds2db_in.condition.con_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (70 x 18 1260)';
      comment <- paste0(comment, "comment on column ", schema_name, ".", table_name, ".", table_description$column_name[row],
                        " is '", table_description$fhir_expression[row], " (", single_length, " x ", count, " ",
                        single_length * count, ")';\n")
    }
  }
  return(comment)
}


replacePlaceholders <- function() {
  table_description <- etlutils::readExcelFileAsTableList('./R-kds2db/kds2db/inst/extdata/Table_Description.xlsx')[['table_description']]
  table_names <- na.omit(table_description$table)

  # Load sql template
  content <- getContentFromFile('./Postgres-amts_db/init/template/init-db_template.sql')

  # replace placeholder for create table statements for schema kds2db
  content <- gsub('<%CREATE_TABLE_STATEMENTS_KDS2DB_IN%>', createTableStatements(table_description, "kds2db_in"), content)

  # replace placeholder for grant statements for schema kds2db
  content <- gsub('<%GRANT_STATEMENTS_KDS2DB_IN%>', getGrantStatements(table_names, "kds2db_in"), content)

  # replace placeholder for comment statements for schema kds2db
  content <- gsub('<%COMMENT_STATEMENTS_KDS2DB_IN%>', getCommentStatements(table_description, "kds2db_in"), content)

  # replace placeholder for create table statements for schema db
  content <- gsub('<%CREATE_TABLE_STATEMENTS_DB%>', createTableStatements(table_description, "db"), content)

  # replace placeholder for grant statements for schema db
  content <- gsub('<%GRANT_STATEMENTS_DB%>', getGrantStatements(table_names, "db"), content)

  # replace placeholder for comment statements for schema db
  content <- gsub('<%COMMENT_STATEMENTS_DB%>', getCommentStatements(table_description, "db"), content)

  # Write the modified content to the file
  writeLines(content, './Postgres-amts_db/init/init-db.sql', useBytes = TRUE)
}

#replacePlaceholders()
