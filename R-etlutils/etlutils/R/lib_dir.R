#' Generate directory names for module outputs.
#'
#' This function takes a module name and constructs directory names for both global and local module outputs.
#' It creates directory names for various result categories, including bundles, log, performance, and tables.
#' The function utilizes predefined global and local output folder names and appends a module-specific timestamp to them.
#' The resulting directory names are organized into a named list for easy access and reference.
#'
#' @param module_name The name of the module. If NULL then the previously initialized MODULE_DIRS will be returned.
#'
#' @return A named list containing directory names for global and local module outputs.
#'
#' @export
getModuleDirNames <- function(module_name) {
  if (is.null(module_name) || (exists("MODULE_DIRS") && module_name %in% MODULE_DIRS$module_name)) {
    return(MODULE_DIRS)
  }
  global_dir <- "outputGlobal"
  local_dir <- "outputLocal"

  local_results_dir_names  <- namedVectorByValue("bundles", "log", "performance", "tables", "reports")
  global_results_dir_names <- namedVectorByValue("performance", "requests", "tables", "reports")

  global_dir <- fhircrackr::pastep(global_dir, module_name)
  local_dir <- fhircrackr::pastep(local_dir, module_name)

  local_cache_dir_name <- "cache" # will be copied from last run to current run
  local_full_cache_dir_name <- paste0(local_dir, "/", local_cache_dir_name)
  namedListByParam(
    module_name,
    global_dir,
    local_dir,
    local_results_dir_names,
    global_results_dir_names,
    local_cache_dir_name,
    local_full_cache_dir_name
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
#' @param module_name name of the module
#' @param showWarnings logical; should the warnings on failure be shown?
#'
#' @export
createDIRS <- function(module_name, showWarnings = FALSE) {
  module_dirs <- getModuleDirNames(module_name)
  module_dirs$last_global_dir <- renameWithCreationTimeIfDirExists(module_dirs$global_dir, MAX_DIR_COUNT)
  module_dirs$last_local_dir <- renameWithCreationTimeIfDirExists(module_dirs$local_dir, MAX_DIR_COUNT)
  for (dir_name in module_dirs$global_results_dir_names) {
    dir.create(paste0(module_dirs$global_dir, "/", dir_name), recursive = TRUE, showWarnings = showWarnings)
  }
  for (dir_name in module_dirs$local_results_dir_names) {
    dir.create(paste0(module_dirs$local_dir, "/", dir_name), recursive = TRUE, showWarnings = showWarnings)
  }
  assign("MODULE_DIRS", module_dirs, envir = .GlobalEnv)

  # copy the cache from last run to current run
  cache_dir_name <- paste0(module_dirs$local_dir, "/", module_dirs$local_cache_dir_name)
  old_cache_dir_name <- paste0(module_dirs$last_local_dir, "/", module_dirs$local_cache_dir_name)
  if (!file.rename(old_cache_dir_name, cache_dir_name)) {
    dir.create(cache_dir_name, recursive = TRUE, showWarnings = showWarnings)
  }
  return(module_dirs)
}

#' Return the path to the log directory of the specific sub module
#'
#' @return A character of length one containing the path to the sub module specific log directory.
#'
#' @export
getLoggingDirectory <- function() {
  fhircrackr::pastep(MODULE_DIRS$local_dir, "log")
}

#' Return the combined paths of the log directory of the specific sub module and a new path
#'
#' @param path the sub directory or file name to add
#'
#' @return A character of length one containing the path to add to the sub module specific log directory.
#'
#' @export
combineLoggingPaths <- function(path) {
  fhircrackr::pastep(getLoggingDirectory(), path)
}

#' Return the path to the bundles directory of the specific sub module
#'
#' @return A character of length one containing the path to the sub module specific log directory.
#'
#' @export
getBundlesDirectory <- function() {
  fhircrackr::pastep(MODULE_DIRS$local_dir, "bundles")
}

#' Return the combined paths of the bundles directory of the specific sub module and a new path
#'
#' @param path the sub directory or file name to add
#'
#' @return A character of length one containing the path to add to the sub module specific bundles directory.
#'
#' @export
combineBundlePaths <- function(path) {
  fhircrackr::pastep(getBundlesDirectory(), path)
}

#' Save a Clock history in the *public* `performance` directory to which was created for the specific submodule.
#'
#' @param filename_without_extension A character vector of length one.
#' @param clock A `Clock` object. Defaults to the global environment `Clock` object `clock_`.
#'
#' @export
savePerformance <- function(filename_without_extension = "Performance_informations", clock = getClock()) {
  clock$write(filename_without_extension = fhircrackr::pastep(MODULE_DIRS$local_dir, "performance", filename_without_extension), hide_errors = FALSE)
  clock$write(filename_without_extension = fhircrackr::pastep(MODULE_DIRS$global_dir, "performance", filename_without_extension), hide_errors = TRUE)
}


####
# Read/Write RDS
####

writeFile <- function(object, full_file_name_with_path) {
  if (endsWith(full_file_name_with_path, ".rds")) {
    saveRDS(object, full_file_name_with_path)
  } else if (endsWith(full_file_name_with_path, ".Rdata")) {
    save(object, full_file_name_with_path)
  } else {
    stop("Can not write this file type with writeFile: ", full_file_name_with_path)
  }
  return(TRUE)
}

readFile <- function(full_file_name_with_path) {
  if (isSimpleNAorNULL(full_file_name_with_path) || !file.exists(full_file_name_with_path)) {
    return(NULL)
  }
  object <- if (endsWith(full_file_name_with_path, ".rds")) {
    # https://cloud.r-project.org/web/packages/data.table/vignettes/datatable-faq.html#reading-data.table-from-rds-or-rdata-file
    # 5.3 Reading data.table from RDS or RData file
    #
    # *.RDS and *.RData are file types which can store in-memory R objects
    # on disk efficiently. However, storing data.table into the binary file
    # loses its column over-allocation. This isn't a big deal – your
    # data.table will be copied in memory on the next by reference
    # operation and throw a warning. Therefore it is recommended to call
    # setalloccol() on each data.table loaded with readRDS() or load() calls.
    rds_content <- readRDS(full_file_name_with_path)
    if ('data.table' %in% class(rds_content)) {
      invisible(data.table::setalloccol(rds_content))
    }
    rds_content
  } else if (endsWith(full_file_name_with_path, ".rRata")) {
    load(fileName)
    #} else if (endsWith(full_file_name_with_path, ".???")) {
    # TODO
  } else {
    readFileAsString(full_file_name_with_path)
  }
  return(object)
}

####
# Read/Write Excel
####

#' Write an Excel file to a local or global tables directory
#'
#' Internal helper that determines the target directory based on `target` and writes
#' the provided tables as an Excel file using `writeExcelFile()`.
#'
#' @param target Either "local" or "global" to choose the base directory.
#' @param tables A `data.frame` or list that can be handled by `write.xlsx`.
#' @param filename_without_extension Optional file name without extension. If NA, the
#'   variable name of `tables` is used.
#' @param with_column_names Logical indicating whether column names should be written.
#' @param subdir subdirectory where the files will be written
writeExcelFileInternal <- function(target = c("local", "global"), tables, filename_without_extension, with_column_names = TRUE, subdir = "tables") {
  target <- match.arg(target)
  module_sub_dir <- fhircrackr::pastep(if (target == "local") MODULE_DIRS$local_dir else MODULE_DIRS$global_dir, subdir)
  if (!dir.exists(module_sub_dir)) {
    dir.create(module_sub_dir, recursive = TRUE)
  }
  file_name <- fhircrackr::pastep(module_sub_dir, filename_without_extension, ext = '.xlsx')
  writeExcelFile(tables, file_name, with_column_names)
}

#' Write an Excel file to the local tables directory if debugging is enabled
#'
#' This function conditionally writes an Excel file to the local tables directory.
#' Writing only occurs if `really_save` evaluates to TRUE. Optionally, the write
#' operation can be wrapped in a `runLevel3Line()` call to integrate with level-3
#' logging.
#'
#' @param tables A `data.frame` or list that can be handled by `writeExcelFile()`.
#' @param filename_without_extension Optional file name without extension. If NA, the
#'   variable name of `tables` is used.
#' @param runLevel3Message Optional message passed to `runLevel3Line()`. If NA, the
#'   file is written directly without level-3 logging.
#'
#' @return Invisibly returns NULL.
#'
#' @export
writeDebugExcelFile <- function(tables, filename_without_extension = NA, runLevel3Message = NA) {
  if (isDefinedAndTrue("LOG_TEMP_EXCEL_TABLES")) {
    if (is.na(filename_without_extension)) {
      filename_without_extension <- as.character(substitute(tables))
    }
    if (!is.na(runLevel3Message)) {
      runLevel3Line(runLevel3Message, {
        writeExcelFileInternal("local", tables, filename_without_extension)
      })
    } else {
      writeExcelFileInternal("local", tables, filename_without_extension)
    }
  }
}

#' Write an Excel file to the local tables directory
#'
#' @inheritParams writeExcelFileInternal
#'
#' @export
writeExcelFileLocal <- function(tables, filename_without_extension = NA, with_column_names = TRUE, subdir = "tables") {
  if (is.na(filename_without_extension)) {
    filename_without_extension <- as.character(substitute(tables))
  }
  writeExcelFileInternal("local", tables, filename_without_extension, with_column_names, subdir)
}

#' Write an Excel file to the global tables directory
#'
#' @inheritParams writeExcelFileInternal
#'
#' @export
writeExcelFileGlobal <- function(tables, filename_without_extension = NA, with_column_names = TRUE, subdir = "tables") {
  if (is.na(filename_without_extension)) {
    filename_without_extension <- as.character(substitute(tables))
  }
  writeExcelFileInternal("global", tables, filename_without_extension, with_column_names, subdir)
}

#' Build an HTML Table with Download Buttons
#'
#' Generates an interactive HTML table from a data frame, including optional caption and footnote,
#' with CSV and Excel download buttons.
#'
#' @param table A data frame or matrix to be converted into an HTML table.
#' @param filename_without_extension Character; optional filename prefix. If NA, the variable name of `table` is used.
#' @param caption Character; optional caption displayed above the table.
#' @param footnote Character; optional footnote displayed below the table. Defaults to an empty string.
#' @param colnames Character vector; optional column names for the table. Defaults to `colnames(table)`.
#'
#' @return An HTML widget containing the interactive table with download buttons.
#'
#' @details
#' This function wraps `DT::datatable()` to create interactive HTML tables with scrollable views,
#' top filters, and download buttons for CSV and Excel formats.
#'
#' @importFrom htmlwidgets createWidget prependContent saveWidget JS
#' @importFrom htmltools tags HTML tagList
#' @importFrom DT datatable
#' @importFrom jsonlite toJSON
#'
#' @export
buildHtmlTable <- function(table, caption = NA, footnote = "", colnames = NULL,
                           filename_without_extension = NA) {
  if (is.na(filename_without_extension)) {
    filename_without_extension <- deparse(substitute(table)) # get the table variable name
  }
  download_name <- filename_without_extension
  if (is.null(colnames)) {
    colnames <- colnames(table)
  }
  tbl <- DT::datatable(table,
    caption = caption,
    escape = FALSE,
    colnames = colnames,
    filter = "top",
    extensions = c("Buttons", "Scroller"),
    options = list(
      dom = "Bfrtip",
      buttons = list(list(
        extend = "collection",
        buttons = list(
          list(
            extend = "csv", filename = download_name,
            exportOptions = list(
              format = list(
                header = htmlwidgets::JS(
                  sprintf(
                    "function (data, columnIdx) { return %s[columnIdx]; }",
                    jsonlite::toJSON(c("row_id", colnames(table)))
                  )
                )
              )
            )
          ),
          list(extend = "excel", filename = download_name)
        ),
        text = "Download"
      )),
      autoWidth = TRUE,
      deferRender = TRUE,
      scroller = TRUE,
      scrollY = 400,
      scrollX = TRUE
    )
  )
  note <- htmltools::tags$p(
    style = "font-size: 1em; color: #000;",
    htmltools::HTML(paste(footnote, collapse = "<br>"))
  )
  html_table <- htmltools::tagList(
    tbl,
    note
  )
  return(html_table)
}

#' writes an HTML page from a list of HTML content to a local or global directory
#'
#' @param html_content_list a list of HTML content to be included in the page
#' @param output_location either "local" or "global" to specify the base directory
#' @param project_sub_dir optional subdirectory within the base directory; if NA, defaults to "reports"
#' within the respective base directory
#' @param pagename the name of the HTML page to be created (without extension and without path)
#'
#' @return None. The function saves the generated HTML page to the specified location.
#'
#' @details The function creates an HTML page by combining the provided HTML content and saves it to
#' the specified location. If the output location is "local", the page is saved in the "reports"
#' subdirectory of the local directory; if "global", it is saved in the "reports" subdirectory of
#' the global directory. The function ensures that the target directory exists and creates it if
#' necessary. The resulting HTML file is self-contained, and any accompanying files (like images or
#' stylesheets) are removed after saving since they are embedded within the HTML.
#'
#' @importFrom htmlwidgets createWidget prependContent saveWidget
#' @importFrom htmltools tags tagList
#' @importFrom fhircrackr pastep
#' @export
writeHtmlPage <- function(html_content_list, output_location = "local",
                          project_sub_dir = NA,
                          pagename = "local report") {
  if (!is.null(html_content_list) && output_location %in% c("local", "global")) {
    if (is.na(project_sub_dir)) {
      if (output_location == "local") {
        module_sub_dir <- fhircrackr::pastep(MODULE_DIRS$local_dir, "reports")
      } else if (output_location == "global") {
        module_sub_dir <- fhircrackr::pastep(MODULE_DIRS$global_dir, "reports")
      }
    } else {
      module_sub_dir <- fhircrackr::pastep(".", module_sub_dir)
    }
    if (!dir.exists(module_sub_dir)) {
      dir.create(module_sub_dir, recursive = TRUE)
    }

    page <- htmltools::tagList()

    for (i in seq_along(html_content_list)) {
      page <- htmltools::tagAppendChildren(page, html_content_list[[i]])

      if (i < length(html_content_list)) {
        page <- htmltools::tagAppendChildren(page, htmltools::tags$hr())
      }
    }

    widget <- htmlwidgets::createWidget(
      name = pagename,
      x = list(),
      package = "htmlwidgets"
    )

    widget <- htmlwidgets::prependContent(widget, page)
    output_html <- fhircrackr::pastep(module_sub_dir, pagename, ext = paste0("_", Sys.Date(), ".html"))
    htmlwidgets::saveWidget(
      widget = widget,
      file = output_html,
      selfcontained = TRUE
    )
    # remove the accompanying _files directory if it exists (because everything is self-contained in the html)
    files_dir <- sub("\\.html$", "_files", output_html)
    if (dir.exists(files_dir)) {
      unlink(files_dir, recursive = TRUE, force = TRUE)
    }
  } else {
    warning(paste0(
      "The html content creation was not succuessful or the output_location '",
      output_location, "' is invalid. No file was written."
    ))
  }
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
