########################
# MRP List Preparation #
########################

#' Dynamically Retrieve a Function by Concatenating Prefix and Suffix
#'
#' This utility function dynamically constructs a function name by concatenating a given
#' prefix and a suffix (with underscores removed) and retrieves the corresponding function
#' from the global environment. This allows flexible referencing of functions that follow
#' a naming convention (e.g., `getRelevantColumnNamesDrugDisease`).
#'
#' @param prefix A \code{character} string specifying the function name prefix.
#' @param suffix A \code{character} string used as the function name suffix. Underscores
#'   in the suffix will be removed before concatenation.
#'
#' @return A reference to the requested function object.
#'
getFunctionByName <- function(prefix, suffix) {
  suffix_cleaned <- gsub("_", "", suffix)
  function_name <- paste0(prefix, suffix_cleaned)
  return(get(function_name, mode = "function"))
}

#' Get Relevant Column Names of a Specific Excel File
#'
#' Calls a dynamically resolved function to retrieve all relevant column names.
#'
#' @param table_name A \code{character} string specifying the MRP type (e.g., \code{"Drug_Disease"}) or LOINC Mapping.
#'
#' @return A named \code{character} vector of column names.
#'
getRelevantColumnNames <- function(table_name) {
  getFunctionByName("getRelevantColumnNames", table_name)()
}

#' Get Display Label for a Given MRP Type
#'
#' Returns a readable label to be used as the display category for the given MRP type,
#' such as \code{"Drug-Disease"}.
#'
#' @param mrp_type A \code{character} string representing the MRP type (e.g., \code{"Drug_Disease"}).
#'
#' @return A \code{character} string with the display name for the MRP category.
#'
getCategoryDisplay <- function(mrp_type) {
  getFunctionByName("getCategoryDisplay", mrp_type)()
}

#' Load and Expand All Available MRP Pair Definitions
#'
#' Iterates through all defined MRP types (from \code{MRP_TYPE}) and loads their
#' respective definition tables, returning an expanded list of all loaded definitions.
#'
#' @return A named \code{list} containing expanded MRP definition tables, one entry per MRP type.
#'
getMRPPairLists <- function() {
  mrp_pair_lists <- list()
  for (mrp_type in MRP_TYPE) {
    etlutils::runLevel3Line(paste0("Load and expand ", mrp_type, " Definition"), {
      mrp_content <- getExpandedExcelContent(mrp_type, table_name_prefix = "MRP_")
      if (!is.null(mrp_content)) {
        mrp_pair_lists[[mrp_type]] <- mrp_content
      }
    })
  }
  return(mrp_pair_lists)
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

###################
# MRP Calculation #
###################

#' Match ATC codes between active medication requests and MRP definitions
#'
#' This function compares ATC codes from a list of active medication requests with the keys
#' (ATC codes) in the MRP rule definitions and returns all codes that appear in both.
#'
#' @param active_atcs A \code{data.table} containing at least a column \code{atc_code}
#'        with the ATC codes from active medication requests.
#' @param mrp_table_list_by_atc A named list of \code{data.table}s, where each name is an ATC code
#'        and the corresponding table contains MRP rule definitions.
#'
#' @return A \code{data.table} with a single column \code{atc_code} listing all ATC codes
#'         found in both \code{active_atcs} and \code{mrp_table_list_by_atc}.
#'
matchATCCodes <- function(active_atcs, mrp_table_list_by_atc) {
  # Extract all ATC codes from the splitted MRP definitions (used as keys)
  mrp_atc_keys <- names(mrp_table_list_by_atc)
  # Reduce active_atcs to the relevant ATC codes (and keep their dates!)
  active_atcs_unique <- active_atcs[
    , .(start_datetime = etlutils::getMinDatetime(start_datetime)),
    by = atc_code
  ]
  # Only keep those that also appear in MRP definitions
  matching_atcs <- active_atcs_unique[atc_code %in% mrp_atc_keys]

  # Build the output properly
  result <- matching_atcs[
    , .(atc_code, start_datetime)
  ]

  return(result)
}

#' Compute combined ATC codes for calculation
#'
#' Diese Funktion berechnet eine kombinierte Liste von ATC-Codes, basierend auf einer
#' primären ATC-Spalte und optionalen Sekundärspalten, die durch eine Einschluss-Spalte
#' gesteuert werden.
#'
#' Wenn die Einschluss-Spalte oder die Sekundärspalten nicht vorhanden sind, wird einfach
#' die primäre ATC-Spalte als Ergebnis in der Ausgabespalte gespeichert.
#'
#' @param data_table data.table Das Datentable mit den zu verarbeitenden Daten.
#' @param primary_col character Name der Spalte mit den primären ATC-Codes.
#' @param inclusion_col character Name der Spalte mit den Einschlussbedingungen (Worte wie "alle", "keine weiteren" oder Suffix-Listen). Kann fehlen.
#' @param output_col character Name der Spalte, in die das Ergebnis geschrieben wird.
#' @param secondary_cols character Vektor mit Namen der Sekundärspalten, die abhängig von inclusion_col ergänzt werden können.
#'
#' @return NULL. Die Funktion verändert \code{data_table} direkt und fügt/überschreibt die Spalte \code{output_col}.
#'
#' @details
#' Die Funktion parst die Werte in \code{inclusion_col} pro Zeile, um zu entscheiden,
#' welche Sekundärspalten (nach Suffix) zusätzlich zu \code{primary_col} in der
#' Ergebnis-Spalte \code{output_col} enthalten sein sollen.
#'
computeATCForCalculation <- function(data_table, primary_col, inclusion_col, output_col, secondary_cols) {

  if (!(inclusion_col %in% names(data_table)) || !any(secondary_cols %in% names(data_table))) {
    data_table[, (output_col) := data_table[[primary_col]]]
    return(NULL)
  }

  suffix_map <- setNames(secondary_cols, sub(".*_", "", secondary_cols))

  data_table[, (output_col) := apply(.SD, 1, function(row) {
    inclusions <- trimws(unlist(strsplit(row[[inclusion_col]], "\\s+")))
    all_secondary <- character(0)

    for (inclusion in inclusions) {
      if (inclusion %in% "alle") {
        raw_values <- row[secondary_cols]
      } else if (is.na(inclusion) || !nchar(trimws(inclusion)) ||inclusion %in% "keine weiteren") {
        raw_values <- character(0)
      } else {
        suffixes <- trimws(unlist(strsplit(inclusion, ",")))
        cols <- suffix_map[suffixes]
        raw_values <- row[cols]
      }
      all_secondary <- c(all_secondary, raw_values)
    }
    secondary <- unlist(strsplit(paste(na.omit(all_secondary), collapse = " "), "\\s+"))
    all_atc <- unique(c(row[[primary_col]], secondary))
    all_atc <- all_atc[nzchar(all_atc)]
    paste(all_atc, collapse = " ")
  }), .SDcols = c(primary_col, inclusion_col, secondary_cols)]
}

#' Match ATC and ATC2 codes between active medication requests and MRP definitions
#'
#' This function compares ATC codes from a list of active medication requests with MRP rule definitions
#' in \code{mrp_table_list_by_atc}. It checks whether any defined interactions (via the \code{ATC2_FOR_CALCULATION}
#' field) also occur in the active medications. For each matched ATC–ATC2 pair, it returns a descriptive
#' entry indicating a potential contraindication.
#'
#' @param active_atcs A \code{data.table} containing at least the column \code{atc_code},
#'        which lists ATC codes of currently active medication requests.
#' @param mrp_table_list_by_atc A named list of \code{data.table}s, where each name corresponds to an
#'        ATC code, and each table contains MRP rule definitions, including a column \code{ATC2_FOR_CALCULATION}.
#'
#' @return A \code{data.table} with the columns:
#'   \describe{
#'     \item{\code{atc_code}}{The ATC code from the active request matching the MRP rule.}
#'     \item{\code{atc2_code}}{The interacting ATC2 code also found in the active requests.}
#'     \item{\code{proxy_code}}{Currently unused (placeholder).}
#'     \item{\code{proxy_type}}{Currently unused (placeholder).}
#'     \item{\code{kurzbeschr}}{A short textual description of the interaction.}
#'   }
matchATCCodePairs <- function(active_atcs, mrp_table_list_by_atc) {
  # Initialize empty result data.table
  result_mrps <- data.table::data.table(
    mrp_index = integer(),
    atc_code = character(),
    atc2_code = character(),
    proxy_code = character(),
    proxy_type = character(),
    kurzbeschr_drug = character(),
    kurzbeschr_item2 = character(),
    kurzbeschr_suffix = character()
  )
  active_atcs_unique <- unique(active_atcs)
  active_atcs <- unique(active_atcs_unique$atc_code)

  # Only use ATCs that are in the MRP table list
  used_keys <- intersect(names(mrp_table_list_by_atc), active_atcs)
  active_atcs_primary <- active_atcs_unique[atc_code %in% used_keys]

  for (i in seq_len(nrow(active_atcs_primary))) {
    atc <- active_atcs_primary$atc_code[i]
    start_datetime <- active_atcs_primary$start_datetime[i]
    end_datetime <- active_atcs_primary$end_datetime[i]

    mrp_rows <- mrp_table_list_by_atc[[atc]]
    # Filter rows where the secondary ATC is also active
    mrp_filtered <- mrp_rows[ATC2_FOR_CALCULATION %in% active_atcs]

    for (j in seq_len(nrow(mrp_filtered))) {
      matched_row <- mrp_filtered[j]
      atc2 <- matched_row$ATC2_FOR_CALCULATION

      active_atc2_rows <- active_atcs_unique[atc_code == atc2]
      data.table::setorder(active_atc2_rows, start_datetime)

      for (k in seq_len(nrow(active_atc2_rows))) {
        atc2_start_datetime <- active_atc2_rows$start_datetime[k]
        atc2_end_datetime <- active_atc2_rows$end_datetime[k]

        # Check for overlapping time periods
        if (start_datetime <= atc2_end_datetime && atc2_start_datetime <= end_datetime) {
          # Check, if the pair (A,B) and (B,A) exists
          result_mrps <- result_mrps[, index := .I]
          duplicate_idx <- result_mrps[(atc_code == atc & atc2_code == atc2) | (atc_code == atc2 & atc2_code == atc)]$index

          # There is no existing mrp in the result table with the same atc codes
          if (!length(duplicate_idx)) {

            mrp_index <- if (nrow(result_mrps) == 0) {
              1
            } else {
              max(result_mrps$mrp_index, na.rm = TRUE) + 1
            }

            mrp_row <- data.table::data.table(
              mrp_index = mrp_index, # All rows for the same mrp have the same index. Its only used for grouping.
              atc_code = atc,
              atc2_code = atc2,
              proxy_code = atc2, # we use the original non proxy code here as "proxy" to get this value in the dp_mrp_calculations table in the proxy_code column
              proxy_type = "ATC", # same like with proxy code (even if this is not a proxy)
              kurzbeschr_drug = paste0(matched_row$ATC_DISPLAY, " - ", atc, "   (", format(start_datetime, "%Y-%m-%d %H:%M:%S"), ")"),
              kurzbeschr_item2 = paste0(matched_row$ATC2_DISPLAY, " - ", atc2, "   (", format(atc2_start_datetime, "%Y-%m-%d %H:%M:%S"), ")"),
              kurzbeschr_suffix = paste("kontraindiziert.")
            )
            result_mrps <- rbind(result_mrps, mrp_row, fill = TRUE)
          } else {
            existing_kurzbeschr <- paste0(result_mrps[duplicate_idx, kurzbeschr_drug], result_mrps[duplicate_idx, kurzbeschr_item2], result_mrps[duplicate_idx, kurzbeschr_suffix])
            # If duplicate exists, append the new information to kurzbeschr
            if (!grepl(matched_row$ATC2_DISPLAY, existing_kurzbeschr, fixed = TRUE)) {
              result_mrps[duplicate_idx, kurzbeschr_item2 := paste0(matched_row$ATC2_DISPLAY, " und ", kurzbeschr_item2)]
            } else if (!grepl(matched_row$ATC_DISPLAY, existing_kurzbeschr, fixed = TRUE)) {
              result_mrps[duplicate_idx, kurzbeschr_item2 := paste0(matched_row$ATC_DISPLAY, " und ", kurzbeschr_item2)]
            }
          }
        }
        break
      }
    }
  }
  if ("index" %in% colnames(result_mrps)) {
    result_mrps[, index := NULL]
  }

  return(result_mrps)
}

#' Calculate Medication-Related Problems (MRPs) for All Types
#'
#' This function analyzes potential medication-related problems (MRPs) across a set of patient
#' encounters. It evaluates predefined MRP rules for contraindications between active medications
#' and known patient diagnoses or co-medications. The function supports multiple MRP types
#' (e.g., Drug-Disease, Drug-Drug) and consolidates results into unified output tables.
#'
#' For each MRP type and each encounter, the function:
#' \itemize{
#'   \item Gathers all active medications and patient conditions.
#'   \item Matches medication ATC codes against MRP definitions.
#'   \item Attempts to find matching ICD codes directly from patient conditions.
#'   \item If no direct ICD matches are found, evaluates proxy rules (using ATC or OPS codes).
#'   \item Compiles results into descriptive and audit tables.
#' }
#'
#' @param start_date Optional. Start of the date range as character or Date (e.g., "2025-10-01").
#'   Only encounters starting on or after this date are included. Time is set to 00:00:00.
#' @param end_date Optional. End of the date range as character or Date (e.g., "2025-10-31").
#'   Only encounters ending on or before this date are included. Time is set to 23:59:59 if
#'   provided, or to current system time if omitted.
#' @param return_used_resources A vector of all table names of the used resource tables which should+
#'   be returned in addition to the calculated tables. Default is NULL.
#'
#' @return A named list with two `data.table` objects:
#'
#' \describe{
#'   \item{retrolektive_mrpbewertung_fe}{Combined MRP evaluations across all types, ready for
#'   reporting or REDCap import.}
#'   \item{dp_mrp_calculations}{Combined audit log of all MRP evaluation steps, including proxy
#'   type and code used.}
#' }
#'
#' @details
#' - The function uses `getResourcesForMRPCalculation()` to load relevant FHIR resources.
#' - ATC codes are matched using `matchATCCodes()`, ICDs using `matchICDCodes()`.
#' - If no ICD match is found, `matchICDProxies()` evaluates proxy rules (ATC/OPS).
#' - Each match results in one entry in both output tables.
#' - If no match is found for an encounter, a placeholder entry is created in
#'   `dp_mrp_calculations`.
#' - The function merges all MRP types into two unified output tables.
#'
#' @examples
#' \dontrun{
#' # Run for all encounters with missing retrospective MRP evaluation
#' calculateMRPs()
#'
#' # Run for encounters from the past 60 days
#' calculateMRPs(Sys.Date() - 60)
#'
#' # Run for specific date range
#' calculateMRPs("2025-10-01", "2025-10-31")
#' }
#'
#' @export
calculateMRPs <- function(start_date = NULL, end_date = NULL, return_used_resources = NULL) {

  # Get all Einrichtungskontakt encounters that ended at least 14 days ago
  # and do not have a retrolective MRP evaluation for Drug_Disease

  main_encounters_by_mrp_type <- if (!is.null(start_date)) {
    start_time <- as.POSIXct(start_date, tz = GLOBAL_TIMEZONE)
    end_time <- if (is.null(end_date)) {
      etlutils::as.POSIXctWithTimezone(Sys.time())
    } else {
      # returns 23:59 h of the day with the end_date
      etlutils::as.POSIXctWithTimezone(end_date) + lubridate::days(1) - lubridate::seconds(1)
    }
    getEncountersWithTimeRangeFromDB(start_time, end_time)
  } else {
    getEncountersWithoutRetrolectiveMRPEvaluationFromDB()
  }

  main_encounters <- main_encounters_by_mrp_type[["ALL_MRP_TYPES"]]

  mrp_table_lists_all <- list()

  resources <- getResourcesForMRPCalculation(main_encounters)

  if (length(resources)) {
    mrp_pair_lists <- getMRPPairLists()

    all_encounters <- etlutils::fhirdataGetAllEncounters(encounter_ids = unique(main_encounters$enc_id),
                                                         lock_id_extension = "CalculateMRPs()_")

    for (mrp_type in names(mrp_pair_lists)) {

      etlutils::runLevel3(paste0("Calculate ", mrp_type, " MRPs"), {

        mrp_pair_list <- mrp_pair_lists[[mrp_type]]
        mrp_pair_list_processed_content_hash <- mrp_pair_list$processed_content_hash
        mrp_pair_list <- mrp_pair_list$processed_content

        # Initialize empty lists for results
        retrolektive_mrpbewertung_rows <- list()
        dp_mrp_calculations_rows <- list()

        mrp_type_main_encounters <- main_encounters_by_mrp_type[[mrp_type]]

        for (encounter_id in mrp_type_main_encounters$enc_id) {
          # Get encounter data and patient ID
          encounter <- resources$main_encounters[enc_id == encounter_id]
          patient_id <- etlutils::fhirdataExtractIDs(encounter$enc_patient_ref)

          # Skip invalid encounters without patient reference
          if (!etlutils::isSimpleNotEmptyString(patient_id)) {
            etlutils::catWarningMessage(paste0("Missing patient reference in FHIR data for Encounter with ID ", encounter$enc_id))
            next
          }

          encounter_ref <- unique(etlutils::fhirdataGetEncounterReference(encounter$enc_id))
          # The calculated_ref column always reference to the main encounter
          medication_requests <- resources$medication_requests[medreq_encounter_calculated_ref %in% encounter_ref]

          meda <- resources$encounters_first_medication_analysis[[encounter_id]]
          meda_id <- if (!is.null(meda)) meda$meda_id else NA_character_
          meda_datetime <- if (!is.null(meda)) meda$meda_dat else NA
          meda_study_phase <- encounter$study_phase
          record_id <- as.integer(resources$record_ids[pat_id == patient_id, record_id])
          # results in "1234-TEST-r" or "1234-r" with the meda_id = "1234"
          ret_id_prefix <- paste0(ifelse(meda_study_phase == "PhaseBTest", paste0(meda_id, "-TEST"), meda_id), "-r")
          ret_status <- ifelse(meda_study_phase == "PhaseBTest", "Unverified", NA_character_)
          kurzbeschr_prefix <- ifelse(meda_study_phase == "PhaseBTest", "*TEST* MRP FÜR FALL AUS PHASE A MIT TEST FÜR PHASE B *TEST*\n\n", "")

          ward_names <- resources$encounters_ward_names[main_enc_id == encounter_id]
          ward_names <- if (nrow(ward_names)) paste0(ward_names$ward_name, collapse = "\n") else NA_character_

          # Get active MedicationRequests for the encounter
          active_atcs <- getActiveATCs(medication_requests, encounter$enc_period_start, encounter$enc_period_end, meda_datetime)
          match_atc_and_item2_codes <- data.table::data.table()

          if (nrow(active_atcs) && meda_study_phase != "PhaseA") {
            fun <- getFunctionByName("calculateMRPs", mrp_type)
            args <- list(
              active_atcs = active_atcs,
              mrp_pair_list = mrp_pair_list,
              resources = resources,
              patient_id = patient_id,
              meda_datetime = meda_datetime
            )
            match_atc_and_item2_codes <- do.call(fun, args)
          }

          if (nrow(match_atc_and_item2_codes)) {
            # Iterate over matched results and create new rows for retrolektive_mrpbewertung and dp_mrp_calculations
            for (current_mrp_index in unique(match_atc_and_item2_codes$mrp_index)) {
              # Subset all rows belonging to the same MRP index
              match <- match_atc_and_item2_codes[mrp_index == current_mrp_index]
              if ("kurzbeschr_additional" %in% names(match) && all(is.na(match$kurzbeschr_additional))) {
                match[, kurzbeschr_additional := NULL]
              }

              collapsed_match <- match[
                ,
                {
                  result <- lapply(.SD, function(x) {
                    vals <- unique(na.omit(trimws(x)))
                    if (length(vals) == 0) return(NA_character_)
                    paste(vals, collapse = " \n")
                  })
                  if ("kurzbeschr_drug" %in% names(.SD)) {
                    vals <- unique(na.omit(trimws(.SD$kurzbeschr_drug)))
                    result$kurzbeschr_drug <- paste0(vals, collapse = "\n")
                  }
                  if ("kurzbeschr_item2" %in% names(.SD)) {
                    if ("kurzbeschr_type" %in% names(.SD)) {
                      types <- unique(na.omit(.SD$kurzbeschr_type))
                      # Define formatting for each type, including first and follow indentations
                      # Change this to adjust formatting in REDCap field "kurzbeschr" in "retrolektive_mrpbewertung_fe"
                      type_formats <- list(
                        "Diagnose"   = list(first = 1, follow = 19),
                        "Medikament" = list(first = 1, follow = 25),
                        "Prozedur"   = list(first = 1, follow = 19),
                        "Laborwert"  = list(first = 1, follow = 20)
                      )
                      pad_type <- function(type) {
                        type_format <- type_formats[[type]]
                        paste0(type, ":", strrep(" ", type_format$first))
                      }
                      type_blocks <- sapply(types, function(type) {
                        items <- unique(trimws(.SD[kurzbeschr_type == type, kurzbeschr_item2]))
                        type_format  <- type_formats[[type]]
                        prefix <- pad_type(type)
                        first_line <- paste0(prefix, items[1])
                        if (length(items) > 1) {
                          follow_indent <- strrep(" ", type_format$follow)
                          follow <- paste0(follow_indent, items[-1], collapse = "\n")
                          paste(first_line, follow, sep = "\n")
                        } else {
                          first_line
                        }
                      })
                      result$kurzbeschr_item2 <- paste(type_blocks, collapse = "\n")
                    } else {
                      items <- unique(na.omit(trimws(.SD$kurzbeschr_item2)))
                      result$kurzbeschr_item2 <- paste(items, collapse = "\n")
                    }
                  }
                  result
                },
                by = mrp_index
              ]

              kurzbeschr_cols <- setdiff(
                grep("^kurzbeschr_", names(collapsed_match), value = TRUE),
                "kurzbeschr_type"
              )

              if (mrp_type == "Drug_Disease" || mrp_type == "Drug_Niereninsuffizienz") {
                collapsed_match[, kurzbeschr := {
                  base <- paste0(
                    kurzbeschr_drug, " ist mit\n ",
                    kurzbeschr_suffix, "\n",
                    kurzbeschr_item2
                  )
                  if ("kurzbeschr_additional" %in% names(collapsed_match) &&
                      any(!is.na(kurzbeschr_additional))) {
                    base <- paste(base, paste(kurzbeschr_additional, collapse = "\n"), sep = " ")
                  }
                  base
                }]
              } else {
                collapsed_match[, kurzbeschr := paste0(
                  kurzbeschr_drug, " ist mit\n ",
                  kurzbeschr_item2, "\n",
                  kurzbeschr_suffix
                )]
              }

              meda_id_value <- meda_id # we need this renaming for the following comparison
              existing_ret_ids <- resources$existing_retrolective_mrp_evaluation_ids[meda_id == meda_id_value, ret_id]
              existing_redcap_repeat_instances <- resources$existing_retrolective_mrp_evaluation_ids[meda_id == meda_id_value, ret_redcap_repeat_instance]
              next_index <- if (length(existing_ret_ids) == 0) 1 else max(as.integer(sub(ret_id_prefix, "", existing_ret_ids)), na.rm = TRUE) + 1

              ids <- as.integer(sub(ret_id_prefix, "", existing_ret_ids))
              next_index <- if (length(existing_ret_ids) == 0) {
                1
              } else {
                max_val <- suppressWarnings(max(ids, na.rm = TRUE))
                # INF or -INF values are not finite. This case should never happen.
                if (is.finite(max_val)) max_val + 1 else 1
              }

              ret_id <- paste0(ret_id_prefix, next_index)
              ret_redcap_repeat_instance <- if (length(existing_redcap_repeat_instances) == 0) 1 else max(as.integer(existing_redcap_repeat_instances), na.rm = TRUE) + 1
              # Always updating the references to the existing ret_ids
              resources$existing_retrolective_mrp_evaluation_ids <- etlutils::addTableRow(resources$existing_retrolective_mrp_evaluation_ids, meda_id, ret_id, ret_redcap_repeat_instance)

              # Create new row for table retrolektive_mrpbewertung
              retrolektive_mrpbewertung_rows[[length(retrolektive_mrpbewertung_rows) + 1]] <- list(
                record_id = record_id,
                ret_id = ret_id,
                ret_meda_id = meda_id,
                ret_meda_dat_referenz = meda_datetime,
                ret_kurzbeschr = paste0(kurzbeschr_prefix, collapsed_match$kurzbeschr),
                ret_atc1 = match$atc_code[1], # take the first ATC code from the match
                ret_ip_klasse_01 = getCategoryDisplay(mrp_type),
                ret_ip_klasse_disease = ifelse(all(is.na(match$icd_code)), NA_character_, na.omit(match$icd_code)[1]), # take the first non-NA ICD code if available
                ret_atc2 = if (is.null(match$atc2_code)) NA_character_ else match$atc2_code,
                retrolektive_mrpbewertung_complete = ret_status,
                redcap_repeat_instrument = "retrolektive_mrpbewertung",
                redcap_repeat_instance = ret_redcap_repeat_instance
              )

              # Iterate over all rows in 'match' and add one entry per row to dp_mrp_calculations_rows
              for (i in seq_len(nrow(match))) {
                # Current match row
                match_row <- match[i]
                # Create new row for table dp_mrp_calculations
                dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
                  enc_id = encounter_id,
                  mrp_calculation_type = mrp_type,
                  meda_id = meda_id,
                  study_phase = meda_study_phase,
                  ward_name = ward_names, # ward_names, # we have changed the meaning from a single ward to all relevant wards, because we can't decide, which ward is the "correct" one
                  ret_id = ret_id,
                  ret_redcap_repeat_instance = ret_redcap_repeat_instance,
                  mrp_proxy_type = match_row$proxy_type,
                  mrp_proxy_code = match_row$proxy_code,
                  input_file_processed_content_hash = mrp_pair_list_processed_content_hash
                )
              }
            }
          } else {
            # No matches found for this encounter
            dp_mrp_calculations_rows[[length(dp_mrp_calculations_rows) + 1]] <- list(
              enc_id = encounter_id,
              mrp_calculation_type = mrp_type,
              meda_id = meda_id,
              study_phase = meda_study_phase,
              ward_name = NA_character_,
              ret_id = NA_character_,
              ret_redcap_repeat_instance = NA_character_,
              mrp_proxy_type = NA_character_,
              mrp_proxy_code = NA_character_,
              input_file_processed_content_hash = mrp_pair_list_processed_content_hash
            )
          }
        }
        # Combine all collected rows into data.tables
        retrolektive_mrpbewertung <- if (length(retrolektive_mrpbewertung_rows)) {
          unique(data.table::rbindlist(retrolektive_mrpbewertung_rows, use.names = TRUE, fill = TRUE))
        } else {
          data.table::data.table(
            record_id = character(),
            ret_id = character(),
            ret_meda_id = character(),
            ret_meda_dat_referenz = as.POSIXct(character()),
            ret_kurzbeschr = character(),
            ret_atc1 = character(),
            ret_ip_klasse_01 = character(),
            ret_ip_klasse_disease = character(),
            ret_atc2 = character(),
            retrolektive_mrpbewertung_complete = character(),
            redcap_repeat_instrument = character(),
            redcap_repeat_instance = character()
          )
        }
        dp_mrp_calculations <- data.table::rbindlist(dp_mrp_calculations_rows, use.names = TRUE, fill = TRUE)

        mrp_table_lists_all[[mrp_type]] <- list(
          retrolektive_mrpbewertung_fe = retrolektive_mrpbewertung,
          dp_mrp_calculations = dp_mrp_calculations
        )
      })
    }
  }
  # Merge all MRP tables into a single list for output
  mrp_table_lists_all_merged <- list(
    retrolektive_mrpbewertung_fe = data.table::rbindlist(
      lapply(mrp_table_lists_all, `[[`, "retrolektive_mrpbewertung_fe"),
      use.names = TRUE, fill = TRUE
    ),
    dp_mrp_calculations = data.table::rbindlist(
      lapply(mrp_table_lists_all, `[[`, "dp_mrp_calculations"),
      use.names = TRUE, fill = TRUE
    )
  )
  # Write the merged tables to RData files
  lapply(names(mrp_table_lists_all_merged), function(name) {
    writeRData(
      object = mrp_table_lists_all_merged[[name]],
      filename_without_extension = paste0("dataprocessor_", name)
    )
  })

  if (!is.null(return_used_resources)) {
    for (table_name in return_used_resources) {
      mrp_table_lists_all_merged[[table_name]] <- resources[[table_name]]
    }
  }
  return(mrp_table_lists_all_merged)
}
