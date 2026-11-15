#' Expand the given ICD Code.
#'
#' This function expands an ICD code by retrieving corresponding labels for the provided ICD codes.
#' It filters the results to include only those codes that have the same prefix as the input ICD code.
#'
#' @param icd The ICD code to be expanded.
#' @param minyear the minimum year to search for the codes in the ICD database. NA is default and means current year.
#' @param maxyear the maximum year to search for the codes in the ICD database. NA is default and means current year.
#' @param fullExpanded logical. If TRUE then only full expanded codes will be returned.
#' @param normcodesOnly logical. Only relevant if fullExpanded is FALSE. If TRUE then codes with bars like 'A21.-' will be returned too.
#'
#' @return A character vector containing the expanded ICD codes.
#'
#' @examples
#' # Example usage:
#' print(expandICD('I25'))
#' print(expandICD('I25', 2018, 2021, fullExpanded = FALSE, normcodesOnly = TRUE))
#' print(expandICD('I25', 2018, 2021, fullExpanded = FALSE, normcodesOnly = FALSE))
#'
#' @export
expandICD <- function(icd, minyear = NA, maxyear = NA, fullExpanded = TRUE, normcodesOnly = TRUE) {
  # Extract the first 3 characters of the ICD code
  icd3 <- substr(icd, 1, 3)
  # Load history table of ICD 10 codes from package ICD10gm
  ICD_history_table <- ICD10gm::get_icd_history()
  # Extract rows with relevant ICD10 Codes
  ICD_history_table <- ICD_history_table[ICD_history_table$icd3 == icd3, ]
  if (is.na(minyear)) {
    minyear <- max(ICD_history_table$year_from)
  }
  if (is.na(maxyear)) {
    # Find maximum year of ICD10 Code history
    maxyear <- max(ICD_history_table$year_to)
  }

  if (minyear < 0 || maxyear < 0) {
    icd_codes <- NULL
    catInfoMessage(paste0("ICD-Code: ", icd3, " is not valid. Please check!"))
    return()
  }

  getICDCode <- function(year) {
    # Get ICD labels for the first 3 characters
    expand_icd_code <- ICD10gm::get_icd_labels(year = year, icd3 = icd3)$icd_normcode
    # Filter the results based on the input ICD code
    expand_icd <- expand_icd_code[startsWith(expand_icd_code, icd)]
    if (fullExpanded) {
      for (i in seq_len(length(expand_icd) - 1)) {
        if (startsWith(expand_icd[i + 1], expand_icd[i])) {
          expand_icd[i] <- NA
        }
      }
      expand_icd <- na.omit(expand_icd)
    } else {
      # should the code with this style 'A00.-' added too?
      if (!normcodesOnly) {
        expand_icd_code <- ICD10gm::get_icd_labels(year = year, icd3 = icd3)$icd_code
        expand_icd <- c(expand_icd, expand_icd_code[startsWith(expand_icd_code, icd)])
      }
      unique(expand_icd)
    }
  }
  # build the full codes list
  icd_codes <- c()
  for (year in minyear:maxyear) {
    icd_codes <- c(icd_codes, getICDCode(year))
  }
  sort(unique(icd_codes))
}

#' Load Official Terminal OPS Codes by Catalogue Year
#'
#' Loads the complete terminal-code ValueSet expansions from the unmodified BfArM
#' FHIR packages bundled in inst/extdata/ops. No network or global configuration is
#' used. Load once and reuse the result across tables and population groups.
#'
#' @param years Catalogue years to load, as integers or four-digit strings.
#'   The bundled catalogues cover 2023 through 2026.
#' @return A data.frame with year (integer), code and display (character).
#' @export
loadOPSCatalogues <- function(years = 2023:2026) {
  loadTerminalCatalogues(years, "ops")
}

#' Load Official Terminal ICD-10-GM Codes by Catalogue Year
#'
#' Loads complete annual terminal-code ValueSet expansions from the unmodified
#' BfArM FHIR packages bundled in inst/extdata/icd10gm, without network access.
#' @param years Catalogue years, as integers or four-digit strings, from 2023 to 2026.
#' @return A data.frame with year, code and display columns.
#' @export
loadICDCatalogues <- function(years = 2023:2026) {
  loadTerminalCatalogues(years, "icd10gm")
}

# Shared archive validation keeps OPS and ICD completeness checks identical.
loadTerminalCatalogues <- function(years, classification) {
  years <- as.character(years)
  if (!length(years) || anyNA(years) || any(!years %in% as.character(2023:2026))) {
    stop("Catalogues are available for 2023, 2024, 2025 and 2026 only.")
  }
  years <- sort(unique(as.integer(years)))
  directory <- system.file("extdata", classification, package = "etlutils", mustWork = TRUE)
  manifest <- jsonlite::fromJSON(file.path(directory, "sources.json"))$catalogues
  value_set <- if (classification == "ops") "ops-terminale-kodes" else "icd10gm-terminale-codes"
  code_system <- if (classification == "ops") "ops" else "icd-10-gm"
  temporary <- tempfile("terminal-catalogue-")
  dir.create(temporary)
  on.exit(unlink(temporary, recursive = TRUE), add = TRUE)
  result <- lapply(years, function(year) {
    entry <- manifest[manifest$year == year, ]
    if (nrow(entry) != 1L) stop("Missing or ambiguous terminal catalogue manifest entry.")
    member <- paste0("package/ValueSet-", value_set, "-", year, ".json")
    archive <- file.path(directory, entry$file)
    utils::untar(archive, files = member, exdir = temporary, tar = "internal")
    resource <- jsonlite::fromJSON(file.path(temporary, member))
    expansion <- resource$expansion
    codes <- expansion$contains
    if (
      !identical(resource$resourceType, "ValueSet") ||
      !identical(resource$url, paste0("https://terminologien.bfarm.de/fhir/ValueSet/", value_set)) ||
      !identical(resource$version, as.character(year)) ||
      !is.data.frame(codes) || !all(c("system", "version", "code", "display") %in% names(codes))
    ) {
      stop("Unexpected terminal ValueSet structure for ", year, ".")
    }
    if (
      anyNA(codes$code) || any(!nzchar(codes$code)) || anyDuplicated(codes$code) ||
      anyNA(codes$version) || any(codes$version != as.character(year)) ||
      anyNA(codes$system) || any(codes$system != paste0("http://fhir.de/CodeSystem/bfarm/", code_system)) ||
      !identical(expansion$offset, 0L) ||
      !identical(expansion$total, as.integer(nrow(codes))) ||
      nrow(codes) != entry$terminal_count
    ) {
      stop("Incomplete or inconsistent terminal ValueSet for ", year, ".")
    }
    data.frame(
      year = rep(year, nrow(codes)), code = codes$code, display = codes$display,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, result)
}

#' Check OPS Endständigkeit Against the Applicable Annual Catalogue
#'
#' Uses exact code/year membership, not code length or prefix matching. FALSE means
#' the code is not in that year's terminal list (it may be a parent or nonexistent
#' code). This does not validate clinical coding rules or additional side markers.
#'
#' @param codes Character vector of documented OPS codes in canonical notation.
#' @param years Catalogue year per code, or one year for all codes. Missing years
#'   remain unknown; year selection belongs to the calling analysis.
#' @param catalogue Output of loadOPSCatalogues(), loaded once by the caller.
#' @return Logical vector aligned with codes. Missing/blank codes or years yield NA.
#'   Malformed years and years absent from catalogue raise an error.
#' @export
isTerminalOPS <- function(codes, years, catalogue) {
  isTerminalCode(codes, years, catalogue)
}

#' Check ICD-10-GM Endständigkeit Against an Annual Catalogue
#'
#' Tests exact annual membership rather than length. Removes a final coding
#' marker (!, + or *) before lookup; no other code characters are changed.
#' @param codes Documented ICD-10-GM codes as a character vector.
#' @param years One catalogue year or one year per code; missing years remain unknown.
#' @param catalogue Output of loadICDCatalogues().
#' @return A logical vector. Missing codes or years yield NA. Unloaded years raise an error.
#' @export
isTerminalICD <- function(codes, years, catalogue) {
  if (!is.character(codes)) stop("ICD codes must be a character vector.")
  isTerminalCode(sub("[!+*]$", "", codes), years, catalogue)
}

isTerminalCode <- function(codes, years, catalogue) {
  if (!is.character(codes)) stop("Codes must be a character vector.")
  if (length(years) != 1L && length(years) != length(codes)) {
    stop("Provide one catalogue year or one year per code.")
  }
  if (!is.data.frame(catalogue) || !all(c("year", "code") %in% names(catalogue))) {
    stop("catalogue must contain year and code columns.")
  }
  years <- rep(as.character(years), length.out = length(codes))
  missing_year <- is.na(years) | !nzchar(trimws(years))
  if (any(!missing_year & !grepl("^[0-9]{4}$", years))) {
    stop("Catalogue years must be four-digit years.")
  }
  if (any(!missing_year & !years %in% as.character(catalogue$year))) {
    stop("Requested Catalogue year has not been loaded.")
  }
  known <- !missing_year & !is.na(codes) & nzchar(trimws(codes))
  result <- rep(NA, length(codes))
  result[known] <- paste(years[known], codes[known], sep = ":") %in%
    paste(catalogue$year, catalogue$code, sep = ":")
  result
}

#' Expand the given ICD Codes.
#'
#' This function expands ICD codes by retrieving corresponding labels for the provided ICD codes.
#' It filters the results to include only those codes that have the same prefix as the input ICD codes.
#'
#' @param icdCodes The ICD code to be expanded.
#' @param minyear the minimum year to search for the codes in the ICD database. NA is default and means current year.
#' @param maxyear the maximum year to search for the codes in the ICD database. NA is default and means current year.
#' @param fullExpanded logical. If TRUE then only full expanded codes will be returned.
#' @param normcodesOnly logical. Only relevant if fullExpanded is FALSE. If TRUE then codes with bars like 'A21.-' will be returned too.
#'
#' @return A character vector containing the expanded ICD codes.
#'
#' @examples
#' # Example usage:
#' print(expandICDs(c('I25', 'A90')))
#' print(expandICDs('I25', 2018, 2021, fullExpanded = FALSE, normcodesOnly = TRUE))
#' print(expandICDs('I25', 2018, 2021, fullExpanded = FALSE, normcodesOnly = FALSE))
#'
#' @export
expandICDs <- function(icdCodes, minyear = NA, maxyear = NA, fullExpanded = FALSE, normcodesOnly = FALSE) {
  icd_codes <- c()
  for (icd in icdCodes) {
    icd_codes <- c(icd_codes, expandICD(icd, minyear, maxyear, fullExpanded, normcodesOnly))
  }
  sort(unique(icd_codes))
}

# https://stackoverflow.com/questions/69947452/regex-boundary-to-also-exclude-special-characters
# These are PERL Patterns -> works only for grep with perl = TRUE
patternw <- function(pattern) paste0("(?<!\\S)", pattern, "(?!\\S)")

#####################
### ATC (and PZN) ###
#####################

# All patterns for valid ATC codes.
# https://www.wido.de/publikationen-produkte/analytik/arzneimittel-klassifikation/
SIMPLE_ATC_PATTERN <- list(
  ATC1 = "[A-Z]",
  # ATC2 is not a valid ATC code
  ATC3 = "[A-Z][0-9]{2}",
  ATC4_5 = "[A-Z][0-9]{2}[A-Z]{1,2}",
  # ATC6 is not a valid ATC code
  ATC7 = "[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}"
)

# All patterns for valid ATC codes in word boundaries.
WORD_ATC_PATTERN <- list(
  ATC1 = patternw(SIMPLE_ATC_PATTERN$ATC1),
  # ATC2 is not a valid ATC code
  ATC3 = patternw(SIMPLE_ATC_PATTERN$ATC3),
  ATC4_5 = patternw(SIMPLE_ATC_PATTERN$ATC4_5),
  # ATC6 is not a valid ATC code
  ATC7 = patternw(SIMPLE_ATC_PATTERN$ATC7)
)

# medication codes pattern list
# used in scrips merge_medications_statements/administrations and in function polar_stats_med_code
MED_CODES_PATTERN <- list(
  ATCsystem = "atc",
  ATC7 = WORD_ATC_PATTERN$ATC7,
  ATCsmaller7 = paste(
    WORD_ATC_PATTERN$ATC4_5, WORD_ATC_PATTERN$ATC3, WORD_ATC_PATTERN$ATC1,
    sep = "|"
  ),
  ATCgreater7 = patternw("[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}\\S+"), # accepts more chars after a valid ATC7 code which are not whitespaces
  ATC7orSmaller = paste(
    WORD_ATC_PATTERN$ATC7, WORD_ATC_PATTERN$ATC4_5, WORD_ATC_PATTERN$ATC3, WORD_ATC_PATTERN$ATC1,
    sep = "|"
  ),
  PZNsystem = "pzn",
  PZN8 = patternw("[0-9]{8}"),
  PZN8orSmaller = patternw("[0-9]{7,8}")
)

# #Tests for MED_CODES_PATTERN
# TEST_ATC <- c('AB01.','A01.', 'AB01C', 'B01C', 'AA01BB23', 'A01BB234asas', 'AASASASASSAA0123BB', 'B01CB2', 'B01CB22', 'A00BC11 asl', 'A00BC11.asl', 'A00BC11.asl PZNCODE', ' Z01')
#
# TEST_ATC[greplic(MED_CODES_PATTERN$ATC7, TEST_ATC)]
# TEST_ATC[greplic(MED_CODES_PATTERN$ATC7orSmaller, TEST_ATC)]
# TEST_ATC[greplic(MED_CODES_PATTERN$ATCsmaller7, TEST_ATC)]
# TEST_ATC[greplic(MED_CODES_PATTERN$ATCgreater7, TEST_ATC)]

#' Check if codes match the ATC7 pattern or smaller.
#'
#' This function determines whether the input codes match the ATC7 pattern or smaller
#' defined in the `MED_CODES_PATTERN` object, while ignoring `NA` values.
#'
#' @param codes A character vector of codes to check.
#'
#' @return A logical vector indicating whether each code matches the ATC7 pattern.
#' `NA` values in the input will remain `NA` in the output.
#'
#' @details The function uses a regular expression from `MED_CODES_PATTERN$ATC7orSmaller`
#' to validate if the provided codes conform to the ATC7 format.
#'
#' @examples
#' # Example usage:
#' codes <- c("A01AB07", "B03AA", "I", NA)
#' isATC7orSmaller(codes)
#' # Returns: TRUE, TRUE, TRUE, FALSE
#'
#' @export
isATC7orSmaller <- function(codes) {
  grepl(MED_CODES_PATTERN$ATC7orSmaller, codes, perl = TRUE)
}

#' Check if codes match the ATC7 pattern.
#'
#' This function determines whether the input codes match the ATC7 pattern
#' defined in the `MED_CODES_PATTERN` object, while ignoring `NA` values.
#'
#' @param codes A character vector of codes to check.
#'
#' @return A logical vector indicating whether each code matches the ATC7 pattern.
#' `NA` values in the input will remain `NA` in the output.
#'
#' @details The function uses a regular expression from `MED_CODES_PATTERN$ATC7`
#' to validate if the provided codes conform to the ATC7 format.
#'
#' @examples
#' # Example usage:
#' codes <- c("A01AB07", "B03AA02", "INVALID", NA)
#' isATC(codes)
#' # Returns: TRUE, TRUE, FALSE, NA
#'
#' @export
isATC <- function(codes) {
  ifelse(is.na(codes), NA, grepl(MED_CODES_PATTERN$ATC7, codes, perl = TRUE))
}

#' Validate LOINC Codes
#'
#' This function checks if the input values are valid LOINC codes.
#'
#' @param codes A character vector of codes to validate.
#'
#' @return A logical vector indicating whether each code is a valid LOINC code.
#'
#' @details A valid LOINC code matches the pattern `^\d{1,6}-\d$`:
#' - 1 to 6 digits
#' - Followed by a hyphen (`-`)
#' - Ending with exactly 1 digit.
#'
#' @examples
#' codes <- c("12345-6", "987-2", "INVALID", NA)
#' isLOINC(codes)
#' # Returns: TRUE, TRUE, FALSE, NA
#'
#' @export
isLOINC <- function(codes) {
  ifelse(is.na(codes), NA, grepl("^\\d{1,6}-\\d$", codes, perl = TRUE))
}

###########
### ICD ###
###########

# https://stackoverflow.com/questions/69947452/regex-boundary-to-also-exclude-special-characters
# These are PERL Patterns -> works only for grep with perl = TRUE
SIMPLE_ICD_PATTERN <- list(
  ICD1 = "[A-Z]",
  ICD2_3 = "[A-Z][0-9]{1,2}",
  ICD4_6 = "[A-Z][0-9]{2}\\.[0-9]{0,2}"
)

WORD_ICD_PATTERN <- list(
  ICD1 = patternw(SIMPLE_ICD_PATTERN$ICD1),
  ICD2_3 = patternw(SIMPLE_ICD_PATTERN$ICD2_3),
  ICD4_6 = patternw(SIMPLE_ICD_PATTERN$ICD4_6)
)

ICD_CODES_PATTERN <- list(
  ICD6orSmaller = paste(WORD_ICD_PATTERN$ICD4_6, WORD_ICD_PATTERN$ICD2_3, WORD_ICD_PATTERN$ICD1, sep = "|")
)

# # Tests for ICD_CODES_PATTERN
# TEST_ICD <- c('A', 'A0', 'A01', 'A01.', 'A01.2', 'A01.23', 'AA01.', 'A1.', 'A01.234sdgfsdfsdf', '.A0')
# TEST_ICD <- c('A B C', 'A0 B1 C1', 'A01 B02 C03', 'A01. B02. C03.', 'A01.2 B01.2 C01.2', 'A01.23 B01.23 C01.23', 'AA01. BB01. CC01.', 'A1. B1. C1.', 'A01.234 B01.234 C01.234')
# TEST_ICD[greplic(WORD_ICD_PATTERN$ICD1, TEST_ICD)]
# TEST_ICD[greplic(WORD_ICD_PATTERN$ICD2_3, TEST_ICD)]
# TEST_ICD[greplic(WORD_ICD_PATTERN$ICD4_6, TEST_ICD)]
# TEST_ICD[greplic(ICD_CODES_PATTERN$ICD6orSmaller, TEST_ICD)]

getCodes <- function(codesColumnName, ...) {
  codes_pattern <- paste0(paste0("^", c(...)), collapse = "|")
}

getATC <- function(...) {
  getCodes("atc", ...)
}

getICD <- function(...) {
  getCodes("icd", ...)
}

catEmptyCodeWarnings <- function(list) {
  for (i in 1:length(list)) {
    if (nchar(c(list[i])) < 1) message("no valid code for ", paste0(sys.call()[-1], "$", names(list)[i]), " found in assets/ALL-CODES.RData \n")
  }
}

#' Validate Codes in Specified Columns
#'
#' This function checks whether the values in specified columns of a data table
#' are valid according to a given validator function, and returns invalid codes.
#'
#' @param dt A data.table containing the columns to validate.
#' @param columns A character vector specifying the column names to check.
#' @param validator_fn A function that takes a vector and returns TRUE/FALSE for each element.
#'
#' @return A named list of invalid codes per column (empty list if all valid).
#' @export
getInvalidCodes <- function(dt, columns, validator_fn) {
  errors <- list()
  for (column in columns) {
    values <- dt[[column]]
    invalid_codes <- values[!validator_fn(values) & !is.na(values)]
    if (length(invalid_codes) > 0) {
      errors[[column]] <- invalid_codes
    }
  }
  return(errors)
}
