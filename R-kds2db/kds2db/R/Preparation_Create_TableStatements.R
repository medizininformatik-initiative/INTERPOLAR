# free memory
rm(list = ls())

getTableStatmentEndRows <- function() {
  end_rows <- ''
  end_rows <- paste0(end_rows, "input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Time at which the data record is inserted\n")
  end_rows <- paste0(end_rows, "last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked\n")
  end_rows <- paste0(end_rows, "current_dataset_status varchar(50) DEFAULT 'input'   -- Processing status of the data record\n")
  end_rows <- paste0(end_rows, ");\n\n")
}

createKDS2DBTableStatements <- function(table_description) {
  statements <- ''
  last_table_name <- NA
  for (row in 1:nrow(table_description)) {
    table_name <- table_description$table[row]
    if (!is.na(table_name)) {
      if (is.na(last_table_name)) {
        statements <- paste0(statements, getTableStatmentEndRows())
      }
      statements <- paste0(statements, "CREATE TABLE IF NOT EXISTS kds2db_in.", table_name, " (\n")
      statements <- paste0(statements, "", table_name, "_id serial PRIMARY KEY not null, -- Primary key of the entity\n")
    }
    if (!all(is.na(table_description[row]))) {
      count <- as.integer(table_description$count[row])
      if (is.na(count)) count <- 1
      single_length <- as.integer(table_description$single_length[row])
      full_length <- single_length * count
      fhir_expression <- table_description$fhir_expression[row]
      statements <- paste0(statements, "", table_description$column_name[row], " varchar (", full_length, "),   -- ", fhir_expression, " (", single_length, " x ", count, " varchar)\n")
    }

  }
  statements <- paste0(statements, getTableStatmentEndRows())
}

getReplacedContentFromFile <- function(file_path, placeholder, replacement) {
  # read the content of the file
  content <- readLines(file_path)
  # Replace the placeholder with the replacement
  content <- paste0(gsub(placeholder, replacement, content), collapse = '\n')
}

getGrantStatements <- function(table_names) {
  grant_statements <- ''
  for (table_name in table_names) {
    grant <- getReplacedContentFromFile('./Postgres-amts_db/init/init-db_template_sub_kds2db_grant.sql', '<%KDS2DB_GRANT_TABLE_NAME%>', table_name)
    grant_statements <- paste0(grant_statements, grant, '\n\n\n')
  }
  return(grant_statements)
}

replacePlaceholders <- function() {
  table_description <- etlutils::readExcelFileAsTableList('./R-kds2db/kds2db/inst/extdata/Table_Description.xlsx')[['table_description']]
  table_names <- na.omit(table_description$table)

  # Load template and replace the placeholder with the create table statements
  content <- getReplacedContentFromFile('./Postgres-amts_db/init/init-db_template.sql', '<%KDS2DB_CREATE_TABLE_STATEMENTS%>', createKDS2DBTableStatements(table_description))
  # replace placeholder for grant statements
  grant_statements <- getGrantStatements(table_names)
  content <- gsub('<%KDS2DB_GRANT%>', getGrantStatements(table_names), content)

  # Write the modified content to the file
  writeLines(content, './Postgres-amts_db/init/init-db_generated.sql', useBytes = TRUE)
}

replacePlaceholders()
