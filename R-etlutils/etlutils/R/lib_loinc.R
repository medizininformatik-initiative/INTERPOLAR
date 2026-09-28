###################
# Unit Convertion #
###################

#' Clean and normalize unit strings for downstream parsing
#'
#' This helper function preprocesses a unit string for consistent handling. It
#' removes a trailing segment of the form `"/{...}"` at the end of the string
#' (e.g., `"mg/{dL}" -> "mg"`), replaces asterisks (`*`) with caret symbols (`^`)
#' (e.g., `"10*9 / L" -> "10^9/L"`), and removes all whitespace.
#' Note: The replacement of `*` with `^` reflects a textual normalization and
#' does not implement a full UCUM/UDUNITS conversion.
#'
#' @param unit Character. A unit string to be cleaned and normalized.
#'
#' @return A cleaned and normalized character string.
#'
#' @examples
#' cleanUnit("mg/{dL}")      # "mg"
#' cleanUnit("10^9 / L")     # "10^9/L"
#' cleanUnit(" mol / L ")    # "mol/L"
#' cleanUnit("kg / m * 2")   # "kg/m^2"
#' cleanUnit("m2/{1.73_m2}") # "m2"
#'
#' @export
cleanUnit <- function(unit) {
  # Remove any curly braces from the unit (e.g., "{1.73_m2}" -> "1.73_m2")
  unit <- sub("/\\{[^/]+\\}$", "", unit)
  # Convert caret to multiplication for units package compatibility
  unit <- gsub("\\*", "^", unit)
  # Remove whitespaces
  unit <- gsub("\\s+", "", unit)
  return(unit)
}

#' Convert a Character Unit String to a `units` Object
#'
#' This helper function attempts to convert a given unit string into a
#' `units` object using the `units::as_units()` function. If the conversion
#' fails (for example, if the unit string is invalid or not supported), the
#' function returns `NA` instead of throwing an error.
#'
#' @param unit Character. A unit string to convert (e.g., `"mmol/L"`, `"kg/m^2"`).
#'
#' @return A `units` object if the conversion succeeds, otherwise `NA`.
#'
#' @examples
#' asUnit("mmol/L")    # valid unit, returns a units object
#' asUnit("10^9/L")    # valid for UDUNITS syntax
#' asUnit("10*9/L")    # valid for UDUNITS, returns NA
#' asUnit("foobar")    # invalid unit, returns NA
#'
#' @export
asUnit <- function(unit) {
  unit <- cleanUnit(unit)
  ok <- try(units::as_units(unit), silent = TRUE)
  return(if (inherits(ok, "try-error")) NA else ok)
}

#' Check if unit strings are supported for lab unit conversion (vectorized)
#'
#' This helper function tests whether each element of a given character vector
#' can be parsed by the `units` package or the supported UCUM families (pressure
#' columns, osmoles, annotations and international-unit quotients). This tests
#' converter support, not complete UCUM validity. It returns a logical vector of
#' the same length: `TRUE` for supported unit strings, `FALSE` otherwise.
#'
#' @param u Character vector. Unit strings (e.g., `"mmol/L"`, `"mg/dL"`).
#' @param unit_cache Optional environment for parsed units, scoped to one processing run.
#'
#' @return Logical vector of the same length as `u`.
#'
#' @examples
#' isValidUnit("mmol/L")                 # TRUE
#' isValidUnit(c("mmol/L", "foobar"))    # TRUE FALSE
#' isValidUnit(c("10^9/L", "10*9/L"))    # TRUE TRUE
#' isValidUnit(c("ng/L", "mU/L"))        # TRUE TRUE
#' isValidUnit(c("U/L", "uU/mL"))        # TRUE TRUE
#' isValidUnit("m[iU]/L")                # TRUE
#'
#' @export
isValidUnit <- function(u, unit_cache = NULL) {
  distinct_units <- unique(u)
  valid <- vapply(distinct_units, function(x) {
    !is.null(parseConvertibleUnit(x, unit_cache))
  }, logical(1), USE.NAMES = FALSE)
  result <- valid[match(u, distinct_units)]
  names(result) <- if (is.null(names(u)) && is.character(u)) u else names(u)
  result
}

# UCUM metric prefixes, shared by the bounded unit-family translations below.
LAB_UNIT_PREFIX_FACTORS <- stats::setNames(
  10^c(0, 24, 21, 18, 15, 12, 9, 6, 3, 2, 1, -1, -2, -3, -6, -9, -12, -15, -18, -21, -24),
  c("", "Y", "Z", "E", "P", "T", "G", "M", "k", "h", "da", "d", "c", "m", "u", "n", "p", "f", "a", "z", "y")
)
LAB_UNIT_PREFIX_PATTERN <- "(da|[YZEPTGMkhdcmunpfazy]?)"

parseSimpleInternationalUnitQuotient <- function(unit) {
  unit <- cleanUnit(unit)
  unit <- gsub("\u00b5", "u", unit, fixed = TRUE)
  matches <- regexec(paste0(
    "^", LAB_UNIT_PREFIX_PATTERN, "(U|IU|\\[IU\\]|\\[iU\\])/",
    LAB_UNIT_PREFIX_PATTERN, "[Ll]$"
  ), unit)
  parts <- regmatches(unit, matches)[[1]]
  if (length(parts) != 4) {
    return(NULL)
  }
  list(
    atom = "IU",
    factor = unname(LAB_UNIT_PREFIX_FACTORS[match(parts[2], names(LAB_UNIT_PREFIX_FACTORS))] /
      LAB_UNIT_PREFIX_FACTORS[match(parts[4], names(LAB_UNIT_PREFIX_FACTORS))])
  )
}

# This is a translation of selected UCUM families, not a general UCUM parser.
# Definitions: https://ucum.org/ucum, sections 6, 27, 44 and 45.
parseLabUcumUnit <- function(unit) {
  pressure <- regmatches(unit, regexec(paste0(
    "^", LAB_UNIT_PREFIX_PATTERN, "m\\[(Hg|H2O)\\]$"
  ), unit))[[1]]
  if (length(pressure) == 3) {
    prefix_factor <- unname(LAB_UNIT_PREFIX_FACTORS[match(pressure[2], names(LAB_UNIT_PREFIX_FACTORS))])
    # Reuse UDUNITS' existing mmHg definition so aliases have identical values.
    definition <- if (pressure[3] == "Hg") {
      paste(format(prefix_factor * 1000, scientific = FALSE, trim = TRUE, digits = 22), "mmHg")
    } else {
      paste(format(prefix_factor * 9806.65, scientific = FALSE, trim = TRUE, digits = 22), "Pa")
    }
    return(asUnit(definition))
  }
  if (grepl("^\\{[^{}]+\\}$", unit)) {
    return(asUnit("1"))
  }
  if (grepl("^%\\{[^{}]+\\}$", unit)) {
    return(asUnit("%"))
  }
  osmole <- regmatches(unit, regexec(paste0(
    "^", LAB_UNIT_PREFIX_PATTERN, "osm(/(", LAB_UNIT_PREFIX_PATTERN, "[Ll]|kg|g))?$"
  ), unit))[[1]]
  if (length(osmole) > 0) {
    return(asUnit(sub("osm", "mol", unit, fixed = TRUE)))
  }
  NA
}

convertSimpleInternationalUnitQuotient <- function(measured_value, measured_unit, target_unit) {
  measured_unit <- parseSimpleInternationalUnitQuotient(measured_unit)
  target_unit <- parseSimpleInternationalUnitQuotient(target_unit)
  if (is.null(measured_unit) || is.null(target_unit) || measured_unit$atom != target_unit$atom) {
    return(NA_real_)
  }

  measured_value * measured_unit$factor / target_unit$factor
}

parseConvertibleUnit <- function(unit, unit_cache = NULL) {
  if (isMissingUnit(unit)) {
    return(NULL)
  }
  cache_key <- paste0("unit:", unit)
  if (!is.null(unit_cache) && exists(cache_key, envir = unit_cache, inherits = FALSE)) {
    return(get(cache_key, envir = unit_cache, inherits = FALSE))
  }
  parsed <- parseConvertibleUnitUncached(unit)
  if (!is.null(unit_cache)) {
    assign(cache_key, parsed, envir = unit_cache)
  }
  parsed
}

parseConvertibleUnitUncached <- function(unit) {
  parsed_units <- asUnit(unit)
  if (!is.na(parsed_units)) {
    return(list(type = "units", value = parsed_units))
  }

  parsed_ucum <- parseLabUcumUnit(unit)
  if (!is.na(parsed_ucum)) {
    return(list(type = "units", value = parsed_ucum))
  }

  parsed_iu_quotient <- parseSimpleInternationalUnitQuotient(unit)
  if (!is.null(parsed_iu_quotient)) {
    return(list(type = "simple_international_unit_quotient", value = parsed_iu_quotient))
  }

  NULL
}

isMissingUnit <- function(unit) {
  etlutils::isSimpleNAorNULL(unit) ||
    (is.character(unit) && length(unit) == 1 && !nzchar(trimws(unit)))
}

#' Convert laboratory values into SI units
#'
#' This function converts laboratory measurements from a given input unit
#' into a specified target SI unit. If the input unit and target unit are
#' directly convertible via the `units` package, the function will use that.
#' Otherwise, it uses an intermediate conversion unit and a user-provided
#' mapping factor.
#'
#' @param unit_cache Optional environment for parsed units, scoped to one processing run.
#' @param measured_value Numeric. The raw measurement value.
#' @param measured_unit Character. The unit of the input value
#'   (e.g., `"mg/dl"`, `"mmol/l"`).
#' @param target_unit Character. The desired SI target unit
#'   (e.g., `"mmol/l"`, `"umol/l"`).
#' @param conversion_factor Numeric (optional).
#'   The factor needed to convert from the conversion_unit to the
#'   target_unit (used only if direct conversion is not possible).
#' @param conversion_unit Character (optional).
#'   The intermediate unit used for conversion
#'   (e.g., `"mg/dl"`, `"U/l"`).
#' @param ignore_errors Logical (default: `TRUE`).
#'  If `TRUE`, conversion errors will be caught and a warning
#' @param additional_error_message Character (optional).
#' Additional context to include in error/warning messages.
#'
#' @return Numeric. The value converted into the target unit (without unit object).
#'
#' @examples
#' # Example: Convert 14 mg/dL to mmol/L using a mapping factor
#' convertLabUnits(
#'   measured_value = 14,
#'   measured_unit = "mg/dl",
#'   target_unit = "mmol/l",
#'   conversion_factor = 0.621,
#'   conversion_unit = "mg/dl"
#' )
#'
#' convertLabUnits(
#'   measured_value = 14,
#'   measured_unit = "ukat/mm^3",
#'   target_unit = "ukat/L",
#'   conversion_factor = 0.621,
#'   conversion_unit = "mg/dl"
#' )
#'
#' convertLabUnits(
#'   measured_value = 14,
#'   measured_unit = "invlaid_unit",
#'   target_unit = "ukat/L",
#'   conversion_factor = 0.621,
#'   conversion_unit = "mg/dl"
#' )
#'
#' convertLabUnits(
#'   measured_value = 14,
#'   measured_unit = "L/h/{1.73_m2}",
#'   target_unit = "mL/min",
#'   conversion_factor = 1,
#'   conversion_unit = "mL/min"
#' )
#'
#' # Example: Direct unit conversion mmol/L to umol/L
#' convertLabUnits(
#'   measured_value = 1,
#'   measured_unit = "mmol/l",
#'   target_unit = "umol/l"
#' )
#'
#' # Example: Direct unit conversion mmol/L to umol/L
#' convertLabUnits(
#'   measured_value = 1,
#'   measured_unit = "%",
#'   target_unit = "mmol/L",
#'   conversion_factor = 50,
#'   conversion_unit = "mmHg",
#'   additional_error_message = "Custom error message for debugging."
#' )
#' @export
convertLabUnits <- function(measured_value,
                            measured_unit,
                            target_unit,
                            conversion_factor = NA_real_,
                            conversion_unit = NA,
                            ignore_errors = TRUE,
                            additional_error_message = NA,
                            unit_cache = NULL) {
  # Default is "symbols" but we need "standard", because "symbols" does'nt work in our cases
  # To set this globally outside this function doesnt work
  # This option is relevant for units::set_units() function
  units::units_options(set_units_mode = "standard")
  # Initialize the result vector
  result <- rep(NA_real_, length(measured_value))
  measured_unit_raw <- measured_unit
  target_unit_raw <- target_unit
  target_unit_missing <- isMissingUnit(target_unit_raw)
  tryCatch(
    {
      # there is no conversion unit (and factor) -> no conversion needed
      # -> return the original value
      if (target_unit_missing) {
        return(measured_value)
      }

      measured_unit <- parseConvertibleUnit(measured_unit_raw, unit_cache)
      target_unit <- parseConvertibleUnit(target_unit_raw, unit_cache)

      # Invalid FHIR units produce missing conversion results
      if (is.null(measured_unit) || is.null(target_unit)) {
        return(result)
      }

      if (
        measured_unit$type == "simple_international_unit_quotient" ||
        target_unit$type == "simple_international_unit_quotient"
      ) {
        if (
          measured_unit$type == target_unit$type &&
          measured_unit$value$atom == target_unit$value$atom
        ) {
          result <- measured_value * measured_unit$value$factor / target_unit$value$factor
        }
        if (
          measured_unit$type != target_unit$type &&
          !etlutils::isSimpleNAorNULL(conversion_factor) &&
          !isMissingUnit(conversion_unit)
        ) {
          # Only the explicitly supplied mapping factor may bridge unit families.
          result <- convertLabUnits(
            measured_value, measured_unit_raw, conversion_unit,
            ignore_errors = ignore_errors,
            additional_error_message = additional_error_message,
            unit_cache = unit_cache
          ) * conversion_factor
        }
        return(result)
      }

      measured_unit_factor <- units::drop_units(measured_unit$value)
      target_unit_factor <- units::drop_units(target_unit$value)

      # Create unit object for measured value
      u_measured <- suppressWarnings(units::set_units(measured_value, measured_unit$value))

      # Create unit object for target unit
      u_target <- suppressWarnings(units::set_units(1, target_unit$value))

      # Case 1: Units are directly convertible
      if (units::ud_are_convertible(units(u_measured), units(u_target))) {
        result <- suppressWarnings(units::set_units(u_measured, u_target))
        result <- units::drop_units(result)
        result <- result * measured_unit_factor / target_unit_factor
      } else if (
        !etlutils::isSimpleNAorNULL(conversion_factor) &&
          !etlutils::isSimpleNAorNULL(conversion_unit)
      ) {
        # Resolve the mapping input with the same UCUM support and numeric scaling.
        result <- convertLabUnits(
          measured_value, measured_unit_raw, conversion_unit,
          ignore_errors = ignore_errors,
          additional_error_message = additional_error_message,
          unit_cache = unit_cache
        ) * conversion_factor
      }
    },
    error = function(e) {
      error_context <- if (etlutils::isSimpleNAorNULL(additional_error_message)) {
        ""
      } else {
        additional_error_message
      }
      warning_message <- paste0(
        "Error converting lab units from '",
        measured_unit_raw,
        "' to '",
        target_unit_raw,
        "': ",
        conditionMessage(e),
        error_context
      )
      if (!ignore_errors) {
        etlutils::catErrorMessage(warning_message)
        stop(e)
      }
      etlutils::catWarningMessage(warning_message)
      result <- NA
    }
  )
  return(result)
}

# #10*9/L	nur dezimal notwendig	10*6/L
# aaa <- convertLabUnits(
#   measured_value = 14,
#   measured_unit = "10 * 6/mL",
#   target_unit = "10^9/L",
# )

# #10*9/L	nur dezimal notwendig	10*6/L
# aaa <- convertLabUnits(
#   measured_value = 14,
#   measured_unit = "mol/L",
#   target_unit = "mmol/L",
# )

# #10*9/L	nur dezimal notwendig	10*6/L
# bbb <- convertLabUnits(
#   measured_value = 14,
#   measured_unit = "10^3/L",
#   target_unit = "10^6/mL"
# )
