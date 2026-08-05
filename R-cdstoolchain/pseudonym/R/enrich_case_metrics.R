SNAPSHOT_MINIMUM_BIRTHDATE <- as.Date("1910-01-01")

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
  age[
    is.na(reference_dates) |
      is.na(birth_dates) |
      birth_dates < SNAPSHOT_MINIMUM_BIRTHDATE |
      age < 0
  ] <- NA_real_
  as.integer(age)
}

emptyAgeCalculationReview <- function() {
  data.table::data.table(
    TABLE_NAME = character(),
    ISSUE_TYPE = character(),
    REDCAP_RECORD_ID = character(),
    FHIR_PATIENT_ID = character(),
    FHIR_ENCOUNTER_ID = character(),
    LOCAL_CASE_ID = character(),
    PATIENT_LOOKUP_KEY = character(),
    BIRTHDATE = as.Date(character()),
    REFERENCE_DATE = as.Date(character()),
    RAW_CALCULATED_AGE = integer(),
    N = integer()
  )
}

ageReviewColumn <- function(table, candidates) {
  column_name <- candidates[candidates %in% names(table)][1]
  if (length(column_name) == 0 || is.na(column_name)) {
    return(rep(NA_character_, nrow(table)))
  }
  as.character(table[[column_name]])
}

getAgeCalculationReview <- function(
  table,
  table_name,
  base_table_name,
  birthdates,
  matched_patient_keys = NULL
) {
  reference_column <- switch(
    base_table_name,
    fall_fe = "fall_aufn_dat",
    encounter = "enc_period_start",
    NULL
  )
  if (is.null(reference_column) || !reference_column %in% names(table)) {
    return(emptyAgeCalculationReview())
  }

  reference_dates <- as.Date(table[[reference_column]])
  birthdates <- as.Date(birthdates)
  matched_patient_keys <- as.character(matched_patient_keys)
  if (length(matched_patient_keys) == 0) {
    matched_patient_keys <- rep(NA_character_, nrow(table))
  }
  patient_not_found <- is.na(matched_patient_keys) | !nzchar(matched_patient_keys)
  issue_types <- rep(NA_character_, nrow(table))
  issue_types[patient_not_found] <- "patient_not_found"
  issue_types[is.na(birthdates) & is.na(issue_types)] <- "missing_birthdate"
  issue_types[is.na(reference_dates) & is.na(issue_types)] <- "missing_reference_date"
  issue_types[
    !is.na(birthdates) &
      birthdates < SNAPSHOT_MINIMUM_BIRTHDATE &
      is.na(issue_types)
  ] <- "birthdate_before_1910_01_01"
  issue_types[
    !is.na(reference_dates) &
      !is.na(birthdates) &
      reference_dates < birthdates &
      is.na(issue_types)
  ] <- "reference_date_before_birthdate"
  issue_rows <- which(!is.na(issue_types))
  if (length(issue_rows) == 0) {
    return(emptyAgeCalculationReview())
  }

  raw_age <- floor(as.numeric(difftime(reference_dates, birthdates, units = "days")) / 365.25)
  fhir_patient_ids <- if (identical(base_table_name, "encounter")) {
    extractFhirReferenceId(ageReviewColumn(table, "enc_patient_ref"), "Patient")
  } else {
    ageReviewColumn(table, "fall_pat_id")
  }
  fhir_encounter_ids <- if (identical(base_table_name, "encounter")) {
    ageReviewColumn(table, "enc_id")
  } else {
    ageReviewColumn(table, "fall_fhir_enc_id")
  }

  data.table::data.table(
    TABLE_NAME = table_name,
    ISSUE_TYPE = issue_types[issue_rows],
    REDCAP_RECORD_ID = ageReviewColumn(
      table,
      c("record_id", "patient_id_fk")
    )[issue_rows],
    FHIR_PATIENT_ID = fhir_patient_ids[issue_rows],
    FHIR_ENCOUNTER_ID = fhir_encounter_ids[issue_rows],
    LOCAL_CASE_ID = ageReviewColumn(table, "fall_id")[issue_rows],
    PATIENT_LOOKUP_KEY = matched_patient_keys[issue_rows],
    BIRTHDATE = birthdates[issue_rows],
    REFERENCE_DATE = reference_dates[issue_rows],
    RAW_CALCULATED_AGE = as.integer(raw_age[issue_rows]),
    N = 1L
  )
}

newBoundedAgeCalculationReview <- function(detail_limit = 1000L) {
  detail_limit <- suppressWarnings(as.integer(detail_limit))
  if (length(detail_limit) != 1 || is.na(detail_limit) || detail_limit < 1) {
    stop("detail_limit must be a positive integer.")
  }
  context <- new.env(parent = emptyenv())
  context$detail_limit <- detail_limit
  context$summary <- data.table::data.table(
    TABLE_NAME = character(),
    ISSUE_TYPE = character(),
    AFFECTED_ROWS = numeric()
  )
  context$examples <- emptyAgeCalculationReview()
  context
}

recordBoundedAgeCalculationReview <- function(context, report) {
  if (nrow(report) == 0) {
    return(invisible())
  }

  group_columns <- c("TABLE_NAME", "ISSUE_TYPE")
  chunk_summary <- sumDataTableColumnBy(
    report,
    group_columns = group_columns,
    value_column = "N",
    result_column = "AFFECTED_ROWS"
  )
  combined_summary <- data.table::rbindlist(list(context$summary, chunk_summary))
  context$summary <- sumDataTableColumnBy(
    combined_summary,
    group_columns = group_columns,
    value_column = "AFFECTED_ROWS",
    result_column = "AFFECTED_ROWS"
  )

  remaining_examples <- context$detail_limit - nrow(context$examples)
  if (remaining_examples > 0) {
    context$examples <- data.table::rbindlist(list(
      context$examples,
      utils::head(report, remaining_examples)
    ))
  }
  invisible()
}

finalizeBoundedAgeCalculationReview <- function(context) {
  data.table::setorderv(context$summary, c("TABLE_NAME", "ISSUE_TYPE"))
  data.table::setorderv(
    context$examples,
    c("TABLE_NAME", "ISSUE_TYPE", "FHIR_PATIENT_ID", "FHIR_ENCOUNTER_ID")
  )
  list(
    age_issue_summary = context$summary[],
    age_issue_examples = context$examples[]
  )
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

enrichSnapshotFallChunk <- function(
  fall_fe,
  birthdates = NULL,
  enrichment_columns = c("fall_age_at_admission", "fall_bmi"),
  source_columns = names(fall_fe)
) {
  fall_fe <- data.table::as.data.table(data.table::copy(fall_fe))
  if (
    "fall_age_at_admission" %in% enrichment_columns &&
    !"fall_age_at_admission" %in% names(fall_fe)
  ) {
    fall_fe[["fall_age_at_admission"]] <- NA_integer_
  }
  if ("fall_bmi" %in% enrichment_columns && !"fall_bmi" %in% names(fall_fe)) {
    fall_fe[["fall_bmi"]] <- NA_real_
  }

  if (
    "fall_age_at_admission" %in% enrichment_columns &&
    "fall_aufn_dat" %in% source_columns &&
    !is.null(birthdates) &&
    "fall_aufn_dat" %in% names(fall_fe)
  ) {
    fall_fe[["fall_age_at_admission"]] <- calculateCompletedYears(
      fall_fe[["fall_aufn_dat"]],
      birthdates
    )
  }

  bmi_columns <- c(
    "fall_gewicht_aktuell",
    "fall_gewicht_aktl_einheit",
    "fall_groesse",
    "fall_groesse_einheit"
  )
  if (
    "fall_bmi" %in% enrichment_columns &&
    all(bmi_columns %in% source_columns) &&
    all(bmi_columns %in% names(fall_fe))
  ) {
    fall_fe[["fall_bmi"]] <- calculateBmi(
      fall_fe[["fall_gewicht_aktuell"]],
      fall_fe[["fall_gewicht_aktl_einheit"]],
      fall_fe[["fall_groesse"]],
      fall_fe[["fall_groesse_einheit"]]
    )
  }

  fall_fe
}

enrichSnapshotEncounterChunk <- function(
  encounter,
  birthdates = NULL,
  enrichment_columns = "enc_age_at_admission",
  source_columns = names(encounter)
) {
  encounter <- data.table::as.data.table(data.table::copy(encounter))
  if (
    "enc_age_at_admission" %in% enrichment_columns &&
    !"enc_age_at_admission" %in% names(encounter)
  ) {
    encounter[["enc_age_at_admission"]] <- NA_integer_
  }
  if (
    "enc_age_at_admission" %in% enrichment_columns &&
    "enc_period_start" %in% source_columns &&
    !is.null(birthdates) &&
    "enc_period_start" %in% names(encounter)
  ) {
    encounter[["enc_age_at_admission"]] <- calculateCompletedYears(
      encounter[["enc_period_start"]],
      birthdates
    )
  }
  encounter
}
