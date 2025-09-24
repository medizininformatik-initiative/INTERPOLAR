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
#'     \item{referenceRangeLow}{Lower reference bound (LLN)}
#'     \item{referenceRangeHigh}{Upper reference bound (ULN)}
#'     \item{start_date}{Date/time of observation}
#'   }
#' @param match_proxy_row A single-row `data.table` from the drug–disease proxy table
#'   containing at least the column `LOINC_CUTOFF_REFERENCE`.
#' @param additional_table A lookup `data.table` containing LOINC metadata, including
#'   columns:
#'   \describe{
#'     \item{LOINC}{LOINC code}
#'     \item{GERMAN_NAME_LOINC_PRIMARY}{German display name of the LOINC}
#'   }
#'
#' @return A character string describing the match if the cutoff was met, otherwise `NA_character_`.
#'
matchLOINCCutoff <- function(observation_resources, match_proxy_row, additional_table) {
  match_description <- NA_character_
  cutoff_reference <- match_proxy_row$LOINC_CUTOFF_REFERENCE
  cutoff_reference <- trimws(cutoff_reference)

  if (!is.na(cutoff_reference) && cutoff_reference != "") {
    # Parse the cutoff string into its components: operator, multiplier, and ULN/LLN
    # Possible cutoff formats: "> ULN", "< LLN", ">= 3*ULN", "<= 2*LLN"
    parseCutoff <- function(cutoff) {
      # Result are the parts in the round brackets
      pattern <- "^([<>]=?)\\s*(\\d*\\.?\\d*)\\*?\\s*(ULN|LLN)$"
      matches <- regexec(pattern, cutoff)
      parts <- regmatches(cutoff, matches)[[1]]

      # 1= full string, 2= operator, 3= multiplier, 4= ULN/LLN
      if (length(parts) == 4) {
        operator <- parts[2]
        multiplier <- as.numeric(ifelse(parts[3] == "", 1, parts[3]))
        reference <- parts[4]
        list(operator = operator, multiplier = multiplier, reference = reference)
      }
    }

    # Get parsed cutoff components
    cutoff <- parseCutoff(cutoff_reference)
    if (!is.null(cutoff)) {
      # Determine which column to use as the reference limit
      reference_col <- if (cutoff$reference == "ULN") {
        "referenceRangeHigh"
      } else if (cutoff$reference == "LLN") {
        "referenceRangeLow"
      } else {
        NA  # Invalid reference keyword
      }

      if(!is.na(reference_col)) {
        # Filter only valid observation rows (non-NA values)
        obs <- observation_resources[!is.na(value) & !is.na(get(reference_col))]

        if (nrow(obs)) {
          # Calculate the threshold based on the multiplier
          threshold <- obs[[reference_col]] * cutoff$multiplier

          # Vectorized comparison of lab values to threshold using specified operator
          match_found <- switch(
            cutoff$operator,
            ">"  = obs$value >  threshold,
            ">=" = obs$value >= threshold,
            "<"  = obs$value <  threshold,
            "<=" = obs$value <= threshold,
            rep(FALSE, nrow(obs))  # fallback for unknown operator
          )

          match_found <- ifelse(is.na(match_found), FALSE, match_found)

          if (any(match_found)) {

            cutoff_description <- list(
              matched_values = obs$value[match_found],
              matched_code = obs$code[match_found],
              matched_unit = obs$unit[match_found],
              matched_start_date = obs$start_date[match_found],
              matched_referenceRangeLow = obs$referenceRangeLow[match_found],
              matched_referenceRangeHigh = obs$referenceRangeHigh[match_found],
              operator = cutoff$operator,
              multiplier = cutoff$multiplier,
              reference = cutoff$reference
            )

            loinc_description <- additional_table$processed_content[LOINC == cutoff_description$matched_code, GERMAN_NAME_LOINC_PRIMARY]
            # Create a description of the match
            match_description <- paste0("Beim Laborparameter ", loinc_description, " (", cutoff_description$matched_code,
                                        ") wurde gemessen: \n ", "Wert: ", cutoff_description$matched_values, " (",
                                        cutoff_description$matched_unit,") \n", "Referenbereich: ", cutoff_description$matched_referenceRangeLow,
                                        " - ", cutoff_description$matched_referenceRangeHigh, " \n ",
                                        "Zeitpunkt: ", cutoff_description$matched_start_date)
          }
        }
      }
    } else {
      # try cutoff absolute value via columns LOINC_CUTOFF_ABSOLUTE and LOINC_UNIT with a lookup via LOINC_PRIMARY_PROXY
      # in Interpolar/Input-Repo/INTERPOLAR-WP7/LOINC_Mapping/LOINC_Mapping_content/LOINC_Mapping_Table_processed.xlsx
      # and conversion of the unit if necessary
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
#'   Each must include columns `atc_code`, `start_date`, and optionally `end_date`.
#'
#' @param procedure_resources A `data.table` containing procedures with columns:
#'   - `proc_code_code`: the OPS code
#'   - `start_date`: date of the procedure
#'   - `end_date`: optional end date of the procedure
#'
#' @param observation_resources A `data.table` containing lab or observation data with columns:
#'   - `obs_code_code`: the LOINC code
#'   - `obs_valuequantity_value`: measured value
#'   - `obs_valuequantity_unit`: measurement unit
#'   - `obs_referencerange_low_value` / `obs_referencerange_high_value`: reference range
#'   - `start_date`: date of measurement
#'   - `end_date`: optional end date
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
#'   It must accept arguments `observation_resources`, `match_proxy_row`, and `additional_table`
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
    loinc_matching_function,
    loinc_mapping_table
) {
  matchProxy <- function(proxy_type, all_items, splitted_proxy_table, additional_matching_function = NULL, additional_table = NULL) {
    mrp_matches <- list()
    used_codes <- unique(all_items[!is.na(code), code])
    matching_proxies <- names(splitted_proxy_table)[
      vapply(names(splitted_proxy_table), function(key) {
        any(startsWith(used_codes, key))
      }, logical(1))
    ]
    for (proxy_code in matching_proxies) {
      single_proxy_sub_table <- splitted_proxy_table[[proxy_code]]
      match_proxy_rows <- single_proxy_sub_table[get("ATC_FOR_CALCULATION") %in% match_atc_codes & etlutils::isSimpleNotEmptyString(get("ICD_PROXY")]

      # Copy column content into new column as comma-separated string
      icd_full_list <- paste0(match_proxy_rows$ICD, collapse = ", ")
      match_proxy_rows[, ICD_FULL_LIST := icd_full_list]
      # Remove ICD column to prevent multiple identical rows with different ICD codes
      match_proxy_rows[, ICD := NA_character_]
      match_proxy_rows <- unique(match_proxy_rows)

      recources_with_proxy <- all_items[grepl(proxy_code, code, fixed = TRUE)]
      if (nrow(recources_with_proxy)) {

        for (i in seq_len(nrow(match_proxy_rows))) {
          match_proxy_row <- match_proxy_rows[i]
          proxy_validity_days <- match_proxy_row[["ICD_PROXY_VALIDITY_DAYS"]]
          fallback_validity_days <- match_proxy_row$ICD_VALIDITY_DAYS
          validity_days <- if (!is.na(proxy_validity_days) && trimws(proxy_validity_days) != "") proxy_validity_days else fallback_validity_days
          validity_days <- suppressWarnings(as.integer(validity_days))
          # All non integer values are considered as unlimited validity duration
          if (is.na(validity_days)) {
            validity_days <- .Machine$integer.max
          }

          valid_proxy_rows <- recources_with_proxy[
            start_date <= meda_datetime &
              (is.na(end_date) | end_date + validity_days >= meda_datetime)
          ]

          if (nrow(valid_proxy_rows)) {
            kurzbeschr <- sprintf(paste0(
              "%s (%s) ist bei %s kontrainduziert.\n",
              "%s ist als %s-Proxy für %s verwendet worden.\n",
              "\n",
              "Komplette Liste der ICD Codes die der Proxy-Code bedeuten kann: \n",
              "%s"),
              match_proxy_row$ATC_DISPLAY, match_proxy_row$ATC_FOR_CALCULATION,
              match_proxy_row$CONDITION_DISPLAY_CLUSTER, proxy_code, proxy_type,
              match_proxy_row$CONDITION_DISPLAY_CLUSTER, match_proxy_row$ICD_FULL_LIST)

            if (!is.null(additional_matching_function)) {
              # Call the external custom function
              mrp_match_description <- additional_matching_function(
                observation_resources = valid_proxy_rows,
                match_proxy_row = match_proxy_row,
                additional_table = additional_table
              )
              # If the matching function returns NA, skip this proxy match
              if (!is.na(mrp_match_description)) {
                kurzbeschr <- paste(kurzbeschr, mrp_match_description, sep = "\n")
              }
            }

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
  #  Combine all observation rows
  all_observations <- observation_resources[, .(code = obs_code_code, value = obs_valuequantity_value,
                                                unit = obs_valuequantity_unit, referenceRangeLow = obs_referencerange_low_value,
                                                referenceRangeHigh = obs_referencerange_high_value, start_date = start_date, end_date = as.Date(NA))]
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
  browser()
  loinc_matches <- matchProxy(
    proxy_type = "LOINC",
    all_items = all_observations,
    splitted_proxy_table = drug_disease_mrp_tables_by_loinc_proxy,
    additional_matching_function = loinc_matching_function,
    additional_table = loinc_mapping_table
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
  # Rename the specific proxy and validity days columns in each splitted table to a common name "ICD_PROXY" and "ICD_PROXY_VALIDITY_DAYS"
  data.table::setnames(splitted$by_atc_proxy,   c("ICD_PROXY_ATC",       "ICD_PROXY_ATC_VALIDITY_DAYS"), c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))
  data.table::setnames(splitted$by_ops_proxy,   c("ICD_PROXY_OPS",       "ICD_PROXY_OPS_VALIDITY_DAYS"), c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))
  data.table::setnames(splitted$by_loinc_proxy, c("LOINC_PRIMARY_PROXY", "LOINC_VALIDITY_DAYS"        ), c("ICD_PROXY", "ICD_PROXY_VALIDITY_DAYS"))

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
  loinc_mapping <- getLOINCMapping()
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
        loinc_matching_function = matchLOINCCutoff,
        loinc_mapping_table = loinc_mapping
      )
      if (nrow(match_icd_proxies)) {
        match_atc_and_icd_codes <- rbind(match_atc_and_icd_codes, match_icd_proxies, fill = TRUE)
      }
    }
  }
  return(match_atc_and_icd_codes)
}
