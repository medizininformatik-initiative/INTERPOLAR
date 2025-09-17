# Creates Mediaktionsanalyse entries for debug patients on debug days

source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)

if (isDebugDay()) {
  # Load the necessary libraries
  template <- loadDebugREDCapDataTemplate("medikationsanalyse")

  dt_patient <- data_to_import$patient
  pat_ids <- filterPatientIdsByLevel(dt_patient$pat_id, 0, 1)
  data_to_import[["medikationsanalyse"]] <- addREDCapMedikationsanalyse(
    dt_med_ana = data_to_import[["medikationsanalyse"]],
    patient_ids = pat_ids,
    day_offset = 0.5
  )

}
