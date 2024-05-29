# This is used to set whether the column widths specified in the TableDefinition Excel file are to
# be taken into account (FALSE) or ignored (TRUE) when generating the database scripts.
IGNORE_DEFINED_COLUMN_WIDTHS = TRUE

# The Fhircrackr places the indices before each value in brackets, indicating where in the
# structure of the resource a column value was located. In addition, a separator is inserted between
# the list values (in our case length 3). The memory requirement for these indices and the separator
# should not exceed 15 and must be added to each single_length in the RAW tables.
RAW_DATA_FHIR_CRACKR_INDICES_STRING_WIDTH = 15

######################################################
# Static Definitions of Paths, File- and Columnnames #
######################################################

getDBScriptsTargetDir <- function() {"./Postgres-cds_hub/init/"}
getTemplateDir <- function() {paste0(getDBScriptsTargetDir(), "template/")}
getRightsDefinitionFileName <- function() {paste0(getTemplateDir(), "user_schema_rights_definition.xlsx")}
getRightsDefinitionSheetName <- function() {"rights_and_functions"}
writeResultFile <- function(scriptname, content) {
  message(scriptname)
  writeLines(content, paste0(getDBScriptsTargetDir(), scriptname), useBytes = TRUE)
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

stopOnNAorNull <- function(table_line, column_name) {
  value <- table_line[[column_name]]
  if (is.na(value) || is.null(value)) {
    print(paste0("Error with missing value in column ", column_name, " in line"))
    print(table_line)
    stop()
  }
}

stopOnMissingValue <- function(table_line, ...) { # ... = column names
  for (column_name in c(...)) {
    stopOnNAorNull(table_line, column_name)
  }
}

loadTemplate <- function(template_filename) {
  # the name can be a placeholder -> try to load a template with the same name
  if (grepl("^<%.*%>$", template_filename)) {
    template_filename <- substr(template_filename, 3, nchar(template_filename) - 2)
    template_filename <- tolower(template_filename)
    template_filename <- paste0(template_filename, ".sql")
  }
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

getFullTableName_2 <- function(tablename, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  tablename_postfix <- rights_first_row$TABLE_POSTFIX_2
  if (is.na(tablename_postfix)) tablename_postfix <- ""
  paste0(tablename, tablename_postfix)
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
      column_type <- "double precision"
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
    full_length  <- (full_length + RAW_DATA_FHIR_CRACKR_INDICES_STRING_WIDTH) * count
  }

  # only for string/varchar and numeric values add the column width
  if (column_type %in% "varchar") {
    column_type_with_length <- paste0(column_type, ifelse(IGNORE_DEFINED_COLUMN_WIDTHS, "",  paste0(" (", full_length, ")")))
  } else {
    column_type_with_length <- column_type
  }

  fhir_expression <- table_description_row$fhir_expression

  if (IGNORE_DEFINED_COLUMN_WIDTHS) {
    comment_length_and_type <- paste0(" (", column_type, ")")
  } else if (ignore_types) {
    comment_length_and_type <- paste0(" ( (", single_length, " + ", RAW_DATA_FHIR_CRACKR_INDICES_STRING_WIDTH, ") x ", count, " = ", full_length, " ", column_type, ")")
  } else {
    comment_length_and_type <- paste0(" (", single_length, " ", column_type, ")")
  }
  comment <- paste0(fhir_expression, comment_length_and_type)

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

getCreateTableStatements <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  ignore_types <- rights_first_row$TABLE_POSTFIX %in% "_raw"
  statements <- ""
  single_statement_template <- loadTemplate("template_cre_table_sub_create_table_statements.sql")
  row <- 1
  indentation <- NA
  for (tablename in names(table_description)) {
    full_tablename <- getFullTableName(tablename, rights_first_row)
    single_table_description <- table_description[[tablename]]
    single_statement <- gsub("<%TABLE_NAME%>", full_tablename, single_statement_template)
    column_line_statement <- ""
    indentation <- etlutils::getWhitespacesBeforeWord(single_statement, "<%CREATE_TABLE_STATEMENT_COLUMNS%>")
    # non RAW tables need an extra column for the ROW/Entry ID which they are originated (multiple
    # typed ( = non RAW) rows can be created by one RAW table row (see fhir_melt)
    if (!ignore_types) {
      column_line_statement <- paste0(full_tablename, "_raw_id int, -- Primary key of the corresponding raw table\n")
    }
    first_row <- TRUE
    for (row in 1:nrow(single_table_description)) {
      table_description_row <- single_table_description[row]
      statement_line <- getCreateTableStatementColumnLine(table_description_row, ignore_types)
      if (ignore_types && first_row) {
        column_line_statement <- paste0(column_line_statement, statement_line)
      } else {
        column_line_statement <- paste0(column_line_statement, indentation, statement_line)
      }
      first_row <- FALSE
    }
    single_statement <- gsub("<%CREATE_TABLE_STATEMENT_COLUMNS%>\n", column_line_statement, single_statement)
    statements <- paste0(statements, single_statement, "\n\n")
  }
  return(statements)
}

getCreateTableGrantStatements <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  tablenames <- names(table_description)
  statements <- ""
  for (tablename in tablenames) {
    # load grant template
    single_statement <- loadTemplate("template_cre_table_sub_grant.sql")

    sequence_name <- rights_first_row$SEQ_NAME
    grant_sub_alter_table_statement <- ""
    if (!is.na(sequence_name)) {
      grant_sub_alter_table_statement <- loadTemplate("template_cre_table_sub_grant_alter_table.sql")
      grant_sub_alter_table_statement <- gsub("<%SEQ_NAME%>", sequence_name, grant_sub_alter_table_statement)
    }
    single_statement <- gsub("<%TEMPLATE_CRE_TABLE_SUB_GRANT_ALTER_TABLE%>", grant_sub_alter_table_statement, single_statement)

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
    single_statement <- gsub("<%TEMPLATE_CRE_TABLE_SUB_GRANT_RIGHTS%>", grant_sub_rights_statements, single_statement)

    # replace placeholders in grant template
    full_tablename <- getFullTableName(tablename, script_rights_description)
    single_statement <- gsub("<%OWNER_USER%>", rights_first_row$OWNER_USER, single_statement)
    single_statement <- gsub("<%TABLE_NAME%>", full_tablename, single_statement)


    statements <- paste0(statements, single_statement, "\n\n")
  }
  return(statements)
}
getCreateTableCommentStatements <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  ignore_types <- rights_first_row$TABLE_POSTFIX %in% "_raw"
  comments <- ""
  table_comment_template <- loadTemplate("template_cre_table_sub_comment.sql")
  single_comment_typed_raw_id_line_template <- if (ignore_types) "" else loadTemplate("<%TEMPLATE_CRE_TABLE_SUB_COMMENT_TYPED_RAW_ID_LINE%>")
  table_comment_template <- gsub("<%TEMPLATE_CRE_TABLE_SUB_COMMENT_TYPED_RAW_ID_LINE%>", single_comment_typed_raw_id_line_template, table_comment_template)
  # if the placeholder for typed tables was replaced by empty string (in raw tables) -> there is an
  # empty line, which we remove now
  table_comment_template <- gsub("\n\n", "\n", table_comment_template)

  single_comment_line_template <- loadTemplate("<%TEMPLATE_CRE_TABLE_SUB_COMMENT_SINGLE_LINE%>")
  for (tablename in names(table_description)) {
    table_comment <- ""
    full_tablename <- getFullTableName(tablename, rights_first_row)
    single_table_description <- table_description[[tablename]]
    single_table_comment <- single_comment_line_template
    for (row in 1:nrow(single_table_description)) {
      # e.g.: comment on column cds2db_in.medicationadministration_raw.medadm_identifier_type_system is 'identifier/type/coding/system (70 x 6 = 420 varchar)';
      table_description_row <- single_table_description[row]
      single_comment <- gsub("<%COLUMN_NAME%>", table_description_row$column_name, single_table_comment)

      arguments <- parseTableDescriptionRow(table_description_row, ignore_types)
      single_comment <- gsub("<%COLUMN_COMMENT%>", arguments$comment, single_comment)
      table_comment <- paste0(table_comment, single_comment)
      if (row < nrow(single_table_description)) {
        table_comment <- paste0(table_comment, "\n")
      }
    }
    table_comment <- gsub("<%TEMPLATE_CRE_TABLE_SUB_COMMENT_SINGLE_LINE%>", table_comment, table_comment_template)
    table_comment <- gsub("<%TABLE_NAME%>", full_tablename, table_comment)
    comments <- paste0(comments, table_comment, "\n")
  }
  return(comments)
}

convertTemplateCreateTable <- function(table_description, script_rights_description) {
  checkMissingValues <- function() {
    # create a named vector with equal names and values for the right description columns
    # so we can use it instead of strings
    rights_columns <- etlutils::namedListByValue(names(script_rights_description))
    for (i in seq_len(nrow(script_rights_description))) {
      if (i == 1) {
        # check if all needed values are present in the first line
        stopOnMissingValue(script_rights_description[1],
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

  checkMissingValues()

  rights_first_row <- script_rights_description[1]
  # Load sql template
  content <- loadTemplate("template_cre_table.sql")
  # replace placeholder for create table statements for schema OWNER_SCHEMA
  content <- gsub("<%CREATE_TABLE_STATEMENTS%>", getCreateTableStatements(table_description, script_rights_description), content)
  # replace placeholder for grant statements for schema OWNER_SCHEMA
  content <- gsub("<%GRANT_STATEMENTS%>", getCreateTableGrantStatements(table_description, script_rights_description), content)
  # replace placeholder for comment statements for schema OWNER_SCHEMA
  content <- gsub("<%COMMENT_STATEMENTS%>", getCreateTableCommentStatements(table_description, script_rights_description), content)
  # replace placeholder for target schema as last
  content <- gsub("<%OWNER_SCHEMA%>", rights_first_row$OWNER_SCHEMA, content)

  # Write the modified content to the file
  writeResultFile(rights_first_row$SCRIPTNAME, content)
}

#########################
# Convert Copy Function #
#########################

getCopyFunctionPlaceholderColumns <- function(single_table_description, indentation, placeholder) {
  statements <- ""
  single_statement_template <- loadTemplate(placeholder)
  for (i in 1:nrow(single_table_description)) {
    table_description_row <- single_table_description[i]
    single_statement <- gsub("<%COLUMN_NAME%>", table_description_row$column_name, single_statement_template)
    if (nchar(statements)) {
      statements <- paste0(statements, indentation)
    }
    statements <- paste0(statements, single_statement, "\n")
  }
  # remove the last newline
  statements <- sub("\n$", "", statements)
  # remove the tailing "," or "AND"
  if (grepl(",$", statements)) {
    #remove last comma
    statements <- sub(",$", "", statements)
  } else {
    # remove last word in string (should be an "AND")
    statements <- sub(" [^ ]*$", "", statements)
  }
  return(statements)
}

convertTemplateCopyFunction <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  # a copy function name is given -> create such function
  copy_function_script_name <- rights_first_row$COPY_FUNC_SCRIPT_NAME
  if (!is.na(copy_function_script_name)) {
    rights_columns <- etlutils::namedListByValue(names(script_rights_description))
    # check if all necessary values for the copy function are given
    stopOnMissingValue(rights_first_row,
                       rights_columns$COPY_FUNC_NAME,
                       rights_columns$SCHEMA_2)

    tablenames <- names(table_description)
    statements <- ""
    for (tablename in tablenames) {
      full_tablename <- getFullTableName(tablename, script_rights_description)
      full_tablename_2 <- getFullTableName_2(tablename, script_rights_description)

      single_statement <- loadTemplate("template_copy_function_sub_single_table.sql")

      single_statement <- gsub("<%COPY_FUNC_NAME%>", rights_first_row$COPY_FUNC_NAME, single_statement)
      single_statement <- gsub("<%OWNER_SCHEMA%>", rights_first_row$OWNER_SCHEMA, single_statement)
      single_statement <- gsub("<%SCHEMA_2%>", rights_first_row$SCHEMA_2, single_statement)
      single_statement <- gsub("<%TABLE_NAME%>", full_tablename, single_statement)
      single_statement <- gsub("<%TABLE_NAME_2%>", full_tablename_2, single_statement)
      single_statement <- gsub("<%SIMPLE_TABLE_NAME%>", tablename, single_statement)

      colum_placeholders <- c("<%TEMPLATE_COPY_FUNCTION_SUB_COMPARE_COLUMNS%>",
                              "<%TEMPLATE_COPY_FUNCTION_SUB_COLUMNS%>",
                              "<%TEMPLATE_COPY_FUNCTION_SUB_CURRENT_RECORD_COLUMNS%>")

      single_table_description <- table_description[[tablename]]
      for (placeholder in colum_placeholders) {
        indentation <- etlutils::getWordIndentation(single_statement, placeholder)
        replacement <- getCopyFunctionPlaceholderColumns(single_table_description, indentation, placeholder)
        single_statement <- gsub(placeholder, replacement, single_statement)
      }

      statements <- paste0(statements, single_statement, "\n")

    }
    full_copy_function <- loadTemplate("template_copy_function.sql")
    full_copy_function <- gsub("<%TEMPLATE_COPY_FUNCTION_SUB_SINGLE_TABLE%>", statements, full_copy_function)
    writeResultFile(copy_function_script_name, full_copy_function)
  }
}

#######################
# Convert Create View #
#######################

getCreateViewCreateOrReplaceViewStatements <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  tablenames <- names(table_description)
  statements <- ""
  for (tablename in tablenames) {
    full_tablename <- getFullTableName(tablename, script_rights_description)
    full_tablename_2 <- getFullTableName_2(tablename, script_rights_description)
    # load grant template
    # CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (select * from <%SCHEMA_2%>.<%TABLE_NAME_2%> where <%TABLE_NAME_2%>_id not in (select <%TABLE_NAME%>_id from <%SCHEMA_2%>.<%SIMPLE_TABLENAME%>));
    single_statement <- loadTemplate("template_cre_view_sub_create_or_replace_view.sql")
    single_statement <- gsub("<%TABLE_NAME%>", full_tablename, single_statement)
    single_statement <- gsub("<%SCHEMA_2%>", rights_first_row$SCHEMA_2, single_statement)
    single_statement <- gsub("<%TABLE_NAME_2%>", full_tablename_2, single_statement)
    single_statement <- gsub("<%SIMPLE_TABLENAME%>", tablename, single_statement)
    statements <- paste0(statements, single_statement, "\n")
  }
  return(statements)
}

getCreateViewGrantStatements <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  tablenames <- names(table_description)
  statements <- ""
  for (tablename in tablenames) {
    # load grant template
    # <%TEMPLATE_CRE_VIEW_SUB_GRANT_RIGHTS%>
    # GRANT USAGE ON SCHEMA <%OWNER_SCHEMA%> TO <%GRANT_TARGET_USER%>;
    single_statement <- loadTemplate("template_cre_view_sub_grant.sql")
    grant_sub_rights_statements <- ""
    for (i in seq_len(nrow(script_rights_description))) {
      # GRANT <%RIGHTS%> ON TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> TO <%GRANT_TARGET_USER%>; -- Assign view to the user
      single_grant_sub_rights_statement <- loadTemplate("template_cre_view_sub_grant_rights.sql")
      single_grant_sub_rights_statement <- gsub("<%RIGHTS%>", script_rights_description[i]$RIGHTS, single_grant_sub_rights_statement)
      single_grant_sub_rights_statement <- gsub("<%GRANT_TARGET_USER%>", script_rights_description[i]$GRANT_TARGET_USER, single_grant_sub_rights_statement)
      grant_sub_rights_statements <- paste0(grant_sub_rights_statements, single_grant_sub_rights_statement)
      if (i < nrow(script_rights_description)) {
        grant_sub_rights_statements <- paste0(grant_sub_rights_statements, "\n")
      }
    }
    single_statement <- gsub("<%TEMPLATE_CRE_VIEW_SUB_GRANT_RIGHTS%>", grant_sub_rights_statements, single_statement)

    # replace placeholders in grant template
    full_tablename <- getFullTableName(tablename, script_rights_description)
    single_statement <- gsub("<%TABLE_NAME%>", full_tablename, single_statement)


    statements <- paste0(statements, single_statement, "\n\n")
  }
  return(statements)
}

checkMissingValuesForCreateView <- function(script_rights_description) {
  # create a named vector with equal names and values for the right description columns
  # so we can use it instead of strings
  rights_columns <- etlutils::namedListByValue(names(script_rights_description))
  for (i in seq_len(nrow(script_rights_description))) {
    if (i == 1) {
      # check if all needed values are present in the first line
      stopOnMissingValue(script_rights_description[1],
                         rights_columns$SCRIPTNAME,
                         rights_columns$OWNER_USER,
                         rights_columns$OWNER_SCHEMA,
                         rights_columns$TABLE_PREFIX,
                         rights_columns$SCHEMA_2)
    }
    # all lines need this values:
    stopOnMissingValue(script_rights_description[i],
                       rights_columns$RIGHTS,
                       rights_columns$GRANT_TRAGET_USER)
  }
}

convertTemplateCreateView <- function(table_description, script_rights_description) {
  checkMissingValuesForCreateView(script_rights_description)
  rights_first_row <- script_rights_description[1]
  # Load sql template
  content <- loadTemplate("template_cre_view.sql")
  # replace placeholder for create or replace view
  content <- gsub("<%TEMPLATE_CRE_VIEW_SUB_CREATE_OR_REPLACE_VIEW%>", getCreateViewCreateOrReplaceViewStatements(table_description, script_rights_description), content)
  content <- gsub("<%TEMPLATE_CRE_VIEW_SUB_GRANT%>", getCreateViewGrantStatements(table_description, script_rights_description), content)
  content <- gsub("<%OWNER_SCHEMA%>", rights_first_row$OWNER_SCHEMA, content)
  content <- gsub("<%OWNER_USER%>", rights_first_row$OWNER_USER, content)

  # Write the modified content to the file
  writeResultFile(rights_first_row$SCRIPTNAME, content)
}

######################################################
# Convert Create View2 (dataprocessor -> all tables) #
######################################################

getCreateView2SingleTableStatements <- function(table_description, script_rights_description) {
  rights_first_row <- script_rights_description[1]
  tablenames <- names(table_description)
  statements <- ""
  for (tablename in tablenames) {
    full_tablename <- getFullTableName(tablename, script_rights_description)
    full_tablename_2 <- getFullTableName_2(tablename, script_rights_description)
    # load grant template
    # CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (select * from <%SCHEMA_2%>.<%TABLE_NAME_2%> where <%TABLE_NAME_2%>_id not in (select <%TABLE_NAME%>_id from <%SCHEMA_2%>.<%SIMPLE_TABLENAME%>));
    single_statement <- loadTemplate("<%TEMPLATE_CRE_VIEW2_SUB_SINGLE_TABLE%>")
    single_statement <- gsub("<%TABLE_NAME%>", full_tablename, single_statement)
    single_statement <- gsub("<%SCHEMA_2%>", rights_first_row$SCHEMA_2, single_statement)
    single_statement <- gsub("<%TABLE_NAME_2%>", full_tablename_2, single_statement)
    single_statement <- gsub("<%SIMPLE_TABLENAME%>", tablename, single_statement)
    statements <- paste0(statements, single_statement, "\n")
  }
  return(statements)
}

convertTemplateCreateView2 <- function(table_description, script_rights_description) {
  checkMissingValuesForCreateView(script_rights_description)
  rights_first_row <- script_rights_description[1]
  # Load sql template
  content <- loadTemplate("template_cre_view2.sql")

  # replace placeholder for create or replace view
  content <- gsub("<%TEMPLATE_CRE_VIEW2_SUB_SINGLE_TABLE%>", getCreateView2SingleTableStatements(table_description, script_rights_description), content)
  content <- gsub("<%TEMPLATE_CRE_VIEW_SUB_GRANT%>", getCreateViewGrantStatements(table_description, script_rights_description), content)
  content <- gsub("<%OWNER_SCHEMA%>", rights_first_row$OWNER_SCHEMA, content)
  content <- gsub("<%OWNER_USER%>", rights_first_row$OWNER_USER, content)

  # Write the modified content to the file
  writeResultFile(rights_first_row$SCRIPTNAME, content)
}



########
# Main #
########

loadDatabaseRightsDescription <- function() {
  rights_description_file_name <- getRightsDefinitionFileName()
  rights_description_sheet_name <- getRightsDefinitionSheetName()
  # read the excel file with the rigths and copy functions definition and extract the specific table
  rights_description <- etlutils::readExcelFileAsTableList(rights_description_file_name)[[rights_description_sheet_name]]

  # this are *exactly* the names of the columns in the excel file
  rights_description_columns <- getRightsDefinitionColumnNames()

  rights_description <- etlutils::removeTableHeader(rights_description, rights_description_columns)

  if (!etlutils::isValidTable(rights_description)) {
    stop(paste0("Could not find a row with the follwing entries in file '",
                rights_description_file_name, "' in sheet '", rights_description_sheet_name, "':\n",
                paste0(rights_description_columns, collapse = ", "), "\n",
                "Hint: If the column names are changed in the Excel file, then replace the same ",
                "strings here in this R-script."))
  }

  rights_description <- etlutils::removeRowsWithNAorEmpty(rights_description)
  rights_description <- etlutils::splitTableToList(rights_description, rights_description_columns$SCRIPTNAME)
  return(rights_description)
}

createDatabaseScriptsFromTemplates <- function() {
  table_description <- getTableDescriptionSplittedByResource()
  rights_description <- loadDatabaseRightsDescription()

  rights_definition_column_names <- getRightsDefinitionColumnNames()
  for (scriptname in names(rights_description)) {
    script_rights_description <- rights_description[[scriptname]]
    template <- script_rights_description[1]$TEMPLATE
    copy_function <- script_rights_description[1]$COPY_FUNC_SCRIPT_NAME
    if (template %in% "template_cre_table.sql") {
      convertTemplateCreateTable(table_description, script_rights_description)
    } else if (template %in% "template_cre_view.sql") {
      convertTemplateCreateView(table_description, script_rights_description)
    } else if (template %in% "template_cre_view2.sql") {
      convertTemplateCreateView2(table_description, script_rights_description)
    } else {
      # simple copy script from template without any changes
      copyTemplate(script_rights_description)
    }
    if (!is.na(copy_function)) {
      convertTemplateCopyFunction(table_description, script_rights_description)
    }

  }
}

# INIT_DATABASE_SCRIPTS <<- TRUE
if (exists("INIT_DATABASE_SCRIPTS") && INIT_DATABASE_SCRIPTS) {
  while(!grepl("/interpolar$", getwd())) {
    setwd("..")
  }
  source("./R-cds2db/cds2db/R/Init_00.R")
  createDatabaseScriptsFromTemplates()
}
