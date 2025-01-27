# TODO Drug_Disease:
# Lade alle Patienten über die aktuelle Liste der PIDs (Patienten, die aktuell auf einer
# IP-Station sind)
# Lade alle Encounter herunter, von den Patienten, die gerade auf einer IP-Station sind (ggf. mit Zeitbegrenzung)
# Lade alle anderen Ressourcen (MedicationRequest/Condition) über Encounter-ID herunter (Solange wir die Encounter-Reference haben)
# MRP Calculation
# Write MRP in DB-Table
etlutils::runLevel2("Calculate Drug-Disease MRPs", {

  # Load Drug-Disease Definition
  path_to_mrp_tables <- "./Input-Repo"
  drug_disease_mrp_definition <- etlutils::readFirstExcelFileAsTableList(path_to_mrp_tables, "Drug-Disease")

  drug_disease_mrp_table <- readRDS("./Input-Repo/drug_disease_mrp_table_expanded.RData")
  if (!exists("drug_disease_mrp_table")) {
    # Preprocess Drug-Disease table
    drug_disease_mrp_table <- cleanAndExpandDefinition(drug_disease_mrp_definition$Drug_Disease_Pairs)
  }

  # Calculate Drug-Disease MRP
  drug_disease_mrps <- calculateDrugDiseaseMRPs(drug_disease_mrp_table)

})
