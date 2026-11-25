#' Resolve packaged cohort assets in installed and sourced manual workflows
#' @param name Asset file name.
#' @return Existing asset path.
cohortAssetPath <- function(name) {
  path <- system.file("extdata", name, package = "CohortDescription")
  if (!nzchar(path)) path <- file.path(
    "R-dataprocessor", "submodules", "manual_start",
    "Cohort_Description", "R-Cohort_Description", "inst", "extdata", name
  )
  if (!file.exists(path)) stop("Missing cohort asset: ", name)
  path
}

#' Aggregate every specified expanded row from case-level features
#' @param cases Selected cases for one station, phase and FAS.
#' @param specification Packaged row mapping with masks from the maintained template.
#' @return Long table of cell addresses and aggregate values; no individual identifiers.
calculateCohortCells <- function(cases, specification) {
  cases <- data.table::as.data.table(cases)
  results <- vector("list", nrow(specification))
  groups <- list(
    rep(TRUE, nrow(cases)), cases$age >= 18 & cases$age <= 40,
    cases$age >= 41 & cases$age <= 64, cases$age >= 65
  )
  genders <- c("", "male", "female", "other")
  for (i in seq_len(nrow(specification))) {
    spec <- specification[i]
    row <- spec$metric_row
    selected <- groups[[spec$age_group + 1L]]
    if (spec$gender_group > 0) selected <- selected & cases$gender %in% genders[spec$gender_group + 1L]
    values <- NULL
    if (row %in% c(6, 7)) {
      values <- rep(TRUE, nrow(cases))
      if (row == 7) selected <- !duplicated(cases$patient_id)
    } else if (row %in% c(9, 10, 12, 13)) {
      column <- c("hospital_start", "ip_start", "hospital_end", "ip_end")[match(row, c(9, 10, 12, 13))]
      # Calculate on the UTC timeline so daylight-saving changes do not alter SD.
      values <- as.numeric(cases[[column]]) / 86400 + 25569
    } else if (row == 21) values <- cases$age
    else if (row %in% 22:24) values <- groups[[row - 20L]]
    else if (row %in% c(26:40)) {
      group <- (row - 26L) %/% 5L + 1L
      part <- (row - 26L) %% 5L
      values <- cases$gender == genders[group + 1L]
      if (part == 1L) {
        selected <- cases$gender %in% genders[group + 1L]
        values <- cases$age
      } else if (part >= 2L) selected <- groups[[part]]
    } else {
      column <- paste0("m", row)
      if (!column %in% names(cases)) stop("No calculation for local specification row ", row)
      values <- cases[[column]]
    }
    selected <- which(selected %in% TRUE)
    summary <- summariseCohortValues(values[selected], cases$patient_id[selected], seed = 1260L)
    mask <- strsplit(spec$mask, "", fixed = TRUE)[[1]] == "1"
    if (length(mask) != 13L) stop("Invalid template result mask.")
    results[[i]] <- data.table::data.table(
      address = paste0(LETTERS[2:14][mask], spec$excel_row),
      value = as.numeric(summary[1, which(mask), with = FALSE])
    )
  }
  data.table::rbindlist(results)
}

#' Fill existing template cells without changing formatting or worksheet structure
#' @param template Single-sheet expanded workbook.
#' @param cells Aggregate cell addresses and numeric values.
#' @param headers Three text header values for B1:B3.
#' @param destination Output workbook path.
#' @param timezone Time zone for displaying date statistics.
#' @return Output path. Missing statistics are written as NA text, never as zero.
writeCohortWorkbook <- function(template, cells, headers, destination, timezone) {
  directory <- tempfile("cohort-xlsx-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  utils::unzip(template, exdir = directory)
  sheet_path <- file.path(directory, "xl", "worksheets", "sheet2.xml")
  sheet <- xml2::read_xml(sheet_path)
  nodes <- xml2::xml_find_all(sheet, "//*[local-name()='sheetData']/*/*[local-name()='c']")
  addresses <- xml2::xml_attr(nodes, "r")
  updates <- c(setNames(as.list(cells$value), cells$address), setNames(as.list(headers), paste0("B", 1:3)))
  if (anyDuplicated(names(updates)) || any(!names(updates) %in% addresses))
    stop("Cohort results do not match existing template cells.")
  positions <- match(names(updates), addresses)
  for (i in seq_along(updates)) {
    node <- nodes[[positions[i]]]
    xml2::xml_remove(xml2::xml_children(node))
    value <- updates[[i]]
    # Template date cells have General format. ISO text preserves full timestamps
    # without changing the maintained cell formats; SD remains a number of days.
    if (grepl("^[HIJKMN](9|10|12|13)$", names(updates)[i]) && is.finite(value)) {
      value <- format(as.POSIXct((value - 25569) * 86400, origin = "1970-01-01", tz = "UTC"),
        "%Y-%m-%d %H:%M:%S",
        tz = timezone
      )
    }
    if (is.numeric(value) && length(value) == 1L && is.finite(value)) {
      xml2::xml_attr(node, "t") <- NULL
      xml2::xml_add_child(node, "v", format(value, digits = 16, scientific = FALSE, trim = TRUE))
    } else {
      xml2::xml_attr(node, "t") <- "inlineStr"
      text <- if (is.na(value)) "NA" else as.character(value)
      child <- xml2::xml_add_child(node, "is")
      xml2::xml_add_child(child, "t", text)
    }
  }
  xml2::write_xml(sheet, sheet_path)
  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  # zipr changes its working directory to root; resolve the output directory first.
  archive_path <- file.path(normalizePath(dirname(destination), mustWork = TRUE), basename(destination))
  zip::zipr(archive_path, list.files(directory, all.files = TRUE, no.. = TRUE), root = directory)
  destination
}

#' Export the complete expanded sheet for every station, period and FAS
#' @param cases Calculated case features.
#' @param wards Station configuration including display metadata.
#' @param timezone Analysis time zone.
#' @param site Site label.
#' @param directory Output directory.
#' @return Aggregate manifest of output files and population sizes.
exportCohortDescription <- function(cases, wards, timezone, site, directory) {
  cases <- data.table::copy(data.table::as.data.table(cases))
  cases[, cohort_case_index := .I]
  periods <- buildCohortPeriods(wards)
  populations <- assignCohortPopulations(cases, periods, timezone)
  specification <- data.table::fread(cohortAssetPath("cohort_rows.csv"), colClasses = c(mask = "character"))
  fas <- c("FAS 1" = "fas1", "FAS 2.1" = "fas21", "FAS 2.2" = "fas22", "FAS 3" = "fas3")
  manifest <- list()
  cell_cache <- new.env(parent = emptyenv())
  for (i in seq_len(nrow(periods))) {
    period <- periods[i]
    ward <- wards[ward_name == period$ward_name]
    for (name in names(fas)) {
      file_number <- (i - 1L) * length(fas) + match(name, names(fas))
      label <- paste0(
        "File ", file_number, " of ", nrow(periods) * length(fas),
        ": ", period$ward_name, " / ", period$phase, " / ", name
      )
      runCohortStep(label, {
        selected <- populations[ward_name == period$ward_name & phase == period$phase & get(fas[[name]])]
        cache_key <- paste0("cases:", paste(sort(selected$cohort_case_index), collapse = ","))
        cells <- cell_cache[[cache_key]]
        if (is.null(cells)) {
          cells <- calculateCohortCells(selected, specification)
          cell_cache[[cache_key]] <- cells
        }
        # An ordinal prefix guarantees unique names even for sanitised ward labels.
        filename <- paste0(sprintf("%02d", i), "_", gsub(
          "[^[:alnum:]_-]", "_",
          paste(period$ward_name, period$phase, name, sep = "_")
        ), ".xlsx")
        headers <- c(
          paste(period$phase, site, period$ward_name, name, sep = " - "),
          paste(
            "Observation time period:", format(period$period_start, tz = timezone), "to",
            format(period$period_end, tz = timezone), "(end exclusive)"
          ),
          paste("Ward type:", ward$ward_type, "-", ward$department)
        )
        writeCohortWorkbook(
          cohortAssetPath("cohort_template.xlsx"), cells, headers,
          file.path(directory, filename), timezone
        )
        manifest[[length(manifest) + 1L]] <- data.table::data.table(
          file = filename,
          ward = period$ward_name, phase = period$phase, fas = name,
          cases = nrow(selected), patients = data.table::uniqueN(selected$patient_id)
        )
      })
    }
  }
  result <- data.table::rbindlist(manifest)
  data.table::fwrite(result, file.path(directory, "cohort_manifest.csv"))
  if (!file.copy(cohortAssetPath("open_questions.md"), file.path(directory, "open_questions.md"), overwrite = TRUE))
    stop("Could not write the cohort clarification notes.")
  result
}
