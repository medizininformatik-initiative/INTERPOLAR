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
    !is.na(start_date) &
      start_date >= enc_period_start &
      start_date <= meda_datetime &
      (is.na(end_date) |
         end_date > meda_datetime)
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
    con_patient_ref == paste0("Patient/", patient_id) & !is.na(start_date) & start_date <= meda_datetime]

  relevant_cols <- c("con_patient_ref", "con_code_code", "con_code_system", "start_date")
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
        condition_match <- any(patient_conditions$start_date <= meda_datetime)
      } else {
        validity_days <- as.numeric(validity_days)
        condition_match <- any(
          patient_conditions$start_date >= (meda_datetime - lubridate::days(validity_days)) &
            patient_conditions$start_date <= meda_datetime
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

#' Match ICD Proxies Using ATC and OPS Codes
#'
#' This function analyzes a patient's medication and procedure data to infer ICD diagnoses
#' based on proxy rules defined in drug-disease MRP (medication risk profile) tables. These rules
#' define ATC (Anatomical Therapeutic Chemical) or OPS (Operationen- und Prozedurenschlüssel, i.e. German procedure)
#' codes as proxies for ICD diagnoses.
#'
#' The function evaluates whether proxy events (e.g., medication or procedure entries) occurred within
#' a rule-defined time window relative to a reference datetime. Matching proxies are returned
#' as suggested ICD codes with context descriptions.
#'
#' @param medication_resources A named list of `data.table`s containing medication information:
#'   - `medication_requests`
#'   - `medication_statements`
#'   - `medication_administrations`
#'   Each must include columns `atc_code` and `start_date`.
#'
#' @param procedure_resources A `data.table` containing procedures with columns:
#'   - `proc_code_code`: the OPS code
#'   - `start_date`: date of the procedure
#'
#' @param drug_disease_mrp_tables_by_atc_proxy A named list of `data.table`s, one per ATC code,
#'   containing MRP rules. Each table should include the columns: `ICD`, `ICD_PROXY_ATC`,
#'   `ICD_PROXY_ATC_VALIDITY_DAYS`, `ICD_VALIDITY_DAYS`, and `ATC_FOR_CALCULATION`.
#'
#' @param drug_disease_mrp_tables_by_ops_proxy A named list of `data.table`s, one per OPS code,
#'   containing MRP rules. Each table should include: `ICD`, `ICD_PROXY_OPS`,
#'   `ICD_PROXY_OPS_VALIDITY_DAYS`, `ICD_VALIDITY_DAYS`, and `ATC_FOR_CALCULATION`.
#'
#' @param meda_datetime A `Date` or `POSIXct` object representing the reference datetime
#'   for evaluating proxy validity windows.
#'
#' @param match_atc_codes A character vector of ATC codes that are being evaluated (e.g.,
#'   medication in question triggering the contraindication check).
#'
#' @return A `data.table` of inferred ICD proxies with columns:
#' \describe{
#'   \item{icd_code}{The ICD code inferred via proxy}
#'   \item{atc_code}{The ATC code evaluated (from the rule)}
#'   \item{proxy_code}{The matching ATC or OPS proxy code that triggered the inference}
#'   \item{proxy_type}{One of `"ATC"` or `"OPS"`}
#'   \item{kurzbeschr}{A short German description of the match reasoning}
#' }
#'
#' @details
#' - The function returns one row per matched rule per ICD code.
#' - Only rules with a valid, non-empty proxy field are evaluated.
#' - Validity periods can be numerical (in days) or `"unbegrenzt"` (no time restriction).
#' - Matching is performed via `grepl` with `fixed = TRUE` for proxy codes.
#'
matchICDProxies <- function(
    medication_resources,
    procedure_resources,
    drug_disease_mrp_tables_by_atc_proxy,
    drug_disease_mrp_tables_by_ops_proxy,
    meda_datetime,
    match_atc_codes
) {
  matchProxy <- function(all_items, proxy_table_list, proxy_type, code_column, rule_proxy_col, rule_validity_col) {
    matched <- list()
    used_codes <- unique(all_items[!is.na(code), code])
    matching_proxies <- intersect(names(proxy_table_list), used_codes)

    for (proxy_code in matching_proxies) {
      rules <- proxy_table_list[[proxy_code]]
      rules <- rules[get("ATC_FOR_CALCULATION") %in% match_atc_codes & !is.na(get(rule_proxy_col)) & get(rule_proxy_col) != ""]

      for (i in seq_len(nrow(rules))) {
        rule <- rules[i]
        validity <- rule[[rule_validity_col]]
        fallback_validity <- rule$ICD_VALIDITY_DAYS
        validity_days <- if (!is.na(validity) && validity != "") validity else fallback_validity

        recources_with_proxy <- all_items[grepl(proxy_code, code, fixed = TRUE)]

        if (!nrow(recources_with_proxy)) next

        match_found <- if (tolower(validity_days) == "unbegrenzt") {
          any(recources_with_proxy$start_date <= meda_datetime)
        } else {
          validity_days_num <- as.numeric(validity_days)
          any(recources_with_proxy$start_date <= meda_datetime & (recources_with_proxy$end_date + validity_days_num) >= meda_datetime )
        }

        if (match_found) {
          matched[[length(matched) + 1]] <- data.table::data.table(
            icd_code = rule$ICD,
            atc_code = rule$ATC_FOR_CALCULATION,
            proxy_code = proxy_code,
            proxy_type = proxy_type,
            kurzbeschr = sprintf(
              "%s (%s) ist bei %s (%s) kontrainduziert.\n%s ist als %s-Proxy für %s verwendet worden.",
              rule$ATC_DISPLAY, rule$ATC_FOR_CALCULATION,
              rule$CONDITION_DISPLAY_CLUSTER, rule$ICD,
              proxy_code, proxy_type, rule$ICD
            )
          )
        }
      }
    }

    return(matched)
  }

  #  Combine all medication rows
  all_medications <- rbind(
    medication_resources$medication_requests[, .(code = atc_code, start_date, end_date)],
    medication_resources$medication_statements[, .(code = atc_code, start_date, end_date)],
    medication_resources$medication_administrations[, .(code = atc_code, start_date, end_date)],
    fill = TRUE
  )

  #  Combine all procedures rows
  all_procedures <- procedure_resources[, .(code = proc_code_code, start_date, end_date)]

  # ATC-Proxy-Matching
  atc_matches <- matchProxy(
    all_items = all_medications,
    proxy_table_list = drug_disease_mrp_tables_by_atc_proxy,
    proxy_type = "ATC",
    code_column = "code",
    rule_proxy_col = "ICD_PROXY_ATC",
    rule_validity_col = "ICD_PROXY_ATC_VALIDITY_DAYS"
  )

  # OPS-Proxy-Matching
  ops_matches <- matchProxy(
    all_items = all_procedures,
    proxy_table_list = drug_disease_mrp_tables_by_ops_proxy,
    proxy_type = "OPS",
    code_column = "code",
    rule_proxy_col = "ICD_PROXY_OPS",
    rule_validity_col = "ICD_PROXY_OPS_VALIDITY_DAYS"
  )

  return(data.table::rbindlist(c(atc_matches, ops_matches), fill = TRUE))
}


#' Calculate Drug-Disease Medication-Related Problems (MRPs)
#'
#' This function analyzes potential drug-disease interactions across a set of patient
#' encounters. It evaluates predefined MRP (medication-related problem) rules for
#' contraindications between active medications and known patient diagnoses.
#'
#' For each encounter, the function:
#' \itemize{
#'   \item Gathers all active medications and patient conditions.
#'   \item Matches medication ATC codes against MRP definitions.
#'   \item Attempts to find matching ICD codes directly from patient conditions.
#'   \item If no direct ICD matches are found, evaluates proxy rules (using ATC or OPS codes).
#'   \item Compiles results into descriptive and audit tables.
#' }
#'
#' @param drug_disease_mrp_tables A `data.table` containing MRP rules for drug-disease
#'   interactions. Expected columns include:
#'   \describe{
#'     \item{ATC_FOR_CALCULATION}{ATC code used for rule evaluation}
#'     \item{ICD}{Target ICD code (contraindicated condition)}
#'     \item{ICD_VALIDITY_DAYS}{Validity period for the ICD diagnosis}
#'     \item{ICD_PROXY_ATC}{Optional proxy ATC code used if no direct ICD is found}
#'     \item{ICD_PROXY_ATC_VALIDITY_DAYS}{Validity window for proxy ATC usage}
#'     \item{ICD_PROXY_OPS}{Optional OPS code used as an ICD proxy}
#'     \item{ICD_PROXY_OPS_VALIDITY_DAYS}{Validity window for proxy OPS usage}
#'   }
#'
#' @param input_file_processed_content_hash A string hash identifying the content version of the input file
#'   used during calculation (useful for reproducibility and auditing).
#'
#' @return A named list with two `data.table` objects:
#' \describe{
#'   \item{retrolektive_mrpbewertung_fe}{MRP evaluations found for each encounter, ready for reporting or REDCap import.}
#'   \item{dp_mrp_calculations}{Audit log of all MRP evaluation steps, including proxy type and code used.}
#' }
#'
#' @details
#' - The function uses `getResourcesForMRPCalculation()` to load relevant FHIR resources.
#' - ATC codes are matched using `matchATCCodes()`, ICDs using `matchICDCodes()`.
#' - If no ICD match is found, `matchICDProxies()` evaluates proxy rules (ATC/OPS).
#' - Each match results in one entry in both output tables.
#' - If no match is found for an encounter, a placeholder entry is created in `dp_mrp_calculations`.
#'
calculateDrugDiseaseMRPs <- function(drug_disease_mrp_tables, input_file_processed_content_hash) {
  resources <- getResourcesForMRPCalculation(MRP_CALCULATION_TYPE$Drug_Disease)

  if (!length(resources)) {
    return(list())
  }

  # Split drug_disease_mrp_tables by ATC and ICD
  drug_disease_mrp_tables_by_atc <- etlutils::splitTableToList(drug_disease_mrp_tables, "ATC_FOR_CALCULATION")
  drug_disease_mrp_tables_by_icd <- etlutils::splitTableToList(drug_disease_mrp_tables, "ICD")
  drug_disease_mrp_tables_by_atc_proxy <- etlutils::splitTableToList(drug_disease_mrp_tables, "ICD_PROXY_ATC")
  drug_disease_mrp_tables_by_ops_proxy <- etlutils::splitTableToList(drug_disease_mrp_tables, "ICD_PROXY_OPS")

  # Initialize empty lists for results
  retrolektive_mrpbewertung_rows <- list()
  dp_mrp_calculations_rows <- list()

  for (encounter_id in resources$main_encounters$enc_id) {

    # Get encounter data and patient ID
    encounter <- resources$main_encounters[enc_id == encounter_id]
    patient_id <- etlutils::fhirdataExtractIDs(encounter$enc_patient_ref)
    meda <- resources$encounters_first_medication_analysis[[encounter_id]]
    meda_id <- if (!is.null(meda)) meda$meda_id else NA_character_
    meda_datetime <- if (!is.null(meda)) meda$meda_dat else NA
    meda_study_phase <- if (!is.null(meda)) meda$study_phase else NA_character_
    meda_ward_name <- if (!is.null(meda)) meda$ward_name else NA_character_
    record_id <- as.integer(resources$record_ids[pat_id == patient_id, record_id])
    ret_id <- ifelse(meda_study_phase == "PhaseBTest", paste0(meda_id, "-TEST"), meda_id)
    ret_status <- ifelse(meda_study_phase == "PhaseBTest", "Unverified", NA_character_)

    # Get active MedicationRequests for the encounter
    active_requests <- getActiveMedicationRequests(resources$medication_requests, encounter$enc_period_start, meda_datetime)

    if (nrow(active_requests) && meda_study_phase != "PhaseA") {
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
        matched_atcs <- unique(match_atc_and_icd_codes$atc)
        unmatched_atcs <- match_atc_codes[!(atc_code %in% matched_atcs)]

        if (nrow(unmatched_atcs)) {
          # No ICD matches found, check ATC and OPS Proxys for ICDs
          match_icd_proxies <- matchICDProxies(
            medication_resources = list(
              medication_requests = resources$medication_requests[medreq_patient_ref == paste0("Patient/", patient_id)],
              medication_statements = resources$medication_statements[medstat_patient_ref == paste0("Patient/", patient_id)],
              medication_administrations = resources$medication_administrations[medadm_patient_ref == paste0("Patient/", patient_id)]
            ),
            procedure_resources = resources$procedures[proc_patient_ref == paste0("Patient/", patient_id)],
            drug_disease_mrp_tables_by_atc_proxy = drug_disease_mrp_tables_by_atc_proxy,
            drug_disease_mrp_tables_by_ops_proxy = drug_disease_mrp_tables_by_ops_proxy,
            meda_datetime = meda_datetime,
            match_atc_codes = unmatched_atcs$atc_code
          )
          if (nrow(match_icd_proxies)) {
            match_atc_and_icd_codes <- rbind(match_atc_and_icd_codes, match_icd_proxies, fill = TRUE)
          }
        }
      } else {
        # No active medication requests found for this encounter
        match_atc_and_icd_codes <- data.table::data.table()
      }
    } else {
      match_atc_and_icd_codes <- data.table::data.table()
    }

    if (nrow(match_atc_and_icd_codes)) {
      # Iterate over matched results and create new rows for retrolektive_mrpbewertung and dp_mrp_calculations
      for (i in seq_len(nrow(match_atc_and_icd_codes))) {
        match <- match_atc_and_icd_codes[i]
        # Create new row for table retrolektive_mrpbewertung
        retrolektive_mrpbewertung_rows[[length(retrolektive_mrpbewertung_rows) + 1]] <- list(
          record_id = record_id,
          ret_id = paste0(ret_id, "-r", i),
          ret_meda_id = meda_id,
          ret_meda_dat1 = meda_datetime,
          ret_kurzbeschr = match$kurzbeschr,
          ret_atc1 = match$atc_code,
          ret_ip_klasse_01 = MRP_CALCULATION_TYPE$Drug_Disease,
          ret_ip_klasse_disease = match$icd,
          retrolektive_mrpbewertung_complete = ret_status,
          redcap_repeat_instrument = "retrolektive_mrpbewertung",
          redcap_repeat_instance = i
        )

        # Create new row for table dp_mrp_calculations
        dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
          enc_id = encounter_id,
          mrp_calculation_type = MRP_CALCULATION_TYPE$Drug_Disease,
          meda_id = meda_id,
          study_phase = meda_study_phase,
          ward_name = meda_ward_name,
          ret_id = retrolektive_mrpbewertung_rows[[length(retrolektive_mrpbewertung_rows)]]$ret_id,
          mrp_proxy_type = match$proxy_type,
          mrp_proxy_code = match$proxy_code,
          input_file_processed_content_hash = input_file_processed_content_hash
        )

      }
    } else {
      # No matches found for this encounter
      dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
        enc_id = encounter_id,
        mrp_calculation_type = MRP_CALCULATION_TYPE$Drug_Disease,
        meda_id = meda_id,
        study_phase = meda_study_phase,
        ward_name = meda_ward_name,
        ret_id = NA_character_,
        mrp_proxy_type = NA_character_,
        mrp_proxy_code = NA_character_,
        input_file_processed_content_hash = input_file_processed_content_hash
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
