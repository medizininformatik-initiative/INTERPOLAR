#' Get First Case Date from Fall Front-End Data
#'
#' Determines the earliest documented case admission date in the fall front-end
#' dataset.
#'
#' @param frontend_summary_data A data frame containing fall front-end documentation data.
#'   The table must include a `fall_aufn_dat` column representing the case
#'   admission date.
#'
#' @return A `Date` value representing the earliest non-missing `fall_aufn_dat`
#'   in the provided table.
#'
#' @details
#' The function filters the input table to remove rows with missing
#' `fall_aufn_dat` values and then calculates the minimum admission date using
#' `min(..., na.rm = TRUE)`. The resulting value is returned as a single scalar.
#'
#' @importFrom dplyr filter summarise pull
#'
#' @export
getFirstCaseDateInFe <- function(frontend_summary_data) {
  first_case_date_in_fe <- frontend_summary_data |>
    dplyr::filter(!is.na(fall_aufn_dat)) |>
    dplyr::summarise(first_case_date = min(fall_aufn_dat, na.rm = TRUE)) |>
    dplyr::pull(first_case_date) |>
    as.Date()
  return(first_case_date_in_fe)
}

#' Get Last Case Date from Fall Front-End Data
#'
#' Determines the most recent documented case admission date in the fall
#' front-end dataset.
#'
#' @param frontend_summary_data A data frame containing fall front-end documentation
#'   data. The table must include a `fall_aufn_dat` column representing the
#'   case admission date.
#'
#' @return A `Date` value representing the latest non-missing `fall_aufn_dat`
#'   in the provided table.
#'
#' @details
#' The function filters the input table to remove rows with missing
#' `fall_aufn_dat` values and then calculates the maximum admission date using
#' `max(..., na.rm = TRUE)`. The resulting value is extracted and converted to
#' `Date` before being returned as a single scalar.
#'
#' @importFrom dplyr filter summarise pull
#'
#' @export
getLastCaseDateInFe <- function(frontend_summary_data) {
  last_case_date_in_fe <- frontend_summary_data |>
    dplyr::filter(!is.na(fall_aufn_dat)) |>
    dplyr::summarise(last_case_date = max(fall_aufn_dat, na.rm = TRUE)) |>
    dplyr::pull(last_case_date) |>
    as.Date()
  return(last_case_date_in_fe)
}

#' Get Earliest Start Date of Defined INTERPOLAR Wards
#'
#' Determines the earliest start date among all INTERPOLAR wards defined via
#' global environment variables.
#'
#' @return A `Date` value representing the earliest start date found in the
#'   ward phase definitions.
#'
#' @details
#' The function searches the global environment for objects matching the
#' pattern `"^PHASES_WARD_"`. For each matching object, it checks whether the
#' definition is available and non-empty using `etlutils::isDefinedAndNotEmpty()`.
#'
#' The start date is extracted from the second element of each valid ward
#' definition and parsed using `stringr::str_split_i()`. All extracted dates
#' are converted to `Date` format, and the earliest date is returned.
#'
#' @importFrom etlutils isDefinedAndNotEmpty
#' @importFrom stringr str_split_i
#'
#' @export
getFirstWardStart <- function() {
  interpolar_wards_definition <- ls(pattern = "^PHASES_WARD_", envir = .GlobalEnv)
  interpolar_ward_starts <- c()
  for (i in seq_along(interpolar_wards_definition)) {
    ward_phase_defintion <- interpolar_wards_definition[i]
    if (etlutils::isDefinedAndNotEmpty(ward_phase_defintion)) {
      ward_start <- get(ward_phase_defintion, envir = .GlobalEnv)[2] |>
        stringr::str_split_i("'", 2)
      interpolar_ward_starts <- c(interpolar_ward_starts, ward_start)
    }
  }
  minimum_start_date <- min(as.Date(interpolar_ward_starts), na.rm = TRUE)

  return(minimum_start_date)
}

#' Get INTERPOLAR Ward Start and End Dates
#'
#' Creates a data frame containing the configured start and end dates for
#' each defined INTERPOLAR ward.
#'
#' @return A data frame with one row per defined INTERPOLAR ward and the
#'   following columns:
#'   \itemize{
#'     \item `ward_name`: Name of the INTERPOLAR ward.
#'     \item `ward_start`: Start date of the ward phase as a `Date`.
#'     \item `ward_end`: End date of the ward phase as a `Date`.
#'   }
#'
#' @details
#' The function searches the global environment for objects matching the
#' pattern `"^PHASES_WARD_"`. For each defined and non-empty ward phase
#' definition, the ward name, start date, and end date are extracted from
#' the corresponding definition.
#'
#' The extracted start and end dates are converted to `Date` objects and
#' combined with the ward names into a data frame.
#'
#' @importFrom etlutils isDefinedAndNotEmpty
#' @importFrom stringr str_split_i
#'
#' @export
getWardStartsAndEnds <- function() {
  interpolar_wards_definition <- ls(pattern = "^PHASES_WARD_", envir = .GlobalEnv)
  interpolar_ward_names <- c()
  interpolar_ward_starts <- c()
  interpolar_ward_ends <- c()
  for (i in seq_along(interpolar_wards_definition)) {
    ward_phase_defintion <- interpolar_wards_definition[i]
    if (etlutils::isDefinedAndNotEmpty(ward_phase_defintion)) {
      ward_start <- get(ward_phase_defintion, envir = .GlobalEnv)[2] |>
        stringr::str_split_i("'", 2)
      interpolar_ward_starts <- c(interpolar_ward_starts, ward_start)
      ward_end <- get(ward_phase_defintion, envir = .GlobalEnv)[4] |>
        stringr::str_split_i("'", 2)
      interpolar_ward_ends <- c(interpolar_ward_ends, ward_end)
      ward_name_i <- get(ward_phase_defintion, envir = .GlobalEnv)[1] |>
        stringr::str_split_i("'", 2)
      interpolar_ward_names <- c(interpolar_ward_names, ward_name_i)
    }
  }
  interpolar_wards_start_end_data <- data.frame(
    ward_name = interpolar_ward_names,
    ward_start = as.Date(interpolar_ward_starts),
    ward_end = as.Date(interpolar_ward_ends)
  )

  return(interpolar_wards_start_end_data)
}

#' Merge INTERPOLAR Ward Start and End Dates
#'
#' Adds the configured start and end dates of each INTERPOLAR ward to a
#' data frame based on the ward name.
#'
#' @param data A data frame containing a column identifying the ward.
#' @param ward_name_col Column in `data` containing the ward names. Defaults
#'   to `ward_name`.
#'
#' @return A data frame containing the original data enriched with
#'   `ward_start` and `ward_end` columns containing the configured start
#'   and end dates for each matching INTERPOLAR ward.
#'
#' @details
#' The function searches the global environment for objects matching the
#' pattern `"^PHASES_WARD_"`. For each defined and non-empty ward phase
#' definition, the ward name, start date, and end date are extracted.
#'
#' A lookup table containing the ward names and corresponding start and end
#' dates is constructed and joined to `data` using the column specified by
#' `ward_name_col`. The extracted dates are converted to `Date` objects
#' before the join.
#'
#' @importFrom dplyr left_join
#' @importFrom etlutils isDefinedAndNotEmpty
#' @importFrom stringr str_split_i
#' @export
mergeWardStartsAndEnds <- function(data, ward_name_col = ward_name) {
  interpolar_wards_definition <- ls(pattern = "^PHASES_WARD_", envir = .GlobalEnv)
  interpolar_ward_names <- c()
  interpolar_ward_starts <- c()
  interpolar_ward_ends <- c()
  for (i in seq_along(interpolar_wards_definition)) {
    ward_phase_defintion <- interpolar_wards_definition[i]
    if (etlutils::isDefinedAndNotEmpty(ward_phase_defintion)) {
      ward_start <- get(ward_phase_defintion, envir = .GlobalEnv)[2] |>
        stringr::str_split_i("'", 2)
      interpolar_ward_starts <- c(interpolar_ward_starts, ward_start)
      ward_end <- get(ward_phase_defintion, envir = .GlobalEnv)[4] |>
        stringr::str_split_i("'", 2)
      interpolar_ward_ends <- c(interpolar_ward_ends, ward_end)
      ward_name_i <- get(ward_phase_defintion, envir = .GlobalEnv)[1] |>
        stringr::str_split_i("'", 2)
      interpolar_ward_names <- c(interpolar_ward_names, ward_name_i)
    }
  }
  interpolar_wards_start_end_data <- data.frame(
    ward_name = interpolar_ward_names,
    ward_start = as.Date(interpolar_ward_starts),
    ward_end = as.Date(interpolar_ward_ends)
  )

  data <- data |>
    dplyr::left_join(
      interpolar_wards_start_end_data,
      by = setNames("ward_name", deparse(substitute(ward_name_col)))
    )

  return(data)
}

#' Get Latest End Date of Defined INTERPOLAR Wards
#'
#' Determines the latest end date among all INTERPOLAR wards defined via
#' global environment variables.
#'
#' @return A `Date` value representing the latest end date found in the
#'   ward phase definitions.
#'
#' @details
#' The function searches the global environment for objects matching the
#' pattern `"^PHASES_WARD_"`. For each matching object, it checks whether
#' the definition is available and non-empty using
#' `etlutils::isDefinedAndNotEmpty()`.
#'
#' The end date is extracted from the fourth element of each valid ward
#' definition and parsed using `stringr::str_split_i()`. All extracted
#' dates are converted to `Date` format, and the latest date is returned.
#'
#' @importFrom etlutils isDefinedAndNotEmpty
#' @importFrom stringr str_split_i
#'
#' @export
getLastWardEnd <- function() {
  interpolar_wards_definition <- ls(pattern = "^PHASES_WARD_", envir = .GlobalEnv)
  interpolar_ward_ends <- c()
  for (i in seq_along(interpolar_wards_definition)) {
    ward_phase_defintion <- interpolar_wards_definition[i]
    if (etlutils::isDefinedAndNotEmpty(ward_phase_defintion)) {
      ward_end <- get(ward_phase_defintion, envir = .GlobalEnv)[4] |>
        stringr::str_split_i("'", 2)
      interpolar_ward_ends <- c(interpolar_ward_ends, ward_end)
    }
  }
  maximum_end_date <- max(as.Date(interpolar_ward_ends), na.rm = TRUE)

  return(maximum_end_date)
}

#' Add Calendar Week to a Data Frame
#'
#' Adds an ISO calendar week column to a data frame based on a
#' reference date column. The resulting calendar_week column is
#' formatted as "YYYY-WW", where YYYY is the ISO year and WW
#' is the zero-padded ISO week number.
#'
#' The new column is inserted immediately after the reference date
#' column. The reference date column is supplied using tidy evaluation,
#' so it should be passed as an unquoted column name.
#'
#' @param data A data frame containing the reference date column.
#' @param reference_date_col A date or date-time column used to
#' determine the ISO calendar year and week. The column should be
#' supplied without quotation marks.
#'
#' @return A data frame containing all columns from data and an
#' additional calendar_week column formatted as "YYYY-WW".
#'
#' @importFrom dplyr mutate
#' @importFrom data.table isoyear isoweek
#'
#' @seealso [data.table::isoyear()], [data.table::isoweek()], [dplyr::mutate()]
#' @export
addCalendarWeek <- function(data, reference_date_col) {
  data_with_calendar_week <- data |>
    dplyr::mutate(
      calendar_week = paste0(
        data.table::isoyear({{ reference_date_col }}), "-",
        sprintf("%02d", data.table::isoweek({{ reference_date_col }}))
      ),
      .after = {{ reference_date_col }}
    )
  return(data_with_calendar_week)
}

#' Add First Encounter Period Start per Main Encounter
#'
#' Adds the first encounter period start to each observation belonging
#' to the same combination of grouping variables.
#'
#' The function excludes observations with missing grouping variables
#' when calculating the first encounter period start. For each remaining
#' group, the earliest non-missing value of `time_var` is determined. If
#' all values of `time_var` within a group are missing, the resulting
#' value is `NA`. The calculated values are then joined back to the
#' original data, preserving observations with missing grouping variables.
#'
#' @param data A data frame containing encounter period information.
#' @param grouping_vars A character vector specifying the variables used
#'   to define groups. Defaults to `c("pat_id", "main_enc_id")`.
#' @param time_var A date or date-time column used to determine the first
#'   encounter period start. The column should be supplied unquoted.
#'
#' @return A data frame containing the original columns and an additional
#'   `first_enc_period_start_per_main_enc` column, positioned immediately
#'   after `time_var`.
#'
#' @importFrom dplyr all_of
#' @importFrom dplyr across
#' @importFrom dplyr filter
#' @importFrom dplyr if_any
#' @importFrom dplyr left_join
#' @importFrom dplyr relocate
#' @importFrom dplyr summarise
#' @importFrom dplyr group_by
#'
#' @export
addFirstEncPeriodStartPerMainEnc <- function(
  data,
  grouping_vars = c("pat_id", "main_enc_id"),
  time_var = enc_period_start
) {
  first_dates <- data |>
    dplyr::filter(!dplyr::if_any(dplyr::all_of(grouping_vars), is.na)) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_vars))) |>
    dplyr::summarise(
      first_enc_period_start_per_main_enc =
        if (all(is.na({{ time_var }}))) {
          {{ time_var }}[NA_integer_]
        } else {
          min({{ time_var }}, na.rm = TRUE)
        },
      .groups = "drop"
    )

  data |>
    dplyr::left_join(first_dates, by = grouping_vars) |>
    dplyr::relocate(first_enc_period_start_per_main_enc, .after = {{ time_var }})
}

#' Calculate Ward Stay Period
#'
#' Calculates the duration of a ward stay based on the difference between
#' encounter period end and start timestamps.
#'
#' The resulting ward stay duration is calculated in days and added as a new
#' column named `ward_stay_period`.
#'
#' @param frontend_table A data frame containing encounter period start and
#'   end information.
#'
#' @return A data frame containing the original data and an additional
#'   `ward_stay_period` column representing the ward stay duration in days.
#'
#' @importFrom dplyr mutate
#'
#' @export
calculateWardStayPeriod <- function(frontend_table) {
  frontend_table_with_ward_stay <- frontend_table |>
    dplyr::mutate(ward_stay_period = curated_enc_period_end - enc_period_start) |>
    dplyr::mutate(ward_stay_period = as.numeric(ward_stay_period, units = "days")) |>
    dplyr::relocate(ward_stay_period, .after = curated_enc_period_end)
}

#' Merge Patient and Encounter Data
#'
#' This function merges patient-level data with encounter-level data into a unified dataset.
#' It extracts the patient ID from the `enc_patient_ref` column in the encounter data and
#' then joins the patient details using that ID.
#'
#' @param patient_table A data frame containing patient information, including at least:
#'   - `pat_id`: FHIR patient ID
#'   - Additional patient attributes such as birthdate
#' @param encounter_table A data frame containing encounter information, including at least:
#'   - `enc_patient_ref`: A reference to the patient (format: "Patient/<pat_id>")
#'   - Other encounter attributes such as `enc_id`, `enc_type_code_Kontaktebene`, etc.
#'
#' @return A data frame that merges the encounter data with patient data, based on the extracted
#' patient ID. The resulting table includes all columns from both input tables.
#'
#' @details
#' The function performs the following steps:
#' 1. Extracts the `pat_id` from the `enc_patient_ref` string in the `encounter_table`.
#' 2. Performs a left join between the encounter table and the patient table using `pat_id` as the key.
#'
#' This merged dataset is used for further filtering, enrichment, or analysis involving both patient
#' and encounter context.
#'
#' @importFrom dplyr mutate left_join select relocate
#' @export

mergePatEnc <- function(patient_table, encounter_table) {
  merged_table <- encounter_table |>
    dplyr::mutate(pat_id = sub("^Patient/", "", enc_patient_ref), .keep = "unused") |>
    dplyr::left_join(
      patient_table |>
        dplyr::select(c(pat_id, pat_birthdate)) |>
        dplyr::distinct(),
      by = "pat_id"
    ) |>
    dplyr::relocate(
      enc_identifier_value,
      pat_id,
      enc_partof_calculated_ref,
      enc_class_code,
      enc_type_code_Kontaktebene,
      enc_type_code_Kontaktart,
      pat_birthdate,
      enc_period_start,
      enc_period_end,
      enc_status,
      .after = enc_id
    )
  return(merged_table)
}

#------------------------------------------------------------------------------#
#' Add Curated Encounter End Date
#'
#' This function adds a new column `curated_enc_period_end` to the encounter table,
#' handling missing (`NA`) end dates for ongoing hospital stays. If the encounter
#' is marked as `"in-progress"` and has no `enc_period_end`, the current system
#' date is inserted to allow downstream time-based operations.
#'
#' @param encounter_table A data frame containing encounter-level data, with columns
#'   `enc_period_end` and `enc_status`.
#'
#' @return A data frame identical to `encounter_table` with an added column
#'   `curated_enc_period_end`, located immediately after `enc_period_end`.
#'
#' @details
#' The function is especially useful for ensuring valid time intervals in joins
#' or filters where open-ended encounters (i.e., missing `enc_period_end`)
#' would otherwise break logic or be excluded.
#'
#' - If `enc_period_end` is `NA` and `enc_status` is `"in-progress"`, then
#'   `curated_enc_period_end` is set to the current system date (`Sys.Date()`).
#' - If `enc_period_end` is `NA` and `enc_status` is `"onleave"`, then
#'  `curated_enc_period_end` is set to `enc_period_start`.
#' - Otherwise, `curated_enc_period_end` takes the value of `enc_period_end`.
#'
#' If any `curated_enc_period_end` values remain `NA` after this process,
#' a warning is issued and those rows are printed for review. The function also
#' updates the `processing_exclusion_reason` column to indicate the presence of
#' `NA` values in `curated_enc_period_end`: "NA_in_curated_enc_period_end".
#'
#' @importFrom dplyr mutate case_when relocate
#' @export
addCuratedEncPeriodEnd <- function(encounter_table) {
  encounter_table_with_curated_enc_period_end <- encounter_table |>
    dplyr::mutate(curated_enc_period_end = dplyr::case_when(
      is.na(enc_period_end) & enc_status == "in-progress" ~ Sys.time(),
      is.na(enc_period_end) & enc_status == "onleave" ~ enc_period_start,
      TRUE ~ enc_period_end
    )) |>
    dplyr::relocate(curated_enc_period_end, .after = enc_period_end)

  if (any(is.na(encounter_table_with_curated_enc_period_end$curated_enc_period_end))) {
    encounter_table_with_curated_enc_period_end <- encounter_table_with_curated_enc_period_end |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(curated_enc_period_end),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "NA_in_curated_enc_period_end",
          level = "sub_encounter",
          type = "data_issues"
        ),
        processing_exclusion_reason
      ))
    print(
      encounter_table_with_curated_enc_period_end |>
        dplyr::filter(is.na(curated_enc_period_end)),
      width = 1000
    )
    warning("There are NA values in curated_enc_period_end. Please check the data.")
  }
  return(encounter_table_with_curated_enc_period_end)
}

#------------------------------------------------------------------------------#

#' Add Main Encounter ID to Encounter Table
#'
#' This function adds a new column `main_enc_id` to the encounter table, identifying
#' the top-level inpatient encounter (e.g., a facility-level "einrichtungskontakt" encounter)
#' for each record. It determines the main encounter by walking up the encounter hierarchy
#' based on encounter type and `enc_partof_calculated_ref` relationships. If part-of references are not
#' available, it uses the unique`enc_identifier_value` to identify top-level encounters.
#' Update: The function now also uses the pre-calculated `enc_main_encounter_calculated_ref` column
#' from the cds-toolchain to determine the main encounter ID, falling back to the original logic if necessary.
#'
#' @param encounter_table A data frame or tibble containing FHIR-based encounter data.
#'   Must include the following columns:
#'   - `enc_id`: Unique identifier of the encounter.
#'   - `enc_partof_calculated_ref`: Reference to the parent encounter (e.g., "Encounter/123").
#'   - `enc_type_code_Kontaktebene`: Type of the encounter (e.g., "einrichtungskontakt",
#'                                   "abteilungskontakt", "versorgungsstellenkontakt").
#'   - `enc_class_code`: Class of the encounter (e.g., "IMP" for inpatient).
#'   - `enc_identifier_value`: Identifier value for the encounter, used to identify top-level
#'                             encounters.
#'
#' @return A data frame or tibble identical to the input but with an additional column:
#'   - `main_enc_id`: The ID of the top-level (main) encounter associated with each record.
#'     For top-level encounters themselves, this is simply their own `enc_id`.
#'
#' @details
#' The main encounter ID is determined using the following logic:
#' 1. If the encounter has no parent (`enc_partof_calculated_ref` is `NA`), is of type `"einrichtungskontakt"`,
#' it is considered a top-level encounter, and its own `enc_id` is used.
#' 2. If the encounter is of type `"abteilungskontakt"` (departmental contact), its parent is
#'    assumed to be the main encounter.
#' 3. If the encounter is of type `"versorgungsstellenkontakt"` (sub-departmental contact), the
#'    function extracts the parent encounter's `enc_id`, finds its parent, and uses that as the
#'    top-level `main_enc_id`.
#' The function also handles cases where encounters may not have a parent reference but have a
#' unique identifier value. The function also checks for the presence of `enc_identifier_value` for
#' top-level encounters and ensures that there are no multiple `einrichtungskontakt` encounters with
#' the same identifier value. If any inconsistencies are found (e.g., multiple top-level encounters
#' for the same identifier), an error is raised. Update: The function now also uses the pre-calculated
#' `enc_main_encounter_calculated_ref` column from the cds-toolchain to determine the main encounter ID,
#' falling back to the original logic if necessary.
#' If any encounters cannot be assigned a `main_enc_id`, a warning is issued, and those records
#' are printed for review. The `processing_exclusion_reason` column is updated to indicate
#' these cases: "encounter_without_main_enc_id".
#'
#' @importFrom dplyr mutate case_when relocate
#' @export
addMainEncId <- function(encounter_table) {
  encounter_table_with_main_enc <- encounter_table |>
    dplyr::left_join(
      encounter_table |>
        dplyr::filter(enc_type_code_Kontaktebene == "einrichtungskontakt") |>
        dplyr::distinct(enc_id, enc_identifier_value),
      by = "enc_identifier_value",
      suffix = c("", "_einrichtungskontakt")
    ) |>
    dplyr::mutate(main_enc_id = dplyr::case_when(
      is.na(enc_partof_calculated_ref) &
        enc_type_code_Kontaktebene != "einrichtungskontakt" ~ enc_id_einrichtungskontakt,

      # Top-level: einrichtungskontakt
      is.na(enc_partof_calculated_ref) &
        enc_type_code_Kontaktebene == "einrichtungskontakt" ~ enc_id,

      # Middle-level: abteilungskontakt
      enc_type_code_Kontaktebene == "abteilungskontakt" ~ sub("^Encounter/", "", enc_partof_calculated_ref),

      # Bottom-level: versorgungsstellenkontakt
      enc_type_code_Kontaktebene == "versorgungsstellenkontakt" ~ {
        parent_id <- sub("^Encounter/", "", enc_partof_calculated_ref)
        grandparent_ref <- encounter_table$enc_partof_calculated_ref[match(parent_id, encounter_table$enc_id)]
        sub("^Encounter/", "", grandparent_ref)
      }
    )) |>
    dplyr::select(-enc_id_einrichtungskontakt) |>
    # use new calculation from cds-toolchain
    dplyr::rename(main_enc_id_initial_try = main_enc_id) |>
    dplyr::mutate(main_enc_id = sub("^Encounter/", "", enc_main_encounter_calculated_ref)) |>
    dplyr::mutate(main_enc_id = dplyr::if_else(is.na(main_enc_id), main_enc_id_initial_try, main_enc_id)) |>
    dplyr::relocate(main_enc_id, main_enc_id_initial_try, .after = enc_id) |>
    dplyr::distinct()

  if (any(is.na(encounter_table_with_main_enc$main_enc_id))) {
    encounter_table_with_main_enc <- encounter_table_with_main_enc |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(main_enc_id),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "encounter_without_main_enc_id",
          level = "sub_encounter",
          type = "data_issues"
        ),
        processing_exclusion_reason
      ))
    print(encounter_table_with_main_enc |>
      dplyr::filter(is.na(main_enc_id)), width = 1000)
    warning("Some encounters have no calculated main_enc_id.
            Please check the data.")
  }

  return(encounter_table_with_main_enc)
}


#------------------------------------------------------------------------------#

#' Add Main Encounter Period Start to Encounter Table
#'
#' This function adds a new column `main_enc_period_start` to the encounter table.
#' It retrieves the `enc_period_start` date from the main (Einrichtungskontakt) encounter associated
#' with each record and joins it based on the `main_enc_id`.
#'
#' @param encounter_table_with_main_enc A data frame or tibble that contains encounter records
#'   with an existing `main_enc_id` column (usually created by \code{\link{addMainEncId}}).
#'   The table must include at least:
#'   - `enc_id`: Encounter ID
#'   - `main_enc_id`: ID of the main (Einrichtungskontakt) encounter
#'   - `enc_period_start`: Start date of the encounter period
#'
#' @return A data frame or tibble with an additional column:
#'   - `main_enc_period_start`: The `enc_period_start` date corresponding to the `main_enc_id`.
#'     This represents the start date of the primary encounter for each record.
#'
#' @details
#' The function performs a left join between the encounter table and a mapping
#' of `main_enc_id` to `enc_period_start`. It ensures that each encounter record
#' has easy access to the start date of its top-level (Einrichtungskontakt) encounter period.
#' The new column is relocated immediately after `main_enc_id` for better readability.
#' If any encounters cannot be assigned a `main_enc_period_start`, a warning is issued,
#' and those records are printed for review. The `processing_exclusion_reason` column
#' is updated to indicate these cases: "encounter_without_main_enc_period_start".
#'
#' @importFrom dplyr left_join select rename relocate
#' @export
addMainEncPeriodStart <- function(encounter_table_with_main_enc) {
  encounter_table_with_MainEncPeriodStart <- encounter_table_with_main_enc |>
    dplyr::left_join(
      encounter_table_with_main_enc |>
        dplyr::select(enc_id, enc_period_start) |>
        dplyr::rename(main_enc_id = enc_id, main_enc_period_start = enc_period_start),
      by = "main_enc_id"
    ) |>
    dplyr::relocate(main_enc_period_start, .after = main_enc_id) |>
    dplyr::arrange(
      main_enc_period_start, enc_class_code, enc_type_code_Kontaktebene,
      enc_period_start, enc_period_end
    )

  if (any(is.na(encounter_table_with_MainEncPeriodStart$main_enc_period_start))) {
    encounter_table_with_MainEncPeriodStart <- encounter_table_with_MainEncPeriodStart |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(main_enc_period_start),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "encounter_without_main_enc_period_start",
          level = "sub_encounter",
          type = "data_issues"
        ),
        "encounter_without_main_enc_period_start",
        processing_exclusion_reason
      ))
    print(encounter_table_with_MainEncPeriodStart |>
      dplyr::filter(is.na(main_enc_period_start)), width = 1000)
    warning("Some encounters have no determined main_enc_period_start.
            Please check the data.")
  }

  return(encounter_table_with_MainEncPeriodStart)
}

#------------------------------------------------------------------------------#
#' Restrict Front-End Fall Data to Dynamically Defined INTERPOLAR Wards
#'
#' Filters the merged patient and fall front-end data to include only rows
#' belonging to INTERPOLAR wards defined via global environment variables.
#'
#' @param merged_pat_fall_fe_table A data frame containing merged patient and
#'   fall front-end data, including a `fall_station` column identifying the ward.
#'
#' @return A data frame containing only rows whose `fall_station` matches one of
#'   the dynamically defined INTERPOLAR wards. Duplicate rows are removed.
#'
#' @details
#' The function searches the global environment for objects with names matching
#' the pattern `"^PHASES_WARD_"`. For each matching object, it checks whether it
#' is defined and non-empty using `etlutils::isDefinedAndNotEmpty()`.
#'
#' The first element of each valid object is extracted and processed to derive
#' the ward name using `stringr::str_split_i()`. All extracted ward names are
#' combined into a vector of valid INTERPOLAR wards.
#'
#' The input table is then filtered to retain only rows where `fall_station`
#' matches one of these wards. Duplicate rows are removed using `distinct()`.
#'
#' @importFrom dplyr filter distinct
#' @importFrom etlutils isDefinedAndNotEmpty
#' @importFrom stringr str_split_i
#'
#' @export
restrictToDefinedWards <- function(merged_pat_fall_fe_table) {
  interpolar_wards_definition <- ls(pattern = "^PHASES_WARD_", envir = .GlobalEnv)
  interpolar_wards <- c()
  for (i in seq_along(interpolar_wards_definition)) {
    ward_phase_defintion <- interpolar_wards_definition[i]
    if (etlutils::isDefinedAndNotEmpty(ward_phase_defintion)) {
      ward_name <- get(ward_phase_defintion, envir = .GlobalEnv)[1] |>
        stringr::str_split_i("'", 2)
      interpolar_wards <- c(interpolar_wards, ward_name)
    }
  }

  merged_pat_fall_fe_table_restricted_to_defined_wards <- merged_pat_fall_fe_table |>
    dplyr::filter(fall_station %in% interpolar_wards) |>
    dplyr::distinct()

  return(merged_pat_fall_fe_table_restricted_to_defined_wards)
}

#------------------------------------------------------------------------------#

#' Calculate Patient Age at Main Encounter Start
#'
#' This function calculates the patient's age at the start of the main encounter period
#' (Einrichtungskontakt) by computing the difference between the main encounter start date and the
#' patient's birthdate. It adds a new column `age_at_hospitalization` to the merged table.
#' The age is calculated in completed years, rounding down to the nearest whole number.
#' If the age already exists in the dataset (e.g., from a pre-calculated column), it can be used
#' directly by specifying the `age_at_admission` parameter in the format: `age_at_admission = "column_name"`.
#'
#' @param merged_table_with_MainEncPeriodStart A data frame or tibble containing merged patient
#'   and encounter data. It must include the columns `pat_birthdate` (patient's birth date)
#'   and `main_enc_period_start` (start date of the main encounter (Einrichtungskontakt)).
#' @param main_enc_period_start The column name representing the start date of the main encounter period.
#' @param pat_birthdate The column name representing the patient's birth date.
#' @param age_at_admission Optional. The column name representing the patient's age at admission, if already available.
#'
#' @return A data frame or tibble with an additional column:
#'   - `age_at_hospitalization`: The patient's age in completed years at the time of the main
#'   encounter start.
#'
#' @details
#' The function calculates age by taking the difference between `main_enc_period_start` and
#' `pat_birthdate`, converting it into days, dividing by 365.25 to account for leap years,
#' and rounding down to the nearest whole number. If any patients cannot have their age
#' determined (i.e., if `age_at_hospitalization` is `NA`), a warning is issued, and those
#' records are printed for review. The `processing_exclusion_reason` column is updated to
#' indicate these cases: "patient_without_determined_age". Similarly, if any patients have
#' an implausible age (<= 0 or > 120), a warning is issued, and those records are printed
#' for review. The `processing_exclusion_reason` column is updated to indicate these cases:
#' "patient_with_implausible_age". If any patients are underage (< 18 years), the
#' `processing_exclusion_reason` column is updated to indicate these cases: "patient_underage".
#'
#' @importFrom dplyr mutate case_when if_else
#' @export
calculateAge <- function(merged_table_with_MainEncPeriodStart,
                         main_enc_period_start = main_enc_period_start,
                         pat_birthdate = pat_birthdate,
                         age_at_admission = NA) {
  columns <- colnames(merged_table_with_MainEncPeriodStart)

  # if age at admission is defined and it exists as column in the database,
  # use this directly instead of calculating it from birthdate and main_enc_period_start
  if (!is.na(age_at_admission) && age_at_admission %in% columns) {
    merged_table_with_age <- merged_table_with_MainEncPeriodStart |>
      dplyr::mutate(age_at_hospitalization = !!dplyr::sym(age_at_admission)) |>
      dplyr::relocate(age_at_hospitalization, .after = {{ pat_birthdate }}) |>
      dplyr::select(-{{ pat_birthdate }}) |>
      dplyr::distinct()
  } else {
    merged_table_with_age <- merged_table_with_MainEncPeriodStart |>
      dplyr::mutate(age_at_hospitalization = floor(as.numeric(difftime(
        as.Date({{ main_enc_period_start }}),
        as.Date({{ pat_birthdate }}, format = "%Y-%m-%d"),
        units = "days"
      )) / 365.25)) |>
      dplyr::relocate(age_at_hospitalization, .after = {{ pat_birthdate }}) |>
      dplyr::select(-{{ pat_birthdate }}) |>
      dplyr::distinct()
  }
  if (any(is.na(merged_table_with_age$age_at_hospitalization))) {
    warning("Some patients have no determined age_at_hospitalization.
            Please check the data.")
    merged_table_with_age <- merged_table_with_age |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(age_at_hospitalization),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "patient_without_determined_age",
          level = "main_encounter",
          type = "data_issues"
        ),
        processing_exclusion_reason
      ))
    print(merged_table_with_age |>
      dplyr::filter(is.na(age_at_hospitalization)), width = 1000)
  }

  if (any(merged_table_with_age$age_at_hospitalization <= 0 | merged_table_with_age$age_at_hospitalization > 120,
    na.rm = TRUE
  )) {
    warning("Some patients have a implausible age_at_hospitalization (<= 0 or > 120).
            Please check the data.")
    merged_table_with_age <- merged_table_with_age |>
      dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
        !is.na(age_at_hospitalization) &
          (age_at_hospitalization <= 0 | age_at_hospitalization > 120) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "patient_with_implausible_age",
            level = "main_encounter",
            type = "data_issues"
          ),
        TRUE ~ processing_exclusion_reason
      ))
    print(merged_table_with_age |>
      dplyr::filter(age_at_hospitalization <= 0 | age_at_hospitalization > 120), width = 1000)
  }

  if (any(merged_table_with_age$age_at_hospitalization < 18, na.rm = TRUE)) {
    merged_table_with_age <- merged_table_with_age |>
      dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
        !is.na(age_at_hospitalization) &
          age_at_hospitalization < 18 ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "patient_underage",
            level = "main_encounter",
            type = "not_in_inclusion_criteria"
          ),
        TRUE ~ processing_exclusion_reason
      ))
  }

  return(merged_table_with_age)
}

#------------------------------------------------------------------------------#
#' Tag Ambulant Encounters in the Processing Exclusion Reason
#'
#' This function marks ambulant encounters by appending a structured
#' processing exclusion reason to the \code{processing_exclusion_reason}
#' column for encounters with class code \code{"AMB"}.
#'
#' The tagging uses \code{\link{addProcessingExclusionReason}} to ensure
#' consistent formatting and to avoid duplicate entries.
#'
#' @param merged_table A data frame containing encounter-level data.
#'   It must include the columns \code{enc_class_code} and
#'   \code{processing_exclusion_reason}.
#'
#' @return
#' A data frame identical to \code{merged_table}, but with
#' \code{processing_exclusion_reason} updated for ambulant encounters.
#'
#' @details
#' For rows where \code{enc_class_code == "AMB"}, the following exclusion
#' reason entry is added:
#'
#' \code{ambulant_encounter|sub_encounter|not_in_inclusion_criteria}
#'
#' If this exclusion reason already exists, it is not added again.
#' Non-ambulant encounters are returned unchanged.
#'
#' @seealso
#' \code{\link{addProcessingExclusionReason}}
#'
#' @importFrom dplyr mutate case_when
#'
#' @export
tagAmbulantEncounters <- function(merged_table) {
  merged_table_with_ambulant_tag <- merged_table |>
    dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
      enc_class_code == "AMB" ~
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "ambulant_encounter",
          level = "sub_encounter",
          type = "not_in_inclusion_criteria"
        ),
      TRUE ~ processing_exclusion_reason
    ))
  return(merged_table_with_ambulant_tag)
}

#------------------------------------------------------------------------------#
#' Tag Kontaktarten That Do Not Represent Inpatient Encounters
#'
#' This function identifies encounters whose \code{enc_type_code_Kontaktart}
#' denotes a contact type that should not be considered an inpatient encounter
#' and appends a structured processing exclusion reason accordingly.
#'
#' The tagging is performed using \code{\link{addProcessingExclusionReason}}
#' to ensure consistent formatting and to prevent duplicate entries.
#'
#' @param merged_table A data frame containing encounter-level data.
#'   It must include the columns \code{enc_type_code_Kontaktart} and
#'   \code{processing_exclusion_reason}.
#'
#' @return
#' A data frame identical to \code{merged_table}, but with
#' \code{processing_exclusion_reason} updated for encounters whose
#' Kontaktart denotes no inpatient encounter.
#'
#' @details
#' The following Kontaktart codes are interpreted as *not* representing
#' inpatient encounters:
#' \itemize{
#'   \item \code{"vorstationaer"}
#'   \item \code{"nachstationaer"}
#'   \item \code{"ub"}
#'   \item \code{"konsil"}
#'   \item \code{"operation"}
#' }
#'
#' For affected rows, the following entry is added to
#' \code{processing_exclusion_reason}:
#'
#' \code{kontaktart_denoting_no_inpatient_encounter|sub_encounter|not_in_inclusion_criteria}
#'
#' If the entry already exists, it is not duplicated.
#' Rows with other Kontaktart codes remain unchanged.
#'
#' @seealso
#' \code{\link{addProcessingExclusionReason}}
#'
#' @importFrom dplyr mutate case_when
#'
#' @export
tagKontaktartDenotingNoInpatientEncounter <- function(merged_table) {
  kontaktarten_denoting_no_inpatient_encounter <- c(
    "vorstationaer", "nachstationaer",
    "ub", "konsil", "operation"
  )

  merged_table_with_kontaktart_tag <- merged_table |>
    dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
      enc_type_code_Kontaktart %in% kontaktarten_denoting_no_inpatient_encounter ~
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "kontaktart_denoting_no_inpatient_encounter",
          level = "sub_encounter",
          type = "not_in_inclusion_criteria"
        ),
      TRUE ~ processing_exclusion_reason
    ))
  return(merged_table_with_kontaktart_tag)
}

#------------------------------------------------------------------------------#

#' Add Ward Name to Patient Encounters
#'
#' This function adds ward names to a table of patient encounters by merging it with a table that
#' provides ward names for each patient and encounter.
#' It ensures ward names are placed after the `curated_enc_period_end` column and removes duplicate rows.
#'
#' @param merged_table_with_main_enc A data frame containing patient encounters. Must include
#' `enc_id`, `pat_id`,`curated_enc_period_end` and encounter type/class columns.
#' @param pids_per_ward_table A data frame containing ward names along with corresponding patient
#' and encounter IDs of the "Versogungsstellenkontakt". Must include `ward_name`, `patient_id`, and
#' `encounter_id`.
#'
#' @return A data frame similar to the input `merged_table_with_main_enc`, but with the `ward_name`
#' column added and located after the `curated_enc_period_end` column. Duplicate rows in the output are
#' removed.
#'
#' @details
#' The function performs a left join between `merged_table_with_main_enc` and `pids_per_ward_table`
#' based on patient and encounter IDs. It uses the `enc_id` and `pat_id` from the encounter_table
#' to match with `encounter_id` and `patient_id` in the pids_per_ward_table.
#' it ensures that ward names are added only to 'Versorgungsstellenkontakten'.
#' It relocates the `ward_name` column to directly follow
#' `curated_enc_period_end`, ensuring that the returned table is free of duplicate rows.
#'
#' @seealso
#' \code{\link[dplyr]{left_join}}, \code{\link[dplyr]{relocate}}, \code{\link[dplyr]{distinct}}
#'
#' @importFrom dplyr left_join select relocate distinct case_when
#' @export
addWardName <- function(merged_table_with_main_enc, pids_per_ward_table) {
  merged_table_with_ward <- merged_table_with_main_enc |>
    dplyr::left_join(
      pids_per_ward_table |>
        dplyr::select(ward_name, patient_id, encounter_id),
      by = c("enc_id" = "encounter_id", "pat_id" = "patient_id")
    ) |>
    dplyr::mutate(ward_name = dplyr::case_when(
      enc_type_code_Kontaktebene == "versorgungsstellenkontakt" ~
        ward_name, TRUE ~ NA_character_
    )) |>
    dplyr::relocate(ward_name, .after = curated_enc_period_end) |>
    dplyr::distinct()
  return(merged_table_with_ward)
}

#------------------------------------------------------------------------------#
#' Add Record Merged Table
#'
#' This function adds a `record_id` to each row in a given merged table by joining it with a
#' patient front-end data table. It ensures that each patient entry in the merged table is
#' complemented with its corresponding `record_id` from the patient data when available.
#'
#' @param merged_table_with_ward A dataframe that includes patient and encounter information, likely
#' merged with ward data. It should have columns that can be used to identify patients.
#' @param patient_fe_table A dataframe containing patient front-end data, including columns
#' `pat_id`, and `record_id`.
#'
#' @return A dataframe identical to `merged_table_with_ward` but with an additional
#' `record_id` column, which is relocated immediately after `pat_id`.
#'
#' @details
#' The function performs a left join on `merged_table_with_ward` using `pat_id` from the merged
#' table and matches it with `pat_id` from `patient_fe_table`. This adds the `record_id` to the
#' merged table, providing a unique identification feature that can be crucial for subsequent
#' analyses or data organization tasks. If any patients in the merged table do not have a matching
#' `record_id` in the patient front-end table, a warning is issued, and those records are printed
#' for review. The `processing_exclusion_reason` column is updated to indicate these cases:
#' "patient_without_matching_record_id_in_fe".
#'
#' @importFrom dplyr left_join select relocate if_else
#' @export
addRecordId <- function(merged_table_with_ward, patient_fe_table) {
  merged_table_with_record_id <- merged_table_with_ward |>
    dplyr::left_join(
      patient_fe_table |>
        dplyr::select(pat_id, record_id),
      by = c("pat_id" = "pat_id")
    ) |>
    dplyr::relocate(record_id, .after = pat_id) |>
    dplyr::distinct()

  if (any(is.na(merged_table_with_record_id$record_id))) {
    warning("Some patients in the database have no matching record id in the frontend patient_fe datatable.
            Please check the data.")
    merged_table_with_record_id <- merged_table_with_record_id |>
      dplyr::mutate(processing_exclusion_reason = dplyr::if_else(
        is.na(record_id),
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "patient_without_matching_record_id_in_fe",
          level = "patient",
          type = "linkage_issues"
        ),
        processing_exclusion_reason
      ))
    print(merged_table_with_record_id |>
      dplyr::filter(is.na(record_id)), width = 1000)
  }

  return(merged_table_with_record_id)
}

#------------------------------------------------------------------------------#
#' Merge Fall ID and Studienphase into Merged Table
#'
#' This function enriches a merged dataset with additional information from a front-end fall data
#' table. It performs a left join to append the cis Fall ID (`fall_id`) and study phase
#' (`fall_studienphase`) based on multiple matching keys, and renames the resulting columns for
#' clarity.
#'
#' @param merged_table_with_record_id A data frame or tibble that must contain the following columns:
#'   `record_id`, `main_enc_id`, `pat_id`, `ward_name`, `main_enc_period_start`, and `enc_identifier_value`.
#' @param fall_fe_table A data frame or tibble returned by [getFallFeData()], which includes:
#'   `record_id`, `fall_fhir_enc_id`, `fall_pat_id`, `fall_id`, `fall_studienphase`, `fall_station`,
#'   and `fall_aufn_dat`.
#'
#' @return A data frame identical to `merged_table_with_record_id`, but with two additional columns:
#'   \item{`fall_id_cis`}{cis Fall ID, renamed from `fall_id`}
#'   \item{`studienphase`}{Study phase, renamed from `fall_studienphase`}
#' The new columns are relocated for readability: `fall_id_cis` is placed after `enc_identifier_value`,
#' and `studienphase` is placed after `ward_name`.
#'
#' @details
#' The function joins the datasets using a composite key made up of:
#' \itemize{
#'   \item `record_id`
#'   \item `main_enc_id` = `fall_fhir_enc_id`
#'   \item `pat_id` = `fall_pat_id`
#'   \item `ward_name` = `fall_station`
#'   \item `main_enc_period_start` = `fall_aufn_dat`
#' }
#' After the join, the function renames and relocates the relevant columns, and ensures uniqueness
#' using `distinct()`. If any INTERPOLAR ward encounters lack a matching record in the
#' `fall_fe_table`, a warning is issued, and those records are printed for review. The
#' `processing_exclusion_reason` column is updated to indicate these cases: "encounter_without_matching_fall_fe_record".
#' Note: fall_studienphase is currently not used in the analysis, therefore it is commented out.
#' Note: the functions is currently not used. maybe remove completely later.
#'
#'
#' @importFrom dplyr left_join select rename relocate distinct case_when
#' @export
addFallIdAndStudienphase <- function(merged_table_with_record_id, fall_fe_table) {
  merged_table_with_fall_id_and_studienphase <- merged_table_with_record_id |>
    dplyr::left_join(
      fall_fe_table,
      by = c(
        "record_id" = "record_id", "main_enc_id" = "fall_fhir_enc_id",
        "pat_id" = "fall_pat_id", "ward_name" = "fall_station",
        "main_enc_period_start" = "fall_aufn_dat"
      )
    ) |>
    dplyr::rename(
      fall_id_cis = fall_id # ,
      # studienphase = fall_studienphase
    ) |>
    dplyr::relocate(fall_id_cis, .after = enc_identifier_value) |>
    # dplyr::relocate(studienphase, .after = ward_name) |>
    dplyr::distinct()

  if (any(merged_table_with_fall_id_and_studienphase$enc_type_code_Kontaktebene == "versorgungsstellenkontakt" &
    !is.na(merged_table_with_fall_id_and_studienphase$ward_name) &
    is.na(merged_table_with_fall_id_and_studienphase$fall_id_cis))) {
    warning("Some INTERPOLAR-ward-encounters in the database have no matching record (CIS-identifier) in the
            frontend fall_fe datatable. Please check the data.")
    merged_table_with_fall_id_and_studienphase <- merged_table_with_fall_id_and_studienphase |>
      dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
        enc_type_code_Kontaktebene == "versorgungsstellenkontakt" & !is.na(ward_name) &
          is.na(fall_id_cis) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "encounter_without_matching_fall_fe_record",
            level = "main_encounter",
            type = "linkage_issues"
          ),
        TRUE ~ processing_exclusion_reason
      ))
    print(merged_table_with_fall_id_and_studienphase |>
      dplyr::filter(enc_type_code_Kontaktebene == "versorgungsstellenkontakt" & !is.na(ward_name) &
        is.na(fall_id_cis)), width = 1000)
  }

  return(merged_table_with_fall_id_and_studienphase)
}

#------------------------------------------------------------------------------#

#' Merge Patient Front-End and Fall Front-End Tables
#'
#' This function merges patient front-end (`patient_fe_table`) and case-level front-end
#' (`fall_fe_table`) data based on shared identifiers (`record_id` and `pat_id`).
#' The goal is to enrich the patient-level data with associated case-level details.
#'
#' @param patient_fe_table A data frame containing front-end patient data, including
#'   at least `record_id`, `pat_id`.
#'
#' @param fall_fe_table A data frame containing front-end fall/case data, including
#'   at least `record_id`, `fall_pat_id`, `fall_fhir_enc_id`, `fall_id`, `fall_studienphase`,
#'   `fall_station`, and `fall_aufn_dat`.
#'
#' @return A merged data frame with the selected columns from both input tables.
#'
#' @details
#' The merge operation:
#' - Performs a left join using `record_id` and `pat_id` (matched to `fall_pat_id`),
#' - Removes duplicate rows after the merge.
#'
#' This is useful for linking case trajectories from the FE system with individual
#' patient-level data in analytical workflows.
#'
#'
#' @importFrom dplyr left_join select distinct
#' @export
mergePatFeFallFe <- function(patient_fe_table, fall_fe_table) {
  frontend_table <- patient_fe_table |>
    dplyr::left_join(
      fall_fe_table,
      by = c(
        "pat_id" = "fall_pat_id",
        "record_id"
      )
    ) |>
    dplyr::distinct() |>
    dplyr::rename(
      fall_id_cis = fall_id,
      fall_fhir_main_enc_id = fall_fhir_enc_id
    )
  return(frontend_table)
}


#------------------------------------------------------------------------------#

#' Add Medication Analysis Data to Front-End Data
#'
#' Merges medication analysis front-end data into a merged patient and fall
#' front-end dataset. The linkage strategy depends on whether patients have
#' multiple main encounters and whether main encounters span multiple wards.
#'
#' @param merged_fe_pat_fall_table_with_enc_id A data frame containing merged
#'   patient and fall front-end data enriched with encounter information.
#' @param medikationsanalyse_fe_table A data frame containing medication
#'   analysis front-end data, including medication analysis identifiers,
#'   dates, and fall identifiers.
#'
#' @return A data frame containing the merged patient, fall, encounter, and
#'   medication analysis data. Medication analysis records that cannot be
#'   linked to an existing front-end row are retained and annotated with
#'   an appropriate `processing_exclusion_reason`.
#'
#' @details
#' The function applies different medication analysis linkage strategies
#' according to the encounter and ward structure:
#'
#' \enumerate{
#'   \item For patients with one main encounter and one ward, medication
#'   analyses are linked using `record_id`.
#'   \item For patients with multiple main encounters but one ward,
#'   medication analyses are linked using `record_id` and `fall_meda_id`.
#'   \item For patients with one main encounter and multiple wards,
#'   medication analyses are linked using `record_id` and the medication
#'   analysis date within the corresponding ward stay period.
#'   \item For patients with multiple main encounters and multiple wards,
#'   medication analyses are linked using `record_id`, `fall_meda_id`,
#'   and the medication analysis date within the corresponding ward stay
#'   period.
#' }
#'
#' Medication analysis records that cannot be linked through these strategies
#' are identified separately and added to the resulting dataset. Depending
#' on the available linkage information, appropriate processing exclusion
#' reasons are assigned for missing fall identifiers, missing medication
#' analysis dates, or missing ward stay period information.
#'
#' Duplicate rows are removed throughout the processing steps and from the
#' final result.
#'
#' @importFrom dplyr anti_join arrange bind_rows between case_when distinct filter left_join mutate select
#'
#' @export
addMedaData <- function(merged_fe_pat_fall_table_with_enc_id, medikationsanalyse_fe_table) {
  meda_with_date <- medikationsanalyse_fe_table |>
    dplyr::filter(!is.na(meda_dat)) |>
    dplyr::distinct()

  one_encounter_one_ward <- merged_fe_pat_fall_table_with_enc_id |>
    dplyr::filter(multiple_main_encounters_per_patient == FALSE &
      multiple_wards_per_main_encounter == FALSE) |>
    # use assignment only depending on record_id
    dplyr::left_join(
      medikationsanalyse_fe_table |>
        dplyr::select(-fall_meda_id) |>
        dplyr::distinct(),
      by = c("record_id")
    ) |>
    dplyr::mutate(
      processing_exclusion_reason = dplyr::case_when(
        !is.na(meda_id) & is.na(meda_dat) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "missing_meda_dat",
            level = "sub_encounter",
            type = "linkage_issues"
          ),
        TRUE ~ processing_exclusion_reason
      )
    ) |>
    dplyr::distinct()

  multiple_encounters_one_ward <- merged_fe_pat_fall_table_with_enc_id |>
    dplyr::filter(multiple_main_encounters_per_patient == TRUE &
      multiple_wards_per_main_encounter == FALSE) |>
    # use assigment depending on record_id and fall_meda_id
    dplyr::left_join(
      medikationsanalyse_fe_table |>
        dplyr::distinct(),
      by = c(
        "record_id",
        "fall_id_cis" = "fall_meda_id"
      ),
      na_matches = "never"
    ) |>
    dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
      is.na(fall_id_cis) ~ addProcessingExclusionReason(
        existing = processing_exclusion_reason,
        reason = "missing_fall_id_in_fall_fe",
        level = "sub_encounter",
        type = "linkage_issues"
      ),
      !is.na(fall_id_cis) & !is.na(meda_id) & is.na(meda_dat) ~
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "missing_meda_dat",
          level = "sub_encounter",
          type = "linkage_issues"
        ),
      TRUE ~ processing_exclusion_reason
    )) |>
    dplyr::distinct()

  one_encounter_multiple_wards <- merged_fe_pat_fall_table_with_enc_id |>
    dplyr::filter(multiple_main_encounters_per_patient == FALSE &
      multiple_wards_per_main_encounter == TRUE) |>
    # use assignment depending on record_id and linking medication analysis date to ward stay period
    dplyr::left_join(
      meda_with_date |>
        dplyr::select(-fall_meda_id) |>
        dplyr::distinct(),
      by = dplyr::join_by(
        record_id == record_id,
        dplyr::between(
          y$meda_dat,
          x$enc_period_start,
          x$curated_enc_period_end
        )
      )
    ) |>
    dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
      is.na(enc_id) ~ addProcessingExclusionReason(
        existing = processing_exclusion_reason,
        reason = "no_matching_Versorgungsstellenkontakt_enc_id_for_ward",
        level = "sub_encounter",
        type = "linkage_issues"
      ),
      !is.na(enc_id) & (is.na(enc_period_start) | is.na(curated_enc_period_end)) ~ addProcessingExclusionReason(
        existing = processing_exclusion_reason,
        reason = "missing_Versorgungsstellenkontakt_start_or_end_date",
        level = "sub_encounter",
        type = "linkage_issues"
      ),
      TRUE ~ processing_exclusion_reason
    )) |>
    dplyr::distinct()

  multiple_encounters_multiple_wards <- merged_fe_pat_fall_table_with_enc_id |>
    dplyr::filter(multiple_main_encounters_per_patient == TRUE &
      multiple_wards_per_main_encounter == TRUE) |>
    # use assignment depending on record_id  and fall_meda_id and linking medication analysis date
    # to ward stay period
    dplyr::left_join(
      meda_with_date,
      by = dplyr::join_by(
        record_id == record_id,
        fall_id_cis == fall_meda_id,
        dplyr::between(
          y$meda_dat,
          x$enc_period_start,
          x$curated_enc_period_end
        )
      ),
      na_matches = "never"
    ) |>
    dplyr::mutate(processing_exclusion_reason = dplyr::case_when(
      is.na(fall_id_cis) ~ addProcessingExclusionReason(
        existing = processing_exclusion_reason,
        reason = "missing_fall_id_in_fall_fe",
        level = "sub_encounter",
        type = "linkage_issues"
      ),
      !is.na(fall_id_cis) & is.na(enc_id) ~ addProcessingExclusionReason(
        existing = processing_exclusion_reason,
        reason = "no_matching_Versorgungsstellenkontakt_enc_id_for_ward",
        level = "sub_encounter",
        type = "linkage_issues"
      ),
      !is.na(fall_id_cis) & !is.na(enc_id) & (is.na(enc_period_start) | is.na(curated_enc_period_end)) ~
        addProcessingExclusionReason(
          existing = processing_exclusion_reason,
          reason = "missing_Versorgungsstellenkontakt_start_or_end_date",
          level = "sub_encounter",
          type = "linkage_issues"
        ),
      TRUE ~ processing_exclusion_reason
    )) |>
    dplyr::distinct()

  # merge all four scenarios back together
  merged_fe_pat_fall_meda_table <- one_encounter_one_ward |>
    rbind(multiple_encounters_one_ward) |>
    rbind(one_encounter_multiple_wards) |>
    rbind(multiple_encounters_multiple_wards) |>
    dplyr::distinct()

  # Check for unmatched medication analysis entries
  unmatched_medas <- medikationsanalyse_fe_table |>
    dplyr::anti_join(
      merged_fe_pat_fall_meda_table |>
        dplyr::filter(!is.na(meda_id)) |>
        dplyr::distinct(meda_id),
      by = "meda_id"
    )

  unmatched_medas_with_fall_meda_id <- unmatched_medas |>
    dplyr::filter(!is.na(fall_meda_id)) |>
    dplyr::left_join(
      merged_fe_pat_fall_table_with_enc_id |>
        dplyr::select(-c(
          enc_id,
          enc_period_start,
          curated_enc_period_end
        )) |>
        dplyr::distinct(),
      by = c(
        "record_id" = "record_id",
        "fall_meda_id" = "fall_id_cis"
      ),
      na_matches = "never"
    ) |>
    dplyr::rename(fall_id_cis = fall_meda_id)

  unmatched_medas_without_fall_meda_id <- unmatched_medas |>
    dplyr::filter(is.na(fall_meda_id)) |>
    dplyr::select(-fall_meda_id) |>
    dplyr::left_join(
      merged_fe_pat_fall_table_with_enc_id |>
        dplyr::select(-c(
          age_at_hospitalization,
          fall_fhir_main_enc_id,
          fall_id_cis,
          fall_studienphase,
          actual_fall_studienphase,
          fall_station,
          fall_aufn_dat,
          enc_id,
          enc_period_start,
          curated_enc_period_end,
          fall_ent_dat,
          fall_complete
        )) |>
        dplyr::distinct(),
      by = "record_id"
    )

  unmatched_medas_to_add <- dplyr::bind_rows(
    unmatched_medas_with_fall_meda_id,
    unmatched_medas_without_fall_meda_id
  ) |>
    dplyr::mutate(
      processing_exclusion_reason = dplyr::case_when(
        # Multiple encounters + multiple wards:
        # both fall_meda_id and meda_dat are needed.
        multiple_main_encounters_per_patient == TRUE &
          multiple_wards_per_main_encounter == TRUE &
          !is.na(fall_id_cis) &
          is.na(meda_dat) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "missing_meda_dat",
            level = "sub_encounter",
            type = "linkage_issues"
          ),

        # Multiple encounters + multiple wards:
        # neither fall nor ward could be determined.
        multiple_main_encounters_per_patient == TRUE &
          multiple_wards_per_main_encounter == TRUE &
          is.na(fall_id_cis) &
          is.na(meda_dat) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "missing_fall_meda_id_and_meda_dat",
            level = "sub_encounter",
            type = "linkage_issues"
          ),

        multiple_main_encounters_per_patient == TRUE &
          multiple_wards_per_main_encounter == TRUE &
          !is.na(fall_id_cis) &
          !is.na(meda_dat) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "no_matching_ward_stay_period_information",
            level = "sub_encounter",
            type = "linkage_issues"
          ),

        # Multiple encounters + multiple wards:
        # fall_meda_id is required to identify the fall.
        multiple_main_encounters_per_patient == TRUE &
          multiple_wards_per_main_encounter == TRUE &
          is.na(fall_id_cis) &
          !is.na(meda_dat) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "missing_fall_meda_id",
            level = "sub_encounter",
            type = "linkage_issues"
          ),

        # Multiple encounters + one ward:
        # fall_meda_id is required to identify the correct fall.
        multiple_main_encounters_per_patient == TRUE &
          multiple_wards_per_main_encounter == FALSE &
          is.na(fall_id_cis) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "missing_fall_meda_id",
            level = "sub_encounter",
            type = "linkage_issues"
          ),

        # One encounter + multiple wards:
        # no fall_meda_id is needed, but meda_dat is required to determine
        # which ward the MDA belongs to.
        multiple_main_encounters_per_patient == FALSE &
          multiple_wards_per_main_encounter == TRUE &
          is.na(meda_dat) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "missing_meda_dat",
            level = "sub_encounter",
            type = "linkage_issues"
          ),

        # If the date exists but no ward could be matched, this means
        # that the date did not fall into any ward period.
        multiple_main_encounters_per_patient == FALSE &
          multiple_wards_per_main_encounter == TRUE &
          !is.na(meda_dat) ~
          addProcessingExclusionReason(
            existing = processing_exclusion_reason,
            reason = "no_matching_ward_stay_period_information",
            level = "sub_encounter",
            type = "linkage_issues"
          ),

        TRUE ~ processing_exclusion_reason
      )
    ) |>
    dplyr::distinct()

  merged_fe_pat_fall_meda_table  <- merged_fe_pat_fall_meda_table |>
    dplyr::bind_rows(unmatched_medas_to_add) |>
    dplyr::distinct()

  return(merged_fe_pat_fall_meda_table)
}

#------------------------------------------------------------------------------#
#' Add Encounter data of the Versorgungsstellenkontakt to Frontend patient and case data
#'
#' This function adds encounter-related information (including encounter ID and
#' period start and end dates) from a FHIR table to a merged frontend patient-fall data table.
#' It performs a left join based on patient ID, main encounter ID, and ward name
#' to combine the relevant columns, ensuring that only distinct rows are included
#' in the final dataset.
#'
#' @param merged_fe_pat_fall_table A data frame containing fall event data for
#'   patients, including patient ID, fall event details, and ward-related information.
#' @param FHIR_table_with_ward_name_and_record_id A data frame containing FHIR
#'   records (patient & encounter ressources) including encounter ID, main encounter ID, patient ID,
#'   and ward name, as well as encounter start and end periods.
#'
#' @return A data frame that contains the original fall event data with additional
#'   FHIR-sub-encounter-related columns, including `enc_id`, `enc_period_start`, and
#'   `curated_enc_period_end`.
#'
#' @details
#' This function performs a left join between the fall event data (`merged_fe_pat_fall_table`)
#' and a FHIR table (`FHIR_table_with_ward_name_and_record_id`). The join is done using
#' `pat_id`, `fall_fhir_main_enc_id`, and `fall_station` as keys. After joining,
#' the resulting data frame is de-duplicated (`distinct()`) and the encounter columns
#' (`enc_id`, `enc_period_start`, `curated_enc_period_end`) are relocated after the
#' `fall_aufn_dat` column for better organization.
#'
#' @note
#' The added information is specifically needed to match the correct medication analysis data
#' to the correct ward stay period via overlap with medication analysis date.
#' In that way multiple rows in fall_fe due to multiple wards per main encounter are handled correctly.
#' The ward name already linked to the input FHIR-data is originated from the `pids_per_ward_table` and only
#' added for the sub-encounter level Versorgungsstellenkontakt, which ensures the correct date assigments
#' per ward-stay.
#'
#' @importFrom dplyr left_join select distinct relocate join_by
#'
#' @export
addVersorgungsstellenkontaktToFeData <- function(merged_fe_pat_fall_table, FHIR_table_with_ward_name_and_record_id) {
  merged_fe_pat_fall_table_with_enc_id <- merged_fe_pat_fall_table |>
    dplyr::left_join(
      FHIR_table_with_ward_name_and_record_id |>
        dplyr::select(
          enc_id, main_enc_id, pat_id,
          enc_period_start,
          curated_enc_period_end, ward_name
        ) |>
        dplyr::distinct(),
      by = dplyr::join_by(
        pat_id == pat_id,
        fall_fhir_main_enc_id == main_enc_id,
        fall_station == ward_name,
      ),
      na_matches = "never"
    ) |>
    dplyr::distinct() |>
    dplyr::relocate(
      enc_id, enc_period_start, curated_enc_period_end,
      .after = fall_aufn_dat
    )
  return(merged_fe_pat_fall_table_with_enc_id)
}

#------------------------------------------------------------------------------#

#' Add MRP Documentation Data to Front-End Medication Analysis Data
#'
#' Merges MRP documentation and validation data into a merged patient,
#' fall, encounter, and medication analysis dataset. The linkage strategy
#' depends on whether a patient has one or multiple medication analyses.
#'
#' @param merged_fe_pat_fall_meda_table_with_enc_id A data frame containing
#'   merged patient, fall, encounter, ward, and medication analysis data.
#' @param mrp_dokumentation_validierung_fe_table A data frame containing
#'   MRP documentation and validation front-end data, including medication
#'   analysis and MRP identifiers.
#'
#' @return A data frame containing the input data enriched with matched MRP
#'   documentation data. MRP documentation entries that cannot be assigned
#'   to a medication analysis are retained where possible and annotated with
#'   an appropriate `processing_exclusion_reason`.
#'
#' @details
#' The function applies different linkage strategies depending on the number
#' of medication analyses associated with a patient:
#'
#' \enumerate{
#'   \item For patients with one medication analysis, MRP documentation is
#'   linked using `record_id`.
#'   \item For patients with multiple medication analyses, MRP documentation
#'   is linked using `record_id` and `mrp_meda_id`, matched to `meda_id`.
#' }
#'
#' MRP documentation entries that cannot be matched to an existing MRP are
#' identified separately. Entries without `mrp_meda_id` are retained and
#' assigned to the available patient and encounter context according to the
#' available fall and ward information:
#'
#' \itemize{
#'   \item For one encounter and one ward, fall and ward information are
#'   retained because `record_id` is sufficient to identify the context.
#'   \item For multiple encounters and one ward, fall and ward information
#'   are removed because the fall cannot be identified from `record_id`
#'   alone.
#'   \item For one encounter and multiple wards, fall information is retained,
#'   while ward and encounter-period information are removed because the
#'   ward cannot be determined.
#'   \item For multiple encounters and multiple wards, fall and ward
#'   information are removed because neither can be determined reliably.
#' }
#'
#' Unmatched MRP documentation entries without a medication analysis
#' identifier are marked with the `missing_mrp_meda_id` processing exclusion
#' reason. Duplicate rows are removed throughout the processing steps and
#' from the final result.
#'
#' @importFrom dplyr anti_join bind_rows distinct filter left_join mutate select
#'
#' @export
addMRPDokuData <- function(merged_fe_pat_fall_meda_table_with_enc_id,
                           mrp_dokumentation_validierung_fe_table) {
  # ============================================================
  # 1. MRP documentation with one medication analysis per patient
  # ============================================================

  one_medication_analysis <- merged_fe_pat_fall_meda_table_with_enc_id |>
    dplyr::filter(!multiple_medas_per_patient) |>
    # record_id is sufficient to identify the medication analysis
    dplyr::left_join(
      mrp_dokumentation_validierung_fe_table |>
        dplyr::select(-mrp_meda_id) |>
        dplyr::distinct(),
      by = "record_id"
    ) |>
    dplyr::distinct()


  # ============================================================
  # 2. MRP documentation with multiple medication analyses
  # ============================================================

  multiple_medication_analyses <- merged_fe_pat_fall_meda_table_with_enc_id |>
    dplyr::filter(multiple_medas_per_patient) |>
    # record_id + mrp_meda_id are required
    dplyr::left_join(
      mrp_dokumentation_validierung_fe_table |>
        dplyr::distinct(),
      by = c(
        "record_id",
        "meda_id" = "mrp_meda_id"
      ),
      na_matches = "never"
    ) |>
    dplyr::distinct()


  # ============================================================
  # 3. Merge successful MRP assignments
  # ============================================================

  merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku <-
    one_medication_analysis |>
    rbind(multiple_medication_analyses) |>
    dplyr::distinct()


  # ============================================================
  # 4. Find MRP documentation entries not yet assigned
  # ============================================================

  unmatched_mrps <- mrp_dokumentation_validierung_fe_table |>
    dplyr::anti_join(
      merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku |>
        dplyr::filter(!is.na(mrp_id)) |>
        dplyr::distinct(mrp_id),
      by = "mrp_id"
    )


  # ============================================================
  # 5. Only MRP documentation without mrp_meda_id remains here
  #
  # These MRPs cannot be assigned to a medication analysis.
  # However, record_id can still be used to determine the
  # patient and potentially the fall/ward context.
  # ============================================================

  unmatched_mrps_without_mrp_meda_id <- unmatched_mrps |>
    dplyr::filter(is.na(mrp_meda_id))


  # ============================================================
  # 6. One fall + one ward
  #
  # record_id uniquely identifies the fall and ward context.
  # Keep fall and ward information.
  #
  # Medication-analysis variables remain NA because
  # mrp_meda_id is missing.
  # ============================================================

  unmatched_mrps_one_encounter_one_ward <-
    unmatched_mrps_without_mrp_meda_id |>
    dplyr::left_join(
      merged_fe_pat_fall_meda_table_with_enc_id |>
        dplyr::filter(
          multiple_main_encounters_per_patient == FALSE &
            multiple_wards_per_main_encounter == FALSE
        ) |>
        dplyr::select(
          -c(
            meda_id,
            meda_dat,
            medikationsanalyse_complete,
            meda_mrp_detekt
          )
        ) |>
        dplyr::distinct(),
      by = "record_id"
    ) |>
    dplyr::distinct() |>
    dplyr::mutate(
      processing_exclusion_reason = addProcessingExclusionReason(
        existing = processing_exclusion_reason,
        reason = "missing_mrp_meda_id",
        level = "sub_encounter",
        type = "linkage_issues"
      )
    )


  # ============================================================
  # 7. Multiple falls + one ward
  #
  # The fall cannot be identified from record_id alone.
  # Therefore remove fall AND ward information.
  #
  # Medication-analysis variables also remain NA.
  # ============================================================

  unmatched_mrps_multiple_encounters_one_ward <-
    unmatched_mrps_without_mrp_meda_id |>
    dplyr::left_join(
      merged_fe_pat_fall_meda_table_with_enc_id |>
        dplyr::filter(
          multiple_main_encounters_per_patient == TRUE &
            multiple_wards_per_main_encounter == FALSE
        ) |>
        dplyr::select(
          -c(
            meda_id,
            meda_dat,
            medikationsanalyse_complete,
            meda_mrp_detekt,
            fall_fhir_main_enc_id,
            fall_id_cis,
            fall_studienphase,
            actual_fall_studienphase,
            fall_station,
            fall_aufn_dat,
            fall_ent_dat,
            fall_complete,
            enc_id,
            enc_period_start,
            curated_enc_period_end
          )
        ) |>
        dplyr::distinct(),
      by = "record_id"
    ) |>
    dplyr::distinct() |>
    dplyr::mutate(
      processing_exclusion_reason = addProcessingExclusionReason(
        existing = processing_exclusion_reason,
        reason = "missing_mrp_meda_id",
        level = "sub_encounter",
        type = "linkage_issues"
      )
    )


  # ============================================================
  # 8. One fall + multiple wards
  #
  # The fall can be identified, but the ward cannot.
  # Keep fall information, remove ward information.
  #
  # Medication-analysis variables remain NA.
  # ============================================================

  unmatched_mrps_one_encounter_multiple_wards <-
    unmatched_mrps_without_mrp_meda_id |>
    dplyr::left_join(
      merged_fe_pat_fall_meda_table_with_enc_id |>
        dplyr::filter(
          multiple_main_encounters_per_patient == FALSE &
            multiple_wards_per_main_encounter == TRUE
        ) |>
        dplyr::select(
          -c(
            meda_id,
            meda_dat,
            medikationsanalyse_complete,
            meda_mrp_detekt,
            enc_id,
            enc_period_start,
            curated_enc_period_end
          )
        ) |>
        dplyr::distinct(),
      by = "record_id"
    ) |>
    dplyr::distinct() |>
    dplyr::mutate(
      processing_exclusion_reason = addProcessingExclusionReason(
        existing = processing_exclusion_reason,
        reason = "missing_mrp_meda_id",
        level = "sub_encounter",
        type = "linkage_issues"
      )
    )


  # ============================================================
  # 9. Multiple falls + multiple wards
  #
  # Neither the fall nor the ward can be identified.
  # Remove both fall and ward information.
  #
  # Medication-analysis variables remain NA.
  # ============================================================

  unmatched_mrps_multiple_encounters_multiple_wards <-
    unmatched_mrps_without_mrp_meda_id |>
    dplyr::left_join(
      merged_fe_pat_fall_meda_table_with_enc_id |>
        dplyr::filter(
          multiple_main_encounters_per_patient == TRUE &
            multiple_wards_per_main_encounter == TRUE
        ) |>
        dplyr::select(
          -c(
            meda_id,
            meda_dat,
            medikationsanalyse_complete,
            meda_mrp_detekt,
            fall_fhir_main_enc_id,
            fall_id_cis,
            fall_studienphase,
            actual_fall_studienphase,
            fall_station,
            fall_aufn_dat,
            fall_ent_dat,
            fall_complete,
            enc_id,
            enc_period_start,
            curated_enc_period_end
          )
        ) |>
        dplyr::distinct(),
      by = "record_id"
    ) |>
    dplyr::distinct() |>
    dplyr::mutate(
      processing_exclusion_reason = addProcessingExclusionReason(
        existing = processing_exclusion_reason,
        reason = "missing_mrp_meda_id",
        level = "sub_encounter",
        type = "linkage_issues"
      )
    )


  # ============================================================
  # 10. Merge the four unresolved-MRP scenarios
  # ============================================================

  unmatched_mrps_to_add <- dplyr::bind_rows(
    unmatched_mrps_one_encounter_one_ward,
    unmatched_mrps_multiple_encounters_one_ward,
    unmatched_mrps_one_encounter_multiple_wards,
    unmatched_mrps_multiple_encounters_multiple_wards
  ) |>
    dplyr::distinct()


  # ============================================================
  # 11. Add unresolved MRP records to final table
  # ============================================================

  merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku <-
    merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku |>
    dplyr::bind_rows(unmatched_mrps_to_add) |>
    dplyr::distinct()

  return(merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku)
}

#' Add Retrospective MRP Evaluation Data with Matching Logic
#'
#' Merges retrospective MRP (medication-related problem) evaluation data into
#' a front-end dataset containing patient, fall, medication analysis, encounter,
#' and MRP documentation data. The function distinguishes between fully matching
#' retrospective records and partially matching records, applying different join
#' strategies.
#'
#' @param merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku A data frame
#'   containing merged front-end data, including patient, fall, medication
#'   analysis, encounter identifiers, and MRP documentation variables.
#' @param retrolektive_mrpbewertung_fe_table A data frame containing
#'   retrospective MRP evaluation front-end data.
#'
#' @return A data frame containing the merged dataset enriched with
#'   retrospective MRP evaluation data, ordered by `record_id`, `meda_dat`,
#'   `mrp_id`, and `ret_id`. Duplicate rows are removed.
#'
#' @details
#' The function performs a two-step merging process:
#'
#' \enumerate{
#'   \item Fully matching retrospective records are identified using an
#'   `inner_join()` on `record_id`, `meda_id` (matched to `ret_meda_id`),
#'   and `mrp_id` (matched to `ret_mrp_zuordnung1`). These matches represent
#'   the most precise linkage between front-end and retrospective data.
#'
#'   \item Remaining retrospective records (not matched in the first step)
#'   are joined using a `left_join()` based on `record_id` and `meda_id`
#'   only.
#' }
#'
#' The two resulting datasets are combined using `rbind()`, duplicates are
#' removed, and the final dataset is sorted for consistent downstream use.
#'
#' Joins are performed with `na_matches = "never"` to prevent matching on
#' missing key values.
#'
#' Note: The `retrolektive_mrpbewertung_fe_table` is expected to contain retrospective
#' MRP evaluation results that are linked to the medication analyses. One medication analysis can
#' result in multiple manually documented but also multiple retrospective algorithmic MRP evaluation,
#' both not nessecarily linked to each other (although they might be linkable via `ret_mrp_zuordnung1`).
#' This may result in duplication of algorithmic MRP
#' evaluation results when merged with the medication analysis data, which is not necessarily wrong
#' but should be kept in mind when interpreting the results.
#'
#' @importFrom dplyr inner_join left_join distinct rename select filter pull arrange
#'
#' @export
addRetrolektiveMRPBewertungData <- function(merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku,
                                            retrolektive_mrpbewertung_fe_table) {
  merged_matching_ret_data <- merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku |>
    dplyr::inner_join(
      retrolektive_mrpbewertung_fe_table |>
        dplyr::distinct(),
      by = c(
        "record_id",
        "meda_id" = "ret_meda_id",
        "mrp_id" = "ret_mrp_zuordnung1"
      ),
      na_matches = "never",
      keep = TRUE
    ) |>
    dplyr::rename(record_id = record_id.x) |>
    dplyr::select(-c(record_id.y, ret_meda_id)) |>
    dplyr::distinct()

  matching_ret_ids <- merged_matching_ret_data |>
    dplyr::distinct(ret_id) |>
    dplyr::pull()

  merged_not_matching_ret_data <- merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku |>
    dplyr::left_join(
      retrolektive_mrpbewertung_fe_table |>
        dplyr::filter(!ret_id %in% matching_ret_ids) |>
        dplyr::distinct(),
      by = c(
        "record_id",
        "meda_id" = "ret_meda_id"
      ),
      na_matches = "never",
      relationship = "many-to-many"
    ) |>
    dplyr::distinct()

  merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku_retrolektive <- merged_matching_ret_data |>
    rbind(merged_not_matching_ret_data) |>
    dplyr::distinct() |>
    dplyr::arrange(record_id, meda_dat, mrp_id, ret_id)

  return(merged_fe_pat_fall_meda_table_with_enc_id_mrp_doku_retrolektive)
}

#------------------------------------------------------------------------------#

#' Add Broad Consent Information to Front-End Data
#'
#' Enriches a front-end dataset with information on whether a patient has
#' given valid broad consent for scientific use of their data.
#'
#' @param frontend_tablend A data frame containing front-end data with a
#'   `pat_id` column.
#' @param consent_table A data frame containing consent information,
#'   including patient references, consent status, provision details, and
#'   validity periods.
#'
#' @return A data frame identical to `frontend_tablend` with an additional
#'   logical column `MDAT_wissenschaftlich_nutzen`, indicating whether the
#'   patient has a currently valid consent for his Policy.
#'
#' @details
#' The function extracts patient IDs from the consent table by removing the
#' `"Patient/"` prefix from `cons_patient_ref`. It then filters for active
#' consents that:
#' \itemize{
#'   \item have status `"active"`
#'   \item are of type `"permit"`
#'   \item match a specific consent code system and code
#'   \item are currently valid based on the provision period (`start <= now < end`)
#' }
#'
#' The resulting set of patient IDs is used to create a new logical variable
#' in the front-end dataset, indicating whether each patient has valid broad
#' consent at the current time.
#'
#' @importFrom dplyr mutate filter distinct pull
#'
#' @export
addBroadConsentInformation <- function(frontend_tablend, consent_table) {
  consent_pids <- consent_table |>
    dplyr::mutate(pat_id = sub("^Patient/", "", cons_patient_ref), .keep = "unused") |>
    dplyr::filter(
      cons_status == "active",
      cons_provision_provision_type == "permit",
      cons_provision_provision_code_system == "urn:oid:2.16.840.1.113883.3.1937.777.24.5.3",
      cons_provision_provision_code_code == "2.16.840.1.113883.3.1937.777.24.5.3.8",
      cons_provision_provision_period_start <= as.POSIXct(Sys.time()),
      cons_provision_provision_period_end > as.POSIXct(Sys.time())
    ) |>
    dplyr::distinct(pat_id) |>
    dplyr::pull(pat_id)

  frontend_tablend_with_consent <- frontend_tablend |>
    dplyr::mutate(MDAT_wissenschaftlich_nutzen = pat_id %in% consent_pids)

  return(frontend_tablend_with_consent)
}
