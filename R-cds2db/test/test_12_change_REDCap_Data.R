# Creates Mediaktionsanalyse entries for debug patients on debug days

source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)

if (isDebugDay(1) || TRUE) {
  dt_patient <- data_to_import$patient
  pat_ids <- filterPatientIdsByLevel(dt_patient$pat_id, 0)
  data_to_import[["medikationsanalyse"]] <- addREDCapMedikationsanalyse(
    dt_med_ana = data_to_import[["medikationsanalyse"]],
    patient_ids = pat_ids,
    #Annahme: Drugs und Observations + Conditions + Procedures sind alle am Tag 1 bis DEBUG_DAY - 0.3 vorhanden
    day_offset = -0.299 # alle MRP müssen berechnet werden, weil MedAna-Datum damit nach allem anderen liegt
    #day_offset = -0.3 # # alle MRP müssen berechnet werden, weil MedAna-Datum damit zeitgleich mit dem letzten anderen Datum liegt
    #day_offset = -0.301 # kein MRP darf berechnet werden
  )
}
