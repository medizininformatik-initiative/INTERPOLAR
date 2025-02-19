# Environment for saving everything but the connections
.lib_db_env <- new.env()
# Environment for saving the connections
.lib_db_connection_env <- new.env()

dbInitModuleContext <- function(module_name, path_to_db_toml, log) {
  constants <- initConstants(path_to_db_toml, envir = .lib_db_env)
  module_name_upper <- toupper(module_name)
  dbSetContext(
    module_name = module_name,
    dbname = constants[["DB_NAME"]],
    host = constants[["DB_HOST"]],
    port = constants[["DB_PORT"]],
    user = constants[[paste0("DB_", module_name_upper, "_USER")]],
    password = constants[[paste0("DB_", module_name_upper, "_PASSWORD")]],
    schema_in = constants[[paste0("DB_", module_name_upper, "_SCHEMA_IN")]],
    schema_out = constants[[paste0("DB_", module_name_upper, "_SCHEMA_OUT")]],
    log = log)
}

#' Set the Database Connection Context
#'
#' This function initializes the database connection context by storing connection
#' details in a private environment. These details are used by other functions
#' within the package to interact with the database.
#'
#' @param module_name A character string representing the name of the module using the connection.
#' @param dbname The name of the database to connect to.
#' @param host The hostname or IP address of the database server.
#' @param port The port number used for the database connection.
#' @param user The username for authentication with the database.
#' @param password The password for authentication with the database.
#' @param schema_in The input schema for reading data from the database.
#' @param schema_out The output schema for writing data to the database.
#' @param log Logical. If \code{TRUE}, database operations will be logged.
#'
#' @return This function does not return a value. It initializes the connection environment.
#'
#' @examples
#' dbSetContext(
#'   module_name = "DataProcessor",
#'   dbname = "my_database",
#'   host = "localhost",
#'   port = 5432,
#'   user = "admin",
#'   password = "secret",
#'   schema_in = "public",
#'   schema_out = "analytics",
#'   log = TRUE
#' )
#'
#' @export
dbSetContext <- function(module_name, dbname, host, port, user, password, schema_in, schema_out, log) {
  .lib_db_env[["MODULE_NAME"]] <- module_name
  .lib_db_env[["DB_NAME"]] <- dbname
  .lib_db_env[["DB_HOST"]] <- host
  .lib_db_env[["DB_PORT"]] <- port
  .lib_db_env[["DB_USER"]] <- user
  .lib_db_env[["DB_PASSWORD"]] <- password
  .lib_db_env[["DB_SCHEMA_IN"]] <- schema_in
  .lib_db_env[["DB_SCHEMA_OUT"]] <- schema_out
  .lib_db_env[["DB_LOG"]] <- log %in% TRUE
}

#' Check if Database Logging is Enabled
#'
#' This function checks whether logging is enabled for database operations.
#' The logging setting is defined during the initialization of the database context.
#'
#' @return A logical value. \code{TRUE} if logging is enabled, \code{FALSE} otherwise.
#'
#' @examples
#' dbSetContext(module_name = "DataProcessor", dbname = "my_database", host = "localhost",
#'              port = 5432, user = "admin", password = "secret",
#'              schema_in = "public", schema_out = "analytics", log = TRUE)
#' dbIsLog()
#'
#' @export
dbIsLog <- function() .lib_db_env[["DB_LOG"]]

#' Get the Module Name from the Database Context
#'
#' This function retrieves the name of the module that was set during
#' the initialization of the database connection context.
#'
#' @return A character string representing the module name.
#'
#' @examples
#' dbSetContext(module_name = "DataProcessor", dbname = "my_database", host = "localhost",
#'              port = 5432, user = "admin", password = "secret",
#'              schema_in = "public", schema_out = "analytics", log = TRUE)
#' dbGetModuleName()
#'
#' @export
dbGetModuleName <- function() .lib_db_env[["MODULE_NAME"]]

#' Log Messages to the Console if Logging is Enabled
#'
#' This function logs messages to the console if logging is enabled.
#' If no messages are provided, it returns the current logging status.
#' Logging is controlled by the "DB_LOG" variable in the environment `.lib_db_env`.
#'
#' If the message does not end with a newline character (`\n`), one is added automatically
#' by using the `fill` parameter of the `cat()` function.
#'
#' @param ... Character strings to be logged. These strings are concatenated
#'        and printed if logging is enabled. If no arguments are provided,
#'        the function only returns the logging status.
#'
#' @return Logical. \code{TRUE} if logging is enabled, \code{FALSE} otherwise.
#'
#' @examples
#' dbSetContext(module_name = "DataProcessor", dbname = "my_database", host = "localhost",
#'              port = 5432, user = "admin", password = "secret",
#'              schema_in = "public", schema_out = "analytics", log = TRUE)
#' dbLog("Logging enabled.")          # Logs the message
#' dbLog("Logging enabled again.\n")  # Logs the message but adds no "\n" at the end
#' dbLog()                            # Returns TRUE (since logging is enabled)
#'
#' @export
dbLog <- function(...) {
  log <- isDefinedAndTrue("DB_LOG", envir = .lib_db_env)
  if (length(list(...)) > 0 && log) {
    message <- paste0(...)
    cat(message, fill = !endsWith(message, "\n"))
  }
  return(log)
}

#' Get a PostgreSQL Database Connection
#'
#' This function retrieves a PostgreSQL database connection from the environment
#' or establishes a new one if no valid connection exists. The connection is stored
#' in a private environment for reuse.
#'
#' If the connection does not exist or is invalid, a new connection is created
#' using the settings defined in the environment `.lib_db_env`.
#'
#' The function distinguishes between read-only and write connections based on the
#' `readonly` parameter. It automatically adjusts the memory allocation for improved performance.
#'
#' @param readonly Logical. If \code{TRUE}, a read-only connection is requested.
#'        Otherwise, a write-enabled connection is established.
#'
#' @return A valid PostgreSQL database connection object.
#'
dbGetConnection <- function(readonly) {
  schema_name <- if (readonly) .lib_db_env[["DB_SCHEMA_OUT"]] else .lib_db_env[["DB_SCHEMA_IN"]]
  db_connection <- .lib_db_connection_env[[schema_name]]

  if (is.null(db_connection) || !DBI::dbIsValid(db_connection)) {
    dbLog(
      "Attempting to connect with: \n",
      "dbname=", .lib_db_env[["DB_NAME"]], "\n",
      "host=", .lib_db_env[["DB_HOST"]], "\n",
      "port=", .lib_db_env[["DB_PORT"]], "\n",
      "user=", .lib_db_env[["DB_USER"]], "\n",
      "schema=", schema_name, "\n"
    )

    db_connection <- DBI::dbConnect(
      RPostgres::Postgres(),
      dbname = .lib_db_env[["DB_NAME"]],
      host = .lib_db_env[["DB_HOST"]],
      port = .lib_db_env[["DB_PORT"]],
      user = .lib_db_env[["DB_USER"]],
      password = .lib_db_env[["DB_PASSWORD"]],
      options = paste0("-c search_path=", schema_name),
      timezone = "Europe/Berlin"
    )

    # Increase memory allocation
    DBI::dbExecute(db_connection, "set work_mem to '32MB';")

    # Store the connection in the environment
    .lib_db_connection_env[[schema_name]] <- db_connection
  }

  return(db_connection)
}

#' Get Database Read Connection
#'
#' This function retrieves a read-only database connection for the default schema.
#' It is a wrapper around the `dbGetConnection` function.
#'
#' @return A database connection object for the default read schema.
#'
dbGetReadConnection <- function() dbGetConnection(readonly = TRUE)

#' Get Database Write Connection
#'
#' This function retrieves a write-enabled database connection for the default schema.
#' It is a wrapper around the \code{dbGetConnection} function.
#'
#' @return A database connection object for the default write schema.
#'
dbGetWriteConnection <- function() dbGetConnection(readonly = FALSE)

#' Execute a Query and Retrieve a Single Value
#'
#' This function executes a read-only SQL query and returns the first value
#' from the first row and first column of the result set.
#'
#' It expects the query result to be a table with one row and one column. If
#' the result is empty or `NULL`, the function returns `NULL`.
#'
#' @param query A character string representing the SQL query to execute.
#'
#' @return The first value from the query result or \code{NULL} if the result is empty.
#'
dbGetSingleValue <- function(query) {
  value <- dbGetQuery(query, readonly = TRUE)
  if (!is.null(value) && nrow(value) > 0 && ncol(value) > 0) {
    value <- value[1, ][[1]]
  } else {
    value <- NULL
  }
  return(value)
}

#' Get the Data Transfer Status from the Database
#'
#' This function retrieves the current data transfer status by calling the
#' `data_transfer_status()` database function. It uses a read-only query.
#'
#' The query is expected to return a single value from the database.
#'
#' @return The status returned by the `data_transfer_status()` function in the database.
#'         If no result is found, \code{NULL} is returned.
#'
dbGetStatus <- function() {
  dbGetSingleValue("SELECT db.data_transfer_status();")
}

#' Check Database Semaphore Status
#'
#' This function checks whether the current database semaphore status starts
#' with a specified status prefix. It retrieves the current database status using
#' `dbGetStatus` and performs a case-insensitive comparison against the provided prefix.
#'
#' @param status_prefix A character string specifying the prefix to check against
#'        the current database status.
#'
#' @return A logical value (`TRUE` or `FALSE`), indicating whether the current
#'         database status starts with the given `status_prefix`.
#'
dbHasStatus <- function(status_prefix) {
  status <- dbGetStatus()
  dbLog("Current database status: ", status)
  if (is.null(status)) {
    return(FALSE)
  }
  startsWith(tolower(status), tolower(status_prefix))
}

#' Get Name of Module That Set the Database Semaphore
#'
#' This function retrieves the name of the module that set the current semaphore (lock)
#' in the database by executing a predefined SQL query. Internally, it uses
#' `dbGetSingleValue()` to extract the result from the query.
#'
#' @return A character string representing the name of the module that set the semaphore,
#'         or `NULL` if no module is found.
#'
dbGetLockModule <- function() {
  dbGetSingleValue("SELECT db.data_transfer_get_lock_module();")
}

#' Check if the Database is Locked by the Current Module
#'
#' This function checks whether the current module has locked the database
#' by comparing the current database lock module with the module name stored
#' in the environment. It uses `dbGetLockModule()` and `dbGetModuleName()` for comparison.
#'
#' @return A logical value (`TRUE` or `FALSE`), indicating whether the current
#'         module holds the lock in the database.
#'
dbIsLockedByModule <- function() {
  lock_module <- dbGetLockModule()
  module_name <- dbGetModuleName()
  if (is.null(lock_module) || is.null(module_name)) {
    return(FALSE)
  }
  return(lock_module %in% module_name)
}

#' Create a Lock ID
#'
#' This function generates a lock ID by combining the current module name with additional
#' arguments provided as the lock ID message. The arguments are concatenated and prefixed
#' with the module name, separated by a colon (`:`).
#'
#' @param ... A variable number of strings to be concatenated as the lock ID message.
#'
#' @return A character string representing the combined lock ID in the format
#'         `<MODULE_NAME>:<lock_id_message>`.
#'
dbCreateLockID <- function(...) {
  paste0(.lib_db_env[["MODULE_NAME"]], ":", paste0(...))
}

#' Lock a Database for Write Access
#'
#' This function locks the database for write access using a specified lock ID.
#' It ensures proper management of recursive lock attempts and waits for the
#' database to become ready before applying the lock.
#'
#' If the lock attempt fails after multiple retries, the function throws an error.
#' The maximum number of retries is set to `5`.
#'
#' @param lock_id A character string specifying the unique identifier for the lock.
#'        If `NULL`, no locking is performed.
#'
#' @return The function does not return a value. It either successfully locks the
#'         database or throws an error if locking fails after the maximum number
#'         of retries.
#'
dbLock <- function(lock_id) {
  if (!is.null(lock_id)) {
    full_lock_id <- dbCreateLockID(lock_id)
    # increase the recursive call counter 'db_lock_depth'
    db_lock_depth <- .lib_db_env[[lock_id]]
    if (is.null(db_lock_depth)) db_lock_depth <- 0
    db_lock_depth <- db_lock_depth + 1
    .lib_db_env[[lock_id]] <- db_lock_depth

    if (dbLog()) {
      log_message <- paste0("Try to lock database with lock_id: '", full_lock_id, "'")
      if (.lib_db_env[[lock_id]] > 1) {
        log_message <- paste0(log_message, " (Trial ", .lib_db_env[[lock_id]], ")")
      }
      log_message <- paste(log_message, "\n")
      cat(log_message)
    }

    # recursive depth too high?
    if (db_lock_depth > 5) {
      stop("Could not lock the database access for lock_id '", full_lock_id, "'\n")
    }

    # if the database is ready for a new connection then the status message starts with "ReadyToConnect"
    while (!dbHasStatus("ReadyToConnect")) {
      Sys.sleep(4) # wait for 4 seconds
    }

    lock_query <- paste0("SELECT db.data_transfer_stop('", dbGetModuleName(), "', '", full_lock_id, "');")
    lock_successful <- dbGetSingleValue(lock_query)
    dbLog("DB lock successful = ", lock_successful, " with status on lock: ", dbGetStatus())
    if (!lock_successful) {
      dbLock(lock_id)
    }

    # decrease the recursive call counter 'db_lock_depth'
    .lib_db_env[[lock_id]] <- .lib_db_env[[lock_id]] - 1

  }
}

#' Unlock a Database for Read or Write Access
#'
#' This function unlocks the database using a specified lock ID. It ensures
#' proper handling of read-only or read-write access during the unlocking process.
#' If unlocking fails, an error is thrown with detailed information about the
#' current database status.
#'
#' @param lock_id A character string specifying the unique identifier for the lock.
#'        If `NULL`, no unlocking is performed.
#' @param readonly A logical value (`TRUE` or `FALSE`). If `TRUE`, the database
#'        is unlocked in read-only mode. Default is `FALSE`.
#'
#' @return A logical value (`TRUE` or `FALSE`), indicating whether the unlocking
#'         was successful.
#'
dbUnlock <- function(lock_id, readonly = FALSE) {
  unlock_successful = FALSE
  if (!is.null(lock_id)) {
    full_lock_id <- dbCreateLockID(lock_id)
    dbLog("Try to unlock database with lock_id: '", full_lock_id, "' and readonly: ", readonly)
    unlock_request <- paste0("SELECT db.data_transfer_start('", dbGetModuleName(), "', '", full_lock_id, "', ", readonly, ");")
    unlock_successful <- dbGetSingleValue(unlock_request)
    if (dbLog()) {
      status <- dbGetStatus()
      cat("Current database status after lock request:", status, "\n")
    }
    if (!unlock_successful) {
      db_connection <- dbGetConnection(readonly)
      status <- dbGetStatus()
      stop("Could not unlock the database for lock_id:\n",
           full_lock_id, "\n",
           "The current status is: " , status, "\n",
           dbGetInfo(readonly))
    }
  }
  return(unlock_successful)
}

#' Forcefully Reset a Database Lock for a Project
#'
#' This function forcibly resets the database lock for a specified project
#' by checking the current semaphore status and issuing a hard reset if
#' the project lock is active. If no lock is present, it logs a message
#' instead of performing any action.
#'
#' If the lock reset fails, the function throws an error and logs the
#' current database status for debugging purposes.
#'
#' @return A logical value (`TRUE` or `FALSE`), indicating whether the
#'         reset was successful.
#'
#'@export
dbResetLock <- function() {
  module_name <- dbGetModuleName()
  unlock_successful <- FALSE
  if (dbIsLockedByModule()) {
    unlock_request <- paste0("SELECT db.data_transfer_reset_lock('", module_name, "');")
    unlock_successful <- dbGetSingleValue(unlock_request)
    if (!unlock_successful) {
      status <- dbGetStatus()
      stop("Could not reset database lock for module:\n",
           module_name, "\n",
           "The current status is: " , status, "\n",
           dbGetInfo())
    }
  }
  if (unlock_successful) {
    dbLog("Reset database lock of module ", module_name)
  } else {
    dbLog("No database lock to remove for module ", module_name)
  }
  return(unlock_successful)
}

#' Close All Database Connections
#'
#' This function closes all active database connections stored in the global
#' connection environment `.lib_db_connection_env`. It iterates through all
#' connection objects, disconnects them, and removes them from the environment.
#'
#' If no connections are found, the function logs a message indicating that
#' there are no active connections to close.
#'
#' @return This function does not return a value. It performs the side effect
#'         of closing and removing all active database connections.
#'
#' @export
dbCloseAllConnections <- function() {
  dbResetLock()
  for (db_connection_variable_name in ls(.lib_db_connection_env)) {
    db_connection <- get(db_connection_variable_name, envir = .lib_db_connection_env)
    if (DBI::dbIsValid(db_connection)) {
      DBI::dbDisconnect(db_connection)
      rm(list = db_connection_variable_name, envir = .lib_db_connection_env)
    }
  }
}

#' List Table Names in a Database
#'
#' This function retrieves and displays the list of existing table names in the database connected
#' through the provided connection. It provides a quick overview of the database structure.
#'
#' @param db_connection A valid database connection object, typically created using `DBI::dbConnect`.
#'
#' @return A character vector containing the names of the tables in the connected database.
#'
#' @seealso \code{\link[DBI]{dbListTables}} for the underlying DBI function used to retrieve table names.
#'
dbListTableNames <- function(db_connection) {
  # Get existing table names from the database connection
  db_table_names <- DBI::dbListTables(db_connection)
  # Display the table names
  dbLog("The following tables are found in database: ", paste(db_table_names, collapse = ", "))
  if (length(db_table_names) == 0) {
    warning("There are no tables found in database for connection\n", dbGetInfoInternal(db_connection))
  }
  return(db_table_names)
}

#' Check Column Widths of a Table in a PostgreSQL Database
#'
#' This function checks whether the content of a specified table exceeds
#' the maximum allowed column widths defined in the PostgreSQL schema.
#' It retrieves the column constraints from `information_schema.columns`
#' and verifies that the lengths of the table content adhere to these limits.
#'
#' If the data exceeds the allowed column width, the function either truncates
#' the data or stops with an error, depending on the `allow_truncate` parameter.
#'
#' @param table_name A character string specifying the name of the table to check.
#'        The name is converted to lowercase for PostgreSQL compatibility.
#' @param table A `data.table` representing the content of the table to be checked.
#' @param allow_truncate Logical. If `TRUE`, values exceeding maximum length
#'        will be truncated. Defaults to `FALSE`.
#'
#' @details
#' - If `allow_truncate = TRUE`, values that exceed the maximum length are truncated.
#' - If `allow_truncate = FALSE`, the function throws an error if any column
#'   exceeds its maximum allowed length.
#'
dbCheckColumsWidthBeforeWrite <- function(table_name, table, allow_truncate = FALSE) {
  # Convert table name to lowercase for PostgreSQL compatibility
  table_name <- tolower(table_name)

  #there isno need to check the column width for read connections
  db_connection <- dbGetWriteConnection()

  # Construct SQL query to retrieve column widths
  sql_query <- paste0(
    "SELECT column_name, character_maximum_length\n",
    "FROM information_schema.columns\n",
    "WHERE table_name = '", table_name, "'"
  )

  dbLog("dbCheckColumsWidthBeforeWrite:\n", sql_query)

  # Retrieve column widths
  column_widths <- DBI::dbGetQuery(db_connection, sql_query)
  column_widths <- unique(column_widths)

  # Filter relevant columns
  column_widths <- column_widths[column_widths$column_name %in% names(table), ]

  # Initialize STOP flag
  STOP <- FALSE

  # Check each column
  for (i in seq_along(column_widths$column_name)) {
    column_name <- column_widths$column_name[i]
    max_length <- column_widths$character_maximum_length[i]

    # Check only VARCHAR columns with a valid max length
    if (!is.null(max_length) && !is.na(max_length)) {
      for (j in seq_len(nrow(table))) {
        value <- as.character(table[[column_name]][j])
        if (!is.null(value) && !is.na(value) && nchar(value) > max_length) {
          # Construct the error message
          cat_message <- paste0(
            "In table '", table_name, "' value '", value, "' in column '", column_name,
            "' at row ", j, " is ", nchar(value),
            " but maximum length is ", max_length
          )

          if (allow_truncate) {
            catInfoMessage(paste0(cat_message, ". Value will be truncated. Please check.\n"))
            # Truncate the value to the maximum allowed length
            table[j, (column_name) := substr(get(column_name), 1, max_length)]
          } else {
            catErrorMessage(paste0(cat_message, ". Please fix it.\n"))
            STOP <- TRUE
          }
        }
      }
    }
  }

  if (STOP) {
    stop("Some columns exceed their maximum allowed length (see error messages above).")
  }

}

dbGetReadOnlyColumns <- function(table_name) {
  # TODO: Dieser Holzhammer muss ersetzt werden durch eine DB-Abfrage, die für jede Tabelle die Spalten liefert, die einen Fehler generieren, wenn man versucht sie in die Datenbank zu schreiben.
  # Wenn man sich die Tabelle aber vorher mit select * geholt hat, dann sind diese Spalten mit dabei.
  # Das hier soll in der Version 0.3.0 nochmal überarbeitet/durchdacht werden!
  # Am besten wäre es, wenn die Views bei einem select * diese Spalten gar nicht erst mit ausliefern!
  return(c("hash_index_col", "hash_txt_col"))
}

#' Insert Rows into a PostgreSQL Table
#'
#' This function inserts rows from a `data.table` or `data.frame` into a
#' specified PostgreSQL table. The table name is converted to lowercase for
#' PostgreSQL compatibility. The function locks the database during the
#' insertion process to ensure data consistency and unlocks it afterward.
#'
#' @param table_name A character string specifying the target table name in
#'        the PostgreSQL database. The name is automatically converted to lowercase.
#' @param table A `data.table` or `data.frame` containing the rows to insert.
#' @param lock_id A character string specifying the lock ID used during the
#'        database operation. Default is `NULL`.
#'
#' @details
#' - If the table contains rows (`nrow(table) > 0`), the rows are appended
#'   to the specified table.
#' - The database is locked before the insertion and unlocked afterward using
#'   the provided lock ID.
#' - The function logs the number of rows inserted and the duration of the
#'   operation if logging is enabled.
#'
dbAddContent <- function(table_name, table, lock_id = NULL) {
  # Convert table name to lower case for PostgreSQL
  table_name <- tolower(table_name)

  # TODO: siehe Kommentar an der Funktion dbGetReadOnlyColumns
  table[, (dbGetReadOnlyColumns(table_name)) := NULL]

  # Measure start time
  time0 <- Sys.time()
  # Get row count for reporting
  row_count <- nrow(table)
  if (row_count > 0) {
    db_connection <- dbGetWriteConnection()
    # Append table content
    dbLock(lock_id)
    RPostgres::dbAppendTable(db_connection, table_name, table)
    dbUnlock(lock_id)
  }
  # Calculate and print duration of operation
  duration <- difftime(Sys.time(), time0, units = 'secs')
  dbLog("Inserted in ", table_name, ", ", row_count, " rows (took ", duration, " seconds)")
}

#' Delete All Rows from a PostgreSQL Table
#'
#' This function deletes all rows from a specified table in the PostgreSQL
#' database. The table name is converted to lowercase for PostgreSQL compatibility.
#' The function locks the database during the deletion process to ensure data
#' consistency and unlocks it afterward.
#'
#' @param table_name A character string specifying the name of the table
#'        from which all rows should be deleted. The name is automatically
#'        converted to lowercase.
#' @param lock_id A character string specifying the lock ID used during the
#'        database operation. Default is `NULL`.
#'
#' @details
#' - Locks the database before deletion and unlocks it afterward.
#' - Executes a `DELETE` SQL statement to remove all rows from the table.
#'
#' @seealso \code{\link[DBI]{dbExecute}} for executing SQL statements.
#'
dbDeleteContent <- function(table_name, lock_id = NULL) {
  # Convert table name to lowercase for PostgreSQL compatibility
  table_name <- tolower(table_name)
  # Create DELETE SQL statement
  statement <- paste0('DELETE FROM ', table_name, ';')
  # Execute the DELETE statement and get the number of affected rows
  deleted_rows <- dbExecute(statement, lock_id)
  # Log the number of deleted rows
  dbLog("Deleted ", deleted_rows, " rows from table ", table_name)
}

#' Execute a SQL Statement on a Database Connection
#'
#' This function executes a given SQL statement on a specified PostgreSQL
#' database connection. It locks the database during the execution to ensure
#' data consistency and unlocks it afterward.
#'
#' @param statement A character string representing the SQL statement to be executed.
#' @param lock_id A character string specifying the lock ID used during the
#'        database operation. Default is `NULL`.
#' @param readonly A logical value (`TRUE` or `FALSE`). If `TRUE`, the database
#'        remains in read-only mode after the operation. Default is `FALSE`.
#'
#' @return An integer value indicating the number of rows affected by the SQL statement.
#'
#' @details
#' - Locks the database before executing the SQL statement and unlocks it afterward.
#' - Logs the executed SQL statement if logging is enabled.
#'
#' @seealso \code{\link[DBI]{dbExecute}} for executing SQL statements.
#'
dbExecute <- function(statement, lock_id = NULL, readonly = FALSE) {
  db_connection <- dbGetConnection(readonly)
  dbLock(lock_id)
  dbLog("dbExecute:\n", statement)
  DBI::dbExecute(db_connection, statement)
  dbUnlock(lock_id, readonly)
}

#' Execute a SQL Query on a PostgreSQL Database
#'
#' This function executes a given SQL query on a specified PostgreSQL database
#' connection. It optionally logs the query, supports parameterized queries,
#' and ensures data consistency by locking and unlocking the database during execution.
#'
#' @param query A character string representing the SQL query to be executed.
#' @param params A named list of query parameters to prevent SQL injection.
#'        These parameters are passed to `DBI::dbGetQuery()`. Default is `NULL`.
#' @param lock_id A character string specifying the lock ID used during the
#'        database operation. Default is `NULL`.
#' @param readonly A logical value (`TRUE` or `FALSE`). If `TRUE`, the database
#'        remains in read-only mode after the operation. Default is `FALSE`.
#'
#' @return A `data.table` containing the results of the query.
#'
#' @details
#' - Locks the database before executing the query and unlocks it afterward.
#' - Supports dynamic queries with the `params` argument to prevent SQL injection.
#' - Converts the query result into a `data.table` for ease of use.
#'
#' @seealso \code{\link[DBI]{dbGetQuery}} for executing SQL queries.
#'
#' @export
dbGetQuery <- function(query, params = NULL, lock_id = NULL, readonly = FALSE) {
  db_connection <- dbGetConnection(readonly)
  # Lock the database
  dbLock(lock_id)
  # Log the query
  dbLog("dbGetQuery:\n", query)
  # Execute the query with parameters
  table <- data.table::as.data.table(DBI::dbGetQuery(db_connection, query, params = params))
  # Unlock the database
  dbUnlock(lock_id, readonly)
  return(table)
}

#' Execute a Read-Only SQL Query on a PostgreSQL Database
#'
#' This function executes a read-only SQL query on a PostgreSQL database.
#' It is a wrapper around `dbGetQuery`, ensuring that the query is always
#' executed in read-only mode.
#'
#' @param query A character string representing the SQL query to be executed.
#' @param params A named list of query parameters to prevent SQL injection.
#'        These parameters are passed to `DBI::dbGetQuery()`. Default is `NULL`.
#' @param lock_id A character string specifying the lock ID used during the
#'        database operation. Default is `NULL`.
#'
#' @return A `data.table` containing the results of the query.
#'
#' @export
dbGetReadOnlyQuery <- function(query, params = NULL, lock_id = NULL) {
  dbGetQuery(query, params = params, lock_id = lock_id, readonly = TRUE)
}

#' Read a Table from a PostgreSQL Database
#'
#' This function reads a table from a PostgreSQL database and returns it as
#' a `data.table`. It ensures compatibility with PostgreSQL by converting the
#' table name to lowercase. The database is locked during the read operation
#' and unlocked afterward.
#'
#' @param table_name A character string specifying the name of the table to read.
#'        The table name will be converted to lowercase.
#' @param lock_id A character string specifying the lock ID used during the
#'        database operation. Default is `NULL`.
#'
#' @return A `data.table` containing the contents of the specified table.
#'
#' @details
#' - Locks the database before reading the table and unlocks it afterward.
#' - Converts the table name to lowercase to comply with PostgreSQL's case
#'   sensitivity rules.
#'
#' @seealso \code{\link[DBI]{dbReadTable}} for reading tables from the database.
#'
#' @export
dbReadTable <- function(table_name, lock_id = NULL) {
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  db_connection <- dbGetReadConnection()
  dbLock(lock_id)
  dbLog("dbReadTable: ", table_name)
  table <- data.table::as.data.table(DBI::dbReadTable(db_connection, table_name))
  dbUnlock(lock_id, readonly = TRUE)
  return(table)
}

#' Check if a PostgreSQL Table is Empty
#'
#' This function checks whether a specified table in a PostgreSQL database
#' contains any rows. It executes a `COUNT(*)` query on the table and evaluates
#' whether the count is zero.
#'
#' @param db_connection A valid database connection object to the PostgreSQL database.
#' @param table_name A character string specifying the name of the table to check.
#'
#' @return A logical value: `TRUE` if the table is empty, `FALSE` otherwise.
#'
#' @details
#' - The function executes a `SELECT COUNT(*)` query to determine the number
#'   of rows in the table.
#' - If the query returns zero, the function returns `TRUE`; otherwise, it
#'   returns `FALSE`.
#'
#' @seealso \code{\link[DBI]{dbGetQuery}} for executing SQL queries.
#'
dbIsTableEmpty <- function(db_connection, table_name) {
  readonly <- identical(db_connection, dbGetReadConnection())
  # SQL query to count rows in the table
  query <- paste0("SELECT COUNT(*) FROM ", table_name)
  # Execute the query and fetch the result (for the write connection)
  result <- dbGetQuery(query, readonly = readonly)
  rows_in_table <- result[1, 1]
  dbLog("Table '", table_name, "' has ", rows_in_table, " rows")
  # Return TRUE if the count is 0, indicating the table is empty
  return(rows_in_table == 0)
}

#' Write Multiple Tables to a PostgreSQL Database
#'
#' This function writes multiple `data.table` or `data.frame` objects to specified
#' tables in a PostgreSQL database. It validates that the target tables exist and
#' optionally checks if they are empty before writing. The function locks the
#' database during the operation for consistency.
#'
#' @param tables A named list of `data.table` or `data.frame` objects to be written
#'        to the database. Each list element name corresponds to a target table name.
#' @param lock_id A character string specifying the lock ID used during the database
#'        operation. Default is `NULL`.
#' @param stop_if_table_not_empty Logical. If `TRUE`, the function stops execution
#'        if any target table is not empty. Default is `FALSE`.
#'
#' @details
#' - Validates the existence of all target tables in the database.
#' - Optionally stops the operation if `stop_if_table_not_empty = TRUE` and
#'   non-empty tables are detected.
#' - Writes the tables sequentially to their corresponding database tables.
#' - Logs the number of written rows and execution time for each table if logging is enabled.
#'
#' @seealso \code{\link[DBI]{dbWriteTable}} for writing tables to a database.
#'
#' @export
dbWriteTables <- function(tables, lock_id = NULL, stop_if_table_not_empty = FALSE) {
  table_names <- names(tables)
  db_connection <- dbGetWriteConnection()
  db_table_names <- dbListTableNames(db_connection)

  # Stop with error if there are tables that do not exist in the database
  missing_db_table_names <- setdiff(table_names, db_table_names)
  if (length(missing_db_table_names) > 0) {
    stop(paste("The following tables are not found in the database. Perhaps the database was not initialized correctly?\n  ",
               paste(missing_db_table_names, collapse = "\n   ")))
  }

  # Restrict `table_names` to only those found in both `tables` and the database
  table_names <- intersect(table_names, db_table_names)

  # 1. Check if any tables are not empty when `stop_if_table_not_empty` is TRUE
  # Check if tables are empty if required
  if (stop_if_table_not_empty) {
    non_empty_tables <- table_names[!sapply(table_names, function(table_name) {
      dbIsTableEmpty(db_connection, table_name)
    })]
    if (length(non_empty_tables) > 0) {
      stop("The following tables are not empty:\n",
           paste(non_empty_tables, collapse = "\n"))
    }
  }

  # 2. Write tables to DB (only if all tables are empty or if `stop_if_table_not_empty` is FALSE)
  dbLock(lock_id)
  for (table_name in table_names) {
    table <- tables[[table_name]]
    # Proceed with writing table data to the database
    dbCheckColumsWidthBeforeWrite(table_name, table)  # Check column widths
    dbAddContent(table_name, table)   # Add table content
  }
  dbUnlock(lock_id)
}

#' Write a Single Table to a PostgreSQL Database
#'
#' This function writes a single `data.table` or `data.frame` to a specified
#' table in a PostgreSQL database. If no table name is provided, the name of
#' the `data.table` variable is used as the target table name. The function
#' ensures data consistency by optionally checking if the table is empty and
#' locking the database during the operation.
#'
#' @param table A `data.table` or `data.frame` object to be written to the database.
#' @param table_name A character string specifying the target table name. If `NA`,
#'        the name of the `data.table` variable is used. Default is `NA`.
#' @param lock_id A character string specifying the lock ID used during the database
#'        operation. Default is `NULL`.
#' @param stop_if_table_not_empty Logical. If `TRUE`, the function stops execution
#'        if the target table is not empty. Default is `FALSE`.
#'
#' @details
#' - If `table_name` is `NA`, the function extracts the variable name of the input
#'   `table` as the target table name.
#' - Ensures the table is empty if `stop_if_table_not_empty` is set to `TRUE`.
#' - Writes the `data.table` or `data.frame` to the target table in the database.
#' - Optionally closes the database connection after the operation.
#'
#' @seealso \code{\link[DBI]{dbWriteTable}} for writing tables to a database.
#'
#' @export
dbWriteTable <- function(table, table_name = NA, lock_id = NULL, stop_if_table_not_empty = FALSE) {
  # Extract the table name if not provided
  if (is.na(table_name)) {
    table_name <- as.character(sys.call()[2]) # Extract the variable name of the data.table
  }
  # Wrap the table into a named list for dbWriteTables
  tables <- list(table)
  names(tables) <- table_name
  # Call the dbWriteTables function to perform the writing operation
  dbWriteTables(tables, stop_if_table_not_empty, lock_id)
}

#' Read Multiple Tables from a PostgreSQL Database
#'
#' This function reads multiple tables from a PostgreSQL database and returns them as a named list
#' of `data.table` objects. If no table names are specified, all tables in the database are read.
#' The function ensures compatibility with PostgreSQL by converting table names to lowercase
#' and handles views prefixed with `v_`.
#'
#' @param table_names A character vector of table names to read. If `NA` (default), all tables
#'        in the database are read.
#' @param lock_id A string specifying the lock ID used during the database operation.
#'
#' @return A named list of `data.table` objects, where each element corresponds to a table read
#'         from the database.
#'
#' @details
#' - If `table_names` is `NA`, all tables in the database are read.
#' - Handles views by detecting and adjusting names prefixed with `v_`.
#' - Locks the database during the operation and unlocks it afterward.
#'
#' @export
dbReadTables <- function(table_names = NA, lock_id = NULL) {
  # Establish a read-only database connection
  db_connection <- dbGetReadConnection()
  # Get the list of tables in the database
  db_table_names <- dbListTableNames(db_connection)

  # If no table names are provided, read all available tables
  if (isSimpleNA(table_names)) {
    table_names <- db_table_names
  }

  # Initialize an empty list to store the results
  tables <- list()
  # Lock the database before reading
  dbLock(lock_id)
  # Loop through each requested table
  for (table_name in table_names) {
    # Handle views prefixed with "v_"
    if (!table_name %in% db_table_names) {
      table_name <- paste0("v_", table_name)
    }
    # Extract the corresponding resource table name
    if (grepl("^v_", table_name)) {
      resource_table_name <- sub("^v_", "", table_name)
    } else {
      resource_table_name <- table_name
    }
    # Read the table and store it in the list
    tables[[resource_table_name]] <- dbReadTable(table_name)
  }
  # Unlock the database after reading
  dbUnlock(lock_id, readonly = TRUE)
  # Return the list of read tables
  return(tables)
}

#' Print Database Timezone and Current Time
#'
#' This function retrieves and prints the current timezone and time from the connected
#' PostgreSQL database. It also prints the current time and timezone of the R session for
#' comparison.
#'
#' @param db_connection A valid database connection object to the PostgreSQL database.
#'
#' @return `NULL`. The function is used for its side effects of printing the database timezone
#'         and time.
#'
#' @details
#' - Queries the PostgreSQL database for its current timezone using `SHOW timezone;`.
#' - Retrieves the current time from the database using `SELECT NOW();` and `SELECT CURRENT_TIMESTAMP;`.
#' - Prints the R session's current time and timezone alongside the database's information.
#'
dbPrintTimeAndTimezone <- function(db_connection) {
  # Query to get the current timezone
  query <- "SHOW timezone;"
  timezone <- DBI::dbGetQuery(db_connection, query)
  print(paste0("DB Timezone: ", timezone))

  # Query to get the current time
  query <- "SELECT NOW();"
  now_time <- DBI::dbGetQuery(db_connection, query)
  print(paste0("DB SELECT NOW(): ", now_time$now))

  # Query to get the current timestamp
  query <- "SELECT CURRENT_TIMESTAMP;"
  current_timestamp <- DBI::dbGetQuery(db_connection, query)
  #print(paste0("CURRENT_TIMESTAMP: ", current_timestamp$current_timestamp))
  print(paste0("DB CURRENT_TIMESTAMP: ", current_timestamp))

  print(paste0("R Sys.time(): ", Sys.time()))
  print(paste0("R Sys.timezone(): ", Sys.timezone()))
}

#' Get the Current Schema of a PostgreSQL Connection
#'
#' This function retrieves the current schema of an active PostgreSQL connection by executing
#' the query `SELECT current_schema();`.
#'
#' @param db_connection A valid database connection object to the PostgreSQL database.
#'
#' @return A string representing the name of the current schema.
#'
#' @details
#' - Logs the executed query if `log = TRUE`.
#' - Uses the schema to identify tables and other database objects accessible in the connection.
#'
dbGetCurrentSchema <- function(db_connection) {
  # SQL query to retrieve the current schema
  query <- "SELECT current_schema();"
  # Execute the query and store the result
  result <- dbGetQuery(query)
  # Return the schema name from the first row and column
  return(result$current_schema[1])
}

#' Retrieve Column Names and Data Types of a Database Table
#'
#' This function retrieves the column names and their corresponding data types
#' for a specified table in the current schema of a PostgreSQL database. It
#' queries the `information_schema.columns` system view to obtain this information.
#'
#' @param table_name A string specifying the name of the table for which column
#'        information is retrieved.
#' @param readonly Logical. If `TRUE`, the database connection remains in read-only
#'        mode after the operation. Default is `FALSE`.
#'
#' @return A `data.table` with two columns:
#' \describe{
#'   \item{`column_name`}{The names of the columns in the specified table.}
#'   \item{`data_type`}{The corresponding PostgreSQL data types of the columns.}
#' }
#'
#' @details
#' - Retrieves column metadata from `information_schema.columns` for the current schema.
#' - Logs the executed SQL query if `log = TRUE`.
#'
dbGetTableColumnTypes <- function(table_name, readonly = FALSE) {
  db_connection <- dbGetConnection(readonly)
  schema <- dbGetCurrentSchema()
  # SQL query to retrieve column names and data types
  query <- paste0(
    "SELECT column_name, data_type
     FROM information_schema.columns
     WHERE table_name = '", tolower(table_name), "'
     AND table_schema = '", schema, "'"
  )
  # Execute the query and return the result as a data.table
  result <- dbGetQuery(query)
  # Ensure the result is not empty
  if (nrow(result) == 0) {
    stop("Table '", table_name, "' does not exist or has no columns defined.")
  }
  return(result)
}

#' Convert Data Table Columns to PostgreSQL-Compatible Types
#'
#' This function converts the columns of a `data.table` to specified types based on a PostgreSQL
#' schema. It ensures that the data matches the database's expected column types, such as
#' integers, character strings, or timestamps.
#'
#' @param dt A `data.table` object containing the data to be converted.
#' @param table_name A string specifying the name of the corresponding PostgreSQL table.
#'
#' @return A `data.table` with columns converted to the specified database-compatible types.
#'
#' @details
#' - Retrieves the expected data types from the PostgreSQL schema using
#'   `dbGetTableColumnTypes()`.
#' - Converts common PostgreSQL types, including integers, doubles, character
#'   strings, dates, and timestamps, to corresponding R types.
#' - Columns not present in the table schema remain unchanged.
#'
#' @export
dbConvertToDBTypes <- function(dt, table_name) {
  # Get the database connection and table schema
  db_columns <- dbGetTableColumnTypes(table_name)

  # Iterate over each column in the database schema
  for (i in seq_len(nrow(db_columns))) {
    col_name <- db_columns$column_name[i]
    db_type <- db_columns$data_type[i]

    # Check if the column exists in the data.table
    if (col_name %in% names(dt)) {
      # Convert the column type based on PostgreSQL type
      if (db_type %in% c("integer", "bigint", "smallint")) {
        dt[, (col_name) := as.integer(get(col_name))]
      } else if (db_type %in% c("double precision", "real", "numeric")) {
        dt[, (col_name) := as.numeric(get(col_name))]
      } else if (db_type %in% c("character varying", "character", "text")) {
        dt[, (col_name) := as.character(get(col_name))]
      } else if (db_type == "date") {
        # It may be that data from the frontend that should actually be of the type “date” is
        # returned as a “timestamp”. This function fix it.
        dt[, (col_name) := as.DateWithTimezone(get(col_name))]
      } else if (db_type %in% c("timestamp without time zone", "timestamp with time zone")) {
        dt[, (col_name) := as.POSIXctWithTimezone(get(col_name))]
      } else if (db_type == "boolean") {
        dt[, (col_name) := as.logical(get(col_name))]
      } else {
        dbLog("Unknown PostgreSQL type for column '", col_name,
              "': ", db_type, ". No conversion applied.")
      }
    }
  }
  return(dt)
}

#' Retrieve Detailed Database Connection Information
#'
#' This function retrieves and formats metadata about a database connection. For PostgreSQL
#' connections, it includes additional details such as the current user, database name, host
#' address, and server version.
#'
#' @param db_connection A valid database connection object created using `DBI::dbConnect`.
#'
#' @return A character string containing formatted connection details, including driver information,
#'         host, port, database name, user, and additional PostgreSQL-specific details if available.
#'
#' @details
#' - Retrieves standard connection metadata using `DBI::dbGetInfo`.
#' - For PostgreSQL connections, executes additional SQL queries to fetch server-specific details,
#'   such as IP address, port, and version.
#' - Formats the retrieved details into a human-readable log message.
#'
dbGetInfoInternal <- function(db_connection = dbGetReadConnection()) {
  # Retrieve standard connection information
  info <- DBI::dbGetInfo(db_connection)

  # Additional information for PostgreSQL
  additional_info <- NULL
  if (inherits(db_connection, "PqConnection")) {
    tryCatch({
      # Fetch additional details using SQL queries
      additional_info <- DBI::dbGetQuery(db_connection, "
        SELECT
          current_user AS user,
          current_database() AS database,
          inet_server_addr() AS host,
          inet_server_port() AS port,
          current_setting('server_version') AS version;
      ")
    }, error = function(e) {
      warning("Failed to fetch additional PostgreSQL details: ", conditionMessage(e))
    })
  }

  # Create a formatted log message
  log_message <- paste0(
    "Database Connection Details:\n",
    "-----------------------------\n",
    "Driver       : ", info$driver, "\n",
    "Host         : ", info$host, "\n",
    "Port         : ", info$port, "\n",
    "Database     : ", info$dbname, "\n",
    "User         : ", info$user, "\n",
    if (!is.null(additional_info)) {
      paste0(
        "Server Info  :\n",
        "  - IP       : ", additional_info$host[1], "\n",
        "  - Port     : ", additional_info$port[1], "\n",
        "  - Version  : ", additional_info$version[1], "\n"
      )
    } else "",
    "Connection Valid: ", ifelse(info$valid, "Yes", "No"), "\n"
  )

  # Return the log message
  return(log_message)
}

#' Retrieve Detailed Database Connection Information
#'
#' This function retrieves and formats metadata about a PostgreSQL database connection.
#' It includes standard connection details such as the database name, user, host, and port.
#' For PostgreSQL-specific connections, additional details like IP address and server version
#' are fetched using SQL queries.
#'
#' @param readonly Logical. If `TRUE`, a read-only connection is used. If `FALSE`,
#'        a write-enabled connection is established. Default is `TRUE`.
#'
#' @return A character string containing formatted connection details, including driver information,
#'         host, port, database name, user, and additional PostgreSQL-specific details if available.
#'
#' @details
#' - Retrieves standard connection metadata using `DBI::dbGetInfo`.
#' - For PostgreSQL connections, executes additional SQL queries to fetch server-specific details,
#'   such as IP address, port, and server version.
#' - Formats the retrieved details into a human-readable log message.
#'
#' @export
dbGetInfo <- function(readonly = TRUE) {
  db_connection <- dbGetConnection(readonly)
  return(dbGetInfoInternal(db_connection))
}

#' Get Corresponding R Data Type for a Given Database Type
#'
#' This function returns the corresponding R data type (as an NA value with the correct class)
#' for a given database type, based on a mapping stored in `.lib_db_env$DB_R_TYPES_MAPPING`.
#' The mapping is parsed only once and cached in `.lib_db_env` as `DB_R_TYPES_MAPPING_PARSED_LIST`.
#'
#' @param db_type A character string representing the database type (e.g., "varchar", "int").
#'
#' @return An R object initialized with NA of the corresponding type (e.g., `as.character(NA)`, `as.integer(NA)`).
#' If no matching R type is found, an error is raised.
#'
#' @details
#' The mapping is expected to be a character vector stored in `.lib_db_env$DB_R_TYPES_MAPPING`
#' with each element formatted like: "character = 'varchar'". This function splits each element
#' and builds a named vector where names are the database types and values are NA values of the corresponding R types.
#'
#' @examples
#' \dontrun{
#' # Suppose .lib_db_env$DB_R_TYPES_MAPPING is defined as:
#' # c("character = 'varchar'", "integer = 'int'", "numeric = 'double precision'",
#' #   "POSIXct = 'timestamp'", "Date = 'date'", "logical = 'boolean'")
#' dbGetRType("varchar")    # Should return as.character(NA)
#' dbGetRType("int")        # Should return as.integer(NA)
#' }
#'
#' @export
dbGetRType <- function(db_type) {
  # If the parsed mapping does not exist, create it from .lib_db_env$DB_R_TYPES_MAPPING
  if (!exists("DB_R_TYPES_MAPPING_PARSED_LIST", envir = .lib_db_env)) {
    if (!exists("DB_R_TYPES_MAPPING", envir = .lib_db_env)) {
      stop("Mapping not found: .lib_db_env$DB_R_TYPES_MAPPING does not exist.")
    }

    # Split each string by " = " to separate the key (R type) and the value (database type)
    split_list <- strsplit(.lib_db_env$DB_R_TYPES_MAPPING, " = ")

    # Create a named vector using a for-loop.
    mapping_vector <- c()
    for (i in seq_along(split_list)) {
      parts <- split_list[[i]]
      r_type <- switch(tolower(trimws(parts[1])),
                       "integer" = as.integer(NA),
                       "character" = as.character(NA),
                       "numeric" = as.numeric(NA),
                       "logical" = as.logical(NA),
                       "date" = as.Date(NA),
                       "posixct" = as.POSIXct(NA, tz = GLOBAL_TIMEZONE),
                       stop("Unknown R type '", parts[1], "' defined in DB_R_TYPES_MAPPING_PARSED_LIST in file cds_hub_db_config.toml") # Error for unknown types
      )
      db_type_key <- gsub("'", "", trimws(parts[2]))
      mapping_vector[[db_type_key]] <- r_type
    }

    # Cache the parsed mapping in the environment.
    assign("DB_R_TYPES_MAPPING_PARSED_LIST", mapping_vector, envir = .lib_db_env)
  } else {
    mapping_vector <- get("DB_R_TYPES_MAPPING_PARSED_LIST", envir = .lib_db_env)
  }

  # Default to character if db_type is empty or NA.
  if (is.na(db_type) || nchar(trimws(db_type)) == 0) {
    return(as.character(NA))
  }

  # Directly return the R type (NA with correct class) based on db_type.
  if (db_type %in% names(mapping_vector)) {
    return(mapping_vector[[db_type]])
  }

  stop(paste("No matching R type found for db type:", db_type))
}

