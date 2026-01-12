#' Create Statistical Report for INTERPOLAR Ward Metrics
#'
#' Generates a comprehensive statistical report for patients hospitalized on INTERPOLAR wards,
#' using patient, encounter, and front-end documentation data within a defined reporting period.
#' The report computes base population metrics (F1) and a summary of medication safety documentation
#' for internal monitoring and evaluation. REPORT_PERIOD_START and REPORT_PERIOD_END can be set
#' via command line arguments. Defaults are set to `"2024-01-01"` for the start date and the
#' current date for the end date.
#'
#' @param REPORT_PERIOD_START Character string in `"YYYY-MM-DD"` format.
#'   Start date of the reporting period. Default is `"2024-01-01"`.
#' @param REPORT_PERIOD_END Character string in `"YYYY-MM-DD"` format.
#'   End date of the reporting period. Defaults to `Sys.Date()`.
#' @param WRITE_TABLE_LOCAL Logical. If `TRUE`, intermediate tables are written to the outputLocal folder.
#'
#' @return Invisibly returns `NULL`. This function is called for its side effects:
#'   writing local and global summary tables and producing a structured internal report.
#'
#' @details
#' The function performs the following main steps:
#'
#' \enumerate{
#'   \item Fetches source tables:
#'     \itemize{
#'       \item `getPatientData()` – one row per patient
#'       \item `getEncounterData()` – multiple rows per encounter possible
#'       \item `getPidsPerWardData()` – ward stays per sub-encounter
#'       \item `getPatientFeData()` – one row per patient
#'       \item `getFallFeData()` – one or more rows per case e.g. different wards
#'       \item `getMedikationsanalyseFeData()` – not yet latest version per entry
#'       \item `getMRPDokumentationValidierungFeData()` – not yet latest version per entry
#'     }
#'
#'   \item Constructs the core encounter-patient dataset:
#'     \itemize{
#'       \item `mergePatEnc()`, `addCuratedEncPeriodEnd()`, `addMainEncId()`,
#'             `addMainEncPeriodStart()`, `calculateAge()`, `addWardName()`,
#'       \item `addRecordId()`, `addFallIdAndStudienphase()`
#'     }
#'
#'   \item Merges and enriches front-end documentation:
#'     \itemize{
#'       \item `mergePatFeFallFe()`, `addMedaData()`, `addVersorgungsstellenkontaktToFeData()`,
#'             `addMRPDokuData()`
#'     }
#'
#'   \item Defines the Full Analysis Set 1 (FAS1) base population with `defineFullAnalysisSet1()`
#'
#'   \item Prepares and calculates key F1 metrics:
#'     \itemize{
#'       \item `prepareF1data()`, `addFeDataToF1data()`, `calculateF1()`, `calculateFeAddOnToF1()`
#'     }
#'
#'   \item Summarizes medication and MRP documentation activity:
#'     \itemize{
#'       \item `prepareFeSummaryData()`, `calculateFeSummary()`
#'     }
#'
#'   \item Writes outputs:
#'     \itemize{
#'       \item `writeHtmlTable()` – html table in output local (default) or global (if defined)
#'     }
#' }
#'
#' @section Output:
#' - **Local output**: `FHIR_table_with_ward_name_and_record_id`, `full_analysis_set_1`, `statistical_report_data`,
#'   `frontend_table`, `frontend_summary_data`
#' - **Global output**:
#'   \itemize{
#'     \item `statistical_report`: F1 metrics with front-end add-ons
#'     \item `frontend_summary`: Overall summary of front-end documentation
#'   }
#' Tables include captions describing the reporting period and footnotes explaining relevant metric
#' assumptions.
#'
#' @note
#' Additional functionality for F2 metrics is scaffolded in the function but currently inactive.
#'
#' @seealso
#' [getPatientData()], [getEncounterData()], [getPidsPerWardData()],
#' [mergePatEnc()], [defineFullAnalysisSet1()], [prepareF1data()], [calculateF1()],
#' [prepareFeSummaryData()], [calculateFeSummary()],
#' [writeHtmlTable()]
#'
#' @export
createStatisticalReport <- function(REPORT_PERIOD_START = "2024-01-01",
                                    REPORT_PERIOD_END = as.character(Sys.Date()),
                                    WRITE_TABLE_LOCAL = FALSE) {
  if (!interactive()) {
    named_args <- parseNamedArgs()
    if ("REPORT_PERIOD_START" %in% names(named_args)) {
      REPORT_PERIOD_START <- named_args[["REPORT_PERIOD_START"]]
    }
    if ("REPORT_PERIOD_END" %in% names(named_args)) {
      REPORT_PERIOD_END <- named_args[["REPORT_PERIOD_END"]]
    }
    if ("WRITE_TABLE_LOCAL" %in% names(named_args)) {
      WRITE_TABLE_LOCAL <- as.logical(named_args[["WRITE_TABLE_LOCAL"]])
    }
  }

  print(paste0(
    "Report period start: ", REPORT_PERIOD_START,
    ", Report period end: ", REPORT_PERIOD_END,
    ", Write local tables: ", WRITE_TABLE_LOCAL
  ))

  patient_table <- getPatientData(
    lock_id = "statistical reports[1]",
    table_name = "v_patient_last_version"
  ) |>
    CheckMultipleRowsPerPatId() |>
    CheckMultipleRowsPerPatIdentifierValue()
  # --> this table should only have one entry per patient (warning if not)

  encounter_table <- getEncounterData(
    lock_id = "statistical reports[2]",
    table_name = "v_encounter_last_version",
    report_period_start = REPORT_PERIOD_START
  ) |>
    CheckMissingStartDate() |>
    CheckMissingKontaktebeneForImpEncounter() |>
    CheckUnexpectedStatus() |>
    CheckImpFinishedWithoutEndDate() |>
    CheckUnexpectedClassCode() |>
    CheckUnexpectedKontaktartCode() |>
    CheckMultipleEinrichtungskontaktEncIdsForSameEncIdentifierValue() |>
    CheckMultipleEinrichtungskontaktEncIdentifierValuesForSameEncId() |>
    CheckEncountersWithoutCalculatedParentRef() |>
    CheckEncountersWithoutCalculatedMainEncounterRef()
  # --> this table can have multiple rows per encounter

  pids_per_ward_table <- getPidsPerWardData(
    lock_id = "statistical reports[3]",
    table_name = "v_pids_per_ward"
  )
  # this table can have multiple entries per main encounter due to transferral to another ward,
  # it should include the encounter level "Versorgungsstellenkontakt"

  patient_fe_table <- getPatientFeData(
    lock_id = "statistical reports[4]",
    table_name = "v_patient_fe"
  ) |>
    CheckMultipleRowsPerPatIdInFe()
  # --> this table should only have one entry per patient (warning if not)

  fall_fe_table <- getFallFeData(
    lock_id = "statistical reports[5]",
    table_name = "v_fall_fe"
  ) |>
    CheckMissingFallIdInFallFe()

  # --> this table shows the trajectory of each case in the front-end system
  #     (multiple rows per case possible, if the case was treated on different INTERPOLAR wards)

  medikationsanalyse_fe_table <- getMedikationsanalyseFeData(
    lock_id = "statistical reports[6]",
    table_name = "v_medikationsanalyse_fe"
  ) |>
    CheckMissingFallMedaId() |>
    CheckMissingMedaDat()
  # --> this table should show only the last version of each medikationsanalyse_fe entry

  mrp_dokumentation_validierung_fe_table <- getMRPDokumentationValidierungFeData(
    lock_id = "statistical reports[7]",
    table_name = "v_mrpdokumentation_validierung_fe"
  )
  # --> this table should show only the last version of each mrp_dokumentation_validierung_fe entry

  FHIR_table <- mergePatEnc(patient_table, encounter_table) |>
    addCuratedEncPeriodEnd() |>
    addMainEncId() |>
    addMainEncPeriodStart() |>
    calculateAge() |>
    tagAmbulantEncounters() |>
    tagKontaktartDenotingNoInpatientEncounter()

  FHIR_table_with_ward_name_and_record_id <- FHIR_table |>
    addWardName(pids_per_ward_table) |>
    addRecordId(patient_fe_table) |>
    # addFallIdAndStudienphase(fall_fe_table) |>
    ExpandProcessingExclusionReasonToAllEncounterLevels()

  # full_analysis_set_1 <- defineFullAnalysisSet1(FHIR_table_with_ward_name_and_record_id)

  frontend_table <- mergePatFeFallFe(patient_fe_table, fall_fe_table) |>
    calculateAge(
      main_enc_period_start = fall_aufn_dat,
      pat_birthdate = pat_gebdat
    ) |>
    CheckMultipleRowsPerPatAndWardInMergedPatFallFe() |>
    detectMultipleEntries(
      grouping_vars = c("pat_id"),
      variable_to_check = fall_fhir_main_enc_id,
      result_variable_name = "multiple_main_encounters_per_patient"
    ) |>
    detectMultipleEntries(
      grouping_vars = c("pat_id", "fall_fhir_main_enc_id"),
      variable_to_check = fall_station,
      result_variable_name = "multiple_wards_per_main_encounter"
    ) |>
    addVersorgungsstellenkontaktToFeData(FHIR_table_with_ward_name_and_record_id) |>
    addMedaData(medikationsanalyse_fe_table) |>
    detectMultipleEntries(
      grouping_vars = c("pat_id"),
      variable_to_check = meda_id,
      result_variable_name = "multiple_medas_per_patient"
    ) |>
    addMRPDokuData(mrp_dokumentation_validierung_fe_table) |>
    dplyr::arrange(record_id, meda_dat, mrp_id)

  frontend_summary_data <- prepareFeSummaryData(
    frontend_table, REPORT_PERIOD_START,
    REPORT_PERIOD_END
  )

  # statistical_report_data <- prepareF1data(
  #   full_analysis_set_1, REPORT_PERIOD_START,
  #   REPORT_PERIOD_END
  # ) |>
  #   addFeDataToF1data(frontend_summary_data)

  # FAS2_1 <- defineFAS2_1(full_analysis_set_1, REPORT_PERIOD_END)
  # F2_data <- prepareF2data(FAS2_1, REPORT_PERIOD_START, REPORT_PERIOD_END)

  # if needed: Print datasets for verification to outputLocal
  if (WRITE_TABLE_LOCAL) {
    writeHtmlTable(patient_table)
    writeHtmlTable(encounter_table)
    writeHtmlTable(pids_per_ward_table)
    writeHtmlTable(FHIR_table_with_ward_name_and_record_id)
    # writeHtmlTable(full_analysis_set_1)
    # writeHtmlTable(statistical_report_data)
    writeHtmlTable(frontend_table)
    writeHtmlTable(frontend_summary_data)
  }


  frontend_summary <- calculateFeSummary(frontend_summary_data)

  # statistical_report <- calculateF1(statistical_report_data) |>
  #   calculateFeAddOnToF1(statistical_report_data)
  # calculateF2(F2_data)

  # print report to outputGlobal
  # writeHtmlTable(statistical_report,
  #   output_location = "global",
  #   caption = paste0("report for period: ", REPORT_PERIOD_START, " to ", REPORT_PERIOD_END),
  #   footnote = c(
  #     "F1: Cumulative number of hospitalized cases on INTERPOLAR wards
  #     (>18y, initial INTERPOLAR ward contact)",
  #     "Medication analysis and mrp counts:
  #     only for first medication analysis of initial INTERPOLAR ward contact for each case"
  #   ),
  #   colnames = c(
  #     "ward", "calendar week", "F1 (patients)", "F1 (patients also in frontend)",
  #     "F1 (encounters)", "F1 (encounters also in frontend)",
  #     "processing excluded F1 encounters", "medication analyses",
  #     "completed medication analyses", "MRP", "completed MRP documention",
  #     "resolved MRP", "MRP resolution not informative", "contra-indications",
  #     "class: drug-drug", "class: drug-disease", "class: drug-renal insufficiency",
  #     "processing excluded frontend encounters"
  #   )
  # )

  writeHtmlTable(frontend_summary,
    output_location = "global",
    caption = paste0(
      "Front-End Summary for period: ", REPORT_PERIOD_START, " to ",
      REPORT_PERIOD_END
    ),
    footnote = c("Medication analysis and mrp counts: for all documented medication analysis of all
                 INTERPOLAR ward contacts for each case"),
    colnames = c(
      "ward", "patients", "encounters", "medication analyses",
      "completed medication analyses", "MRP", "completed MRP documention",
      "resolved MRP", "MRP resolution not informative", "contra-indications",
      "class: drug-drug", "class: drug-disease", "class: drug-renal insufficiency",
      "excluded encounters (e.g. patient underage or linkage issues)"
    )
  )

}
