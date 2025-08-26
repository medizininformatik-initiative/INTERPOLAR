##############
# enc_lvl_1 = Einrichtungskontakt
# enc_lvl_2 = Abteilungskontakt
# enc_lvl_3 = Versorgungsstellenkontakt
##############

.test_env <- new.env(parent = emptyenv())

testSetResourceTables <- function(resource_tables) {
  # Set the resources in the environment
  assign("resource_tables", resource_tables, envir = .test_env)
}

testGetResourceTables <- function() {
  # Get the resources from the environment
  get("resource_tables", envir = .test_env)
}

testGetResourceTable <- function(resource_name) {
  # Get a specific resource table from the environment
  resource_tables <- get("resource_tables", envir = .test_env)
  return(resource_tables[[resource_name]])
}

testSetResourceTable <- function(resource_name, resource_table) {
  # Set a specific resource table in the environment
  resource_tables <- get("resource_tables", envir = .test_env)
  resource_tables[[resource_name]] <- resource_table
  assign("resource_tables", resource_tables, envir = .test_env)
}

testEnsureRAWId <- function(id) {
  if (!startsWith(id, "[1]")) {
    id <- paste0("[1]", id)
  }
  return(id)
}

testEnsureSimpleId <- function(id) {
  if (startsWith(id, "[1]")) {
    id <- sub("^\\[1\\]", "", id)
  }
  return(id)
}

enc_level_1_id_pattern <- "-E-\\d+$"
enc_level_2_id_pattern <- "-A-\\d+$"
enc_level_3_id_pattern <- "-V-\\d+$"

#
# Add encounters with type "Versorgungstellenkontakt"
#
testAddEncounterLevel3 <- function(dt_enc) {
  pattern = "-A-(\\d+)$" # Pattern to match the end of the enc_id for duplication
  colnames_pattern_servicetype <- "^enc_servicetype_" # Pattern for service type columns

  enc_servicetype_colnames <- getColNames(dt_enc, colnames_pattern_servicetype)

  rows_to_duplicate <- dt_enc[grepl(pattern, enc_id)]
  if (nrow(rows_to_duplicate) == 0) return(dt_enc)

  rows_to_duplicate[, enc_partof_ref := sub("(Encounter/).*",
                                            paste0("\\1", sub(".*]", "", enc_id)), enc_partof_ref)]
  rows_to_duplicate[, enc_id := sub(pattern, "-A-\\1-V-\\1", enc_id)]
  rows_to_duplicate[, enc_type_code := sub("\\](.*)", "]versorgungsstellenkontakt", enc_type_code)]
  rows_to_duplicate[, enc_type_display := sub("\\](.*)", "]Versorgungsstellenkontakt", enc_type_display)]
  rows_to_duplicate[, (enc_servicetype_colnames) := NA]
  rows_to_duplicate[, enc_location_physicaltype_code := "[1.1.1.1]ro ~ [2.1.1.1]bd"]

  dt_enc <- rbind(dt_enc, rows_to_duplicate)
  return(dt_enc)
}

#' Filter raw resource tables based on patient IDs
#'
#' This function filters resource tables from `resource_tables` based on patient IDs provided as input.
#' It extracts the actual patient identifiers from the input using `etlutils::getAfterLastSlash()`
#' and constructs different reference formats depending on the resource type. The function supports
#' different types of patient identifier columns and applies filtering accordingly.
#'
#' - **Patient references (`patient_ref`)** are matched against `"[1.1]Patient/"` followed by the
#'   patient ID.
#' - **Patient tables (`pat_id`)** use a different reference format `"[1]"` followed by the patient ID.
#' - **Ward PID tables (`pid`)** are matched directly against the extracted patient IDs.
#' - **Non-patient referencing tables** (e.g., `Location`, `Medication`) are returned unfiltered.
#'
#' @param patient_ids A character vector representing patient IDs (e.g., `c("UKB-0001", "UKB-0002")`).
#'
#' @return A named list of `data.table` objects, where each table is filtered based on patient
#'         identifiers if applicable.
#'
testPrepareRAWResources <- function(patient_ids) {
  filtered_resources <- list()
  ids <- etlutils::getAfterLastSlash(patient_ids)
  refs <- paste0("[1.1]Patient/", ids)
  resource_tables <- testGetResourceTables()
  for (resource_name in names(resource_tables)) {
    pid_column <- if (resource_name == "pids_per_ward") "patient_id" else etlutils::fhirdbGetPIDColumn(resource_name)
    resource_table <- resource_tables[[resource_name]]
    if (pid_column %in% names(resource_table)) {
      filtered_resources[[resource_name]] <- if (endsWith(pid_column, "patient_ref")) {
        resource_table[get(pid_column) %in% refs]
      } else if (pid_column == "pat_id") { # Patient table
        resource_table[get(pid_column) %in% paste0("[1]", ids)]
      } else if (pid_column == "patient_id") { # pids_per_war_table
        resource_table[get(pid_column) %in% ids]
      }
    } else { # non patient referencing tables (Location, Medication...)
      filtered_resources[[resource_name]] <- resource_table
    }
  }
  # Add template for encounter table
  enc_templates <- data.table::copy(resource_tables[["Encounter"]])
  # Filter encounter IDs based on the provided patient IDs
  # Filter for the first encounters with level 1 id
  enc_templates <- enc_templates[grepl("-E-1", enc_id)]
  # Filter for the first encounters for the first entry
  enc_templates <- enc_templates[grepl("-1$", enc_id)]
  # Add encounters with type "Versorgungstellenkontakt"
  enc_templates <- testAddEncounterLevel3(enc_templates)

  # Change encounter data
  enc_templates <- enc_templates[grepl("-(A|V)-1$", enc_id),
                                 enc_partof_ref := paste0("[1.1]Encounter/", sub("-(A|V)-1$", "", enc_id))]
  enc_templates[, enc_status := "[1]in-progress"]
  enc_templates[, enc_period_start := getDebugDatesRAWDateTime(-0.5)]
  enc_templates[, enc_period_end := NA]
  enc_templates[, enc_meta_lastupdated := getDebugDatesRAWDateTime(-0.1)]

  enc_templates <- enc_templates[order(enc_id)]

  filtered_resources[["Encounter"]] <- filtered_resources[["Encounter"]][0]
  filtered_resources[["pids_per_ward"]] <- filtered_resources[["pids_per_ward"]][0]

  assign("enc_templates", enc_templates, envir = .test_env)

  testSetResourceTables(filtered_resources)
}

#' Retain specific resource tables while clearing others
#'
#' This function retains only the specified tables from `resource_tables`, while all other tables
#' are cleared by removing all rows but keeping the structure. The table `"pids_per_ward"` is
#' always retained by default.
#'
#' @param ... Character strings representing table names that should be retained.
#'
#' @return A modified named list of `data.table` objects, where only the specified tables remain
#'         unchanged, and all others are cleared (empty but with the same structure).
#'
testRetainRAWTables <- function(...) {
  table_names <- c(..., "pids_per_ward")
  for (name in names(resource_tables)) {
    if (!(name %in% table_names)) {
      resource_tables[[name]] <- resource_tables[[name]][0]  # Remove all rows, keep structure
    }
  }
  return(resource_tables)
}

#' Format a datetime as RAW timestamp with a fixed offset
#'
#' This function formats a given datetime into the RAW timestamp format used in the system.
#' If no datetime is provided, the current system time (`Sys.time()`) is used.
#' The function subtracts the specified number of days from the given datetime and returns it
#' in the format: `"[1.1]YYYY-MM-DDTHH:MM:SS+02:00"`, where the offset represents the system's timezone.
#'
#' @param datetime A `POSIXct` object representing the datetime to be formatted.
#'                 Defaults to the current system time (`Sys.time()`).
#' @param offset_days_minus An integer specifying how many days should be subtracted from `datetime`.
#'                    Defaults to `2`.
#'
#' @return A character string with the formatted datetime.
#'
getFormattedRAWDateTime <- function(datetime = DEBUG_DATES[DEBUG_DAY], offset_days_minus = 1) {
  datetime <- as.POSIXct(datetime)
  # Subtract the specified number of days from the given datetime
  datetime <- datetime - offset_days_minus * 86400

  # Format as "[1.1]YYYY-MM-DDTHH:MM:SS+02:00"
  format(datetime, "[1.1]%Y-%m-%dT%H:%M:%S%z")
}

#' Get a RAW-formatted datetime from DEBUG_DATES with additive offset
#'
#' Returns a RAW-formatted datetime string based on \code{DEBUG_DATES[debug_date_index]} and an
#' additive day offset. Internally delegates to \code{getFormattedRAWDateTime()} and passes the
#' negated offset so that positive values in \code{offset_days} shift the datetime forward.
#'
#' @param offset_days Integer number of days to add to the selected debug date. Defaults to \code{0}.
#' @param debug_date_index Integer index into \code{DEBUG_DATES} selecting the base datetime.
#'
#' @return Character string in the RAW datetime format produced by
#'   \code{getFormattedRAWDateTime()}.
#'
#' @examples
#' \dontrun{
#' # Shift DEBUG_DATES[1] by +2 days and format as RAW timestamp
#' getDebugDatesRAWDateTime(offset_days = 0.2, debug_date_index = 1)
#'
#' # Use the date as-is (no shift)
#' getDebugDatesRAWDateTime(debug_date_index = 2)
#' }
#'
#' @export
getDebugDatesRAWDateTime <- function(offset_days = 0, debug_date_index = DEBUG_DAY) {
  datetime <- DEBUG_DATES[debug_date_index]
  # Get the formatted RAW datetime
  raw_datetime <- getFormattedRAWDateTime(datetime, -as.numeric(offset_days))
  # Return the formatted datetime
  return(raw_datetime)
}


#' Update values in a data.table based on patient ID and column name pattern
#'
#' This function updates one or more columns in a `data.table` (`table`) based on a given patient ID (`pid`).
#' The row selection criteria depend on the structure of the table:
#'
#' - If the table contains a `pat_id` column, rows are selected where `pat_id` matches `pid` or `"[1]"` followed by `pid`.
#' - Otherwise, if a column ending in `_patient_ref` exists, rows are selected where the extracted patient ID
#'   (obtained via `etlutils::getAfterLastSlash()`) matches `pid`.
#' - If no such identifying columns exist, the table remains unchanged.
#'
#' The function allows updating multiple columns that match a given pattern, including exact column names.
#'
#' @param table A `data.table` containing patient data.
#' @param pid A character string representing the patient ID to match.
#' @param pattern A character string specifying a pattern or exact column name to match.
#' @param new_value The new value to assign to the selected rows in the matching columns.
#'
#' @return The modified `data.table` with updated values in the specified columns.
#'
changeDataForPID <- function(table, pid, pattern, new_value) {
  colnames <- names(table)

  # Identify rows to update
  rows_to_update <- NULL

  if ("pat_id" %in% colnames) {
    rows_to_update <- which(table$pat_id == pid | table$pat_id == paste0("[1]", pid))
  } else {
    ref_col <- colnames[endsWith(colnames, "_patient_ref")]

    if (length(ref_col) > 0) {
      ref_col <- ref_col[1]  # Take the first matching column if multiple exist
      extracted_pid <- etlutils::getAfterLastSlash(table[[ref_col]])
      rows_to_update <- which(extracted_pid == pid)
    } else {
      return(table) # No matching column found, return unchanged data.table
    }
  }

  # Identify columns matching the pattern (supporting exact names)
  matching_columns <- colnames[colnames == pattern | grepl(pattern, colnames)]

  if (length(matching_columns) > 0 && length(rows_to_update) > 0) {
    # Update matching columns
    table[rows_to_update, (matching_columns) := lapply(.SD, function(x) new_value), .SDcols = matching_columns]
  }
  return(table)
}

# Change data for a specific patient ID in the Encounter table
testChangeDataForPIDEncounter <- function(pid, pattern, new_value) {
  # Get the Encounter table
  dt_enc <- testGetResourceTable("Encounter")

  # Change data for the specified PID
  dt_enc <- changeDataForPID(dt_enc, pid, pattern, new_value)

  # Update the Encounter table in the environment
  testSetResourceTable("Encounter", dt_enc)

  return(dt_enc)
}

#' Set enc_period_start for all encounters of given patients
#'
#' @param pats A character vector of patient IDs (z.B. c("UKB-0001", "UKB-0002")).
#' @return Updated Encounter table (data.table).
setEncounterStartDates <- function(pats) {
  for (i in seq_along(pats)) {
    pid <- pats[i]
    new_value <- getDebugDatesRAWDateTime(-i, 1)
    testChangeDataForPIDEncounter(pid, "enc_period_start", new_value)
  }
  # return updated Encounter table for inspection
  return(testGetResourceTable("Encounter"))
}

#' Get column names from a data.table matching a given pattern
#'
#' This function returns all column names from a \code{data.table} that match a given
#' regular expression pattern.
#'
#' @param dt A \code{data.table} from which the column names will be extracted.
#' @param pattern A character string containing a regular expression to match against
#'   column names.
#'
#' @return A character vector containing the names of all matching columns.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(enc_diagnosis_a = 1, enc_diagnosis_b = 2, enc_servicetype_x = 3)
#' getColNames(dt, "^enc_diagnosis_")
#' getColNames(dt, "^enc_servicetype_")
#'
#' @export
getColNames <- function(dt, pattern) {
  grep(pattern, names(dt), value = TRUE)
}

#' Extract values from a RAW-formatted column
#'
#' This function extracts the part of each string value that comes **after** the first closing
#' square bracket (`]`). If there is no closing bracket in a value, the value is returned unchanged.
#'
#' Typical RAW values may look like `"[1.2]2024-08-13T10:15:00+02:00"`, where the prefix in square
#' brackets contains numeric components separated by dots. The shortest valid form could be
#' a single digit in square brackets (e.g., `"[5]"`).
#'
#' @param dt_raw A \code{data.table} containing the column to be processed.
#' @param column_name A character string with the name of the column to process.
#'
#' @return A character vector with the extracted values.
#'
#' @examples
#' library(data.table)
#' dt <- data.table(raw_col = c("[1.2]2024-08-13", "[5]", "no_brackets"))
#' extractValueFromRAW(dt, "raw_col")
#' # Returns: c("2024-08-13", "", "no_brackets")
#'
#' @export
extractValueFromRAW <- function(dt_raw, column_name) {
  values <- dt_raw[[column_name]]
  sub("^\\[[0-9]+(\\.[0-9]+)*\\](.*)$", "\\2", values)
}

# Remove multiple diagnoses from the Encounter table
testRemoveMultipleDiagnoses <- function() {
  # Identify columns starting with "enc_diagnosis_" as vector of column names
  colnames_pattern_diagnosis <- "^enc_diagnosis_"
  dt_enc <- testGetResourceTable("Encounter")
  enc_diagnosis_cols <- getColNames(dt_enc, colnames_pattern_diagnosis)

  # Remove multiple diagnoses to prevent splitting the main encounter to multiple
  # lines after fhir_melt (= set first value before " ~ " and remove the rest)
  dt_enc[, (enc_diagnosis_cols) := lapply(.SD, function(x) sub(" ~ .*", "", x)), .SDcols = enc_diagnosis_cols]
}

# Set bed and room for a specific encounter
testSetBedAndRoom <- function(dt_enc, room, bed) {
  # Get the encounter ID of the Versorgungsstellenkontakt
  enc_level_3_id <- dt_enc$enc_id[grepl(enc_level_3_id_pattern, dt_enc$enc_id)]

  dt_enc[enc_id == enc_level_3_id,
         enc_location_identifier_value := paste0("[1.1.1.1]", room, " ~ [2.1.1.1]", bed)]
  return(dt_enc)
}

# Extract patient ID from encounter ID
extractPID <- function(enc_ids) {
  enc_ids <- as.character(enc_ids)
  no_prefix <- gsub("^\\[[0-9]+\\]", "", enc_ids)
  pids <- sub("-E-.*", "", no_prefix)
  return(pids)
}

#' Update ward assignment for a patient in pids_per_ward
#'
#' @param enc_id Encounter ID to assign
#' @param ward_names Ward name(s) to assign
#' @return Modified data.table with updated ward assignment
testUpdateWard <- function(enc_ids, ward_names = NULL) {
  pids_per_wards <- testGetResourceTable("pids_per_ward")
  pids <- unique(extractPID(enc_ids))

  pids_per_wards <- pids_per_wards[!patient_id %in% pids]

  if (!is.null(ward_names)) {
    new_pids_rows <- data.table::data.table(
      patient_id   = extractPID(enc_ids),
      encounter_id = enc_ids,
      ward_name    = ward_names
    )
    pids_per_wards <- rbind(pids_per_wards, new_pids_rows)
  }

  testSetResourceTable("pids_per_ward", pids_per_wards)
  return(pids_per_wards)
}

# Helper function to increment encounter ID based on level
incrementEncounterId <- function(x, level) {
  if (grepl("-E-\\d+$", x)) {
    # Level 1: ...-E-n
    pattern <- "^(.*-E-)(\\d+)$"
    parts <- sub(pattern, "\\1|\\2", x)
    split <- strsplit(parts, "\\|")[[1]]

    prefixE <- split[1]
    numE    <- as.integer(split[2])
    numA    <- 0
    numV    <- 0

  } else if (grepl("-E-\\d+-A-\\d+$", x)) {
    # Level 2: ...-E-n-A-m
    pattern <- "^(.*-E-)(\\d+)(-A-)(\\d+)$"
    parts <- sub(pattern, "\\1|\\2|\\3|\\4", x)
    split <- strsplit(parts, "\\|")[[1]]

    prefixE <- split[1]
    numE    <- as.integer(split[2])
    midA    <- split[3]
    numA    <- as.integer(split[4])
    numV    <- 0

  } else if (grepl("-E-\\d+-A-\\d+-V-\\d+$", x)) {
    # Level 3: ...-E-n-A-m-V-k
    pattern <- "^(.*-E-)(\\d+)(-A-)(\\d+)(-V-)(\\d+)$"
    parts <- sub(pattern, "\\1|\\2|\\3|\\4|\\5|\\6", x)
    split <- strsplit(parts, "\\|")[[1]]

    prefixE <- split[1]
    numE    <- as.integer(split[2])
    midA    <- split[3]
    numA    <- as.integer(split[4])
    midV    <- split[5]
    numV    <- as.integer(split[6])
  } else {
    stop("Encounter-ID Format nicht erkannt: ", x)
  }

  # Increment based on level
  if (level == 1) {
    numE <- numE + 1
    numA <- 1
    numV <- 1
    new_id <- paste0(prefixE, numE)
  } else if (level == 2) {
    numA <- numA + 1
    numV <- 1
    new_id <- paste0(prefixE, numE, midA, numA)
  } else if (level == 3) {
    numV <- numV + 1
    new_id <- paste0(prefixE, numE, midA, numA, midV, numV)
  } else {
    stop("Ungültiges Level: ", level)
  }

  return(new_id)
}

# Get the last encounter of a patient in level-3
testGetEncounterLevel <- function(pid, enc_level, last_only = TRUE) {
  dt_enc <- testGetResourceTable("Encounter")

  pid_plain <- gsub("^\\[[0-9]+\\]", "", pid)   # z.B. "UKB-0001"
  pid_prefix <- paste0("\\[\\d+\\]", pid_plain) # z.B. "\[1\]UKB-0001"

  if (enc_level == 1) {
    regex_pattern <- paste0("(^", pid_plain, "-E-\\d+$)|(^", pid_prefix, "-E-\\d+$)")
  } else if (enc_level == 2) {
    regex_pattern <- paste0("(^", pid_plain, "-E-\\d+-A-\\d+$)|(^", pid_prefix, "-E-\\d+-A-\\d+$)")
  } else if (enc_level == 3) {
    regex_pattern <- paste0("(^", pid_plain, "-E-\\d+-A-\\d+-V-\\d+$)|(^", pid_prefix, "-E-\\d+-A-\\d+-V-\\d+$)")
  } else {
    stop("Invalid encounter level: ", enc_level)
  }

  dt_enc <- dt_enc[grepl(regex_pattern, enc_id)]

  if (last_only && nrow(dt_enc) > 0) {
    # Return only the last encounter of this patient
    dt_enc <- dt_enc[nrow(dt_enc)]
  }
  return(dt_enc)
}

# Get encounter templates for a specific patient ID
getEncounterTemplates <- function(pid, encounter_level = NA){
  enc_templates <- get("enc_templates", envir = .test_env)[enc_patient_ref == paste0("[1.1]Patient/", pid)]
  if (!is.na(encounter_level)) {
    enc_templates <- enc_templates[[encounter_level]]
  }
  return(enc_templates)
}

# This function admits a patient (creates a new encounter for the patient)
testAdmission <- function(pid, room, bed, ward_name = NULL) {
  # Get the Encounter table
  dt_enc <- testGetResourceTable("Encounter")
  enc_templates <- getEncounterTemplates(pid)

  # Create a new encounter for the patient
  enc_level_1_index <- nrow(dt_enc[grepl(paste0("^\\[1\\]", pid, enc_level_1_id_pattern), enc_id)]) + 1

  # Set main encounter index in all 3 encounter ids
  enc_templates[, enc_id := gsub(paste0("\\[1\\]", pid, "-E-1"), paste0("[1]", pid, "-E-", enc_level_1_index), enc_id)]
  # Set encounter partof references in all 3 encounter ids
  part_of_ref_pattern <- paste0("\\[1.1\\]Encounter/", pid, "-E-")
  enc_templates[, enc_partof_ref := gsub(paste0(part_of_ref_pattern, "1"), paste0(part_of_ref_pattern, enc_level_1_index), enc_partof_ref)]
  # Set encounter start date to current debug day -0.5
  enc_templates[, enc_period_start := getDebugDatesRAWDateTime(-0.5)]
  enc_templates[, enc_meta_lastupdated := getDebugDatesRAWDateTime(-0.1)]

  # Set bed & room for Versorgungsstellenkontakt
  enc_templates <- testSetBedAndRoom(enc_templates, room, bed)

  # Update the ward information
  if (!is.null(ward_name)) {
    testUpdateWard(enc_ids = enc_templates$enc_id,
                   ward_names = ward_name)
  }

  # Append the new encounter to the Encounter table
  dt_enc <- data.table::rbindlist(list(dt_enc, enc_templates), use.names = TRUE)

  # Set the Encounter table back to the environment
  testSetResourceTable("Encounter", dt_enc)

  return(dt_enc)
}

# Helper: close the last open encounter of a given level and create a new one
# - dt_enc: Encounter table (data.table)
# - pid: patient ID
# - level: encounter level (2 = Abteilung, 3 = Versorgungsstelle)
# - room, bed: optional, only relevant for Versorgungsstellenkontakte
transferEncounterLevel <- function(dt_enc, pid, level, room = NULL, bed = NULL) {
  # Get the last open encounter of the given level
  enc_last <- testGetEncounterLevel(pid, enc_level = level)
  enc_id_last <- enc_last$enc_id

  # Close the old contact
  end_start_datetime <- getDebugDatesRAWDateTime(-0.5)
  dt_enc[enc_id == enc_id_last, `:=`(
    enc_status = "[1]finished",
    enc_period_end = end_start_datetime
  )]

  # Prepare the new contact
  enc_last[, enc_period_start := end_start_datetime]
  enc_last[, enc_period_end := NA]
  enc_last[, enc_status := "[1]in-progress"]
  enc_last[, enc_meta_lastupdated := getDebugDatesRAWDateTime(-0.1)]

  # Increment the encounter ID
  enc_last[, enc_id := incrementEncounterId(enc_id_last, level)]

  # Optionally set room and bed
  if (!is.null(room) && !is.null(bed)) {
    enc_last <- testSetBedAndRoom(enc_last, room, bed)
  }

  # Return both tables: updated dt_enc and the new row
  list(dt_enc = dt_enc, new_enc_row = enc_last)
}

# This function represents the transfer of a patient to another Versorgungsstelle
testTransferWardInternal <- function(pid, room = NULL, bed = NULL, ward_name = NULL) {
  dt_enc <- testGetResourceTable("Encounter")
  enc_level_3_rows <- transferEncounterLevel(dt_enc, pid, level = 3, room, bed)
  # Update the ward information
  testUpdateWard(enc_ids = enc_level_3_rows$new_enc_row[["enc_id"]],
                 ward_names = ward_name)
  # Merge the updated old contact and the new one into the Encounter table
  dt_enc <- data.table::rbindlist(list(enc_level_3_rows$dt_enc, enc_level_3_rows$new_enc_row), use.names = TRUE)
  testSetResourceTable("Encounter", dt_enc)
}

# This function represents the transfer of a patient to another Abteilung
testTransferWardDepartment <- function(pid, room = NULL, bed = NULL, ward_name = NULL) {
  dt_enc <- testGetResourceTable("Encounter")
  # Step 1: Transfer the Abteilungskontakte (level 2)
  enc_level_2_rows <- transferEncounterLevel(dt_enc, pid, level = 2)
  # Get the encounter index of the new Abteilungskontakt
  enc_level_2_row_index <- sub(".*-(\\d+)$", "\\1", enc_level_2_rows$new_enc_row[["enc_id"]])

  # Step 2: Transfer the Versorgungsstellenkontakte (level 3)
  enc_level_3_rows <- transferEncounterLevel(dt_enc, pid, level = 3, room = room, bed = bed)
  # Update the encounter ID of the new Versorgungsstellenkontakt to match the new Abteilungskontakt
  enc_level_3_rows$new_enc_row[, enc_id := sub("-A-\\d+-V-\\d+$", paste0("-A-", enc_level_2_row_index, "-V-1"), enc_id)]


  # Step 3: If ward name is given, update mapping
  testUpdateWard(enc_ids   = enc_level_3_rows$new_enc_row[["enc_id"]],
                 ward_names = ward_name)

  # Step 4: Merge all into Encounter table
  dt_enc <- data.table::rbindlist(
    list(enc_level_2_rows$new_enc_row, enc_level_3_rows$dt_enc, enc_level_3_rows$new_enc_row),
    use.names = TRUE
  )
  testSetResourceTable("Encounter", dt_enc)
}

# This function discharges a patient (closes all encounters of the current case)
testDischarge <- function(pid) {
  dt_enc <- testGetResourceTable("Encounter")

  # Get discharge datetime (0.5 days before current debug day)
  discharge_datetime <- getDebugDatesRAWDateTime(-0.5)

  pid_ref <- paste0("[1.1]Patient/", pid)

  # Close all encounters of this patient
  dt_enc[enc_patient_ref == pid_ref & enc_status != "finished", `:=`(
    enc_status = "[1]finished",
    enc_period_end = discharge_datetime,
    enc_meta_lastupdated = getDebugDatesRAWDateTime(-0.1)
  )]

  # Update the ward information
  enc_ids <- dt_enc[enc_patient_ref == pid_ref, enc_id]
  testUpdateWard(enc_ids = enc_ids, ward_names = NULL)

  # Save back to environment
  testSetResourceTable("Encounter", dt_enc)

  return(dt_enc)
}

#TODO: Können die Funktionen alle weg?
#############################
######OLD_FUNCTIONS##########
#############################


# startNewEncounter <- function(dt_enc, patient_id, encounter_number,
#                               room, bed, debug_day, start_offset = 0) {
#   # Construct encounter IDs
#   enc_id_level1 <- paste0("[1]", patient_id, "-E-", encounter_number)
#   enc_id_level2  <- paste0(enc_id_level1, "-A-1")
#   enc_id_level3   <- paste0(enc_id_level2, "-V-1")
#
#   # Update encounter status (in-progress, with custom start offset)
#   dt_enc <- testUpdateEncounterStatus(
#     dt_enc,
#     pid   = patient_id,
#     status = "[1]in-progress",
#     start  = getDebugDatesRAWDateTime(-0.5, DEBUG_DAY + start_offset),
#     end    = NA
#   )
#
#   # Replace enc_id (make sure new Encounter number is applied everywhere)
#   dt_enc <- dt_enc[, enc_id := gsub(paste0("\\[1\\]", patient_id, "-E-1"), enc_id_level1, enc_id)]
#   # Set bed & room for Versorgungsstellenkontakt
#   dt_enc <- testSetBedAndRoom(dt_enc, enc_id_level3, room, bed)
#   # Update references
#   dt_enc <- dt_enc[enc_id == enc_id_level2,
#                    enc_partof_ref := paste0("[1.1]Encounter/", patient_id, "-E-", encounter_number)]
#   dt_enc <- dt_enc[enc_id == enc_id_level3,
#                    enc_partof_ref := paste0("[1.1]Encounter/", enc_id_level2)]
#   return(dt_enc)
# }

# startNewEncounter <- function(dt_enc, patient_id, encounter_number,
#                               room, bed, debug_day, start_offset = 0) {
#   # Construct encounter IDs
#   base_enc_id <- paste0("[1]", patient_id, "-E-", encounter_number)
#   abt_enc_id  <- paste0(base_enc_id, "-A-1")
#   vs_enc_id   <- paste0(abt_enc_id, "-V-1")
#
#   # Update encounter status (in-progress, with custom start offset)
#   dt_enc <- updateEncounterStatus(
#     dt_enc,
#     pid   = patient_id,
#     status = "in-progress",
#     start  = getDebugDatesRAWDateTime(-0.5, debug_day + start_offset),
#     end    = NA
#   )
#
#   # Replace enc_id (make sure new Encounter number is applied everywhere)
#   dt_enc <- dt_enc[, enc_id := gsub(paste0("\\[1\\]", patient_id, "-E-1"), base_enc_id, enc_id)]
#   # Set bed & room for Versorgungsstellenkontakt
#   testSetBedAndRoom(vs_enc_id, room, bed)
#   # Update identifiers and references
#   dt_enc <- dt_enc[enc_id == base_enc_id,
#                    enc_identifier_value := paste0(patient_id, "-E-", encounter_number)]
#   dt_enc <- dt_enc[enc_id == abt_enc_id,
#                    enc_partof_ref := paste0("Encounter/", patient_id, "-E-", encounter_number)]
#   dt_enc <- dt_enc[enc_id == vs_enc_id,
#                    enc_partof_ref := paste0("Encounter/", abt_enc_id)]
#   return(dt_enc)
# }

# testTransferWardInternal <- function(dt_enc, enc_lvl_3_id, day_offset = -0.5) {
#   dt_enc <- resource_tables[["Encounter"]]
#   dt_enc <- updateEncounterStatus(dt_enc, pid, "finished")
#   end_start_datetime <- getDebugDatesRAWDateTime(day_offset)
#   dt_enc[enc_id == enc_lvl_3_id, enc_period_end := end_start_datetime]
#   testTransferEncounterLevel3(enc_lvl_3_id)
#
#   dt_enc[nrow(dt_enc), `:=`(
#     enc_status = "in-progress",
#     enc_period_start = end_start_datetime,
#     enc_period_end = NA
#   )]
#
#   resource_tables[["Encounter"]] <<- dt_enc
# }

# Duplicate Encounter Level 3 and increment enc_id
# testTransferEncounterLevel3 <- function(pid) {
#   dt_enc <- testGetResourceTable("Encounter")
#
#   # Extract the row to duplicate
#   transfer_row <-  testGetEncounterLevel3(pid)
#   # Increment enc_id in duplicate
#   transfer_row[, enc_id := incrementLastDashNumber(enc_id)]
#   # Append to table
#   dt_enc <- data.table::rbindlist(list(dt_enc, transfer_row), use.names = TRUE)
#
#   testSetResourceTable("Encounter", dt_enc)
#
#   return(dt_enc)
# }

#' #' Increment the last numeric suffix after the final dash
#' #'
#' #' Takes an encounter id (or similar string) and increments the last number
#' #' following the final dash ("-").
#' #'
#' #' @param x Character scalar, e.g. \code{"[1]UKB-0002-E-1-A-1-V-1"}.
#' #'
#' #' @return Modified string with the last number incremented by 1.
#' #'
#' #' @examples
#' #' incrementLastDashNumber("[1]UKB-0002-E-1-A-1-V-1")
#' #' # Returns "[1]UKB-0002-E-1-A-1-V-2"
#' #'
#' #' incrementLastDashNumber("ABC-99")
#' #' # Returns "ABC-100"
#' #'
#' #' @export
#' incrementLastDashNumber <- function(x) {
#'   sub("-(\\d+)$", function(m) {
#'     num <- as.integer(sub("-(\\d+)$", "\\1", m))
#'     paste0("-", num + 1)
#'   }, x)
#' }

# testUpdateEncounterStatus <- function(dt_enc, pid, status, start = NULL, end = NULL, colnames_pattern_to_clear = "^enc_diagnosis_") {
#   changeDataForPID(dt_enc, pid, "enc_status", status)
#   if (!is.null(start)) changeDataForPID(dt_enc, pid, "enc_period_start", start)
#   if (!is.null(end)) changeDataForPID(dt_enc, pid, "enc_period_end", end)
#   if (!is.null(colnames_pattern_to_clear)) changeDataForPID(dt_enc, pid, colnames_pattern_to_clear, NA)
#   changeDataForPID(dt_enc, pid, "enc_meta_lastupdated", getDebugDatesRAWDateTime(-0.1))
#
#   return(dt_enc)
# }

# # TODO: Funktion nochmal checken und an gegebener Stelle aufrufen
# # This function represents the transfer of a patient to another ward (Versorgungsstelle)
# testTransferWardInternal <- function(pid, room, bed) {
#   dt_enc <- testGetResourceTable("Encounter")
#
#   # Get the last open Versorgungsstellenkontakt for the given PID
#   enc_level_3 <- testGetEncounterLevel(pid, enc_level = 3)
#   enc_id_level_3 <- enc_level_3$enc_id
#
#   # Close the old contact:
#   # - set the end time to the transfer time
#   # - set the status to "finished"
#   end_start_datetime <- getDebugDatesRAWDateTime(-0.5)
#   dt_enc[enc_id == enc_id_level_3, `:=`(
#     enc_status = "finished",
#     enc_period_end = end_start_datetime
#   )]
#
#   # Prepare the duplicate (new contact):
#   # - set the start time to the same as the end time of the old contact
#   enc_level_3[, enc_period_start := end_start_datetime]
#
#   # Increment the encounter ID for the new Versorgungsstellenkontakt
#   enc_level_3[, enc_id := incrementEncounterId(enc_id, "V")]
#
#   # Set the room and bed for the new contact
#   enc_level_3 <- testSetBedAndRoom(enc_level_3, room, bed)
#
#   # Merge the updated old contact and the new one into the Encounter table
#   dt_enc <- data.table::rbindlist(list(dt_enc, enc_level_3), use.names = TRUE)
#
#   # Write the updated Encounter table back to the environment
#   testSetResourceTable("Encounter", dt_enc)
# }

# testAddPartOf <- function() {
#   dt_enc <- testGetResourceTable("Encounter")
#
#   # 1) Wenn es auf -V-<zahl> endet → Parent ist ohne den V-Teil
#   dt_enc[grepl("-V-\\d+$", enc_id),
#          enc_partof_ref := sub("^\\[1\\]", "[1.1]Encounter/", sub("-V-\\d+$", "", enc_id))]
#
#   # 2) Wenn es auf -A-<zahl> endet → Parent ist ohne den A-Teil
#   dt_enc[grepl("-A-\\d+$", enc_id),
#          enc_partof_ref := sub("^\\[1\\]", "[1.1]Encounter/", sub("-A-\\d+$", "", enc_id))]
#
#   # 3) Wenn es auf -E-<zahl> endet → Kein Parent (NA)
#   dt_enc[grepl("-E-\\d+$", enc_id),
#          enc_partof_ref := NA_character_]
#
#   testSetResourceTable("Encounter", dt_enc)
#   return(dt_enc)
# }
