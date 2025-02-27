#browser()

if (exists("DEBUG_DAY")) {

  if (DEBUG_DAY == 1) {
    # clear database on Day 1
    #etlutils::dbReset()
  }

  #resource_tables <- retainRAWTables("Patient", "Encounter")
  resource_tables <- getFilteredRAWResources("UKB-0001")
  # short reference to Encounter table
  dt_enc <- resource_tables[["Encounter"]]
  # Identify columns starting with "enc_diagnosis_"
  enc_diagnosis_cols <- grep("^enc_diagnosis_", names(dt_enc), value = TRUE)
  # Identify columns starting with "enc_diagnosis_"
  enc_servicetype_cols <- grep("^enc_servicetype_", names(dt_enc), value = TRUE)
  # Set first value before " ~ " and remove the rest
  dt_enc[, (enc_diagnosis_cols) := lapply(.SD, function(x) sub(" ~ .*", "", x)), .SDcols = enc_diagnosis_cols]

  #browser()

  if (DEBUG_DAY == 1) {
    # Set all encounter to "in-progress" and delete end date
    dt_enc[, enc_status := "in-progress"]
    dt_enc[, enc_period_end := NA]
    dt_enc[, (enc_diagnosis_cols) := NA]

    enc_start <- getFormattedRAWDateTime()
    dt_enc[, enc_period_start := enc_start]



  } else if (DEBUG_DAY == 2) {

    # Patient 2: unverändert zu Tag 1
    dt_enc[pats_enc$p2, enc_status := "in-progress"]
    dt_enc[pats_enc$p2, enc_period_end := NA]
    dt_enc[pats_enc$p2, (enc_diagnosis_cols) := NA]

    # Patient 3: Fall weiter in progress, vorhandene Diagnose wird nicht gelöscht
    dt_enc[pats_enc$p3, enc_status := "in-progress"]
    dt_enc[pats_enc$p3, enc_period_end := NA]

    # Patient 4: Fall beendet, Diagnose ist nun vorhanden
    # entspricht Originaldaten, daher hier keine Änderung

    # Patient 6: Fall beendet, keine Diagnose
    dt_enc[pats_enc$p6, (enc_diagnosis_cols) := NA]

    # # Patient 10: neuer Fall ohne Diagnose
    # dt_enc[pats_enc$p10, enc_status := "in-progress"]
    # dt_enc[pats_enc$p10, enc_period_end := NA]
    # dt_enc[pats_enc$p10, (enc_diagnosis_cols) := NA]

  } else if (DEBUG_DAY == 3) {

  } else if (DEBUG_DAY == 4) {

  }
  # only to create a statment in Debug cases
  dt_enc <- dt_enc
}
