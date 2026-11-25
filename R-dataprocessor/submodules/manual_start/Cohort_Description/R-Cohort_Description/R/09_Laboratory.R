#' Prepare laboratory usability and reference-range flags once
#' @param observations Latest laboratory observations from the shared MRP loader.
#' @param mapping Quantitative INTERPOLAR LOINC mapping from getLOINCMapping().
#' @return Normalised patient events, retaining original codes for distinct counts.
prepareCohortLaboratory <- function(observations, mapping) {
  x <- data.table::copy(data.table::as.data.table(observations))
  mapping <- data.table::as.data.table(mapping)
  if (anyDuplicated(mapping$LOINC)) stop("LOINC mapping must contain unique source codes.")
  x[, `:=`(
    patient_id = etlutils::fhirdataExtractIDs(obs_patient_ref, unique = FALSE),
    code = obs_code_code, value_reference = NA_real_, compatible_unit = FALSE
  )]
  lookup <- match(x$code, mapping$LOINC)
  unit <- x$obs_valuequantity_code
  valid <- etlutils::isValidUnit(unit)
  unit[!valid %in% TRUE] <- x$obs_valuequantity_unit[!valid %in% TRUE]
  x[, `:=`(
    relevant = !is.na(lookup), unit_ok = etlutils::isValidUnit(unit) %in% TRUE,
    egfr = mapping$LOINC_PRIMARY[lookup] %in% "62238-1"
  )]
  x[, numeric_ok := unit_ok & is.finite(obs_valuequantity_value)]
  # Convert once per code/unit group; this reuses the same conversion utility as
  # MRP and snapshot enrichment, including analyte-specific mass/molar factors.
  groups <- data.table::data.table(code = x$code, unit = unit)
  groups[, group := .GRP, by = .(code, unit)]
  for (indices in split(seq_len(nrow(x)), groups$group)) {
    i <- indices[1]
    m <- lookup[i]
    if (is.na(m)) next
    factor <- suppressWarnings(as.numeric(mapping$CONVERSION_FACTOR[m]))
    conversion_unit <- mapping$CONVERSION_UNIT[m]
    if (isTRUE(factor == 1)) {
      factor <- NA_real_
      conversion_unit <- NA_character_
    }
    converted <- etlutils::convertLabUnits(x$obs_valuequantity_value[indices], unit[i],
      mapping$UNIT[m],
      conversion_factor = factor, conversion_unit = conversion_unit
    )
    compatible <- is.finite(etlutils::convertLabUnits(1, unit[i], mapping$UNIT[m],
      conversion_factor = factor, conversion_unit = conversion_unit
    ))
    x[indices, `:=`(value_reference = converted, compatible_unit = compatible)]
  }
  # Keep missing reference limits distinct from a documented normal result.
  low <- high <- rep(NA_real_, nrow(x))
  for (bound in c("low", "high")) {
    values <- x[[paste0("obs_referencerange_", bound, "_value")]]
    source_units <- x[[paste0("obs_referencerange_", bound, "_code")]]
    # An omitted range unit inherits the observation unit in the source data.
    source_units[is.na(source_units) | !nzchar(source_units)] <- unit[is.na(source_units) | !nzchar(source_units)]
    converted <- rep(NA_real_, nrow(x))
    combinations <- unique(data.table::data.table(source = source_units, target = unit))
    for (i in seq_len(nrow(combinations))) {
      indices <- which(source_units == combinations$source[i] & unit == combinations$target[i])
      if (length(indices)) converted[indices] <- etlutils::convertLabUnits(
        values[indices],
        combinations$source[i], combinations$target[i]
      )
    }
    if (bound == "low") low <- converted else high <- converted
  }
  has_range <- is.finite(low) | is.finite(high)
  contradictory <- is.finite(low) & is.finite(high) & low > high
  abnormal <- (is.finite(low) & x$obs_valuequantity_value < low) |
    (is.finite(high) & x$obs_valuequantity_value > high)
  abnormal[!has_range | contradictory | !x$numeric_ok] <- NA
  x[, `:=`(abnormal = abnormal, normal = !abnormal)]
  # For relevant parameters numeric usability additionally requires conversion
  # into the mapped reference unit. Raw values remain available for range checks.
  x
}
