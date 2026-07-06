# ============================================================================
# STATISTICAL REPORTS: GENERIC TEST DATA MANIPULATION FUNCTIONS
# ============================================================================
# These functions provide generic, reusable data manipulation capabilities
# for injecting test scenarios. NO HARDCODED TEST IDS.
#
# All functions accept resource tables and specific IDs/conditions as parameters.
# Test-specific logic (which IDs, which scenarios) lives in test_11_*.R files.
#
# To integrate: Append content of this file to test_common_data_preparation.R
# ============================================================================

#' Modify Patient Identifier System/Type/Code
#'
#' Injects identifier mismatches into patient data for testing filtering logic.
#' This generic function modifies ANY patient's identifier fields based on parameters.
#'
#' @param dt_pat Patient data.table (must contain pat_id, pat_identifier_system,
#'                pat_identifier_type_system, pat_identifier_type_code)
#' @param pat_ids Character vector of patient IDs to modify (e.g., c("SR_PAT_01", "SR_PAT_02"))
#' @param mismatch_fields Character: which fields to mismatch.
#'        - "all": mismatch all three (system, type_system, type_code)
#'        - "system": only pat_identifier_system
#'        - "type_system": only pat_identifier_type_system
#'        - "type_code": only pat_identifier_type_code
#'        - vector of multiple: c("system", "type_system")
#' @param suffix String to append to create mismatch (default: "-test")
#'
#' @return Modified patient table with identifier mismatches injected for specified IDs
#'
#' @details
#' Maps to createPatientDataWarningsSituations() from 00_help-functions.R
#' but generalized to accept any patient IDs.
#'
#' @examples
#' \dontrun{
#' dt_pat <- testGetResourceTable("Patient")
#' # All three fields mismatch for patient SR_PAT_01
#' dt_pat <- modifyPatientIdentifiers(dt_pat, pat_ids = "SR_PAT_01", mismatch_fields = "all")
#' # Only system field mismatch for patient SR_PAT_02
#' dt_pat <- modifyPatientIdentifiers(dt_pat, pat_ids = "SR_PAT_02", mismatch_fields = "system")
#' testSetResourceTable("Patient", dt_pat)
#' }
#'
modifyPatientIdentifiers <- function(dt_pat, pat_ids, mismatch_fields = "all", suffix = "-test") {
  # Normalize mismatch_fields to vector
  if (mismatch_fields == "all") {
    mismatch_fields <- c("system", "type_system", "type_code")
  }

  for (pat_id in pat_ids) {
    rows_to_modify <- which(dt_pat$pat_id == pat_id | dt_pat$pat_id == paste0("[1]", pat_id))

    if (length(rows_to_modify) > 0) {
      if ("system" %in% mismatch_fields) {
        dt_pat[rows_to_modify, pat_identifier_system := paste0(pat_identifier_system, suffix)]
      }
      if ("type_system" %in% mismatch_fields) {
        dt_pat[rows_to_modify, pat_identifier_type_system := paste0(pat_identifier_type_system, suffix)]
      }
      if ("type_code" %in% mismatch_fields) {
        dt_pat[rows_to_modify, pat_identifier_type_code := paste0(pat_identifier_type_code, suffix)]
      }
    }
  }

  return(dt_pat)
}

#' Set Patient as Underage
#'
#' Injects underage patient scenario by setting birthdate to a recent year.
#' Generic function that works with any patient IDs.
#'
#' @param dt_pat Patient data.table (FE or FHIR, must contain pat_id and pat_birthdate or pat_gebdat)
#' @param pat_ids Character vector of patient IDs to set as underage
#' @param birthdate Date to assign (default: 2020-01-01, makes patient ~4 years old)
#'
#' @return Modified patient table with updated birthdates for specified patients
#'
#' @details
#' Automatically detects column name: pat_birthdate (FHIR) or pat_gebdat (FE).
#' Maps to setPatientAsUnderage logic from debug functions.
#'
modifyPatientBirthdate <- function(dt_pat, pat_ids, birthdate = as.Date("2020-01-01")) {
  # Detect which column name to use
  colname <- if ("pat_birthdate" %in% names(dt_pat)) "pat_birthdate" else "pat_gebdat"

  for (pat_id in pat_ids) {
    rows_to_modify <- which(dt_pat$pat_id == pat_id | dt_pat$pat_id == paste0("[1]", pat_id))

    if (length(rows_to_modify) > 0) {
      dt_pat[rows_to_modify, (colname) := birthdate]
    }
  }

  return(dt_pat)
}

#' Remove Patient Birthdate
#'
#' Sets birthdate to NA for specified patients.
#' Generic function used for testing missing birthdate scenarios.
#'
#' @param dt_pat Patient data.table (FE or FHIR)
#' @param pat_ids Character vector of patient IDs
#'
#' @return Modified patient table with birthdates set to NA
#'
removePatientBirthdate <- function(dt_pat, pat_ids) {
  colname <- if ("pat_birthdate" %in% names(dt_pat)) "pat_birthdate" else "pat_gebdat"

  for (pat_id in pat_ids) {
    rows_to_modify <- which(dt_pat$pat_id == pat_id | dt_pat$pat_id == paste0("[1]", pat_id))

    if (length(rows_to_modify) > 0) {
      dt_pat[rows_to_modify, (colname) := NA]
    }
  }

  return(dt_pat)
}

#' Override Encounter Status
#'
#' Changes encounter status for specified encounter IDs.
#' Generic function that injects unexpected status scenarios.
#'
#' @param dt_enc Encounter data.table (must contain enc_id, enc_status)
#' @param enc_ids Character vector of encounter IDs to modify
#' @param new_status Character: new status value (e.g., "test_status", "unknown")
#'
#' @return Modified encounter table
#'
#' @details
#' Maps to CheckUnexpectedStatus logic from 00_help-functions.R.
#' Valid statuses are "finished", "in-progress", "onleave" - this function
#' can inject invalid values for testing.
#'
overrideEncounterStatus <- function(dt_enc, enc_ids, new_status) {
  for (enc_id in enc_ids) {
    rows_to_modify <- which(dt_enc$enc_id == enc_id)

    if (length(rows_to_modify) > 0) {
      dt_enc[rows_to_modify, enc_status := paste0("[1]", new_status)]
    }
  }

  return(dt_enc)
}

#' Override Encounter Period (Start/End Dates)
#'
#' Changes encounter start and/or end dates.
#' Generic function for testing date-related scenarios (historic data, missing dates, etc).
#'
#' @param dt_enc Encounter data.table (must contain enc_id, enc_period_start, enc_period_end)
#' @param enc_ids Character vector of encounter IDs to modify
#' @param new_start New start datetime (POSIXct, optional)
#' @param new_end New end datetime (POSIXct, optional)
#'
#' @return Modified encounter table
#'
#' @details
#' Maps to CheckMissingStartDate and historic data filtering logic.
#' If new_start is POSIXct("2000-01-01"), creates a historic encounter scenario.
#' If new_start is NA, creates missing start date scenario.
#'
overrideEncounterPeriod <- function(dt_enc, enc_ids, new_start = NULL, new_end = NULL) {
  for (enc_id in enc_ids) {
    rows_to_modify <- which(dt_enc$enc_id == enc_id)

    if (length(rows_to_modify) > 0) {
      if (!is.null(new_start)) {
        dt_enc[rows_to_modify, enc_period_start := new_start]
      }
      if (!is.null(new_end)) {
        dt_enc[rows_to_modify, enc_period_end := new_end]
      }
    }
  }

  return(dt_enc)
}

#' Override Encounter Type Codes (Kontaktebene, Kontaktart)
#'
#' Changes encounter type codes for testing missing/unexpected Kontaktebene scenarios.
#' Generic function that accepts any encounter IDs.
#'
#' @param dt_enc Encounter data.table
#' @param enc_ids Character vector of encounter IDs
#' @param new_kontaktebene New Kontaktebene value (optional, e.g., NA or "TEST")
#' @param new_kontaktart New Kontaktart value (optional)
#'
#' @return Modified encounter table
#'
#' @details
#' Maps to CheckMissingKontaktebeneForImpEncounter and CheckUnexpectedKontaktartCode.
#' Set new_kontaktebene = NA to create missing Kontaktebene for IMP encounters.
#' Set to "TEST" or other invalid value to create unexpected code scenario.
#'
overrideEncounterTypeCode <- function(dt_enc, enc_ids, new_kontaktebene = NULL, new_kontaktart = NULL) {
  for (enc_id in enc_ids) {
    rows_to_modify <- which(dt_enc$enc_id == enc_id)

    if (length(rows_to_modify) > 0) {
      if (!is.null(new_kontaktebene)) {
        dt_enc[rows_to_modify, enc_type_code_Kontaktebene := new_kontaktebene]
      }
      if (!is.null(new_kontaktart)) {
        dt_enc[rows_to_modify, enc_type_code_Kontaktart := new_kontaktart]
      }
    }
  }

  return(dt_enc)
}

#' Override Encounter Class Code
#'
#' Changes encounter class code for testing unexpected class code scenarios.
#' Generic function that works with any encounter IDs and class codes.
#'
#' @param dt_enc Encounter data.table
#' @param enc_ids Character vector of encounter IDs
#' @param new_class_code New class code value (e.g., "TEST", "AMB")
#'
#' @return Modified encounter table
#'
#' @details
#' Maps to CheckUnexpectedClassCode logic.
#' Valid codes are "AMB", "SS", "IMP". This function can inject "TEST" or other
#' invalid values for testing.
#'
overrideEncounterClassCode <- function(dt_enc, enc_ids, new_class_code) {
  for (enc_id in enc_ids) {
    rows_to_modify <- which(dt_enc$enc_id == enc_id)

    if (length(rows_to_modify) > 0) {
      dt_enc[rows_to_modify, enc_class_code := new_class_code]
    }
  }

  return(dt_enc)
}

#' Remove Encounter Main Encounter Reference
#'
#' Sets enc_main_encounter_calculated_ref to NA.
#' Generic function for testing scenarios where main encounter reference is missing.
#'
#' @param dt_enc Encounter data.table
#' @param enc_ids Character vector of encounter IDs
#'
#' @return Modified encounter table
#'
#' @details
#' Maps to CheckEncountersWithoutCalculatedMainEncounterRef.
#' This tests the data quality check that detects encounters without proper
#' main encounter references.
#'
removeEncounterMainRef <- function(dt_enc, enc_ids) {
  for (enc_id in enc_ids) {
    rows_to_modify <- which(dt_enc$enc_id == enc_id)

    if (length(rows_to_modify) > 0) {
      dt_enc[rows_to_modify, enc_main_encounter_calculated_ref := NA_character_]
    }
  }

  return(dt_enc)
}

#' Modify Encounter Identifier System
#'
#' Changes encounter identifier system for testing identifier mismatch scenarios.
#' Generic function matching patient identifier mismatch logic but for encounters.
#'
#' @param dt_enc Encounter data.table
#' @param enc_ids Character vector of encounter IDs
#' @param suffix String to append for mismatch (default: "-test")
#'
#' @return Modified encounter table
#'
modifyEncounterIdentifierSystem <- function(dt_enc, enc_ids, suffix = "-test") {
  for (enc_id in enc_ids) {
    rows_to_modify <- which(dt_enc$enc_id == enc_id)

    if (length(rows_to_modify) > 0) {
      dt_enc[rows_to_modify, enc_identifier_system := paste0(enc_identifier_system, suffix)]
    }
  }

  return(dt_enc)
}

#' Override Fall Ward Assignment
#'
#' Changes ward assignment in fall_fe table.
#' Generic function for testing ward change scenarios.
#'
#' @param dt_fall Fall FE data.table
#' @param fall_ids Character vector of fall/encounter IDs
#' @param new_ward New ward name (e.g., "Test")
#'
#' @return Modified fall table
#'
modifyFallWard <- function(dt_fall, fall_ids, new_ward = "Test") {
  for (fall_id in fall_ids) {
    rows_to_modify <- which(dt_fall$fall_fhir_main_enc_id == fall_id)

    if (length(rows_to_modify) > 0) {
      dt_fall[rows_to_modify, fall_station := new_ward]
    }
  }

  return(dt_fall)
}

#' Add Broad Consent Record
#'
#' Injects a broad consent record for a specific patient.
#' Generic function for testing consent linkage scenarios.
#'
#' @param dt_consent Consent data.table (or empty table with correct structure)
#' @param pat_id Patient ID to add consent for
#' @param consent_code Consent code (default: "2.16.840.1.113883.3.1937.777.24.5.3.8"
#'        for "MDAT wissenschaftlich nutzen")
#' @param period_start Consent period start (default: as.POSIXct("2020-09-01"))
#' @param period_end Consent period end (default: as.POSIXct("2026-08-31"))
#'
#' @return Modified consent table with new record appended
#'
addBroadConsentRecord <- function(dt_consent,
                                  pat_id,
                                  consent_code = "2.16.840.1.113883.3.1937.777.24.5.3.8",
                                  period_start = as.POSIXct("2020-09-01"),
                                  period_end = as.POSIXct("2026-08-31")) {
  # Ensure pat_id has FHIR reference format
  if (!startsWith(pat_id, "[")) {
    pat_ref <- paste0("[1.1]Patient/", pat_id)
  } else {
    pat_ref <- pat_id
  }

  new_consent <- data.table::data.table(
    cons_patient_ref = pat_ref,
    cons_status = "[1]active",
    cons_provision_provision_type = "[1]permit",
    cons_provision_provision_code_system = "[1.1]urn:oid:2.16.840.1.113883.3.1937.777.24.5.3",
    cons_provision_provision_code_code = paste0("[1.1]", consent_code),
    cons_provision_provision_period_start = period_start,
    cons_provision_provision_period_end = period_end
  )

  # Append to existing consent table
  dt_consent <- rbind(dt_consent, new_consent, fill = TRUE)

  return(dt_consent)
}

# ============================================================================
# INTEGRATION NOTES
# ============================================================================
# 1. Append this entire section to test_common_data_preparation.R after line 1363
#
# 2. Usage pattern in test_11_change_RAW_Data.R:
#
#    # Define SR test patient IDs
#    SR_PAT_01 <- "[1]SR_PAT_01"
#    SR_ENC_01 <- "[1]SR_ENC_01"
#
#    # Use generic helpers with hardcoded IDs
#    if (ENABLE_SR_SCENARIOS) {
#      dt_pat <- testGetResourceTable("Patient")
#      dt_pat <- modifyPatientIdentifiers(dt_pat, pat_ids = SR_PAT_01, mismatch_fields = "all")
#      testSetResourceTable("Patient", dt_pat)
#
#      dt_enc <- testGetResourceTable("Encounter")
#      dt_enc <- overrideEncounterStatus(dt_enc, enc_ids = SR_ENC_02, new_status = "test_status")
#      testSetResourceTable("Encounter", dt_enc)
#    }
#
# 3. Similar pattern applies to test_11_change_REDCap_Data.R for FE-level scenarios
#
# ============================================================================
