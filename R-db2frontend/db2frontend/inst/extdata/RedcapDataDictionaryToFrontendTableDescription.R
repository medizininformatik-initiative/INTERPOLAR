# Change the working directory to the main directory
if (grepl('/db2frontend$', getwd())) setwd("../..")
if (grepl('/R-db2frontend$', getwd())) setwd("../")

# Free memory
rm(list = ls())

library(data.table)
library(openxlsx)

# Load the CSV file as a data.table
dt <- fread("./R-db2frontend/db2frontend/inst/extdata/INTERPOLARDev_DataDictionary_mit_Datentypen_2025-03-04.csv", encoding = "UTF-8")

# Rename columns
column_names <- c("Variable / Field Name", "Form Name", "Field Type", "Field Label", "Text Validation Type OR Show Slider Number")
new_names <- c("COLUMN_NAME", "TABLE_NAME", "COLUMN_TYPE", "COLUMN_DESCRIPTION", "VALIDATION_TYPE")
setnames(dt, column_names, new_names)

# Keep only specific TABLE_NAME values (after renaming columns)
allowed_tables <- c("patient", "fall", "medikationsanalyse", "mrpdokumentation_validierung")
dt <- dt[TABLE_NAME %in% allowed_tables | TABLE_NAME == ""]

# Remove unnecessary columns (keep only the renamed ones)
dt <- dt[, ..new_names]

# Remove rows with Field Type == "descriptive"
dt <- dt[COLUMN_TYPE != "descriptive"]

# Mapping Field Type and Validation Type to PostgreSQL-compatible types
type_mapping <- list(
  "text" = "varchar",
  "notes" = "varchar",
  "dropdown" = "varchar",
  "radio" = "varchar",
  "yesno" = "varchar",
  "checkbox" = "varchar",
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

# # Fill missing TABLE_NAME values with the last observed non-missing value (LOCF)
# dt[, TABLE_NAME := fifelse(TABLE_NAME == "", NA_character_, TABLE_NAME)]  # Convert empty strings to NA
# dt[, TABLE_NAME := zoo::na.locf(TABLE_NAME, na.rm = FALSE)]  # Alternative ohne nafill()

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

# Split by TABLE_NAME, add standard rows, and recombine
dt_list <- split(dt, by = "TABLE_NAME", keep.by = FALSE)

dt_list <- lapply(names(dt_list), function(tbl) {
  table_data <- dt_list[[tbl]]
  table_data <- rbind(data.table(TABLE_NAME = tbl, standard_rows), table_data, fill = TRUE)
  return(table_data)
})

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

# Save the final data.table as an Excel file
openxlsx::write.xlsx(dt, "./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description_generated.xlsx", colNames = TRUE)


