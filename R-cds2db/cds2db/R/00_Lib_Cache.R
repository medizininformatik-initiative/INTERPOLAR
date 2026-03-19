# Environment for registered cache configurations
.cache_env <- new.env(parent = emptyenv())


#' Register cache configuration
#'
#' Registers a cache configuration consisting of a file base name and the
#' corresponding file pattern.
#'
#' @param files_base_name Base filename of the cache files without numeric suffix.
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#' the current process returned by `etlutils::getProcess()`.
#'
#' @return None.
#'
#' @export
registerCache <- function(files_base_name, var_prefix = etlutils::getProcess()) {
  .cache_env[[var_prefix]] <- list(
    module_name = getModuleName(),
    base = files_base_name,
    pattern = paste0("^", files_base_name, "_\\d+\\.rds$")
  )
  return(NULL)
}

#' Get cache configuration
#'
#' Returns the registered cache configuration for the given prefix.
#'
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#' the current process returned by `etlutils::getProcess()`.
#'
#' @return A list containing `base` and `pattern`.
#'
#' @export
getCacheConfig <- function(var_prefix = etlutils::getProcess()) {
  return(.cache_env[[var_prefix]])
}

#' Check if cache configuration exists
#'
#' Checks whether a cache configuration is registered for the given prefix.
#'
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#' the current process returned by `etlutils::getProcess()`.
#'
#' @return `TRUE` if the cache configuration exists, otherwise `FALSE`.
#'
#' @export
hasCacheConfig <- function(var_prefix = etlutils::getProcess()) {
  return(exists(var_prefix, envir = .cache_env, inherits = FALSE))
}

#' Check if a cache file exists
#'
#' Checks whether a next cache file matching the registered cache file pattern
#' is available.
#'
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#' the current process returned by `etlutils::getProcess()`.
#'
#' @return `TRUE` if a matching cache file exists, otherwise `FALSE`.
#'
#' @export
hasNextCacheFile <- function(var_prefix = etlutils::getProcess()) {
  return(!is.null(getNextCacheFile(var_prefix)))
}

#' Get number of cache files
#'
#' Returns the number of cache files matching the registered cache file
#' pattern.
#'
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#'   the current process returned by `etlutils::getProcess()`.
#'
#' @return Integer number of matching cache files.
#'
#' @export
getCacheFilesCount <- function(var_prefix = etlutils::getProcess()) {
  cache_config <- getCacheConfig(var_prefix)
  files <- etlutils::listCacheFiles(pattern = cache_config$pattern)
  return(length(files))
}

#' Get next cache file
#'
#' Returns the first cache file matching the registered cache file pattern or
#' `NULL` if no such file exists.
#'
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#' the current process returned by `etlutils::getProcess()`.
#'
#' @return A character string containing the file name of the first cache file
#'   or `NULL` if no matching file is found.
#'
#' @export
getNextCacheFile <- function(var_prefix = etlutils::getProcess()) {
  cache_config <- getCacheConfig(var_prefix)
  files <- etlutils::listCacheFiles(pattern = cache_config$pattern)
  if (!length(files)) {
    return(NULL)
  }
  files <- sort(files)
  return(files[1])
}

#' Read next cache file
#'
#' Reads and returns the content of the cache file returned by
#' `getNextCacheFile()`. If no such file exists, `NULL` is returned.
#'
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#' the current process returned by `etlutils::getProcess()`.
#'
#' @return The R object stored in the cache file or `NULL` if no matching file
#'   exists.
#'
#' @export
readNextCacheFile <- function(var_prefix = etlutils::getProcess()) {
  filename <- getNextCacheFile(var_prefix)
  if (is.null(filename)) {
    return(NULL)
  }
  filename <- sub("\\.rds$", "", filename)
  return(etlutils::readRDSFileCache(filename_without_extension = filename))
}

#' Write cache files
#'
#' Deletes existing cache files matching the registered cache file pattern and
#' writes the provided object or objects to separate cache files. If `object` is
#' not a list, it is wrapped into a list. The numeric suffix is zero-padded to
#' the width required by the number of written files.
#'
#' @param object An object or a list of objects to be written as cache files.
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#' the current process returned by `etlutils::getProcess()`.
#'
#' @return A character vector containing the written file names without
#'   extension.
#'
#' @export
writeCacheFiles <- function(object, var_prefix = etlutils::getProcess()) {
  cache_config <- getCacheConfig(var_prefix)
  files <- etlutils::listCacheFiles(pattern = cache_config$pattern)

  if (length(files)) {
    unlink(file.path(MODULE_DIRS$local_dir, files), force = TRUE)
  }

  objects <- if (is.list(object)) object else list(object)
  n_files <- length(objects)

  if (!n_files) {
    return(character(0))
  }

  index_width <- nchar(as.character(n_files))
  filenames <- character(n_files)

  for (i in seq_len(n_files)) {
    filename <- sprintf(paste0("%s_%0", index_width, "d"), cache_config$base, i)
    etlutils::writeRDSFileCache(object = objects[[i]], filename_without_extension = filename)
    filenames[i] <- filename
  }

  return(filenames)
}


#' Delete next cache file
#'
#' Deletes the cache file returned by `getNextCacheFile()`. If no such file
#' exists, nothing is done and `NULL` is returned.
#'
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#' the current process returned by `etlutils::getProcess()`.
#'
#' @return The name of the deleted file or `NULL` if no matching file exists.
#'
#' @export
deleteNextCacheFile <- function(var_prefix = etlutils::getProcess()) {
  filename <- getNextCacheFile(var_prefix)

  if (is.null(filename)) {
    return(NULL)
  }

  unlink(file.path(MODULE_DIRS$local_dir, filename), force = TRUE)
  return(filename)
}


#' Delete all cache files
#'
#' Deletes all cache files matching the registered cache file pattern.
#'
#' @param var_prefix Prefix used to store the cache configuration. Defaults to
#' the current process returned by `etlutils::getProcess()`.
#'
#' @return `TRUE` if any files were deleted, otherwise `FALSE`.
#'
#' @export
deleteAllCacheFiles <- function(var_prefix = etlutils::getProcess()) {
  cache_config <- getCacheConfig(var_prefix)
  files <- etlutils::listCacheFiles(pattern = cache_config$pattern)

  if (!length(files)) {
    return(FALSE)
  }

  unlink(file.path(MODULE_DIRS$local_dir, files), force = TRUE)
  return(TRUE)
}
