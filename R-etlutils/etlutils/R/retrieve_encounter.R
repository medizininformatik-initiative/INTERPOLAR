#' Download and preprocess encounter data from FHIR server
#'
#' This function retrieves encounter data from a FHIR server, applies various filters,
#' and performs data processing tasks.
#'
#' @param table_description the fhir crackr table description with the columns definition
#' of the returned table.
#'
#' @details
#' The function handles the download of encounter data, filtering based on date ranges,
#' and additional processing steps such as fixing dates, adding columns, and handling
#' exclusion criteria.
#'
#' @return
#' The processed encounter data is saved, and relevant tables are returned and/or
#' saved as RData files.
#'
#' @export
getEncounters <- function(table_description) {

  runLevel3("Get Enconters", {

    #refresh token, if defined
    refreshFHIRToken()

    resource <- 'Encounter'

    #
    #for date restriction, identify the specification required in endpoint
    # do we need {sa, eb} or {ge, le}
    #
    runLevel3Line('Create Test Request for Search Parameter \'sa\' and \'eb\'', {
      request <- fhircrackr::fhir_url(FHIR_SERVER_ENDPOINT, 'Encounter',
                                      parameters = c(
                                        'date' = paste0('sa', PERIOD_START),
                                        'date' = paste0('eb', PERIOD_END),
                                        '_summary' = 'count'
                                      )
      )
    })

    runLevel3('Send Test Request', {
      test_bundles <- executeFHIRSearchVariation(request = request, verbose = VERBOSE)
    })

    #
    # determine, whether date restrictions must be specified with
    #  {sa, eb} or {ge, le}
    #
    runLevel3('Check Response', {

      params <- if (
        succ <- !inherits(test_bundles, 'try-error') &&
        0 < length(test_bundles) && {
          total <- as.numeric(
            xml2::xml_attr(
              x = xml2::xml_find_all(
                x = test_bundles[[1]],
                xpath = './/total'
              ),
              'value'
            )
          )
          !is.na(total) && 0 < total
        }
      ) {
        c(
          'date' = paste0('sa', PERIOD_START),
          'date' = paste0('eb', PERIOD_END)
        )
      } else {
        c(
          'date' = paste0('ge', PERIOD_START),
          'date' = paste0('le', PERIOD_END)
        )
      }

      catByVerbose('Request')
      catByVerbose(formatStringStyle(request, fg = 2, underline = TRUE))
      if (succ) {
        catByVerbose('returned', total, 'available Encounters.')
        catByVerbose('Will download Encounters using parameters "sa" and "eb"')
      } else {
        catByVerbose('did not return any available Encounters.')
        catByVerbose('Will download Encounters using parameters "ge" and "le"')
      }

      op.beg <- gsub("^([a-z]+).*", "\\1", params[1])
      op.end <- gsub("^([a-z]+).*", "\\1", params[2])
    })

    runLevel3('Download and Crack Encounters', {
      request_encounter <- fhircrackr::fhir_url(
        url        = FHIR_SERVER_ENDPOINT,
        resource   = 'Encounter',
        parameters = addParamToFHIRRequest(params)
      )

      table_enc <- downloadAndCrackFHIRResources(
        request           = request_encounter,
        table_description = table_description,
        bundles_at_once   = BUNDLES_AT_ONCE,
        log_errors        = 'enc_error.xml',
        verbose           = VERBOSE
      )
    })

    runLevel3Line('change column classes', {
      table_enc <- table_enc[, lapply(.SD, as.character), ]
    })

    printAllTables(table_enc)

    # TODO: das hier muss wahrscheinlich für alle Resourcen nochmal getan werden, die wir dann endgültig vom FHIR-Server herunterladen
    # runLevel3Line('Fix Dates in Encounter Table', {
    #   # splits the provided dates into day and time columns, if data is available
    #   # converts fhir dates to R dates
    #   # fix the column class to date()
    #   fixDateFormat(table_enc, c('Enc.Period.Start', 'Enc.Period.End'))
    #
    #   # combine day and time column in a column of type date()
    #   table_enc[, Enc.Period.Start.Datetime := do.call(paste,.SD), .SDcols = c('Enc.Period.Start', 'Enc.Period.Start.TimeSpec')]
    #   table_enc[, Enc.Period.End.Datetime   := do.call(paste,.SD), .SDcols = c('Enc.Period.End', 'Enc.Period.End.TimeSpec')]
    # })

    # AXS 10.01.2024: das können wir leider nicht mehr machen, weil jeden Tag ein anderer Patient die pat.id 1 oder
    #                 ein anderer Fall die fall.no 1 bekommen würde.
    #
    # # generate generic pat.id and fall.no, that will be used during retrieval and analysis
    # #  ensures the ID-class numeric()
    # runLevel3Line('Add \'fall.no\' and \'pat.id\' to Encounter Table', {
    #   table_enc[
    #     ,pat.id  := as.numeric(as.factor(Enc.Pat.ID))
    #   ][
    #     ,fall.no := as.numeric(as.factor(paste(pat.id, Enc.Enc.ID)))
    #   ]
    # })
    #

    # AXS 10.01.2024: Keine Ahnung warum das hier gemacht werden musste, aber es bleibt als Erinnerung auskommentiert drin.
    #
    # # if available, simplify the evaluation of Enc.Hospitalization.Code
    # #  TODO: tolower() must be removed, if any DIC provides these data correctly
    # runLevel3Line('Convert hospitalization code to upper case', {
    #   if (any(colnames(table_enc) == "Enc.Hospitalization.Code")) {
    #     table_enc[, Enc.Hospitalization.Code := toupper(Enc.Hospitalization.Code)]
    #   }
    # })

    # AXS 10.01.2024: Keine Ahnung warum das hier gemacht werden musste, aber es bleibt als Erinnerung auskommentiert drin.
    # #
    # # filter applied once again, even though the filter has been applied during request
    # # however, filter might fail during request
    # # necessary as fallback, in this case
    # # issue observed with FHIR IBM Server
    # #
    # # in addition, encounters are removed, where start or end dates are missing
    # #
    # runLevel3Line('Filter for Encounter Period', {
    #   table_enc <- table_enc[
    #     !is.na(Enc.Period.Start)                      &
    #     !is.na(Enc.Period.End)                        &
    #     0 <= difftime(Enc.Period.Start, PERIOD_START) &
    #     0 <= difftime(PERIOD_END, Enc.Period.End)
    #   ]
    # })

    # #
    # # we want to analyse inpatient encounters only
    # #   inpatient can be provided by a variety of values
    # #
    # runLevel3Line('Filter to inpatient encounter only', {
    #   #simplifier MII suggest IMP only
    #   table_enc <- table_enc[grep("station|IMP|inpatient|emer|ACUTE|NONAC", Enc.Class.Code, ignore.case = TRUE)]
    # })
    #
    # # no encounter found? stop here
    # runLevel3Line('Check Size of Encounters Table', {
    #   if (nrow(table_enc) < 1) {
    #     STOP <<- 1
    #     cat(formatStringStyle('Encounter Table table_enc is empty.\nTherefore no Analysis could be made. Stop execution here.\n', fg = 1, bold = TRUE))
    #     stop('Encounter Table table_enc is empty. Therefore no Analysis could be made. Stop execution here.')
    #   }
    # })
    #
    # #Exclusion criterion
    # runLevel3Line('Check for Time Direction Violating Encounters and mark them', {
    #   table_enc[,Exclusion.TimeOrderViolation := Enc.Period.End.Datetime < Enc.Period.Start.Datetime]
    # })
    #
    # #Exclusion criterion
    # runLevel3Line('Check for Time Overlapping Encounters and mark them', {
    #
    #   tab.pat.fall <- table_enc[Exclusion.TimeOrderViolation == FALSE, .(
    #     "pat.id"  = pat.id,
    #     "fall.no" = fall.no,
    #     "Start"   = Enc.Period.Start,
    #     "End"     = Enc.Period.End
    #   )]
    #
    #   # expand periods to day-by-day notation
    #   tab.pat.fall <- unique(tab.pat.fall)
    #   tab.pat.fall <- polar_period_to_time(tab.pat.fall, "Start", "End")
    #
    #   #
    #   # count patients and their number of encounters day-by-day
    #   # usually, this value is 1
    #   # if N>1, the patient records multiple encounter a day
    #   #  may occur for instance with dialysis treatment and 'common' injuries
    #   #
    #   tab.pat.fall[, N := length(unique(fall.no)), by = c("Time", "pat.id")]
    #   tab.pat.fall <- tab.pat.fall[N > 1, ]
    #   tab.pat.fall[, c("Start", "End", "Time", "N") := NULL] #remove obsolete columns
    #
    #   tab.pat.fall <- unique(tab.pat.fall)
    #
    #   #mark any encounter to be excluded, if this is an overlapping encounter
    #   table_enc[, Exclusion.TimeOverlap := FALSE]
    #   table_enc[fall.no %in% tab.pat.fall$fall.no & pat.id %in% tab.pat.fall$pat.id, Exclusion.TimeOverlap := TRUE]
    #
    #   rm (tab.pat.fall)
    # })
    #
    # runLevel3Line('Extract Reference IDs', {
    #   table_enc <- polar_extract_reference_id(reference = table_enc)
    # })
    #
    # #data absent reasons
    # # TODO: should this removal be registerd as inclusion/exclusion criterion?
    # runLevel3Line('Remove Encounter with missing patient reference ID\'s', {
    #
    #   table_enc_missing_patID <- table_enc[is.na(Enc.Pat.ID), ]
    #   table_enc               <- table_enc[!is.na(Enc.Pat.ID), ]
    #
    #   if (NROW(table_enc_missing_patID)) {
    #     warning(nrow(table_enc_missing_patID)," Encounter does not provide a patient reference ID. Please check table_enc_missing_patID.RData")
    #     writeRData(table_enc_missing_patID)
    #   }
    #   rm(table_enc_missing_patID)
    # })
    #
    # #
    # # in further requests on other resources, we try to restrict the download request to
    # #  patients registered with the encounters from POLAR period
    # #
    # runLevel3Line('Collect Patients Reference ID\'s', {
    #   patient_refs_ids <- unique(table_enc[Exclusion.TimeOrderViolation == FALSE & Exclusion.TimeOverlap == FALSE, Enc.Pat.ID])
    # })
    #
    # printTable(table_enc)
    #
    # # some stats
    # runLevel3('Update \'tab.resource.used\' Table', {
    #   tab.resource.used[name == 'Encounter', value := length(unique(table_enc$Enc.Enc.ID))]
    #   writeRData(tab.resource.used)
    #   rm(tab.resource.used)
    # })

    runLevel3Line('Save and Delete Encounters Table', {
      writeRData(table_enc, 'pid_source_encounter_unfiltered')
    })

    table_enc
  })
}
