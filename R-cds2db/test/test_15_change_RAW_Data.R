# Datenverfuegbarkeit: Ein Patient mit einem INTERPOLAR-Fall und einem Nicht-INTERPOLAR-Fall.
#
# Tag 1:
#   - UKB-0001 hat zuerst einen Fall auf Station 1 (INTERPOLAR/IP).
#   - Danach wird derselbe Patient in einem neuen Fall auf Station 3 aufgenommen
#     (nicht INTERPOLAR/IP).
#   - Beide Faelle enthalten fallbezogene FHIR-Ressourcen.
#   - Am Ende bleibt nur der Station-1-Fall in pids_per_ward sichtbar.
#
# Erwartung fuer die Database Quality Analysis:
#   - FHIR enthaelt beide Faelle.
#   - FHIR INTERPOLAR enthaelt nur Ressourcen des Station-1-Falls.
#   - Ressourcen des Station-3-Falls duerfen trotz gleicher Patient-ID nicht
#     im FHIR-INTERPOLAR-Sheet mitgezaehlt werden.

#################################
# Start Define global variables #
#################################

DEBUG_DAYS_COUNT <- 1

DEBUG_MODULES_PATH_TO_CONFIG_TOML <- c(
  cds2db = "./R-cds2db/test/test_cds2db_config.toml",
  dataprocessor = "",
  db2frontend = ""
)

DEBUG_PATH_TO_RAW_RDATA_FILES <- "./R-cds2db/test/tables/"

###############################
# End Define global variables #
###############################


if (exists("TOOLCHAIN_DAY")) {
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  testSetResourceTables(resource_tables)

  pid1 <- "UKB-0001"
  pats <- namedListByValue(pid1)

  testPrepareRAWResources(pats)
  testRemoveMultipleDiagnoses()

  runCodeForDebugDay(1, {
    # Fall 1: INTERPOLAR-relevanter Fall auf Station 1.
    interpolar_enc_ids <- testAdmission(
      pid1,
      room = "Raum IP",
      bed = "Bett IP",
      ward_name = "Station 1",
      day_offset = -0.9
    )
    addObservation(
      pid1,
      code = "14933-1",
      day_offset = -0.85,
      value = 1000,
      unit = "umol/L",
      encounter_id = interpolar_enc_ids[[3]]
    )
    addDrugs(
      pid1,
      codes = "M04AA01",
      day_offset = -0.84,
      encounter_id = interpolar_enc_ids[[3]]
    )
    testDischarge(pid1)

    # Fall 2: Nicht-INTERPOLAR-Fall desselben Patienten auf Station 3.
    non_interpolar_enc_ids <- testAdmission(
      pid1,
      room = "Raum Nicht-IP",
      bed = "Bett Nicht-IP",
      ward_name = "Station 3",
      day_offset = -0.7
    )
    addObservation(
      pid1,
      code = "14933-3",
      day_offset = -0.65,
      value = 2000,
      unit = "umol/L",
      encounter_id = non_interpolar_enc_ids[[3]]
    )
    addDrugs(
      pid1,
      codes = "M04AA03",
      day_offset = -0.64,
      encounter_id = non_interpolar_enc_ids[[3]]
    )
    testDischarge(pid1)

    # Die DQA soll nur den IP-Fall als INTERPOLAR-Fall erkennen. Das ist bewusst
    # nach der zweiten Entlassung gesetzt, weil testDischarge pids_per_ward leert.
    testUpdateWard(interpolar_enc_ids[[3]], "Station 1")
  })

  resource_tables <- testGetResourceTables()
  return(resource_tables)
}
