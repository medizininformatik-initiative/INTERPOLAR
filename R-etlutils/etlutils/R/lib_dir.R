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
getProjectDirNames <- function(project_name, project_time_stamp = MODULE_TIME_STAMP) {

  global_dir <- "outputGlobal"
  local_dir <- "outputLocal"

  local_results_directories_names  <- c("bundles", "log", "performance", "tables")
  global_results_directories_names <- c("performance", "requests")

  global_dir <- fhircrackr::pastep(global_dir, project_name)
  local_dir <- fhircrackr::pastep(local_dir, project_name)

  global_dir <- paste0(global_dir, MODULE_TIME_STAMP)
  local_dir <- paste0(local_dir, MODULE_TIME_STAMP)

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
    dirCreationTime <- as.POSIXctWithTimezone(dirCreationTime)  # Convert to POSIXct
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
createDIRS <- function(project_name, showWarnings = FALSE) {
  module_dirs <- getProjectDirNames(project_name)
  module_dirs$last_global_dir <- renameWithCreationTimeIfDirExists(module_dirs$global_dir, MAX_DIR_COUNT)
  module_dirs$last_al_dir <- renameWithCreationTimeIfDirExists(module_dirs$local_dir, MAX_DIR_COUNT)
  for (rd in module_dirs$global_results_directories_names) {
    dir.create(paste0(module_dirs$global_dir, "/", rd), recursive = TRUE, showWarnings = showWarnings)
  }
  for (rd in module_dirs$local_results_directories_names) {
    dir.create(paste0(module_dirs$local_dir, "/", rd), recursive = TRUE, showWarnings = showWarnings)
  }
  assign("MODULE_DIRS", module_dirs, envir = .GlobalEnv)
}

#' Return the path to the log directory of the specific sub project
#'
#' @return A character of length one containing the path to the sub project specific log directory.
#'
#' @export
getLoggingDirectory <- function() {
  fhircrackr::pastep(MODULE_DIRS$local_dir, "log")
}

#' Return the combined paths of the log directory of the specific sub project and a new path
#'
#' @param path the sub directory or file name to add
#'
#' @return A character of length one containing the path to add to the sub project specific log directory.
#'
#' @export
combineLoggingPaths <- function(path) {
  fhircrackr::pastep(getLoggingDirectory(), path)
}

#' Return the path to the bundles directory of the specific sub project
#'
#' @return A character of length one containing the path to the sub project specific log directory.
#'
#' @export
getBundlesDirectory <- function() {
  fhircrackr::pastep(MODULE_DIRS$local_dir, "bundles")
}

#' Return the combined paths of the bundles directory of the specific sub project and a new path
#'
#' @param path the sub directory or file name to add
#'
#' @return A character of length one containing the path to add to the sub project specific bundles directory.
#'
#' @export
combineBundlePaths <- function(path) {
  fhircrackr::pastep(getBundlesDirectory(), path)
}

#' Save a Clock history in the *public* `performance` directory to which was created for the specific subproject.
#'
#' @param filename_without_extension A character vector of length one.
#' @param clock A `Clock` object. Defaults to the global environment `Clock` object `clock_`.
#'
#' @export
savePerformance <- function(filename_without_extension = "Performance_informations", clock = getClock()) {
  clock$write(filename_without_extension = fhircrackr::pastep(MODULE_DIRS$local_dir, "performance", filename_without_extension), hide_errors = FALSE)
  clock$write(filename_without_extension = fhircrackr::pastep(MODULE_DIRS$global_dir, "performance", filename_without_extension), hide_errors = TRUE)
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
    project_sub_dir <- fhircrackr::pastep(MODULE_DIRS$local_dir, "tables")
    #saveRDS(object = object, file = fhircrackr::pastep(MODULE_DIRS$local_dir, "tables", filename_without_extension, ext = '.RData'))
  } else {
    project_sub_dir <- fhircrackr::pastep('.', project_sub_dir)
  }
  saveRDS(object = object, file = fhircrackr::pastep(project_sub_dir, filename_without_extension, ext = '.RData'))
}

#' Read the entire content of a file as a string
#'
#' This function reads the entire content of a given file and returns it as a single string,
#' ensuring that the final newline character is preserved if it exists.
#'
#' @param file_path A string representing the path to the file.
#' @param normalize_newlines A boolean indicating whether to normalize newline characters
#' from "\\r\\n" to "\\n". Default is TRUE.
#'
#' @return A single string containing the entire content of the file, including the final
#' newline character if it was present.
#'
#' @examples
#' \dontrun{
#'   file_content <- readFileAsString("path/to/your/file.txt")
#'   print(file_content)
#' }
#'
#' @export
readFileAsString <- function(file_path, normalize_newlines = TRUE) {
  file_content <- readChar(file_path, file.info(file_path)$size, useBytes = TRUE)
  if (normalize_newlines) {
    file_content <- gsub("\r\n", "\n", file_content, fixed = TRUE)
  }
  return(file_content)
}

#' Get All Files Matching a Pattern
#'
#' This function retrieves all files matching a specified pattern from a flexible set
#' of inputs, which can be a string (directory or file), a vector, or a list of mixed
#' directory and file paths. It removes duplicates from the results.
#'
#' @param paths A string, vector, or list containing file paths and/or directory paths.
#' @param pattern A regular expression pattern to filter the files (e.g., "*.xlsx" or "\\.csv$").
#' @param recursive Logical, indicating whether to search directories recursively. Default is `FALSE`.
#'
#' @return A character vector containing all unique file paths that match the pattern.
#'
getFilesByPattern <- function(paths, pattern, recursive = FALSE) {
  # Ensure `paths` is a character vector
  paths <- unlist(paths)

  # Initialize an empty vector to store matching files
  matching_files <- c()

  for (path in paths) {
    if (file.exists(path)) {
      if (file.info(path)$isdir) {
        # If it's a directory, list files matching the pattern
        files <- list.files(path, pattern = pattern, full.names = TRUE, recursive = recursive)
        matching_files <- c(matching_files, files)
      } else {
        # If it's a file, check if it matches the pattern
        if (grepl(pattern, path)) {
          matching_files <- c(matching_files, path)
        }
      }
    }
  }

  # Remove duplicates and return the result
  return(unique(matching_files))
}

#' Get Full List of Excel Files
#'
#' This function retrieves a full list of `.xlsx` files from a mix of directories and file paths.
#' It identifies whether each input is a directory or file, and applies a filter to only include
#' files matching the `.xlsx` extension. Duplicate file paths are removed from the result.
#'
#' @param filesOrDirs A character vector or list containing file paths and/or directory paths.
#' @param recursive Logical, indicating whether to search directories recursively. Default is `FALSE`.
#'
#' @return A character vector containing unique file paths to `.xlsx` files.
#'
#' @export
getFullExcelFilesList <- function(filesOrDirs, recursive = FALSE) {
  getFilesByPattern(filesOrDirs, ".*\\.xlsx$", recursive = recursive)
}

#' Retrieve files matching a given prefix in specified directories
#'
#' Searches for files with a given prefix within one or more directories. Optionally filters by file extension.
#' If `extension` is `NA` or an empty string, the function retrieves all files matching the prefix
#' without filtering by extension.
#'
#' This function internally calls `getFilesByPattern` for flexible pattern-based searching.
#'
#' @param prefix A string specifying the prefix that the files must start with.
#' @param directories A character vector specifying the directories to search in.
#' @param extension A string specifying the file extension (e.g., `"xlsx"`, `"csv"`). Can be `NA` or `""`
#'   to disable extension filtering. If provided with a leading dot (e.g., `".csv"`), it will be removed.
#' @param recursive Logical, indicating whether to search directories recursively. Default is `FALSE`.
#'
#' @return A character vector containing the full paths of the matching files.
#' @export
getFilesByPrefix <- function(prefix, directories, extension = NA, recursive = FALSE) {
  # Build the pattern based on prefix and optional extension
  if (is.na(extension) || extension == "") {
    pattern <- paste0("^", prefix)
  } else {
    extension <- sub("^\\.", "", extension)  # Remove leading dot if present
    pattern <- paste0("^", prefix, ".*\\.", extension, "$")
  }

  # Use getFilesByPattern to retrieve matching files
  return(getFilesByPattern(paths = directories, pattern = pattern, recursive = recursive))
}

#' Retrieve all Excel files with a given prefix from directories and subdirectories
#'
#' Searches for `.xlsx` files that start with a specified prefix in one or more directories,
#' including all subdirectories.
#'
#' @param prefix A string specifying the prefix that the Excel files must start with.
#' @param directories A character vector specifying the directories to search in.
#'
#' @return A character vector containing the full paths of the matching `.xlsx` files.
#' @export
getExcelFilesByPrefixInDirsAndSubdirs <- function(prefix, directories) {
  return(getFilesByPrefix(prefix = prefix, directories = directories, extension = "xlsx", recursive = TRUE))
}

#' Read an Object as RDS-File from the *private* `tables` directory to which was created for the specific subproject.
#'
#' a <- ReadRData('a')
#'
#' @param filename_without_extension If the default NA is not changed then the name is the name of the table variable.
#' @param load_from_last_run fehlende Beschreibung
#'
#' @return the object
#'
#' @export
readRData <- function(filename_without_extension, load_from_last_run = FALSE) {
  if (load_from_last_run) dir <- MODULE_DIRS$local_dir else MODULE_DIRS$last_local_dir
  project_sub_dir <- fhircrackr::pastep(dir, "tables")
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

#' #' Get the filename for an RData file corresponding to a table
#' #'
#' #' This function constructs the filename for an RData file corresponding to the specified table.
#' #'
#' #' @param table_name The name of the table.
#' #' @return A character string representing the filename for the RData file.
#' #'
#' #' @export
#' getLocalRdataFileName <- function(table_name) {
#'   fhircrackr::pastep(MODULE_DIRS$local_dir, "tables", table_name, ext = '.RData')
#' }
#'
#' #' Get file information for an RData file
#' #'
#' #' This function retrieves information about an RData file corresponding to the specified table.
#' #'
#' #' @param table_name The name of the table.
#' #' @return A list containing file information such as size, permissions, and timestamps.
#' #'
#' #' @export
#' getLocalRdataFileInfo <- function(table_name) {
#'   table_name <- getLocalRdataFileName(table_name)
#'   file_info <- list()
#'   if (file.exists(table_name)) {
#'     file_info <- file.info(table_name)
#'   }
#'   return(file_info)
#' }
#'
#' #' Check if an RData file exists locally
#' #'
#' #' This function checks if an RData file corresponding to the specified table exists locally.
#' #'
#' #' @param table_name The name of the table.
#' #' @return TRUE if the RData file exists locally, otherwise FALSE.
#' #'
#' #' @export
#' existsLocalRdataFile <- function(table_name) {
#'   file.exists(getLocalRdataFileName(table_name))
#' }
#'
#' #' Read Content from a File into a Single String
#' #'
#' #' This function reads the entire content of a given file and returns it as a single string,
#' #' ensuring that the final newline character is preserved if it exists.
#' #'
#' #' Note: of the original file ends with a new line character then this caracter is missing in
#' #' the result.
#' #'
#' #' @param file_path A string representing the path to the file.
#' #'
#' #' @return A single string containing the entire content of the file, including the final
#' #' newline character if it was present.
#' #'
#' #' @examples
#' #' \dontrun{
#' #'   file_content <- readFileLinesAsString("path/to/your/file.txt")
#' #'   print(file_content)
#' #' }
#' #'
#' #' @export
#' readFileLinesAsString <- function(file_path) {
#'   file_content <- readLines(file_path, warn = FALSE)
#'   full_content <- paste(file_content, collapse = "\n")
#'   return(full_content)
#' }
