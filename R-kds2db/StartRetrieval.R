##########################################################################
# free memory
##########################################################################
rm(list = ls())

library(etlutils)
library(kds2db)

retrieve()

#'
#' Loads all tables from subdirectory 'tables' of the last directory
#' in the given tale_path.
#'
#'
loadTables <- function(table_path, name_pattern = NA) {
  table_names <- sort(list.files(path = table_path))
  table_path <- paste0(table_path, table_names[length(table_names)], '/tables/')
  table_names <- list.files(path = table_path, pattern = '.\\.RData$')
  if (!is.na(name_pattern)) {
    table_names <- table_names[grep(name_pattern, table_names, ignore.case = TRUE)]
  }
  tables <- list()
  for (table_name in table_names) {
    full_table_path <- paste0(table_path, table_name)
    table <- try(readRDS(full_table_path), silent = TRUE)
    if (data.table::is.data.table(table)) {
      tables <- append(tables, list(table))
      names(tables)[length(tables)] <- gsub('\\.RData$', '', table_name)
    }
  }
  return(tables)
}

tables <- loadTables('./outputLocal/')
