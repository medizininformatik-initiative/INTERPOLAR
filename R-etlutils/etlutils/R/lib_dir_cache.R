# Environment for registered cache configurations
.cache_env <- new.env(parent = emptyenv())

getCacheId <- function(process_name, module_name) {
  paste0(process_name, module_name)
}

#' Register cache configuration
#'
#' Registers a cache configuration consisting of a file base name and the
#' corresponding file pattern.
#'
#' @param files_base_name Base filename of the cache files without numeric suffix.
#' @param files_extension File name extension of he cache files.
#' @param process_name ID string to store the cache configuration. Defaults to
#' the current process returned by `getProcess()`.
#' @param module_name name of the registering module as part of the cache ID
#'
#' @return the created cache config.
#'
#' @export
registerCache <- function(files_base_name, files_extension = "rds", process_name = getProcess(), module_name = getModuleName()) {
  pattern <- paste0("^", files_base_name, "_\\d+\\.", files_extension, "$")
  cache_dir <- getModuleDirNames(module_name)$local_full_cache_dir_name
  cache_config <- namedListByParam(
    process_name,
    module_name,
    files_base_name,
    files_extension,
    pattern,
    cache_dir
  )
  .cache_env[[getCacheId(process_name, module_name)]] <- cache_config
  return(cache_config)
}

#' Get cache configuration
#'
#' Returns the registered cache configuration for the given prefix.
#'
#' @inheritParams registerCache
#'
#' @return A list containing `module_name`, `base_file_name` and `pattern`.
#'
getCacheConfig <- function(process_name = getProcess(), module_name = getModuleName()) {
  return(.cache_env[[getCacheId(process_name, module_name)]])
}

#' Check if cache configuration exists
#'
#' Checks whether a cache configuration is registered for the given prefix.
#'
#' @inheritParams registerCache
#'
#' @return `TRUE` if the cache configuration exists, otherwise `FALSE`.
#'
#' @export
hasCacheConfig <- function(process_name = getProcess(), module_name = getModuleName()) {
  return(exists(getCacheId(process_name, module_name), envir = .cache_env, inherits = FALSE))
}

#' List cache files
#'
#' @inheritParams registerCache
#' @param with_dir_names if TRUE (default) then the file names will returned with
#' the directory names
#'
#' @return A character vector containing the matching file names.
#'
#' @export
listCacheFiles <- function(process_name = getProcess(), module_name = getModuleName(), with_dir_names = TRUE) {
  cache_config <- getCacheConfig(process_name, module_name)
  files <- list.files(cache_config$cache_dir, pattern = cache_config$pattern, full.names = with_dir_names)
  return(files)
}

#' Get next cache file
#'
#' Returns the first cache file matching the registered cache file pattern or
#' `NULL` if no such file exists.
#'
#' @inheritParams listCacheFiles
#'
#' @return A character string containing the file name of the first cache file
#'   or `NULL` if no matching file is found.
#'
#' @export
getNextCacheFile <- function(process_name = getProcess(), module_name = getModuleName(),  with_dir_names = TRUE) {
  files <- listCacheFiles(process_name, module_name, with_dir_names)
  if (!length(files)) {
    return(NULL)
  }
  files <- sort(files)
  return(files[1])
}

#' Check if a cache file exists
#'
#' Checks whether a next cache file matching the registered cache file pattern
#' is available.
#'
#' @inheritParams registerCache
#'
#' @return `TRUE` if a matching cache file exists, otherwise `FALSE`.
#'
#' @export
hasNextCacheFile <- function(process_name = getProcess(), module_name = getModuleName()) {
  return(!is.null(getNextCacheFile(process_name, module_name)))
}

#' Get number of cache files
#'
#' Returns the number of cache files matching the registered cache file
#' pattern.
#'
#' @inheritParams listCacheFiles
#'
#' @return Integer number of matching cache files.
#'
#' @export
getCacheFilesCount <- function(process_name = getProcess(), module_name = getModuleName()) {
  return(length(listCacheFiles(process_name, module_name)))
}

#' Read next cache file
#'
#' Reads and returns the content of the cache file returned by
#' `getNextCacheFile()`. If no such file exists, `NULL` is returned.
#'
#' @inheritParams getNextCacheFile
#'
#' @return The R object stored in the cache file or `NULL` if no matching file
#'   exists.
#'
#' @export
readNextCacheFile <- function(process_name = getProcess(), module_name = getModuleName()) {
  return(readFile(getNextCacheFile(process_name, module_name)))
}

#' Write cache files
#'
#' Deletes existing cache files matching the registered cache file pattern and
#' writes the provided object or objects to separate cache files. If `object` is
#' not a list, it is wrapped into a list. The numeric suffix is zero-padded to
#' the width required by the number of written files.
#'
#' @param object An object or a list of objects to be written as cache files.
#' @inheritParams registerCache
#'
#' @return A character vector containing the written file names without
#'   extension.
#'
#' @export
writeCacheFiles <- function(object, process_name = getProcess(), module_name = getModuleName()) {
  cache_config <- getCacheConfig(process_name, module_name)
  files <- listCacheFiles(process_name, module_name)
  if (length(files)) {
    unlink(files, force = TRUE)
  }
  objects <- if (typeof(object) == "list" && !inherits(object, "data.frame")) {
    object
  } else {
    list(object)
  }
  n_files <- length(objects)
  if (!n_files) {
    return(character(0))
  }
  index_width <- nchar(as.character(n_files))
  filenames <- character(n_files)
  for (i in seq_len(n_files)) {
    filename <- sprintf(paste0(cache_config$cache_dir, "/%s_%0", index_width, "d.", cache_config$files_extension), cache_config$files_base_name, i)
    writeFile(objects[[i]], filename)
    filenames[i] <- filename
  }
  return(filenames)
}


#' Delete next cache file
#'
#' Deletes the cache file returned by `getNextCacheFile()`. If no such file
#' exists, nothing is done and `NULL` is returned.
#'
#' @inheritParams registerCache
#'
#' @return The name of the deleted file or `NULL` if no matching file exists.
#'
#' @export
deleteNextCacheFile <- function(process_name = etlutils::getProcess(), module_name = getModuleName()) {
  filename <- getNextCacheFile(process_name, module_name)
  if (is.null(filename)) {
    return(NULL)
  }
  unlink(filename, force = TRUE)
  return(filename)
}


#' Delete all cache files
#'
#' Deletes all cache files matching the registered cache file pattern.
#'
#' @inheritParams registerCache
#'
#' @return `TRUE` if any files were deleted, otherwise `FALSE`.
#'
#' @export
deleteAllCacheFiles <- function(process_name = etlutils::getProcess(), module_name = getModuleName()) {
  files <- listCacheFiles(process_name, module_name)
  if (!length(files)) {
    return(FALSE)
  }
  unlink(files, force = TRUE)
  return(TRUE)
}
