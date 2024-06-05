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
getProjectDirNames <- function(project_name = PROJECT_NAME, project_time_stamp = PROJECT_TIME_STAMP) {

  PROJECT_NAME <<- project_name
  PROJECT_TIME_STAMP <<- project_time_stamp

  global_dir <- "outputGlobal"
  local_dir <- "outputLocal"

  local_results_directories_names  <- c("bundles", "log", "performance", "tables")
  global_results_directories_names <- c("performance", "requests")

  global_dir <- fhircrackr::pastep(global_dir, project_name)
  local_dir <- fhircrackr::pastep(local_dir, project_name)

  global_dir <- paste0(global_dir, PROJECT_TIME_STAMP)
  local_dir <- paste0(local_dir, PROJECT_TIME_STAMP)

  namedListByParam(
    global_dir,
    local_dir,
    local_results_directories_names,
    global_results_directories_names
  )
}

#' Rename a Directory with Creation Timestamp If It Exists
#'
#' This function checks if a specified directory exists. If it does, the directory is renamed
#' by appending its creation time to its original name, optionally prefixed by a given string.
#' Also, this function deletes the oldest directories in the specified outer directory
#' if the count of directories exceeds the specified limit.
#'
#' @param dir The directory path to check and rename.
#' @param MAX_DIR_COUNT An optional maximum count of directories.
#'        If the count of directories exceeds this value, the oldest directories will be deleted.
#'        Default is NA, meaning no deletion is performed.
#' @param timeStampPrefix An optional string to prefix to the creation time in the new name.
#'        Default is an empty string.
#'
#' @details If the directory exists, the function retrieves its creation time, formats it to
#' replace spaces with underscores and colons with dashes, and then constructs a new directory
#' name by appending this timestamp to the original directory name with an optional prefix.
#' Finally, it renames the directory to this new name.
#'
#' If the `MAX_DIR_COUNT` parameter is provided and the count of directories in the outer directory
#' exceeds this value, the function will delete the oldest directories until the count matches
#' the specified limit. The deletion is performed in ascending order based on the creation time
#' embedded in the directory names.
#'
#' @return Returns the new directory name if the directory exists and was renamed, or `NA`
#' if the directory does not exist or no action was taken.
#'
#' @export
renameWithCreationTimeIfDirExists <- function(dir, MAX_DIR_COUNT = NA, timeStampPrefix = "") {
  newName <- NA
  if (dir.exists(dir)) {
    dirCreationTime <- file.info(dir)$ctime
    dirCreationTime <- as.POSIXct(dirCreationTime, tz = "GMT")  # Convert to POSIXct
    dirCreationTime <- format(dirCreationTime, "%Y-%m-%d_%H-%M-%S")  # Format without milliseconds
    dirCreationTime <- gsub(" ", "_", dirCreationTime)
    dirCreationTime <- gsub(":", "-", dirCreationTime)
    newName <- paste0(dir, timeStampPrefix, "_", dirCreationTime)
    file.rename(dir, newName)

    # Extract outer directory
    outer_dir <- sub("/.*", "", dir)
    # Extract inner directory
    inner_dir <- sub(".*/", "", dir)
    # Specific Files in outer dir
    files <- list.files(outer_dir, inner_dir)
    # Number of files in outer dir
    num_files <- length(files)
    if (num_files > MAX_DIR_COUNT && !is.na(MAX_DIR_COUNT)) {
      # Sort files (oldest first)
      sorted_files <- sort(files)
      # Calculate number of files to delete
      num_files_to_delete <- num_files - MAX_DIR_COUNT
      # Delete the oldest files
      for (i in 1:num_files_to_delete) {
        # Create full path to the file to be deleted
        dir_path <- file.path(outer_dir, sorted_files[i])
        # Delete paths
        unlink(dir_path, recursive = TRUE)
      }
    }
  }
  return(newName)
}

#'
#' This function is used by the framework itself
#'
#' @param project_name name of the project
#' @param showWarnings logical; should the warnings on failure be shown?
#'
#' @export
createDIRS <- function(project_name = PROJECT_NAME, showWarnings = FALSE) {
  SUB_PROJECTS_DIRS <<- getProjectDirNames(project_name)
  renameWithCreationTimeIfDirExists(SUB_PROJECTS_DIRS$global_dir, MAX_DIR_COUNT)
  renameWithCreationTimeIfDirExists(SUB_PROJECTS_DIRS$local_dir, MAX_DIR_COUNT)
  for (rd in SUB_PROJECTS_DIRS$global_results_directories_names) {
    dir.create(paste0(SUB_PROJECTS_DIRS$global_dir, "/", rd), recursive = TRUE, showWarnings = showWarnings)
  }
  for (rd in SUB_PROJECTS_DIRS$local_results_directories_names) {
    dir.create(paste0(SUB_PROJECTS_DIRS$local_dir, "/", rd), recursive = TRUE, showWarnings = showWarnings)
  }
}

#' Return the path to the log directory of the specific sub project
#'
#' @param project_name name of the project
#'
#' @return A character of length one containing the path to the sub project specific log directory.
#'
#' @export
returnPathToLogDir <- function(project_name = PROJECT_NAME) {
  fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "log")
}

#' Return the combined paths of the log directory of the specific sub project and a new path
#'
#' @param path the sub directory or file name to add
#'
#' @return A character of length one containing the path to add to the sub project specific log directory.
#'
#' @export
combineLogPaths <- function(path) {
  fhircrackr::pastep(returnPathToLogDir(), path)
}

#' Return the path to the bundles directory of the specific sub project
#'
#' @return A character of length one containing the path to the sub project specific log directory.
#'
#' @export
returnPathToBundlesDir <- function() {
  fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "bundles")
}

#' Return the combined paths of the bundles directory of the specific sub project and a new path
#'
#' @param path the sub directory or file name to add
#'
#' @return A character of length one containing the path to add to the sub project specific bundles directory.
#'
#' @export
combineBundlePaths <- function(path) {
  fhircrackr::pastep(returnPathToBundlesDir(), path)
}

#' Save a Clock history in the *public* `performance` directory to which was created for the specific subproject.
#'
#' @param filename_without_extension A character vector of length one.
#' @param clock A `Clock` object. Defaults to the global environment `Clock` object `clock_`.
#'
#' @export
savePerformance <- function(filename_without_extension = "Performance_informations", clock = getClock()) {
  clock$write(filename_without_extension = fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "performance", filename_without_extension), hide_errors = FALSE)
  clock$write(filename_without_extension = fhircrackr::pastep(SUB_PROJECTS_DIRS$global_dir, "performance", filename_without_extension), hide_errors = TRUE)
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
  cat(err, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "log", filename_without_extension, ext = ".txt"), sep = "\n")
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
  utils::write.table(table, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "tables", filename_without_extension, ext = ".csv"), sep = sep, quote = FALSE, dec = ".", row.names = FALSE, col.names = TRUE)
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
  utils::write.table(table, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "tables", filename_without_extension, ext = ".tsv"), sep = "\t", quote = FALSE, dec = ".", row.names = FALSE, col.names = TRUE)
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
  save(table, file = getLocalRdataFileName(table_name))
}

#' Save an Object as RDS-File in the *private* `tables` directory to which was created for the specific subproject.
#'
#' a <- 1
#' writeRData(a)
#'
#' @param object the table to write
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#' @param project_sub_dir subdirectory of the current working directory where the table is located. If NA (default),
#' then the tables will be loaded from outputLocal/tables'.
#'
#' @return Nothing.
#'
#' @export
writeRData <- function(object = table, filename_without_extension = NA, project_sub_dir = NA) {
  if (is.na(filename_without_extension)) {
    filename_without_extension <- as.character(sys.call()[2]) # get the table variable name
  }
  if (is.na(project_sub_dir)) {
    project_sub_dir <- fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "tables")
    #saveRDS(object = object, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "tables", filename_without_extension, ext = '.RData'))
  } else {
    project_sub_dir <- fhircrackr::pastep('.', project_sub_dir)
  }
  saveRDS(object = object, file = fhircrackr::pastep(project_sub_dir, filename_without_extension, ext = '.RData'))
}

#' Read an Object as RDS-File from the *private* `tables` directory to which was created for the specific subproject.
#'
#' a <- ReadRData('a')
#'
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#' @param project_sub_dir subdirectory of the current working directory where the table is located. If NA (default),
#' then the tables will be loaded from outputLocal/tables'.
#'
#' @return the object
#'
#' @export
ReadRData <- function(filename_without_extension, project_sub_dir = NA) {
  # default project_sub_dir is NA -> load tables from outputLocal/tables
  if (is.na(project_sub_dir)) {
    project_sub_dir <- fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "tables")
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
  save(..., file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, 'tables', 'tables.RData'))
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
  utils::write.table(table, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$global_dir, "results", filename_without_extension, ext = extension), sep = sep, quote = FALSE, dec = dec, row.names = row.names, col.names = TRUE)
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
  utils::write.table(table, file = fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "tables", filename_without_extension, ext = extension), sep = sep, quote = FALSE, dec = dec, row.names = row.names, col.names = TRUE)
}

#' Save a Result of an ***ANALYSIS-SCTIPT*** in the *public* `results` directory to which was created for the specific subproject.
#'
#' @param ... A list of data.
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#'
#' @return Nothing.
#' @export
polar_save_result_as_rdata <- function(..., filename_without_extension) {
  save(..., file = fhircrackr::pastep(SUB_PROJECTS_DIRS$global_dir, "results", filename_without_extension, ext = ".RData"))
}

#' Get the filename for an RData file corresponding to a table
#'
#' This function constructs the filename for an RData file corresponding to the specified table.
#'
#' @param table_name The name of the table.
#' @return A character string representing the filename for the RData file.
#'
#' @export
getLocalRdataFileName <- function(table_name) {
  fhircrackr::pastep(SUB_PROJECTS_DIRS$local_dir, "tables", table_name, ext = '.RData')
}

#' Get file information for an RData file
#'
#' This function retrieves information about an RData file corresponding to the specified table.
#'
#' @param table_name The name of the table.
#' @return A list containing file information such as size, permissions, and timestamps.
#'
#' @export
getLocalRdataFileInfo <- function(table_name) {
  table_name <- getLocalRdataFileName(table_name)
  file_info <- list()
  if (file.exists(table_name)) {
    file_info <- file.info(table_name)
  }
  return(file_info)
}

#' Check if an RData file exists locally
#'
#' This function checks if an RData file corresponding to the specified table exists locally.
#'
#' @param table_name The name of the table.
#' @return TRUE if the RData file exists locally, otherwise FALSE.
#'
#' @export
existsLocalRdataFile <- function(table_name) {
  file.exists(getLocalRdataFileName(table_name))
}

#' Read Content from a File into a Single String
#'
#' This function reads the content of a file specified by the file path and
#' concatenates all lines into a single string, with each line separated by a newline character.
#' This is useful for processing file data that needs to be utilized as a continuous string.
#'
#' @param file_path The path to the file whose content is to be read.
#' @return A single string containing all the lines from the file, concatenated together with newline
#' characters between each line.
#' @examples
#' \dontrun{
#'   content <- getContentFromFile("path/to/your/file.txt")
#'   print(content)
#' }
#' @export
getContentFromFile <- function(file_path) {
  # read the content of the file
  content <- readLines(file_path, warn = FALSE)
  # append all single line strings to one large string
  content <- paste0(content, collapse = '\n')
  return(content)
}
