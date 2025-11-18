# Creates Mediaktionsanalyse entries for debug patients on debug days

source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)

if (isDebugDay(1)) {
  dt_patient <- data_to_import$patient
  pat_ids <- filterPatientIdsByLevel(dt_patient$pat_id, 1)
  data_to_import[["medikationsanalyse"]] <- addREDCapMedikationsanalyse(
    dt_med_ana = data_to_import[["medikationsanalyse"]],
    patient_ids = pat_ids,
    #Annahme: Drugs und Observations + Conditions + Procedures sind alle an Tag 1 bis 5 ( = + 0 bis 4.5)
    day_offset = 4.4 # alle MRP müssen berechnet werden, weil MedAna-Datum damit nach allem anderen liegt
  )
}
