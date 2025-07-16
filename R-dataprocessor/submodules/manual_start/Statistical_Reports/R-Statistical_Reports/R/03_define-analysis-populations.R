#' Define FAS1: Filter Adult Inpatient INTERPOLAR Encounters
#'
#' This function filters a dataset of encounters to define the FAS1 group, consisting of inpatient
#' encounters occurring in INTERPOLAR wards and involving adult patients.
#'
#' @param complete_table A data frame containing comprehensive encounter data. It must include the following columns:
#'   `enc_type_code`, `enc_class_code`, `main_enc_id`, `ward_name`, and `age_at_hospitalization`.
#'
#' @return A data frame representing the FAS1 group, including only those inpatient encounters from INTERPOLAR wards
#' involving patients aged 18 and over. The resulting dataset adds a `calendar_week` column and excludes irrelevant columns.
#'
#' @details
#' The function applies a series of filters to identify the FAS1 group:
#' - Encounters must be classified as inpatient (i.e., `enc_class_code` is "IMP") under facility contact (`enc_type_code` is "einrichtungskontakt").
#' - Encounters must have a non-missing `ward_name`, denoting an INTERPOLAR encounter obtained from the Versorgungsstellenkontakte in the `pids_per_ward` table.
#' - Patients in these encounters must be adults, defined as individuals aged 18 or over (`age_at_hospitalization >= 18`).
#'
#' The function also calculates and adds the `calendar_week` for the `enc_period_start` date and removes columns not essential to the FAS1 analysis.
#'
#' @seealso
#' \code{\link[dplyr]{filter}}, \code{\link[dplyr]{mutate}}, \code{\link[dplyr]{select}}, \code{\link[dplyr]{distinct}},
#' \code{\link[data.table]{isoweek}}
#'
#' @importFrom dplyr filter pull mutate select distinct
#' @importFrom data.table isoweek
#' @export
# TODO: check each FHIR item for the possible values and include this into filtering e.g. "Begleitperson" --------

defineFAS1 <- function(complete_table) {

  inpatient_encounters <- complete_table |>
    dplyr::filter(enc_type_code == "einrichtungskontakt" & enc_class_code == "IMP") |>
    dplyr::pull(main_enc_id)

  INTERPOLAR_encounters <- complete_table |>
    dplyr::filter(!is.na(ward_name)) |>
    dplyr::pull(main_enc_id)

  FAS1_raw <- complete_table |>
    dplyr::filter(main_enc_id %in% inpatient_encounters) |> # only IMP patients
    dplyr::filter(main_enc_id %in% INTERPOLAR_encounters) |> # only main encounters with any INTERPOLAR ward visit
    dplyr::filter(age_at_hospitalization >= 18) |> # only adults
    dplyr::mutate(calendar_week = data.table::isoweek(enc_period_start), .after = enc_period_start) |> # add calendar week
    dplyr::distinct()

  FAS1 <- FAS1_raw |>
    dplyr::select(-c(enc_partof_ref, enc_class_code, pat_birthdate, enc_class_system, enc_type_system,
                     enc_servicetype_system, enc_servicetype_code, enc_hospitalization_admitsource_system,
                     enc_hospitalization_admitsource_code, enc_hospitalization_dischargedisposition_system,
                     enc_hospitalization_dischargedisposition_code, enc_location_physicaltype_system,
                     enc_location_physicaltype_code, enc_serviceprovider_identifier_type_system,
                     enc_serviceprovider_identifier_type_code, enc_serviceprovider_identifier_system,
                     enc_serviceprovider_identifier_value))

  return(FAS1)
}

#------------------------------------------------------------------------------#

#' Define FAS2_1: Filter Long-Term or Ongoing Encounters
#'
#' This function filters the FAS1 group to define the FAS2_1 group. It includes encounters that have either
#' lasted at least 7 days or are ongoing with an assumed duration of at least 7 days since the report period start.
#'
#' @param FAS1 A data frame representing the FAS1 group, which includes inpatient, adult INTERPOLAR ward encounters.
#'   The data frame must include `enc_period_start`, `enc_period_end`, and `enc_status`.
#' @param REPORT_PERIOD_START A date object representing the start of the reporting period.
#' @param REPORT_PERIOD_END A date object representing the end of the reporting period.
#'
#' @return A data frame representing the FAS2_1 group. This includes encounters from FAS1
#' that lasted at least 7 days or ongoing encounters projected to last 7 days.
#'
#' @details
#' The function applies the following filtering criteria:
#' - Encounters with a non-missing `enc_period_end` should have a duration of 7 days or more.
#' - For ongoing encounters (`enc_status == "in-progress"`) with a missing `enc_period_end`,
#'   the expected duration is calculated from `enc_period_start` to `REPORT_PERIOD_END`, and
#'   only those projected to last 7 days or more are included.
#' - Ensures the output is distinct by removing duplicate records.
#'
#' Note: The function is designed to accommodate ongoing encounters by estimating their duration
#' based on the report period, reflecting hypothetical ongoing progress.
#'
#' @seealso
#' \code{\link[dplyr]{filter}}, \code{\link[dplyr]{case_when}}, \code{\link[dplyr]{distinct}}
#'
#' @export

# TODO: identify first interpolar ward contact and its lenght
# TODO: implement rules for combining short absences? -------
# TODO: include all patients with documented medication analysis within the first 7 days -------------
# TODO: handle NA end-dates properly (e.g. deceased) -------------

defineFAS2_1 <- function(FAS1,REPORT_PERIOD_START,REPORT_PERIOD_END) {
  FAS2_1 <- FAS1 |>
    dplyr::filter(dplyr::case_when(
      !is.na(enc_period_end) ~
        as.numeric(enc_period_end - enc_period_start) >= 7,
      is.na(enc_period_end) & enc_status == "in-progress" ~
        as.numeric(as.POSIXct(REPORT_PERIOD_END) - enc_period_start) >= 7)) |>
    dplyr::distinct()

  return(FAS2_1)
}


