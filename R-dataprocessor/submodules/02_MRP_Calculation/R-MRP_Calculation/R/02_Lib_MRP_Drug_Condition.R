.drug_condition_env <- new.env()

setDrugConditionListRows <- function(drug_condition_list_rows) {
  # Set the resources in the environment
  assign("drug_condition_list_rows", drug_condition_list_rows, envir = .drug_condition_env)
}

getDrugConditionListRows <- function() {
  if (exists("drug_condition_list_rows", envir = .drug_condition_env)) {
    get("drug_condition_list_rows", envir = .drug_condition_env)
  } else {
    data.table::data.table(
      ATC_FULL_LIST = character(),
      ICD_FULL_LIST = character(),
      CONDITION_DISPLAY_CLUSTER = character(),
      mrp_index = integer()
    )
  }
}

getNextMrpIndex <- function() {
  if (exists("drug_condition_list_rows", envir = .drug_condition_env)) {
    tbl <- get("drug_condition_list_rows", envir = .drug_condition_env)
    if (nrow(tbl) > 0 && "mrp_index" %in% names(tbl)) {
      return(max(tbl$mrp_index, na.rm = TRUE) + 1)
    }
  }
  return(1L)
}

getOrCreateMrpIndex <- function(match_proxy_row, drug_condition_list_rows) {
  # Arguments:
  #   match_proxy_row: data.table with columns ATC_FULL_LIST, ICD_FULL_LIST, CONDITION_DISPLAY_CLUSTER
  #   drug_condition_list_rows: existing mapping table with same columns + mrp_index

  current_key <- match_proxy_row[, .(
    ATC_FULL_LIST,
    ICD_FULL_LIST,
    CONDITION_DISPLAY_CLUSTER
  )]
  existing_entry <- drug_condition_list_rows[
    ATC_FULL_LIST %in% current_key$ATC_FULL_LIST &
      CONDITION_DISPLAY_CLUSTER %in% current_key$CONDITION_DISPLAY_CLUSTER &
      ICD_FULL_LIST %in% current_key$ICD_FULL_LIST
  ]

  if (nrow(existing_entry)) {
    mrp_index <- existing_entry$mrp_index
  } else {
    mrp_index <- getNextMrpIndex()
    drug_condition_list_rows <- rbind(
      drug_condition_list_rows,
      data.table::data.table(
        ATC_FULL_LIST = current_key$ATC_FULL_LIST,
        ICD_FULL_LIST = current_key$ICD_FULL_LIST,
        CONDITION_DISPLAY_CLUSTER = current_key$CONDITION_DISPLAY_CLUSTER,
        mrp_index = mrp_index
      ),
      fill = TRUE
    )

    setDrugConditionListRows(drug_condition_list_rows)
  }
  return(mrp_index)
}

####################################################################################################
# Functions that are only required for MRP calculation of Drug_Disease and Drug_Niereninsuffizienz #
####################################################################################################

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
#' @param mrp_tables_by_icd A named list of \code{data.table}s containing MRP rules grouped by ICD code
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
matchICDCodes <- function(relevant_conditions, mrp_tables_by_icd, match_atc_codes, meda_datetime, patient_id) {

  # Initialize empty result data.table
  matched_rows <- data.table::data.table(
    mrp_index = integer(),
    icd_code = character(),
    icd_display = character(),
    atc_code = character(),
    proxy_code = character(),
    proxy_type = character(),
    diagnosis_cluster = character(),
    kurzbeschr_drug = character(),
    kurzbeschr_suffix = character(),
    kurzbeschr_type = character(),
    kurzbeschr_item2 = character()
  )

  # Function to check if validity days match any patient condition
  validity_matches_patient <- function(validity_days, patient_conditions, meda_datetime) {
    if (tolower(validity_days) == "unbegrenzt") {
      return(any(patient_conditions$start_datetime <= meda_datetime))
    } else {
      return(any(
        patient_conditions$start_datetime >= (meda_datetime - lubridate::days(as.numeric(validity_days))) &
          patient_conditions$start_datetime <= meda_datetime
      ))
    }
  }

  # Filter all conditions for the current patient
  all_patient_conditions <- relevant_conditions[con_patient_ref == paste0("Patient/", patient_id)]
  used_icds <- unique(all_patient_conditions[!is.na(con_code_code), con_code_code])
  icds <- intersect(names(mrp_tables_by_icd), used_icds)

  for (mrp_icd in icds) {

    # Find matching ICD conditions for this specific ICD
    patient_conditions <- all_patient_conditions[
      con_code_code == mrp_icd &
        con_code_system == "http://fhir.de/CodeSystem/bfarm/icd-10-gm"
    ]

    if (!nrow(patient_conditions)) next

    # Extract all MRP rules for this ICD
    mrp_table_list_rows <- mrp_tables_by_icd[[mrp_icd]]
    mrp_table_list_rows <- mrp_table_list_rows[ATC_FOR_CALCULATION %in% match_atc_codes$atc_code]

    # Keep only relevant columns
    keep_cols <- c("ATC_DISPLAY", "ATC_FOR_CALCULATION", "ICD_VALIDITY_DAYS", "CONDITION_DISPLAY_CLUSTER",
                   "ATC_FULL_LIST", "ICD_FULL_LIST")
    mrp_table_list_rows <- unique(mrp_table_list_rows[, ..keep_cols])

    # Filter MRP rows based on validity days and patient conditions
    mrp_table_list_rows <- mrp_table_list_rows[
      ,
      {
        valid_rows <- .SD[
          sapply(
            ICD_VALIDITY_DAYS,
            validity_matches_patient,
            patient_conditions = patient_conditions,
            meda_datetime = meda_datetime
          )
        ]
        if (!nrow(valid_rows)) return(NULL)
        validity_num <- ifelse(
          tolower(valid_rows$ICD_VALIDITY_DAYS) == "unbegrenzt",
          Inf,
          as.numeric(valid_rows$ICD_VALIDITY_DAYS)
        )
        valid_rows[validity_num == min(validity_num)]
      },
      by = .(ATC_DISPLAY, ATC_FOR_CALCULATION)
    ]

    if (!nrow(mrp_table_list_rows)) next

    # Combine rows with same ATC, ICD and ICD validity by concatenating CONDITION_DISPLAY_CLUSTER
    mrp_table_list_rows <- mrp_table_list_rows[
      ,
      .(
        CONDITION_DISPLAY_CLUSTER = paste(
          unique(CONDITION_DISPLAY_CLUSTER),
          collapse = " und "
        ),
        ICD_FULL_LIST = paste(
          unique(unlist(strsplit(ICD_FULL_LIST, "\\s+"))),
          collapse = " "
        ),
        ATC_FULL_LIST = paste(
          unique(unlist(strsplit(ATC_FULL_LIST, "\\s+"))),
          collapse = " "
        )
      ),
      by = .(
        ATC_DISPLAY,
        ATC_FOR_CALCULATION,
        ICD_VALIDITY_DAYS
      )
    ]

    if (nrow(matched_rows)) {
      # Extract all diagnosis_cluster from matched_rows
      matched_clusters <- unique(na.omit(matched_rows$diagnosis_cluster))
      # Sort mrp_table_list_rows by matches
      mrp_table_list_rows <- mrp_table_list_rows[
        order(
          sapply(CONDITION_DISPLAY_CLUSTER, function(x)
            any(grepl(x, matched_clusters, fixed = TRUE))),
          decreasing = TRUE
        )
      ]
    }

    for (j in seq_len(nrow(mrp_table_list_rows))) {
      mrp_table_list_row <- mrp_table_list_rows[j]
      validity_days <- mrp_table_list_row$ICD_VALIDITY_DAYS

      if (tolower(validity_days) == "unbegrenzt") {
        condition_start_datetime <- max(patient_conditions$start_datetime)
      } else {
        condition_start_datetime <- patient_conditions[
          start_datetime >= (meda_datetime - lubridate::days(as.numeric(validity_days))) &
            start_datetime <= meda_datetime,
          start_datetime
        ][1]
      }

      # Check if any of the matched ATC codes appear in the current ATC field of the MRP definition
      relevant_atcs <- match_atc_codes[
        grepl(mrp_table_list_row$ATC_FOR_CALCULATION, atc_code),
        atc_code
      ]

      # Get or create mrp_index
      mrp_index <- getOrCreateMrpIndex(mrp_table_list_row, getDrugConditionListRows())

      # Add directly to matched_rows
      if (length(relevant_atcs) > 0) {
        new_row <- data.table::data.table(
          mrp_index = mrp_index,
          icd_code = mrp_icd,
          atc_code = relevant_atcs,
          proxy_code = mrp_icd, # for ICD MRP without a real proxy we set the ICD code as "proxy" code to get this value in the dp_mrp_calculations table in the proxy_code column
          proxy_type = "ICD", # same like with proxy code (even if this is not a proxy)
          diagnosis_cluster = mrp_table_list_row$CONDITION_DISPLAY_CLUSTER
        )

        # Add start_datetime of the matched ATC code
        new_row <- merge(new_row, match_atc_codes[, .(atc_code, start_datetime)],
                         by = "atc_code", all.x = TRUE)

        new_row[, icd_display := {
          displays <- relevant_conditions[con_code_code %in% icd_code, con_code_display]
          displays <- unique(displays[!is.na(displays)])
          if (length(displays) == 0) NA_character_ else paste(displays, collapse = "; ")
        }]

        new_row[, kurzbeschr_drug := paste0(mrp_table_list_row$ATC_DISPLAY, " - ", atc_code,
                                            "  (", format(start_datetime, "%Y-%m-%d %H:%M:%S"), ")")]
        new_row[, kurzbeschr_suffix := paste0("  [", diagnosis_cluster, "] kontraindiziert.\n")]
        new_row[, kurzbeschr_type := "Diagnose"]
        new_row[, kurzbeschr_item2 := paste0(icd_display, " - ", icd_code, "   (",
                                             format(condition_start_datetime, "%Y-%m-%d %H:%M:%S"), ")")]

        matched_rows <- rbind(matched_rows, new_row, fill = TRUE)
      }
    }
  }
  # Remove helper columns at the end
  matched_rows[, c("icd_display", "diagnosis_cluster") := NULL]
  return(matched_rows)
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

  # Step 1: Filter observations based on reference_range_type and unit convertibility
  valid_obs <- obs[
    ,
    {
      # --- Helper function to test whether a unit can be converted ---
      isConvertibleUnit <- function(unit_from, unit_to) {
        # Missing reference unit counts as convertible
        if (is.na(unit_to)) return(TRUE)
        !is.na(convertLabUnits(1, unit_from, unit_to))
      }
      # --- 1.1: Try to use rows where reference_range_type == "normal" ---
      preferred <- .SD[reference_range_type == "normal"]
      # --- 1.2: If no "normal" rows exist, try those with missing type ---
      if (!nrow(preferred)) {
        preferred <- .SD[is.na(reference_range_type)]
      }
      # --- 1.3: If neither "normal" nor NA exists → mark as invalid ---
      if (!nrow(preferred)) {
        NULL
      } else {
        # Determine which rows have convertible or missing reference units
        # preferred[, is_convertible := mapply(isConvertibleUnit, unit, get(reference_unit_col))]
        #
        # convertible <- preferred[is_convertible == TRUE]
        convertible <- preferred[
          mapply(isConvertibleUnit, unit, get(reference_unit_col))
        ]
        # --- 1.1.2: If no convertible rows exist → mark as invalid ---
        if (!nrow(convertible)) {
          NULL
        } else {
          # --- 1.1.1: Keep the first convertible row ---
          convertible[1]
        }
      }
    },
    by = non_ref_cols
  ]

  if (nrow(valid_obs)) {
    # Sort column order before fsetdiff
    data.table::setcolorder(obs, sort(names(obs)))
    data.table::setcolorder(valid_obs, sort(names(valid_obs)))
    # Invalid observations are those that were dropped
    invalid_obs <- data.table::fsetdiff(obs, valid_obs)
    obs <- valid_obs

    # Step 2: Split observations into convertible and non-convertible
    obs_to_convert_unit <- obs[!is.na(get(reference_unit_col)) & !is.na(unit)]
    obs_no_convert_unit <- obs[is.na(get(reference_unit_col)) | is.na(unit)]
    obs_no_convert_unit[, converted_value := value]  # Non-convertible → value unchanged
    obs_to_convert_unit[, converted_value := NA_real_]  # Initialize converted values
    obs_no_convert_unit[, converted_unit := unit]  # Non-convertible → value unchanged
    obs_to_convert_unit[, converted_unit := NA_real_]  # Initialize converted values

    # Step 3: Perform unit conversion row by row
    invalid_idx <- c()
    for (i in seq_len(nrow(obs_to_convert_unit))) {
      unit_from <- obs_to_convert_unit$unit[i]
      unit_target <- obs_to_convert_unit[[reference_unit_col]][i]
      obs_row <- obs_to_convert_unit[i]

      # Attempt conversion
      converted_val <- convertLabUnits(
        measured_value = obs_row$value,
        measured_unit = unit_from,
        target_unit = unit_target,
        additional_error_message = paste0(" for LOINC code ", obs_row$code)
      )
      if (is.na(converted_val)) {
        invalid_obs <- if (nrow(invalid_obs) > 0) rbind(invalid_obs, obs_row, fill = TRUE) else obs_row
        invalid_idx <- c(invalid_idx, i)
      } else {
        obs_to_convert_unit$converted_value[i] <- converted_val
        obs_to_convert_unit$converted_unit[i] <- unit_target
      }
    }
    # Remove invalid observations after the loop
    if (length(invalid_idx) > 0) {
      obs_to_convert_unit <- obs_to_convert_unit[-invalid_idx]
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
  } else {
    invalid_obs <- obs
    obs <- data.table::data.table()
  }

  # Immediately issue warning for this single invalid observation
  catInvalidObservationsWarning(invalid_obs)

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
        # --- 1. Invalid observations based on numeric value or unit ---
        invalid_obs <- observation_resources[
          is.na(suppressWarnings(as.numeric(value))) | !isValidUnit(unit)
        ]

        # --- 2. Temporarily remove those invalid ones from main table ---
        valid_obs <- data.table::fsetdiff(observation_resources, invalid_obs)

        # --- 3. Now apply the next filter (reference values) ---
        obs <- valid_obs[!is.na(value) & !is.na(get(reference_value_col))]

        # --- 4. Add rows removed here also to invalid_obs ---
        invalid_obs <- rbind(
          invalid_obs,
          data.table::fsetdiff(valid_obs, obs),
          fill = TRUE
        )

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
                  conversion_unit = conversion_unit,
                  additional_error_message = paste0(" for LOINC code ", obs_row$code)
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
  }
  return(match_description)
}

#' Match ICD Proxies Using ATC, OPS, and LOINC Codes
#'
#' This function analyzes a patient's medication, procedure, and observation data to infer
#' ICD diagnoses based on proxy rules defined in drug-disease MRP (medication risk profile) tables.
#' Depending on the provided inputs, ATC (medications), OPS (procedures), and/or LOINC (laboratory
#' observations) codes can be used as proxies for ICD diagnoses.
#'
#' Only proxy types for which both resource data and corresponding MRP rule tables are provided
#' are evaluated. All proxy types are optional and can be combined arbitrarily.
#'
#' @param medication_resources Optional. A named list of `data.table`s containing medication information:
#'   - `medication_requests`
#'   - `medication_statements`
#'   - `medication_administrations`
#'   Each table must include columns `atc_code`, `start_datetime`, and optionally `end_datetime`.
#'   If `NULL`, ATC proxy matching is skipped.
#'
#' @param procedure_resources Optional. A `data.table` containing procedures with columns:
#'   - `proc_code_code`: the OPS code
#'   - `start_datetime`: date of the procedure
#'   - `end_datetime`: optional end date of the procedure
#'   If `NULL`, OPS proxy matching is skipped.
#'
#' @param observation_resources Optional. A `data.table` containing laboratory or observation data with columns:
#'   - `obs_code_code`: the LOINC code
#'   - `obs_valuequantity_value`: measured value
#'   - `obs_valuequantity_unit`: measurement unit
#'   - `obs_referencerange_low_value` / `obs_referencerange_high_value`: reference range
#'   - `start_datetime`: date of measurement
#'   If `NULL`, LOINC proxy matching is skipped.
#'
#' @param drug_condition_mrp_tables_by_atc_proxy Optional. A named list of `data.table`s (one per ATC proxy)
#'   containing MRP rules for ATC-based ICD inference. If `NULL`, ATC proxy matching is skipped.
#'
#' @param drug_condition_mrp_tables_by_ops_proxy Optional. A named list of `data.table`s (one per OPS proxy)
#'   containing MRP rules for OPS-based ICD inference. If `NULL`, OPS proxy matching is skipped.
#'
#' @param drug_condition_mrp_tables_by_loinc_proxy Optional. A named list of `data.table`s (one per LOINC proxy)
#'   containing MRP rules for LOINC-based ICD inference. If `NULL`, LOINC proxy matching is skipped.
#'
#' @param meda_datetime A `Date` or `POSIXct` object representing the reference datetime
#'   for evaluating proxy validity windows.
#'
#' @param match_atc_codes A `data.table` containing ATC codes under evaluation (e.g. medications
#'   triggering a contraindication check), including at least columns `atc_code` and `start_datetime`.
#'
#' @param loinc_mapping_table Optional. A `data.table` containing metadata for LOINC codes
#'   (e.g. mappings between primary and secondary LOINC codes). Required only for LOINC proxy matching.
#'
#' @param loinc_matching_function Optional. A function providing additional matching logic
#'   for LOINC proxies. It must accept arguments `observation_resources`, `match_proxy_row`,
#'   and `loinc_mapping_table`, and return either `NA` (no match) or a character vector describing
#'   the match reasoning. Required only for LOINC proxy matching.
#'
#' @return
#' A `data.table` containing inferred ICD diagnoses based on matched proxies.
#' One row is returned per matched proxy rule. If no proxy matches are found,
#' an empty `data.table` is returned.
#'
#' The result includes at least the following columns:
#' \describe{
#'   \item{icd_code}{The ICD code inferred via proxy matching}
#'   \item{atc_code}{The ATC code evaluated (from the MRP rule)}
#'   \item{proxy_code}{The ATC, OPS, or LOINC code that triggered the inference}
#'   \item{proxy_type}{The proxy type used: `"ATC"`, `"OPS"`, or `"LOINC"`}
#'   \item{kurzbeschr_*}{German textual descriptions explaining the matching context}
#' }
#'
#' @details
#' - Each proxy type (ATC, OPS, LOINC) is evaluated independently and only if the required inputs
#'   are provided.
#' - Validity periods can be numeric (days) or non-numeric (treated as unlimited).
#' - Matching is performed using prefix matching on proxy codes.
#' - For LOINC proxies, additional value- and reference-range-based logic can be applied via
#'   `loinc_matching_function`.
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
    # Initialize empty result data.table
    matched_rows <- data.table::data.table(
      mrp_index = integer(),
      icd_code = character(),
      atc_code = character(),
      proxy_code = character(),
      proxy_type = character(),
      kurzbeschr_drug = character(),
      kurzbeschr_suffix = character(),
      kurzbeschr_type = character(),
      kurzbeschr_item2 = character(),
      kurzbeschr_additional = character()
    )

    type_code_to_display <- c(
      ATC   = "Medikament",
      OPS   = "Prozedur",
      LOINC = "Laborwert"
    )

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
      match_proxy_rows <- single_proxy_sub_table[get("ATC_FOR_CALCULATION") %in% match_atc_codes$atc_code & !is.na(get("ICD_PROXY")) & get("ICD_PROXY") != ""]
      if (nrow(match_proxy_rows)) {
        # Remove other proxy rows
        cols_to_remove <- unique(c(
          grep("^ICD_PROXY_", names(match_proxy_rows), value = TRUE),
          if (proxy_type != "LOINC") grep("^LOINC_", names(match_proxy_rows), value = TRUE)
        ))
        cols_to_remove <- setdiff(cols_to_remove, "ICD_PROXY_VALIDITY_DAYS")
        if (length(cols_to_remove)) {
          match_proxy_rows[, (cols_to_remove) := NULL]
          # Remove ICD column data to prevent multiple identical rows with different ICD codes
          match_proxy_rows[, ICD := NA_character_]
        }
        match_proxy_rows <- unique(match_proxy_rows)

        if (nrow(match_proxy_rows)) {
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
                # LOINC values are valid for 7 days, all other types are valid for 36525 days, which are 100 years in the future
                validity_days <- ifelse (proxy_type == "LOINC", 7, 36525)
              }

              resources_with_proxy[is.na(end_datetime), end_datetime := start_datetime + lubridate::days(validity_days)]

              valid_proxy_rows <- unique(resources_with_proxy[start_datetime <= meda_datetime & end_datetime >= meda_datetime])

              if (nrow(valid_proxy_rows[!is.na(display)])) {
                first_valid_row <- valid_proxy_rows[!is.na(display)][1]
              } else {
                first_valid_row <- valid_proxy_rows[1]
              }
              proxy_display <- first_valid_row$display
              proxy_start_datetime <- first_valid_row$start_datetime

              # Get or create mrp_index
              mrp_index <- getOrCreateMrpIndex(match_proxy_row, getDrugConditionListRows())

              if (nrow(valid_proxy_rows)) {
                # Get the start datetime of the matched ATC code
                atc_start <- match_atc_codes[atc_code == match_proxy_row$ATC_FOR_CALCULATION, start_datetime][1]

                new_row <- data.table::data.table(
                  mrp_index = mrp_index,
                  icd_code = match_proxy_row$ICD,
                  atc_code = match_proxy_row$ATC_FOR_CALCULATION,
                  proxy_code = proxy_code,
                  proxy_type = proxy_type,
                  kurzbeschr_drug = paste0(match_proxy_row$ATC_DISPLAY, " - ", match_proxy_row$ATC_FOR_CALCULATION,
                                           "  (", format(atc_start, "%Y-%m-%d %H:%M:%S"), ")"),
                  kurzbeschr_suffix = paste0("  [", match_proxy_row$CONDITION_DISPLAY_CLUSTER, "] kontraindiziert.\n"),
                  kurzbeschr_type = type_code_to_display[[proxy_type]],
                  kurzbeschr_item2 = paste0(proxy_display, " - ", proxy_code),
                  kurzbeschr_additional = NA_character_
                )

                if (proxy_type != "LOINC") {
                  new_row[, kurzbeschr_item2 := paste0(
                    kurzbeschr_item2,
                    "   (",
                    format(proxy_start_datetime, "%Y-%m-%d %H:%M:%S"), ")")]
                  matched_rows <- rbind(matched_rows, new_row, fill = TRUE)
                } else {
                  # Call the external custom function
                  mrp_match_description <- loinc_matching_function(
                    observation_resources = valid_proxy_rows,
                    match_proxy_row = match_proxy_row,
                    loinc_mapping_table = loinc_mapping_table
                  )
                  # If both matching functions returns NA, skip this proxy match
                  if (length(mrp_match_description) && any(!is.na(mrp_match_description))) {
                    new_row[, kurzbeschr_additional :=  paste(mrp_match_description, collapse = "\n")]
                    matched_rows <- rbind(matched_rows, new_row, fill = TRUE)
                  }
                }
              }
            }
          }
        }
      }
    }
    return(matched_rows)
  }

  #  Combine all medication rows
  all_medications <- rbind(
    medication_resources$medication_requests[, .(code = atc_code, display = atc_display, start_datetime, end_datetime)],
    medication_resources$medication_statements[, .(code = atc_code, display = atc_display, start_datetime, end_datetime)],
    medication_resources$medication_administrations[, .(code = atc_code, display = atc_display, start_datetime, end_datetime)],
    fill = TRUE
  )
  #  Combine all procedures rows
  all_procedures <- procedure_resources[, .(code = proc_code_code, display = proc_code_display, start_datetime, end_datetime)]
  #  Combine all observation rows
  all_observations <- observation_resources[, .(code = obs_code_code,
                                                display = obs_code_display,
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

  return(data.table::rbindlist(list(atc_matches, ops_matches, loinc_matches), fill = TRUE))
}
