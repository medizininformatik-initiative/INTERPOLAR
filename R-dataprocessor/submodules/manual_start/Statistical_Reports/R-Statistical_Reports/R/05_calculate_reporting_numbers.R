#' Calculate F1 Aggregates
#'
#' This function summarizes the prepared F1 dataset by computing counts of encounters and patients
#' grouped by ward and calendar week. It also computes overall totals across all wards and weeks.
#'
#' @param F1_prep A data frame or tibble as returned by `prepareF1data()`.
#' It must include the columns: `main_enc_id`, `fall_id_cis`, `pat_id`, `record_id`, `ward_name`,
#'                              `calendar_week` and `main_enc_any_processing_exclusion`.
#'
#' @return A tibble containing aggregated counts of F1-relevant metrics. The result includes:
#'   \item{`ward_name`}{Ward name or `"all"` for total counts.}
#'   \item{`calendar_week`}{Calendar week or `"all weeks"` for total counts.}
#'   \item{`F1_encounters`}{Number of distinct main encounters.}
#'   \item{`F1_encounters_also_in_fe`}{Number of main encounters matched in the front-end data
#'                                    (`fall_id_cis`).}
#'   \item{`F1_patients`}{Number of distinct patients.}
#'   \item{`F1_patients_also_in_fe`}{Number of patients matched in the front-end data (`record_id`).}
#'   \item{`F1_encounters_processing_exclusion`}{Number of encounters excluded due to processing
#'                                               criteria.}
#'
#' @details
#' The function excludes encounters marked by `main_enc_any_processing_exclusion` from counts.
#' The function performs two levels of aggregation:
#' \itemize{
#'   \item Grouped by `ward_name` and `calendar_week`.
#'   \item Total row for all and all calendar weeks.
#' }
#'
#' This helps in comparing study and front-end data coverage over time and location.
#'
#' @importFrom dplyr group_by summarise n_distinct bind_rows
#' @export
calculateF1 <- function(F1_prep) {
  F1_grouped_counts <- F1_prep |>
    dplyr::group_by(ward_name, calendar_week) |>
    dplyr::summarise(
      F1_patients = dplyr::n_distinct(
        pat_id[!main_enc_any_processing_exclusion],
        na.rm = TRUE
      ),
      F1_patients_also_in_fe = dplyr::n_distinct(
        record_id[!main_enc_any_processing_exclusion],
        na.rm = TRUE
      ),
      F1_encounters = dplyr::n_distinct(
        main_enc_id[!main_enc_any_processing_exclusion],
        na.rm = TRUE
      ),
      F1_encounters_also_in_fe = dplyr::n_distinct(
        fall_id_cis[!main_enc_any_processing_exclusion],
        na.rm = TRUE
      ),
      F1_encounters_processing_exclusion = dplyr::n_distinct(
        main_enc_id[main_enc_any_processing_exclusion],
        na.rm = TRUE
      ),
      .groups = "drop"
    )

  F1_total_counts <- F1_prep |>
    dplyr::summarise(
      ward_name = "all",
      calendar_week = "all",
      F1_patients = dplyr::n_distinct(
        pat_id[!main_enc_any_processing_exclusion],
        na.rm = TRUE
      ),
      F1_patients_also_in_fe = dplyr::n_distinct(
        record_id[!main_enc_any_processing_exclusion],
        na.rm = TRUE
      ),
      F1_encounters = dplyr::n_distinct(
        main_enc_id[!main_enc_any_processing_exclusion],
        na.rm = TRUE
      ),
      F1_encounters_also_in_fe = dplyr::n_distinct(
        fall_id_cis[!main_enc_any_processing_exclusion],
        na.rm = TRUE
      ),
      F1_encounters_processing_exclusion = dplyr::n_distinct(
        main_enc_id[main_enc_any_processing_exclusion],
        na.rm = TRUE
      )
    )

  F1 <- dplyr::bind_rows(F1_grouped_counts, F1_total_counts)

  return(F1)
}

#------------------------------------------------------------------------------#
#' Calculate Front-End Summary Metrics
#'
#' Summarizes front-end medication analysis and MRP documentation statistics by ward
#' and for all wards combined. Provides counts for patients, encounters, medication analyses,
#' and various MRP outcomes.
#'
#' @param frontend_summary_data A data frame prepared by `prepareFeSummaryData()` containing
#'   deduplicated front-end data with patient, encounter, ward, MRP-level variables and the
#'   `main_enc_any_processing_exclusion_fe`.
#'
#' @param grouping_variables A character vector specifying the variables to group by.
#'
#' @return A data frame with summarized counts per `ward_name`, including a row for `"all"`.
#'   The columns include:
#'   - `patients`: Number of distinct patients
#'   - `encounters`: Number of distinct hospital stays
#'   - `medication_analyses`: Total medication analyses
#'   - `medication_analyses_complete`: Analyses marked "Complete"
#'   - `MRP`: Total MRP entries
#'   - `MRP_documentation_complete`: MRP documentation completed
#'   - `MRP_resolved`: MRPs marked as resolved with intervention implemented
#'   - `MRP_resolution_non_informative`: MRPs with documentation but no clear resolution
#'   - `contraindications`: MRPs flagged as contraindications
#'   - `MRP_drug_drug`: Drug-drug interactions
#'   - `MRP_drug_disease`: Drug-disease interactions
#'   - `MRP_drug_renal_insufficiency`: Drug interactions with renal insufficiency
#'   - `encounters_processing_exclusion`: Encounters excluded due to processing criteria
#'
#' @details
#' - Summarization is grouped by `ward_name` derived from `ward_name`
#'  and `calendar_week` if available and given as input for grouping_variables.
#' - Uses `dplyr::n_distinct()` for robust unique counts
#' - Excludes encounters marked by `main_enc_any_processing_exclusion_fe` from counts
#'
#' @importFrom dplyr group_by summarise bind_rows n_distinct rename across all_of any_of if_else
#' @export
calculateFeSummary <- function(frontend_summary_data, grouping_variables = c("ward_name")) {
  fe_grouped_counts <- frontend_summary_data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_variables))) |>
    dplyr::summarise(
      patients = dplyr::n_distinct(
        pat_id[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      encounters = dplyr::n_distinct(
        main_enc_id[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      medication_analyses = dplyr::n_distinct(
        meda_id[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      medication_analyses_complete = dplyr::n_distinct(
        dplyr::if_else(
          medikationsanalyse_complete == "Complete", meda_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP = dplyr::n_distinct(
        mrp_id[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_documentation_complete = dplyr::n_distinct(
        dplyr::if_else(
          mrpdokumentation_validierung_complete == "Complete", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_resolved = dplyr::n_distinct(
        dplyr::if_else(
          mrp_dokup_hand_emp_akz == "Intervention vorgeschlagen und umgesetzt", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_resolution_non_informative = dplyr::n_distinct(
        dplyr::if_else(
          mrp_dokup_hand_emp_akz %in% c("Arzt / Pflege informiert", "Intervention vorgeschlagen,
                                        Umsetzung unbekannt"), mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      contraindications = dplyr::n_distinct(
        dplyr::if_else(
          Kontraindikation == "Checked", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_drug_drug = dplyr::n_distinct(
        dplyr::if_else(
          mrp_ip_klasse_01 == "Drug-Drug", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_drug_disease = dplyr::n_distinct(
        dplyr::if_else(
          mrp_ip_klasse_01 == "Drug-Disease", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_drug_renal_insufficiency = dplyr::n_distinct(
        dplyr::if_else(
          mrp_ip_klasse_01 == "Drug-Niereninsuffizienz", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      encounters_processing_exclusion = dplyr::n_distinct(
        main_enc_id[main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ), .groups = "drop"
    )

  fe_total_counts <- frontend_summary_data |>
    dplyr::summarise(
      dplyr::across(dplyr::any_of(c("ward_name", "calendar_week")), ~"all"),
      patients = dplyr::n_distinct(
        pat_id[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      encounters = dplyr::n_distinct(
        main_enc_id[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      medication_analyses = dplyr::n_distinct(
        meda_id[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      medication_analyses_complete = dplyr::n_distinct(
        dplyr::if_else(medikationsanalyse_complete == "Complete", meda_id, NA)[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP = dplyr::n_distinct(
        mrp_id[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ), MRP_documentation_complete = dplyr::n_distinct(
        dplyr::if_else(
          mrpdokumentation_validierung_complete == "Complete", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_resolved = dplyr::n_distinct(
        dplyr::if_else(
          mrp_dokup_hand_emp_akz == "Intervention vorgeschlagen und umgesetzt", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_resolution_non_informative = dplyr::n_distinct(
        dplyr::if_else(
          mrp_dokup_hand_emp_akz %in% c("Arzt / Pflege informiert", "Intervention vorgeschlagen,
                                        Umsetzung unbekannt"), mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      contraindications = dplyr::n_distinct(
        dplyr::if_else(
          Kontraindikation == "Checked", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_drug_drug = dplyr::n_distinct(
        dplyr::if_else(
          mrp_ip_klasse_01 == "Drug-Drug", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_drug_disease = dplyr::n_distinct(
        dplyr::if_else(
          mrp_ip_klasse_01 == "Drug-Disease", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      MRP_drug_renal_insufficiency = dplyr::n_distinct(
        dplyr::if_else(
          mrp_ip_klasse_01 == "Drug-Niereninsuffizienz", mrp_id, NA
        )[!main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      ),
      encounters_processing_exclusion = dplyr::n_distinct(
        main_enc_id[main_enc_any_processing_exclusion_fe],
        na.rm = TRUE
      )
    )

  frontend_summary <- dplyr::bind_rows(fe_grouped_counts, fe_total_counts)

  return(frontend_summary)
}

#------------------------------------------------------------------------------#

#' Add Front-End Summary Statistics to F1 Report
#'
#' Enriches the F1 statistical report with front-end documentation metrics
#' (e.g., medication analyses, MRP documentation) aggregated at the ward level.
#'
#' @param F1 A data frame containing the initial F1 report with patient and encounter-level metrics.
#' Typically produced by `calculateF1()`.
#' @param statistical_report_data_F1_with_fe A data frame containing individual-level data
#' enriched with front-end variables (from `addFeDataToF1data()`).
#'
#' @return A data frame that merges F1-level statistics with aggregated
#' front-end documentation summaries per ward and calendar week.
#'
#' @details
#' This function works in two steps:
#' \enumerate{
#'   \item Aggregates front-end documentation metrics using `calculateFeSummary()`.
#'   \item Merges the result into the existing F1 table via a left join, matching on:
#'     \itemize{
#'       \item `ward_name`
#'       \item `F1_patients` (from F1) = `patients` (from FE summary)
#'       \item `F1_encounters` (from F1) = `encounters` (from FE summary)
#'     }
#' }
#'
#' This enables reporting on the extent and completeness of front-end data
#' for each ward's F1 population.
#'
#' @seealso [calculateFeSummary()], [calculateF1()], [addFeDataToF1data()]
#'
#' @importFrom dplyr left_join
#' @export
calculateFeAddOnToF1 <- function(F1, statistical_report_data_F1_with_fe) {
  report_with_fe_prep <- statistical_report_data_F1_with_fe |>
    calculateFeSummary(grouping_variables = c("ward_name", "calendar_week"))

  report_with_fe <- F1 |>
    dplyr::left_join(report_with_fe_prep,
      by = c("ward_name",
        "calendar_week",
        "F1_patients" = "patients",
        "F1_encounters" = "encounters"
      )
    )
  return(report_with_fe)
}


# TODO: calculate F2 counts ------------------------------------------------------------
calculateF2 <- function(F2_prep) {
  return(F2)
}
