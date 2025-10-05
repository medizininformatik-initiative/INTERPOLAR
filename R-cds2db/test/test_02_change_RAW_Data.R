# Patient UKB-0001 6x dupliziert -> UKB-0001_1 bis UKB-0001_6
# Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
#        Erster Patient hat nichts, alle anderen haben jeweils ein MRP und eine
#        Medikationsanalyse (diese kommt aus der zugehörigne change_REDCap_Data.R)
# Tag 2: Encounter wird entlassen

# Ergebnis: Am Ende soll im Redcap nach Tag 2 für UKB-0001_1 bis UKB-0001_6 jeweils ein MRP und eine Medikationsanalyse vorliegen

#################################
# Start Define global variables #
#################################

# Define the days count for this test
DEBUG_DAYS_COUNT <- 2

# Activate if only a specific debug day should be run
#RUN_DEBUG_DAY_ONLY <- 2

###
# DEBUG_MODULES_PATH_TO_CONFIG_TOML can contain for every module a path to
# a config file. If the path is not set, then only the default config file
# is used and no default values are overwritten by the debug config file.
###
DEBUG_MODULES_PATH_TO_CONFIG_TOML <- c(
  cds2db = "./R-cds2db/test/test_cds2db_config.toml",
  dataprocessor = "",
  db2frontend = ""
)

###
# If this parameter is given, then no request is sent to the FHIR server, but
# all data is loaded from this folder from RData files
###
DEBUG_PATH_TO_RAW_RDATA_FILES <- "./R-cds2db/test/tables/"

WARDS_PHASE_B_TEST <- c("Station 1-1")

###############################
# End Define global variables #
###############################


if (exists("DEBUG_DAY")) {

  # Load the necessary libraries
  source("./R-cds2db/test/test_common_data_preparation.R", local = TRUE)
  # resources are a list of data tables from outside we want to change for the test
  testSetResourceTables(resource_tables)

  pid1 <- "UKB-0001"
  pats <- pid1 # present at day 1

  if (DEBUG_DAY == 1) {
    # clear database on Day 1
    etlutils::dbReset()
  } else {
    if (exists("RUN_DEBUG_DAY_ONLY")) {
      etlutils::dbReset(c("db_log.dp_mrp_calculations", "db_log.retrolektive_mrpbewertung_fe"))
    }
    # Load all encounters from the database which, according to the database,
    # have not yet ended on the 'current' date and determine the PIDs.
    # Background: We want to track all cases that have ever been on a relevant
    # station until they are completed. So if a patient is discharged, we still
    # want to track the case until it is completed.
    patient_ids_db <- etlutils::getAfterLastSlash(getActiveEncounterPIDsFromDB())
    pats <- unique(c(pats, patient_ids_db))
  }

  # Convenience list of patient IDs
  pats <- namedListByValue(pats)

  testPrepareRAWResources(pats)
  testRemoveMultipleDiagnoses()

  # set the enc_period_start of all encounters of a patient to the current date
  # minus an offset
  for (i in seq_along(pats)) {
    testChangeDataForPIDEncounter(paste0("UKB-000", i), "enc_period_start", getDebugDatesRAWDateTime(-i, 1))
  }

  # Show the current state of the resources
  # dt_enc <- testGetResourceTable("Encounter")
  # pids_per_wards <- testGetResourceTable("pids_per_ward")
  current_debug_day <- DEBUG_DAY

  runCodeForDebugDay(1, {
    # Patient 1 Tag 1: Versorgungsstellenkontakt auf Station 1-1 Zimmer 1-1, Bett 1-1
    testAdmission(pid1, "Raum 1-1", "Bett 1-1", "Station 1-1")
  })
  runCodeForDebugDay(2, {
    # Patient 1 Tag 2: Encounter wird entlassen
    testDischarge(pid1)
  })

  #duplicatePatients(15)
  duplicatePatients(1, 6)

  runCodeForDebugDay(1, {

    ################
    # Drug_Disease #
    ################

    # # UKB-0001_1 -> Drug_Disease -> simple Drug + simple Disease
    # # Line 114850 -> MedicationRequest - N02AA01 + Diagnosis - R10.0
    # addDrugs("UKB-0001_1", "N02AA01")
    # addConditions("UKB-0001_1", "R10.0")
    #
    # # UKB-0001_2 -> Drug_Disease -> Drug SY + simple Disease
    # # Line 115318 -> MedicationRequest - H02BX09 + Diagnosis - O41.1
    # addDrugs("UKB-0001_2", "H02BX09")
    # addConditions("UKB-0001_2", "O41.1")
    #
    # # UKB-0001_3 -> Drug_Disease -> Proxy ATC
    # # Line 71835 -> MedicationRequest - C09DA06 + M04AA01 (ATC-Proxy)
    # addDrugs("UKB-0001_3", c("C09DA06", "M04AA01"))
    #
    # # UKB-0001_4 -> Drug_Disease -> Proxy LOINC primary, > ULN
    # # Line 76539 -> MedicationRequest - C03DA02 + Observation - 2823-3
    # addDrugs("UKB-0001_4", "C03DA02")
    # addObservations("UKB-0001_4", "2823-3", value = 12, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10)
    #
    # # UKB-0001_5 -> Drug_Disease -> Proxy LOINC primary, < LLN
    # # Line 104451 -> MedicationRequest - C03DA02 + Observation - 2951-2
    # addDrugs("UKB-0001_5", "C03DA02")
    # addObservations("UKB-0001_5", "2951-2", value = 3, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10)
    #
    # UKB-0001_6 -> Drug_Disease -> Proxy LOINC primary, > 5 * ULN
    # Line 8096 -> MedicationRequest - J01MA14 + Observation - 1742-6
    addDrugs("UKB-0001_6", c("J01MA14", "C03DA02"))
    for (i in 1:5) {
      # 5 Obs mit ULN Überschreitung alle Zeitpunkte an Tag 1  (Wert immer > 5 * ULN)
      addObservations("UKB-0001_6", "1742-6", day_offset = -0.5 + (i * 0.01), value = 60 + i, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10) # +
      # 5 Obs mit ULN Überschreitung alle Zeitpunkte an Tag 0 (vor Aufnahme) (Wert immer > 5 * ULN)
      addObservations("UKB-0001_6", "1742-6", day_offset = -1.5 + (i * 0.01), value = 60.1 + i, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10) # +

      # 5 Obs mit ULN Überschreitung alle Zeitpunkte an Tag 1 (Wert immer > 5 * ULN) aber anderer Reference Range als bei den ersten 10
      addObservations("UKB-0001_6", "1742-6", day_offset = -0.5 + (i * 0.01), value = 0.6 + (i * 0.001), unit = "mg/mL", referencerange_low = 0.03, referencerange_high = 0.11) # +
      # 5 Obs mit ULN Überschreitung alle Zeitpunkte an Tag 0 (vor Aufnahme) (Wert immer > 5 * ULN) aber anderer Reference Range als bei den ersten 10
      addObservations("UKB-0001_6", "1742-6", day_offset = -1.5 + (i * 0.01), value = 0.61 + (i * 0.001), unit = "mg/mL", referencerange_low = 0.03, referencerange_high = 0.11) # +


      # 5 Obs ohne ULN Überschreitung alle Zeitpunkte an Tag 1 (Wert immer < 5 * ULN)
      addObservations("UKB-0001_6", "1742-6", day_offset = -0.5 + (i * 0.015), value = 5 + (i * 0.1), unit = "mg/dL", referencerange_low = 5, referencerange_high = 10) # -
      # 5 Obs mit ULN Überschreitung für alle Zeitpunkte um die Gültigkeitsdauer der Diagnose von max. 30 Tagen (Wert immer > 5 * ULN)
      addObservations("UKB-0001_6", "1742-6", day_offset = -28.5 + (i * 0.01), value = 0.62 + (i * 0.001), unit = "mg/mL", referencerange_low = 0.03, referencerange_high = 0.11) # +
      addObservations("UKB-0001_6", "1742-6", day_offset = -29.5 + (i * 0.01), value = 0.63 + (i * 0.001), unit = "mg/mL", referencerange_low = 0.03, referencerange_high = 0.11) # +
      addObservations("UKB-0001_6", "1742-6", day_offset = -30.5 + (i * 0.01), value = 0.64 + (i * 0.001), unit = "mg/mL", referencerange_low = 0.03, referencerange_high = 0.11) # -
      addObservations("UKB-0001_6", "1742-6", day_offset = -31.5 + (i * 0.01), value = 0.65 + (i * 0.001), unit = "mg/mL", referencerange_low = 0.03, referencerange_high = 0.11) # -

      # 5 Obs mit LLN Unterschreitung alle Zeitpunkte an Tag 1 (Wert immer < LLN) anderer LOINC
      addObservations("UKB-0001_6", "2951-2", day_offset = -0.5 + (i * 0.01), value = 5 - (i * 0.001), unit = "mg/dL", referencerange_low = 5, referencerange_high = 10)

      #TODO: Über- und Unterschreitung gleichzeitg testen mit demselben LOINC
    }

    # # UKB-0001_7 -> Drug_Disease -> Proxy LOINC secondary, > 5 * ULN
    # # Line 8096 -> MedicationRequest - J01MA14 + Observation - 1743-4
    # addDrugs("UKB-0001_7", "J01MA14")
    # addObservations("UKB-0001_7", "1743-4", value = 60, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10)

    # # UKB-0001_8 -> Drug_Disease -> Proxy LOINC primary, cutoff absolute, no unit conversion
    # # Line 133 -> MedicationRequest - C02KX01 + Observation - 1751-7 < 20 g/L
    # addDrugs("UKB-0001_8", "C02KX01")
    # addObservations("UKB-0001_8", "1751-7", value = 15, unit = "g/L")
    #
    # # UKB-0001_9 -> Drug_Disease -> Proxy LOINC primary, cutoff absolute, simple unit conversion
    # # Line 133 -> MedicationRequest - C02KX01 + Observation - 1751-7 < 20 g/L
    # addDrugs("UKB-0001_9", "C02KX01")
    # addObservations("UKB-0001_9", "1751-7", value = 15000, unit = "mg/L")
    #
    # # UKB-0001_10 -> Drug_Disease -> Proxy LOINC secondary, cutoff absolute, no unit conversion
    # # Line 71660 -> MedicationRequest - C01DA14 + Observation - 14775-1 < 4,9 mmol/L
    # addDrugs("UKB-0001_10", "C01DA14")
    # addObservations("UKB-0001_10", "14775-1", value = 4.1, unit = "mmol/L")
    #
    # # UKB-0001_11 -> Drug_Disease -> Proxy LOINC secondary, cutoff absolute, simple SI unit conversion
    # # Line 71660 -> MedicationRequest - C01DA14 + Observation - 14775-1 < 4,9 mmol/L
    # addDrugs("UKB-0001_11", "C01DA14")
    # addObservations("UKB-0001_11", "14775-1", value = 0.41, unit = "mmol/dL")
    #
    # # UKB-0001_12 -> Drug_Disease -> Proxy LOINC secondary, cutoff absolute, complex unit conversion
    # # Line 71660 -> MedicationRequest - C01DA14 + Observation - 14775-1 < 4,9 mmol/L with mmol/L = 621 * mg/dL
    # addDrugs("UKB-0001_12", "C01DA14")
    # addObservations("UKB-0001_12", "14775-1", value = 3000, unit = "mg/dL")
    #
    # # UKB-0001_13 -> Drug_Disease -> Proxy LOINC secondary, cutoff absolute, simple non-SI and complex unit conversion
    # # Line 71660 -> MedicationRequest - C01DA14 + Observation - 14775-1 < 4,9 mmol/L with mmol/L = 621 * mg/dL
    # addDrugs("UKB-0001_13", "C01DA14")
    # addObservations("UKB-0001_13", "14775-1", value = 30, unit = "g/L")

    # # UKB-0001_14 -> Drug_Disease -> Proxy LOINC primary, > ULN
    # # Line 570 -> MedicationRequest - C03DA02 + Observation - 2823-3
    # # UKB-0001_14 -> Drug_Disease -> Proxy LOINC primary, < LLN
    # # Line 571 -> MedicationRequest - C03DA02 + Observation - 2951-2
    # addDrugs("UKB-0001_14", "C03DA02")
    # addObservations("UKB-0001_14", "2823-3", value = 12, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10) # MRP, weil > ULN
    # addObservations("UKB-0001_14", "2951-2", value = 3, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10) # MRP, weil < LLN
    # addObservations("UKB-0001_14", "1111-1", value = 3, unit = "mg/dL", referencerange_low = 5, referencerange_high = 10) # kein MRP, weil ungültiger LOINC
    # addObservations("UKB-0001_14", "39789-3", value = 4, unit = "mg/dL", referencerange_low = 1, referencerange_high = 2) # MRP, weil > ULN
    # addObservations("UKB-0001_14", "39789-3", value = 3, unit = "mg/dL", referencerange_low = 1, referencerange_high = 2) # MRP, weil > ULN
    # addObservations("UKB-0001_14", "39789-3", value = 2, unit = "mg/dL", referencerange_low = 1, referencerange_high = 2) # kein MRP, weil = ULN


    # # UKB-0001_15 -> Drug_Disease -> Proxy LOINC secondary, cutoff absolute, simple non-SI and complex unit conversion
    # # Line 71660 -> MedicationRequest - C01DA14 + Observation - 14775-1 < 4,9 mmol/L with mmol/L = 621 * mg/dL
    # addDrugs("UKB-0001_15", "C01DA14")
    # for (i in 0:10) {
    #   addObservations("UKB-0001_15", "14775-1", day_offset = -0.5 + (i * 0.01), value = 30 - (i * 0.01), unit = "g/L")
    # }




    # # UKB-0001_14 -> Drug_Disease -> Proxy LOINC primary, cutoff absolute, no unit conversion
    # # Line 151967 -> MedicationRequest - C01DA14 + Observation - 14775-1
    # addDrugs("UKB-0001_14", "C07BB27")
    # addObservations("UKB-0001_14", "33762-6", value = 1801, unit = "pg/mL")


    # TODO: 30 Tage ültigkeitsdauer vs. unendliche Gültigkeit testen

    #
    # ###############
    # # Drug - Drug #
    # ###############
    #
    # # UKB-0001_15 -> Drug_Drug_Interaction                  -> MedicationRequests - N06AX22 + J01MA02
    # addDrugs("UKB-0001_15", c("N06AX22", "J01MA02"))
    #
    # ####################
    # # Drug - DrugGroup #
    # ####################
    #
    # # UKB-0001_16 -> Drug_DrugGroup_Interaction             -> MedicationRequests - N06BA09 + C02KC01
    # addDrugs("UKB-0001_16", c("N06BA09", "C02KC01"))

  })

  # Update the resource_tables list with the modified data tables
  resource_tables <- testGetResourceTables()
}
