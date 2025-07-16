#' Create Statistical Report for INTERPOLAR Ward Metrics
#'
#' This function orchestrates the creation of a statistical report by extracting,
#' processing, and summarizing patient- and encounter-level data. The report focuses
#' on hospitalized patients in INTERPOLAR wards and computes key metrics within a
#' specified reporting period.
#'
#' @param REPORT_PERIOD_START Character string in `"YYYY-MM-DD"` format specifying the start date of the reporting period.
#' @param REPORT_PERIOD_END Character string in `"YYYY-MM-DD"` format specifying the end date of the reporting period.
#'
#' @return Invisibly returns `NULL`. The function is used for its side effects of writing tables to local/global output
#'   and producing a summarized statistical report for review.
#'
#' @details
#' This function performs the following steps:
#' \enumerate{
#'   \item Fetches patient data via `getPatientData()`.
#'   \item Fetches encounter data via `getEncounterData()`.
#'   \item Fetches ward-stay mappings via `getPidsPerWardData()`.
#'   \item Fetches patient front-end data via `getPatientFeData()`.
#'   \item Fetches case (fall) front-end data via `getFallFeData()`.
#'   \item Fetches medication analysis data via `getMedikationsanalyseFeData()`.
#'   \item Merges the datasets into a complete table using helper functions like:
#'     \itemize{
#'       \item `mergePatEnc()`
#'       \item `addMainEncId()`
#'       \item `addMainEncPeriodStart()`
#'       \item `calculateAge()`
#'       \item `addWardName()`
#'       \item `addRecordId()`
#'       \item `addFallIdAndStudienphase()`
#'     }
#'   \item Defines the FAS1 dataset by filtering relevant INTERPOLAR ward stays using `defineFAS1()`.
#'   \item Prepares and filters F1 data for the reporting period using `prepareF1data()`.
#'   \item Calculates summary statistics using `calculateF1()`, providing encounter and patient counts.
#'   \item Writes intermediate and final results using `writeTableLocal()` and `writeTableGlobal()`.
#' }
#'
#' @section Output:
#' - Intermediate data frames (e.g., `FAS1`, `F1_data`, `fall_fe_table`) are written to local output using `writeTableLocal()`.
#' - The final statistical summary is printed globally via `writeTableGlobal()` with metadata (caption and footnote).
#'
#' @note Additional metrics such as F2 are scaffolded but currently commented out. Future versions may include more detailed analyses.
#'
#' @seealso [getPatientData()], [getEncounterData()], [getPidsPerWardData()],
#'   [mergePatEnc()], [calculateAge()], [defineFAS1()], [prepareF1data()], [calculateF1()],
#'   [addMainEncId()], [addMainEncPeriodStart()], [writeTableLocal()], [writeTableGlobal()]
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

  patient_fe_table <- getPatientFeData(lock_id = "statistical reports[4]",
                                  table_name = "v_patient_fe")
  # --> this table should only have one entry per patient (error if not)

  fall_fe_table <- getFallFeData(lock_id = "statistical reports[5]",
                                  table_name = "v_fall_fe")
  # --> this table shows the trajectory of each case in the front-end system (multiple rows per case possible)

  medikationsanalyse_fe_table <- getMedikationsanalyseFeData(lock_id = "statistical reports[6]",
                                  table_name = "v_medikationsanalyse_fe_last_import")
  # --> this table shows only the last version of each medikationsanalyse_fe entry

  complete_table <- mergePatEnc(patient_table, encounter_table) |>
    addMainEncId() |>
    addMainEncPeriodStart() |>
    calculateAge() |>
    addWardName(pids_per_ward_table) |>
    addRecordId(patient_fe_table) |>
    addFallIdAndStudienphase(fall_fe_table)

  FAS1 <- defineFAS1(complete_table)
  F1_data <- prepareF1data(FAS1, REPORT_PERIOD_START, REPORT_PERIOD_END)

  # FAS2_1 <- defineFAS2_1(FAS1, REPORT_PERIOD_END)
  # F2_data <- prepareF2data(FAS2_1, REPORT_PERIOD_START, REPORT_PERIOD_END)

  # Print datasets for verification to outputLocal
  writeTableLocal(complete_table)
  writeTableLocal(F1_data)
  writeTableLocal(FAS1)
  writeTableLocal(fall_fe_table)
  writeTableLocal(medikationsanalyse_fe_table)

  statistical_report <- calculateF1(F1_data) #|>
  # calculateF2(F2_data)

  # print report to outputGlobal
  writeTableGlobal(statistical_report,
             caption = paste0("report for period: ",REPORT_PERIOD_START, " to ", REPORT_PERIOD_END),
             footnote = "F1: Cumulative number of hospitalized cases on INTERPOLAR wards (>18y, initial INTERPOLAR ward contact)")

  #TODO: implement pdf / quarto option ----------
}
