#' Clean and Expand Drug_Disease_MRP Definition Table
#'
#' This function cleans and expands the MRP definition table by removing unnecessary rows and columns,
#' splitting and trimming values, and expanding concatenated ICD codes.
#'
#' @param drug_disease_mrp_definition A data.table containing the MRP definition table.
#'
#' @return A cleaned and expanded data.table containing the MRP definition table.
#'
#' @export
cleanAndExpandDefinitionDrugDisease <- function(drug_disease_mrp_definition) {

  # Remove not nesessary columns
  drug_disease_mrp_definition <- drug_disease_mrp_definition[, c("SMPC_NAME", "SMPC_VERSION") := NULL]

  # Remove rows with all empty code columns
  proxy_column_names <- names(drug_disease_mrp_definition)[
    (grepl("PROXY|ATC", names(drug_disease_mrp_definition))) &
      !grepl("DISPLAY|INCLUSION|VALIDITY_DAYS", names(drug_disease_mrp_definition))
  ]
  relevant_column_names <- c("ICD", proxy_column_names)
  drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, relevant_column_names)

  # ICD column:
  # remove white spaces around plus signs
  etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\s*\\+\\s*', '+')
  # replace all invalid chars in the ICD codes by a simple whitespace -> can be trimmed and splitted
  drug_disease_mrp_definition[, ICD := sapply(ICD, function(text) gsub('[^0-9A-Za-z. +]', '', text))]

  secondary_atc_cols <- setdiff(
    grep("^ATC_", proxy_column_names, value = TRUE),
    "ATC_PRIMARY"
  )
  suffix_map <- setNames(secondary_atc_cols, sub(".*_", "", secondary_atc_cols))

  drug_disease_mrp_definition[, ATC_FOR_CALCULATION := apply(
    drug_disease_mrp_definition, 1, function(row) {
      # Split the ATC_INCLUSION field by whitespace to handle multiple inclusion terms (e.g., "SY OP" -> c("SY", "OP"))
      inclusions <- trimws(unlist(strsplit(row[["ATC_INCLUSION"]], "\\s+")))
      # Initialize a vector to collect all secondary ATC codes from all inclusions
      all_secondary <- character(0)

      for (inclusion in inclusions) {
        if (inclusion == "alle") {
          raw_values <- row[secondary_atc_cols]
        } else if (inclusion == "keine weiteren") {
          raw_values <- character(0)
        } else {
          suffixes <- trimws(unlist(strsplit(inclusion, ",")))
          cols <- suffix_map[suffixes]
          raw_values <- row[cols]
        }
        # Append the raw values for this inclusion to the overall secondary list
        all_secondary <- c(all_secondary, raw_values)
      }

      # Combine all collected secondary ATC codes into a single vector, splitting by whitespace
      secondary <- unlist(strsplit(paste(na.omit(all_secondary), collapse = " "), "\\s+"))
      # Merge primary and secondary ATC codes, remove duplicates and empty strings
      all_atc <- unique(c(row[["ATC_PRIMARY"]], secondary))
      all_atc <- all_atc[nzchar(all_atc)]
      # Collapse the final list of ATC codes into a single space-separated string
      paste(all_atc, collapse = " ")
    }
  )]

  relevant_column_names <- c(relevant_column_names[!startsWith(relevant_column_names, "ATC")], "ATC_FOR_CALCULATION")
  # SPLIT and TRIM: ICD and proxy column:
  # split the whitespace separated lists in ICD and proxy columns in a single row per code
  drug_disease_mrp_definition <- etlutils::splitColumnsToRows(drug_disease_mrp_definition, relevant_column_names)
  # trim all values in the whole table
  etlutils::trimTableValues(drug_disease_mrp_definition)
  # ICD column: remove tailing points from ICD codes
  etlutils::replacePatternsInColumn(drug_disease_mrp_definition, 'ICD', '\\.$', '')
  # remove rows with empty ICD code and empty proxy codes (ATC, LOINC, OPS) again.
  # After the replacing of special signs with an empty string their can be new empty rows in this both columns
  drug_disease_mrp_definition <- etlutils::removeRowsWithNAorEmpty(drug_disease_mrp_definition, relevant_column_names)

  # Remove duplicate rows
  drug_disease_mrp_definition <- unique(drug_disease_mrp_definition)

  # Clean rows with NA or empty values in relevant columns
  for (col in relevant_column_names) {
    drug_disease_mrp_definition[[col]] <- ifelse(
      is.na(drug_disease_mrp_definition[[col]]) |
        !nzchar(trimws(drug_disease_mrp_definition[[col]])),
      NA_character_,
      drug_disease_mrp_definition[[col]]
    )
  }

  # check column ATC and ATC_PROXY for correct ATC codes
  atc_columns <- grep("ATC(?!.*(DISPLAY|INCLUSION|VALIDITY_DAYS))", names(drug_disease_mrp_definition), value = TRUE, perl = TRUE)
  atc_errors <- validateATCCodes(drug_disease_mrp_definition, atc_columns)

  # check column LOINC_PROXY for correct LOINC codes
  loinc_errors <- validateLOINCCodes(drug_disease_mrp_definition, "LOINC_PRIMARY_PROXY")

  error_messages <- c(
    formatCodeErrors(atc_errors, "ATC"),
    formatCodeErrors(loinc_errors, "LOINC")
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

#' Filter active MedicationRequests for an encounter within a specific time window
#'
#' @param medication_requests A \code{data.table} of MedicationRequest resources. Must contain columns \code{medreq_encounter_ref} and \code{medreq_authoredon}.
#' @param enc_period_start POSIXct. The start datetime of the encounter period.
#' @param meda_datetime POSIXct. The datetime of the medication analysis (cutoff point).
#'
#' @return A \code{data.table} with filtered active medication requests for the given encounter and time range.
#'
getActiveMedicationRequests <- function(medication_requests, enc_period_start, meda_datetime) {

  active_requests <- medication_requests[
    #medreq_encounter_ref == paste0("Encounter/", encounter_id) &
    !is.na(medreq_authoredon) &
      medreq_authoredon >= enc_period_start &
      medreq_authoredon <= meda_datetime
  ]

  relevant_cols <- c("atc_code")
  active_requests <- active_requests[, ..relevant_cols]

  return(active_requests)
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
    con_patient_ref == paste0("Patient/", patient_id) &
      ((!is.na(con_recordeddate) & con_recordeddate <= meda_datetime) |
         (is.na(con_recordeddate) & con_onsetperiod_start <= meda_datetime))
  ]

  relevant_cols <- c("con_patient_ref", "con_code_code", "con_code_system",
                     "con_recordeddate", "con_onsetperiod_start")
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

  for (mrp_icd in names(drug_disease_mrp_tables_by_icd)) {
    # Extract all MRP rules for this ICD
    mrp_table_list_rows <- drug_disease_mrp_tables_by_icd[[mrp_icd]]

    # Find matching ICD conditions for this specific ICD
    patient_conditions <- all_patient_conditions[
      con_code_code == mrp_icd &
        con_code_system == "http://fhir.de/CodeSystem/bfarm/icd-10-gm"
    ]

    if (nrow(patient_conditions) == 0) next

    for (j in seq_len(nrow(mrp_table_list_rows))) {
      mrp_table_list_row <- mrp_table_list_rows[j]
      validity_days <- mrp_table_list_row$ICD_VALIDITY_DAYS

      # Check if at least one matching condition is within the validity window
      if (tolower(validity_days) == "unbegrenzt") {
        condition_match <- any(
          (is.na(patient_conditions$con_recordeddate) &
             patient_conditions$con_onsetperiod_start <= meda_datetime) |
            (!is.na(patient_conditions$con_recordeddate) &
               patient_conditions$con_recordeddate <= meda_datetime)
        )
      } else {
        validity_days <- as.numeric(validity_days)
        condition_match <- any(
          (is.na(patient_conditions$con_recordeddate) &
             patient_conditions$con_onsetperiod_start >= (meda_datetime - validity_days) &
             patient_conditions$con_onsetperiod_start <= meda_datetime) |
            (!is.na(patient_conditions$con_recordeddate) &
               patient_conditions$con_recordeddate >= (meda_datetime - validity_days) &
               patient_conditions$con_recordeddate <= meda_datetime)
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
          icd = mrp_icd,
          atc = atc_code,
          # TODO: Use a more descriptive text from the MRP definition
          kurzbeschr = paste0(
            mrp_table_list_row$ATC_DISPLAY,
            " ist bei ",
            mrp_table_list_row$CONDITION_DISPLAY_CLUSTER,
            " kontrainduziert.")
        )
      }
    }
  }

  return(data.table::rbindlist(matched_rows, fill = TRUE))
}

#' Match ICD Proxies Using ATC and OPS Codes
#'
#' This function searches a patient's medication and (optionally) procedure data
#' to infer ICD diagnoses based on proxy rules defined in drug-disease MRP tables.
#' These proxy rules allow using ATC (Anatomical Therapeutic Chemical) codes or
#' OPS (German procedure codes) as indirect indicators for ICD codes, in case no
#' explicit diagnosis is present.
#'
#' For each ICD-related rule, the function checks whether a proxy ATC or OPS code
#' is defined and whether a relevant event (e.g., medication or procedure) has occurred
#' within a valid time window relative to a given reference date.
#'
#' @param medication_resources A list of data.tables containing the patient's medications,
#'   typically with the elements: `medication_requests`, `medication_statements`, and
#'   `medication_administrations`. Each should include `atc_code` and `date` columns.
#' @param drug_disease_mrp_tables_by_icd A named list of data.tables, where each name
#'   represents an ICD code, and each table contains rules with possible proxy fields
#'   such as `ICD_PROXY_ATC`, `ICD_PROXY_ATC_VALIDITY_DAYS`, `ICD_PROXY_OPS`, and
#'   `ICD_PROXY_OPS_VALIDITY_DAYS`.
#' @param meda_datetime A reference `Date` or `POSIXct` object representing the time
#'   at which proxies are evaluated (e.g., current time or time of case evaluation).
#'
#' @return A `data.table` listing matched proxy-based ICD suggestions. Each row contains:
#'   - `icd`: the ICD code inferred,
#'   - `atc`: the matching proxy ATC (if applicable),
#'   - `kurzbeschr`: a short description of the rule match.
#'
#' @details
#' This function currently supports ATC proxies (from medication data). You can extend it
#' to support OPS proxies (from procedure data) by incorporating logic similar to the ATC
#' check, using fields `ICD_PROXY_OPS` and `ICD_PROXY_OPS_VALIDITY_DAYS`.
#'
#' If multiple matching ATC proxies are found for a single ICD rule, only the first
#' valid match will be reported per rule iteration.
#'
matchICDProxies <- function(medication_resources, procedure_resources, drug_disease_mrp_tables_by_icd, meda_datetime) {
  matched_rows <- list()

  for (mrp_icd in names(drug_disease_mrp_tables_by_icd)) {
    mrp_table <- drug_disease_mrp_tables_by_icd[[mrp_icd]]

    proxy_enabled_rules <- mrp_table[
      (!is.na(ICD_PROXY_ATC) & ICD_PROXY_ATC != "") |
        (!is.na(ICD_PROXY_OPS) & ICD_PROXY_OPS != "")
    ]

    if (nrow(proxy_enabled_rules) == 0) next

    for (j in seq_len(nrow(proxy_enabled_rules))) {
      rule <- proxy_enabled_rules[j]

      # Combine all medication rows
      all_medications <- rbind(
        medication_resources$medication_requests[, .(code = atc_code, date)],
        medication_resources$medication_statements[, .(code = atc_code, date)],
        medication_resources$medication_administrations[, .(code = atc_code, date)],
        fill = TRUE
      )

      # Combine all procedure rows
      all_procedures <- procedure_resources[, .(code = ops_code, date)]

      match_found <- FALSE
      beschreibung <- NULL

      # Check ATC proxy
      if (!is.na(rule$ICD_PROXY_ATC) && rule$ICD_PROXY_ATC != "") {
        proxy_code <- rule$ICD_PROXY_ATC
        validity <- rule$ICD_PROXY_ATC_VALIDITY_DAYS
        fallback_validity <- rule$ICD_VALIDITY_DAYS

        validity_days <- if (!is.na(validity) && validity != "") validity else fallback_validity

        relevant_rows <- all_medications[
          grepl(proxy_code, code, fixed = TRUE) & !is.na(date)
        ]

        if (tolower(validity_days) == "unbegrenzt") {
          match_found <- any(relevant_rows$date <= meda_datetime)
        } else {
          validity_days_num <- as.numeric(validity_days)
          match_found <- any(
            relevant_rows$date >= (meda_datetime - validity_days_num) &
              relevant_rows$date <= meda_datetime
          )
        }

        if (match_found) {
          beschreibung <- paste0(proxy_code, " ist als ATC-Proxy für ", mrp_icd, " verwendet worden.")
        }
      }

      # Check OPS proxy (only if not already matched by ATC)
      if (!match_found && !is.na(rule$ICD_PROXY_OPS) && rule$ICD_PROXY_OPS != "") {
        proxy_code <- rule$ICD_PROXY_OPS
        validity <- rule$ICD_PROXY_OPS_VALIDITY_DAYS
        fallback_validity <- rule$ICD_VALIDITY_DAYS

        validity_days <- if (!is.na(validity) && validity != "") validity else fallback_validity

        relevant_rows <- all_procedures[
          grepl(proxy_code, code, fixed = TRUE) & !is.na(date)
        ]

        if (tolower(validity_days) == "unbegrenzt") {
          match_found <- any(relevant_rows$date <= meda_datetime)
        } else {
          validity_days_num <- as.numeric(validity_days)
          match_found <- any(
            relevant_rows$date >= (meda_datetime - validity_days_num) &
              relevant_rows$date <= meda_datetime
          )
        }

        if (match_found) {
          beschreibung <- paste0(proxy_code, " ist als OPS-Proxy für ", mrp_icd, " verwendet worden.")
        }
      }

      if (match_found) {
        matched_rows[[length(matched_rows) + 1]] <- data.table(
          icd = mrp_icd,
          code = proxy_code,
          kurzbeschr = beschreibung
        )
      }
    }
  }

  return(rbindlist(matched_rows, fill = TRUE))
}

#' Calculate Drug-Disease Medication-Related Problems (MRPs)
#'
#' This function analyzes potential drug-disease interactions for a set of patient
#' encounters. It loads all relevant patient resources (such as medication requests,
#' conditions, and encounters) and applies predefined MRP rules to identify
#' clinically relevant drug-disease medication-related problems (MRPs).
#'
#' For each encounter, any matches are compiled into two result tables: one containing
#' descriptive MRP evaluations (`retrolektive_mrpbewertung`), and one documenting
#' the MRP calculation process (`dp_mrp_calculations`).
#'
#' @param drug_disease_mrp_tables A `data.table` containing all predefined MRP rules
#'   for drug-disease interactions, typically with columns like `ATC_FOR_CALCULATION`,
#'   `ICD`, `ICD_VALIDITY_DAYS`, etc.
#'
#' @return A named list with two `data.table`s:
#' \describe{
#'   \item{retrolektive_mrpbewertung}{A table containing all detected drug-disease MRP matches.}
#'   \item{dp_mrp_calculations}{A table logging the MRP calculation process per encounter.}
#' }
#'
calculateDrugDiseaseMRPs <- function(drug_disease_mrp_tables) {

  resources <- getResourcesForMRPCalculation(MRP_CALCULATION_TYPE$Drug_Disease)

  if (!length(resources)) {
    return(list())
  }

  # Split drug_disease_mrp_tables by ATC and ICD
  drug_disease_mrp_tables_by_atc <- etlutils::splitTableToList(drug_disease_mrp_tables, "ATC_FOR_CALCULATION")
  drug_disease_mrp_tables_by_icd <- etlutils::splitTableToList(drug_disease_mrp_tables, "ICD")

  # Initialize empty lists for results
  retrolektive_mrpbewertung_rows <- list()
  dp_mrp_calculations_rows <- list()

  for (encounter_id in resources$main_encounters$enc_id) {

    # Get encounter data and patient ID
    encounter <- resources$main_encounters[enc_id == encounter_id]
    patient_id <- etlutils::fhirdataExtractIDs(encounter$enc_patient_ref)
    meda <- resources$encounters_first_medication_analysis[[encounter_id]]
    meda_id <- if (!is.null(meda)) meda$medikationsanalyse_fe_id else NA_character_
    meda_datetime <- if (!is.null(meda)) meda$meda_dat else NA
    record_id <- as.integer(resources$record_ids[pat_id == patient_id, record_id])

    # Get active MedicationRequests for the encounter
    active_requests <- getActiveMedicationRequests(resources$medication_requests, encounter$enc_period_start, meda_datetime)

    if (nrow(active_requests)) {
      # Match ATC-codes between encounter data and MRP definitions
      match_atc_codes <- matchATCCodes(active_requests, drug_disease_mrp_tables_by_atc)
      # Get and match ICD-codes of the patient
      if (nrow(match_atc_codes)) {
        # Get relevant conditions
        relevant_conditions <- getRelevantConditions(resources$conditions, patient_id, meda_datetime)
        # Match ICD codes against MRP definitions and ATC codes
        match_atc_and_icd_codes <- matchICDCodes(
          relevant_conditions = relevant_conditions,
          drug_disease_mrp_tables_by_icd = drug_disease_mrp_tables_by_icd,
          match_atc_codes = match_atc_codes,
          meda_datetime = meda_datetime,
          patient_id = patient_id
        )
      }
      if (nrow(match_atc_and_icd_codes) == 0 && nrow(match_atc_codes)) {
        # No ICD matches found, check ATC and OPS Proxys for ICDs
        match_icd_proxies <- matchICDProxies(
          medication_resources = list(
            medication_requests = resources$medication_requests[medreq_patient_ref == paste0("Patient/", patient_id)],
            medication_statements = resources$medication_statements[medstat_patient_ref == paste0("Patient/", patient_id)],
            medication_administrations = resources$medication_administrations[medadm_patient_ref == paste0("Patient/", patient_id)]
          ),
          procedure_resources = resources$procedures[proc_patient_ref == paste0("Patient/", patient_id)],
          drug_disease_mrp_tables_by_icd = drug_disease_mrp_tables_by_icd,
          meda_datetime = meda_datetime
        )

        match_atc_and_icd_codes <- match_icd_proxies
      }
    } else {
      # No active medication requests found for this encounter
      match_atc_and_icd_codes <- data.table()
    }

    if (nrow(match_atc_and_icd_codes)) {
      # Iterate over matched results and create new rows for retrolektive_mrpbewertung and dp_mrp_calculations
      for (i in nrow(match_atc_and_icd_codes)) {
        match <- match_atc_and_icd_codes[i]
        # Create new row for table retrolektive_mrpbewertung
        retrolektive_mrpbewertung_rows[[length(retrolektive_mrpbewertung_rows) + 1]] <- list(
          record_id = record_id,
          ret_id = paste0(meda_id, "-r", i),
          ret_meda_id = meda_id,
          ret_meda_dat1 = meda_datetime,
          ret_kurzbeschr = match$kurzbeschr,
          ret_atc1 = match$atc,
          ret_ip_klasse_01 = MRP_CALCULATION_TYPE$Drug_Disease,
          ret_ip_klasse_disease = match$icd,
          redcap_repeat_instrument = "retrolektive_mrpbewertung",
          redcap_repeat_instance = i
        )

        # Create new row for table dp_mrp_calculations
        dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
          enc_id = encounter_id,
          mrp_calculation_type = MRP_CALCULATION_TYPE$Drug_Disease,
          meda_id = meda_id,
          ret_id = retrolektive_mrpbewertung_rows[[length(retrolektive_mrpbewertung_rows)]]$ret_id,
          mrp_proxy_type = NA_character_,
          mrp_proxy_code = NA_character_
        )

      }
    } else {
      # No matches found for this encounter
      dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
        enc_id = encounter_id,
        mrp_calculation_type = MRP_CALCULATION_TYPE$Drug_Disease,
        meda_id = meda_id,
        ret_id = NA_character_,
        mrp_proxy_type = NA_character_,
        mrp_proxy_code = NA_character_
      )
    }
  }
  # Combine all collected rows into data.tables
  retrolektive_mrpbewertung <- data.table::rbindlist(retrolektive_mrpbewertung_rows, use.names = TRUE, fill = TRUE)
  dp_mrp_calculations <- data.table::rbindlist(dp_mrp_calculations_rows, use.names = TRUE, fill = TRUE)

  return(list(
    retrolektive_mrpbewertung_fe = retrolektive_mrpbewertung,
    dp_mrp_calculations = dp_mrp_calculations
  ))
}
