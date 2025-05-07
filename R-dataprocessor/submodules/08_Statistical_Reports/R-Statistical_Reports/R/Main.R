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
#' 1. Fetches patient data from the database using `getPatientData()`.
#' 2. Fetches encounter data from the database using `getEncounterData()`.
#' 3. Fetches data related to patients per ward using `getPidsPerWardData()`.
#' 4. Merges the patient, encounter, and ward data using `mergePatEnc()`, adds the main encounter ID
#'    using `addMainEncId()`, adds the main encounter period start using `addMainEncPeriodStart()`, and
#'    calculates patient age using `calculateAge()`.
#' 5. Defines the FAS1 dataset by filtering and processing the merged data using `defineFAS1()`,
#'    considering the provided reporting period (`REPORT_PERIOD_START` and `REPORT_PERIOD_END`).
#' 6. Prints the resulting datasets (`complete_table` and `FAS1`) for verification.
#' 7. Prints the reporting period and the number of cases in the FAS1 dataset.
#'
#' @seealso [getPatientData()], [getEncounterData()], [getPidsPerWardData()],
#'   [mergePatEnc()], [calculateAge()], [defineFAS1()], [addMainEncId()], [addMainEncPeriodStart()]
#' @export
createStatisticalReport <- function(REPORT_PERIOD_START ="2025-01-01",
                                    REPORT_PERIOD_END = "2025-04-30") {

  # TODO: include the start and end date in an interactive way ----------

  # TOASK: Sicherstellen, dass immer nur der aktuellste bzw. vollständigste Datensatz betrachtet wird -----
  # z.B. durch Auswahl eines anderen views oder durch Filterung der Datensätze über input_datetime
  # oder meta_last_updated?
  patient_table <- getPatientData(lock_id = "statistical reports[1]",
                                    table_name = "v_patient_last_version")
  # --> this table should only have one entry per patient (warning if not)

  encounter_table <- getEncounterData(lock_id = "statistical reports[2]",
                                        table_name = "v_encounter_last_version")
  # this table can have multiple rows per encounter
  # e.g. if there are entries for enc_location_physicaltype_code wa, ro & bd
          # ---------------------------------------------------------------------------#
          # DEBUG: test data with added enc_type_code "versorgungsstellenkontakt" -------
            # add one Versorgungsstellenkontakt to each abteilungskontakt starting 2 days later
            encounter_table <- encounter_table |>
              dplyr::filter(enc_type_code == "abteilungskontakt") |>
              dplyr::mutate(enc_partof_ref = paste0("Encounter/",enc_id),
                            enc_id = paste0(enc_id,"-V-1"),
                            enc_type_code = "versorgungsstellenkontakt",
                            enc_servicetype_system = NA_character_,
                            enc_servicetype_code = NA_character_,
                            enc_location_physicaltype_code = "wa",
                            enc_period_start = enc_period_start+172800) |>
              dplyr::bind_rows(encounter_table) |>
              dplyr::arrange(enc_patient_ref, enc_id, enc_period_start, enc_period_end, enc_status, input_datetime)
            # add one additional Versorgungsstellenkontakt to the last abteilungskontakt with same start date
            # and end date one day later
            encounter_table <- encounter_table |>
              dplyr::add_row(encounter_table |>
                               dplyr::slice_tail() |>
                               dplyr::mutate(enc_id = paste0(sub("^Encounter/", "", enc_partof_ref),"-V-0"),
                                             enc_period_start = enc_period_start-172800,
                                             enc_period_end = enc_period_start+86400) |>
                               dplyr::relocate(enc_period_start, .before = enc_period_end))
          # ---------------------------------------------------------------------------#

  pids_per_ward_table <- getPidsPerWardData(lock_id = "statistical reports[3]",
                                                table_name = "v_pids_per_ward")
  # this table can have multiple entries per main encounter due to transferral to another ward

          # ---------------------------------------------------------------------------#
          # DEBUG: test data with different wards in pids_per_ward table (patient transferral) -------
          # change the input datetime for the last and the added versorgungstellenkontakt
          pids_per_ward_table <- pids_per_ward_table |>
            dplyr::mutate(input_datetime = dplyr::if_else(
              dplyr::row_number() == nrow(pids_per_ward_table),
              encounter_table |>
                dplyr::slice_tail() |>
                dplyr::mutate(enc_period_end = enc_period_end+86400) |>
                dplyr::pull(enc_period_end),
              input_datetime)) |>
            dplyr::add_row(pids_per_ward_table |>
                             dplyr::slice_tail() |>
                             dplyr::mutate(ward_name = "Station X",
                                           input_datetime = encounter_table |>
                                             dplyr::slice_tail() |>
                                             dplyr::pull(enc_period_end)))
          # ---------------------------------------------------------------------------#

  complete_table <- mergePatEnc(patient_table, encounter_table) |>
    addMainEncId() |>
    addMainEncPeriodStart() |>
    calculateAge() |>
    addWardName(pids_per_ward_table)

  FAS1 <- defineFAS1(complete_table)

  F1 <- calculateF1(FAS1, REPORT_PERIOD_START, REPORT_PERIOD_END)

  FAS2_1 <- defineFAS2_1(FAS1,REPORT_PERIOD_START,REPORT_PERIOD_END)
  F2 <- calculateF2(FAS2_1, REPORT_PERIOD_START, REPORT_PERIOD_END)


  print(patient_table)
  print(encounter_table)
  print(pids_per_ward_table)

  # Print the patient, encounter, F1 and F2 datasets for verification
  print(data.table::as.data.table(complete_table))
  # print(data.table::as.data.table(FAS2_1))
  #
  # # Print the reporting period
  # print(paste0("Reporting period: ",REPORT_PERIOD_START, " - ", REPORT_PERIOD_END))
  #
  # # Print the number of cases in the F1 dataset
  #
  # print(F1 |>
  #         dplyr::distinct(main_enc_id,ward_name) |>
  #         dplyr::group_by(ward_name) |>
  #         dplyr::tally())
  #
  # print(paste0("Number of cases in F1: ",
  #              F1 |>
  #                dplyr::distinct(main_enc_id, ward_name) |>
  #                nrow()))
  #
  # # Print the number of cases in the F2 dataset
  #
  # print(F2 |>
  #         dplyr::distinct(main_enc_id,ward_name) |>
  #         dplyr::group_by(ward_name) |>
  #         dplyr::tally())
  #
  # print(paste0("Number of cases in F2: ",
  #              F2 |>
  #                dplyr::distinct(main_enc_id, ward_name) |>
  #                nrow()))

}
