# Creates Medikationsanalyse entries for debug patients on debug days

source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)

if (isDebugDay(1)) {
  dt_patient <- data_to_import$patient
  pat_ids <- filterPatientIdsByLevel(dt_patient$pat_id, 0)
  # The medication analysis is created in REDCap on day 1 but is only available
  # to dataprocessor on day 2 after the regular frontend2db import.
  data_to_import[["medikationsanalyse"]] <- addREDCapMedikationsanalyse(
    dt_med_ana = data_to_import[["medikationsanalyse"]],
    patient_ids = pat_ids,
    # The first medication analysis must be inside the short encounter from day 1:
    # after the initial RAW data (-0.7 / -0.69) but before discharge (-0.5).
    day_offset = -0.55
  )
}
