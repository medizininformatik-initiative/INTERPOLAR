###################
# Unit Convertion #
###################

#' Clean and normalize unit strings for downstream parsing
#'
#' This helper function preprocesses a unit string for consistent handling. It
#' removes a trailing segment of the form `"/{...}"` at the end of the string
#' (e.g., `"mg/{dL}" -> "mg"`), replaces caret symbols (`^`) with asterisks (`*`)
#' (e.g., `"10^9 / L" -> "10*9/L"`), and removes all whitespace.
#' Note: The replacement of `^` with `*` reflects a textual normalization and
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

#' Check if unit strings are valid for the `units` package (vectorized)
#'
#' This helper function tests whether each element of a given character vector
#' can be parsed by the `units` package. It returns a logical vector of the same
#' length: `TRUE` for valid unit strings, `FALSE` otherwise.
#'
#' @param u Character vector. Unit strings (e.g., `"mmol/L"`, `"mg/dL"`).
#'
#' @return Logical vector of the same length as `u`.
#'
#' @examples
#' isValidUnit("mmol/L")                 # TRUE
#' isValidUnit(c("mmol/L", "foobar"))    # TRUE FALSE
#' isValidUnit(c("10^9/L", "10*9/L"))    # TRUE FALSE
#'
#' @export
isValidUnit <- function(u) {
  u <- as.character(u)
  u <- cleanUnit(u)
  vapply(u, function(x) {
    ok <- suppressWarnings(try(units::as_units(x), silent = TRUE))
    !inherits(ok, "try-error")
  }, logical(1))
}

#' Convert laboratory values into SI units
#'
#' This function converts laboratory measurements from a given input unit
#' into a specified target SI unit. If the input unit and target unit are
#' directly convertible via the `units` package, the function will use that.
#' Otherwise, it uses an intermediate conversion unit and a user-provided
#' mapping factor.
#'
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
                            additional_error_message = NA) {

  # Default is "symbols" but we need "standard", because "symbols" does'nt work in our cases
  # To set this globally outside this function doesnt work
  # This option is relevant for units::set_units() function
  units::units_options(set_units_mode = "standard")
  # Initialize result
  result <- NA
  tryCatch({
    measured_unit <- asUnit(measured_unit)
    target_unit <- asUnit(target_unit)

    # the provided FHIR unit is invalid -> the full Observations is invald
    if (is.na(measured_unit)) {
      return(NA)
    }
    # there is no conversion unit (and factor) -> no conversion needed -> return the original value
    if (is.na(target_unit)) {
      return(measured_value)
    }

    measured_unit_factor <- units::drop_units(measured_unit)
    target_unit_factor <- units::drop_units(target_unit)

    # Create unit object for measured value
    u_measured <- suppressWarnings(units::set_units(measured_value, measured_unit))

    # Create unit object for target unit
    u_target <- suppressWarnings(units::set_units(1, target_unit))

    # Case 1: Units are directly convertible
    if (units::ud_are_convertible(units(u_measured), units(u_target))) {
      result <- suppressWarnings(units::set_units(u_measured, u_target))
      result <- units::drop_units(result)
      result <- result * measured_unit_factor / target_unit_factor
    } else if (!etlutils::isSimpleNAorNULL(conversion_factor) && !etlutils::isSimpleNAorNULL(conversion_unit)) {
      # Create unit object for conversion unit
      u_conversion <- suppressWarnings(units::set_units(1, conversion_unit))

      # Case 2: Indirect conversion via mapping unit and factor
      result_u_conversion <- suppressWarnings(units::set_units(u_measured, u_conversion))

      if (!is.na(result_u_conversion)) {
        # Drop unit to apply mapping factor
        numeric_value <- units::drop_units(result_u_conversion)
        converted_value <- numeric_value * conversion_factor

        # Assign the target unit back
        result <- suppressWarnings(units::set_units(converted_value, u_target))
        result <- units::drop_units(result)
      }
    }
  }, error = function(e) {
    warning_message <- paste0("Error converting lab units from '",
                              as.character(units(u_measured)$numerator),
                              "' to '",
                              as.character(units(u_target)$numerator),
                              "': ",
                              additional_error_message)
    if (!ignore_errors) {
      etlutils::catErrorMessage(warning_message)
      stop(e)
    }
    etlutils::catWarningMessage(warning_message)
    result <- NA
  })
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
