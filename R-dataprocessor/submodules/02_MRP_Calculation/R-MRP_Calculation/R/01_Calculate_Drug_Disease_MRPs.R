#' Get Column Names for Drug-Disease MRP Pair List
#'
#' Returns a named character vector of relevant column names used in the
#' Drug-Disease medication-related problem (MRP) pair list.
#' These columns define the structure of the MRP rule table, including
#' primary ATC codes, condition codes (ICD), proxy rules, and laboratory proxies (LOINC).
#'
#' @return A named character vector of column names relevant to Drug-Disease MRP definitions.
getRelevantColumnNamesDrugDisease <- function() {
  etlutils::namedVectorByValue(
    #"SMPC_NAME",
    #"SMPC_VERSION",
    "ATC_DISPLAY",
    "ATC_PRIMARY",
    "ATC_SYSTEMIC_SY",
    "ATC_DERMATIC_D",
    "ATC_OPHTHALMOLOGIC_OP",
    "ATC_INHALATIVE_I",
    "ATC_OTHER_OT",
    "ATC_INCLUSION",
    "CONDITION_DISPLAY",
    "CONDITION_DISPLAY_CLUSTER",
    "ICD",
    "ICD_VALIDITY_DAYS",
    "ICD_PROXY_ATC",
    "ICD_PROXY_ATC_VALIDITY_DAYS",
    "ICD_PROXY_OPS",
    "ICD_PROXY_OPS_VALIDITY_DAYS",
    "LOINC_PRIMARY_PROXY",
    "LOINC_UNIT",
    "LOINC_DISPLAY",
    "LOINC_VALIDITY_DAYS",
    "LOINC_CUTOFF_REFERENCE",
    "LOINC_CUTOFF_ABSOLUTE")
}

#' Get Category Display Name for Drug-Disease MRPs
#'
#' Returns the display label for the MRP category "Drug-Disease", used for
#' tagging or labeling MRPs in evaluation outputs.
#'
#' @return A character string: \code{"Drug-Disease"}
getCategoryDisplayDrugDisease <- function() {"Drug-Disease"}

#' Clean and Expand Drug_Disease_MRP Definition Table
#'
#' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#' splitting and trimming values, and expanding concatenated ICD codes.
#'
#' @param drug_disease_mrp_definition A data.table containing the MRP definition table.
#' @param mrp_type A character string representing the base name of the MRP definition (e.g., `"Drug_Disease"`).
#'
#' @return A cleaned and expanded data.table containing the MRP definition table.
#'
#' @export
processExcelContentDrugDisease <- function(drug_disease_mrp_definition, mrp_type) {

  # Remove not nesessary columns
  mrp_columnnames <- getRelevantColumnNames(mrp_type)
  drug_disease_mrp_definition <- drug_disease_mrp_definition[, ..mrp_columnnames]

  # Remove rows with all empty code columns
  proxy_column_names <- names(drug_disease_mrp_definition)[
    (grepl("PROXY|ATC", names(drug_disease_mrp_definition))) &
      !grepl("DISPLAY|INCLUSION|VALIDITY_DAYS", names(drug_disease_mrp_definition))
  ]
  code_column_names <- c("ICD", proxy_column_names)
  drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, code_column_names)

  # ICD column:
  # remove white spaces around plus signs
  etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\s*\\+\\s*', '+')
  # replace all invalid chars in the ICD codes by a simple whitespace -> can be trimmed and splitted
  drug_disease_mrp_definition[, ICD := sapply(ICD, function(text) gsub('[^0-9A-Za-z. +]', '', text))]

  computeATCForCalculation(
    data_table = drug_disease_mrp_definition,
    primary_col = "ATC_PRIMARY",
    inclusion_col = "ATC_INCLUSION",
    output_col = "ATC_FOR_CALCULATION",
    secondary_cols = c("ATC_SYSTEMIC_SY", "ATC_DERMATIC_D", "ATC_OPHTHALMOLOGIC_OP", "ATC_INHALATIVE_I", "ATC_OTHER_OT")
  )

  # To prevent a large number of meaningless MRPs from being found, all lines for proxy codes that essentially
  # mean the same thing must be combined. The reason for this is that a short form of an ICD code (e.g., K70)
  # results in a large number of individual codes, which then all generate their own MRP for the LOINC proxy
  # because LOINC says that the patient has all these diseases.

  code_column_names <- c(code_column_names[!startsWith(code_column_names, "ATC")], "ATC_FOR_CALCULATION")
  # Create a new column for the full ICD list
  drug_disease_mrp_definition[, ICD_FULL_LIST := ICD]
  # SPLIT and TRIM: ICD and proxy column:
  # split the whitespace separated lists in ICD and proxy columns in a single row per code
  drug_disease_mrp_definition <- etlutils::splitColumnsToRows(drug_disease_mrp_definition, code_column_names)
  # trim all values in the whole table
  etlutils::trimTableValues(drug_disease_mrp_definition)
  # ICD column: remove tailing points from ICD codes
  etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\.$', '')
  # remove rows with empty ICD code and empty proxy codes (ATC, LOINC, OPS) again.
  # After the replacing of special signs with an empty string their can be new empty rows in this both columns
  drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, code_column_names)

  # Remove duplicate rows
  drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)

  # Clean rows with NA or empty values in relevant code columns
  for (col in code_column_names) {
    drug_disease_mrp_definition[[col]] <- ifelse(
      is.na(drug_disease_mrp_definition[[col]]) |
        !nzchar(trimws(drug_disease_mrp_definition[[col]])),
      NA_character_,
      drug_disease_mrp_definition[[col]]
    )
  }

  # check column ATC and ATC_PROXY for correct ATC codes
  invalid_atcs <- etlutils::getInvalidCodes(drug_disease_mrp_definition, "ATC_FOR_CALCULATION", etlutils::isATC)
  invalid_atcs_proxy <- etlutils::getInvalidCodes(drug_disease_mrp_definition, "ICD_PROXY_ATC", etlutils::isATC7orSmaller)

  # check column LOINC_PROXY for correct LOINC codes
  invalid_loincs <- etlutils::getInvalidCodes(drug_disease_mrp_definition, "LOINC_PRIMARY_PROXY", etlutils::isLOINC)

  error_messages <- c(
    formatCodeErrors(invalid_atcs, "ATC"),
    formatCodeErrors(invalid_atcs_proxy, "ATC_PROXY"),
    formatCodeErrors(invalid_loincs, "LOINC")
  )

  if (length(error_messages) > 0) {
    stop(paste(error_messages, collapse = "\n"))
  }

  # Expand and concatenate ICD codes in a vectorized manner.
  # If there are multiple ICD codes separated by "+", each code is expanded separately, and
  # combinations of expanded codes are concatenated. ICD Codes must be have at least 3 digits.
  expandAndConcatenateICDs <- function(icd_column) {
    # Function to process a single ICD code
    processICD <- function(icd) {
      if (is.na(icd) || icd == "") {
        return(NA_character_)
      }
      if (!grepl("+", icd, fixed = TRUE)) {
        # Handle single ICD code case
        return(paste(etlutils::expandICDs(icd), collapse = ' '))

      }
      # Handle multiple ICD codes separated by '+'
      input_icds <- unlist(strsplit(icd, '\\+'))
      icd_1 <- etlutils::expandICDs(input_icds[[1]])
      icd_2 <- etlutils::expandICDs(input_icds[[2]])
      # Create combinations and concatenate
      combinations <- outer(icd_1, icd_2, paste, sep = '+')
      return(trimws(paste(c(combinations), collapse = ' ')))

    }
    # Apply the function to the entire column
    sapply(icd_column, processICD)
  }

  # Apply the function to the 'ICD' column
  drug_disease_mrp_definition$ICD <- expandAndConcatenateICDs(drug_disease_mrp_definition$ICD)
  # Split concatenated ICD codes into separate rows
  drug_disease_mrp_definition <- etlutils::splitColumnsToRows(drug_disease_mrp_definition, "ICD")
  # Remove duplicate rows
  drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)

  return(drug_disease_mrp_definition)
}

#' Get relevant patient conditions up to a given date
#'
#' Filters the list of Condition resources to return conditions for a specific patient
#' that occurred on or before the given medication analysis date. If the condition has a
#' \code{con_recordeddate}, it is used for filtering; otherwise, \code{con_onsetperiod_start}
#' is used as a fallback.
#'
#' @param conditions A \code{data.table} of FHIR Condition resources, including columns \code{pat_id},
#' \code{con_recordeddate}, and \code{con_onsetperiod_start}.
#' @param patient_id A character string identifying the patient whose conditions should be returned.
#' @param meda_datetime A POSIXct timestamp representing the medication analysis date.
#'
#' @return A \code{data.table} of conditions that match the patient and date criteria.
#'
getRelevantConditions <- function(conditions, patient_id, meda_datetime) {

  # Filter conditions by patient ID and ensure recorded date is before or on meda_datetime
  relevant_conditions <- conditions[
    con_patient_ref == paste0("Patient/", patient_id) & !is.na(start_datetime) & start_datetime <= meda_datetime]

  relevant_cols <- c("con_patient_ref", "con_code_code", "con_code_system", "start_datetime")
  relevant_conditions <- relevant_conditions[, ..relevant_cols]

  return(relevant_conditions)
}

#' Match ATC codes between active medication requests and MRP definitions
#'
#' This function compares ATC codes from a list of active medication requests with the keys
#' (ATC codes) in the MRP rule definitions and returns all codes that appear in both.
#'
#' @param active_requests A \code{data.table} containing at least a column \code{atc_code}
#'        with the ATC codes from active medication requests.
#' @param mrp_table_list_by_atc A named list of \code{data.table}s, where each name is an ATC code
#'        and the corresponding table contains MRP rule definitions.
#'
#' @return A \code{data.table} with a single column \code{atc_code} listing all ATC codes
#'         found in both \code{active_requests} and \code{mrp_table_list_by_atc}.
#'
matchATCCodes <- function(active_requests, mrp_table_list_by_atc) {
  # Extract all ATC codes from the splitted MRP definitions (used as keys)
  mrp_atc_keys <- names(mrp_table_list_by_atc)
  # Extract unique ATC codes from the active medication requests
  active_atcs <- unique(active_requests$atc_code)
  # Identify the intersection (matching ATC codes) between the two sets
  matching_atcs <- intersect(active_atcs, mrp_atc_keys)
  # Collect matched ATC codes into a data.table
  matched_rows <- list()
  for (atc in matching_atcs) {
    row <- data.table::data.table(
      atc_code = atc
    )
    matched_rows[[length(matched_rows) + 1]] <- row
  }
  return(data.table::rbindlist(matched_rows))
}

#' Match ICD codes against MRP rules and ATC codes
#'
#' This function matches ICD codes found in a patient's condition records to the ICD codes defined
#' in a list of MRP rules. It also checks whether the condition was recorded within a valid
#' time window relative to a medication analysis date and whether the corresponding ATC code
#' is part of the active ATC matches.
#'
#' @param relevant_conditions A \code{data.table} of FHIR Condition resources, including columns
#'        \code{pat_id}, \code{con_code_code}, \code{con_code_system},
#'        \code{con_recordeddate}, and \code{con_onsetperiod_start}.
#' @param drug_disease_mrp_tables_by_icd A named list of \code{data.table}s containing MRP rules grouped by ICD code
#'        (names are ICD-10-GM codes).
#' @param match_atc_codes A \code{data.table} with a column \code{atc_code}, representing ATC codes
#'        matched from active medication requests.
#' @param meda_datetime The medication analysis date (as \code{Date} or \code{POSIXct}) to evaluate
#'        the time window for ICD code validity.
#' @param patient_id The patient ID to filter relevant condition entries.
#'
#' @return A \code{data.table} containing matched ICD and ATC codes, with one row per valid combination.
#'         Each row includes columns \code{icd}, \code{atc}, and \code{kurzbeschr} (a textual description
#'         of the contraindication).
#'
matchICDCodes <- function(relevant_conditions, drug_disease_mrp_tables_by_icd, match_atc_codes, meda_datetime, patient_id) {
  matched_rows <- list()

  # Filter all conditions for the current patient
  all_patient_conditions <- relevant_conditions[con_patient_ref == paste0("Patient/", patient_id)]
  used_icds <- unique(all_patient_conditions[!is.na(con_code_code), con_code_code])
  icds <- intersect(names(drug_disease_mrp_tables_by_icd), used_icds)

  for (mrp_icd in icds) {
    # Extract all MRP rules for this ICD
    mrp_table_list_rows <- drug_disease_mrp_tables_by_icd[[mrp_icd]]
    mrp_table_list_rows <- mrp_table_list_rows[ATC_FOR_CALCULATION %in% match_atc_codes$atc_code]

    # Find matching ICD conditions for this specific ICD
    patient_conditions <- all_patient_conditions[
      con_code_code == mrp_icd &
        con_code_system == "http://fhir.de/CodeSystem/bfarm/icd-10-gm"
    ]

    if (!nrow(patient_conditions)) next

    for (j in seq_len(nrow(mrp_table_list_rows))) {
      mrp_table_list_row <- mrp_table_list_rows[j]
      validity_days <- mrp_table_list_row$ICD_VALIDITY_DAYS

      # Check if at least one matching condition is within the validity window
      if (tolower(validity_days) == "unbegrenzt") {
        condition_match <- any(patient_conditions$start_datetime <= meda_datetime)
      } else {
        validity_days <- as.numeric(validity_days)
        condition_match <- any(
          patient_conditions$start_datetime >= (meda_datetime - lubridate::days(validity_days)) &
            patient_conditions$start_datetime <= meda_datetime
        )
      }

      if (!condition_match) next

      # Check if any of the matched ATC codes appear in the current ATC field of the MRP definition
      relevant_atcs <- match_atc_codes[
        grepl(mrp_table_list_row$ATC_FOR_CALCULATION, atc_code),
        atc_code
      ]

      # Add one row per matching ATC
      for (atc_code in relevant_atcs) {
        matched_rows[[length(matched_rows) + 1]] <- data.table::data.table(
          icd_code = mrp_icd,
          atc_code = atc_code,
          proxy_code = NA_character_,
          proxy_type = NA_character_,
          # TODO: Use a more descriptive text from the MRP definition
          kurzbeschr = paste0(
            mrp_table_list_row$ATC_DISPLAY, " (", atc_code, ") ist bei ",
            mrp_table_list_row$CONDITION_DISPLAY_CLUSTER, " (", mrp_icd, ") kontrainduziert.")
        )
      }
    }
  }

  return(data.table::rbindlist(matched_rows, fill = TRUE))
}

#' Print a warning for observations with invalid or non-convertible units
#'
#' This helper function prints a formatted warning message when entries
#' in an observation table (`invalid_obs`) contain invalid or non-convertible
#' measurement units.
#' For each affected observation, the `code`, `value`, and `unit` are displayed.
#'
#' @param invalid_obs `data.table` or `data.frame`
#'   A table containing the columns `code`, `value`, and `unit`, representing
#'   observations with invalid or non-convertible units.
#'
#' @details
#' If `invalid_obs` is empty (i.e., `nrow(invalid_obs) == 0`), no warning
#' message is printed.
#' Otherwise, a multi-line warning is issued using
#' [`etlutils::catWarningMessage()`], listing all affected observations.
#'
#' @return
#' Invisibly returns `NULL`.
#' The function is called for its side effect — printing a warning message
#' to the console.
catInvalidObservationsWarning <- function(invalid_obs) {
  if (nrow(invalid_obs)) {
    details <- character()
    for (i in seq_len(nrow(invalid_obs))) {
      details[i] <- paste0(
        "  code=", invalid_obs$code[i],
        ", value=", invalid_obs$value[i],
        ", unit=", invalid_obs$unit[i]
      )
    }
    etlutils::catWarningMessage(
      paste0(
        "The following observations have an invalid or not convertible unit and will be ignored:\n",
        paste(details, collapse = "\n")
      )
    )
  }
}

#' Generate a formatted description of matched laboratory observations
#'
#' This function takes a data.table of observations and a logical match vector,
#' filters the matching rows, and generates a grouped description by reference
#' range and unit. Each group is formatted with its reference range and all
#' corresponding observation values, including timestamps.
#'
#' @param obs A data.table containing observation data with columns:
#'   \code{code}, \code{value}, \code{unit}, \code{start_datetime},
#'   \code{reference_range_low_value}, and \code{reference_range_high_value}.
#' @param match_found A logical vector indicating which rows of \code{obs}
#'   matched a certain condition (e.g., a threshold).
#' @param loinc_mapping_table A data.table mapping LOINC codes to descriptive names.
#'   Must include columns \code{LOINC} and \code{GERMAN_NAME_LOINC_PRIMARY}.
#'
#' @return A character string containing a formatted summary of matched observations,
#'   grouped by reference range and unit.
generateMatchDescriptionReferenceCutoff <- function(obs, match_found, loinc_mapping_table) {

  # Filter matched observations and extract relevant columns
  matched_obs <- data.table::data.table(
    matched_values = obs$converted_value[match_found],
    matched_code = obs$code[match_found],
    matched_unit = obs$converted_unit[match_found],
    matched_start_datetime = obs$start_datetime[match_found],
    matched_reference_range_low = obs$reference_range_low_value[match_found],
    matched_reference_range_high = obs$reference_range_high_value[match_found]
  )

  if (nrow(matched_obs) == 0) {
    return("No matching observations found.\n")
  }

  # Group by reference range and unit, and build formatted text per group
  obs_values_by_reference_range <- matched_obs[
    ,
    {
      # Extract unique reference range values and unit for this group
      ref_low  <- unique(matched_reference_range_low)
      ref_high <- unique(matched_reference_range_high)
      unit     <- unique(matched_unit)
      # Create one formatted line per observation
      value_lines <- sprintf(
        "\t\t%s %s (%s)",
        matched_values,
        matched_unit,
        format(matched_start_datetime, "%Y-%m-%d %H:%M:%S")
      )
      # Combine all lines for the group
      group_text <- paste0(
        sprintf(
          "\nReferenzbereich: %s - %s %s\nWert:\t",
          ref_low, ref_high, unit
        ),
        paste(trimws(value_lines), collapse = "\n")
      )
      .(text = group_text)
    },
    by = .(matched_reference_range_low, matched_reference_range_high, matched_unit)
  ][, paste(text, collapse = "\n")]

  # Add LOINC description (names and codes)
  loinc_description <- loinc_mapping_table[
    LOINC %in% matched_obs$matched_code,
    unique(GERMAN_NAME_LOINC_PRIMARY)
  ]

  loinc_description <- paste(loinc_description, collapse = ", ")

  # Combine everything into a final description text
  match_description <- paste0(
    "Laborparameter: ", loinc_description, " (",
    paste0(unique(matched_obs$matched_code), collapse = ", "),
    ")\n",
    obs_values_by_reference_range,
    "\n"
  )

  return(match_description)
}

#' Generate a textual description of LOINC observations and matching threshold values
#'
#' This function builds a formatted description string summarizing all observation
#' values from a given data.table (`obs`), grouped by LOINC code. It includes
#' each observation’s original and converted values, associated units, timestamps,
#' and links them to a primary LOINC threshold.
#'
#' @param obs A data.table containing observation data. Must include columns:
#'   \code{code}, \code{value}, \code{unit}, \code{converted_value}, \code{start_datetime}.
#' @param loinc_mapping_table A data.table mapping LOINC codes to their German names.
#'   Must include columns \code{LOINC} and \code{GERMAN_NAME_LOINC_PRIMARY}.
#' @param primary_loinc The primary LOINC code (character) used as the reference.
#' @param cutoff_absolute Numeric value indicating the threshold or cutoff value.
#' @param cutoff_unit Character string specifying the unit of the cutoff value.
#'
#' @return A formatted character string describing all LOINC observations and their
#'   corresponding values relative to the specified cutoff.
generateMatchDescriptionAbsoluteCutoff <- function(obs, loinc_mapping_table, primary_loinc, cutoff_absolute, cutoff_unit) {

  # Create header text summarizing the main LOINC and cutoff information
  header <- sprintf(
    "Primärer LOINC %s Grenzwert %s %s \n",
    primary_loinc, cutoff_absolute, cutoff_unit
  )

  # Build description entries for each LOINC code
  desc_list <- obs[, {
    loinc_name <- loinc_mapping_table[LOINC %in% code, GERMAN_NAME_LOINC_PRIMARY]

    entry <- paste0(
      "\n   LOINC: ", code, " (", loinc_name, ")\n",
      paste(sprintf("     Wert: %s %s (%s %s) (Zeitpunkt: %s)", value, unit, as.character(converted_value), cutoff_unit, format(start_datetime, "%Y-%m-%d %H:%M:%S")),
            collapse = "\n")
    )
    list(text = entry)
  }, by = code]

  # Combine all entries into one final formatted text block
  full_text <- paste0(header, paste(desc_list$text, collapse = "\n"), "\n")
  return(full_text)
}

#' Filter and Convert Laboratory Observations to Reference Units
#'
#' This function processes a laboratory observation table (`obs`) by:
#' \itemize{
#'   \item Resolving conflicts in `reference_range_type`, keeping only "normal" if multiple types exist.
#'   \item Selecting one row per group defined by `non_ref_cols` while prioritizing:
#'     \itemize{
#'       \item `reference_range_type == "normal"`
#'       \item Rows with standard system `"http://unitsofmeasure.org"`
#'       \item Rows where the reference unit matches the observation unit
#'       \item If multiple candidates remain, the first is kept.
#'     }
#'   \item Splitting observations into those that can be converted and those that cannot.
#'   \item Converting observation values to the reference unit using `convertLabUnits()`.
#'   \item Collecting invalid or non-convertible observations into `invalid_obs` and issuing a warning.
#'   \item Printing a warning for observations whose unit was successfully converted.
#' }
#'
#' @param obs A `data.table` containing laboratory observations.
#' @param reference_value_col The name of the reference value column (e.g., `"reference_range_high_value"`).
#' @param invalid_obs A `data.table` of invalid observations (can be empty initially).
#'
#' @return A `data.table` containing filtered and unit-normalized observations,
#' with a new column `converted_value` representing the value in reference units.
#'
#' @examples
#' # Example usage:
#' # obs <- data.table(code = "1742-6", value = 61, unit = "mg/dL", reference_range_high_value = 10, ...)
#' # invalid_obs <- data.table()
#' # obs_filtered <- filterObservations(obs, "reference_range_high_value", invalid_obs)
filterObservations <- function(obs, reference_value_col, invalid_obs) {

  # Derive the corresponding unit and system columns from the reference value column
  reference_unit_col   <- sub("_value$", "_code", reference_value_col)
  reference_system_col <- sub("_value$", "_system", reference_value_col)

  # Identify columns that define unique observations, excluding reference columns
  non_ref_cols <- setdiff(names(obs), grep("^reference_", names(obs), value = TRUE))

  # Step 1: Filter multiple reference_range_type entries per observation
  obs <- obs[
    ,
    {
      # Prioritize "normal"
      preferred <- .SD[reference_range_type == "normal"]
      if (nrow(preferred) == 0) {
        # If no "normal", take rows without reference_range_type
        preferred <- .SD[is.na(reference_range_type)]
      }
      if (nrow(preferred) == 0) {
        # No eligible rows → drop group
        NULL
      } else if (nrow(preferred) > 1) {
        # Multiple candidates → prefer standard system
        standard <- preferred[get(reference_system_col) == "http://unitsofmeasure.org"]

        if (nrow(standard) == 0) {
          preferred <- preferred[1]  # No standard → keep first
        } else if (nrow(standard) > 1) {
          # Multiple standard system rows → prefer matching unit
          match_unit <- standard[get(reference_unit_col) == unit]
          preferred <- if (nrow(match_unit) > 0) match_unit[1] else standard[1]
        } else {
          preferred <- standard[1]  # Exactly one standard system row
        }
      } else {
        # Only one candidate → keep it
        preferred <- preferred[1]
      }
      preferred
    },
    by = non_ref_cols
  ]

  # Step 2: Split observations into convertible and non-convertible
  obs_to_convert_unit <- obs[!is.na(get(reference_unit_col)) & !is.na(unit)]
  obs_no_convert_unit <- obs[is.na(get(reference_unit_col)) | is.na(unit)]
  obs_no_convert_unit[, converted_value := value]  # Non-convertible → value unchanged
  obs_to_convert_unit[, converted_value := NA_real_]  # Initialize converted values
  obs_no_convert_unit[, converted_unit := unit]  # Non-convertible → value unchanged
  obs_to_convert_unit[, converted_unit := NA_real_]  # Initialize converted values

  # Step 3: Perform unit conversion row by row
  obs_value_converted_to_threshold_unit <- c()
  for (i in seq_len(nrow(obs_to_convert_unit))) {
    unit_from <- obs_to_convert_unit$unit[i]
    unit_target <- obs_to_convert_unit[[reference_unit_col]][i]
    obs_row <- obs_to_convert_unit[i]

    # Attempt conversion
    obs_value_converted_to_threshold_unit[i] <- convertLabUnits(
      measured_value = obs_row$value,
      measured_unit = unit_from,
      target_unit = unit_target
    )

    # Handle invalid conversions
    if (is.na(obs_value_converted_to_threshold_unit[i])) {
      invalid_obs <- if (nrow(invalid_obs) > 0) rbind(invalid_obs, obs_row) else obs_row
    } else {
      obs_to_convert_unit$converted_value[i] <- obs_value_converted_to_threshold_unit[i]
      obs_to_convert_unit$converted_unit[i] <- unit_target
    }

    # Remove invalid observations from dataset and issue a warning
    if (nrow(invalid_obs) > 0) {
      obs_to_convert_unit <- data.table::fsetdiff(obs_to_convert_unit, invalid_obs)
      catInvalidObservationsWarning(invalid_obs)
    }
  }

  # Step 4: Warn for observations whose units were converted
  changed_rows <- obs_to_convert_unit[
    !is.na(converted_value) & !is.na(value) & converted_value != value
  ]
  if (nrow(changed_rows)) {
    details <- character(nrow(changed_rows))
    for (i in seq_len(nrow(changed_rows))) {
      details[i] <- paste0(
        "  code=", changed_rows$code[i],
        ", value=", changed_rows$value[i], " ", changed_rows$unit[i],
        " changed to ", changed_rows$converted_value[i], " ", changed_rows[[reference_unit_col]][i]
      )
    }
    etlutils::catWarningMessage(
      paste0(
        "For the following observations, the unit had to be converted to match the reference range:\n",
        paste(details, collapse = "\n")
      )
    )
  }

  # Step 5: Combine converted and non-converted observations
  obs <- rbind(obs_to_convert_unit, obs_no_convert_unit)

  return(obs)
}

#' Match LOINC Cutoff Reference Against Observation Values
#'
#' This function checks whether any laboratory observation exceeds or falls below
#' a defined cutoff threshold as specified in the `LOINC_CUTOFF_REFERENCE` field
#' from drug–disease MRP (medication risk profile) proxy rules.
#'
#' Supported `cutoff_reference` formats include:
#' \itemize{
#'   \item `"> ULN"` — greater than upper limit of normal
#'   \item `"< LLN"` — less than lower limit of normal
#'   \item `">= 3*ULN"` — greater than or equal to three times ULN
#'   \item `"< 2*LLN"` — less than two times LLN
#' }
#'
#' The function parses the cutoff expression into an operator, an optional multiplier,
#' and a reference bound (`ULN` or `LLN`). It then evaluates whether any observation
#' matches this condition.
#'
#' @param observation_resources A `data.table` of lab observations with the columns:
#'   \describe{
#'     \item{code}{LOINC code of the observation}
#'     \item{value}{The measured lab value}
#'     \item{unit}{Unit of the measurement}
#'     \item{reference_range_low_value}{Lower reference bound (LLN)}
#'     \item{reference_range_high_value}{Upper reference bound (ULN)}
#'     \item{start_datetime}{Date/time of observation}
#'   }
#' @param match_proxy_row A single-row `data.table` from the drug–disease proxy table
#'   containing at least the column `LOINC_CUTOFF_REFERENCE`.
#' @param loinc_mapping_table A lookup `data.table` containing LOINC metadata, including
#'   columns:
#'   \describe{
#'     \item{LOINC}{LOINC code}
#'     \item{GERMAN_NAME_LOINC_PRIMARY}{German display name of the LOINC}
#'   }
#'
#' @return A character string describing the match if the cutoff was met, otherwise `NA_character_`.
#'
matchLOINCCutoff <- function(observation_resources, match_proxy_row, loinc_mapping_table) {

  data.table::setorder(observation_resources, "start_datetime")
  match_description <- NA_character_
  cutoff_reference <- trimws(match_proxy_row$LOINC_CUTOFF_REFERENCE)
  if (!is.na(cutoff_reference) && cutoff_reference != "") {
    # Parse the cutoff string into its components: operator, multiplier, and ULN/LLN
    # Possible cutoff formats: "> ULN", "< LLN", ">= 3*ULN", "<= 2*LLN"
    parseCutoffReference <- function(cutoff) {
      # Result are the parts in the round brackets
      pattern <- "^([<>]=?)\\s*(\\d*\\.?\\d*)\\*?\\s*(ULN|LLN)$"
      matches <- regexec(pattern, cutoff)
      parts <- regmatches(cutoff, matches)[[1]]

      # 1= full string, 2= operator, 3= multiplier, 4= ULN/LLN
      if (length(parts) == 4) {
        operator <- parts[2]
        multiplier <- ifelse(parts[3] == "", 1, as.numeric(parts[3]))
        reference <- parts[4]
        list(operator = operator, multiplier = multiplier, reference = reference)
      }
    }

    # Get parsed cutoff components
    cutoff <- parseCutoffReference(cutoff_reference)
    if (!is.null(cutoff)) {
      # Determine which column to use as the reference limit
      reference_value_col <- if (cutoff$reference == "ULN") {
        "reference_range_high_value"
      } else if (cutoff$reference == "LLN") {
        "reference_range_low_value"
      } else {
        NA  # Invalid reference keyword
      }

      if (!is.na(reference_value_col)) {
        # Split observation_resources in valid and invalid ones
        invalid_obs <- observation_resources[is.na(suppressWarnings(as.numeric(value))) | !isValidUnit(unit)]
        obs <- data.table::fsetdiff(observation_resources, invalid_obs)

        obs <- observation_resources[!is.na(value) & !is.na(get(reference_value_col))]

        if (nrow(obs)) {

          obs <- filterObservations(
            obs = obs,
            reference_value_col = reference_value_col,
            invalid_obs = invalid_obs
          )

          if (nrow(obs)) {
            # Calculate the threshold based on the multiplier
            threshold <- obs[[reference_value_col]] * cutoff$multiplier

            # Vectorized comparison of lab values to threshold using specified operator
            match_found <- switch(
              cutoff$operator,
              ">"  = obs$converted_value >  threshold,
              ">=" = obs$converted_value >= threshold,
              "<"  = obs$converted_value <  threshold,
              "<=" = obs$converted_value <= threshold,
              rep(FALSE, nrow(obs))  # fallback for unknown operator
            )

            match_found <- ifelse(is.na(match_found), FALSE, match_found)

            if (any(match_found)) {
              match_description <- generateMatchDescriptionReferenceCutoff(obs, match_found, loinc_mapping_table)
            }
          }
        }
      }
    }
  } else {
    # try cutoff absolute value via columns LOINC_CUTOFF_ABSOLUTE and LOINC_UNIT with a lookup via LOINC_PRIMARY_PROXY
    # in loinc_mapping_table and conversion of the unit if necessary

    cutoff_absolute <- trimws(match_proxy_row$LOINC_CUTOFF_ABSOLUTE)
    if (!is.na(cutoff_absolute) && cutoff_absolute != "") {
      # Parse the cutoff string into its components: operator and number
      # Possible cutoff formats: "> 3", "< 3", ">= 3,5", "< 2,8"
      parseCutoffAbsolute <- function(cutoff) {
        # Pattern allows comma or dot in the number
        pattern <- "^([<>]=?)\\s*(\\d+(?:[.,]\\d+)?)"
        matches <- regexec(pattern, cutoff)
        parts <- regmatches(cutoff, matches)[[1]]

        # 1 = full string, 2 = operator, 3 = threshold
        if (length(parts) == 3) {
          operator <- parts[2]
          # Replace comma with dot before conversion
          threshold <- as.numeric(sub(",", ".", parts[3], fixed = TRUE))
          list(operator = operator, threshold = threshold)
        }
      }

      # Get parsed cutoff components
      cutoff <- parseCutoffAbsolute(cutoff_absolute)
      if (!is.null(cutoff) && !any(is.na(cutoff))) {

        # Split observation_resources in valid and invalid ones
        invalid_obs <- observation_resources[is.na(suppressWarnings(as.numeric(value))) | !isValidUnit(unit)]
        obs <- data.table::fsetdiff(observation_resources, invalid_obs)

        if (nrow(obs)) {

          mapping_rows <- loinc_mapping_table[LOINC %in% obs$code]
          mapping_row  <- unique(mapping_rows[, c("LOINC_PRIMARY", "UNIT", "CONVERSION_FACTOR", "CONVERSION_UNIT")])
          if (nrow(mapping_row) == 1) { # no row would be an error and more than one row would be ambiguous

            # conversion_factor must be NA if it is not a number or 1
            conversion_factor <- suppressWarnings(as.numeric(mapping_row$CONVERSION_FACTOR))
            if (conversion_factor %in% 1) conversion_factor <- NA_real_
            # there must be a valid unit if the conversion_factor is a valid number != 1
            conversion_unit <- if (is.na(conversion_factor)) NA else mapping_row$CONVERSION_UNIT

            obs_value_converted_to_threshold_unit <- c()
            for (i in seq_len(nrow(obs))) {
              obs_row <- obs[i]
              obs_value_converted_to_threshold_unit[i] <- convertLabUnits(
                measured_value = obs_row$value,
                measured_unit = obs_row$unit,
                target_unit = mapping_row$UNIT,
                conversion_factor = conversion_factor,
                conversion_unit = conversion_unit
              )
              if (is.na(obs_value_converted_to_threshold_unit[i])) {
                # store this observation as invalid
                if (nrow(invalid_obs)) {
                  invalid_obs <- rbind(invalid_obs, obs_row)
                } else {
                  invalid_obs <- obs_row
                }
              }
            }

            obs_value_converted_to_threshold_unit <- obs_value_converted_to_threshold_unit[!is.na(obs_value_converted_to_threshold_unit)]
            obs <- data.table::fsetdiff(obs, invalid_obs)
            catInvalidObservationsWarning(invalid_obs)

            if (nrow(obs)) {
              # get the threshold
              threshold <- cutoff$threshold

              # Vectorized comparison of lab values to threshold using specified operator
              match_found <- switch(
                cutoff$operator,
                ">"  = obs_value_converted_to_threshold_unit >  threshold,
                ">=" = obs_value_converted_to_threshold_unit >= threshold,
                "<"  = obs_value_converted_to_threshold_unit <  threshold,
                "<=" = obs_value_converted_to_threshold_unit <= threshold,
                rep(FALSE, nrow(obs))  # fallback for unknown operator
              )

              match_found <- ifelse(is.na(match_found), FALSE, match_found)

              if (any(match_found)) {

                obs <- obs[match_found][, converted_value := obs_value_converted_to_threshold_unit[match_found]]

                match_description <- generateMatchDescriptionAbsoluteCutoff(
                  obs = obs,
                  loinc_mapping_table = loinc_mapping_table,
                  primary_loinc = mapping_row$LOINC_PRIMARY,
                  cutoff_absolute = cutoff_absolute,
                  cutoff_unit = mapping_row$UNIT
                )
              }
            }
          }
        }
      }
    }
  }
  return(match_description)
}

#' Match ICD Proxies Using ATC, OPS, and LOINC Codes
#'
#' This function analyzes a patient's medication, procedure, and observation data to infer ICD diagnoses
#' based on proxy rules defined in drug-disease MRP (medication risk profile) tables. These rules
#' define ATC (Anatomical Therapeutic Chemical), OPS (Operationen- und Prozedurenschlüssel, i.e. German procedure),
#' or LOINC (Logical Observation Identifiers Names and Codes) codes as proxies for ICD diagnoses.
#'
#' The function evaluates whether proxy events (e.g., medication, procedure, or lab measurement entries) occurred within
#' a rule-defined time window relative to a reference datetime. Matching proxies are returned
#' as suggested ICD codes with context descriptions.
#'
#' @param medication_resources A named list of `data.table`s containing medication information:
#'   - `medication_requests`
#'   - `medication_statements`
#'   - `medication_administrations`
#'   Each must include columns `atc_code`, `start_datetime`, and optionally `end_datetime`.
#'
#' @param procedure_resources A `data.table` containing procedures with columns:
#'   - `proc_code_code`: the OPS code
#'   - `start_datetime`: date of the procedure
#'   - `end_datetime`: optional end date of the procedure
#'
#' @param observation_resources A `data.table` containing lab or observation data with columns:
#'   - `obs_code_code`: the LOINC code
#'   - `obs_valuequantity_value`: measured value
#'   - `obs_valuequantity_unit`: measurement unit
#'   - `obs_referencerange_low_value` / `obs_referencerange_high_value`: reference range
#'   - `start_datetime`: date of measurement
#'   - `end_datetime`: optional end date
#'
#' @param drug_disease_mrp_tables_by_atc_proxy A named list of `data.table`s, one per ATC code,
#'   containing MRP rules. Each table should include: `ICD`, `ICD_PROXY_ATC`,
#'   `ICD_PROXY_ATC_VALIDITY_DAYS`, `ICD_VALIDITY_DAYS`, and `ATC_FOR_CALCULATION`.
#'
#' @param drug_disease_mrp_tables_by_ops_proxy A named list of `data.table`s, one per OPS code,
#'   containing MRP rules. Each table should include: `ICD`, `ICD_PROXY_OPS`,
#'   `ICD_PROXY_OPS_VALIDITY_DAYS`, `ICD_VALIDITY_DAYS`, and `ATC_FOR_CALCULATION`.
#'
#' @param drug_disease_mrp_tables_by_loinc_proxy A named list of `data.table`s, one per LOINC code,
#'   containing MRP rules. Each table should include: `ICD`, `LOINC_PRIMARY_PROXY`,
#'   `LOINC_VALIDITY_DAYS`, `ICD_VALIDITY_DAYS`, and `ATC_FOR_CALCULATION`.
#'
#' @param meda_datetime A `Date` or `POSIXct` object representing the reference datetime
#'   for evaluating proxy validity windows.
#'
#' @param match_atc_codes A character vector of ATC codes that are being evaluated (e.g.,
#'   medication in question triggering the contraindication check).
#'
#' @param loinc_matching_function A function used for additional matching logic when evaluating LOINC proxies.
#'   It must accept arguments `observation_resources`, `match_proxy_row`, and `loinc_mapping_table`
#'   and return either `NA` (no match) or a character description of the match reasoning.
#'
#' @param loinc_mapping_table A `data.table` containing metadata for LOINC codes (e.g., German names).
#'
#' @return A `data.table` of inferred ICD proxies with columns:
#' \describe{
#'   \item{icd_code}{The ICD code inferred via proxy}
#'   \item{atc_code}{The ATC code evaluated (from the rule)}
#'   \item{proxy_code}{The matching ATC, OPS, or LOINC proxy code that triggered the inference}
#'   \item{proxy_type}{One of `"ATC"`, `"OPS"`, or `"LOINC"`}
#'   \item{kurzbeschr}{A short German description of the match reasoning}
#' }
#'
#' @details
#' - The function returns one row per matched rule per ICD code.
#' - Only rules with a valid, non-empty proxy field are evaluated.
#' - Validity periods can be numerical (in days) or `"unbegrenzt"` (no time restriction).
#' - Matching is performed via `grepl` with `fixed = TRUE` for proxy codes.
#' - For LOINC proxies, an additional matching function can refine matches based on lab values and reference ranges.
#'
matchICDProxies <- function(
    medication_resources,
    procedure_resources,
    observation_resources,
    drug_disease_mrp_tables_by_atc_proxy,
    drug_disease_mrp_tables_by_ops_proxy,
    drug_disease_mrp_tables_by_loinc_proxy,
    meda_datetime,
    match_atc_codes,
    loinc_mapping_table,
    loinc_matching_function
) {

  matchProxy <- function(proxy_type, all_items, splitted_proxy_table) {
    mrp_matches <- list()
    used_codes <- unique(all_items[!is.na(code), code])
    if (proxy_type == "LOINC") {
      # Filter of all codes which are present in LOINC mapping table as secondary code
      used_codes <- loinc_mapping_table[LOINC %in% used_codes, .(code = LOINC, primary_code = LOINC_PRIMARY)]
    } else {
      used_codes <- data.table::data.table(
        # for the other two proxy types generate the same two columns table with identical code and primary_code values
        code = used_codes,
        primary_code = used_codes
      )
    }

    matching_proxies <- names(splitted_proxy_table)[
      vapply(names(splitted_proxy_table), function(key) {
        any(startsWith(used_codes$primary_code, key))
      }, logical(1))
    ]
    for (proxy_code in matching_proxies) {
      single_proxy_sub_table <- splitted_proxy_table[[proxy_code]]
      match_proxy_rows <- single_proxy_sub_table[get("ATC_FOR_CALCULATION") %in% match_atc_codes & !is.na(get("ICD_PROXY")) & get("ICD_PROXY") != ""]

      # Create ICD_FULL_LIST per ATC_PRIMARY group
      match_proxy_rows[
        ,
        ICD_FULL_LIST := {
          vals <- ICD
          vals <- vals[!is.na(vals) & nzchar(vals)]  # drop NA and empty strings
          if (length(vals)) paste(unique(vals), collapse = ", ") else NA_character_
        },
        by = ATC_FOR_CALCULATION
      ]

      # Remove ICD column data to prevent multiple identical rows with different ICD codes
      match_proxy_rows[, ICD := NA_character_]
      match_proxy_rows <- unique(match_proxy_rows)

      # Get the relevant secondary codes for this primary code
      relevant_secondary_codes <- used_codes[primary_code == proxy_code, code]
      # Select all items where the code matches any of the relevant secondary codes
      resources_with_proxy <- all_items[code %in% relevant_secondary_codes]
      if (nrow(resources_with_proxy)) {

        for (i in seq_len(nrow(match_proxy_rows))) {
          match_proxy_row <- match_proxy_rows[i]
          proxy_validity_days <- match_proxy_row[["ICD_PROXY_VALIDITY_DAYS"]]
          fallback_validity_days <- match_proxy_row$ICD_VALIDITY_DAYS
          validity_days <- if (!is.na(proxy_validity_days) && trimws(proxy_validity_days) != "") proxy_validity_days else fallback_validity_days
          validity_days <- suppressWarnings(as.integer(validity_days))
          # All non integer values are considered as unlimited validity duration
          if (is.na(validity_days)) {
            # 36525 days are 100 years in the future
            validity_days <- 36525
          }

          resources_with_proxy[is.na(end_datetime), end_datetime := start_datetime + lubridate::days(validity_days)]

          valid_proxy_rows <- resources_with_proxy[start_datetime <= meda_datetime & end_datetime >= meda_datetime]

          if (nrow(valid_proxy_rows)) {

            kurzbeschr <- sprintf(
              paste0(
                "%s (%s) ist bei %s kontraindiziert.\n",        # 1,2,3
                "%s ist als %s%s-Proxy für %s verwendet worden.\n", # 4,5,6,7
                "\n",
                "Der %s-Proxy steht für folgende ICD Codes:\n", # 8
                "%s\n"                                          # 9
              ),
              match_proxy_row$ATC_DISPLAY,               # 1
              match_proxy_row$ATC_FOR_CALCULATION,       # 2
              match_proxy_row$CONDITION_DISPLAY_CLUSTER, # 3
              proxy_code,                                # 4
              ifelse(proxy_type == "LOINC", "primärer ", ""), # 5
              proxy_type,                                # 6
              match_proxy_row$CONDITION_DISPLAY_CLUSTER, # 7
              proxy_type,                                # 8
              match_proxy_row$ICD_FULL_LIST              # 9
            )

            if (proxy_type == "LOINC") {
              # Call the external custom function
              mrp_match_description <- loinc_matching_function(
                observation_resources = valid_proxy_rows,
                match_proxy_row = match_proxy_row,
                loinc_mapping_table = loinc_mapping_table
              )
              # If both matching functions returns NA, skip this proxy match
              if (length(mrp_match_description) && any(!is.na(mrp_match_description))) {
                kurzbeschr <- paste(kurzbeschr, paste(mrp_match_description, collapse = "\n"), sep = "\n")
              } else {
                kurzbeschr <- NA_character_
              }
            }

            if (!is.na(kurzbeschr)) {
              mrp_matches[[length(mrp_matches) + 1]] <- data.table::data.table(
                icd_code = match_proxy_row$ICD,
                atc_code = match_proxy_row$ATC_FOR_CALCULATION,
                proxy_code = proxy_code,
                proxy_type = proxy_type,
                kurzbeschr = kurzbeschr
              )
            }
          }
        }
      }
    }
    return(mrp_matches)
  }

  #  Combine all medication rows
  all_medications <- rbind(
    medication_resources$medication_requests[, .(code = atc_code, start_datetime, end_datetime)],
    medication_resources$medication_statements[, .(code = atc_code, start_datetime, end_datetime)],
    medication_resources$medication_administrations[, .(code = atc_code, start_datetime, end_datetime)],
    fill = TRUE
  )
  #  Combine all procedures rows
  all_procedures <- procedure_resources[, .(code = proc_code_code, start_datetime, end_datetime)]
  #  Combine all observation rows
  all_observations <- observation_resources[, .(code = obs_code_code,
                                                value = obs_valuequantity_value,
                                                unit = obs_valuequantity_code,
                                                reference_range_low_value = obs_referencerange_low_value,
                                                reference_range_high_value = obs_referencerange_high_value,
                                                reference_range_low_system = obs_referencerange_low_system,
                                                reference_range_high_system = obs_referencerange_high_system,
                                                reference_range_low_code = obs_referencerange_low_code,
                                                reference_range_high_code = obs_referencerange_high_code,
                                                reference_range_type = obs_referencerange_type_code,
                                                start_datetime = start_datetime,
                                                end_datetime = as.POSIXct(NA))] # Observations don't have an end datetime
  # ATC-Proxy-Matching
  atc_matches <- matchProxy(
    proxy_type = "ATC",
    all_items = all_medications,
    splitted_proxy_table = drug_disease_mrp_tables_by_atc_proxy
  )
  # OPS-Proxy-Matching
  ops_matches <- matchProxy(
    proxy_type = "OPS",
    all_items = all_procedures,
    splitted_proxy_table = drug_disease_mrp_tables_by_ops_proxy
  )
  # LOINC-Proxy-Matching
  loinc_matches <- matchProxy(
    proxy_type = "LOINC",
    all_items = all_observations,
    splitted_proxy_table = drug_disease_mrp_tables_by_loinc_proxy
  )

  return(data.table::rbindlist(c(atc_matches, ops_matches, loinc_matches), fill = TRUE))
}

#' Split Drug-Disease MRP Table into Lookup Structures
#'
#' Takes a full Drug-Disease MRP table and splits it into multiple lookup tables
#' to support efficient MRP evaluation. Splitting is done by relevant rule keys such as:
#' ATC codes, ICD codes, and proxy definitions (ATC and OPS).
#'
#' @param drug_disease# The complete MRP definition table for Drug-Disease interactions as a \code{data.table}.
#'
#' @return A list of named \code{data.table} lookup structures:
#' \describe{
#'   \item{by_atc}{Split by \code{ATC_FOR_CALCULATION}, used for direct ATC code matching.}
#'   \item{by_icd}{Split by \code{ICD}, used to match ICD codes from conditions.}
#'   \item{by_atc_proxy}{Split by \code{ICD_PROXY_ATC}, used for proxy rules based on medication.}
#'   \item{by_ops_proxy}{Split by \code{ICD_PROXY_OPS}, used for proxy rules based on procedures.}
#' }
#'
getSplittedMRPTablesDrugDisease <- function(mrp_pair_list) {
  splitted <- list(
    by_atc = etlutils::splitTableToList(mrp_pair_list, "ATC_FOR_CALCULATION", rm.na = TRUE),
    by_icd = etlutils::splitTableToList(mrp_pair_list, "ICD", rm.na = TRUE),
    by_atc_proxy = etlutils::splitTableToList(mrp_pair_list, "ICD_PROXY_ATC", rm.na = TRUE),
    by_ops_proxy = etlutils::splitTableToList(mrp_pair_list, "ICD_PROXY_OPS", rm.na = TRUE),
    by_loinc_proxy = etlutils::splitTableToList(mrp_pair_list, "LOINC_PRIMARY_PROXY", rm.na = TRUE)
  )

  # Helper function to rename columns inside each list of data.tables
  renameProxyCols <- function(tbl_list, old, new) {
    lapply(tbl_list, function(tbl) {
      data.table::setnames(tbl, old = old, new = new, skip_absent = TRUE)
      tbl
    })
  }

  splitted$by_atc_proxy   <- renameProxyCols(splitted$by_atc_proxy,   c("ICD_PROXY_ATC",       "ICD_PROXY_ATC_VALIDITY_DAYS"), c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))
  splitted$by_ops_proxy   <- renameProxyCols(splitted$by_ops_proxy,   c("ICD_PROXY_OPS",       "ICD_PROXY_OPS_VALIDITY_DAYS"), c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))
  splitted$by_loinc_proxy <- renameProxyCols(splitted$by_loinc_proxy, c("LOINC_PRIMARY_PROXY", "LOINC_VALIDITY_DAYS"),         c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))

  return(splitted)
}

#' Calculate Drug-Disease Medication-Related Problems (MRPs)
#'
#' Detects MRPs by evaluating combinations of medications (ATC codes) and diseases (ICD codes).
#' If direct ICD matches are not found for an ATC, proxy rules are applied using medication
#' and procedure history to infer possible conditions.
#'
#' @param active_requests A \code{data.table} of the patient's active medications (e.g. FHIR MedicationRequest).
#' @param mrp_pair_list MRP-Pair list to create a list of lookup tables created by \code{getSplittedMRPTablesDrugDisease()}.
#' @param resources A named list of all FHIR resource tables relevant to the encounter (conditions, medications, procedures, etc.).
#' @param patient_id A character string representing the internal patient ID.
#' @param meda_datetime A POSIXct timestamp representing the time of medication evaluation.
#'
#' @return A \code{data.table} containing matched Drug-Disease MRPs, including both direct and proxy-based findings.
#'
calculateMRPsDrugDisease <- function(active_requests, mrp_pair_list, resources, patient_id, meda_datetime) {
  loinc_mapping_table <- getLOINCMapping()$processed_content
  match_atc_and_icd_codes <- data.table::data.table()
  splitted_mrp_tables <- getSplittedMRPTablesDrugDisease(mrp_pair_list)
  # Match ATC-codes between encounter data and MRP definitions
  match_atc_codes <- matchATCCodes(active_requests, splitted_mrp_tables$by_atc)
  # Get and match ICD-codes of the patient
  if (nrow(match_atc_codes)) {
    # Get relevant conditions
    relevant_conditions <- getRelevantConditions(resources$conditions, patient_id, meda_datetime)
    # Match ICD codes against MRP definitions and ATC codes
    match_atc_and_icd_codes <- matchICDCodes(
      relevant_conditions = relevant_conditions,
      drug_disease_mrp_tables_by_icd = splitted_mrp_tables$by_icd,
      match_atc_codes = match_atc_codes,
      meda_datetime = meda_datetime,
      patient_id = patient_id
    )
    matched_atcs <- unique(match_atc_and_icd_codes$atc)
    unmatched_atcs <- match_atc_codes[!(atc_code %in% matched_atcs)]

    if (nrow(unmatched_atcs)) {
      # No ICD matches found, check ATC and OPS Proxys for ICDs
      patient_ref <- paste0("Patient/", patient_id)
      match_icd_proxies <- matchICDProxies(
        medication_resources = list(
          medication_requests = resources$medication_requests[medreq_patient_ref %in% patient_ref],
          medication_statements = resources$medication_statements[medstat_patient_ref %in% patient_ref],
          medication_administrations = resources$medication_administrations[medadm_patient_ref %in% patient_ref]
        ),
        procedure_resources = resources$procedures[proc_patient_ref %in% patient_ref],
        observation_resources = resources$observations[obs_patient_ref %in% patient_ref],
        drug_disease_mrp_tables_by_atc_proxy = splitted_mrp_tables$by_atc_proxy,
        drug_disease_mrp_tables_by_ops_proxy = splitted_mrp_tables$by_ops_proxy,
        drug_disease_mrp_tables_by_loinc_proxy = splitted_mrp_tables$by_loinc_proxy,
        meda_datetime = meda_datetime,
        match_atc_codes = unmatched_atcs$atc_code,
        loinc_mapping_table = loinc_mapping_table,
        loinc_matching_function = matchLOINCCutoff
      )
      if (nrow(match_icd_proxies)) {
        match_atc_and_icd_codes <- rbind(match_atc_and_icd_codes, match_icd_proxies, fill = TRUE)
      }
    }
  }
  return(match_atc_and_icd_codes)
}
