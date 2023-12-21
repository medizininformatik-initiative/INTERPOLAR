#' Generate directory names for project outputs.
#'
#' This function takes a project name and constructs directory names for both global and local project outputs.
#' It creates directory names for various result categories, including bundles, log, performance, and tables.
#' The function utilizes predefined global and local output folder names and appends a project-specific timestamp to them.
#' The resulting directory names are organized into a named list for easy access and reference.
#'
#' @param project_name The name of the project.
#' @param project_time_stamp Time stamp as extension for the current project subfolders
#'
#' @return A named list containing directory names for global and local project outputs.
#'
#' @export
get_project_dir_names <- function(project_name = PROJECT_NAME, project_time_stamp = PROJECT_TIME_STAMP) {

  PROJECT_NAME <<- project_name
  PROJECT_TIME_STAMP <<- project_time_stamp

  global <- "outputGlobal"
  local <- "outputLocal"

  local_results_directories_names  <- c("bundles", "log", "performance", "tables")
  global_results_directories_names <- c("performance", "requests")

  global_main_path <- fhircrackr::pastep(global, project_name)
  local_main_path <- fhircrackr::pastep(local, project_name)

  global_main_path <- paste0(global_main_path, PROJECT_TIME_STAMP)
  local_main_path <- paste0(local_main_path, PROJECT_TIME_STAMP)

  namedListByParam(
    gobal,
    local,
    local_results_directories_names,
    global_results_directories_names,
    global_main_path,
    local_main_path
  )
}

#'
#' This function is used by the framework itself
#'
#' @param project_name name of the project
#'
#' @export
create_dirs <- function(project_name = PROJECT_NAME) {
  SUB_PROJECTS_DIRS <<- get_project_dir_names(project_name)

  for (rd in SUB_PROJECTS_DIRS$global_results_directories_names) {
    dir.create(paste0(SUB_PROJECTS_DIRS$global_main_path, "/", rd), recursive = TRUE)
  }

  for (rd in SUB_PROJECTS_DIRS$local_results_directories_names) {
    dir.create(paste0(SUB_PROJECTS_DIRS$local_main_path, "/", rd), recursive = TRUE)
  }
}


#' Return the path to the log directory of the specific sub project
#'
#' @param project_name name of the project
#'
#' @return A character of length one containing the path to the sub project specific log directory.
#'
#' @export
polar_path_to_log_directory <- function(project_name = PROJECT_NAME) {
  fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "log")
}


#' Return the combined paths of the log directory of the specific sub project and a new path
#'
#' @param path the sub directory or file name to add
#'
#' @return A character of length one containing the path to add to the sub project specific log directory.
#'
#' @export
polar_add_to_log_path <- function(path) {
  fhircrackr::pastep(polar_path_to_log_directory(), path)
}



#' Return the path to the bundles directory of the specific sub project
#'
#' @return A character of length one containing the path to the sub project specific log directory.
#'
#' @export
polar_path_to_bundles_directory <- function() {
  fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "bundles")
}


#' Return the combined paths of the bundles directory of the specific sub project and a new path
#'
#' @param path the sub directory or file name to add
#'
#' @return A character of length one containing the path to add to the sub project specific bundles directory.
#'
#' @export
polar_add_to_bundles_path <- function(path) {
  fhircrackr::pastep(polar_path_to_bundles_directory(), path)
}



#' Return the path to the tables directory of the specific sub project
#'
#' @return A character of length one containing the path to the sub project specific log directory.
#'
#' @export
polar_path_to_tables_directory <- function() {
  fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "tables")
}


#' Return the combined paths of the tables directory of the specific sub project and a new path
#'
#' @param path the sub directory or file name to add
#'
#' @return A character of length one containing the path to add to the sub project specific tables directory.
#'
#' @export
polar_add_to_tables_path <- function(path) {
  fhircrackr::pastep(polar_path_to_tables_directory(), path)
}


#' Load a single Bundle
#'
#' polar_load('bundle.xml')
#'
#' @param path the path to load from
#'
#' @return A fhir_bundle as XML
#' @importFrom fhircrackr fhir_bundle_xml
#' @importFrom xml2 read_xml
#' @export
polar_load_bundle <- function(path) {
  fhircrackr::fhir_bundle_xml(bundle = xml2::read_xml(x = path, encoding = 'utf-8'))
}


#' Save Bundle
##
#' bndls <- fhircrackr::fhir_search("http://vonk.fire.ly/R4/Patient?gender=male", max_bundles = 1)
#' polar_save_bundles(bndls)
#'
#' @param bundles A fhir_bundle_list containing the bundles to store to the sub project related bundles directory.
#'
#' @return Nothing
#' @importFrom fhircrackr fhir_save
#' @export
polar_save_bundles <- function(bundles) {
  bundles_name <- deparse(substitute(bundles))
  fhircrackr::fhir_save(bundles = bundles, directory = fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "bundles", bundles_name))
}


#' Save a Request without url and endpoint in the *public* `requests` directory to which was created for the specific subproject.
#'
#' (request <- fhircrackr::fhir_url(
#'   url        = "http://vonk.fire.ly/R4",
#'   resource   = "Patient",
#'   parameters = c(
#'   "gender" = "female",
#'   "_count" = "10"
#' )))
#' polar_save_request(request = request, filename_without_extension = "my_request")
#'
#' @param request A character of length one holding the fhir search request with url and endpoint.
#' @param filename_without_extension A character of length one.
#'
#' @return Nothing.
#'
#' @export
polar_save_request <- function(request, filename_without_extension) {
  utils::write.table(data.table::data.table(request = request), file = fhircrackr::pastep(SUB_PROJECTS_DIRS$global, "requests", filename_without_extension, ext = ".tsv"), sep = "\t", quote = FALSE, dec = ".", row.names = FALSE, col.names = TRUE)
}


###
# save_performance into the sub project related request directory. Don't use it by yourself!
###
#' Save a Clock history in the *public* `performance` directory to which was created for the specific subproject.
#'
#' clock_$reset()
#' clock_$measure_process_time("Some Process", {for(i in 1:1000)function(n)mean(cos(1:n))})
#' clock_
#' polar_save_performance(filename_without_extension = "some_process")
#' my_clock <- clock()
#' my_clock$measure_process_time("Some different Process", {for(i in 1:1000)function(n)mean(cos(1:n))})
#' my_clock
#' save_performance(filename_without_extension = "some_differen_process", clock = my_clock)
#'
#' @param filename_without_extension A character vector of length one.
#' @param clock A `Clock` object. Defaults to the global environment `Clock` object `clock_`.
#'
#' @return Nothing.
#' @export
save_performance <- function(filename_without_extension, clock = if (is.null(polar_clock)) NULL else polar_clock) {
  clock$write(filename_without_extension = fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "performance", filename_without_extension), hide_errors = FALSE)
  clock$write(filename_without_extension = fhircrackr::pastep(SUB_PROJECTS_DIRS$global, "performance", filename_without_extension), hide_errors = TRUE)
}


#' Write versions to folder performance
#'
#' @param versions A data.table containing the columns Software and Verion
#'
#' @return NULL
#' @export
polar_save_versions <- function(versions) {
  utils::write.table(
    x         = versions,
    file      = fhircrackr::pastep(SUB_PROJECTS_DIRS$global, 'performance', 'versions-retrieval', ext = '.tsv'),
    sep       = '\t',
    quote     = FALSE,
    dec       = '.',
    row.names = FALSE,
    col.names = TRUE
  )
}


###
# save error into the sub project related log directory
###
#' Save an Error Message in the *private* `log` directory to which was created for the specific subproject.
#'
#' polar_save_error(err = "Housten! We have a Problem!", filename_without_extension = "big_problem")
#'
#' @param err A character of length one. The error message.
#' @param filename_without_extension A character of length one.
#'
#' @return Nothing.
#' @export
polar_save_error <- function(err, filename_without_extension) {
  cat(err, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "log", filename_without_extension, ext = ".txt"), sep = "\n")
}


###
# save a data.frame/data.table as tsv into the sub project related tables directory
###
#' Save a Table/Data.Frame as .csv in the *private* `tables` directory to which was created for the specific subproject.
#'
#' d <- data.frame(x=1:10, y=rnorm(10))
#' polar_save_table_as_csv(table = d)
#'
#' @param table A data.frame/data.table object.
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#' @param sep the field separator string. Values within each row of x are separated by this string.
#'
#' @return Nothing.
#' @export
polar_save_table_as_csv <- function(table, filename_without_extension = NA, sep = ";") {
  if (is.na(filename_without_extension)) {
    filename_without_extension <- as.character(sys.call()[2]) # get the table variable name
  }
  utils::write.table(table, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "tables", filename_without_extension, ext = ".csv"), sep = sep, quote = FALSE, dec = ".", row.names = FALSE, col.names = TRUE)
}


###
# save a data.frame/data.table as tsv into the sub project related tables directory
###
#' Save a Table/Data.Frame as .tsv in the *private* `tables` directory to which was created for the specific subproject.
#'
#' d <- data.frame(x=1:10, y=rnorm(10))
#' polar_save_table_as_tsv(table = d)
#'
#' @param table A data.frame/data.table object.
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#'
#' @return Nothing.
#' @export
polar_save_table_as_tsv <- function(table, filename_without_extension = NA) {
  if (is.na(filename_without_extension)) {
    filename_without_extension <- as.character(sys.call()[2]) # get the table variable name
  }
  utils::write.table(table, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "tables", filename_without_extension, ext = ".tsv"), sep = "\t", quote = FALSE, dec = ".", row.names = FALSE, col.names = TRUE)
}


###
# save a data.frame/data.table as tsv into the sub project related tables directory
###
#' Save a Table/Data.Frame as .tsv in the *private* `tables` directory to which was created for the specific subproject.
#'
#' d <- data.frame(x=1:10, y=rnorm(10))
#' polar_save_table_as_tsv(table = d)
#'
#' @param table A data.frame/data.table object.
#' @param table_name If the default NA is not changed then the name is the name of the table variable.
#'
#' @return Nothing.
#' @export
polar_save_table_as_rdata <- function(table, table_name = NA) {
  if (is.na(table_name)) {
    table_name <- as.character(sys.call()[2]) # get the table variable name
  }
  save(table, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "tables", table_name, ext = '.RData'))
}

#' Save an Object as RDS-File in the *private* `tables` directory to which was created for the specific subproject.
#'
#' a <- 1
#' polar_write_rdata(a)
#'
#' @param object the table to write
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#' @param project_sub_dir subdirectory of the current working directory where the table is located. If NA (default),
#' then the tables will be loaded from outputLocal/tables'.
#'
#' @return Nothing.
#'
#' @export
polar_write_rdata <- function(object = table, filename_without_extension = NA, project_sub_dir = NA) {
  if (is.na(filename_without_extension)) {
    filename_without_extension <- as.character(sys.call()[2]) # get the table variable name
  }
  if (is.na(project_sub_dir)) {
    project_sub_dir <- fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "tables")
    #saveRDS(object = object, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "tables", filename_without_extension, ext = '.RData'))
  } else {
    project_sub_dir <- fhircrackr::pastep('.', project_sub_dir)
  }
  saveRDS(object = object, file = fhircrackr::pastep(project_sub_dir, filename_without_extension, ext = '.RData'))
}

#' Read an Object as RDS-File from the *private* `tables` directory to which was created for the specific subproject.
#'
#' a <- polar_read_rdata('a')
#'
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#' @param project_sub_dir subdirectory of the current working directory where the table is located. If NA (default),
#' then the tables will be loaded from outputLocal/tables'.
#'
#' @return the object
#'
#' @export
polar_read_rdata <- function(filename_without_extension, project_sub_dir = NA) {
  # default project_sub_dir is NA -> load tables from outputLocal/tables
  if (is.na(project_sub_dir)) {
    project_sub_dir <- fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "tables")
  } else {
    project_sub_dir <- fhircrackr::pastep('.', project_sub_dir)
  }
  fname <- fhircrackr::pastep(project_sub_dir, filename_without_extension, ext = '.RData')
  data <- NULL
  if (file.exists(fname)) {
    # https://cloud.r-project.org/web/packages/data.table/vignettes/datatable-faq.html#reading-data.table-from-rds-or-rdata-file
    # 5.3 Reading data.table from RDS or RData file
    # ---------------------------------------------
    # *.RDS and *.RData are file types which can store in-memory R objects
    # on disk efficiently. However, storing data.table into the binary file
    # loses its column over-allocation. This isn't a big deal – your
    # data.table will be copied in memory on the next by reference
    # operation and throw a warning. Therefore it is recommended to call
    # setalloccol() on each data.table loaded with readRDS() or load() calls.
    data <- readRDS(fname)
    if ('data.table' %in% class(data)) {
      invisible(data.table::setalloccol(data))
    }
  }
  data
}

#' Save all given data as .RData in the *private* `tables` directory to which was created for the specific subproject.
#'
#' d1 <- data.frame(x=1:10, y=rnorm(10))
#' d2 <- data.frame(x=1:10, y=runif(10))
#' polar_save_rdata(d1, d2)
#'
#' @param ... A collection of variables to store.
#'
#' @return Nothing.
#' @export
polar_save_rdata <- function(...) {
  save(..., file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local, 'tables', 'tables.RData'))
}

#' Save a Result Table of an ***ANALYSIS-SCTIPT*** in the *public* `results` directory to which was created for the specific subproject.
#'
#' @param table the table to save
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#' @param extension the file name extension (default is ".txt")
#' @param sep the field separator string. Values within each row of x are separated by this string.
#' @param dec the string to use for decimal points in numeric or complex columns: must be a single character
#' @param collapse If there are any list columns then all list items will be pasted with this delimiter to one string
#' and the class of the column will be changed to character. Default is ' ~ '.
#' @param row.names either a logical value indicating whether the row names of x are to be written along with x, or a
#' character vector of row names to be written.
#'
#' @return Nothing.
#' @export
polar_save_result_table_as_csv <- function(table, filename_without_extension = NA, extension = ".txt", sep = "\t", dec = ".", collapse = ' ~ ', row.names = FALSE) {
  if (is.na(filename_without_extension)) {
    filename_without_extension <- as.character(sys.call()[2]) # get the table variable name
  }
  convertListColumnsToString(table, separator = collapse) # converts all list to strings
  utils::write.table(table, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$global, "results", filename_without_extension, ext = extension), sep = sep, quote = FALSE, dec = dec, row.names = row.names, col.names = TRUE)
}

#' Save a Result Table of an ***ANALYSIS-SCTIPT*** in the *local* `tables` directory to which was created for the specific subproject.
#'
#' @param table the table to save
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#' @param extension the file name extension (default is ".txt")
#' @param sep the field separator string. Values within each row of x are separated by this string.
#' @param dec the string to use for decimal points in numeric or complex columns: must be a single character
#' @param collapse If there are any list columns then all list items will be pasted with this delimiter to one string
#' and the class of the column will be changed to character. Default is ' ~ '.
#' @param row.names either a logical value indicating whether the row names of x are to be written along with x, or a
#' character vector of row names to be written.
#'
#' @return Nothing.
#' @export
polar_save_result_table_as_csv_local <- function(table, filename_without_extension = NA, extension = ".txt", sep = "\t", dec = ".", collapse = ' ~ ', row.names = FALSE) {
  if (is.na(filename_without_extension)) {
    filename_without_extension <- as.character(sys.call()[2]) # get the table variable name
  }
  convertListColumnsToString(table, separator = collapse) # converts all list to strings
  utils::write.table(table, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local, "tables", filename_without_extension, ext = extension), sep = sep, quote = FALSE, dec = dec, row.names = row.names, col.names = TRUE)
}

#' Save a Result of an ***ANALYSIS-SCTIPT*** in the *public* `results` directory to which was created for the specific subproject.
#'
#' @param ... A list of data.
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#'
#' @return Nothing.
#' @export
polar_save_result_as_rdata <- function(..., filename_without_extension) {
  save(..., file = fhircrackr::pastep(SUB_PROJECTS_DIRS$global, "results", filename_without_extension, ext = ".RData"))
}
