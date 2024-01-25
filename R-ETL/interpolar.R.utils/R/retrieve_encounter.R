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
get_encounters <- function(table_description) {

  run_in(toupper('get_encounters'), {

    #refresh token, if defined
    refreshFhirToken()

    resource <- 'Encounter'

    #
    #for date restriction, identify the specification required in endpoint
    # do we need {sa, eb} or {ge, le}
    #
    runs_in_in('Create Test Request for Search Parameter \'sa\' and \'eb\'', {
      request <- fhircrackr::fhir_url(FHIR_SERVER_ENDPOINT, 'Encounter',
                                      parameters = c(
                                        'date' = paste0('sa', PERIOD_START),
                                        'date' = paste0('eb', PERIOD_END),
                                        '_summary' = 'count'
                                      )
      )
    })

    run_in_in_ignore_error('Send Test Request', {
      test_bundles <- try(polar_fhir_search(request = request, verbose = VERBOSE - VL_70_DOWNLOAD), silent = TRUE)
    })

    #
    # determine, whether date restrictions must be specified with
    #  {sa, eb} or {ge, le}
    #
    run_in_in('Check Response', {

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

      catl('Request')
      catl(styled_string(request, fg = 2, underline = TRUE))
      if (succ) {
        catl('returned', total, 'available Encounters.')
        catl('Will download Encounters using parameters "sa" and "eb"')
      } else {
        catl('did not return any available Encounters.')
        catl('Will download Encounters using parameters "ge" and "le"')
      }

      op.beg <- gsub("^([a-z]+).*", "\\1", params[1])
      op.end <- gsub("^([a-z]+).*", "\\1", params[2])
    })

    polar_run('Download and Crack Encounters', {
      request_encounter <- fhircrackr::fhir_url(
        url        = FHIR_SERVER_ENDPOINT,
        resource   = 'Encounter',
        parameters = polar_add_common_request_params(params)
      )

      table_enc <- polar_download_and_crack_parallel(
        request           = request_encounter,
        table_description = table_description,
        bundles_at_once   = BUNDLES_AT_ONCE,
        log_errors        = 'enc_error.xml',
        verbose           = VERBOSE - VL_70_DOWNLOAD
      )

    }, single_line = VERBOSE <= VL_70_DOWNLOAD, verbose = VERBOSE - VL_40_INNER_SCRIPTS_INFOS + 1)

    runs_in_in('change column classes', {
      table_enc <- table_enc[, lapply(.SD, as.character), ]
    })

    runs_in_in('Save Encounter table after download before remove something', {
      polar_write_rdata(table_enc, 'table_enc_all') # name differs from variable name!?
    })

    print_table_if_all(table_enc)


    # TODO: das hier muss wahrscheinlich für alle Resourcen nochmal getan werden, die wir dann endgültig vom FHIR-Server herunterladen
    # runs_in_in('Fix Dates in Encounter Table', {
    #   # splits the provided dates into day and time columns, if data is available
    #   # converts fhir dates to R dates
    #   # fix the column class to date()
    #   polar_fix_dates(table_enc, c('Enc.Period.Start', 'Enc.Period.End'))
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
    # runs_in_in('Add \'fall.no\' and \'pat.id\' to Encounter Table', {
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
    # runs_in_in('Convert hospitalization code to upper case', {
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
    # runs_in_in('Filter for Encounter Period', {
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
    # runs_in_in('Filter to inpatient encounter only', {
    #   #simplifier MII suggest IMP only
    #   table_enc <- table_enc[grep("station|IMP|inpatient|emer|ACUTE|NONAC", Enc.Class.Code, ignore.case = TRUE)]
    # })
    #
    # # no encounter found? stop here
    # runs_in_in('Check Size of Encounters Table', {
    #   if (nrow(table_enc) < 1) {
    #     STOP <<- 1
    #     cat(styled_string('Encounter Table table_enc is empty.\nTherefore no Analysis could be made. Stop execution here.\n', fg = 1, bold = TRUE))
    #     stop('Encounter Table table_enc is empty. Therefore no Analysis could be made. Stop execution here.')
    #   }
    # })
    #
    # #Exclusion criterion
    # runs_in_in('Check for Time Direction Violating Encounters and mark them', {
    #   table_enc[,Exclusion.TimeOrderViolation := Enc.Period.End.Datetime < Enc.Period.Start.Datetime]
    # })
    #
    # #Exclusion criterion
    # runs_in_in('Check for Time Overlapping Encounters and mark them', {
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
    # runs_in_in('Extract Reference IDs', {
    #   table_enc <- polar_extract_reference_id(reference = table_enc)
    # })
    #
    # #data absent reasons
    # # TODO: should this removal be registerd as inclusion/exclusion criterion?
    # runs_in_in('Remove Encounter with missing patient reference ID\'s', {
    #
    #   table_enc_missing_patID <- table_enc[is.na(Enc.Pat.ID), ]
    #   table_enc               <- table_enc[!is.na(Enc.Pat.ID), ]
    #
    #   if (NROW(table_enc_missing_patID)) {
    #     warning(nrow(table_enc_missing_patID)," Encounter does not provide a patient reference ID. Please check table_enc_missing_patID.RData")
    #     polar_write_rdata(table_enc_missing_patID)
    #   }
    #   rm(table_enc_missing_patID)
    # })
    #
    # #
    # # in further requests on other resources, we try to restrict the download request to
    # #  patients registered with the encounters from POLAR period
    # #
    # runs_in_in('Collect Patients Reference ID\'s', {
    #   patient_refs_ids <- unique(table_enc[Exclusion.TimeOrderViolation == FALSE & Exclusion.TimeOverlap == FALSE, Enc.Pat.ID])
    # })
    #
    # print_table(table_enc)
    #
    # # some stats
    # run_in_in('Update \'tab.resource.used\' Table', {
    #   tab.resource.used[name == 'Encounter', value := length(unique(table_enc$Enc.Enc.ID))]
    #   polar_write_rdata(tab.resource.used)
    #   rm(tab.resource.used)
    # })

    run_in_in('Save and Delete Encounters Table', {
      polar_write_rdata(table_enc)
    })

    table_enc
  })
}
