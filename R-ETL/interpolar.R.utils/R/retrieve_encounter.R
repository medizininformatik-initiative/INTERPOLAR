#' Download and preprocess encounter data from FHIR server
#'
#' This function retrieves encounter data from a FHIR server, applies various filters,
#' and performs data processing tasks.
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
get_encounters <- function() {

  run_in(toupper('get_encounters'), {

    #refresh token, if defined
    refreshFhirToken()

    resource <- 'Encounter'

    # download encounter from fhir server or load encouter table from snapshot?
    #if (resource %in% RESOURCES_TO_DOWNLOAD) {
      #
      #for date restriction, identify the specification required in endpoint
      # do we need {sa, eb} or {ge, le}
      #
      runs_in_in('Create Test Request for Search Parameter \'sa\' and \'eb\'', {
        request <- fhircrackr::fhir_url(FHIR_SERVER_ENDPOINT, 'Encounter',
          parameters = c(
            # 'date' = paste0('sa', PERIOD_START),
            # 'date' = paste0('eb', PERIOD_END),
            '_summary' = 'count'
          )
        )
      })

      polar_run('Send Test Request', {
        test_bundles <- try(polar_fhir_search(request = request, verbose = VERBOSE - 7), silent = TRUE)
        NULL
      }, single_line = VERBOSE <= 7, verbose = VERBOSE - 4 + 1, throw_exception = FALSE)

      # #
      # # determine, whether date restrictions must be specified with
      # #  {sa, eb} or {ge, le}
      # #
      # run_in_in('Check Response', {
      #
      # params <- if (
      #   succ <- !inherits(test_bundles, 'try-error') &&
      #   0 < length(test_bundles) && {
      #     total <- as.numeric(
      #       xml2::xml_attr(
      #         x = xml2::xml_find_all(
      #           x = test_bundles[[1]],
      #           xpath = './/total'
      #         ),
      #         'value'
      #       )
      #     )
      #     !is.na(total) && 0 < total
      #   }
      # ) {
      #     c(
      #       'date' = paste0('sa', PERIOD_START),
      #       'date' = paste0('eb', PERIOD_END)
      #     )
      #   } else {
      #     c(
      #       'date' = paste0('ge', PERIOD_START),
      #       'date' = paste0('le', PERIOD_END)
      #     )
      #   }
      #
      #   catl('Request')
      #   catl(styled_string(request, fg = 2, underline = TRUE))
      #   if (succ) {
      #     catl('returned', total, 'available Encounters.')
      #     catl('Will download Encounters using parameters "sa" and "eb"')
      #   } else {
      #     catl('did not return any available Encounters.')
      #     catl('Will download Encounters using parameters "ge" and "le"')
      #   }
      #
      #   op.beg <- gsub("^([a-z]+).*", "\\1", params[1])
      #   op.end <- gsub("^([a-z]+).*", "\\1", params[2])
      # })

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
          catl('Request')
          catl(styled_string(request, fg = 2, underline = TRUE))
          catl('returned', total, 'available Encounters.')
        }

        op.beg <- gsub("^([a-z]+).*", "\\1", params[1])
        op.end <- gsub("^([a-z]+).*", "\\1", params[2])
      })

      polar_run('Download and Crack Encounters', {
        # #
        # # is this parameter defined ?
        # # must be set manual by used interaction
        # # can be something like 'einrichtungskontakt'
        # #
        # if (ENC_REQ_TYPE != "") {
        #   params <- c(params, 'type' = ENC_REQ_TYPE)
        # }

        #
        # type of encounter collection
        # full: download any encounter within period
        # month: download encounter within period month-by-month
        # year: download encounter within period year-by-year
        #
        # take care, encounter with missing end-date (patient is still in hospital)
        # may generate tremendous overhead, as those encounter are not excluded by the
        # period restriction. They will be downloaded with each request
        #
        #if (ENC_REQ_PER == "full") {

          request_encounter <- fhircrackr::fhir_url(
            url        = FHIR_SERVER_ENDPOINT,
            resource   = 'Encounter'#,
            #parameters = polar_add_common_request_params(params)
            #parameters = '_count' = COUNT_PER_BUNDLE
          )

          table_enc <- polar_download_and_crack_parallel(
            request           = request_encounter,
            table_description = TABLE_DESCRIPTION$Encounter,
            bundles_at_once   = BUNDLES_AT_ONCE,
            log_errors        = 'enc_error.xml',
            verbose           = VERBOSE - 7
          )
        # } else if (grepl("^(month|year)$", ENC_REQ_PER) ) {
        #
        #   table_enc <- list()
        #
        #   #determine the parallelization level
        #   os <- get_os()
        #   ncores <- get_ncores(os)
        #
        #   # download seqence, month by month or year by year
        #   period.seq <- seq(as.Date(PERIOD_START), as.Date(PERIOD_END), by = ENC_REQ_PER)
        #
        #   # apply parallel download of encounter from several month/years
        #   table_enc <- parallel::mclapply(
        #
        #     X = 1:length(period.seq),
        #     mc.cores = limit_ncores(ncores),
        #     FUN = function (X) {
        #
        #       #determine start and end date for sub-period
        #       period.beg <- period.seq[X]
        #       if (X == length(period.seq)) {
        #
        #         period.end <- PERIOD_END
        #       } else {
        #
        #         period.end <- period.seq[X+1]-1 # previous day, the last day of the month before
        #       }
        #
        #       #
        #       # params has been defined above and may contain additional parameters, such as type=='einrichtungskontakt'
        #       #  thus, replace params 1 and 2 only
        #       #  TODO do we need a special check here to determine the right index
        #       #
        #       params[1] <- paste0(op.beg, period.beg)
        #       params[2] <- paste0(op.end, period.end)
        #
        #       if (VL_60_ALL_TABLES <= VERBOSE) {
        #
        #         message("Retrieve encounter from ",params[1]," - ",params[2],"\n")
        #       }
        #
        #       request_encounter <- fhircrackr::fhir_url(
        #         url        = FHIR_ENDPOINT,
        #         resource   = 'Encounter',
        #         parameters = polar_add_common_request_params(params)
        #       )
        #
        #       # return request result to table_enc
        #       polar_download_and_crack_parallel(
        #         request           = request_encounter,
        #         table_description = TABLE_DESCRIPTION$Encounter,
        #         bundles_at_once   = BUNDLES_AT_ONCE,
        #         log_errors        = 'enc_error.xml',
        #         max_cores         = 1, #avoid double parallelization with inner mclapply
        #         verbose           = VERBOSE - 7
        #       )
        #   })

          # combine the results from each request
          table_enc <- unique(data.table::rbindlist(table_enc))
        #}
      }, single_line = VERBOSE <= 7, verbose = VERBOSE - 4 + 1)
    #}

    # run_in_in('change column classes', {
    #   table_enc <- table_enc[, lapply(.SD, as.character), ]
    # })
    #
    # runs_in_in('Save Encounter table after download before remove something', {
    #   polar_write_rdata(table_enc, 'table_enc_all') # name differs from variable name!?
    # })
    #
    # # if (isDebug()) {
    # #   retainColumns(table_enc, c('Enc.Enc.ID', 'Enc.PartOf.ID', 'Enc.Service.Code'))
    # #   table_enc <- setkey(table_enc, Enc.Enc.ID)
    # #   table_enc[3, ] <-  table_enc[2, ]
    # #   table_enc[4, ] <-  table_enc[2, ]
    # #   table_enc[2, Enc.Enc.ID := paste0(Enc.Enc.ID, '_1')]
    # #   table_enc[3, Enc.Enc.ID := paste0(Enc.Enc.ID, '_2')]
    # #   table_enc[4, Enc.Enc.ID := paste0(Enc.Enc.ID, '_3')]
    # #   table_enc[3, Enc.Service.Code := 1600]
    # #   table_enc[4, Enc.Service.Code := 3200]
    # # }
    #
    # print_table_if_all(table_enc)
    #
    # runs_in_in('Create Table with ServiceType', {
    #   table_serviceType <- unique(table_enc[ , c("Enc.Service.Type", "Enc.Service.Code", "Enc.Service.Display")])
    #   table_serviceType <- table_serviceType[rowSums(is.na(table_serviceType)) != ncol(table_serviceType), ]
    #   setnames(table_serviceType, old = c('Enc.Service.Type', 'Enc.Service.Code', 'Enc.Service.Display'),
    #            new = c('serviceType', 'Code', 'Name'))
    # })
    #
    # print_table(table_serviceType)
    #
    # runs_in_in('Extract sub Encounters ("Abteilungskontakt" + "Versorgungsstellenkontakt")', {
    #   # sub encounters have partOf references
    #   table_enc_sub <- unique(table_enc[!is.na(Enc.PartOf.ID)])
    # })
    #
    # runs_in_in('Extract super Encounters ("Einrichtungskontakt")', {
    #   table_enc <- unique(table_enc[is.na(Enc.PartOf.ID)])
    # })
    #
    # runs_in_in('Retain only Depatment Encounters in sub Encounters ("Abteilungskontakt")', {
    #
    #   table_enc_sub[, Enc.PartOf.ID := makeRelative(Enc.PartOf.ID)]
    #
    #   # only department encounters have a reference to the super encounters
    #   table_enc_sub <- unique(table_enc_sub[Enc.PartOf.ID %in% table_enc$Enc.Enc.ID])
    #
    #   # remove all departmente encounters without a service type code information
    #   table_enc_sub <- table_enc_sub[!is.na(Enc.Service.Code) & nchar(as.character(Enc.Service.Code))]
    #
    # })
    #
    # runs_in_in('Add department codes to encounter table', {
    #   table_enc[, Enc.Service.Code := {
    #     id <- Enc.Enc.ID
    #     table_enc_sub_parts <- table_enc_sub[Enc.PartOf.ID %in% (id)]
    #     codes <- table_enc_sub_parts$Enc.Service.Code
    #     # if (isDebug() && !all(is.na(codes))) codes <- c(codes, 3200, 50, 'ABC') ###### D E B U G changes to ensure all cobinations of codes ###############
    #     # get indices of number strings < 1000
    #     is_small_number <- !is.na(as.integer(codes)) & as.integer(codes) < 1000
    #     # fill the number stings with leading 0 up to 4 chars
    #     codes[is_small_number] <- sprintf('%04d', as.integer(codes[is_small_number]))
    #     paste0(sort(unique(codes)), collapse = ' ~ ')
    #   }, by = Enc.Enc.ID]
    #   #remove the sub encounter table
    #   rm(table_enc_sub)
    # })
    #
    # runs_in_in('Remove unnecessary Columns', {
    #   table_enc[, Enc.PartOf.ID := NULL]
    # })
    #
    # # some stats
    # run_in_in('Update \'tab.resource.used\' Table', {
    #   tab.resource.used <- polar_read_rdata('tab.resource.used')
    #   tab.resource.used[name == 'Encounter (unfiltered)', value := length(unique(table_enc$Enc.Enc.ID))]
    # })
    #
    # runs_in_in('Fix Dates in Encounter Table', {
    #   # splits the provided dates into day and time columns, if data is available
    #   # converts fhir dates to R dates
    #   # fix the column class to date()
    #   polar_fix_dates(table_enc, c('Enc.Start', 'Enc.End'))
    #
    #   # combine day and time column in a column of type date()
    #   table_enc[, Enc.Start.Datetime := do.call(paste,.SD), .SDcols = c('Enc.Start', 'Enc.Start.TimeSpec')]
    #   table_enc[, Enc.End.Datetime   := do.call(paste,.SD), .SDcols = c('Enc.End', 'Enc.End.TimeSpec')]
    # })
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
    # # if available, simplify the evaluation of Enc.Hospitalization.Code
    # #  TODO: tolower() must be removed, if any DIC provides these data correctly
    # runs_in_in('Convert hospitalization code to upper case', {
    #   if (any(colnames(table_enc) == "Enc.Hospitalization.Code")) {
    #     table_enc[, Enc.Hospitalization.Code := toupper(Enc.Hospitalization.Code)]
    #   }
    # })
    #
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
    #     !is.na(Enc.Start)                      &
    #     !is.na(Enc.End)                        &
    #     0 <= difftime(Enc.Start, PERIOD_START) &
    #     0 <= difftime(PERIOD_END, Enc.End)
    #   ]
    # })
    #
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
    #   table_enc[,Exclusion.TimeOrderViolation := Enc.End.Datetime < Enc.Start.Datetime]
    # })
    #
    # #Exclusion criterion
    # runs_in_in('Check for Time Overlapping Encounters and mark them', {
    #
    #   tab.pat.fall <- table_enc[Exclusion.TimeOrderViolation == FALSE, .(
    #     "pat.id"  = pat.id,
    #     "fall.no" = fall.no,
    #     "Start"   = Enc.Start,
    #     "End"     = Enc.End
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
      # polar_write_rdata(patient_refs_ids)
      # polar_write_rdata(table_serviceType)
      # rm(table_enc, patient_refs_ids, table_serviceType)
    })
  })
}
