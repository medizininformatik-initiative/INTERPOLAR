# Environment for saving the connections
.lib_db_env <- new.env()

#' Retrieve a Single Status Value from the Database
#'
#' This function executes a query on a given database connection and extracts the first value
#' from the result, assuming the query returns a single row and column.
#'
#' @param db_connection A valid database connection object.
#' @param query A character string representing the SQL query to execute.
#' @param log logical. If TRUE then all tables names will be printed to the console. Default is TRUE.
#'
#' @return The first value from the query result, or \code{NULL} if the result is empty.
#'
getStatusFromDB <- function(db_connection, query, log = TRUE) {
  status <- dbGetQuery(db_connection, query, log = log, readonly = TRUE)
  if (!is.null(status)) status <- status[1, ][[1]] # the functions answer is a table with 1 row and 1 column
}

#' Check Database Semaphore Status
#'
#' This function checks whether the current database status starts with a specified status prefix.
#'
#' @param db_connection A database connection object used to query the database.
#' @param status_prefix A string specifying the prefix to check against the current database status.
#'
#' @return A logical value (`TRUE` or `FALSE`), indicating whether the database status starts
#'         with the given `status_prefix`.
#'
hasSemaphoreStatus <- function(db_connection, status_prefix) {
  status <- getStatusFromDB(db_connection, "SELECT db.data_transfer_status();")
  cat("Current database status:", status, "\n")
  return(startsWith(tolower(status), tolower(status_prefix)))
}

#' Lock a Database for Write Access
#'
#' This function attempts to lock the database for write access using a specified lock ID.
#' It ensures that recursive locking attempts are managed, and it waits for the database to
#' become ready before applying the lock.
#'
#' @param db_connection A database connection object used to interact with the database.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs messages to the console.
#' @param lock_id A string specifying the unique identifier for the lock. If `NULL`, no locking is performed.
#'
#' @return The function does not return a value. It either successfully locks the database
#'         or throws an error if locking fails due to excessive recursive attempts or other issues.
#'
dbLock <- function(db_connection, log = TRUE, lock_id = NULL) {
  if (!is.null(lock_id)) {
    # increase the recursive call counter 'db_lock_depth'
    db_lock_depth <- .lib_db_env[[lock_id]]
    if (is.null(db_lock_depth)) db_lock_depth <- 0
    db_lock_depth <- db_lock_depth + 1
    .lib_db_env[[lock_id]] <- db_lock_depth

    if (log) {
      log_message <- paste0("Try to lock database with lock_id: '", lock_id, "'")
      if (.lib_db_env[[lock_id]] > 1) {
        log_message <- paste0(log_message, " (Trial", .lib_db_env[[lock_id]], ")")
      }
      log_message <- paste(log_message, "\n")
      cat(log_message)
    }

    # recursive depth too high?
    if (db_lock_depth > 5) {
      stop("Could not lock the database for write access.\n", dbGetInfo(db_connection))
    }

    # if the database is ready for a new connection then the status message starts with "ReadyToConnect"
    while (!hasSemaphoreStatus(db_connection, "ReadyToConnect")) {
      Sys.sleep(4) # wait for 4 seconds
      # TODO alle Minute eine Rückmeldung geben "Warte immer noch darauf, die DB locken zu dürfen..."
    }

    lock_sucessful <- getStatusFromDB(db_connection, paste0("SELECT db.data_transfer_stop('", lock_id, "');"), log)
    if (log) {
      cat(paste("DB status on lock:", lock_sucessful, "\n"))
    }
    if (!lock_sucessful) {
      dbLock(db_connection, log, lock_id)
    }

    # decrease the recursive call counter 'db_lock_depth'
    .lib_db_env[[lock_id]] <- .lib_db_env[[lock_id]] - 1
  }
}

#' Unlock a Database for Read or Write Access
#'
#' This function attempts to unlock the database using a specified lock ID.
#' It ensures proper handling of read-only or read-write access during the unlocking process.
#'
#' @param db_connection A database connection object used to interact with the database.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs messages to the console.
#' @param lock_id A string specifying the unique identifier for the lock. If `NULL`, no unlocking is performed.
#' @param readonly A logical value (`TRUE` or `FALSE`). If `TRUE`, the database is unlocked in read-only mode.
#'
#' @return The function does not return a value. It either successfully unlocks the database
#'         or throws an error if unlocking fails.
#'
dbUnlock <- function(db_connection, log = TRUE, lock_id, readonly = FALSE) {
  if (!is.null(lock_id)) {
    if (log) {
      cat(paste0("Try to unlock database with lock_id: '", lock_id, "' and readonly: ", readonly, "\n"))
    }
    unlock_sucessful <- getStatusFromDB(db_connection, paste0("SELECT db.data_transfer_start('", lock_id, "', ", readonly, ");"), log)
    if (!unlock_sucessful) {
      status <- getSemaphoreStatus(db_connection)
      stop("Could not unlock the database for lock_did:\n",
           lock_id, "\n",
           "The current status is: " , status, "\n",
           dbGetInfo(db_connection))
    }
  }
}

#' Establish a Connection to a PostgreSQL Database
#'
#' This function establishes a connection to a PostgreSQL database using the specified credentials and settings.
#' It configures the connection to use a specific schema and adjusts the `work_mem` setting to allow more memory for
#' operations, enhancing performance for tasks that require more memory.
#'
#' @param dbname The name of the database.
#' @param host The host address where the database is located.
#' @param port The port number for the database connection.
#' @param user The username for the database connection.
#' @param password The password for the database connection.
#' @param schema The schema under which the tables can be found. This sets the search path to the specified schema.
#'
#' @return A database connection object that is configured to use the specified schema and has an increased `work_mem`
#' setting.
#'
#' @export
dbConnect <- function(dbname, host, port, user, password, schema) {
  cat(paste0("Try to connect with: \n   dbname=", dbname, "\n   host=", host, "\n   port=", port, "\n   user=", user, "\n   password=", password, "\n   schema=", schema, "\n"))
  db_connection <- DBI::dbConnect(RPostgres::Postgres(),
                                  dbname = dbname,
                                  host = host,
                                  port = port,
                                  user = user,
                                  password = password,
                                  options = paste0('-c search_path=', schema),
                                  timezone = "Europe/Berlin")

  # Increase memory allocation for this connection to improve performance for memory-intensive operations
  DBI::dbExecute(db_connection, "set work_mem to '32MB';")
  return(db_connection)
}

#' Close Database Connection
#'
#' This function serves as a wrapper around `DBI::dbDisconnect`, providing a simplified
#' interface for closing an open database connection. It ensures that the connection
#' is properly closed to free up resources.
#'
#' @param db_connection A valid database connection object created by `DBI::dbConnect` or
#' a similar DBI connection function. This connection will be closed by this function.
#'
#' @return Invisible `TRUE` if the disconnection was successful, otherwise an error is thrown
#' by the underlying DBI function.
#'
#' @seealso \code{\link[DBI]{dbDisconnect}} for the underlying DBI function.
#' @export
dbDisconnect <- function(db_connection) {
  DBI::dbDisconnect(db_connection)
}

#' Check Database Connection Validity
#'
#' This function serves as a wrapper around `DBI::dbIsValid`, providing a simplified
#' interface for checking if a database connection is still open. It ensures that
#' the connection is properly validated.
#'
#' @param db_connection A valid database connection object created by `DBI::dbConnect` or
#' a similar DBI connection function. This connection will be checked for validity by this function.
#'
#' @return A logical value: `TRUE` if the connection is valid (open), otherwise `FALSE`.
#'
#' @seealso \code{\link[DBI]{dbIsValid}} for the underlying DBI function.
#' @export
dbIsValid <- function(db_connection) {
  DBI::dbIsValid(db_connection)
}

#' List Table Names in a Database
#'
#' Retrieves and displays the list of existing table names in a database connection. This function
#' provides a quick overview of all tables within the specified database, offering immediate insight
#' into the database structure without returning the actual data.
#'
#' @param db_connection A valid database connection object, typically created using `DBI::dbConnect`.
#' This connection should already be established and active to successfully retrieve table names.
#' @param log logical. If TRUE then all tables names will be printed to the console. Default is TRUE.
#'
#' @return Returns a character vector of table names. The function primarily prints these names
#' using `utils::str()` for immediate inspection, which is useful for debugging or quick checks in
#' an interactive R session.
#'
#' @seealso
#' \code{\link[DBI]{dbConnect}} to learn about establishing database connections.
#' \code{\link[DBI]{dbListTables}} for the underlying DBI function that this wrapper utilizes.
#' \code{\link[utils]{str}} to explore the utility function used for displaying the table names.
#'
#' @export
dbListTableNames <- function(db_connection, log = TRUE) {
  # Get existing table names from the database connection
  db_table_names <- DBI::dbListTables(db_connection)
  if (log) {
    # Display the table names
    print(paste("The following tables are found in database:", paste(db_table_names, collapse = ", ")))
    if (is.null(db_table_names)) {
      warning("There are no tables found in database")
    }
  }
  return(db_table_names)
}

#' Check column widths of a table in a PostgreSQL database
#'
#' This function retrieves information about the column widths of a specified table
#' in a PostgreSQL database using the information_schema.columns system view.
#'
#' @param db_connection A DBI connection object to the PostgreSQL database.
#' @param table_name A character string specifying the name of the table to check.
#' @param table A data frame representing the table to be checked.
#' @param log logical. If TRUE then all tables names will be printed to the console. Default is TRUE.
#'
#' @details This function converts the table name to lowercase for PostgreSQL compatibility,
#' then constructs a SQL query to retrieve the column widths (maximum length for VARCHAR columns)
#' of the specified table from the information_schema.columns system view. It retrieves the
#' column widths using \code{DBI::dbGetQuery()} and checks the lengths of the corresponding
#' columns in the provided table. If any values exceed the maximum length, it prints an error
#' message and returns FALSE. Otherwise, it returns TRUE indicating no violations were found.
#'
#' @return A logical value indicating whether the table content meets the length constraints.
#'
#' @export
dbCheckContent <- function(db_connection, table_name, table, log = TRUE) {
  # Convert table name to lowercase for PostgreSQL compatibility
  table_name <- tolower(table_name)

  # Construct SQL query to retrieve column widths
  sql_query <- paste0("SELECT column_name, character_maximum_length
                     FROM information_schema.columns
                     WHERE table_name = '", table_name, "'")

  if (log) {
    cat(paste0("dbCheckContent:\n", sql_query, "\n"))
  }

  # Retrieve column widths
  column_widths <- DBI::dbGetQuery(db_connection, sql_query)

  # Remove duplicate column widths
  column_widths <- unique(column_widths)

  # Filter column_widths to keep only columns present in the data table
  column_widths <- column_widths[column_widths$column_name %in% names(table), ]

  # Initialize STOP flag
  STOP <- FALSE

  # Check length of each column in column_widths
  for (i in seq_along(column_widths$column_name)) {
    column_name <- column_widths$column_name[i]
    max_length <- column_widths$character_maximum_length[i]
    if (!is.na(max_length)) { # only varchars have a valid (non NA) value
      # Check length of each value in the column
      for (j in seq_len(nrow(table))) {
        value <- as.character(table[[column_name]][j])
        if (!is.na(value) && nchar(value) > max_length) {
          # Add message text
          cat_message <- paste0("In table '", table_name , "' value '", value, "' in column '", column_name, "' at row ", j, " is " , nchar(value), " but maximum length is ", max_length)
          # Print error or info message for values exceeding maximum length
          if (max_length <= 100) {
            catErrorMessage(paste0(cat_message, ". Please Fix it", "\n"))
            STOP <- TRUE
          } else {
            catInfoMessage(paste0(cat_message, ". Will be truncated. Please Check", "\n"))
            # Truncate string to possible maximum length
            table[j, (column_name) := substr(get(column_name), 1, max_length)]
          }
        }
      }
    }
  }
  if (STOP) stop()
}

#' Insert Rows into a PostgreSQL Table
#'
#' This function inserts rows from a `data.table` or `data.frame` into a specified table within a PostgreSQL database.
#' It automatically converts the table name to lower case to align with PostgreSQL's case sensitivity conventions.
#' The function attempts to insert all provided rows into the database and reports the number of rows inserted
#' along with the duration of the operation. In case of an error during the insert operation, it prints out the error
#' message and stops execution.
#'
#' @param db_connection A valid database connection object, typically created using `DBI::dbConnect`.
#' @param table_name The name of the target table in the PostgreSQL database where rows will be inserted.
#'                   The table name is automatically converted to lower case.
#' @param table A `data.table` or `data.frame` containing the rows to be inserted into the specified table.
#' @param log A logical value indicating whether the SQL statement should be logged to the console.
#'        Default is TRUE.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#'
#' @export
dbAddContent <- function(db_connection, table_name, table, log = TRUE, lock_id = NULL) {
  # Convert table name to lower case for PostgreSQL
  table_name <- tolower(table_name)
  # Measure start time
  time0 <- Sys.time()
  # Get row count for reporting
  row_count <- nrow(table)
  if (row_count > 0) {
    # Append table content
    dbLock(db_connection, log, lock_id)
    RPostgres::dbAppendTable(db_connection, table_name, table)
    dbUnlock(db_connection, log, lock_id)
  }
  # Calculate and print duration of operation
  duration <- difftime(Sys.time(), time0, units = 'secs')
  print(paste0('Inserted in ', table_name, ', ', row_count, ' rows (took ', duration, ' seconds)'))
}

#' Delete All Rows from a Database Table
#'
#' This function deletes all rows from a specified table in the database. It is designed to
#' work with PostgreSQL databases, where table names are case-sensitive and typically lower case.
#' The function converts the provided table name to lower case before executing the delete operation.
#'
#' @param db_connection A database connection object created by `DBI::dbConnect` or a similar
#'                      DBI connection function. This connection should be active and valid for
#'                      the deletion to work.
#' @param table_name The name of the table from which all rows should be deleted. The table name
#'                   will be converted to lower case to comply with PostgreSQL naming conventions.
#' @param log A logical value indicating whether the SQL statement should be logged to the console.
#'        Default is TRUE.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#'
#' @return An integer value indicating the number of rows affected by the delete operation. For
#'         a successful deletion, this will be the number of rows that were in the table prior
#'         to deletion.
#'
#' @export
dbDeleteContent <- function(db_connection, table_name, log = TRUE, lock_id = NULL) {
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  dbLock(db_connection, log, lock_id)
  DBI::dbExecute(db_connection, paste0('DELETE FROM ', table_name, ';'))
  dbUnlock(db_connection, log, lock_id)
}

#' Execute a SQL Statement on a Database Connection
#'
#' This function executes a given SQL statement on a specified database connection.
#'
#' @param db_connection A database connection object.
#' @param statement A string representing the SQL statement to be executed.
#' @param log logical value indicating whether the statement should be logged to the console.
#' Default is TRUE.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#'
#' @return The number of rows affected by the SQL statement.
#'
#' @export
dbExecute <- function(db_connection, statement, log = TRUE, lock_id = NULL) {
  if (log) {
    cat(paste0("dbExecute:\n", statement, "\n"))
  }
  dbLock(db_connection, log, lock_id)
  DBI::dbExecute(db_connection, statement)
  dbUnlock(db_connection, log, lock_id)
}

#' Execute a SQL Query on a Database Connection
#'
#' This function executes a given SQL query on a specified database connection. It allows for the
#' optional logging of the query to the console and supports parameterized queries using the `params` argument.
#'
#' @param db_connection A database connection object.
#' @param query A string representing the SQL query to be executed.
#' @param log Logical value indicating whether the query should be logged to the console. Default is TRUE.
#' @param params A list of parameters to be safely inserted into the SQL query, allowing for parameterized queries.
#' If NA, no parameters will be used. This is useful for preventing SQL injection and handling dynamic query inputs.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#' @param readonly Logical value indicating whether the database was changed with the query. This should
#' be used to trigger a database internal cron job which copies the changed data in the database core.
#' If the query has not changed anything then set this paramter to TRUE to prevent the expensive cron
#' job execution.
#'
#' @return The result of the SQL query as a data.table.
#'
#' @export
dbGetQuery <- function(db_connection, query, params = NULL, log = TRUE, lock_id = NULL, readonly = FALSE) {
  if (log) {
    cat(paste0("dbGetQuery:\n", query, "\n"))
  }
  dbLock(db_connection, log, lock_id)
  table <- data.table::as.data.table(DBI::dbGetQuery(db_connection, query, params = params))
  dbUnlock(db_connection, log, lock_id, readonly)
  return(table)
}

#' Read a Table from a PostgreSQL Database
#'
#' This function reads a table from a PostgreSQL database and returns it as a data table.
#' PostgreSQL only accepts lower case table names, so the table name is converted to lower case.
#'
#' @param db_connection A DBI connection object to the PostgreSQL database.
#' @param table_name A character string specifying the name of the table to read.
#'        The table name will be converted to lower case.
#' @param log A logical value indicating whether the SQL statement should be logged to the console.
#'        Default is TRUE.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#'
#' @return A data table containing the contents of the specified table.
#'
#' @examples
#' \dontrun{
#'   con <- DBI::dbConnect(RPostgres::Postgres(), dbname = "your_database_name", host = "your_host",
#'                         port = 5432, user = "your_username", password = "your_password")
#'   dt <- dbReadTable(con, "YourTableName")
#'   print(head(dt))
#'   DBI::dbDisconnect(con)
#' }
#' @export
dbReadTable <- function(db_connection, table_name, log = TRUE, lock_id = NULL) {
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  dbLock(db_connection, log, lock_id)

  table <- data.table::as.data.table(DBI::dbReadTable(db_connection, table_name))
  dbUnlock(db_connection, log, lock_id, readonly = TRUE)
  return(table)
}

#' Check if a Database Table is Empty
#'
#' This function checks if a specified table in the database is empty by
#' executing a SQL query that counts the number of rows in the table.
#'
#' @param db_connection A database connection object created using `DBI::dbConnect()`.
#' @param table_name A character string specifying the name of the table to check.
#' @param log A logical value indicating whether the SQL statement should be logged to the console.
#'        Default is TRUE.
#'
#' @return A logical value: `TRUE` if the table is empty, `FALSE` otherwise.
#'
dbIsTableEmpty <- function(db_connection, table_name, log = TRUE) {
  # SQL query to count rows in the table
  query <- paste0("SELECT COUNT(*) FROM ", table_name)
  if (log) {
    cat(paste0("dbIsTableEmpty:\n", query, "\n"))
  }
  # Execute the query and fetch the result
  result <- dbGetQuery(db_connection, query, log = FALSE, readonly = TRUE)
  # Return TRUE if the count is 0, indicating the table is empty
  return(result[1, 1] == 0)
}

#' Write Multiple Tables to Database
#'
#' This function writes multiple data frames to specified tables within a database schema.
#' It includes an option to stop the process if any target table is not empty and an option
#' to close the database connection after execution.
#'
#' @param tables A named list of data frames representing the tables to be written to the database.
#'               Each list element name should correspond to the target database table name.
#' @param db_connection A connection object to the target database.
#' @param stop_if_table_not_empty A logical value indicating whether the function should stop if
#'                                any target database table is not empty. If `TRUE`, the function
#'                                checks each table and raises an error listing the tables that
#'                                are not empty. Default is `FALSE`.
#' @param close_db_connection A logical value indicating whether to close the database connection
#'                            after executing the function. Default is `FALSE`.
#' @param log A logical value indicating whether to log the database access steps
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#'
#' @return NULL. This function is used for its side effects of writing data to the database and,
#'         optionally, closing the connection.
#'
#' @details
#' - The function first checks if each table specified in `tables` exists in the database.
#' - If `stop_if_table_not_empty` is set to `TRUE`, the function verifies that each target
#'   table is empty before writing. If any table is not empty, an error is raised with a
#'   message listing these tables.
#' - If `stop_if_table_not_empty` is `FALSE`, the function proceeds to write data directly
#'   to the tables without checking.
#' - If `close_db_connection` is `TRUE`, the database connection will be closed at the end of the process.
#'
#' @export
writeTablesToDatabase <- function(tables, db_connection, stop_if_table_not_empty = FALSE, close_db_connection = FALSE, log = TRUE, lock_id = NULL) {
  table_names <- names(tables)
  db_table_names <- dbListTableNames(db_connection)

  # Stop with error if there are tables that do not exist in the database
  missing_db_table_names <- setdiff(table_names, db_table_names)
  if (length(missing_db_table_names) > 0) {
    stop(paste("The following tables are not found in the database. Perhaps the database was not initialized correctly?",
               paste(missing_db_table_names, collapse = "\n   ")))
  }

  # Restrict `table_names` to only those found in both `tables` and the database
  table_names <- intersect(table_names, db_table_names)

  # 1. Check if any tables are not empty when `stop_if_table_not_empty` is TRUE
  non_empty_tables <- c()
  if (stop_if_table_not_empty) {
    for (table_name in table_names) {
      if (!dbIsTableEmpty(db_connection, table_name)) {
        non_empty_tables <- c(non_empty_tables, table_name)
      }
    }

    # If there are non-empty tables, raise an error and list them
    if (length(non_empty_tables) > 0) {
      stop(paste("The following tables are not empty. The cron job may not have completed yet:\n   ",
                 paste(non_empty_tables, collapse = "\n   ")))
    }
  }

  dbLock(db_connection, log, lock_id)
  # 2. Write tables to DB (only if all tables are empty or if `stop_if_table_not_empty` is FALSE)
  for (table_name in table_names) {
    table <- tables[[table_name]]
    # Proceed with writing table data to the database
    dbCheckContent(db_connection, table_name, table)  # Check column widths
    dbAddContent(db_connection, table_name, table, log)    # Add table content
  }
  dbUnlock(db_connection, log, lock_id)

  if (close_db_connection) {
    dbDisconnect(db_connection)
  }
}

#' Write a Data Table to a Database
#'
#' This function writes a single data.table to a specified database. If the table name is not
#' provided, the function uses the name of the data.table variable. It includes an option to stop
#' the process if any target table is not empty and an option to close the database connection after
#' execution.
#'
#' @param table A data.table object to be written to the database.
#' @param db_connection A database connection to which the table should be written.
#' @param table_name A character string representing the name of the table in the database. If not provided,
#'                   the name of the data.table variable is used.
#' @param stop_if_table_not_empty A logical value indicating whether the function should stop if
#'                                any target database table is not empty. If `TRUE`, the function
#'                                checks each table and raises an error listing the tables that
#'                                are not empty. Default is `FALSE`.
#' @param close_db_connection If TRUE, the database connection will be closed at the end of the
#'                            process. Default is FALSE.
#' @param log A logical value indicating whether the SQL statement should be logged to the console.
#'        Default is TRUE.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#'
#' @return NULL. The function is used for its side effects of writing data to the database.
#'
#' @export
writeTableToDatabase <- function(table, db_connection, table_name = NA, stop_if_table_not_empty = FALSE, close_db_connection = FALSE, log = TRUE, lock_id = NULL) {
  if (is.na(table_name)) {
    table_name <- as.character(sys.call()[2]) # get the table variable name
  }
  tables <- list(table)
  names(tables) <- table_name
  writeTablesToDatabase(tables, db_connection, stop_if_table_not_empty, close_db_connection, log = log, lock_id = lock_id)
}

#' Read Multiple Tables from Database
#'
#' This function reads multiple tables from a specified database connection. If no table names are
#' provided, it reads all available tables in the schema.
#'
#' @param db_connection A database connection from where the tables should be read.
#' @param table_names A character vector of table names to read. If NA(default), all tables are
#' read.
#' @param close_db_connection If TRUE the database connection will be closed at the end of the
#' process. Default is FALSE.
#' @param log A logical value indicating whether the SQL statement should be logged to the console.
#'        Default is TRUE.
#' @param lock_id A string representation as ID for the process to lock the database during the
#' access under this name
#'
#' @return A named list of data frames representing the tables read from the database.
#'
#' @export
readTablesFromDatabase <- function(db_connection, table_names = NA, close_db_connection = FALSE, log = TRUE, lock_id = NULL) {
  db_table_names <- dbListTableNames(db_connection)
  if (isSimpleNA(table_names)) {
    table_names <- db_table_names
  }

  tables <- list()
  dbLock(db_connection, log, lock_id)
  for (table_name in table_names) {
    # If the database tables here are tables of a View, then they have (per convention) the prefix
    # "v_" -> add this prefix in this cases
    if (!table_name %in% db_table_names) {
      table_name <- paste0("v_", table_name)
    }
    if (grepl("^v_", table_name)) {
      resource_table_name <- sub("^v_", "", table_name)
    }
    tables[[resource_table_name]] <- dbReadTable(db_connection, table_name)
  }
  dbUnlock(db_connection, log, lock_id, readonly = TRUE)
  dbUnlock(db_connection, lock_id, readonly = TRUE)
  dbDisconnect(db_connection)
  return(tables)
}

#' Prints Database Timezone and Current Time
#'
#' This function prints the current timezone and the current time from the connected PostgreSQL database.
#'
#' @param db_connection A DBI connection object to the PostgreSQL database.
#'
#' @return Prints the timezone and current time of the PostgreSQL database.
#'
#' @export
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

#' Get the current schema of the PostgreSQL connection
#'
#' This function retrieves the current schema of an active PostgreSQL connection
#' using the SQL query `SELECT current_schema();`. It returns the name of the
#' schema that is currently in use by the connection.
#'
#' @param db_connection A valid PostgreSQL connection object from the RPostgres package.
#' @param log A logical value indicating whether the SQL statement should be logged to the console.
#'        Default is TRUE.
#'
#' @return A string representing the name of the current schema.
#'
getCurrentSchema <- function(db_connection, log = TRUE) {
  # SQL query to retrieve the current schema
  query <- "SELECT current_schema();"
  if (log) {
    cat(paste0("getCurrentSchema:\n", query, "\n"))
  }
  # Execute the query and store the result
  result <- dbGetQuery(db_connection, query, log, readonly = TRUE)
  # Return the schema name from the first row and column
  return(result$current_schema[1])
}

#' Retrieve Database Table Columns
#'
#' This function retrieves the column names and their corresponding data types
#' for a specified table in the current schema of a PostgreSQL database.
#'
#' @param db_connection A database connection object. This connection must be established
#'   using an appropriate database driver.
#' @param table_name A character string representing the name of the table for
#'   which the column information is to be retrieved.
#' @param log A logical value indicating whether the SQL statement should be logged to the console.
#'        Default is TRUE.
#'
#' @return A data.frame containing two columns:
#'   \itemize{
#'     \item \code{column_name}: The names of the columns in the specified table.
#'     \item \code{data_type}: The corresponding PostgreSQL data types of the columns.
#'   }
#'
#' @export
#'
getDBTableColumns <- function(db_connection, table_name, log = TRUE) {
  # Get the current schema using the helper function
  schema <- getCurrentSchema(db_connection, log)
  # SQL query to retrieve column names and data types for the specified table in the current schema
  query <- paste0(
    "SELECT column_name, data_type
     FROM information_schema.columns
     WHERE table_name = '", table_name, "'
     AND table_schema = '", schema, "'"
  )
  if (log) {
    cat(paste0("getDBTableColumns:\n", query, "\n"))
  }
  # Execute the query and return the result as a data frame
  result <- dbGetQuery(db_connection, query, log, readonly = TRUE)
  return(result)
}

#' Convert Data Table Column types to Database column Types
#'
#' This function converts the columns of a data.table to specified types based on a PostgreSQL schema.
#'
#' @param dt A data.table object containing the data to be converted.
#' @param db_columns A data.frame or data.table containing the database schema with two columns:
#'   \itemize{
#'     \item \code{column_name}: The names of the columns in the data.table.
#'     \item \code{data_type}: The corresponding PostgreSQL data types to convert to, which can include
#'     "integer", "double precision", "character varying", "date", and "timestamp without time zone".
#'   }
#'
#' @return A data.table with columns converted to the specified database types.
#'
#' @export
convertToDBTypes <- function(dt, db_columns) {
  # Iterate over each column in the database schema
  for (i in seq_along(db_columns$column_name)) {
    col_name <- db_columns$column_name[i]
    db_type <- db_columns$data_type[i]

    # Check if the column exists in the data.table
    if (col_name %in% names(dt)) {
      # Convert the column type based on PostgreSQL type
      if (db_type == "integer") {
        # Convert to integer type
        dt[, (col_name) := as.integer(get(col_name))]
      } else if (db_type == "double precision") {
        # Convert to numeric type
        dt[, (col_name) := as.numeric(get(col_name))]
      } else if (db_type == "character varying") {
        # Convert to character type
        dt[, (col_name) := as.character(get(col_name))]
      } else if (db_type == "date") {
        # Convert to Date type
        dt[, (col_name) := as.Date(get(col_name))]
      } else if (db_type == "timestamp without time zone") {
        # Convert to POSIXct (datetime) type
        dt[, (col_name) := as.POSIXct(get(col_name))]
      }
    }
  }
  return(dt)
}

#' Retrieve detailed database connection information as a formatted log message
#'
#' This function serves as a wrapper for `DBI::dbGetInfo` to provide additional
#' PostgreSQL-specific connection details. It combines standard connection
#' metadata with additional information retrieved via SQL queries for PostgreSQL
#' connections. The result is returned as a formatted string suitable for logging.
#'
#' @param db_connection A DBI database connection object.
#'
#' @return A character string containing formatted connection details.
#'
dbGetInfo <- function(db_connection) {
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

