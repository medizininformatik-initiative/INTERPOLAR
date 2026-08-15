#' Create Statistical Report for INTERPOLAR Ward Metrics
#'
#' Generates a comprehensive statistical report for patients hospitalized on
#' INTERPOLAR wards, using patient, encounter, and front-end documentation
#' data within a defined reporting period. The report summarizes medication
#' analysis, MRP documentation, retrospective MRP assessment, and broad
#' consent information for internal monitoring and evaluation.
#'
#' By default, the reporting period starts at the earliest defined INTERPOLAR
#' ward start date and ends at the earlier of the latest defined INTERPOLAR
#' ward end date and the current date. REPORT_PERIOD_START and
#' REPORT_PERIOD_END can be set via command line arguments.
#'
#' @param REPORT_PERIOD_START Character string in "YYYY-MM-DD" format.
#' Start date of the reporting period. Defaults to the earliest start date
#' of the defined INTERPOLAR wards.
#' @param REPORT_PERIOD_END Character string in "YYYY-MM-DD" format.
#' End date of the reporting period. Defaults to the earlier of the latest
#' end date of the defined INTERPOLAR wards and Sys.Date().
#' @param WRITE_TABLE_LOCAL Logical. If TRUE, intermediate tables are
#' written to the local output folder.
#'
#' @return Invisibly returns NULL. This function is called for its side
#' effects: writing local and global summary tables and producing a
#' structured internal report.
#'
#' @details
#' The function performs the following main steps:
#'
#' \enumerate{
#' \item Determines the reporting period from the defined INTERPOLAR ward
#' phases, unless explicitly provided through the function arguments or command line arguments.
#'
#' \item Fetches source tables:
#' \itemize{
#' \item getPatientData() - one row per patient
#' \item getEncounterData() - multiple rows per encounter possible
#' \item getPidsPerWardData() - ward stays per sub-encounter
#' \item getPatientFeData() - one row per patient
#' \item getFallFeData() - one or more rows per case
#' \item getMedikationsanalyseFeData() - medication analysis entries
#' \item getMRPDokumentationValidierungFeData() - MRP documentation
#' \item getRetrolektiveMRPBewertungFeData() - retrospective MRP assessment entries
#' \item getConsentData() - consent information
#' }
#'
#' \item Constructs the core encounter-patient dataset:
#' \itemize{
#' \item mergePatEnc(), addCuratedEncPeriodEnd(), addMainEncId(), addMainEncPeriodStart()
#' \item calculateAge(), tagAmbulantEncounters(),tagKontaktartDenotingNoInpatientEncounter()
#' \item addWardName(), addRecordId()
#' }
#'
#' \item Restricts front-end data to defined INTERPOLAR wards and enriches
#' it with ward, encounter, and fall information:
#' \itemize{
#' \item mergePatFeFallFe()
#' \item restrictToDefinedWards()
#' \item addVersorgungsstellenkontaktToFeData()
#' }
#'
#' \item Merges and enriches front-end documentation:
#' \itemize{
#' \item addMedaData() - medication analysis data
#' \item addMRPDokuData() - MRP documentation data
#' \item addRetrolektiveMRPBewertungData() - retrospective MRP assessment data
#' \item addBroadConsentInformation() - broad consent information
#' }
#'
#' \item Prepares front-end summary data for the reporting period with prepareFeSummaryData().
#'
#' \item Calculates front-end summaries using both hospitalization dates and defined ward
#' stay boundaries. Weekly summaries are calculated for both approaches.
#'
#' \item Calculates front-end summaries for only the first ward stay and first medication analysis
#' per case, with weekly summaries.
#'
#' \item Writes the resulting summary tables to the global output as an
#' HTML report. If WRITE_TABLE_LOCAL is TRUE, intermediate datasets
#' are additionally written to the local output folder.
#' }
#'
#' The front-end processing distinguishes between different combinations of
#' multiple main encounters, multiple wards, and multiple medication analyses
#' to determine the most appropriate linkage of medication analyses and MRP
#' documentation. Entries that cannot be unambiguously linked are retained
#' where possible and annotated with processing exclusion reasons.
#'
#' @section Output:
#' - Local output: intermediate patient, encounter, ward, front-end, and
#' summary datasets when WRITE_TABLE_LOCAL is TRUE.
#' - Global output: an HTML report containing front-end summary tables
#' based on the reporting period and the defined INTERPOLAR ward periods.
#'
#' The global report includes overall and weekly summaries. The summaries
#' contain counts for patients, encounters, medication analyses, completed
#' medication analyses, MRP documentation, completed and resolved MRP
#' documentation, MRP resolution categories, contraindications, MRP classes,
#' and processing exclusions.
#'
#' @seealso
#' [getPatientData()], [getEncounterData()], [getPidsPerWardData()],
#' [getPatientFeData()], [getFallFeData()],
#' [getMedikationsanalyseFeData()],
#' [getMRPDokumentationValidierungFeData()],
#' [getRetrolektiveMRPBewertungFeData()], [getConsentData()],
#' [mergePatEnc()], [restrictToDefinedWards()],
#' [addVersorgungsstellenkontaktToFeData()], [addMedaData()],
#' [addMRPDokuData()], [addRetrolektiveMRPBewertungData()],
#' [addBroadConsentInformation()], [prepareFeSummaryData()],
#' [calculateFeSummary()], [writeHtmlTable()]
#' @export
createStatisticalReport <- function(REPORT_PERIOD_START = as.character(getFirstWardStart()),
                                    REPORT_PERIOD_END = as.character(min(getLastWardEnd(), Sys.Date())),
                                    WRITE_TABLE_LOCAL = FALSE) {
  # CONFIG LOCAL ANFANG--------------------------------------------------------------------
  # WRITE_TABLE_LOCAL <- TRUE
  # REPORT_PERIOD_END <- "2026-03-27"
  # CONFIG LOCAL ENDE---------------------------------------------------------------------

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

  print(getWardStartsAndEnds())

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
    # table_name = "v_patient_fe"
    table_name = "v_patient_fe_last_version"
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
    # table_name = "v_medikationsanalyse_fe"
    table_name = "v_medikationsanalyse_fe_last_version"
  ) |>
    CheckMissingFallMedaId() |>
    CheckMissingMedaDat()
  # --> this table should show only the last version of each medikationsanalyse_fe entry

  mrp_dokumentation_validierung_fe_table <- getMRPDokumentationValidierungFeData(
    lock_id = "statistical reports[7]",
    # table_name = "v_mrpdokumentation_validierung_fe"
    table_name = "v_mrpdokumentation_validierung_fe_last_version"
  )
  # --> this table should show only the last version of each mrp_dokumentation_validierung_fe entry

  retrolektive_mrpbewertung_fe_table <- getRetrolektiveMRPBewertungFeData(
    lock_id = "statistical reports[8]",
    table_name = "v_retrolektive_mrpbewertung_fe_last_version"
  )

  consent_table <- getConsentData(
    lock_id = "statistical reports[9]",
    table_name = "v_consent_last_version"
  )
  # TEST ANFANG--------------------------------------------------------------------
  # consent_table <- rbind(consent_table, data.frame(
  #   cons_patient_ref = "Patient/UKB-0001_1",
  #   cons_status = "active",
  #   cons_provision_provision_type = "permit",
  #   cons_provision_provision_code_system = "urn:oid:2.16.840.1.113883.3.1937.777.24.5.3",
  #   cons_provision_provision_code_code = "2.16.840.1.113883.3.1937.777.24.5.3.8",
  #   cons_provision_provision_period_start = as.POSIXct("2020-09-01"),
  #   cons_provision_provision_period_end = as.POSIXct("2026-08-31")
  # ))
  # TEST ENDE---------------------------------------------------------------------

  FHIR_table <- mergePatEnc(patient_table, encounter_table) |>
    addCuratedEncPeriodEnd() |>
    addMainEncId() |>
    # TODO: go on with detailed documentation from here (+add the new processing exclusion reason advancements in doku) -------
    addMainEncPeriodStart() |>
    calculateAge() |>
    tagAmbulantEncounters() |>
    tagKontaktartDenotingNoInpatientEncounter()

  FHIR_table_with_ward_name_and_record_id <- FHIR_table |>
    addWardName(pids_per_ward_table) |>
    addRecordId(patient_fe_table) |>
    # TODO: remove completely if not needed in this step -----------
    # addFallIdAndStudienphase(fall_fe_table) |>
    ExpandProcessingExclusionReasonToAllEncounterLevels()

  frontend_table <- mergePatFeFallFe(patient_fe_table, fall_fe_table) |>
    restrictToDefinedWards() |>
    calculateAge(
      main_enc_period_start = fall_aufn_dat,
      pat_birthdate = pat_gebdat
    ) |>
    CheckMultipleRowsPerMainEncAndWardInMergedPatFallFe() |>
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
    # TODO: check if this logic can be optimized (documented medas are deleted here if no matching enc_id is found!; same with MRP matching) ----------
    addMedaData(medikationsanalyse_fe_table) |>
    detectMultipleEntries(
      grouping_vars = c("pat_id"),
      variable_to_check = meda_id,
      result_variable_name = "multiple_medas_per_patient"
    ) |>
    addMRPDokuData(mrp_dokumentation_validierung_fe_table) |>
    addRetrolektiveMRPBewertungData(retrolektive_mrpbewertung_fe_table) |>
    addBroadConsentInformation(consent_table)

  # TEST ANFANG--------------------------------------------------------------------
  # change the actual_fall_studienphase to "PhaseB"
  # frontend_table <- frontend_table |>
  #   dplyr::mutate(actual_fall_studienphase = dplyr::case_when(
  #     fall_fhir_main_enc_id %in% head(unique(frontend_table$fall_fhir_main_enc_id), 30) ~ "PhaseB",
  #     TRUE ~ actual_fall_studienphase
  #   )) |>
  #   dplyr::mutate(fall_aufn_dat = dplyr::case_when(
  #     fall_fhir_main_enc_id %in% tail(unique(frontend_table$fall_fhir_main_enc_id), 2) ~ as.Date("2025-12-31"),
  #     TRUE ~ fall_aufn_dat
  #   ))
  # TEST ENDE---------------------------------------------------------------------

  frontend_summary_data <- prepareFeSummaryData(
    frontend_table, REPORT_PERIOD_START,
    REPORT_PERIOD_END,
    report_period_boundary = "hospital_stay",
    calendar_week_reference_date_col = fall_aufn_dat
  )

  frontend_summary_data_ward_stay_defined <- prepareFeSummaryData(
    frontend_table, REPORT_PERIOD_START,
    REPORT_PERIOD_END,
    report_period_boundary = "ward_stay",
    calendar_week_reference_date_col = first_enc_period_start_per_main_enc
  )

  frontend_summary_data_only_first_ward_stay_and_meda <- prepareFeSummaryData(
    frontend_table, REPORT_PERIOD_START,
    REPORT_PERIOD_END,
    report_period_boundary = "ward_stay",
    calendar_week_reference_date_col = first_enc_period_start_per_main_enc,
    first_ward_stay_and_meda_filter = TRUE
  )

  # statistical_report_data <- prepareF1data(
  #   full_analysis_set_1, REPORT_PERIOD_START,
  #   REPORT_PERIOD_END
  # ) |>
  #   addFeDataToF1data(frontend_summary_data)

  # if needed: Print datasets for verification to outputLocal
  if (WRITE_TABLE_LOCAL) {
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(patient_table)),
      pagename = "patient_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(encounter_table)),
      pagename = "encounter_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(pids_per_ward_table)),
      pagename = "pids_per_ward_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(FHIR_table_with_ward_name_and_record_id)),
      pagename = "FHIR_table_with_ward_name_and_record_id"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(patient_fe_table)),
      pagename = "patient_fe_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(fall_fe_table)),
      pagename = "fall_fe_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(medikationsanalyse_fe_table)),
      pagename = "medikationsanalyse_fe_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(mrp_dokumentation_validierung_fe_table)),
      pagename = "mrp_dokumentation_validierung_fe_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(retrolektive_mrpbewertung_fe_table)),
      pagename = "retrolektive_mrpbewertung_fe_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(consent_table)),
      pagename = "consent_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(frontend_table)),
      pagename = "frontend_table"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(frontend_summary_data)),
      pagename = "frontend_summary_data"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(frontend_summary_data_ward_stay_defined)),
      pagename = "frontend_summary_data_ward_stay_defined"
    )
    etlutils::writeHtmlPage(
      list(etlutils::buildHtmlTable(frontend_summary_data_only_first_ward_stay_and_meda)),
      pagename = "frontend_summary_data_only_first_ward_stay_and_meda"
    )
  }

  frontend_summary <- calculateFeSummary(frontend_summary_data)
  frontend_summary_weekly <- calculateFeSummary(
    frontend_summary_data,
    grouping_variables = c("ward_name", "calendar_week")
  )

  frontend_summary_ward_stay_defined <- calculateFeSummary(frontend_summary_data_ward_stay_defined)
  frontend_summary_weekly_ward_stay_defined <- calculateFeSummary(
    frontend_summary_data_ward_stay_defined,
    grouping_variables = c("ward_name", "calendar_week")
  )

  frontend_summary_only_first_ward_stay_and_meda <- calculateFeSummary(frontend_summary_data_only_first_ward_stay_and_meda)
  frontend_summary_weekly_only_first_ward_stay_and_meda <- calculateFeSummary(
    frontend_summary_data_only_first_ward_stay_and_meda,
    grouping_variables = c("ward_name", "calendar_week")
  )

  # statistical_report <- calculateF1(statistical_report_data) |>
  #   calculateFeAddOnToF1(statistical_report_data)
  # calculateF2(F2_data)

  # print report to outputGlobal
  # writeHtmlTable(
  #   statistical_report,
  #   output_location = "global",
  #   caption = paste0(
  #     "report for period: ", REPORT_PERIOD_START, " to ", REPORT_PERIOD_END),
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

  colnames_reporting_counts <- c(
    "patients",
    "censored patients (n < 5)",
    "consent given (MDAT wissenschaftlich nutzen)",
    "encounters",
    "processing excluded encounters (linkage issues)",
    "not meeting inclusion criteria (patient underage)",
    "encounters with completed medication analysis",
    "medication analyses",
    "completed medication analyses",
    "completed medication analyses with detected MRP",
    "encounters with completed MRP documentation",
    "MRP documented", "completed MRP documention",
    "resolved MRP", "MRP resolution not informative", "contra-indications",
    "class: drug-drug", "class: drug-disease", "class: drug-renal insufficiency",
    "class not assigned",
    "resolved contra-indications",
    "encounters eligible for algorithmic MRP",
    "encounters with algorithmic MRP",
    "encounters with non-confirmed non-incorrect data items MRP and consent",
    "algorithmic MRP found",
    "algorithmic class: drug-drug", "algorithmic class: drug-disease", "algorithmic class: drug-renal insufficiency",
    "completed algorithmic MRP evaluation",
    "evaluation: new and clinically relevant",
    "evaluation: already manually documented",
    "evaluation: no contraindication",
    "evaluation: based on incorrect data items",
    "evaluation: MRP concept unspecific",
    "evaluation: clinically irrelevant",
    "evaluation: always clinically irrelevant"
  )

  frontend_summary_html_table <- etlutils::buildHtmlTable(
    frontend_summary,
    filename_without_extension = paste0("frontend_summary_", format(Sys.Date(), "%Y%m%d")),
    caption = paste0(
      "Front-End Summary for period: ", REPORT_PERIOD_START, " to ",
      REPORT_PERIOD_END, " (hospitalizations from: ", getFirstCaseDateInFe(frontend_summary_data), " to ",
      getLastCaseDateInFe(frontend_summary_data), "; wards: ",
      paste0(
        getWardStartsAndEnds()$ward_name, " (", getWardStartsAndEnds()$ward_start, " to ",
        getWardStartsAndEnds()$ward_end, ")",
        collapse = "; "
      ), ")"
    ),
    footnote = c("Medication analysis and mrp counts: for all documented medication analysis of all
                 INTERPOLAR ward contacts for each case"),
    colnames = c("ward", colnames_reporting_counts)
  )

  frontend_summary_weekly_html_table <- etlutils::buildHtmlTable(
    frontend_summary_weekly,
    filename_without_extension = paste0("frontend_summary_weekly_", format(Sys.Date(), "%Y%m%d")),
    caption = paste0(
      "Weekly Front-End Summary for period: ", REPORT_PERIOD_START, " to ",
      REPORT_PERIOD_END, " (hospitalizations from: ", getFirstCaseDateInFe(frontend_summary_data), " to ",
      getLastCaseDateInFe(frontend_summary_data), "; wards: ",
      paste0(
        getWardStartsAndEnds()$ward_name, " (", getWardStartsAndEnds()$ward_start, " to ",
        getWardStartsAndEnds()$ward_end, ")",
        collapse = "; "
      ), ")"
    ),
    footnote = c("Medication analysis and mrp counts: for all documented medication analysis of all
                 INTERPOLAR ward contacts for each case"),
    colnames = c("ward", "calendar week", colnames_reporting_counts)
  )

  frontend_summary_html_table_ward_stay_defined <- etlutils::buildHtmlTable(
    frontend_summary_ward_stay_defined,
    filename_without_extension = paste0("frontend_summary_ward_stay_defined_", format(Sys.Date(), "%Y%m%d")),
    caption = paste0(
      "Ward-Stay defined Front-End Summary for period: ", REPORT_PERIOD_START, " to ",
      REPORT_PERIOD_END, " (hospitalizations from: ", getFirstCaseDateInFe(frontend_summary_data_ward_stay_defined), " to ",
      getLastCaseDateInFe(frontend_summary_data_ward_stay_defined), "; wards: ",
      paste0(
        getWardStartsAndEnds()$ward_name, " (", getWardStartsAndEnds()$ward_start, " to ",
        getWardStartsAndEnds()$ward_end, ")",
        collapse = "; "
      ), ")"
    ),
    footnote = c("Medication analysis and mrp counts: for all documented medication analysis of all
                 INTERPOLAR ward contacts for each case; inclusion in reporting period is defined by
                 the ward stay boundaries of each case"),
    colnames = c("ward", colnames_reporting_counts)
  )

  frontend_summary_weekly_html_table_ward_stay_defined <- etlutils::buildHtmlTable(
    frontend_summary_weekly_ward_stay_defined,
    filename_without_extension = paste0("frontend_summary_weekly_ward_stay_defined_", format(Sys.Date(), "%Y%m%d")),
    caption = paste0(
      "Weekly Ward-Stay defined Front-End Summary for period: ", REPORT_PERIOD_START, " to ",
      REPORT_PERIOD_END, " (hospitalizations from: ", getFirstCaseDateInFe(frontend_summary_data_ward_stay_defined), " to ",
      getLastCaseDateInFe(frontend_summary_data_ward_stay_defined), "; wards: ",
      paste0(
        getWardStartsAndEnds()$ward_name, " (", getWardStartsAndEnds()$ward_start, " to ",
        getWardStartsAndEnds()$ward_end, ")",
        collapse = "; "
      ), ")"
    ),
    footnote = c("Medication analysis and mrp counts: for all documented medication analysis of all
                 INTERPOLAR ward contacts for each case; inclusion in reporting period is defined by
                 the ward stay boundaries of each case"),
    colnames = c("ward", "calendar week", colnames_reporting_counts)
  )

  frontend_summary_html_table_only_first_ward_stay_and_meda <- etlutils::buildHtmlTable(
    frontend_summary_only_first_ward_stay_and_meda,
    filename_without_extension = paste0("frontend_summary_only_first_ward_stay_and_meda_", format(Sys.Date(), "%Y%m%d")),
    caption = paste0(
      "First Ward-Stay and Medication Analysis defined Front-End Summary for period: ", REPORT_PERIOD_START, " to ",
      REPORT_PERIOD_END, " (hospitalizations from: ", getFirstCaseDateInFe(frontend_summary_data_only_first_ward_stay_and_meda), " to ",
      getLastCaseDateInFe(frontend_summary_data_only_first_ward_stay_and_meda), "; wards: ",
      paste0(
        getWardStartsAndEnds()$ward_name, " (", getWardStartsAndEnds()$ward_start, " to ",
        getWardStartsAndEnds()$ward_end, ")",
        collapse = "; "
      ), ")"
    ),
    footnote = c("Medication analysis and mrp counts: for only the first documented medication analysis of the first
                 INTERPOLAR ward contact for each case; inclusion in reporting period is defined by
                 the ward stay boundaries of each case"),
    colnames = c("ward", colnames_reporting_counts)
  )

  frontend_summary_weekly_html_table_only_first_ward_stay_and_meda <- etlutils::buildHtmlTable(
    frontend_summary_weekly_only_first_ward_stay_and_meda,
    filename_without_extension = paste0("frontend_summary_weekly_only_first_ward_stay_and_meda_", format(Sys.Date(), "%Y%m%d")),
    caption = paste0(
      "Weekly First Ward-Stay and Medication Analysis defined Front-End Summary for period: ", REPORT_PERIOD_START, " to ",
      REPORT_PERIOD_END, " (hospitalizations from: ", getFirstCaseDateInFe(frontend_summary_data_only_first_ward_stay_and_meda), " to ",
      getLastCaseDateInFe(frontend_summary_data_only_first_ward_stay_and_meda), "; wards: ",
      paste0(
        getWardStartsAndEnds()$ward_name, " (", getWardStartsAndEnds()$ward_start, " to ",
        getWardStartsAndEnds()$ward_end, ")",
        collapse = "; "
      ), ")"
    ),
    footnote = c("Medication analysis and mrp counts: for only the first documented medication analysis of the first
                 INTERPOLAR ward contact for each case; inclusion in reporting period is defined by
                 the ward stay boundaries of each case"),
    colnames = c("ward", "calendar week", colnames_reporting_counts)
  )

  etlutils::writeHtmlPage(
    html_content_list = list(
      frontend_summary_html_table,
      frontend_summary_weekly_html_table,
      frontend_summary_html_table_ward_stay_defined,
      frontend_summary_weekly_html_table_ward_stay_defined,
      frontend_summary_html_table_only_first_ward_stay_and_meda,
      frontend_summary_weekly_html_table_only_first_ward_stay_and_meda
    ),
    output_location = "global",
    pagename = "INTERPOLAR-Reporting"
  )

  # TODO: evtl. implement separate script/enhanced data quality checks (raw & processed data) ----------
}
