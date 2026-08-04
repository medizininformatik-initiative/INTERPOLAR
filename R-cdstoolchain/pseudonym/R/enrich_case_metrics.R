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
