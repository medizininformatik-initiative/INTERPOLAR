# Change the working directory to the main directory
if (grepl('/db2frontend$', getwd())) setwd("../..")
if (grepl('/R-db2frontend$', getwd())) setwd("../")

# Free memory
rm(list = ls())

library(data.table)
library(openxlsx)
library(etlutils)

# Load the CSV file as a data.table
dt <- fread("./R-db2frontend/db2frontend/inst/extdata/Frontend_DataDictionary.csv", encoding = "UTF-8")

# Rename columns
column_names <- c("Variable / Field Name", "Form Name", "Field Type", "Field Label",
                  "Text Validation Type OR Show Slider Number", "Choices, Calculations, OR Slider Labels")
new_names <- c("COLUMN_NAME", "TABLE_NAME", "COLUMN_TYPE", "COLUMN_DESCRIPTION",
               "VALIDATION_TYPE", "CHOICES")
setnames(dt, column_names, new_names)

# Remove unnecessary columns (keep only the renamed ones)
dt <- dt[, ..new_names]

# Remove rows with Field Type == "descriptive"
dt <- dt[COLUMN_TYPE != "descriptive"]

# **Remove rows where COLUMN_NAME matches TABLE_NAME with "_fe_id" suffix**
dt <- dt[!(grepl("_fe_id$", COLUMN_NAME) & paste0(TABLE_NAME, "_fe_id") == COLUMN_NAME)]


# **Expand only checkbox fields into multiple rows using a for-loop**
expanded_rows <- data.table()  # Leere data.table für das Ergebnis
for (i in 1:nrow(dt)) {
  row <- dt[i]

  # Falls es eine Checkbox ist, spalte sie in mehrere Zeilen auf
  if (row$COLUMN_TYPE == "checkbox") {
    options <- unlist(strsplit(row$CHOICES, " \\| "))  # Split bei " | "

    # Erstelle für jede Option eine neue Zeile
    for (option in options) {
      option <- gsub(",", " -", option)  # Ersetze Komma durch " -"
      option_number <- gsub(" -.*", "", option)  # Extrahiere die Nummer vor dem Trennzeichen
      new_row <- data.table(
        TABLE_NAME = row$TABLE_NAME,
        COLUMN_NAME = paste0(row$COLUMN_NAME, "___", option_number),
        COLUMN_DESCRIPTION = option,  # Behalte den vollen Text
        COLUMN_TYPE = row$COLUMN_TYPE,  # Behalte den ursprünglichen Typ für Mapping
        VALIDATION_TYPE = row$VALIDATION_TYPE
      )
      expanded_rows <- rbindlist(list(expanded_rows, new_row), fill = TRUE)  # Sichere Kombination
    }
  } else {
    expanded_rows <- rbindlist(list(expanded_rows, as.data.table(row[, .(TABLE_NAME, COLUMN_NAME, COLUMN_DESCRIPTION, COLUMN_TYPE, VALIDATION_TYPE)])), fill = TRUE)
  }
}
# Update dt with expanded rows
dt <- expanded_rows

# Mapping Field Type and Validation Type to PostgreSQL-compatible types
type_mapping <- list(
  "text" = "varchar",
  "notes" = "varchar",
  "dropdown" = "varchar",
  "radio" = "varchar",
  "yesno" = "varchar",
  "checkbox" = "varchar",  # Checkboxen bleiben varchar
  "calc" = "double precision",
  "integer" = "int",
  "number" = "double precision",
  "date" = "timestamp",
  "date_ymd" = "date",
  "sql" = "varchar"
)

validation_mapping <- list(
  "date_ymd" = "date",
  "datetime_ymd" = "timestamp",
  "datetime_seconds_ymd" = "timestamp",
  "integer" = "int",
  "number" = "double precision"
)

# Convert COLUMN_TYPE using primary mapping
dt[, COLUMN_TYPE := type_mapping[COLUMN_TYPE]]

# If COLUMN_TYPE is unspecific (varchar), check if VALIDATION_TYPE provides better information
dt[, COLUMN_TYPE := fifelse(
  COLUMN_TYPE == "varchar" & !is.na(VALIDATION_TYPE) & VALIDATION_TYPE %in% names(validation_mapping),
  validation_mapping[VALIDATION_TYPE],
  COLUMN_TYPE
)]

# Remove any existing rows that match the standard column names to avoid duplicates
standard_col_names <- c("record_id", "redcap_repeat_instrument", "redcap_repeat_instance", "redcap_data_access_group")
dt <- dt[!(COLUMN_NAME %in% standard_col_names)]

# Define standard rows to be inserted at the beginning of each table
standard_rows <- data.table(
  COLUMN_NAME = standard_col_names,
  COLUMN_DESCRIPTION = c(
    "Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap",
    "Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation",
    "Frontend internal dataset management - Instance of the instrument - Numeric: 1…n",
    "Function as dataset filter by stations"
  ),
  COLUMN_TYPE = "varchar"
)

# Split by TABLE_NAME
dt_list <- split(dt, by = "TABLE_NAME", keep.by = FALSE)

# Iterate over tables and add standard rows + _complete row
for (tbl in names(dt_list)) {
  table_data <- dt_list[[tbl]]

  # Add standard rows at the beginning
  table_data <- rbind(data.table(TABLE_NAME = tbl, standard_rows), table_data, fill = TRUE)

  # Add _complete row at the end
  complete_row <- data.table(
    TABLE_NAME = tbl,
    COLUMN_NAME = paste0(tbl, "_complete"),
    COLUMN_DESCRIPTION = "Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete",
    COLUMN_TYPE = "varchar"
  )
  table_data <- rbind(table_data, complete_row, fill = TRUE)

  # Update dt_list
  dt_list[[tbl]] <- table_data
}

# Combine all tables back into one data.table
dt <- rbindlist(dt_list, fill = TRUE)

# Ensure TABLE_NAME only appears in the first row of each table, replace NA with empty strings
dt[, TABLE_NAME := fifelse(duplicated(TABLE_NAME), "", TABLE_NAME)]

# Replace any remaining NA with empty strings (ensures consistency in Excel exports)
dt[is.na(TABLE_NAME), TABLE_NAME := ""]

# Keep only relevant columns and ensure correct order
dt <- dt[, .(TABLE_NAME, COLUMN_NAME, COLUMN_DESCRIPTION, COLUMN_TYPE)]

# Remove HTML tags from COLUMN_DESCRIPTION
dt[, COLUMN_DESCRIPTION := gsub("<[^>]+>", "", COLUMN_DESCRIPTION)]

# Add the "This file is generated..." header to the resut file
header <- c(
  "Hint",
  "This file is generated by the R script 'RedcapDataDictionaryToFrontend'. Do not change it directly.",
  "If you want to add or remove columns for a resource or an entire table, change the Redcap exported",
  "'Frontend_DataDictionary.csv' and execute the generation process via the init script in the db2frontend module."
)
expanded_table_description <- etlutils::addTextHeaderToTable(dt, header, insert_column_names_below_header = TRUE)

# Save the final data.table as an Excel file
table_description_file_name <- "./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx"
etlutils::writeExcelFile(list("frontend_table_description" = expanded_table_description), table_description_file_name, with_column_names = FALSE)
message("Frontend Table Description is written to ", normalizePath(table_description_file_name))
