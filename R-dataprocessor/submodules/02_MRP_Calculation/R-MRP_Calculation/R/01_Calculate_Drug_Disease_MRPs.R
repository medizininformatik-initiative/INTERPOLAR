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

  code_column_names <- c(code_column_names[!startsWith(code_column_names, "ATC")], "ATC_FOR_CALCULATION")
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
  atc_columns <- grep("ATC(?!.*(DISPLAY|INCLUSION|VALIDITY_DAYS))", names(drug_disease_mrp_definition), value = TRUE, perl = TRUE)
  invalid_atcs <- etlutils::getInvalidATCCodes(drug_disease_mrp_definition, atc_columns)

  # check column LOINC_PROXY for correct LOINC codes
  invalid_loincs <- etlutils::getInvalidLOINCCodes(drug_disease_mrp_definition, "LOINC_PRIMARY_PROXY")

  error_messages <- c(
    formatCodeErrors(invalid_atcs, "ATC"),
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
  matchProxy <- function(all_items, proxy_tables, proxy_type, code_column, proxy_col_name, validity_days_col_name) {
    mrp_matches <- list()
    used_codes <- unique(all_items[!is.na(code), code])
    matching_proxies <- intersect(names(proxy_tables), used_codes)

    for (proxy_code in matching_proxies) {
      single_proxy_sub_table <- proxy_tables[[proxy_code]]
      match_proxy_row <- single_proxy_sub_table[get("ATC_FOR_CALCULATION") %in% match_atc_codes & !is.na(get(proxy_col_name)) & get(proxy_col_name) != ""]

      recources_with_proxy <- all_items[grepl(proxy_code, code, fixed = TRUE)]
      if (nrow(recources_with_proxy)) {

        for (i in seq_len(nrow(match_proxy_row))) {
          match_proxy_row <- match_proxy_row[i]
          proxy_validity_days <- match_proxy_row[[validity_days_col_name]]
          fallback_validity_days <- match_proxy_row$ICD_VALIDITY_DAYS
          validity_days <- if (!is.na(proxy_validity_days) && trimws(proxy_validity_days) != "") proxy_validity_days else fallback_validity_days
          validity_days <- as.integer(validity_days)
          # All non integer values are considered as unlimited validity duration
          if (is.na(validity_days)) {
            validity_days <- .Machine$integer.max
          }

          mrp_match_found <- any(recources_with_proxy$start_date <= meda_datetime & (is.na(recources_with_proxy$end_date) | recources_with_proxy$end_date + validity_days >= meda_datetime))

          if (mrp_match_found) {
            mrp_matches[[length(mrp_matches) + 1]] <- data.table::data.table(
              icd_code = match_proxy_row$ICD,
              atc_code = match_proxy_row$ATC_FOR_CALCULATION,
              proxy_code = proxy_code,
              proxy_type = proxy_type,
              kurzbeschr = sprintf(
                "%s (%s) ist bei %s (%s) kontrainduziert.\n%s ist als %s-Proxy für %s verwendet worden.",
                match_proxy_row$ATC_DISPLAY, match_proxy_row$ATC_FOR_CALCULATION,
                match_proxy_row$CONDITION_DISPLAY_CLUSTER, match_proxy_row$ICD,
                proxy_code, proxy_type, match_proxy_row$ICD
              )
            )
          }
        }
      }
    }
    return(mrp_matches)
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
    proxy_tables = drug_disease_mrp_tables_by_atc_proxy,
    proxy_type = "ATC",
    code_column = "code",
    proxy_col_name = "ICD_PROXY_ATC",
    validity_days_col_name = "ICD_PROXY_ATC_VALIDITY_DAYS"
  )

  # OPS-Proxy-Matching
  ops_matches <- matchProxy(
    all_items = all_procedures,
    proxy_tables = drug_disease_mrp_tables_by_ops_proxy,
    proxy_type = "OPS",
    code_column = "code",
    proxy_col_name = "ICD_PROXY_OPS",
    validity_days_col_name = "ICD_PROXY_OPS_VALIDITY_DAYS"
  )

  return(data.table::rbindlist(c(atc_matches, ops_matches), fill = TRUE))
}

#' Split Drug-Disease MRP Table into Lookup Structures
#'
#' Takes a full Drug-Disease MRP table and splits it into multiple lookup tables
#' to support efficient MRP evaluation. Splitting is done by relevant rule keys such as:
#' ATC codes, ICD codes, and proxy definitions (ATC and OPS).
#'
#' @param drug_disease_mrp_tables A named list containing the key \code{processed_content},
#'   which holds the complete MRP definition table for Drug-Disease interactions as a \code{data.table}.
#'
#' @return A list of named \code{data.table} lookup structures:
#' \describe{
#'   \item{by_atc}{Split by \code{ATC_FOR_CALCULATION}, used for direct ATC code matching.}
#'   \item{by_icd}{Split by \code{ICD}, used to match ICD codes from conditions.}
#'   \item{by_atc_proxy}{Split by \code{ICD_PROXY_ATC}, used for proxy rules based on medication.}
#'   \item{by_ops_proxy}{Split by \code{ICD_PROXY_OPS}, used for proxy rules based on procedures.}
#' }
#'
getSplittedMRPTablesDrugDisease <- function(drug_disease_mrp_tables) {
  drug_disease_mrp_table_content <- drug_disease_mrp_tables$processed_content
  list(
    by_atc = etlutils::splitTableToList(drug_disease_mrp_table_content, "ATC_FOR_CALCULATION"),
    by_icd = etlutils::splitTableToList(drug_disease_mrp_table_content, "ICD"),
    by_atc_proxy = etlutils::splitTableToList(drug_disease_mrp_table_content, "ICD_PROXY_ATC"),
    by_ops_proxy = etlutils::splitTableToList(drug_disease_mrp_table_content, "ICD_PROXY_OPS")
  )
}

#' Calculate Drug-Disease Medication-Related Problems (MRPs)
#'
#' Detects MRPs by evaluating combinations of medications (ATC codes) and diseases (ICD codes).
#' If direct ICD matches are not found for an ATC, proxy rules are applied using medication
#' and procedure history to infer possible conditions.
#'
#' @param active_requests A \code{data.table} of the patient's active medications (e.g. FHIR MedicationRequest).
#' @param splitted_mrp_tables A list of lookup tables created by \code{getSplittedMRPTablesDrugDisease()}.
#' @param resources A named list of all FHIR resource tables relevant to the encounter (conditions, medications, procedures, etc.).
#' @param patient_id A character string representing the internal patient ID.
#' @param meda_datetime A POSIXct timestamp representing the time of medication evaluation.
#'
#' @return A \code{data.table} containing matched Drug-Disease MRPs, including both direct and proxy-based findings.
#'
calculateMRPsDrugDisease <- function(active_requests, splitted_mrp_tables, resources, patient_id, meda_datetime) {
  match_atc_and_icd_codes <- data.table::data.table()
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
        drug_disease_mrp_tables_by_atc_proxy = splitted_mrp_tables$by_atc_proxy,
        drug_disease_mrp_tables_by_ops_proxy = splitted_mrp_tables$by_ops_proxy,
        meda_datetime = meda_datetime,
        match_atc_codes = unmatched_atcs$atc_code
      )
      if (nrow(match_icd_proxies)) {
        match_atc_and_icd_codes <- rbind(match_atc_and_icd_codes, match_icd_proxies, fill = TRUE)
      }
    }
  }
  return(match_atc_and_icd_codes)
}
