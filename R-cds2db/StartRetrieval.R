####################################################################################
# Preferences: The current working directory must be the main project directory.   #
#              In interactive setting this is the parent directory of the R-cds2db #
#              directory.                                                          #
####################################################################################

# chance the working directory to the main directory
if (grepl('/cds2db$', getwd())) setwd("../..")
if (grepl('/R-cds2db$', getwd())) setwd("../")

# free memory
rm(list = ls())

library(etlutils)
library(cds2db)


# Set path for Debug config toml files
DEBUG_PATHS_TO_CONFIG_TOMLS <- c("./R-cds2db/debug_config_toml/debug_cds2db_config_1.toml"#,
                                 #"./debug_config_toml/debug_cds2db_config_2.toml",
                                 #"./debug_config_toml/debug_cds2db_config_3.toml"
                                 )

if (exists("DEBUG_PATHS_TO_CONFIG_TOMLS") && length(DEBUG_PATHS_TO_CONFIG_TOMLS) > 0) {
  for (debug_config_toml in DEBUG_PATHS_TO_CONFIG_TOMLS) {
    cds2db::retrieve(debug_config_toml)
  }
} else {
  cds2db::retrieve()
}

#' #'
#' #' Loads all tables from subdirectory 'tables' of the last directory
#' #' in the given tale_path.
#' #'
#' #'
#' loadTables <- function(table_path, name_pattern = NA) {
#'   table_names <- sort(list.files(path = table_path))
#'   table_path <- paste0(table_path, table_names[length(table_names)], '/tables/')
#'   table_names <- list.files(path = table_path, pattern = '.\\.RData$')
#'   if (!is.na(name_pattern)) {
#'     table_names <- table_names[grep(name_pattern, table_names, ignore.case = TRUE)]
#'   }
#'   tables <- list()
#'   for (table_name in table_names) {
#'     full_table_path <- paste0(table_path, table_name)
#'     table <- try(readRDS(full_table_path), silent = TRUE)
#'     if (data.table::is.data.table(table)) {
#'       tables <- append(tables, list(table))
#'       names(tables)[length(tables)] <- gsub('\\.RData$', '', table_name)
#'     }
#'   }
#'   return(tables)
#' }
#'
#' tables <- loadTables('./outputLocal/')
