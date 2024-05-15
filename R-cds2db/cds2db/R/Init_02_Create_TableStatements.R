######################################################
# Static Definitions of Paths, File- and Columnnames #
######################################################
getDBScriptsTargetDir <- function() {"./Postgres-cds_hub/init/"}
getTemplateDir <- function() {paste0(getDBScriptsTargetDir(), "template/")}
getRightsDefinitionFileName <- function() {paste0(getTemplateDir(), "user_schema_rights_definition.xlsx")}
getRightsDefinitionSheetName <- function() {"rights_and_functions"}
writeResultFile <- function(scriptname, content) {
  writeLines(content, paste0(getDBScriptsTargetDir(), scriptname), useBytes = TRUE)
}
#' Load Table Description Excel File
#'
#' This function loads a table description excel file
#'
#' @return A data table with table descriptions
#'
loadTableDescriptionFile <- function() {
  table_description_file_path <- system.file("extdata", "Table_Description.xlsx", package = "cds2db")
  table_description <- etlutils::readExcelFileAsTableList(table_description_file_path)[['table_description']]
  return(table_description)
}

getRightsDefinitionColumnNames <- function() {
  # these are *exactly* the names of the columns in the excel file
  etlutils::namedListByValue(
    "SCRIPTNAME",
    "TEMPLATE",
    "OWNER_USER",
    "OWNER_SCHEMA",
    "TABLE_PREFIX",
    "TABLE_POSTFIX",
    "SEQ_NAME",
    "RIGHTS",
    "GRANT_TARGET_USER",
    "COPY_FUNC_SCRIPT_NAME",
    "COPY_FUNC_NAME",
    "SCHEMA_2",
    "TABLE_POSTFIX_2",
    "SCHEMA_3",
    "TABLE_POSTFIX_3")
}

#####################
# General Functions #
#####################

stopOnNA <- function(table_line, column_name) {
  if (is.na(table_line[[column_name]])) {
    print(paste0("Error with missing value in column ", column_name, " in line"))
    print(table_line)
    stop()
  }
}

stopOnMissingValue <- function(table_line, ...) { # ... = column names
  for (column_name in c(...)) {
    stopOnNA(table_line, column_name)
  }
}

loadTemplate <- function(template_filename) {
  full_template_filename <- paste0(getTemplateDir(), template_filename)
  etlutils::getContentFromFile(full_template_filename)
}

copyTemplate <- function(script_rights_description) {
  scriptname <- script_rights_description[1]$SCRIPTNAME
  content <- loadTemplate(paste0("template_", scriptname))
  # Write the unmodified content to the file
  writeResultFile(scriptname, content)
}

getFullTableName <- function(tablename, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  tablename_prefix <- rights_first_row$TABLE_PREFIX
  tablename_postfix <- rights_first_row$TABLE_POSTFIX
  if (is.na(tablename_prefix)) tablename_prefix <- ""
  if (is.na(tablename_postfix)) tablename_postfix <- ""
  paste0(tablename_prefix, tablename, tablename_postfix)
}

########################
# Convert Create Table #
########################

parseTableDescriptionRow <- function(table_description_row, ignore_types = TRUE) {
  column_line_arguments <- list()

  # if there is no type information -> set varchar = string
  column_type <- "varchar"
  # in the raw table all types are varchar
  if (!ignore_types) {
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

  single_length <- as.integer(table_description_row$single_length)

  # the count is needed only in the raw table
  count <- as.integer(table_description_row$count)
  # an empty count in the defnition means 1
  if (is.na(count)) count <- 1

  full_length <- single_length
  # only the raw tables have list values in the same row (it's before the fhir_melt()
  # step to split multiple values in single rows)
  if (ignore_types) {
    full_length  <- full_length * count
  }

  # only for string/varchar and numeric values add the column width
  if (column_type %in% "varchar") {
    column_type_with_length <- paste0(column_type, " (", full_length, ")")
  } else if (column_type %in% "numeric") {
    # decimal/numeric needs a length for the places before and after the decimal point -> set same
    # value before and after decimal point
    column_type_with_length <- paste0(column_type, " (", full_length, ", ", full_length, ")")
  } else {
    column_type_with_length <- column_type
  }

  fhir_expression <- table_description_row$fhir_expression
  if (ignore_types) {
    comment <- paste0(fhir_expression, " (", single_length, " x ", count, " = ", full_length, " ", column_type, ")")
  } else {
    comment <- paste0(fhir_expression, " (", single_length, " ", column_type, ")")
  }

  column_line_arguments[["comment"]] <- comment
  column_line_arguments[["column_type_with_length"]] <- column_type_with_length

  return(column_line_arguments)
}

getCreateTableStatementColumnLine <- function(table_description_row, ignore_types = TRUE) {
  # e.g.: medadm_identifier_type_system varchar (420),   -- identifier/type/coding/system (70 x 6 = 420 varchar)
  arguments <- parseTableDescriptionRow(table_description_row, ignore_types)
  column_line <- paste0(table_description_row$column_name, " ", arguments$column_type_with_length, ",   -- ", arguments$comment, "\n")
  return(column_line)
}

getCreateCommentColumnLine <- function(schema_name, full_tablename, table_description_row, ignore_types = TRUE) {
  # e.g.: comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_system is 'identifier/type/coding/system (70 x 6 = 420 varchar)';
  arguments <- parseTableDescriptionRow(table_description_row, ignore_types)
  comment_line <- paste0("comment on column ", schema_name, ".", full_tablename, ".",
                         table_description_row$column_name," is '",
                         table_description_row$fhir_expression, " ", arguments$comment, "';\n")
  return(comment_line)
}

createTableStatements <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  ignore_types <- rights_first_row$TABLE_POSTFIX %in% "_raw"
  statements <- ""
  last_full_tablename <- NA
  sub_template_filename <- "template_cre_table_sub_create_table_statements.sql"
  single_statement <- loadTemplate(sub_template_filename)
  row <- 1
  indentation <- NA
  while (row <= nrow(table_description)) {
    tablename <- table_description$resource[row]
    if (!is.na(tablename)) {
      full_tablename <- getFullTableName(tablename, rights_first_row)
      if (!full_tablename %in% last_full_tablename) {
        last_full_tablename <- full_tablename
        single_statement <- gsub("<%OWNER_SCHEMA%>", rights_first_row$OWNER_SCHEMA, single_statement)
        single_statement <- gsub("<%TABLE_NAME%>", full_tablename, single_statement)
        column_line_statement <- ""
        row2 <- row
        while (row2 <= nrow(table_description)) {
          next_tablename <- table_description$resource[row2]
          new_tablename_found <- !is.na(next_tablename) && next_tablename != tablename
          if (!new_tablename_found) {
            table_description_row <- table_description[row2]
            if (!all(is.na(table_description_row))) {
              statement_line <- getCreateTableStatementColumnLine(table_description_row, ignore_types)
              if (is.na(indentation)) {
                column_line_statement <- paste0(column_line_statement, statement_line)
                indentation <- etlutils::getWhitespacesBeforeWord(single_statement, "<%CREATE_TABLE_STATEMENT_COLUMNS%>")
              } else {
                column_line_statement <- paste0(column_line_statement, indentation, statement_line)
              }
            }
          }
          reached_last_row <- row2 == nrow(table_description)
          if (new_tablename_found || reached_last_row) {
            single_statement <- gsub("<%CREATE_TABLE_STATEMENT_COLUMNS%>\n", column_line_statement, single_statement)
            statements <- paste0(statements, single_statement, "\n\n")
            single_statement <- loadTemplate(sub_template_filename)
            row <- if (reached_last_row) Inf  else row2
            indentation <- NA
            row2 <- Inf
          }
          row2 <- row2 + 1
        }
      }
    }
  }
  return(statements)
}

getGrantStatements <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  tablenames <- unique(na.omit(table_description$resource))
  grant_statements <- ''
  for (tablename in tablenames) {
    # load grant template
    single_grant_statement <- loadTemplate("template_cre_table_sub_grant.sql")

    sequence_name <- rights_first_row$SEQ_NAME
    grant_sub_alter_table_statement <- ""
    if (!is.na(sequence_name)) {
      grant_sub_alter_table_statement <- loadTemplate("template_cre_table_sub_grant_alter_table.sql")
      grant_sub_alter_table_statement <- gsub("<%SEQ_NAME%>", sequence_name, grant_sub_alter_table_statement)
    }
    single_grant_statement <- gsub("<%TEMPLATE_CRE_TABLE_SUB_GRANT_ALTER_TABLE%>", grant_sub_alter_table_statement, single_grant_statement)

    grant_sub_rights_statements <- ""
    for (i in seq_len(nrow(script_rights_description))) {
      single_grant_sub_rights_statement <- loadTemplate("template_cre_table_sub_grant_rights.sql")
      single_grant_sub_rights_statement <- gsub("<%RIGHTS%>", script_rights_description[i]$RIGHTS, single_grant_sub_rights_statement)
      single_grant_sub_rights_statement <- gsub("<%GRANT_TARGET_USER%>", script_rights_description[i]$GRANT_TARGET_USER, single_grant_sub_rights_statement)
      grant_sub_rights_statements <- paste0(grant_sub_rights_statements, single_grant_sub_rights_statement)
      if (i < nrow(script_rights_description)) {
        grant_sub_rights_statements <- paste0(grant_sub_rights_statements, "\n")
      }
    }
    single_grant_statement <- gsub("<%TEMPLATE_CRE_TABLE_SUB_GRANT_RIGHTS%>", grant_sub_rights_statements, single_grant_statement)

    # replace placeholders in grant template
    full_tablename <- getFullTableName(tablename, script_rights_description)
    single_grant_statement <- gsub("<%OWNER_SCHEMA%>", rights_first_row$OWNER_SCHEMA, single_grant_statement)
    single_grant_statement <- gsub("<%OWNER_USER%>", rights_first_row$OWNER_USER, single_grant_statement)
    single_grant_statement <- gsub("<%TABLE_NAME%>", full_tablename, single_grant_statement)


    grant_statements <- paste0(grant_statements, single_grant_statement, "\n\n")
  }
  return(grant_statements)
}

getCommentStatements <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  ignore_types <- rights_first_row$TABLE_POSTFIX %in% "_raw"
  comments <- ''
  tablename <- NA
  for (row in 1:nrow(table_description)) {
    table_description_row <- table_description[row]
    if (!all(is.na(table_description_row))) {
      new_tablename <- table_description_row$resource
      if (!is.na(new_tablename)) {
        if (!is.na(tablename)) {
          comments <- paste0(comments, '\n')
        }
        tablename <- new_tablename
      }
      single_length <- as.integer(table_description_row$single_length)
      count <- as.integer(table_description_row$count)
      if (is.na(count)) count <- 1
      schema_name <- rights_first_row$OWNER_SCHEMA
      full_tablename <- getFullTableName(tablename, rights_first_row)
      comment <- getCreateCommentColumnLine(schema_name, full_tablename, table_description_row, ignore_types)
      # generates something like this:
      # comment on column cds2db_in.condition.con_note_authorreference_identifier_type_system is 'note/authorReference/identifier/type/coding/system (70 x 18 1260)';
      comments <- paste0(comments, comment)
    }
  }
  return(comments)
}

convertTemplateCreateTable <- function(table_description, script_rights_description) {

  checkMissingValues <- function() {
    for (i in seq_len(nrow(script_rights_description))) {
      if (i == 1) {
        # check if all needed values are present in the first line
        stopOnMissingValue(rights_first_row,
                           rights_columns$SCRIPTNAME,
                           rights_columns$OWNER_USER,
                           rights_columns$OWNER_SCHEMA)
      }
      # all lines need this values:
      stopOnMissingValue(script_rights_description[i],
                         rights_columns$RIGHTS,
                         rights_columns$GRANT_TRAGET_USER)
    }
  }

  rights_first_row <- script_rights_description[1]
  # create a named vector with equal names and values for the right description columns
  # so we can use it instead of strings
  rights_columns <- etlutils::namedListByValue(names(script_rights_description))
  # check if all needed values for the conversion are present (rights_first_row and rights_columns must be initialized here)
  checkMissingValues()

  # preapre table description -> table names must be in lower
  table_description$resource <- tolower(table_description$resource)
  # Load sql template
  content <- loadTemplate("template_cre_table.sql")
  # replace placeholder for target schema
  content <- gsub('<%OWNER_SCHEMA%>', rights_first_row$OWNER_SCHEMA, content)
  # replace placeholder for create table statements for schema OWNER_SCHEMA
  content <- gsub('<%CREATE_TABLE_STATEMENTS%>', createTableStatements(table_description, script_rights_description), content)
  # replace placeholder for grant statements for schema OWNER_SCHEMA
  content <- gsub('<%GRANT_STATEMENTS%>', getGrantStatements(table_description, script_rights_description), content)
  # replace placeholder for comment statements for schema OWNER_SCHEMA
  content <- gsub('<%COMMENT_STATEMENTS%>', getCommentStatements(table_description, script_rights_description), content)

  # Write the modified content to the file
  writeResultFile(rights_first_row$SCRIPTNAME, content)
}

#######################
# Convert Create View #
#######################

convertTemplateCreateView <- function(table_description, script_rights_description) {

}

########
# Main #
########

createDatabaseScriptsFromTemplates <- function() {
  table_description <- loadTableDescriptionFile()

  rights_description_file_name <- getRightsDefinitionFileName()
  rights_description_sheet_name <- getRightsDefinitionSheetName()
  # read the excel file with the rigths and copy functions definition and extract the specific table
  rights_description <- etlutils::readExcelFileAsTableList(rights_description_file_name)[[rights_description_sheet_name]]

  # this are *exactly* the names of the columns in the excel file
  rights_description_columns <- getRightsDefinitionColumnNames()

  rights_description <- etlutils::removeTableHeader(rights_description, rights_description_columns)

  if (!etlutils::isValidTable(rights_description)) {
    stop(paste0("Could not find a row with the follwing entries in file '", rights_description_file_name, "' in sheet '", rights_description_sheet_name, "':\n",
                paste0(rights_description_columns, collapse = ", ")))
  }

  rights_description <- etlutils::removeRowsWithNAorEmpty(rights_description)
  rights_description <- etlutils::fillNAWithLastRowValue(rights_description, rights_description_columns$SCRIPTNAME)

  isCreateTableScript <- function(script_name) {
    # accepts names like "12a_cre_table_raw_db_log.sql" or "01_cre_table"
    return(grepl("^[0-9]+[a-zA-Z]*_cre_table", script_name))
  }

  isCreateViewScript <- function(script_name) {
    # accepts names like "12a_cre_view_raw_db_log.sql" or "01_cre_view"
    return(grepl("^[0-9]+[a-zA-Z]*_cre_view", script_name))
  }

  script_min_row_index <- 1 # set first row index as start
  scriptname <- rights_description[1][[rights_description_columns$SCRIPTNAME]] # get first row scriptname
  for (i in seq_len(nrow(rights_description))) {
    if (i == nrow(rights_description)) {
      i <- i + 1
      next_scriptname <- NA
    } else {
      row <- rights_description[i + 1]
      next_scriptname <- row[[rights_description_columns$SCRIPTNAME]]
    }

    if (!scriptname %in% next_scriptname) {
      message(scriptname)
      script_rights_description <- rights_description[script_min_row_index:i]
      if (isCreateTableScript(scriptname)) {
        convertTemplateCreateTable(table_description, script_rights_description)
      } else if (isCreateViewScript(scriptname)) {
        convertTemplateCreateView(table_description, script_rights_description)
      } else {
        # simple copy script from template without any changes
        copyTemplate(script_rights_description)
      }
      scriptname = next_scriptname
      script_min_row_index = i + 1
    }
  }

}

#createDatabaseScriptsFromTemplates()
