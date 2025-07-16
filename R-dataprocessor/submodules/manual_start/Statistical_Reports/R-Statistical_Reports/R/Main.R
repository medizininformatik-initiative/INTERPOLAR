#' Create Statistical Report
#'
#' This function generates a statistical report by fetching and processing patient, encounter,
#' and ward data. It includes steps for merging the data, calculating the age of patients,
#' defining the FAS1 dataset, and verifying that the data meets specific criteria. The report
#' focuses on encounters and patients that meet certain conditions such as the presence of a ward,
#' patient age, and encounter type. The report also allows for customization of the start and end
#' date for the reporting period.
#'
#' @param REPORT_PERIOD_START A character string specifying the start date of the report period in "YYYY-MM-DD" format.
#' @param REPORT_PERIOD_END A character string specifying the end date of the report period in "YYYY-MM-DD" format.
#'
#' @return A statistical report that includes processed tables, such as the patient table, encounter table,
#'   the merged dataset, and calculation results within the specified reporting period.
#'
#' @details
#' The function performs the following steps:
#' 1. Fetches patient data from the database using `getPatientData()`.
#' 2. Fetches encounter data from the database using `getEncounterData()`.
#' 3. Fetches data related to patients per ward using `getPidsPerWardData()`.
#' 4. Fetches patient feature data using `getPatientFeData()`.
#' 5. Merges the patient, encounter, and ward data using `mergePatEnc()`, adds the main encounter ID
#'    using `addMainEncId()`, adds the main encounter period start using `addMainEncPeriodStart()`, and
#'    calculates patient age using `calculateAge()`, adds ward names using `addWardName()` and
#'    adds record IDs using `addRecordId()`.
#' 6. Defines the FAS1 dataset by filtering and processing the merged data using `defineFAS1()`,
#'    considering the provided reporting period (`REPORT_PERIOD_START` and `REPORT_PERIOD_END`).
#' 7. Calculates the F1 metric for the defined FAS1 dataset using `calculateF1()`, summarizing findings within the reporting period.
#' 8. Outputs tables in an HTML format for review, facilitating verification and analysis.
#'
#' @seealso [getPatientData()], [getEncounterData()], [getPidsPerWardData()],
#'   [mergePatEnc()], [calculateAge()], [defineFAS1()], [addMainEncId()], [addMainEncPeriodStart()],
#'   [calculateF1()]
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

  complete_table <- mergePatEnc(patient_table, encounter_table) |>
    addMainEncId() |>
    addMainEncPeriodStart() |>
    calculateAge() |>
    addWardName(pids_per_ward_table) |>
    addRecordId(patient_fe_table) |>
    addFallIdAndStudienphase(fall_fe_table)

  FAS1 <- defineFAS1(complete_table)

  F1 <- calculateF1(FAS1, REPORT_PERIOD_START, REPORT_PERIOD_END)

  # FAS2_1 <- defineFAS2_1(FAS1,REPORT_PERIOD_START,REPORT_PERIOD_END)
  # F2 <- calculateF2(FAS2_1, REPORT_PERIOD_START, REPORT_PERIOD_END)

  # Print the patient, encounter, F1 and F2 datasets for verification
  writeTableLocal(FAS1)
  writeTableGlobal(F1,
             caption = paste0("report for period: ",REPORT_PERIOD_START, " to ", REPORT_PERIOD_END, " <br>
                              F1: Cumulative number of hospitalized cases on INTERPOLAR wards (>18y, initial INTERPOLAR ward contact)"))

  writeTableLocal(fall_fe_table)

  #TODO: implement pdf / quarto option ----------
  # writeTable(complete_table, format = "pdf")
  #
}
