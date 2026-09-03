# Erweiterter Mehrpatienten-Test für die MRP-Rekalkulation
# Tag 1:
#   - UKB-0001: 1 initiale Drug-Disease-Konstellation -> soll nach Tag 2 genau 1 MRP haben
#   - UKB-0002: noch keine MRP-ausloesenden RAW-Daten -> soll nach Tag 2 noch 0 MRP haben
#   - UKB-0003: 1 initiale Drug-Disease-Konstellation aus einer WP7-Zeile mit weiteren Proxy-Moeglichkeiten
#               -> soll nach Tag 2 genau 1 MRP haben
#   - Fuer alle drei Patienten wird am selben Tag eine Medikationsanalyse im REDCap angelegt
#     und der Fall wieder in pids_per_ward sichtbar gehalten.
# Tag 2:
#   - regulaerer voller Toolchain-Lauf
#   - frontend2db uebernimmt die Medikationsanalysen in die DB
#   - dataprocessor berechnet die initialen MRPs:
#       UKB-0001 -> 1
#       UKB-0002 -> 0
#       UKB-0003 -> 1
# Tag 3:
#   - es laeuft absichtlich nur cds2db
#   - verspaetete, rueckdatierte RAW-Daten werden importiert:
#       UKB-0001 -> 2 weitere neue MRPs
#       UKB-0002 -> 1 erstes MRP erst durch Recalculation
#       UKB-0003 -> dieselbe WP7-Drug-Disease-Zeile nochmal ueber einen anderen Proxy
#                   -> darf nach Recalculation KEIN zusaetzliches MRP erzeugen
# Danach soll MRP_Recalculation insgesamt genau 3 neue MRPs nachziehen.

#################################
# Start Define global variables #
#################################

DEBUG_DAYS_COUNT <- 3

# Activate if only a specific debug day should be run
# DEBUG_RUN_SINGLE_DAY_ONLY <- 2

# Immediate MRP calculation after encounter end so the effect of day 2 is visible.
DAYS_AFTER_ENCOUNTER_END_TO_CHECK_FOR_MRPS <- 0

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
  pid2 <- "UKB-0002"
  pid3 <- "UKB-0003"
  pats <- c(pid1, pid2, pid3)

  if (TOOLCHAIN_DAY > 1) {
    if (exists("DEBUG_RUN_SINGLE_DAY_ONLY")) {
      etlutils::dbReset(c("db_log.dp_mrp_calculations", "db_log.retrolektive_mrpbewertung_fe"))
    }
    patient_ids_db <- etlutils::getAfterLastSlash(getActiveEncounterPIDsFromDB())
    pats <- unique(c(pats, patient_ids_db))
  }

  pats <- namedListByValue(pats)

  testPrepareRAWResources(pats)
  testRemoveMultipleDiagnoses()

  runCodeForDebugDay(1, {
    if (exists("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)) {
      rm("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)
    }

    # UKB-0001: one simple initial MRP on day 2, then two more by recalculation.
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1", day_offset = -0.8)
    pid <- addDrugs(pid1, "N02AA01", day_offset = -0.7)
    addConditions(pid, "R10.0", day_offset = -0.69)
    testDischarge(pid1)
    testUpdateWard(testGetEncounterLevel(pid1, 1)$enc_id, "Station 1")

    # UKB-0002: encounter and medication analysis exist, but no MRP-triggering RAW data
    # are present before day 3. The first MRP should therefore appear only after
    # the explicit recalculation run.
    testAdmission(pid2, "Raum 1-2", "Bett 1-2", "Station 1", day_offset = -0.8)
    testDischarge(pid2)
    testUpdateWard(testGetEncounterLevel(pid2, 1)$enc_id, "Station 1")

    # UKB-0003: one initial MRP from a Drug-Disease row that also supports ATC proxies.
    # On day 3 a second proxy for the same WP7 line is imported and must not create
    # a duplicate retrospective MRP during recalculation.
    testAdmission(pid3, "Raum 1-3", "Bett 1-3", "Station 1", day_offset = -0.8)
    pid <- addDrugs(pid3, "C09DA06", day_offset = -0.7)
    addConditions(pid, "M10.00", day_offset = -0.69)
    testDischarge(pid3)
    testUpdateWard(testGetEncounterLevel(pid3, 1)$enc_id, "Station 1")
  })

  runCodeForDebugDay(2, {
    if (exists("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)) {
      rm("DEBUG_START_SINGLE_MODULE", envir = .GlobalEnv)
    }
  })

  runCodeForDebugDay(3, {
    assign("DEBUG_START_SINGLE_MODULE", "cds2db", envir = .GlobalEnv)

    # The timestamps are intentionally backdated to lie
    #   encounter_start < late_data < first_medication_analysis < encounter_end
    # so the day-1 medication analyses can be reused by the later recalculation.

    # UKB-0001: two additional, distinct retrospective MRPs.
    pid <- addDrugs(pid1, "R03CC53", day_offset = -2.65)
    addConditions(pid, "I47", day_offset = -2.64)

    pid <- addDrugs(pid1, "L04AX03", day_offset = -2.63)
    addConditions(pid, "J32.0", day_offset = -2.62)

    # UKB-0002: first MRP only via late data and later recalculation.
    pid <- addDrugs(pid2, "N02AA01", day_offset = -2.65)
    addConditions(pid, "R10.0", day_offset = -2.64)

    # UKB-0003: same Drug-Disease row as day 1, now via ATC proxy instead of
    # diagnosis. Recalculation must treat the resulting retrospective MRP as an
    # already existing one and must not append a duplicate.
    addDrugs(pid3, "M04AA01", day_offset = -2.65)
  })

  resource_tables <- testGetResourceTables()
  return(resource_tables)
}
