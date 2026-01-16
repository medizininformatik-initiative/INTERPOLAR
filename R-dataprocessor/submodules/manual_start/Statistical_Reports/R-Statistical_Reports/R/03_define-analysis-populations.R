#' Define Full Analysis Set 1 (FAS1): Filter Adult Inpatient INTERPOLAR Encounters
#'
#' This function filters a dataset of encounters to define the Full Analysis Set 1 (FAS1) group,
#' consisting of inpatient encounters occurring in INTERPOLAR wards and involving adult patients.
#'
#' @param complete_table A data frame containing comprehensive encounter data. It must include the
#' following columns: `enc_type_code_Kontaktebene`, `enc_class_code`, `main_enc_id`, `ward_name`,
#' and `age_at_hospitalization`.
#'
#' @return A data frame representing the Full Analysis Set 1 (FAS1) group, including only those
#' inpatient encounters from INTERPOLAR wards involving patients aged 18 and over.
#'
#' @details
#' The function applies a series of filters to identify the Full Analysis Set 1 (FAS1) group:
#' - inpatient INTERPOLAR Encounters must be classified as defined in FRONTEND_DISPLAYED_ENCOUNTER_CLASS
#' - Encounters must have a non-missing `ward_name`, denoting an INTERPOLAR encounter obtainen
#'   from the Versorgungsstellenkontakte in the `pids_per_ward` table.
#' - Patients in these encounters must be adults, defined as individuals aged 18 or over
#'   (`age_at_hospitalization >= 18`).
#'
#'
#' @seealso
#' \code{\link[dplyr]{filter}}, \code{\link[dplyr]{mutate}}, \code{\link[dplyr]{select}},
#' \code{\link[dplyr]{distinct}}, \code{\link[data.table]{isoweek}}
#'
#' @importFrom dplyr filter pull mutate select distinct
#' @importFrom data.table isoweek
#' @export
# TODO: check each FHIR item for the possible values and include this into filtering --------

defineFullAnalysisSet1 <- function(complete_table) {
  inpatient_encounters <- complete_table |>
    dplyr::filter(enc_class_code %in% FRONTEND_DISPLAYED_ENCOUNTER_CLASS) |>
    dplyr::distinct(main_enc_id) |>
    dplyr::arrange(main_enc_id) |>
    dplyr::pull(main_enc_id)

  INTERPOLAR_encounters <- complete_table |>
    dplyr::filter(!is.na(ward_name)) |>
    dplyr::distinct(main_enc_id) |>
    dplyr::arrange(main_enc_id) |>
    dplyr::pull(main_enc_id)

  full_analysis_set_1_raw <- complete_table |>
    dplyr::filter(main_enc_id %in% inpatient_encounters) |> # only IMP patients
    dplyr::filter(main_enc_id %in% INTERPOLAR_encounters) |> # only encounters with any INTERPOLAR ward visit
    dplyr::filter(age_at_hospitalization >= 18) |> # only adults
    dplyr::distinct()

  full_analysis_set_1 <- full_analysis_set_1_raw |>
    dplyr::select(-c(
      enc_partof_calculated_ref, enc_class_code
    ))

  return(full_analysis_set_1)
}

#------------------------------------------------------------------------------#

# TODO: identify first interpolar ward contact and its proper lenght --------
# TODO: implement rules for combining short absences? -------
# TODO: include all patients with documented medication analysis within the first 7 days -------------
# TODO: handle NA end-dates properly (e.g. deceased) -------------

defineFAS2_1 <- function(full_analysis_set_1, report_period_end) {
  FAS2_1 <- full_analysis_set_1 |>
    dplyr::filter(dplyr::case_when(
      !is.na(enc_period_end) ~
        as.numeric(enc_period_end - enc_period_start) >= 7,
      is.na(enc_period_end) & enc_status == "in-progress" ~
        as.numeric(as.POSIXct(report_period_end) - enc_period_start) >= 7
    )) |>
    dplyr::distinct()

  return(FAS2_1)
}
