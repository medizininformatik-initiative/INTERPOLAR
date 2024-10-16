#' Get the Operating System Name
#'
#' This function retrieves the name of the operating system and returns it in lowercase.
#'
#' @return A character string representing the operating system name.
#'
#' @export
getOperationSystem <- function() {
  sysinf <- Sys.info()
  if (!is.null(sysinf)) {
    os <- sysinf[['sysname']]
    if (os == 'Darwin') os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  tolower(os)
}

#' Get the Number of Cores Available for Parallelization
#'
#' This function determines the number of CPU cores available for parallelization
#' based on the operating system.
#'
#' @param os A character string representing the operating system name.
#' @return An integer specifying the number of cores available for parallelization.
#'
#' @export
getAvailableCoreNumber <- function(os) {
  n_cores <- if (os %in% c("linux", "osx")) parallel::detectCores() else 1
  if (0 < MAX_CORES) min(n_cores, MAX_CORES) else n_cores
}

#' Limit the Number of Cores Based on Available Cores
#'
#' This function limits the number of cores based on the available cores and a specified limit.
#'
#' @param ncores An integer specifying the desired number of cores. If NULL, defaults to 1.
#' @return An integer representing the limited number of cores.
#'
#' @export
limitAvailableCoreNumber <- function(ncores) {
  os <- getOperationSystem()
  available_cores <- getAvailableCoreNumber(os)
  if (is.null(ncores)) 1 else min(c(available_cores, ncores))
}

#' Refresh FHIR Token
#'
#' This function refreshes the FHIR token if it is defined.
#'
#' @export
refreshFHIRToken <- function() {

  # Refresh FHIR-Server authentication Token
  #
  # This function refreshes the FHIR-Server authentication token by making a request to the specified token refresh URL.
  #
  # @return A character string representing the refreshed FHIR-Server authentication token.
  #
  refreshFHIRTokenInternal <- function() {
    if (FHIR_TOKEN_REFRESH_URL == '' || FHIR_TOKEN_REFRESH_USER == '' || FHIR_TOKEN_REFRESH_PASSWORD == '') {
      return ("")
    }
    # Token call
    response <- httr::GET(
      url = FHIR_TOKEN_REFRESH_URL,
      httr::authenticate(
        user = FHIR_TOKEN_REFRESH_USER,
        password = FHIR_TOKEN_REFRESH_PASSWORD
      ))
    # Token as payload
    httr::content(response, as = "text")
  }

  # refresh token, if defined
  if (FHIR_TOKEN != '') {
    runLevel3IgnoreError('Refresh FHIR_TOKEN', {
      FHIR_TOKEN <- refreshFHIRTokenInternal()
    })
  }
}

#' Paste Parameters for a FHIR Search Request
#'
#' @param parameters Either a character of length 1 containing an existing parameter string or
#' a named vector or list of the form
#' c("_summary" = "count", "gender" = "male") or list("_summary" = "count", "gender" = "female").
#' @param parameters2add Either a character of length 1 containing a parameter string to add or
#' a named vector or list of the form
#' c("_summary" = "count", "gender" = "male") or list("_summary" = "count", "gender" = "female").
#' @param add_question_sign Logical. Should an ?-Sign to be prefixed. Defaults to FALSE.
#'
#' @return A character of length 1 representing the pasted parameter string.
#' @export
pasteFHIRSearchParams <- function(parameters = NULL, parameters2add = NULL, add_question_sign = F) {
  # convert list names and elements to a string of the form name1=element2&name1=element2&...
  convert <- function(arg) {
    n <- names(arg)
    if (length(n) < length(arg)) {# if less arg names than arg elements were given
      if (0 == length(n) && length(arg) == 1) {# if no names were given and one single element
        # return arg
        arg
      }
    } else {# if every element has a name paste all the names and elements to name1=element1&name2=element2&...
      paste0(
        sapply(
          seq_along(arg),
          function(i) {
            if (is.null(arg[i]) || is.na(arg[i])) {# if element is NULL or NA
              if (VL_70_DOWNLOAD <= VERBOSE) {# if verbose level is at least VL_70_DOWNLOAD
                warning("WARNING: Ignore parameter ",n[i]," which is ",arg[i],"\n")
              }
              ""
            } else {
              paste0(n[i], "=", arg[i])
            }
          }
        ),
        collapse = "&"
      )
    }
  }
  # build argument string from old parameters list
  pre  = convert(parameters)
  # build argument string from new parameters list
  post = convert(parameters2add)
  s <- if (0 < nchar(pre) && 0 < nchar(post)) {# if both strings aren't zero
    paste0(pre, "&", post)
  } else if (0 < nchar(pre)) {# if no old parameters were present
    pre
  } else {# if no new parameters were present
    post
  }
  if (0 < nchar(s) && substr(s, 1, 1) != "?" && add_question_sign) {# add a question sign if required and needed
    s <- paste0("?", s)
  }
  s
}

#' Get FHIR Resources by IDs
#'
#' This function retrieves FHIR resources from a server based on a list of resource IDs.
#' It supports both GET and POST methods for querying the server.
#'
#' @param endpoint The FHIR server endpoint URL.
#' @param resource The name of the FHIR resource to retrieve.
#' @param ids A vector of identifiers for the FHIR resources.
#' @param id_param_str The parameter string for specifying the resource IDs (default is '_id').
#' @param parameters Additional parameters for the FHIR resource query (optional).
#' @param verbose The level of verbosity for logging (default is 0).
#'
#' @return A list of FHIR resources in the form of a fhir_bundle_list.
#' @export
getResourcesByIDs <- function(
    endpoint,
    resource,
    ids,
    id_param_str = '_id',
    parameters   = addParamToFHIRRequest(c()),
    verbose      = 0
) {
  getResourcesByIDs_get <- function(endpoint, resource, ids, parameters = NULL, verbose = 1) {
    # create a string of max_len of given maximal max_ids ids
    collect_ids_for_request <- function(ids, max_ids = length(ids), max_len = MAX_CHARACTER_LENGTH_FOR_GET_REQUESTS - MAX_CHARACTER_LENGTH_FOR_GET_REQUESTS_RESERVE) {
      if (length(ids) < 1) {# if there are no more ids to stringify
        warning(
          paste0(
            "The length of ids is zero. So no single id is added to the list."
          )
        )
        list(str = "", n = 0) # return pair of an empty string and number of added ids
      } else if (max_len < nchar(ids[[1]])) {# if the id itself is longer than max_len
        warning(
          paste0(
            "The length of the first id string ",
            ids[[1]],
            " is already greater than max_len=",
            max_len,
            ". So no single id is added to the list."
          )
        )
        list(str = "", n = 0) # return pair of an empty string and its length of zero
      } else {# if there are ids to stringify
        n <- 1
        s <- ids[[n]] # first id is begin of string
        # while string is not to long and the added ids are less than not max_ids and total length of the string is
        # small enough
        while (n < max_ids && n < length(ids) && nchar(s) + nchar(ids[[n + 1]]) < max_len) {
          n <- n + 1
          s <- paste0(s, ",", ids[[n]]) # add new ids comma separated
        }
        list(str = s, n = n) # return pair of an empty string and number of added ids
      }
    }
    bundles <- list()
    total <- 1
    bundle_count <- 1
    while (0 < length(ids)) {# while there are still ids to add
      # build request string of maximal max_ids ids
      ids_ <- collect_ids_for_request(ids = ids, max_ids = length(ids))
      # create request with list of resource ids to get from server
      url_ <- fhircrackr::fhir_url(endpoint, resource, pasteFHIRSearchParams(paste0(id_param_str, "=", ids_$str), addParamToFHIRRequest(parameters)))
      # get bundle
      bnd_ <- executeFHIRSearchVariation(request = url_, verbose = verbose)
      if (VL_90_FHIR_RESPONSE <= VERBOSE) {
        print (bnd_)
      }
      total <- total + ids_$n # count received ids
      ids <- ids[-seq_len(ids_$n)] # remove received ids from ids list
      bundles <- c(bundles, bnd_) # add bundle bnd_ to bundle list bundles
      if (1 < verbose) {
        cat(paste0("Bundle ", bundle_count, " a ", ids_$n, " ", resource, "s  \u03A3 ", total - 1, "\n"))
      }
      bundle_count <- bundle_count + 1 # count received bundles
    }
    fhircrackr::fhir_bundle_list(bundles) # return bundles list as fhir_crackr class bundle_list
  }
  getResourcesByIDs_post <- function(endpoint, resource, ids, parameters = NULL, verbose = 1) {
    parameters_list <- list(paste0(ids, collapse = ","), COUNT_PER_BUNDLE) # add all ids
    names(parameters_list) <- c(id_param_str, '_count') # name arguments
    executeFHIRSearchVariation(
      request = fhircrackr::fhir_url(# get resources
        url      = endpoint,
        resource = resource,
        url_enc  = TRUE
      ),
      body    = fhircrackr::fhir_body(
        content = pasteFHIRSearchParams(
          parameters     = parameters_list,
          parameters2add = parameters
        ),
        type    = "application/x-www-form-urlencoded"
      ),
      verbose = verbose
    )
  }

  # if getting resources via post fails, the try to get them via get
  bundles <- try(
    getResourcesByIDs_post(
      endpoint   = endpoint,
      resource   = resource,
      ids        = ids,
      parameters = parameters,
      verbose    = verbose - 1
    )
  )

  if (inherits(bundles, "try-error")) {
    if (0 < verbose) cat("Getting Bundles via POST failed. Try to get them via GET.\n")
    bundles <- getResourcesByIDs_get(
      endpoint   = endpoint,
      resource   = resource,
      ids        = ids,
      parameters = parameters,
      verbose    = verbose - 1)
  } else {
    if (0 < verbose) cat("Getting Bundles via POST succeded.\n")
  }

  bundles
}

#' Log Request Details to a File
#'
#' Logs a detailed request string for a specific resource to a file. This function is intended
#' for debugging or auditing purposes. If the verbosity level is high enough, it also outputs
#' the request details to the console.
#'
#' @param verbose current verbose level
#' @param resource_name The name of the resource being requested.
#' @param bundles A list of bundles where the first bundle's self link is included in the log.
#'
#' @details The function constructs a detailed request string from the resource name and the
#' self link of the first bundle. If `verbose` is set to `VL_90_FHIR_RESPONSE` or higher, the
#' request details are printed to the console using `cat()`. The log file path is generated
#' using `fhircrackr::paste_paths()` and the file `cds2db_total_bundles.txt` in the specified
#' directory. The file is created or overwritten in write-text mode and the request is logged.
#'
#' @return This function does not return a value, focusing instead on side effects such as
#' writing to a file and potentially printing to the console.
#'
logRequest <- function(verbose, resource_name, bundles) {
  bundles_requests <- paste0("Request for ", resource_name, ":\n", toString(bundles[[1]]@self_link), "\n")
    if (verbose >= VL_90_FHIR_RESPONSE) {
      cat(bundles_requests)
    }
  log_filename <- fhircrackr::paste_paths(returnPathToBundlesDir(), paste0("cds2db_total_bundles.txt"))
  log_file <- file(log_filename, open = "at")
  writeLines(bundles_requests, log_file, useBytes = TRUE)
  close(log_file)
}

#' Download and Crack FHIR Resources
#'
#' This function downloads FHIR resources based on the provided `request` and processes
#' them into a table format using the `fhircrackr` package. It handles the download of
#' FHIR bundles, checks the total number of available resources, and converts the
#' downloaded data into a table according to the specified `table_description`.
#'
#' @param request A string representing the FHIR search request. This request should
#'   define the criteria for retrieving FHIR resources.
#' @param max_bundles Integer specifying the maximum number of bundles to download.
#'   Default is `MAX_ENCOUNTER_BUNDLES`.
#' @param table_description A table description that defines the structure of the
#'   resulting table. This should be compatible with the `fhircrackr` package.
#' @param verbose Logical flag indicating whether to print detailed logs during
#'   the execution of the function. Default is `VERBOSE`.
#' @param log_errors A string specifying the file name where any errors encountered
#'   during the FHIR request will be logged. Default is `'enc_error.xml'`.
#'
#' @return A data table containing the cracked FHIR resources as defined by the
#'   `table_description`.
#'
#' @export
downloadAndCrackFHIRResources <- function(
    request,
    max_bundles,
    table_description,
    verbose     = VERBOSE,
    log_errors
) {

  bundles <- executeFHIRSearchVariation(
    request = request,
    max_bundles = max_bundles,
    verbose = verbose,
    log_errors = log_errors
  )

  cracked_ressources <- NA

  if (!isSimpleNA(bundles) && all(length(bundles))) {
    cracked_ressources <- fhircrackr::fhir_crack(
      bundles = bundles,
      design = table_description,
      verbose = verbose,
      data.table = TRUE
    )
  }

  return(cracked_ressources)
}

#' Downloads and cracks FHIR resources in parallel for a given resource type and patient IDs.
#'
#' This function downloads FHIR resources specified by the provided IDs for a given resource type in parallel.
#' It then performs cracking on the obtained bundles using the specified table description.
#'
#' @param resource The type of FHIR resource to download and crack.
#' @param ids A vector of patient IDs for the FHIR resources.
#' @param table_description A table description object specifying the structure of the resulting data table.
#' @param ids_at_once The maximum number of IDs to process in each iteration (default: IDS_AT_ONCE).
#' @param id_param_str Additional parameter string for constructing the FHIR request URL.
#' @param verbose Verbosity level (default: VERBOSE)
#'
#' @return A data.table containing the cracked FHIR resources.
#' @export
downloadAndCrackFHIRResourcesByPIDs <- function(
    resource,
    ids,
    table_description,
    ids_at_once       = IDS_AT_ONCE,
    id_param_str,
    verbose = VERBOSE
) {
  WAIT_TIMES <- 2 ** (0 : 7)
  max_trials <- length(WAIT_TIMES)

  verbose <- max(c(0, verbose))
  request <- fhircrackr::fhir_url(
    url        = FHIR_SERVER_ENDPOINT,
    resource   = resource,
    parameters = c(
      '_summary' = 'count',
      '_count'   = '1'
    ),
    url_enc = TRUE
  )
  bndls <- try(
    executeFHIRSearchVariation(
      request    = request,
      log_errors = paste0(resource, 'Availability-Test-error.xml'),
      verbose    = verbose
    )
  )
  if (VL_90_FHIR_RESPONSE <= VERBOSE) {
    print(bndls)
  }

  total <- if (isError(bndls)) {
    if (verbose) {
      cat(formatStringStyle('\nAvailability-Check failed.', fg = 1), '\n')
    }
    0
  } else {
    as.numeric(xml2::xml_attr(xml2::xml_find_all(bndls[[1]], '//total'), 'value'))
  }
  if (total < 1) {
    if (verbose) catWarningMessage(paste0('Warning: No ', resource, 's found on FHIR Server. Return empty Table. Please note!\n'))
    return(NA)
  }

  curr_len <- min(ids_at_once, length(ids))

  if (curr_len < 1) {# if no ids for download. return empty data.table with required columns
    return(completeTable(data.table::data.table(), table_description))
  }

  os <- getOperationSystem()
  ncores <- getAvailableCoreNumber(os)
  if (1 < verbose) {
    cat(paste0(
      'OS:    ',
      formatStringStyle(os, bold = TRUE),
      '\nCores: ',
      formatStringStyle(ncores, bold = TRUE),
      '\n'
    ))
  }
  mb <- MAX_ENCOUNTER_BUNDLES # for later restoring
  MAX_ENCOUNTER_BUNDLES <<- Inf
  run <- 0
  tables <- list()
  pkg <- list()

  curr_len_recent <- 0
  seq_ids  <- seq_len(curr_len)
  curr_ids <- ids[seq_ids]
  ids      <- ids[-seq_ids]

  pkg <- c(pkg, if (0 < curr_len) list(curr_ids))

  if (1 < ncores) {# split ids on cores
    for (nc in seq_len(ncores - 1)) {#nc <- seq_len(ncores - 2)

      curr_len <- min(ids_at_once, length(ids))
      seq_ids  <- seq_len(curr_len)
      curr_ids <- ids[seq_ids]
      ids      <- ids[-seq_ids]

      pkg <- c(pkg, if (0 < curr_len) list(curr_ids))
    }
  }

  resource_name <- table_description@resource
  # if there elements in pkg and at least one of them has a positive length
  while (0 < length(pkg) && any(0 < sapply(pkg, length))) {

    requests <- sapply(pkg, is.character)
    bndl_lengths <- if (0 < sum(requests)) {
      sum(sapply(pkg[requests], length))
    } else 0

    if (0 < verbose) {
      if (any(sapply(pkg, is.character)) && any(!sapply(pkg, is.character))) {
        cat(paste0(
          'Download of ', convertVerboseNumbers(run + 1), ' Set of Bundles for ', bndl_lengths, ' ID', getPluralSuffix(bndl_lengths),
          ' (FHIR Resource: ', resource_name, ' ',substr(gsub(paste0(".*", resource_name), "", pkg$request@.Data),2,30),')',
          ' and Crack of ', convertVerboseNumbers(run), ' Set of Bundles for ', curr_len_recent, ' ID', getPluralSuffix(curr_len_recent), '.\n'
        ))
      } else if (any(sapply(pkg, is.character))) {
        cat(paste0(
          'Download of ', convertVerboseNumbers(run + 1), ' Set of Bundles for ', bndl_lengths, ' ID', getPluralSuffix(bndl_lengths),
          ' (FHIR Resource: ', resource_name, ' ',substr(gsub(paste0(".*", resource_name), "", pkg$request@.Data),2,30),')',
          '\n'
        ))
      } else {
        cat(paste0(
          'Crack of ', convertVerboseNumbers(run), ' Set of Bundles for ', curr_len_recent, ' ID', getPluralSuffix(curr_len_recent), '.\n'
        ))
      }
    }
    pkg <- parallel::mclapply(
      mc.cores = ncores,
      X        = pkg,
      FUN      = function(element) {# element <- pkg[[1]]
        if (!inherits(element, 'character')) {
          unserialized_bundle <- try(lapply(element, fhircrackr::fhir_unserialize))
          if (inherits(unserialized_bundle, 'try-error')) {
            unserialized_bundle
          } else {
            try({
              data.table::rbindlist(
                l         = lapply(
                  unserialized_bundle,
                  function(b) {
                    fhircrackr::fhir_crack(bundles = b, design = table_description, data.table = TRUE, verbose = verbose)
                  }
                ),
                fill      = TRUE,
                use.names = TRUE
              )
            })
          }
        } else {
          if (0 < length(element)) {
            trial <- 1
            while (trial <= max_trials) {
              bundles <- try(getResourcesByIDs(
                endpoint     = FHIR_SERVER_ENDPOINT,
                resource     = resource,
                ids          = element,
                id_param_str = id_param_str,
                parameters   = NULL,
                verbose      = verbose
              ))
              if (inherits(bundles, 'try-error')) {
                if (0 < verbose) {
                  cat(
                    formatStringStyle(
                      'Bundles for the following IDs could not be downloaded:',
                      element,
                      "Request with error:",
                      fhircrackr::fhir_current_request(),
                      fg = 1,
                      bold = TRUE,
                      sep = "\n"
                    ),
                    '\n',
                    pkg$ids
                  )
                  cat(formatStringStyle('Stream lost. Wait for ', WAIT_TIMES[[trial]], ' seconds and try again...\n'))
                }
                Sys.sleep(WAIT_TIMES[[trial]])
                trial <- trial + 1
              } else {
                logRequest(verbose, resource_name, bundles)
                break
              }
            }
            if (max_trials < trial) {
              if (0 < verbose) {
                cat(
                  formatStringStyle(
                    trial,
                    convertVerboseNumbers(trial),
                    'attempt to Download Bundle failed. Bundle is lost. ',
                    'Please note! This may cause further Problems.',
                    fg = 1,
                    bold = TRUE
                  ),
                  '\n'
                )
              }
              NULL
            } else {
              try(fhircrackr::fhir_serialize(bundles))
            }
          }
        }
      }
    )

    for (dt in pkg[sapply(pkg, inherits, 'data.table')]) {
      tables <- c(tables, list(dt))
    }

    pkg <- list(pkg[sapply(pkg, inherits, 'fhir_bundle_list')])

    curr_len_recent <- bndl_lengths
    curr_len <- min(ids_at_once, length(ids))
    seq_ids  <- seq_len(curr_len)
    curr_ids <- ids[seq_ids]
    ids      <- ids[-seq_ids]
    pkg <- c(pkg, if (0 < curr_len) list(curr_ids))

    if (2 < ncores) {
      for (nc in seq_len(ncores - 2)) {#nc <- seq_len(ncores - 1)[[1]]
        curr_len <- min(ids_at_once, length(ids))
        seq_ids  <- seq_len(curr_len)
        curr_ids <- ids[seq_ids]
        ids      <- ids[-seq_ids]

        pkg <- c(pkg, if (0 < curr_len) list(curr_ids))
        #        nc <- nc + 1
      }
    }

    run <- run + 1
  }
  MAX_ENCOUNTER_BUNDLES <<- mb
  completeTable(unique(data.table::rbindlist(tables, fill = TRUE)), table_description)
}

#' Load Resources by Their Own IDs
#'
#' This function downloads and processes resources specified by their IDs. It uses a parallel
#' downloading and cracking method tailored for handling resources described in a table structure.
#' The function is part of a larger workflow designed to work with polar data resources.
#'
#' @param ids A vector of resource IDs. These should be the unique identifiers for the resources you
#' wish to download and process. The function expects these IDs to be in a specific format, where
#' the actual ID follows the last slash ("/") in each string.
#' @param table_description An object containing the description of the table where the resources
#' are to be found. This object must have a specific structure, including a resource slot that
#' contains the URL or identifier needed for downloading the resources.
#'
#' @return Returns a table of the downloaded resources, processed and cracked open according to the
#' specifications in `table_description`. The exact structure of the returned table depends on the
#' `table_description` parameter and the data processing within `downloadAndCrackFHIRResourcesByPIDs`.
#'
#' @export
loadFHIRResourcesByOwnID <- function(ids, table_description) {
  resource <- table_description@resource@.Data
  if (length(ids)) {
    resource_table <- downloadAndCrackFHIRResourcesByPIDs(
      resource = resource,
      id_param_str = '_id',
      ids = getAfterLastSlash(ids),
      table_description = table_description,
      verbose = VERBOSE
    )
  } else {
    # if there are no IDs -> create an empt table with all needed columns as character columns
    column_names <- table_description@cols@names
    resource_table <- data.table(matrix(ncol = length(column_names), nrow = 0))
    data.table::setnames(resource_table, column_names)
    resource_table[, (column_names) := lapply(.SD, as.character), .SDcols = column_names]
  }
  return(resource_table)
}

#' Load Resources by Patient IDs
#'
#' This function is designed to load resources based on patient IDs. It checks if the requested
#' resource is "Patient" and uses a specific loading function or the general downloading and
#' cracking function for other types of resources. It's tailored for handling resources described
#' in a table structure, specifically for patient-related data.
#'
#' @param patient_IDs A vector of patient IDs, which are the unique identifiers for the patients
#' whose resources you wish to download and process.
#' @param table_description An object describing the table where the resources are to be found.
#' This object must have a specific structure, including a resource slot that contains the URL or
#' identifier needed for downloading the resources.
#'
#' @return Returns a table of the downloaded resources, processed according to the specifications
#' in `table_description`. The function handles different types of resources by adapting the ID
#' parameter string based on the resource type, ensuring correct processing.
#'
#' @export
loadFHIRResourcesByPID <- function(patient_IDs, table_description) {
  resource <- table_description@resource@.Data
  if (resource == "Patient") {
    resource_table <- loadFHIRResourcesByOwnID(patient_IDs, table_description)
  } else {
    resource_table <- downloadAndCrackFHIRResourcesByPIDs(
      resource = resource,
      id_param_str = ifelse(resource == 'Consent', 'patient', 'subject'),
      ids = patient_IDs,
      table_description = table_description,
      verbose = VERBOSE
    )
  }
  return(resource_table)
}

#' Download FHIR resources by patient IDs and perform parallel cracking for each resource type.
#'
#' This function iterates over the resource types defined in table_description, and for each resource type,
#' it calls the downloadAndCrackFHIRResourcesByPIDs function to download and crack FHIR resources
#' associated with the given patient IDs. The download behavior is adjusted based on the resource type.
#'
#' @param patient_IDs A vector of patient IDs for whom FHIR resources should be retrieved.
#' @param table_descriptions A list of table descriptions for different FHIR resource types.
#'
#' @return A list containing a table for each resource type, with resource type names as keys.
#' @export
loadMultipleFHIRResourcesByPID <- function(patient_IDs, table_descriptions) {
  resource_name_to_resources <- list()
  for (table_description in table_descriptions) {
    resource_table <- loadFHIRResourcesByPID(patient_IDs, table_description)
    if (!isSimpleNA(resource_table)) {
      resource <- table_description@resource@.Data
      resource_name_to_resources[[resource]] <- resource_table
      if (nrow(resource_table)) {
        printAllTables(resource_table, resource)
      } else {
        catInfoMessage(paste("Info: No", resource, "resources found for the given Patient IDs.\n"))
      }
    }
  }
  resource_name_to_resources
}

#' Add Common Parameters to FHIR Resource Request
#'
#' This function adds common parameters, such as '_count' and '_sort', to a list of FHIR resource query parameters.
#'
#' @param parameters A list of FHIR resource query parameters.
#'
#' @return A modified list of FHIR resource query parameters with common parameters added.
#'
#' @export
addParamToFHIRRequest <- function(parameters = NULL) {
  parameters <- parameters[!is.na(parameters)]
  if (!'_count' %in% names(parameters) && exists('COUNT_PER_BUNDLE') && !is.null(COUNT_PER_BUNDLE) && !is.na(COUNT_PER_BUNDLE) && COUNT_PER_BUNDLE != '') {
    parameters <- c(parameters, c('_count' = COUNT_PER_BUNDLE))
  }
  if (!'_sort' %in% names(parameters) && exists('SORT') && !is.null(SORT) && !is.na(SORT) && SORT != '') {
    parameters <- c(parameters, c('_sort' = SORT))
  }
  parameters
}
