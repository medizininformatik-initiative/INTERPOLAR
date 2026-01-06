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

runCodeForDebugDay <- function(debug_day, code_block) {
  current_debug_day <- get("DEBUG_DAY", envir = .GlobalEnv)
  if (!exists("DEBUG_RUN_SINGLE_DAY_ONLY") || isTRUE(DEBUG_RUN_SINGLE_DAY_ONLY == debug_day)) {
    if (current_debug_day >= debug_day) {
      assign("DEBUG_DAY", debug_day, envir = .GlobalEnv)
      eval(substitute(code_block))
      assign("DEBUG_DAY", current_debug_day, envir = .GlobalEnv)
    }
  }
}

isDebugDay <- function(index = NULL) {
  return(exists("DEBUG_DAY") && (is.null(index) || DEBUG_DAY == index))
}

testEnsureRAWId <- function(id) {
  if (!startsWith(id, "[1]")) {
    id <- paste0("[1]", id)
  }
  return(id)
}

extractSimpleId <- function(id) {
  id <- sub("^\\[[0-9]+(\\.[0-9]+)*\\]", "", id)
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
  # Give all encounter the same identifier system and identifier of the same medical record as value
  enc_templates[, enc_identifier_system := "[1.1]http://www.commonidentifiersystem.de"]
  enc_templates[, enc_identifier_value := sub("[1]", "[1.1]", sub("-A-1$", "", enc_id), fixed = TRUE)]
  # Add encounters with type "Versorgungstellenkontakt"
  enc_templates <- testAddEncounterLevel3(enc_templates)
  # Change encounter data
  enc_templates[grepl("-(A|V)-1$", enc_id),
                enc_partof_ref := paste0("[1.1]Encounter/", sub("^\\[[^]]+\\]", "", sub("-(A|V)-1$", "", enc_id)))]
  enc_templates[, enc_status := "[1]in-progress"]
  enc_templates[, enc_period_end := NA]
  enc_templates <- enc_templates[order(enc_id)]

  # Add template for MedicationRequest table
  med_req_templates <- data.table::copy(resource_tables[["MedicationRequest"]])
  med_req_templates <- rbind(med_req_templates, as.list(rep(NA_character_, ncol(med_req_templates))))
  med_req_templates[, medreq_status := "[1]active"]

  # Add template for Condition table
  med_templates <- data.table::copy(resource_tables[["Medication"]])
  med_templates <- med_templates[1]
  med_templates[, med_code_system := "[1.1.1]http://fhir.de/CodeSystem/bfarm/atc"]


  # Add template for Condition table
  con_templates <- data.table::copy(resource_tables[["Condition"]])
  con_templates <- con_templates[1]

  # Add template for Observation table
  obs_templates <- data.table::copy(resource_tables[["Observation"]])
  obs_templates <- obs_templates[1]

  # Add template for Procedure table
  proc_templates <- data.table::copy(resource_tables[["Procedure"]])
  proc_templates <- proc_templates[1]

  filtered_resources[["Encounter"]] <- filtered_resources[["Encounter"]][0]
  filtered_resources[["MedicationRequest"]] <- filtered_resources[["MedicationRequest"]][0]
  filtered_resources[["Condition"]] <- filtered_resources[["Condition"]][0]
  filtered_resources[["Observation"]] <- filtered_resources[["Observation"]][0]
  filtered_resources[["Procedure"]] <- filtered_resources[["Procedure"]][0]
  filtered_resources[["pids_per_ward"]] <- filtered_resources[["pids_per_ward"]][0]

  assign("enc_templates", enc_templates, envir = .test_env)
  assign("med_req_templates", med_req_templates, envir = .test_env)
  assign("med_templates", med_templates, envir = .test_env)
  assign("con_templates", con_templates, envir = .test_env)
  assign("obs_templates", obs_templates, envir = .test_env)
  assign("proc_templates", proc_templates, envir = .test_env)

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
#'                          Defaults to `1`.
#' @param raw_index A character string to prefix the formatted datetime. Typically indicates a RAW index
#'                  such as `"[1.1]"`.
#'
#' @return A character string with the formatted datetime.
#'
#' @examples
#' getFormattedRAWDateTime(as.POSIXct("2023-10-07 12:00:00", tz = "Europe/Berlin"), offset_days_minus = 2)
#' # Example with default values (won't run due to missing DEBUG_DATES and DEBUG_DAY):
#' # getFormattedRAWDateTime()
#'
#' @export
getFormattedRAWDateTime <- function(datetime = DEBUG_DATES[DEBUG_DAY], offset_days_minus = 1, raw_index = "[1.1]") {
  datetime <- as.POSIXct(datetime)
  # Subtract the specified number of days from the given datetime
  datetime <- datetime - offset_days_minus * 86400

  # Format as "[1.1]YYYY-MM-DDTHH:MM:SS+02:00"
  paste0(raw_index, format(datetime, "%Y-%m-%dT%H:%M:%S%z"))
}

#' Get a RAW-formatted datetime from DEBUG_DATES with additive offset
#'
#' Returns a RAW-formatted datetime string based on \code{DEBUG_DATES[debug_date_index]} and an
#' additive day offset. Internally delegates to \code{getFormattedRAWDateTime()} and passes the
#' negated offset so that positive values in \code{offset_days} shift the datetime forward.
#'
#' @param offset_days Integer number of days to add to the selected debug date. Defaults to \code{0}.
#' @param debug_date_index Integer index into \code{DEBUG_DATES} selecting the base datetime.
#' @param raw_index A character string to prefix the formatted datetime. Typically indicates a RAW index
#'                  such as `"[1.1]"`.
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
getDebugDatesRAWDateTime <- function(offset_days = 0, debug_date_index = DEBUG_DAY, raw_index = "[1.1]") {
  datetime <- DEBUG_DATES[debug_date_index]
  # Get the formatted RAW datetime
  raw_datetime <- getFormattedRAWDateTime(datetime, -as.numeric(offset_days), raw_index)
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
  enc_ids <- extractSimpleId(enc_ids)

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
testAdmission <- function(pid, room, bed, ward_name = NULL, day_offset = -0.5) {
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
  enc_templates[, enc_period_start := getDebugDatesRAWDateTime(day_offset)]
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

  return(enc_templates$enc_id)
}

# Helper: close the last open encounter of a given level and create a new one
# - dt_enc: Encounter table (data.table)
# - pid: patient ID
# - level: encounter level (2 = Abteilung, 3 = Versorgungsstelle)
# - room, bed: optional, only relevant for Versorgungsstellenkontakte
transferEncounterLevel <- function(dt_enc, pid, level, room = NULL, bed = NULL, day_offset = -0.5) {
  # Get the last open encounter of the given level
  enc_last <- testGetEncounterLevel(pid, enc_level = level)
  enc_id_last <- enc_last$enc_id

  # Close the old contact
  enc_start_datetime <- getDebugDatesRAWDateTime(day_offset)
  dt_enc[enc_id == enc_id_last, `:=`(
    enc_status = "[1]finished",
    enc_period_end = enc_start_datetime
  )]

  # Prepare the new contact
  enc_last[, enc_period_start := enc_start_datetime]
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
testTransferWardInternal <- function(pid, room = NULL, bed = NULL, ward_name = NULL, day_offset = -0.5) {
  dt_enc <- testGetResourceTable("Encounter")
  enc_level_3_rows <- transferEncounterLevel(dt_enc, pid, level = 3, room, bed, day_offset)
  # Update the ward information
  testUpdateWard(enc_ids = enc_level_3_rows$new_enc_row[["enc_id"]],
                 ward_names = ward_name)
  # Merge the updated old contact and the new one into the Encounter table
  dt_enc <- data.table::rbindlist(list(enc_level_3_rows$dt_enc, enc_level_3_rows$new_enc_row), use.names = TRUE)
  testSetResourceTable("Encounter", dt_enc)
  return(enc_level_3_rows$new_enc_row[["enc_id"]])
}

# This function represents the transfer of a patient to another Abteilung
testTransferWardDepartment <- function(pid, room = NULL, bed = NULL, ward_name = NULL, day_offset = -0.5) {
  dt_enc <- testGetResourceTable("Encounter")
  # Step 1: Transfer the Abteilungskontakte (level 2)
  enc_level_2_rows <- transferEncounterLevel(dt_enc, pid, level = 2, day_offset)
  # Get the encounter index of the new Abteilungskontakt
  enc_level_2_row_index <- sub(".*-(\\d+)$", "\\1", enc_level_2_rows$new_enc_row[["enc_id"]])

  # Step 2: Transfer the Versorgungsstellenkontakte (level 3)
  enc_level_3_rows <- transferEncounterLevel(dt_enc, pid, level = 3, room = room, bed = bed, day_offset)
  # Update the encounter ID and partof of the new Versorgungsstellenkontakt to match the new Abteilungskontakt
  enc_level_3_rows$new_enc_row[, enc_id := sub("-A-\\d+-V-\\d+$", paste0("-A-", enc_level_2_row_index, "-V-1"), enc_id)]
  enc_level_3_rows$new_enc_row[, enc_partof_ref := sub("-A-\\d+$", paste0("-A-", enc_level_2_row_index), enc_partof_ref)]

  # Step 3: If ward name is given, update mapping
  testUpdateWard(enc_ids   = enc_level_3_rows$new_enc_row[["enc_id"]],
                 ward_names = ward_name)

  # Step 4: Merge all into Encounter table
  dt_enc <- data.table::rbindlist(
    list(enc_level_2_rows$new_enc_row, enc_level_3_rows$dt_enc, enc_level_3_rows$new_enc_row),
    use.names = TRUE
  )
  testSetResourceTable("Encounter", dt_enc)
  return(enc_level_2_rows$new_enc_row[["enc_id"]])
}

# This function discharges a patient (closes all encounters of the current case)
testDischarge <- function(pid) {
  dt_enc <- testGetResourceTable("Encounter")

  # Get discharge datetime (0.5 days before current debug day)
  discharge_datetime <- getDebugDatesRAWDateTime(-0.5)

  pid_ref <- paste0("[1.1]Patient/", pid)

  # Close all encounters of this patient
  dt_enc[enc_patient_ref == pid_ref & enc_status != "[1]finished", `:=`(
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

duplicatePatients <- function(count, duplicated_start_index = 1) {

  addPatientIdIndex <- function(old_id, index, resource_table, resource_name) {
    new_id <- paste0(old_id, "_", index)
    id_column <- etlutils::fhirdbGetIDColumn(resource_name)

    if (resource_name == "Patient") {
      resource_table[pat_id == testEnsureRAWId(old_id), pat_name_family := paste0(pat_name_family, "_", index)]
    }

    identifier_column <- etlutils::fhirdbGetIdentifierColumn(resource_name)
    pid_ref_column <- if (resource_name == "pids_per_ward") "patient_id" else etlutils::fhirdbGetPIDColumn(resource_name)
    enc_ref_column <- if (resource_name == "pids_per_ward") "encounter_id" else etlutils::fhirdbGetEncIDColumn(resource_name)

    # Unique if id_column and any reference columns are the same
    columns_to_replace <- unique(c(id_column, identifier_column, pid_ref_column, enc_ref_column, "enc_partof_ref"))

    for (col in columns_to_replace) {
      if (col %in% names(resource_table)) {
        if (resource_name == "pids_per_ward") {
          # special in pids_per_ward: IDs without [] prefix
          resource_table[, (col) := sub(
            paste0("(^)", old_id, "(?=-E|$)"),
            paste0("\\1", new_id),
            get(col),
            perl = TRUE
          )]
        } else if (endsWith(col, "_ref")) {
          resource_table[, (col) := sub(
            paste0("(^\\[[^]]+\\][^/]+/)", old_id),
            paste0("\\1", new_id),
            get(col)
          )]
        } else {
          resource_table[, (col) := sub(
            paste0("(^\\[[^]]+\\])", old_id, "(?=-E|$)"),
            paste0("\\1", new_id),
            get(col),
            perl = TRUE
          )]
        }
      }
    }
    return(resource_table)
  }

  # Copy ressource tables
  resource_tables <- testGetResourceTables()
  # Get patient table
  dt_pat <- resource_tables[["Patient"]]
  new_resource_tables <- lapply(resource_tables, data.table::copy)

  # iterate over all resource_tables
  for (i in duplicated_start_index:(count + duplicated_start_index - 1)) {
    for (resource_name in names(resource_tables)) {
      resource_table <- data.table::copy(resource_tables[[resource_name]])
      pat_ids <- dt_pat$pat_id
      if (any(grepl("_", pat_ids))) {
        dash_counts <- stringr::str_count(pat_ids, "_")
        max_dashes <- max(dash_counts)
        pat_ids <- pat_ids[dash_counts == max_dashes]
      }
      for (pat_id in pat_ids) {
        pat_id <- sub("^\\[[^]]+\\]", "", pat_id)
        new_resource_table <- addPatientIdIndex(pat_id, i, resource_table, resource_name)
        new_resource_tables[[resource_name]] <- unique(rbind(new_resource_tables[[resource_name]], new_resource_table))
      }
    }
  }
  testSetResourceTables(new_resource_tables)
}

addDrugs <- function(pid, codes, day_offset = -0.4, authoredon = NA, period_type = c(
  "start",
  "start_and_end",
  "start_and_end_and_timing_event",
  "timing_event",
  "timing_events",
  "all_timestamps_NA"
), encounter_id = NULL, timing_events_count = 3, timing_events_day_offset = 2) {

  period_type <- match.arg(period_type)

  # Load template tables from environment
  med_req_templates <- get("med_req_templates", envir = .test_env)
  med_templates <- get("med_templates", envir = .test_env)

  # Get current resource tables
  resource_tables <- testGetResourceTables()

  # Determine the next available index for encounters, MedicationRequests, and Medications
  # If encounter_id is not NULL or NA get the index from the encounter id
  if (!is.null(encounter_id) && !is.na(encounter_id)) {
    enc_index <- as.numeric(sub(".*-E-(\\d+).*", "\\1", encounter_id))
    enc_ref_id <- gsub("^\\[\\d+\\]", "", encounter_id)
  } else { # if encounter_id is NULL enc_ref_id has the next available index; if NA enc_ref_id is NA
    enc_index <- nrow(resource_tables[["Encounter"]][grepl(paste0("^\\[1\\]", pid, "-E-\\d+$"), enc_id)])
    enc_ref_id <- if (is.null(encounter_id)) paste0(pid, "-E-", enc_index) else NA_character_
  }

  med_req_index <- nrow(resource_tables[["MedicationRequest"]][grepl(paste0("^\\[1\\]", pid, "-E-", enc_index, "-MR-\\d+$"), medreq_id)]) + 1
  med_index <- nrow(resource_tables[["Medication"]][grepl(paste0("^\\[1\\]", pid, "-MR-", med_req_index, "-M-\\d+$"), med_id)]) + 1

  # Create MedicationRequest entries for each code
  med_req_dt <- data.table::rbindlist(lapply(seq_along(codes), function(i) {
    dt <- data.table::copy(med_req_templates)
    # Generate unique ID for MedicationRequest
    medreq_base_id <- paste0(pid, "-E-", enc_index, "-MR-", med_req_index + (i - 1))
    dt[, medreq_id := paste0("[1]", medreq_base_id)]
    dt[, medreq_identifier_value := paste0("[1.1]", medreq_base_id)]
    # Reference patient and encounter
    dt[, medreq_patient_ref := paste0("[1.1]Patient/", pid)]
    dt[, medreq_encounter_ref := if (!is.na(enc_ref_id)) paste0("[1.1]Encounter/", enc_ref_id) else NA_character_]
    # Reference the corresponding Medication
    dt[, medreq_medicationreference_ref := paste0("[1.1]Medication/", pid, "-MR-", med_req_index, "-M-", med_index + (i - 1))]
    dt[, medreq_meta_lastupdated := getDebugDatesRAWDateTime(-0.1)]

    # calculate boundsperiod start and end and and timing event(s) and authoredon based on period_type
    if (period_type %in% c("start",
                           "start_and_end",
                           "start_and_end_and_timing_event")) {
      dt[, medreq_doseinstruc_timing_repeat_boundsperiod_start := getDebugDatesRAWDateTime(day_offset, raw_index = "[1.1.1.1.1]")]
    }
    if (period_type %in% c("start_and_end",
                           "start_and_end_and_timing_event")) {
      dt[, medreq_doseinstruc_timing_repeat_boundsperiod_end := getDebugDatesRAWDateTime(day_offset + 5, raw_index = "[1.1.1.1.1]")]
    }
    if (period_type %in% c("start_and_end_and_timing_event",
                           "timing_event")) {
      dt[, medreq_doseinstruc_timing_event := getDebugDatesRAWDateTime(day_offset + 0.05, raw_index = "[1.1.1]")]
    }
    if (period_type %in% c("timing_events")) {
      events <- c()
      for (j in 1:timing_events_count) {
        events <- c(events, getDebugDatesRAWDateTime(day_offset + 0.05 + (j - 1) * timing_events_day_offset, raw_index = paste0("[1.1.", j, "]")))
      }
      dt[, medreq_doseinstruc_timing_event := paste0(events, collapse = " ~ ")]
    }
    if (!is.na(authoredon)) authoredon <- getDebugDatesRAWDateTime(authoredon, raw_index = "[1]")
    dt[, medreq_authoredon := authoredon]
    dt
  }))

  # Create Medication entries for each code
  med_dt <- data.table::rbindlist(lapply(seq_along(codes), function(i) {
    dt <- data.table::copy(med_templates)
    # Generate unique ID for Medication
    dt[, med_id := paste0("[1]", pid, "-MR-", med_req_index, "-M-", med_index + (i - 1))]
    dt[, med_identifier_value := paste0("[1.1]", pid, "-MR-", med_req_index - 1, "-M-", med_index + (i - 1))]
    # Assign the drug code
    dt[, med_code_code := paste0("[1.1.1]", codes[i])]
    dt[, med_meta_lastupdated := getDebugDatesRAWDateTime(-0.1)]
    dt
  }))

  # Append the new entries to the resource tables
  resource_tables[["Medication"]] <- rbind(resource_tables[["Medication"]], med_dt, fill = TRUE)
  resource_tables[["MedicationRequest"]] <- rbind(resource_tables[["MedicationRequest"]], med_req_dt, fill = TRUE)

  # Save the updated resource tables
  testSetResourceTables(resource_tables)

  return(pid) # convenience to write compact tests
}

addConditions <- function(pid, codes, day_offset = -0.5) {
  # Load template table for Condition
  con_templates <- get("con_templates", envir = .test_env)

  # Get current resource tables
  resource_tables <- testGetResourceTables()

  # Determine next available index for Conditions and Encounter for this patient
  enc_index <- nrow(resource_tables[["Encounter"]][grepl(paste0("^\\[1\\]", pid, "-E-\\d+$"), enc_id)])
  con_index <- nrow(resource_tables[["Condition"]][grepl(paste0("^\\[1\\]", pid, "-E-", enc_index, "-C-\\d+$"), con_id)]) + 1

  # Create Condition entries for each code
  con_dt <- data.table::rbindlist(lapply(seq_along(codes), function(i) {
    dt <- data.table::copy(con_templates)
    # Generate unique Condition ID
    dt[, con_id := paste0("[1]", pid, "-E-", enc_index, "-C-", con_index + (i - 1))]
    dt[, con_identifier_value := paste0("[1.1]", pid, "-E-", enc_index, "-C-", con_index + (i - 1))]
    # Reference the patient and encounter
    dt[, con_patient_ref := paste0("[1.1]Patient/", pid)]
    dt[, con_encounter_ref := paste0("[1.1]Encounter/", pid, "-E-", enc_index)]
    # Assign the condition code
    dt[, con_code_code := paste0("[1.1.1]", codes[i])]
    dt[, con_recordeddate := getDebugDatesRAWDateTime(day_offset, raw_index = "[1]")]
    dt[, con_onsetperiod_start := getDebugDatesRAWDateTime(day_offset)]
    dt[, con_meta_lastupdated := getDebugDatesRAWDateTime(-0.1)]
    dt
  }))

  # Append the new entries to the Condition table
  resource_tables[["Condition"]] <- rbind(resource_tables[["Condition"]], con_dt, fill = TRUE)

  # Save updated resource tables
  testSetResourceTables(resource_tables)
}

createReferenceRange <- function(referencerange_low_value = NULL, referencerange_low_code = NULL,
                                 referencerange_high_value = NULL, referencerange_high_code = NULL,
                                 referencerange_type_code = NULL,
                                 referencerange_low_system = NULL, referencerange_high_system = NULL) {

  if(!etlutils::isSimpleNAorNULL(referencerange_low_value) || !etlutils::isSimpleNAorNULL(referencerange_high_value)) {
    reference_range <- etlutils::namedListByParam(
      referencerange_low_value,
      referencerange_high_value,
      referencerange_low_code,
      referencerange_high_code,
      referencerange_low_system,
      referencerange_high_system,
      referencerange_type_code
    )
  } else {
    reference_range <- NULL
  }
  return(reference_range)
}

addObservation <- function(pid, code, day_offset = -0.5, value = NULL, unit = NULL, referencerange_low_value = NULL,
                           referencerange_high_value = NULL, referencerange_low_code = NULL, referencerange_high_code = NULL,
                           referencerange_low_system = NULL, referencerange_high_system = NULL, referencerange_type_code = NULL,
                           encounter_id = NULL) {
  addObservationWithRanges(pid, code, day_offset, value, unit, reference_ranges = createReferenceRange(referencerange_low_value,
                                                                                                       referencerange_low_code,
                                                                                                       referencerange_high_value,
                                                                                                       referencerange_high_code,
                                                                                                       referencerange_low_system,
                                                                                                       referencerange_high_system,
                                                                                                       referencerange_type_code),
                           encounter_id = encounter_id)
}

addObservationWithRanges <- function(pid, code, day_offset = -0.5, value = NULL, unit = NULL, reference_ranges = NULL, encounter_id = NULL) {
  # Load template table for Observation
  obs_templates <- get("obs_templates", envir = .test_env)

  # Get current resource tables
  resource_tables <- testGetResourceTables()

  # Determine next available index for Observations and Encounter for this patient
  # If encounter_id is not NULL or NA get the index from the encounter id
  if (!is.null(encounter_id) && !is.na(encounter_id)) {
    enc_index <- as.numeric(sub(".*-E-(\\d+).*", "\\1", encounter_id))
    enc_ref_id <- gsub("^\\[\\d+\\]", "", encounter_id)
  } else { # if encounter_id is NULL enc_ref_id has the next available index; if NA enc_ref_id is NA
    enc_index <- nrow(resource_tables[["Encounter"]][grepl(paste0("^\\[1\\]", pid, "-E-\\d+$"), enc_id)])
    enc_ref_id <- if (is.null(encounter_id)) paste0(pid, "-E-", enc_index) else NA_character_
  }
  obs_index <- nrow(resource_tables[["Observation"]][grepl(paste0("^\\[1\\]", pid, "-E-", enc_index, "-OL-\\d+$"), obs_id)]) + 1

  # Normalize single list input
  if (!is.null(reference_ranges) && !is.list(reference_ranges[[1]])) {
    reference_ranges <- list(reference_ranges)
  }

  # convenience function to get a value or NA
  getValue <- function(prefix, value) {
    if ((is.character(value) && etlutils::isSimpleNotEmptyString(value)) || !etlutils::isSimpleNAorNULL(value)) {
      return(paste0(prefix, value))
    }
    return(NA_character_)
  }

  # convenience function to add a value to a vector
  addValue <- function(vector, prefix, value) {
    value <- getValue(prefix, value)
    if (is.na(value)) {
      return(vector)
    }
    return(c(vector, value))
  }

  # Create Observation entries for each code
  obs_dt <- data.table::copy(obs_templates)
  # Generate unique Observation ID
  obs_dt[, obs_id := paste0("[1]", pid, "-E-", enc_index, "-OL-", obs_index)]
  obs_dt[, obs_identifier_value := paste0("[1.1]", pid, "-E-", enc_index, "-OL-", obs_index)]
  # Reference the patient and encounter
  obs_dt[, obs_patient_ref := paste0("[1.1]Patient/", pid)]
  obs_dt[, obs_encounter_ref := if (!is.na(enc_ref_id)) paste0("[1.1]Encounter/", enc_ref_id) else NA_character_]
  # Assign the observation code
  obs_dt[, obs_code_code := paste0("[1.1.1]", code)]
  obs_dt[, obs_effectivedatetime := getDebugDatesRAWDateTime(day_offset, raw_index = "[1]")]
  obs_dt[, obs_meta_lastupdated := getDebugDatesRAWDateTime(-0.1)]
  # Optional fields
  obs_dt[, obs_valuequantity_value := getValue("[1.1]", value)]
  obs_dt[, obs_valuequantity_code := getValue("[1.1]", unit)]
  obs_dt[, obs_valuequantity_unit := getValue("[1.1]Display of unit ", unit)]

  if (!is.null(reference_ranges)) {
    low_values <- c()
    high_values <- c()
    low_codes <- c()
    high_codes <- c()
    low_systems <- c()
    high_systems <- c()
    type_codes <- c()

    for (r in seq_along(reference_ranges)) {
      range <- reference_ranges[[r]]

      prefix  <- paste0("[", r, ".1.1]")
      prefix2 <- paste0("[", r, ".1.1.1]")
      low_values   <- addValue(low_values, prefix, range$referencerange_low_value)
      high_values  <- addValue(high_values, prefix, range$referencerange_high_value)
      low_codes    <- addValue(low_codes, prefix, range$referencerange_low_code)
      high_codes   <- addValue(high_codes, prefix, range$referencerange_high_code)
      low_systems  <- addValue(low_systems, prefix, range$referencerange_low_system)
      high_systems <- addValue(high_systems, prefix, range$referencerange_high_system)
      type_codes   <- addValue(type_codes, prefix2, range$referencerange_type_code)

    }
    pasteRAW <- function(vec) {
      raw <- paste0(vec, collapse = " ~ ")
      if(!nchar(raw)) raw <- NA_character_ # vec = NULL return empty string
      return(raw)
    }
    obs_dt[, obs_referencerange_low_value   := pasteRAW(low_values)]
    obs_dt[, obs_referencerange_high_value  := pasteRAW(high_values)]
    obs_dt[, obs_referencerange_low_code    := pasteRAW(low_codes)]
    obs_dt[, obs_referencerange_high_code   := pasteRAW(high_codes)]
    obs_dt[, obs_referencerange_low_system  := pasteRAW(low_systems)]
    obs_dt[, obs_referencerange_high_system := pasteRAW(high_systems)]
    obs_dt[, obs_referencerange_type_code   := pasteRAW(type_codes)]
  }

  # Append the new entries to the Observation table
  resource_tables[["Observation"]] <- rbind(resource_tables[["Observation"]], obs_dt, fill = TRUE)

  # Save updated resource tables
  testSetResourceTables(resource_tables)
}

addProcedures <- function(pid, codes, day_offset = -0.5, encounter_id = NULL) {
  # Load template table for Procedure
  proc_templates <- get("proc_templates", envir = .test_env)

  # Get current resource tables
  resource_tables <- testGetResourceTables()

  # Determine next available index for Procedure and Encounter for this patient
  # If encounter_id is not NULL or NA get the index from the encounter id
  if (!is.null(encounter_id) && !is.na(encounter_id)) {
    enc_index <- as.numeric(sub(".*-E-(\\d+).*", "\\1", encounter_id))
    enc_ref_id <- gsub("^\\[\\d+\\]", "", encounter_id)
  } else { # if encounter_id is NULL enc_ref_id has the next available index; if NA enc_ref_id is NA
    enc_index <- nrow(resource_tables[["Encounter"]][grepl(paste0("^\\[1\\]", pid, "-E-\\d+$"), enc_id)])
    enc_ref_id <- if (is.null(encounter_id)) paste0(pid, "-E-", enc_index) else NA_character_
  }

  proc_index <- nrow(resource_tables[["Procedure"]][grepl(paste0("^\\[1\\]", pid, "-E-", enc_index, "-P-\\d+$"), proc_id)]) + 1

  # Create Procedure entries for each code
  proc_dt <- data.table::rbindlist(lapply(seq_along(codes), function(i) {
    dt <- data.table::copy(proc_templates)
    # Generate unique Procedure ID
    dt[, proc_id := paste0("[1]", pid, "-E-", enc_index, "-P-", proc_index + (i - 1))]
    dt[, proc_identifier_value := paste0("[1.1]", pid, "-E-", enc_index, "-P-", proc_index + (i - 1))]
    # Reference the patient and encounter
    dt[, proc_patient_ref := paste0("[1.1]Patient/", pid)]
    dt[, proc_encounter_ref := if (!is.na(enc_ref_id)) paste0("[1.1]Encounter/", enc_ref_id) else NA_character_]
    # Assign the condition code
    dt[, proc_code_code := paste0("[1.1.1]", codes[i])]
    dt[, proc_code_display := paste0("[1.1.1]Neurologische Untersuchungen")]
    dt[, proc_performeddatetime := getDebugDatesRAWDateTime(day_offset)]
    dt[, proc_performedperiod_start := getDebugDatesRAWDateTime(day_offset)]
    dt[, proc_meta_lastupdated := getDebugDatesRAWDateTime(-0.1)]
    dt
  }))

  # Append the new entries to the Procedure table
  resource_tables[["Procedure"]] <- rbind(resource_tables[["Procedure"]], proc_dt, fill = TRUE)

  # Save updated resource tables
  testSetResourceTables(resource_tables)
}

####################
# REDCAP-FUNCTIONS #
####################

loadDebugREDCapDataTemplates <- function(table_names, path_to_redcap_data_files = "./R-cds2db/test/tables/") {
  debug_redcap_data_from_db <- list()
  files <- list.files(path_to_redcap_data_files, pattern = "_redcap\\.RData$", full.names = TRUE)
  names(files) <- sub(paste0("^", path_to_redcap_data_files, "/(.*?)_redcap\\.RData$"), "\\1", files)
  # Filter files to keep only those whose names are in table_names
  files <- files[names(files) %in% table_names]
  for (i in seq_along(files)) {
    debug_redcap_data_from_db[[names(files)[i]]] <- readRDS(files[i])
  }
  return(debug_redcap_data_from_db)
}

loadDebugREDCapDataTemplate <- function(table_name, path_to_redcap_data_files = "./R-cds2db/test/tables/") {
  return(loadDebugREDCapDataTemplates(c(table_name), path_to_redcap_data_files)[[table_name]])
}

# Helper function to get record_id for a given patient ID
getRecordID <- function(dt_patient, pid) {
  dt_patient$record_id[which(dt_patient$pat_id == pid)][1]
}

# Helper function to filter patient IDs by duplicate level and last indices
filterPatientIdsByLevel <- function(all_pids, duplicate_level, last_indices = NULL) {
  underscore_counts <- stringr::str_count(all_pids, "_")
  if (etlutils::isSimpleNAorNULL(last_indices)) {
    matching_ids <- all_pids[underscore_counts == duplicate_level]
  } else {
    # pattern like "(1|2|3)$" → no underscore before the number
    pattern <- paste0("(?:", paste(last_indices, collapse = "|"), ")$")
    if (duplicate_level > 0) {
      # pattern like "_(1|2|3)$" → underscore before the number
      pattern <- paste0("_", pattern)
    }
    matching_ids <- all_pids[underscore_counts == duplicate_level & grepl(pattern, all_pids)]
  }
  return(matching_ids)
}

addREDCapMedikationsanalyse <- function(dt_med_ana, patient_ids, day_offset, status = c("Complete", "Incomplete", "Unverified")) {
  status <- match.arg(status)
  # Load the necessary libraries
  template <- data.table::as.data.table(loadDebugREDCapDataTemplate("medikationsanalyse"))
  for (pid in patient_ids) {
    # Clean and add correct medication analysis datetime
    meda_datetime <- getDebugDatesRAWDateTime(day_offset, raw_index = "")
    template$meda_dat <- lubridate::ymd_hms(meda_datetime)
    # set the record_id in the template based on the current patient id
    template$record_id <- getRecordID(dt_patient, pid)
    # join with the encounter table to populate fall_meda_id in the template
    template[data_to_import$fall, on = "record_id", fall_meda_id := i.fall_id]
    # count how many entries already exist in "medikationsanalyse" for this fall_meda_id
    count <- data_to_import$medikationsanalyse[fall_meda_id == template$fall_meda_id, .N]
    # create a new meda_id by appending "-(count + 1)" to the fall_meda_id
    template[, meda_id := paste0(fall_meda_id, "-", count + 1)]
    # set the redcap_repeat_instrument to "medikationsanalyse"
    template[, redcap_repeat_instrument := "medikationsanalyse"]
    # count how many entries already exist in "medikationsanalyse" for this record_id
    count_redcap_repeat_instances <- data_to_import$medikationsanalyse[record_id == template$record_id, .N]
    template[, medikationsanalyse_complete := status]
    # set the redcap_repeat_instance to count + 1
    template[, redcap_repeat_instance := count_redcap_repeat_instances + 1]
    # append the updated template row into the "medikationsanalyse" table
    dt_med_ana <- rbind(dt_med_ana, template, fill = TRUE)
  }
  return(dt_med_ana)
}

addREDCapMRPDokumentation <- function(dt_mrp_doku, patient_ids) {
  # Load the necessary libraries
  template <- data.table::as.data.table(loadDebugREDCapDataTemplate("mrpdokumentation_validierung"))
  for (pid in patient_ids) {
    # set the record_id in the template based on the current patient id
    template$record_id <- getRecordID(dt_patient, pid)
    # join with the medication analysis table to populate mrp_meda_id in the template
    template[data_to_import$medikationsanalyse, on = "record_id", mrp_meda_id := i.meda_id]
    # count how many entries already exist in "mrpdokumentation_validierung" for this mrp_meda_id
    count <- data_to_import$mrpdokumentation_validierung[mrp_meda_id == template$mrp_meda_id, .N]
    # create a new mrp_id by appending "-(count + 1)" to the mrp_meda_id
    template[, mrp_id := paste0(mrp_meda_id, "-m", count + 1)]
    # set the redcap_repeat_instrument to "mrpdokumentation_validierung"
    template[, redcap_repeat_instrument := "mrpdokumentation_validierung"]
    # count how many entries already exist in "mrpdokumentation_validierung" for this record_id
    count_redcap_repeat_instances <- data_to_import$mrpdokumentation_validierung[record_id == template$record_id, .N]
    # set the redcap_repeat_instance to count + 1
    template[, redcap_repeat_instance := count_redcap_repeat_instances + 1]
    # set the mrp_pigrund___21 to "Checked" (Kontraindikation (MF))
    template[, mrp_pigrund___21 := "Checked"]
    # set the mrp_ip_klasse to a random value from the given options
    template[, mrp_ip_klasse_01 := sample(c("Drug-Drug",
                                            "Drug-Disease",
                                            "Drug-Niereninsuffizienz"))[1]]
    # set the mrp_dokup_hand_emp_akz to a random value from the given options
    template[, mrp_dokup_hand_emp_akz := sample(c("Arzt / Pflege informiert",
                                                  "Intervention vorgeschlagen und umgesetzt",
                                                  "Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation)",
                                                  "Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung)",
                                                  "Intervention vorgeschlagen, Umsetzung unbekannt",
                                                  "Problem nicht gelöst"))[1]]
    # append the updated template row into the "mrpdokumentation_validierung" table
    dt_mrp_doku <- rbind(dt_mrp_doku, template, fill = TRUE)
  }
  return(dt_mrp_doku)
}

# getNextPatientId <- function(pat_id, dt_pat) {
#   # Extract numeric suffix
#   num_suffix <- as.integer(sub(".*-(\\d+)$", "\\1", pat_id))
#   # Get Id prefix (before the suffix)
#   id_prefix <- sub("-(\\d+)$", "", pat_id)
#   # Filter rows in dt_pat with the same prefix
#   similar_ids <- dt_pat[grepl(paste0("^", id_prefix, "-"), pat_id), pat_id]
#   # Extract numeric suffixes from similar IDs
#   suffixes <- as.integer(sub(".*-(\\d+)$", "\\1", similar_ids))
#   # Determine the maximum suffix
#   if (length(suffixes) > 0) {
#     num_suffix <- max(suffixes, na.rm = TRUE)
#   } else {
#     num_suffix <- 0
#   }
#   # Create new patient ID by incrementing the maximum suffix
#   new_pat_id <- paste0(id_prefix, "-", num_suffix + 1)
#
#   return(new_pat_id)
# }
