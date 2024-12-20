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

getDBScriptsTargetDir <- function() "./Postgres-cds_hub/init/"
getTemplateDir <- function() paste0(getDBScriptsTargetDir(), "template/")
getRightsDefinitionDirName <- function() getTemplateDir()
getRightsDefinitionFileName <- function() paste0(getRightsDefinitionDirName(), "User_Schema_Rights_Definition.xlsx")
getRightsDefinitionSheetName <- function() "rights_and_functions"
getConvertDefinitionSheetName <- function() "table_description_convert_def"

writeResultFile <- function(scriptname, content) {
  message(scriptname)
  content <- gsub("\r\n", "\n", content, fixed = TRUE)
  writeLines(content, paste0(getDBScriptsTargetDir(), scriptname), useBytes = TRUE, sep = "\n")
}

#' Replace and remove specific placeholders from a text
#'
#' This function replaces and removes lines containing only the specific placeholder surrounded
#' by optional whitespace. It also removes the placeholder within a line, along with an optional
#' surrounding space.
#'
#' @param input_string A string containing the text to process.
#' @param placeholder A string representing the placeholder to be removed.
#'
#' @return A processed string with the specified placeholder removed as described.
#'
#' @examples
#' text <- paste0("Dieser Text ergibt keinen Sinn, denn <%placeholder%>\n",
#'                "er <%placeholder%> ist nur <%placeholder%> zu Demonstrationszecken da\n",
#'                "<%placeholder%>\n",
#'                "   <%placeholder%>\n",
#'                "       <%placeholder%>   \n",
#'                "und soll helfen, Chatgpt\n",
#'                "\n",
#'                "\n",
#'                "\n",
#'                "  eine Aufgabe lösen zu lassen.")
#' cleaned_text <- removePlaceholderLines(text, "<%placeholder%>")
#' cat(cleaned_text)
#'
#' @export
removePlaceholderLines <- function(input_string, placeholder) {

  placeholder_escaped <- etlutils::getEscaped(placeholder)

  # Check if input_string ends with a newline
  ends_with_newline <- grepl("\n$", input_string)

  # Split the input string into lines
  lines <- strsplit(input_string, "\n", fixed = TRUE)[[1]]

  # Remove lines containing only the placeholder with optional whitespace
  placeholder_pattern <- paste0("^\\s*", placeholder_escaped, "\\s*$")
  lines <- lines[!grepl(placeholder_pattern, lines, perl = TRUE)]

  # Remove the placeholder within lines, along with an optional surrounding space
  placeholder_inline_pattern <- paste0("\\s?\\Q", placeholder, "\\E\\s?")
  lines <- gsub(placeholder_inline_pattern, "", lines, perl = TRUE)

  # Combine the lines back into a single string
  output_string <- paste(lines, collapse = "\n")

  # Re-add the final newline if it was originally present
  if (nchar(output_string) && ends_with_newline) {
    output_string <- paste0(output_string, "\n")
  }

  return(output_string)
}

getRightsDefinitionColumnNames <- function() {
  # these are *exactly* the names of the columns in the excel file
  etlutils::namedListByValue(
    "TABLE_DESCRIPTION",
    "SCRIPTNAME",
    "TEMPLATE",
    "OWNER_USER",
    "OWNER_SCHEMA",
    "TAGS",
    "TABLE_PREFIX",
    "TABLE_POSTFIX",
    "RIGHTS",
    "GRANT_TARGET_USER",
    "COPY_FUNC_SCRIPTNAME",
    "COPY_FUNC_TEMPLATE",
    "COPY_FUNC_NAME",
    "SCHEMA_2",
    "TABLE_POSTFIX_2",
    "SCHEMA_3",
    "TABLE_POSTFIX_3")
}

getConvertDefinitionColumnNames <- function() {
  # these are *exactly* the names of the columns in the excel file
  etlutils::namedListByValue(
    "TABLE_DESCRIPTION",
    "SOURCE_COLUMN_NAME",
    "TARGET_COLUMN_NAME",
    "SOURCE_TYPE",
    "TARGET_TYPE")
}


#####################
# General Functions #
#####################

extractPlaceholders <- function(input_string) {
  # Regular expression to match placeholders including quoted text
  pattern <- "<%([^\"%]*(\"[^\"]*\"|'[^']*')?)*?%>"

  # Extract all matches
  matches <- gregexpr(pattern, input_string, perl = TRUE)
  placeholders <- regmatches(input_string, matches)
  placeholders <- unlist(placeholders)
  placeholders <- unique(placeholders)

  # Sort placeholders to bring <%IF ... %> to the front
  if_placeholders <- placeholders[grepl("^<%[iI][fF]", placeholders)]
  other_placeholders <- placeholders[!grepl("^<%[iI][fF]", placeholders)]

  # Combine sorted placeholders
  sorted_placeholders <- c(if_placeholders, other_placeholders)
  return(sorted_placeholders)
}

extractPlaceholderName <- function(placeholder) {
  # Regular expression to match the pattern and capture the content inside the placeholder
  pattern <- "^<%(.*)%>$"
  # Extract the content inside the placeholder
  content <- sub(pattern, "\\1", placeholder)
  return(content)
}

isWholeWordPresent <- function(text, word) {
  # Regular expression to match the whole word
  pattern <- paste0("\\b", word, "\\b")

  # Check if the word is present as a whole word
  matches <- gregexpr(pattern, text, perl = TRUE)
  match_positions <- regmatches(text, matches)

  return(length(unlist(match_positions)) > 0)
}

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
  }
  if (!endsWith(template_filename, ".sql")) {
    template_filename <- paste0(template_filename, ".sql")
  }
  full_template_filename <- paste0(getTemplateDir(), template_filename)
  etlutils::readFileAsString(full_template_filename)
}

copyTemplate <- function(script_rights_definition) {
  scriptname <- script_rights_definition[1]$SCRIPTNAME
  content <- loadTemplate(paste0("template_", scriptname))
  # Write the unmodified content to the file
  writeResultFile(scriptname, content)
}

getFullTableName <- function(tablename, script_rights_definition, name_index = 1) {
  rights_first_row <- script_rights_definition[1]
  table_prefix_colname <- "TABLE_PREFIX"
  if (name_index > 1) {
    table_prefix_colname <- paste0(table_prefix_colname, "_", name_index)
  }
  table_postfix_colname <- "TABLE_POSTFIX"
  if (name_index > 1) {
    table_postfix_colname <- paste0(table_postfix_colname, "_", name_index)
  }
  tablename_prefix <- try(rights_first_row[[table_prefix_colname]], silent =  TRUE)
  tablename_postfix <- try(rights_first_row[[table_postfix_colname]], silent =  TRUE)
  if (etlutils::isSimpleNaOrError(tablename_prefix)) tablename_prefix <- ""
  if (etlutils::isSimpleNaOrError(tablename_postfix)) tablename_postfix <- ""
  paste0(tablename_prefix, tablename, tablename_postfix)
}

#####################################
# Crate Generated SQL Script Header #
#####################################

createHeader <- function(script_rights_definition) {

  add <- function(...) {
    header <<- paste0(header, paste0(...), "\n")
  }

  formatTime <- function(timestamp) {
    format(timestamp, "%Y-%m-%d %H:%M:%S")
  }

  rights_definition_file_name <- getRightsDefinitionFileName()
  rights_definition_file_info <- file.info(rights_definition_file_name)

  header <- ""
  add("-- ########################################################################################################")
  add("--")
  add("-- This file is generated. Changes should only be made by regenerating the file.")
  add("--")
  add("-- Rights definition file             : ", rights_definition_file_name)
  add("-- Rights definition file last update : ", formatTime(rights_definition_file_info$mtime))
  add("-- Rights definition file size        : ", rights_definition_file_info$size, " Byte")
  add("--")
  add("-- Create SQL Tables in Schema \"", script_rights_definition[1]$OWNER_SCHEMA ,"\"")
  add("-- Create time: ", formatTime(Sys.time()))
  # iterate over all columns and rows in the script_rights_definition
  col_names <- names(script_rights_definition)
  for (col_name in col_names) {
    for (r in seq_len(nrow(script_rights_definition))) {
      # add the value always if we are in the first row of the script_rights_definition or if
      # the value is not NA and different to the value in the previous row
      if (r == 1 || ((!is.na(script_rights_definition[r, ..col_name]) && !(script_rights_definition[r, ..col_name] %in% script_rights_definition[r - 1, ..col_name])))) {
        value <- script_rights_definition[r, ..col_name]
        if (is.na(value)) value <- "" # change NA values to NA (should only happen in row 1)
        add("-- ", col_name, ifelse (r == 1, "", paste0(" (", r, ")")), ":  ", value, "")
      }
    }
  }
  add("-- ########################################################################################################\n")
  return(header)
}

########################
# Convert Create Table #
########################

parseIFExpression <- function(expression) {
  # Examples
  # expression <- "<%IF NOT TAGS \"\\bTYPED\\b\" \"<%TABLE_NAME%>_raw_id int NOT NULL, -- Primary key of the corresponding raw table\"%>"
  # expression <- "<%IF TAGS \"^TYPED$\" TEMPLATE_SUB_LOOP_TABLES_CREATE_TABLE_IF_TYPED%>"
  #patternInlineIf <- "^<%[IF]\\s+([a-zA-Z0-9_]+)\\s+(['\"].*['\"])\\s+(.*)%>$"
  patternInlineIf <- "^<%[iI][fF](\\s+[nN][oO][tT])?\\s+([a-zA-Z0-9_]+)\\s+(['\"].*?['\"])\\s+(.*?)%>$"
  # Extract the parts of the expression
  matches <- regmatches(expression, regexec(patternInlineIf, expression))
  if (length(matches[[1]]) != 5 || is.na(matches[[1]][1])) {
    stop(paste0("Can not parse expression '", expression, "'"))
  }
  return(list(field = matches[[1]][3], invert = trimws(toupper(matches[[1]][2])) == "NOT", pattern = etlutils::getBetweenQuotes(matches[[1]][4]), result = matches[[1]][5]))
}

convertTemplate <- function(tables_descriptions, script_rights_definition, result_file_name_column = "SCRIPTNAME", template_content = NA, template_name = NA, table_name = NA, column_name = NA, indentation = "", recursion = 0) {
  rights_first_row <- script_rights_definition[1]
  # Load SQL template
  content <- ifelse (is.na(template_content), loadTemplate(template_name), template_content)
  if (recursion == 0) {
    header <- createHeader(script_rights_definition)
    content <- paste0(header, content)
  }

  placeholders <- extractPlaceholders(content)

  for (placeholder in placeholders) {
    # replace complex placeholders

    if (startsWith(placeholder, "<%LOOP_TABS_")) {
      tables_content <- ""
      for (table_name in names(tables_descriptions)) {
        single_table_content <- convertTemplate(tables_descriptions, script_rights_definition, template_name = placeholder, table_name = table_name, recursion = recursion + 1)
        tables_content <- paste0(tables_content, single_table_content)
      }
      tables_content <- gsub("\n$", "", tables_content)
      content <- gsub(placeholder, tables_content, content)

    } else if (startsWith(placeholder, "<%LOOP_COLS_")) {
      single_table_description <- tables_descriptions[[table_name]]
      columns_content <- ""
      indentation <- etlutils::getWordIndentation(content, placeholder)
      for (row in seq_len(nrow(single_table_description))) {
        column_row <- single_table_description[row]
        single_column_content <- convertTemplate(tables_descriptions, script_rights_definition, template_name = placeholder, table_name = table_name, recursion = recursion + 1)
        single_column_content_placeholders <- extractPlaceholders(single_column_content)
        for (sub_placeholder in single_column_content_placeholders) {
          # parse the columns value separator. this is a special tag which defines the separator
          # between all lines, but not after the last line. (style: <%SEP = " AND"%>)
          if (grepl("^<%SEP\\s*=\\s*\".*\"\\s*%>$", sub_placeholder)) {
            replace = if (row == nrow(single_table_description)) "" else etlutils::getBetweenQuotes(sub_placeholder)
            single_column_content <- gsub(sub_placeholder, replace, single_column_content)
          } else {
            sub_placeholder_name <- extractPlaceholderName(sub_placeholder)
            if (sub_placeholder_name %in% names(column_row)) {
              single_column_content <- gsub(sub_placeholder, column_row[[sub_placeholder_name]], single_column_content)
            }
          }
        }
        # set indentation, but not for the first column (first column gets its indentation from
        # the line with the placeholder itself
        indent <- ifelse(row == 1, "", indentation)
        columns_content <- paste0(columns_content, indent, single_column_content)
      }
      columns_content <- gsub("\n$", "", columns_content)
      content <- gsub(placeholder, columns_content, content)

    } else if (startsWith(placeholder, "<%LOOP_DEF_")) {
      rights_content <- ""
      for (row in seq_len(nrow(script_rights_definition))) {
        sub_content <- loadTemplate(placeholder)
        sub_content_placeholders <- extractPlaceholders(sub_content)
        rights_row <- script_rights_definition[row]
        for (sub_placeholder in sub_content_placeholders) {
          sub_placeholder_name <- extractPlaceholderName(sub_placeholder)
          if (sub_placeholder_name %in% names(rights_row)) {
            value <- rights_row[[sub_placeholder_name]]
            # missing values in the current rigths row are replaced by the value in the first row
            if (is.na(value)) value <- rights_first_row[[sub_placeholder_name]]
            sub_content <- gsub(sub_placeholder, value, sub_content)
          }
        }
        sub_content <- convertTemplate(tables_descriptions, script_rights_definition, template_content = sub_content, table_name = table_name, recursion = recursion + 1)
        rights_content <- paste0(rights_content, sub_content)
      }
      rights_content <- gsub("\n$", "", rights_content)
      content <- gsub(placeholder, rights_content, content)

    } else if (startsWith(placeholder, "<%TABLE_NAME")) {
      placeholder_name <- extractPlaceholderName(placeholder)
      name_index <- sub(".*_", "", placeholder_name)
      if (grepl("^\\d+$", name_index)) { # positive integer?
        name_index <- as.integer(name_index)
      } else {
        name_index <- 1
      }
      full_table_name <- getFullTableName(table_name, rights_first_row, name_index)
      content <- gsub(placeholder, full_table_name, content)

    } else if (placeholder == "<%SIMPLE_TABLE_NAME%>") {
      content <- gsub(placeholder, table_name, content)

    } else if (startsWith(toupper(placeholder), "<%IF ")) {
      condition_arguments <- parseIFExpression(placeholder)
      condition_compare_value <- rights_first_row[[condition_arguments$field]]
      if (is.na(condition_compare_value)) {
        condition_compare_value <- ""
      }
      if (( condition_arguments$invert && !grepl(condition_arguments$pattern, condition_compare_value, perl = TRUE)) ||
          (!condition_arguments$invert &&  grepl(condition_arguments$pattern, condition_compare_value, perl = TRUE))) {

        # quotes at the beginning of the result indicate that not a subtemplate name is given but
        # directly the content
        if (startsWith(condition_arguments$result, "\"")) {
          template_content <- condition_arguments$result
          template_name <- NA
        } else { # subtemplate is given (no quotes at the beginning)
          template_content <- NA
          template_name <- condition_arguments$result
        }
        condition_content <- convertTemplate(tables_descriptions, script_rights_definition, result_file_name_column, template_content, template_name, table_name, column_name, indentation, recursion = recursion + 1)
        condition_content <- gsub("^\"|\"$", "", condition_content)
        condition_content <- gsub("\n$", "", condition_content)
        content <- gsub(placeholder, condition_content, content, fixed = TRUE) # fixed because the condition_content itself contains a pattern
      } else {
        content <- removePlaceholderLines(content, placeholder)
      }

    } else {
      placeholder_name <- extractPlaceholderName(placeholder)
      if (placeholder_name %in% names(rights_first_row)) {
        content <- gsub(placeholder, rights_first_row[[placeholder_name]], content)
      }
    }
  }

  if (recursion == 0) {
    writeResultFile(rights_first_row[[result_file_name_column]], content)
  }
  # Write the modified content to the file
  return(content)
}

########
# Main #
########

loadDatabaseRightsAndConvertDefinition <- function() {

  rights_definition_file_name <- getRightsDefinitionFileName()
  rights_and_convert_definition <- etlutils::readExcelFileAsTableList(rights_definition_file_name)

  rights_definition_sheet_name <- getRightsDefinitionSheetName()
  convert_definition_sheet_name <- getConvertDefinitionSheetName()

  ### rights definition ###

  # read the excel file with the rigths and copy functions definition and extract the specific table
  rights_definition <- rights_and_convert_definition[[rights_definition_sheet_name]]

  # this are *exactly* the names of the columns in the excel file
  rights_definition_columns <- getRightsDefinitionColumnNames()

  rights_definition <- etlutils::removeTableHeader(rights_definition, rights_definition_columns)

  if (!etlutils::isValidTable(rights_definition)) {
    stop(paste0("Could not find a row with the follwing entries in file '",
                rights_definition_file_name, "' in sheet '", rights_definition_sheet_name, "':\n",
                paste0(rights_definition_columns, collapse = ", "), "\n",
                "Hint: If the column names are changed in the Excel file, then replace the same ",
                "strings here in this R-script."))
  }

  rights_definition <- etlutils::removeRowsWithNAorEmpty(rights_definition)
  rights_definition[, TABLE_DESCRIPTION := trimws(TABLE_DESCRIPTION)]
  rights_definition <- etlutils::splitTableToList(rights_definition, rights_definition_columns$TABLE_DESCRIPTION)
  for (i in 1:length(rights_definition)) {
    rights_definition[[i]] <- etlutils::splitTableToList(rights_definition[[i]], rights_definition_columns$SCRIPTNAME)
  }

  ### convert definition ###

  convert_definition <- rights_and_convert_definition[[convert_definition_sheet_name]]
  if (etlutils::isValidTable(convert_definition)) {
    # this are *exactly* the names of the columns in the excel file
    convert_definition_columns <- getConvertDefinitionColumnNames()
    convert_definition <- etlutils::removeTableHeader(convert_definition, convert_definition_columns)
    if (etlutils::isValidTable(convert_definition)) {
      convert_definition <- etlutils::removeRowsWithNAorEmpty(convert_definition)
      convert_definition <- etlutils::splitTableToList(convert_definition, convert_definition_columns$TABLE_DESCRIPTION)
    } else {
      message("No valid convert definition found -> we use all Table Descriptions in the original style.")
      convert_definition <- list()
    }
  }

  return(list(rights_definition = rights_definition, convert_definition = convert_definition))
}

createDatabaseScriptsFromTemplates <- function() {
  rights_and_convert_definition <- loadDatabaseRightsAndConvertDefinition()
  full_rights_definition <- rights_and_convert_definition$rights_definition
  for (i in seq_along(full_rights_definition)) {
    table_description_path_with_sheet_name <- names(full_rights_definition)[i]
    # Extract worksheet name from table_description_path_with_sheet_name (given in square brackets after the path)
    table_description_sheet_name <- sub(".*\\[(.*)\\]$", "\\1", table_description_path_with_sheet_name)
    # No worksheet name given in square brackets? -> table_description_sheet_name is the unchanged
    # full table_description_path_with_sheet_name -> set the default sheet name
    if (table_description_sheet_name == table_description_path_with_sheet_name) {
      table_description_path <- table_description_sheet_name
      table_description_sheet_name <- "table_description" # default
    } else { # remove the worksheet name from the path
      table_description_path <- sub("\\[.*\\]$", "", table_description_path_with_sheet_name)
    }
    table_description_convert_definition <- rights_and_convert_definition$convert_definition[[table_description_path_with_sheet_name]]
    table_description <- getConvertedTableDescriptionSplittedByTableName(table_description_path, table_description_sheet_name, table_description_convert_definition)
    rights_definition <- full_rights_definition[[i]]
    for (scriptname in names(rights_definition)) {
      script_rights_definition <- rights_definition[[scriptname]]
      template <- script_rights_definition[1]$TEMPLATE
      copy_function_template <- script_rights_definition[1]$COPY_FUNC_TEMPLATE

      convertTemplate(table_description, script_rights_definition, "SCRIPTNAME", template_name = template)
      if (!is.na(copy_function_template)) {
        convertTemplate(table_description, script_rights_definition, "COPY_FUNC_SCRIPTNAME", template_name = copy_function_template)
      }
    }
  }

}
