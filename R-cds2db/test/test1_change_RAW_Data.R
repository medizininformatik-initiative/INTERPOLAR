#browser()

if (exists("DEBUG_DAY")) {

  dt_enc <- data.table::copy(resource_tables[["Encounter"]])
  dt_pat <- data.table::copy(resource_tables[["Patient"]])
  dt_pid <- data.table::copy(resource_tables[["pids_per_ward"]])

  # Identify columns starting with "enc_diagnosis_"
  diag_cols <- grep("^enc_diagnosis_", names(dt_enc), value = TRUE)
  # Set first value before " ~ " and remove the rest
  dt_enc[, (diag_cols) := lapply(.SD, function(x) sub(" ~ .*", "", x)), .SDcols = diag_cols]

  pattern <- function(num) sprintf(".*UKB-%04d(-.*|$)", num)
  patRowsEnc <- function(num) {
    which(grepl(pattern(num), dt_enc$enc_id))
  }
  patRowsPat <- function(num) which(grepl(pattern(num), dt_pat$pat_id))
  patRowsPid <- function(num) which(grepl(pattern(num), dt_pid$patient_id))

  # IDs, die gesucht werden sollen
  pat_nums <- c(2, 3, 4, 6, 7, 10, 12, 13)

  # Automatische Erstellung aller pat-Variablen
  pats_enc <- lapply(pat_nums, patRowsEnc)
  names(pats_enc) <- paste0("p", pat_nums)

  pats_pat <- lapply(pat_nums, patRowsPat)
  names(pats_pat) <- paste0("p", pat_nums)

  pats_pid <- lapply(pat_nums, patRowsPid)
  names(pats_pid) <- paste0("p", pat_nums)

  # Fälle von 4 Patienten ohne Enddatum, in progress und ohne Diagnosen
  dt_enc <- dt_enc[c(pats_enc$p2, pats_enc$p3, pats_enc$p4, pats_enc$p6)]
  dt_pat <- dt_pat[c(pats_pat$p2, pats_pat$p3, pats_pat$p4, pats_pat$p6)]
  dt_pid <- dt_pid[c(pats_pid$p2, pats_pid$p3, pats_pid$p4, pats_pid$p6)]

  if (DEBUG_DAY == 1) {
    dt_enc[, enc_status := "in-progress"]
    dt_enc[, enc_period_end := NA]
    dt_enc[, (diag_cols) := NA]

  } else if (DEBUG_DAY == 2) {

    # Patient 2: unverändert zu Tag 1
    dt_enc[pats_enc$p2, enc_status := "in-progress"]
    dt_enc[pats_enc$p2, enc_period_end := NA]
    dt_enc[pats_enc$p2, (diag_cols) := NA]

    # Patient 3: Fall weiter in progress, vorhandene Diagnose wird nicht gelöscht
    dt_enc[pats_enc$p3, enc_status := "in-progress"]
    dt_enc[pats_enc$p3, enc_period_end := NA]

    # Patient 4: Fall beendet, Diagnose ist nun vorhanden
    # entspricht Originaldaten, daher hier keine Änderung

    # Patient 6: Fall beendet, keine Diagnose
    dt_enc[pats_enc$p6, (diag_cols) := NA]

    # # Patient 10: neuer Fall ohne Diagnose
    # dt_enc[pats_enc$p10, enc_status := "in-progress"]
    # dt_enc[pats_enc$p10, enc_period_end := NA]
    # dt_enc[pats_enc$p10, (diag_cols) := NA]

  } else if (DEBUG_DAY == 3) {

  } else if (DEBUG_DAY == 4) {

  }

  dt_enc <- unique(dt_enc)
  dt_pat <- unique(dt_pat)
  dt_pid <- unique(dt_pid)

  resource_tables[["Encounter"]] <- dt_enc
  resource_tables[["Patient"]] <- dt_pat
  resource_tables[["pids_per_ward"]] <- dt_pid
}
