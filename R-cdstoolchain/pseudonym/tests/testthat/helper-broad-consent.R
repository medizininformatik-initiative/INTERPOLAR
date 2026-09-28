consentProvisionFixture <- function(
  code, type = "permit", start = "2020-01-01", end = "2025-12-31",
  consent_id = "a", declared_at = "2020-01-01 12:00:00", status = "active"
) {
  data.table::data.table(
    consent_id = consent_id, declared_at = as.POSIXct(declared_at, tz = "UTC"),
    status = status, system = BROAD_CONSENT_CODE_SYSTEM,
    code = paste0(BROAD_CONSENT_CODE_PREFIX, code), type = type,
    start = as.Date(start), end = as.Date(end)
  )
}

consentDocumentFixture <- function(consent_id = "a", declared_at = "2020-01-01 12:00:00") {
  data.table::rbindlist(list(
    consentProvisionFixture("6", consent_id = consent_id, declared_at = declared_at),
    consentProvisionFixture("8", end = "2050-01-01", consent_id = consent_id, declared_at = declared_at)
  ))
}

broadConsentSnapshotFixtureTables <- function() {
  timestamp <- function(x) as.POSIXct(x, tz = "UTC")
  tables <- list(
    patient = data.frame(patient_id = 1:2, pat_id = c("p1", "p2"), pat_meta_versionid = "1"),
    encounter = data.frame(
      encounter_id = 1:3, enc_id = c("main", "ward", "other"), enc_meta_versionid = "1",
      enc_patient_ref = c("Patient/p1", "Patient/p1", "Patient/p2"),
      enc_period_start = timestamp(c("2026-03-01", "2026-03-05", "2026-03-01")),
      enc_period_end = timestamp(c("2026-03-20", "2026-03-10", "2026-03-10")),
      enc_partof_ref = c(NA, "Encounter/main", NA),
      enc_partof_calculated_ref = c(NA, "Encounter/main", NA),
      enc_main_encounter_calculated_ref = c("Encounter/main", "Encounter/main", "Encounter/other")
    ),
    observation = data.frame(
      observation_id = 1:6, obs_id = c("good", "late", "empty", "dangling", "versioned", "versioned"),
      obs_meta_versionid = c("1", "1", "1", "1", "1", "2"), obs_patient_ref = "Patient/p1",
      obs_effectivedatetime = timestamp(c("2026-03-08", "2026-03-18", "2026-03-08", "2026-03-08", "2026-03-18", "2026-03-08")),
      obs_encounter_ref = c("Encounter/main", "Encounter/main", NA, "Encounter/absent", "Encounter/main", "Encounter/ward"),
      obs_encounter_calculated_ref = c("Encounter/main", "Encounter/main", "Encounter/main", "invalid", "Encounter/main", "Encounter/main")
    ),
    patient_fe = data.frame(patient_fe_id = 1:2, record_id = c("r1", "r2"), pat_id = c("p1", "p2")),
    fall_fe = data.frame(fall_fe_id = 1:2, record_id = c("r1", "r2"), fall_pat_id = c("p1", "p2"), fall_fhir_enc_id = c("main", "other")),
    dp_mrp_calculations = data.frame(dp_mrp_calculations_id = 1:2, enc_id = c("main", "other")),
    pids_per_ward = data.frame(pids_per_ward_id = 1:2, patient_id = c("p1", "p2"), encounter_id = c("main", "other")),
    medicationrequest = data.frame(
      medicationrequest_id = 1:2, medreq_id = c("req1", "req2"), medreq_meta_versionid = "1",
      medreq_patient_ref = c("Patient/p1", "Patient/p2"), medreq_authoredon = timestamp(rep("2026-03-08", 2)),
      medreq_medicationreference_ref = c("Medication/m1/_history/1", "Medication/m2")
    ),
    medication = data.frame(
      medication_id = 1:3, med_id = c("m1", "m2", "ingredient"), med_meta_versionid = "1",
      med_ingredient_itemreference_ref = c("Medication/ingredient", NA, "Medication/m1")
    ),
    location = data.frame(location_id = 1L, loc_id = "loc", loc_meta_versionid = "1")
  )
  provisions <- data.table::rbindlist(list(
    consentProvisionFixture("6", start = "2026-03-01", end = "2026-03-15", declared_at = "2026-03-01 00:00:00"),
    consentProvisionFixture("8", start = "2026-03-01", end = "2050-01-01", declared_at = "2026-03-01 00:00:00")
  ))
  consents <- as.data.frame(provisions)
  names(consents) <- c(
    "cons_id", "cons_datetime", "cons_status", "cons_provision_provision_code_system",
    "cons_provision_provision_code_code", "cons_provision_provision_type", "cons_provision_provision_period_start", "cons_provision_provision_period_end"
  )
  consents$cons_provision_provision_period_start <- timestamp(consents$cons_provision_provision_period_start)
  consents$cons_provision_provision_period_end <- timestamp(consents$cons_provision_provision_period_end)
  consents$consent_id <- 1:2
  consents$cons_patient_ref <- "Patient/p1"
  consents$cons_meta_versionid <- "1"
  tables$consent <- consents
  tables
}

writeBroadConsentSnapshotFixture <- function(source, source_schema) {
  tables <- broadConsentSnapshotFixtureTables()
  for (base in names(tables)) {
    DBI::dbWriteTable(source, DBI::Id(schema = source_schema, table = base), tables[[base]])
    for (suffix in c("", SNAPSHOT_LAST_VERSION_SUFFIX)) {
      predicate <- if (base == "observation" && nzchar(suffix)) " WHERE observation_id <> 5" else ""
      DBI::dbExecute(source, paste0(
        "CREATE VIEW ", snapshotQualifiedName(source, paste0("v_", base, suffix), source_schema),
        " AS SELECT * FROM ", snapshotQualifiedName(source, base, source_schema), predicate
      ))
    }
  }
  DBI::dbWriteTable(
    source, DBI::Id(schema = source_schema, table = "v_db_parameter"),
    data.frame(parameter_name = c("release_version", "database_content_type"), parameter_value = c("2.1.0", "pseudonymized_snapshot"))
  )
  tables
}
