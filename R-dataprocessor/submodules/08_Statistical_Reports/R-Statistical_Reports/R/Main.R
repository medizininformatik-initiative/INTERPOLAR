#' Create Statistical Report
#'
#' This function generates a statistical report by fetching and processing patient, encounter,
#' and ward data. It includes steps for merging the data, calculating the age of patients,
#' defining the FAS1 dataset, and verifying that the data meets specific criteria. The report
#' focuses on encounters and patients that meet certain conditions such as the presence of a ward,
#' patient age, and encounter type. The report also allows for customization of the start and end
#' date for the reporting period.
#'
#' @param REPORT_PERIOD_START A character string specifying the start date of the report period.
#' @param REPORT_PERIOD_END A character string specifying the end date of the report period.
#'
#' @return A statistical report that includes the patient table, encounter table,
#'   merged table, and FAS1 dataset.
#'
#' @details
#' The function performs the following steps:
#' 1. Checks if `LOCATION_IDENTIFIER` is defined. If not, the function stops with an error message.
#' 2. Fetches patient data from the database using `getPatientData()`.
#' 3. Fetches encounter data from the database using `getEncounterData()`.
#' 4. Fetches data related to patients per ward using `getPidsPerWardData()`.
#' 5. Merges the patient, encounter, and ward data using `mergePatEnc()`, adds the main encounter ID
#'    using `addMainEncId()`, adds the main encounter period start using `addMainEncPeriodStart()`, and
#'    calculates patient age using `calculateAge()`.
#' 6. Defines the FAS1 dataset by filtering and processing the merged data using `defineFAS1()`,
#'    considering the provided reporting period (`REPORT_PERIOD_START` and `REPORT_PERIOD_END`).
#' 7. Prints the resulting datasets (`complete_table` and `FAS1`) for verification.
#' 8. Prints the reporting period and the number of cases in the FAS1 dataset.
#'
#' @seealso [getPatientData()], [getEncounterData()], [getPidsPerWardData()],
#'   [mergePatEnc()], [calculateAge()], [defineFAS1()], [addMainEncId()], [addMainEncPeriodStart()]
#' @export
createStatisticalReport <- function(REPORT_PERIOD_START ="2019-01-01",
                                    REPORT_PERIOD_END = "2025-03-05") {

  # TODO: include the start and end date in an interactive way ----------

  # Check if LOCATION_IDENTIFIER is defined (needed for mapping of the report to a site)
  if (!exists("LOCATION_IDENTIFIER")) {
    stop("LOCATION_IDENTIFIER is not defined. Please define it in the dataprocessor_config.toml")
  }

  patient_table <- getPatientData(lock_id = "statistical reports[1]",
                                    table_name = "v_patient")

  encounter_table <- getEncounterData(lock_id = "statistical reports[2]",
                                        table_name = "v_encounter")

  pids_per_ward_table <- getPidsPerWardData(lock_id = "statistical reports[3]",
                                                table_name = "v_pids_per_ward")

  complete_table <- mergePatEncWard(patient_table, encounter_table, pids_per_ward_table) |>
    addMainEncId() |>
    addMainEncPeriodStart() |>
    calculateAge()

  # DEBUG: for test reasons the start and end dates for abteilungskontakt -----------
  #        instead of versorgungsstellenkontakt are used

  FAS1 <- defineFAS1(complete_table,REPORT_PERIOD_START,REPORT_PERIOD_END)

  # Print the patient, encounter, and FAS1 datasets for verification
  print(complete_table, width = Inf)
  print(FAS1, width = Inf)

  # Print the reporting period
  print(paste0("Reporting period: ",REPORT_PERIOD_START, " - ", REPORT_PERIOD_END))

  # Print the number of cases in the FAS1 dataset

  print(FAS1 |>
          dplyr::distinct(enc_partof_ref,ward_name) |>
          dplyr::group_by(ward_name) |>
          dplyr::tally())

  print(paste0("Number of cases in FAS1: ",
               FAS1 |>
                 dplyr::distinct(enc_partof_ref, ward_name) |>
                 nrow()))

}
