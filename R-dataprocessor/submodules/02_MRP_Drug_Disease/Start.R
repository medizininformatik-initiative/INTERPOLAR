# TODO Drug_Disease:
# Lade alle Patienten über die aktuelle Liste der PIDs (Patienten, die aktuell auf einer
# IP-Station sind)
# Lade alle Encounter herunter, von den Patienten, die gerade auf einer IP-Station sind (ggf. mit Zeitbegrenzung)
# Lade alle anderen Ressourcen (MedicationRequest/Condition) über Encounter-ID herunter (Solange wir die Encounter-Reference haben)
# MRP Calculation
# Write MRP in DB-Table
etlutils::runLevel2("Study 1a Create Simple Patient and Case View", {
  print("TODO Calculate Drug Disease...")
})
