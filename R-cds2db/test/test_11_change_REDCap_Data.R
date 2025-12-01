# Creates Mediaktionsanalyse and mrpdokumentation_validierung entries for debug patients on debug days

source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)

if (isDebugDay(1)) {
  dt_patient <- data_to_import$patient
  # all patients of level 1 receive one Medikationsanalyse entry
  pat_ids <- filterPatientIdsByLevel(dt_patient$pat_id, 1)
  data_to_import[["medikationsanalyse"]] <- addREDCapMedikationsanalyse(
    dt_med_ana = data_to_import[["medikationsanalyse"]],
    patient_ids = pat_ids,
    #Annahme: Drugs und Observations + Conditions + Procedures sind alle am Tag 1 bis DEBUG_DAY - 0.3 vorhanden
    day_offset = -0.299 # alle MRP müssen berechnet werden, weil MedAna-Datum damit nach allem anderen liegt
    #day_offset = -0.3 # # alle MRP müssen berechnet werden, weil MedAna-Datum damit zeitgleich mit dem letzten anderen Datum liegt
    #day_offset = -0.301 # kein MRP darf berechnet werden
  )
  # patients of level 1 with last index 2-12 receive one MRP Dokumentation entry
  pat_ids <- filterPatientIdsByLevel(dt_patient$pat_id, 1, last_indices = c(2:12))
  data_to_import[["mrpdokumentation_validierung"]] <- addREDCapMRPDokumentation(
    dt_mrp_doku = data_to_import[["mrpdokumentation_validierung"]],
    patient_ids = pat_ids
  )
  # patients of level 1 with last index 2-3 receive a second MRP Dokumentation entry
  pat_ids <- filterPatientIdsByLevel(dt_patient$pat_id, 1, last_indices = c(2,3))
  data_to_import[["mrpdokumentation_validierung"]] <- addREDCapMRPDokumentation(
    dt_mrp_doku = data_to_import[["mrpdokumentation_validierung"]],
    patient_ids = pat_ids
  )
  # patients of level 1 with last index 3 receive a third MRP Dokumentation entry
  pat_ids <- filterPatientIdsByLevel(dt_patient$pat_id, 1, last_indices = c(3))
  data_to_import[["mrpdokumentation_validierung"]] <- addREDCapMRPDokumentation(
    dt_mrp_doku = data_to_import[["mrpdokumentation_validierung"]],
    patient_ids = pat_ids
  )
  # patients of level 1 with last index 4 receive a second Medikationsanalyse entry
  pat_ids <- filterPatientIdsByLevel(dt_patient$pat_id, 1, last_indices = c(4))
  data_to_import[["medikationsanalyse"]] <- addREDCapMedikationsanalyse(
    dt_med_ana = data_to_import[["medikationsanalyse"]],
    patient_ids = pat_ids,
    day_offset = -0.200
  )
}
