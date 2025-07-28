#' Create Statistical Report for INTERPOLAR Ward Metrics
#'
#' This function orchestrates the creation of a comprehensive statistical report
#' by extracting, processing, and summarizing patient-, encounter-, and front-end-level data.
#' The report focuses on hospitalized patients in INTERPOLAR wards and computes
#' key metrics within a specified reporting period.
#'
#' @param REPORT_PERIOD_START Character string in `"YYYY-MM-DD"` format specifying the start date of the reporting period.
#' @param REPORT_PERIOD_END Character string in `"YYYY-MM-DD"` format specifying the end date of the reporting period. Defaults to `Sys.Date()`.
#'
#' @return Invisibly returns `NULL`. The function is used for its side effects:
#' writing summary tables to local/global output and producing structured
#' statistical reports for internal review.
#'
#' @details
#' This function performs the following steps:
#' \enumerate{
#'   \item Fetches patient, encounter, and ward-stay data via:
#'     \itemize{
#'       \item `getPatientData()`
#'       \item `getEncounterData()`
#'       \item `getPidsPerWardData()`
#'     }
#'   \item Retrieves front-end documentation from:
#'     \itemize{
#'       \item `getPatientFeData()`
#'       \item `getFallFeData()`
#'       \item `getMedikationsanalyseFeData()`
#'       \item `getMRPDokumentationValidierungFeData()`
#'     }
#'   \item Constructs a complete encounter-patient dataset using:
#'     \itemize{
#'       \item `mergePatEnc()`, `addMainEncId()`, `addMainEncPeriodStart()`,
#'       \item `calculateAge()`, `addWardName()`, `addRecordId()`, `addFallIdAndStudienphase()`
#'     }
#'   \item Merges front-end data into a comprehensive table via:
#'     \itemize{
#'       \item `mergePatFeFallFe()`, `addMedaData()`, `addEncIdToFeData()`, `addMRPDokuData()`
#'     }
#'   \item Defines FAS1 (base population) using `defineFAS1()`.
#'   \item Prepares F1 metrics via `prepareF1data()` and calculates stats with `calculateF1()`.
#'   \item Prepares and summarizes front-end documentation data via:
#'     \itemize{
#'       \item `prepareFeSummaryData()`
#'       \item `calculateFeSummary()`
#'     }
#'   \item Writes key intermediate and final results using:
#'     \itemize{
#'       \item `writeTableLocal()` (debugging, reproducibility)
#'       \item `writeTableGlobal()` (formal output)
#'     }
#' }
#'
#' @section Output:
#' - Writes intermediate datasets like `FAS1`, `F1_data`, `complete_fe_table`, and `fe_summary_data` to local output for traceability.
#' - Writes final tables such as `statistical_report` (F1 metrics) and `fe_summary` (Front-End summary) to global output with captions and footnotes.
#'
#' @note Additional analyses (e.g., F2 metrics) are scaffolded in the function but currently inactive. These may be enabled in future iterations.
#'
#' @seealso [getPatientData()], [getEncounterData()], [getPidsPerWardData()],
#'   [mergePatEnc()], [defineFAS1()], [prepareF1data()], [calculateF1()],
#'   [prepareFeSummaryData()], [calculateFeSummary()],
#'   [writeTableLocal()], [writeTableGlobal()]
#'
#' @export
createStatisticalReport <- function(REPORT_PERIOD_START ="2025-01-01",
                                    REPORT_PERIOD_END = Sys.Date()) {

  # TODO: include the start and end date in an interactive way ----------

  patient_table <- getPatientData(lock_id = "statistical reports[1]",
                                    table_name = "v_patient_last_version")
  # --> this table should only have one entry per patient (error if not)

  encounter_table <- getEncounterData(lock_id = "statistical reports[2]",
                                        table_name = "v_encounter_last_version")
  # this table can have multiple rows per encounter
  # e.g. if there are entries for enc_location_physicaltype_code wa, ro & bd

  pids_per_ward_table <- getPidsPerWardData(lock_id = "statistical reports[3]",
                                                table_name = "v_pids_per_ward")
  # this table can have multiple entries per main encounter due to transferral to another ward,
  # it should include the encounter level "Versorgungsstellenkontakt"

  # TODO: check if the appropriate views are used -------
  patient_fe_table <- getPatientFeData(lock_id = "statistical reports[4]",
                                  table_name = "v_patient_fe")
  # --> this table should only have one entry per patient (error if not)

  fall_fe_table <- getFallFeData(lock_id = "statistical reports[5]",
                                  table_name = "v_fall_fe")
  # --> this table shows the trajectory of each case in the front-end system (multiple rows per case possible)

  medikationsanalyse_fe_table <- getMedikationsanalyseFeData(lock_id = "statistical reports[6]",
                                  table_name = "v_medikationsanalyse_fe_last_import")
  # --> this table shows only the last version of each medikationsanalyse_fe entry

  mrp_dokumentation_validierung_fe_table <- getMRPDokumentationValidierungFeData(lock_id = "statistical reports[7]",
                                  table_name = "v_mrpdokumentation_validierung_fe_last_import")
  # --> this table shows only the last version of each mrp_dokumentation_validierung_fe entry

  complete_FHIR_table <- mergePatEnc(patient_table, encounter_table) |>
    addCuratedEncPeriodEnd() |>
    addMainEncId() |>
    addMainEncPeriodStart() |>
    calculateAge() |>
    addWardName(pids_per_ward_table) |>
    addRecordId(patient_fe_table) |>
    addFallIdAndStudienphase(fall_fe_table)

  complete_fe_table <-mergePatFeFallFe(patient_fe_table, fall_fe_table) |>
    addMedaData(medikationsanalyse_fe_table) |>
    addEncIdToFeData(complete_FHIR_table) |>
    addMRPDokuData(mrp_dokumentation_validierung_fe_table)

  FAS1 <- defineFAS1(complete_FHIR_table)
  F1_data <- prepareF1data(FAS1, REPORT_PERIOD_START, REPORT_PERIOD_END)
  fe_summary_data <- prepareFeSummaryData(complete_fe_table, REPORT_PERIOD_START, REPORT_PERIOD_END)

  # FAS2_1 <- defineFAS2_1(FAS1, REPORT_PERIOD_END)
  # F2_data <- prepareF2data(FAS2_1, REPORT_PERIOD_START, REPORT_PERIOD_END)

  # Print datasets for verification to outputLocal
  writeTableLocal(complete_FHIR_table)
  writeTableLocal(FAS1)
  writeTableLocal(F1_data)
  writeTableLocal(complete_fe_table)
  writeTableLocal(fe_summary_data)

  fe_summary <- calculateFeSummary(fe_summary_data)

  statistical_report <- calculateF1(F1_data) #|>
  # calculateF2(F2_data)

  # print report to outputGlobal
  writeTableGlobal(statistical_report,
             caption = paste0("report for period: ",REPORT_PERIOD_START, " to ", REPORT_PERIOD_END),
             footnote = "F1: Cumulative number of hospitalized cases on INTERPOLAR wards (>18y, initial INTERPOLAR ward contact)")

  writeTableGlobal(fe_summary,
             caption = paste0("Front-End Summary for period: ",REPORT_PERIOD_START, " to ", REPORT_PERIOD_END))

  #TODO: implement pdf / quarto option ----------
}
