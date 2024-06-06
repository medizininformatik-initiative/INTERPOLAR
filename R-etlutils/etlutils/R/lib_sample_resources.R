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
    run_in_in_ignore_error('Refresh FHIR_TOKEN', {
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

#' Get Resources' Counts
#'
#' @param endpoint A character of length 1 containing the FHIR R4 endpoint.
#' @param resource A character of length 1 containing the Resource's name.
#' @param parameters Either a character of length 1 containing the parameter string or
#' a named vector of the form c("gender" = "male", "_summary" = "count").
#' @param verbose An integer of length 1 containing the level of verbosity. Defaults to 0.
#'
#' @return An integer of length 1 containing the number of resources named `resource`
#' filtered by parameters available on the FHIR R4 endpoint.
#' @export
getResourcesCounts <- function(endpoint, resource, parameters = NULL, verbose = 0) {
  as.numeric(# return as number
    xml2::xml_attr(# get attribute "value" of found xml tag "total"
      xml2::xml_find_first(# find first occurrence of tag "total"
        polar_fhir_search(# get resources count
          fhircrackr::fhir_url(
            url = endpoint,
            resource = resource,
            parameters = pasteFHIRSearchParams(parameters = parameters, parameters2add = c("_summary" = "count"), add_question_sign = F),
          ),
          verbose = verbose
        )[[1]],
        "//total"
      ),
      "value"
    )
  )
}

#' Get Resources' IDs
#'
#' @param endpoint A character of length 1 containing the FHIR R4 endpoint.
#' @param resource A character of length 1 containing the Resource's name.
#' @param parameters Either a character of length 1 containing the parameter string or
#' a named vector of the form c("gender" = "male", "_summary" = "count").
#' @param verbose An integer of length 1 containing the level of verbosity. Defaults to 0.
#'
#' @return A character containing the IDs all requested Resources.
#' @export
getResourcesIDs <- function(endpoint, resource, parameters = NULL, verbose = 0) {
  if (0 < verbose) {
    cat(
      paste0(
        "Download ",
        getResourcesCounts(
          endpoint = endpoint,
          resource = resource,
          parameters = pasteFHIRSearchParams(parameters)
        ),
        " ",
        resource,
        "s' IDs...\n"
      )
    )
  }
  bundles <- try(
    polar_fhir_search(
      url <- fhircrackr::fhir_url(
        url = endpoint,
        resource = resource,
        parameters = pasteFHIRSearchParams(parameters, c("_elements" = "id", "_count" = "500"))
      ),
      verbose = verbose
    )
  )
  if (VL_90_FHIR_RESPONSE <= VERBOSE) {
    print (bundles)
  }

  if (inherits(bundles, "try-error")) {
    warning(paste0("The url ", url, " could not be succesfully resolved. Use fhir_recent_http_error() to get more information!"))
    NA_integer_
  } else {
    unlist(
      lapply(
        bundles,
        function(bundle) {
          xml2::xml_attr(
            xml2::xml_find_all(
              bundle,
              paste0(
                "entry/resource/",
                resource,
                "/id"
              )
            ),
            "value"
          )
        }
      )
    )
  }
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
    collect_ids_for_request <- function(ids, max_ids = length(ids), max_len = MAX_LEN - RES_LEN) {
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
      bnd_ <- polar_fhir_search(request = url_, verbose = verbose)
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
    polar_fhir_search(
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

#' Download and Crack FHIR Resources in Parallel
#'
#' This function downloads FHIR resources by making parallel requests and cracks the bundles in parallel.
#'
#' @param request The initial FHIR request to start the download process.
#' @param table_description The description of the expected table structure for the resource.
#' @param bundles_at_once The maximum number of bundles to process in a single iteration.
#' @param verbose An integer specifying the verbosity level.
#' @param bundles_left The total number of bundles to download and process.
#' @param max_cores The maximum number of CPU cores to use for parallel processing.
#' @param log_errors The file name for logging errors during the process.
#'
#' @return A data.table containing the cracked FHIR resource data.
#' @export
downloadAndCrackFHIRResources <- function(
    request,
    table_description,
    bundles_at_once   = 20,
    verbose           = 1,
    bundles_left      = Inf,
    max_cores         = 2, #1core: Download, 1core: crack (the previous downloaded bundles)
    log_errors        = 'enc_error.xml'
) {

  WAIT_TIMES <- DELAY_REQ ** (0 : 7) # try 8 times and wait DELAY_REQ^loop seconds
  max_trials <- length(WAIT_TIMES) # 8

  if (bundles_left < 1) {# if no bundle to download
    stop(
      paste0(
        'bundles_left needs to be positive. bundles_left is ', bundles_left, '. Stop execution here.'
      )
    )
  }
  if (bundles_left < bundles_at_once) {# bundles_at_once cannot be greater than bundles_left
    bundles_at_once <- bundles_left
  }

  # in case of relative URL in next_link
  # extract the base url, FHIR_ENDPOINT might contain some additional paths, such as
  # http://im.a.fhir.endpoint/fhir/api/v4
  baseurl <- stringr::str_match(FHIR_SERVER_ENDPOINT, "(.*?:\\/\\/.*?)\\/")[[2]]
  tables <- list()
  i <- 0
  curr_request <- request # first request
  pkg <- list(request = curr_request, bundles = NULL) # store request with empty bundle in pkg
  succesfully <- TRUE
  resource_name <- table_description@resource
  while (!is.null(pkg$request) || !is.null(pkg$bundles)) {#while there is at least a request or a bundle in pkg
    if (0 < verbose) {
      if (!is.null(pkg$request) && !is.null(pkg$bundles)) {
        cat(paste0(
          'Download of ', convertVerboseNumbers(i + 1), ' ', bundles_at_once, ' bundle', getPluralSuffix(bundles_at_once),
          ' (FHIR Resource: ', resource_name, ' ',
          substr(gsub(paste0(".*", resource_name), "", pkg$request@.Data),2,30),')',
          ' and Crack of ', convertVerboseNumbers(i), ' ', length(pkg$bundles), ' bundle', getPluralSuffix(length(pkg$bundles)), '.\n'
        ))
      } else if (!is.null(pkg$request) && is.null(pkg$bundles)) {
        cat(paste0(
          'Download of ', convertVerboseNumbers(i + 1), ' ', bundles_at_once, ' bundle', getPluralSuffix(bundles_at_once),
          ' (FHIR Resource: ', resource_name, ' ',
          substr(gsub(paste0(".*", resource_name), "", pkg$request@.Data),2,30),')',
          '.\n'
        ))
      } else {
        cat(paste0(
          'Crack of ', convertVerboseNumbers(i), ' ', length(pkg$bundles), ' bundle', getPluralSuffix(length(pkg$bundles)), '.\n'
        ))
      }
    }
    trial <- 1
    succ <- FALSE

    while (trial <= max_trials && !succ) {
      pkg <- parallel::mclapply(# parallel apply with max max_cores cores if available
        mc.cores = limitAvailableCoreNumber(max_cores),
        X        = namedListByValue(names(pkg)),
        # alternating function
        FUN      = function(n) {# n <- names(pkg)[[1]]
          element <- pkg[[n]] # get nth pkg element
          if (!is.null(element)) {# if there is a element
            if (n == 'request') {# if name of pkg is 'request'
              if (inherits(element, 'fhir_url')) {# if the element itself is a fhir request
                bundles <- try(polar_fhir_search( # try to download resources
                  request     = element,
                  verbose     = verbose,
                  log_errors  = log_errors,
                  max_bundles = bundles_at_once
                ))
                if (inherits(bundles, 'try-error')) {# if download fails return error stored in variable bundle
                  if (0 < verbose) {
                    cat(
                      styled_string(
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
                    cat(styled_string('Stream lost. Wait for ', WAIT_TIMES[[trial]], ' seconds and try again...\n'))
                  }
                } else {# if download was successful
                  logRequest(verbose, resource_name, bundles)
                  try(fhircrackr::fhir_serialize(bundles)) # return serialized bundles due to stable addressing
                }
              } else {# return nothing
                NULL
              }
            } else if (n == 'bundles') {# if name of pkg is 'bundles'
              if (inherits(element, 'fhir_bundle_list')) {# if element is a fhir_bundle_list
                unserialized_bundle <- try(fhircrackr::fhir_unserialize(element)) # serialize bundles
                if (inherits(unserialized_bundle, 'try-error')) {# return error stored in unserialized_bundle
                  unserialized_bundle
                } else {# try to crack bundles ignoring errors
                  try(fhircrackr::fhir_crack(bundles = unserialized_bundle, design = table_description, data.table = TRUE, verbose = verbose))
                }
              } else {# return nothing
                NULL
              }
            } else {# some mysterious name has occurred in pkg names
              stop(paste0(n, ' is not part of the pkg list. Stop Execution here.'))
            }
          } else {# element is NULL here
            # NULL             #is.null(element)
            element #aka NULL
          }
        }
      )

      if (inherits(pkg$bundles, 'data.table')) {# if pkg$bundles are actually data.tables
        tables <- c(tables, list(pkg$bundles)) # add to resulting table list
        pkg$bundles <- NULL # remove bundle from pkg
      }

      # if we have no request of request is a fhir_bundle_list
      if (is.null(pkg$request) || inherits(pkg$request, 'fhir_bundle_list')) {
        succ <- TRUE # we succeded
      } else {# otherwise we have to repeat
        succ <- FALSE
        if (0 < verbose) {
          cat_red(pkg$request)
          cat_red(paste0('Stream lost. Wait for ', WAIT_TIMES[[trial]], ' seconds and try again...\n'))
        }
        Sys.sleep(WAIT_TIMES[[trial]]) # wait longer and longer between requests
        pkg$request <- curr_request # and again
        trial <- trial + 1 # count trials
      }
    }

    if (max_trials < trial) {# if we' reached've done to many trials
      if (0 < verbose)
        cat_red('Download Stream broken. Leave Download Routine now. Please note! This may cause further problems.\n')
      succesfully <- FALSE
      break; # stop while loop
    } else if (succ) {# if trial <= max_trials
      pkg$bundles <- pkg$request # remember pkg request contains here a fhir_bundle_list
      if (!is.null(pkg$request) && inherits(pkg$request, 'fhir_bundle_list')) {# if it is so
        unserialized_bundle <- fhircrackr::fhir_unserialize(pkg$request) # unserialize the bundles
        bundles_left <- bundles_left - length(unserialized_bundle)
        if (0 < bundles_left) {# if there are bundle left
          pkg$request <- # create next request from next link found in bundle
            if (0 < length(unserialized_bundle) && 0 < length(unserialized_bundle[length(unserialized_bundle)][[1]]@next_link)) {
              next_link <- unserialized_bundle[length(unserialized_bundle)][[1]]@next_link

              #is next_link a relative URL?
              if (grepl("^/", next_link) == TRUE) {
                next_link <- fhircrackr::fhir_url(paste0(baseurl, next_link), url_enc = NEXT_LINK_ENCODE)
              }

              #check for issues such as missing port specification
              if (9 <= VERBOSE) {

                if (!grepl(baseurl, next_link)) {

                  warning("specified FHIR_ENDPOINT is not part of the next_link URL\n")
                }

                if ( URL_PORT_SPEC && grepl(":[0-9]+(/.*)?$", next_link) ) {

                  warning("specified FHIR_ENDPOINT provides a PORT, whereas the next_link URL does not provide a PORT\n")
                }
              }
              next_link
            } else {
              NULL
            }

          if (bundles_left < bundles_at_once) {
            bundles_at_once <- bundles_left
          }
        } else {# if no bundles left
          pkg$request <- NULL
        }
      }
      i <- i + 1
    }
  }
  if (!succesfully) {
    if (0 < verbose)
      cat_red('Download Stream broken. Leave Download Routine now. Please note! This may cause further problems.\n')
  }
  # complete tables with missing column
  complete_table(unique(data.table::rbindlist(tables, fill = TRUE)), table_description)
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
    polar_fhir_search(
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
      cat(styled_string('\nAvailability-Check failed.', fg = 1), '\n')
    }
    0
  } else {
    as.numeric(xml2::xml_attr(xml2::xml_find_all(bndls[[1]], '//total'), 'value'))
  }
  if (total < 1) {
    if (verbose) cat_warning(paste0('Warning: No ', resource, 's found on FHIR Server. Return empty Table. Please note!\n'))
    return(NA)
  }

  curr_len <- min(ids_at_once, length(ids))

  if (curr_len < 1) {# if no ids for download. return empty data.table with required columns
    return(complete_table(data.table::data.table(), table_description))
  }

  os <- getOperationSystem()
  ncores <- getAvailableCoreNumber(os)
  if (1 < verbose) {
    cat(paste0(
      'OS:    ',
      styled_string(os, bold = TRUE),
      '\nCores: ',
      styled_string(ncores, bold = TRUE),
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
                    styled_string(
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
                  cat(styled_string('Stream lost. Wait for ', WAIT_TIMES[[trial]], ' seconds and try again...\n'))
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
                  styled_string(
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
  complete_table(unique(data.table::rbindlist(tables, fill = TRUE)), table_description)
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
  if (!rlang::is_empty(ids)) {
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
        cat_info(paste("Info: No", resource, "resources found for the given Patient IDs.\n"))
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
