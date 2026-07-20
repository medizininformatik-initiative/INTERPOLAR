extractFhirReferenceId <- function(references, resource_type) {
  references <- as.character(references)
  references[is.na(references) | !nzchar(references)] <- NA_character_
  references <- sub("^\\[[^]]+\\]", "", references)
  references <- sub(paste0("^", resource_type, "/"), "", references)
  references
}

calculateCompletedYears <- function(reference_dates, birth_dates) {
  reference_dates <- as.Date(reference_dates)
  birth_dates <- as.Date(birth_dates)
  age <- floor(as.numeric(difftime(reference_dates, birth_dates, units = "days")) / 365.25)
  age[is.na(reference_dates) | is.na(birth_dates) | age < 0] <- NA_real_
  as.integer(age)
}

convertWeightToKg <- function(values, units) {
  values <- suppressWarnings(as.numeric(values))
  units <- tolower(trimws(as.character(units)))
  result <- rep(NA_real_, length(values))
  kg_rows <- units %in% c("kg", "kilogram", "kilograms")
  g_rows <- units %in% c("g", "gram", "grams")
  mg_rows <- units %in% c("mg", "milligram", "milligrams")
  result[kg_rows] <- values[kg_rows]
  result[g_rows] <- values[g_rows] / 1000
  result[mg_rows] <- values[mg_rows] / 1000000
  result
}

convertHeightToM <- function(values, units) {
  values <- suppressWarnings(as.numeric(values))
  units <- tolower(trimws(as.character(units)))
  result <- rep(NA_real_, length(values))
  m_rows <- units %in% c("m", "meter", "meters")
  cm_rows <- units %in% c("cm", "centimeter", "centimeters")
  mm_rows <- units %in% c("mm", "millimeter", "millimeters")
  result[m_rows] <- values[m_rows]
  result[cm_rows] <- values[cm_rows] / 100
  result[mm_rows] <- values[mm_rows] / 1000
  result
}

calculateBmi <- function(weight_values, weight_units, height_values, height_units) {
  weight_kg <- convertWeightToKg(weight_values, weight_units)
  height_m <- convertHeightToM(height_values, height_units)
  result <- weight_kg / (height_m^2)
  result[is.na(weight_kg) | is.na(height_m) | weight_kg <= 0 | height_m <= 0] <- NA_real_
  result
}

getPatientFrontendBirthdateMap <- function(patient_fe) {
  patient_fe <- data.table::as.data.table(data.table::copy(patient_fe))
  result <- data.table::data.table(
    patient_key = character(),
    birthdate = as.Date(character())
  )
  if ("record_id" %in% names(patient_fe) && "pat_gebdat" %in% names(patient_fe)) {
    record_rows <- !is.na(patient_fe[["record_id"]]) &
      nzchar(as.character(patient_fe[["record_id"]]))
    result <- data.table::rbindlist(list(
      result,
      data.table::data.table(
        patient_key = as.character(patient_fe[["record_id"]][record_rows]),
        birthdate = as.Date(patient_fe[["pat_gebdat"]][record_rows])
      )
    ))
  }
  if ("pat_id" %in% names(patient_fe) && "pat_gebdat" %in% names(patient_fe)) {
    pat_rows <- !is.na(patient_fe[["pat_id"]]) &
      nzchar(as.character(patient_fe[["pat_id"]]))
    result <- data.table::rbindlist(list(
      result,
      data.table::data.table(
        patient_key = as.character(patient_fe[["pat_id"]][pat_rows]),
        birthdate = as.Date(patient_fe[["pat_gebdat"]][pat_rows])
      )
    ))
  }
  unique(result[!is.na(result[["patient_key"]]), ], by = "patient_key")
}

enrichSnapshotFallTable <- function(fall_fe, patient_fe) {
  fall_fe <- data.table::as.data.table(data.table::copy(fall_fe))
  if (!"fall_age_at_admission" %in% names(fall_fe)) {
    fall_fe[["fall_age_at_admission"]] <- NA_integer_
  }
  if (!"fall_bmi" %in% names(fall_fe)) {
    fall_fe[["fall_bmi"]] <- NA_real_
  }
  if (nrow(fall_fe) == 0) {
    return(fall_fe)
  }

  if (!is.null(patient_fe) && "fall_aufn_dat" %in% names(fall_fe)) {
    patient_birthdates <- getPatientFrontendBirthdateMap(patient_fe)
    patient_key <- rep(NA_character_, nrow(fall_fe))
    if ("patient_id_fk" %in% names(fall_fe)) {
      patient_key <- as.character(fall_fe[["patient_id_fk"]])
    }
    if ("fall_pat_id" %in% names(fall_fe)) {
      fallback_rows <- is.na(patient_key) | !nzchar(patient_key)
      patient_key[fallback_rows] <- as.character(fall_fe[["fall_pat_id"]][fallback_rows])
    }
    birthdates <- patient_birthdates[
      match(patient_key, patient_birthdates[["patient_key"]]),
      "birthdate"
    ][[1]]
    fall_fe[["fall_age_at_admission"]] <- calculateCompletedYears(fall_fe[["fall_aufn_dat"]], birthdates)
  }

  bmi_columns <- c(
    "fall_gewicht_aktuell",
    "fall_gewicht_aktl_einheit",
    "fall_groesse",
    "fall_groesse_einheit"
  )
  if (all(bmi_columns %in% names(fall_fe))) {
    fall_fe[["fall_bmi"]] <- calculateBmi(
      fall_fe[["fall_gewicht_aktuell"]],
      fall_fe[["fall_gewicht_aktl_einheit"]],
      fall_fe[["fall_groesse"]],
      fall_fe[["fall_groesse_einheit"]]
    )
  }

  fall_fe
}

getPatientBirthdateMap <- function(patient) {
  patient <- data.table::as.data.table(data.table::copy(patient))
  if (!all(c("pat_id", "pat_birthdate") %in% names(patient))) {
    return(data.table::data.table(patient_id = character(), birthdate = as.Date(character())))
  }
  patient_rows <- !is.na(patient[["pat_id"]]) &
    nzchar(as.character(patient[["pat_id"]]))
  unique(
    data.table::data.table(
      patient_id = as.character(patient[["pat_id"]][patient_rows]),
      birthdate = as.Date(patient[["pat_birthdate"]][patient_rows])
    ),
    by = "patient_id"
  )
}

enrichSnapshotEncounterTable <- function(encounter, patient) {
  encounter <- data.table::as.data.table(data.table::copy(encounter))
  if (!"enc_age_at_admission" %in% names(encounter)) {
    encounter[["enc_age_at_admission"]] <- NA_integer_
  }
  if (
    nrow(encounter) == 0 ||
    is.null(patient) ||
    !"enc_patient_ref" %in% names(encounter) ||
    !"enc_period_start" %in% names(encounter)
  ) {
    return(encounter)
  }

  patient_birthdates <- getPatientBirthdateMap(patient)
  patient_ids <- extractFhirReferenceId(encounter[["enc_patient_ref"]], "Patient")
  birthdates <- patient_birthdates[
    match(patient_ids, patient_birthdates[["patient_id"]]),
    "birthdate"
  ][[1]]
  encounter[["enc_age_at_admission"]] <- calculateCompletedYears(
    encounter[["enc_period_start"]],
    birthdates
  )
  encounter
}

#' Enrich Snapshot Case Tables with Age and BMI
#'
#' Adds snapshot-specific case metrics before pseudonymization. `fall_fe` gets
#' BMI and age at case admission, while `encounter` gets age at encounter start.
#'
#' @param tables Named list of snapshot source tables.
#'
#' @return The table list with enriched case and encounter tables.
#' @export
enrichSnapshotCaseMetricTables <- function(tables) {
  for (suffix in c("", "_last_version")) {
    fall_table_name <- paste0("fall_fe", suffix)
    patient_fe_table_name <- paste0("patient_fe", suffix)
    if (!is.null(tables[[fall_table_name]])) {
      tables[[fall_table_name]] <- enrichSnapshotFallTable(
        tables[[fall_table_name]],
        tables[[patient_fe_table_name]]
      )
    }

    encounter_table_name <- paste0("encounter", suffix)
    patient_table_name <- paste0("patient", suffix)
    if (!is.null(tables[[encounter_table_name]])) {
      tables[[encounter_table_name]] <- enrichSnapshotEncounterTable(
        tables[[encounter_table_name]],
        tables[[patient_table_name]]
      )
    }
  }

  tables
}
