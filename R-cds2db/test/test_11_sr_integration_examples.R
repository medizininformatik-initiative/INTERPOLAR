# ============================================================================
# STATISTICAL REPORTS: TEST DATA INTEGRATION EXAMPLES
# ============================================================================
# This file shows how to integrate the generic helper functions from
# test_common_data_preparation_sr_helpers.R into the existing test_11 workflow.
#
# KEY PRINCIPLE:
# - Generic helpers (test_common_data_preparation_sr_helpers.R) contain NO hardcoded IDs
# - Test-specific logic (THIS FILE) contains ALL hardcoded SR test patient IDs
# - By calling generic helpers with specific IDs, we keep test infrastructure clean
#
# ============================================================================

# ============================================================================
# PART 1: FHIR-LEVEL TEST SCENARIOS (to be added to test_11_change_RAW_Data.R)
# ============================================================================

# Add this section AFTER line 189 of test_11_change_RAW_Data.R
# Conditionally enable Statistical Reports test scenarios

if (exists("TOOLCHAIN_DAY")) {
  # ========================================================================
  # STATISTICAL REPORTS: FHIR TEST SCENARIOS
  # Uncomment to enable SR scenario testing
  # ========================================================================

  # Uncomment line below to enable SR scenarios (or set externally)
  # ENABLE_SR_FHIR_SCENARIOS <- TRUE

  if (exists("ENABLE_SR_FHIR_SCENARIOS") && isTRUE(ENABLE_SR_FHIR_SCENARIOS)) {
    # Source the generic helpers (already sourced at top, but shown for clarity)
    # source("./R-cds2db/test/test_common_data_preparation_sr_helpers.R", local = TRUE)

    # ====================================================================
    # DEFINE SR TEST PATIENT IDS (hardcoded here, not in generic functions)
    # ====================================================================

    # FHIR Patient-Level Test IDs
    SR_PAT_01 <- "[1]SR_PAT_01"  # All identifier fields mismatch
    SR_PAT_02 <- "[1]SR_PAT_02"  # Only system mismatch
    SR_PAT_03 <- "[1]SR_PAT_03"  # Only type_system mismatch
    SR_PAT_04 <- "[1]SR_PAT_04"  # Only type_code mismatch
    SR_PAT_05 <- "[1]SR_PAT_05"  # Multiple pat_ids for one identifier
    SR_PAT_06 <- "[1]SR_PAT_06"  # Underage patient

    # FE Patient-Level Test IDs
    SR_PAT_FE_06 <- "[1]SR_PAT_FE_06"  # Underage in FE (pat_gebdat = 2020-01-01)
    SR_PAT_FE_07 <- "[1]SR_PAT_FE_07"  # Missing birthdate (pat_gebdat = NA)
    SR_PAT_FE_08 <- "[1]SR_PAT_FE_08"  # Double birthdate edge case

    # FHIR Encounter-Level Test IDs
    SR_ENC_01 <- "[1]SR_ENC_01"  # Encounter identifier system mismatch
    SR_ENC_02 <- "[1]SR_ENC_02"  # Historic encounter (>1 year before report start)
    SR_ENC_03 <- "[1]SR_ENC_03"  # Unknown enc_type_code ("test")
    SR_ENC_04 <- "[1]SR_ENC_04"  # Unknown enc_type_system ("test")
    SR_ENC_05 <- "[1]SR_ENC_05"  # Missing enc_period_start
    SR_ENC_06 <- "[1]SR_ENC_06"  # Missing enc_type_code_Kontaktebene (IMP)
    SR_ENC_07 <- "[1]SR_ENC_07"  # Unexpected status ("test_status")
    SR_ENC_08 <- "[1]SR_ENC_08"  # Finished IMP without end date
    SR_ENC_09 <- "[1]SR_ENC_09"  # Unexpected class ("TEST")
    SR_ENC_10 <- "[1]SR_ENC_10"  # Multiple enc_identifier_values for same enc_id
    SR_ENC_11 <- "[1]SR_ENC_11"  # Multiple enc_ids for same identifier value
    SR_ENC_12 <- "[1]SR_ENC_12"  # No main encounter ref + various type checks

    # FE Fall-Level Test IDs
    SR_FALL_01 <- "[1]SR_FALL_01"  # Ward change scenario

    # ====================================================================
    # FHIR PATIENT-LEVEL SCENARIOS
    # ====================================================================

    if (TOOLCHAIN_DAY == 1) {
      dt_pat <- testGetResourceTable("Patient")

      # SR_PAT_01: All 3 identifier fields mismatch
      dt_pat <- modifyPatientIdentifiers(
        dt_pat,
        pat_ids = SR_PAT_01,
        mismatch_fields = "all",
        suffix = "-mismatch"
      )

      # SR_PAT_02: Only system mismatch
      dt_pat <- modifyPatientIdentifiers(
        dt_pat,
        pat_ids = SR_PAT_02,
        mismatch_fields = "system"
      )

      # SR_PAT_03: Only type_system mismatch
      dt_pat <- modifyPatientIdentifiers(
        dt_pat,
        pat_ids = SR_PAT_03,
        mismatch_fields = "type_system"
      )

      # SR_PAT_04: Only type_code mismatch
      dt_pat <- modifyPatientIdentifiers(
        dt_pat,
        pat_ids = SR_PAT_04,
        mismatch_fields = "type_code"
      )

      # SR_PAT_06: Underage patient (birthdate = 2020-01-01)
      dt_pat <- modifyPatientBirthdate(
        dt_pat,
        pat_ids = SR_PAT_06,
        birthdate = as.Date("2020-01-01")
      )

      testSetResourceTable("Patient", dt_pat)

      # ====================================================================
      # FHIR ENCOUNTER-LEVEL SCENARIOS
      # ====================================================================

      dt_enc <- testGetResourceTable("Encounter")

      # SR_ENC_01: Encounter identifier system mismatch
      dt_enc <- modifyEncounterIdentifierSystem(
        dt_enc,
        enc_ids = SR_ENC_01,
        suffix = "-mismatch"
      )

      # SR_ENC_02: Historic encounter (>1 year before report start)
      dt_enc <- overrideEncounterPeriod(
        dt_enc,
        enc_ids = SR_ENC_02,
        new_start = as.POSIXct("2000-01-01 12:00:00"),
        new_end = as.POSIXct("2000-01-10 12:00:00")
      )

      # SR_ENC_07: Unexpected encounter status ("test_status")
      dt_enc <- overrideEncounterStatus(
        dt_enc,
        enc_ids = SR_ENC_07,
        new_status = "test_status"
      )

      # SR_ENC_08: Finished IMP without end date
      dt_enc <- overrideEncounterStatus(
        dt_enc,
        enc_ids = SR_ENC_08,
        new_status = "finished"
      )
      dt_enc <- overrideEncounterPeriod(
        dt_enc,
        enc_ids = SR_ENC_08,
        new_end = NA
      )

      # SR_ENC_09: Unexpected class code ("TEST")
      dt_enc <- overrideEncounterClassCode(
        dt_enc,
        enc_ids = SR_ENC_09,
        new_class_code = "[1]TEST"
      )

      # SR_ENC_12: No calculated main encounter reference
      dt_enc <- removeEncounterMainRef(
        dt_enc,
        enc_ids = SR_ENC_12
      )

      testSetResourceTable("Encounter", dt_enc)
    }
  }
}

# ============================================================================
# PART 2: FE-LEVEL TEST SCENARIOS (to be added to test_11_change_REDCap_Data.R)
# ============================================================================

# Add this section AFTER line 55 of test_11_change_REDCap_Data.R

# Uncomment to enable SR scenario testing for FE data
# ENABLE_SR_FE_SCENARIOS <- TRUE

if (exists("ENABLE_SR_FE_SCENARIOS") && isTRUE(ENABLE_SR_FE_SCENARIOS)) {
  if (isDebugDay(1)) {
    # ====================================================================
    # STATISTICAL REPORTS: FE PATIENT-LEVEL SCENARIOS
    # ====================================================================

    dt_patient_fe <- data_to_import[["patient_fe"]]

    # SR_PAT_FE_06: Underage in FE (pat_gebdat = 2020-01-01)
    dt_patient_fe <- modifyPatientBirthdate(
      dt_patient_fe,
      pat_ids = SR_PAT_FE_06,
      birthdate = as.Date("2020-01-01")
    )

    # SR_PAT_FE_07: Missing birthdate (pat_gebdat = NA)
    dt_patient_fe <- removePatientBirthdate(
      dt_patient_fe,
      pat_ids = SR_PAT_FE_07
    )

    # SR_PAT_FE_08: Double birthdate edge case (1980-01-01)
    dt_patient_fe <- modifyPatientBirthdate(
      dt_patient_fe,
      pat_ids = SR_PAT_FE_08,
      birthdate = as.Date("1980-01-01")
    )

    data_to_import[["patient_fe"]] <- dt_patient_fe

    # ====================================================================
    # STATISTICAL REPORTS: FE FALL-LEVEL SCENARIOS
    # ====================================================================

    if ("fall_fe" %in% names(data_to_import)) {
      dt_fall <- data_to_import[["fall_fe"]]

      # SR_FALL_01: Ward change scenario
      dt_fall <- modifyFallWard(
        dt_fall,
        fall_ids = SR_FALL_01,
        new_ward = "Test_Ward"
      )

      data_to_import[["fall_fe"]] <- dt_fall
    }

    # ====================================================================
    # STATISTICAL REPORTS: CONSENT SCENARIOS
    # ====================================================================

    if ("consent" %in% names(data_to_import)) {
      dt_consent <- data_to_import[["consent"]]

      # Add broad consent for SR test patient
      dt_consent <- addBroadConsentRecord(
        dt_consent,
        pat_id = "SR_PAT_01",
        consent_code = "2.16.840.1.113883.3.1937.777.24.5.3.8",  # MDAT wissenschaftlich nutzen
        period_start = as.POSIXct("2020-09-01"),
        period_end = as.POSIXct("2026-08-31")
      )

      data_to_import[["consent"]] <- dt_consent
    }
  }
}

# ============================================================================
# INTEGRATION CHECKLIST
# ============================================================================
# [ ] 1. Append test_common_data_preparation_sr_helpers.R content to
#        test_common_data_preparation.R (after line 1363)
#
# [ ] 2. Add FHIR scenarios section (PART 1 above) to test_11_change_RAW_Data.R
#        after line 189
#
# [ ] 3. Add FE scenarios section (PART 2 above) to test_11_change_REDCap_Data.R
#        after line 55
#
# [ ] 4. Enable scenarios by setting (in test runner or globally):
#        ENABLE_SR_FHIR_SCENARIOS <- TRUE
#        ENABLE_SR_FE_SCENARIOS <- TRUE
#
# [ ] 5. Verify scenarios load correctly:
#        source("./R-cds2db/test/test_11_change_RAW_Data.R", local = TRUE)
#        source("./R-cds2db/test/test_11_change_REDCap_Data.R", local = TRUE)
#
# ============================================================================

