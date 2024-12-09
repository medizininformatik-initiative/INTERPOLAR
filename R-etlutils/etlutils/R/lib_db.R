# Environment for saving the connections
.lib_db_env <- new.env()

#' Retrieve the First Value from a SQL Query Result
#'
#' This function executes a query on a given database connection and extracts the first value
#' from the result. If the query returns multiple rows or columns, the value in the first row
#' and column is returned. If the result is empty, `NULL` is returned.
#'
#' The query is executed in read-only mode by default to ensure no changes are made to the database.
#'
#' @param db_connection A valid database connection object used to execute the query.
#' @param query A character string representing the SQL query to execute.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, messages about the query execution
#'        are logged to the console. Default is `TRUE`.
#' @param project_name A string representing the name of the project to check for a lock.
#'
#' @return The first value from the query result, or `NULL` if the result is empty.
#'
dbGetSingleValue <- function(db_connection, query, log = TRUE, project_name = NULL) {
  status <- dbGetQuery(db_connection, query, log = log, project_name = project_name, readonly = TRUE)
  if (!is.null(status)) status <- status[1, ][[1]] # the functions answer is a table with 1 row and 1 column
}

#' Retrieve the Current Semaphore Status from the Database
#'
#' This function retrieves the current semaphore status from the database by executing
#' a predefined SQL query. The query is hardcoded and does not accept parameters. Internally,
#' the function uses `dbGetSingleValue` to extract the first value from the query result.
#'
#' If the query result is empty, the function returns `NULL`.
#'
#' @param db_connection A database connection object used to execute the query.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, messages about the query execution
#'        are logged to the console. Default is `TRUE`.
#'
#' @return A character string representing the current semaphore status in the database, or `NULL`
#'         if no status is available.
#'
dbGetStatus <- function(db_connection, log = TRUE) {
  dbGetSingleValue(db_connection, "SELECT db.data_transfer_status();", log)
}

#' Check Database Semaphore Status
#'
#' This function checks whether the current database semaphore status starts with a specified
#' status prefix. It retrieves the status using `dbGetStatus` and performs a case-insensitive
#' comparison against the provided prefix.
#'
#' @param db_connection A database connection object used to query the database.
#' @param status_prefix A string specifying the prefix to check against the current database status.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs the current database
#'        status to the console. Default is `TRUE`.
#'
#' @return A logical value (`TRUE` or `FALSE`), indicating whether the database status starts
#'         with the given `status_prefix`.
#'
dbHasStatus <- function(db_connection, status_prefix, log = TRUE) {
  status <- dbGetStatus(db_connection, log)
  if (log) cat("Current database status:", status, "\n")
  return(startsWith(tolower(status), tolower(status_prefix)))
}

#' Get Name of Module That Set the Database Semaphore
#'
#' This function retrieves the name of the module that set the current semaphore (lock) in the
#' database by executing a predefined SQL query. Internally, it uses `dbGetSingleValue` to
#' extract the result.
#'
#' @param db_connection A database connection object used to query the database.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs messages about
#'        the query execution to the console. Default is `TRUE`.
#'
#' @return A character string representing the name of the module that set the semaphore, or
#'         `NULL` if no module is found.
#'
#' @export
dbGetLockModule <- function(db_connection, log = TRUE) {
  dbGetSingleValue(db_connection, "select db.data_transfer_get_lock_module();", log)
}

#' Check for a Lock in the Database by Module
#'
#' This function checks whether the database is locked by a specified module (project) by
#' comparing the current lock module name with the given project name. It retrieves the lock
#' module name using `dbGetLockModule`.
#'
#' @param db_connection A database connection object used to query the database.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs messages about
#'        the query execution to the console. Default is `TRUE`.
#' @param project_name A string representing the name of the project to check for a lock.
#'
#' @return A logical value (`TRUE` or `FALSE`), indicating whether the specified project holds
#'         the lock in the database.
#'
#' @export
dbIsLockedBy <- function(db_connection, log = TRUE, project_name) {
  dbGetLockModule(db_connection, log) == project_name
}

#' Lock a Database for Write Access
#'
#' This function locks the database for write access using a specified lock ID. It ensures proper
#' management of recursive lock attempts and waits for the database to become ready before applying
#' the lock. The function recursively retries locking if the initial attempt fails, up to a
#' maximum depth.
#'
#' @param db_connection A database connection object used to interact with the database.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs messages about
#'        the locking process to the console. Default is `TRUE`.
#' @param project_name A string representing the name of the project for which the lock is applied.
#' @param lock_id A string specifying the unique identifier for the lock. If `NULL`, no locking
#'        is performed.
#'
#' @return The function does not return a value. It either successfully locks the database or
#'         throws an error if locking fails due to excessive recursive attempts or other issues.
#'
dbLock <- function(db_connection, log = TRUE, project_name, lock_id) {
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
    while (!dbHasStatus(db_connection, "ReadyToConnect", log)) {
      Sys.sleep(4) # wait for 4 seconds
      # TODO alle Minute eine Rückmeldung geben "Warte immer noch darauf, die DB locken zu dürfen..."
    }

    lock_sucessful <- dbGetSingleValue(db_connection, paste0("SELECT db.data_transfer_stop('", project_name, "', '", lock_id, "');"), log, project_name)
    if (log) {
      status <- dbGetStatus(db_connection, log)
      cat(paste("DB lock sucessfull =", lock_sucessful, "with status on lock:", status, "\n"))
    }
    if (!lock_sucessful) {
      dbLock(db_connection, log, project_name, lock_id)
    }

    # decrease the recursive call counter 'db_lock_depth'
    .lib_db_env[[lock_id]] <- .lib_db_env[[lock_id]] - 1

    #stop("Testerror")

  }
}

#' Unlock a Database for Read or Write Access
#'
#' This function unlocks the database using a specified lock ID. It ensures proper handling of
#' read-only or read-write access during the unlocking process. If unlocking fails, an error is thrown
#' with detailed information about the current database status.
#'
#' @param db_connection A database connection object used to interact with the database.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs messages about
#'        the unlocking process to the console. Default is `TRUE`.
#' @param project_name A string representing the name of the project associated with the lock.
#' @param lock_id A string specifying the unique identifier for the lock. If `NULL`, no unlocking
#'        is performed.
#' @param readonly A logical value (`TRUE` or `FALSE`). If `TRUE`, the database is unlocked in
#'        read-only mode. Default is `FALSE`.
#'
#' @return A logical value (`TRUE` or `FALSE`), indicating whether the unlocking was successful.
#'
dbUnlock <- function(db_connection, log = TRUE, project_name, lock_id, readonly = FALSE) {
  unlock_sucessful = FALSE
  if (!is.null(lock_id)) {
    if (log) {
      cat(paste0("Try to unlock database with lock_id: '", lock_id, "' and readonly: ", readonly, "\n"))
    }
    unlock_request <- paste0("SELECT db.data_transfer_start('", project_name, "', '", lock_id, "', ", readonly, ");")
    unlock_sucessful <- dbGetSingleValue(db_connection, unlock_request, log, project_name)
    if (log) {
      status <- dbGetStatus(db_connection, log)
      cat("Current database status:", status, "\n")
    }
    if (!unlock_sucessful) {
      status <- dbGetStatus(db_connection, log, project_name)
      stop("Could not unlock the database for lock_id:\n",
           lock_id, "\n",
           "The current status is: " , status, "\n",
           dbGetInfo(db_connection))
    }
  }
  return(unlock_sucessful)
}

#' Forcefully Reset a Database Lock for a Project
#'
#' This function forcibly resets the database lock for a specified project by checking the
#' current semaphore status and issuing a hard reset if the project lock is active. If no lock
#' is present, it logs a message instead of performing any action.
#'
#' @param db_connection A database connection object used to interact with the database.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs messages about
#'        the reset process to the console. Default is `TRUE`.
#' @param project_name A string representing the name of the project whose lock should be reset.
#'
#' @return A logical value (`TRUE` or `FALSE`), indicating whether the reset was successful.
#'
#' @export
dbResetLock <- function(db_connection, log = TRUE, project_name) {
  unlock_sucessful <- FALSE
  if (dbIsLockedBy(db_connection, log, project_name)) {
    unlock_request <- paste0("SELECT db.data_transfer_reset_lock('", project_name, "');")
    unlock_sucessful <- dbGetSingleValue(db_connection, unlock_request, log, project_name)
    if (!unlock_sucessful) {
      status <- dbGetStatus(db_connectionm, log, project_name)
      stop("Could not reset database lock for module:\n",
           project_name, "\n",
           "The current status is: " , status, "\n",
           dbGetInfo(db_connection))
    }
  }
  if (log) {
    if (unlock_sucessful) {
      cat(paste("Reset database lock of module", project_name, "\n"))
    } else {
      cat(paste("No database lock to remove for module", project_name, "\n"))
    }
  }
  return(unlock_sucessful)
}

#' Create a Lock ID
#'
#' This function generates a lock ID by combining a project name with a variable number of
#' arguments for the lock ID message. The arguments are concatenated and prefixed with the
#' project name, separated by a colon (`:`).
#'
#' @param project_name A string representing the name of the project.
#' @param ... A variable number of strings to be concatenated as the lock ID message.
#'
#' @return A character string representing the combined lock ID in the format
#'         `<project_name>:<lock_id_message>`.
#'
#' @export
createLockID <- function(project_name, ...) {
  lock_id_message <- paste0(...)
  paste0(project_name, ":", lock_id_message)
}

#' Establish a Connection to a PostgreSQL Database
#'
#' This function establishes a connection to a PostgreSQL database using the specified credentials
#' and settings. It configures the connection to use a specific schema and adjusts the `work_mem`
#' setting to enhance performance for memory-intensive operations.
#'
#' @param dbname A string specifying the name of the database.
#' @param host A string specifying the host address where the database is located.
#' @param port An integer specifying the port number for the database connection.
#' @param user A string specifying the username for the database connection.
#' @param password A string specifying the password for the database connection.
#' @param schema A string specifying the schema under which the tables can be found. This sets
#'        the search path to the specified schema.
#'
#' @return A database connection object configured to use the specified schema and with an increased
#'         `work_mem` setting.
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
#' This function closes an active database connection. It serves as a wrapper around
#' `DBI::dbDisconnect` and ensures that the connection is properly terminated to free up resources.
#'
#' @param db_connection A valid database connection object created by `DBI::dbConnect` or
#'        a similar DBI connection function.
#'
#' @return Invisible `TRUE` if the disconnection was successful; otherwise, an error is thrown.
#'
#' @seealso \code{\link[DBI]{dbDisconnect}} for the underlying DBI function.
#'
#' @export
dbDisconnect <- function(db_connection) {
  DBI::dbDisconnect(db_connection)
}

#' Check Database Connection Validity
#'
#' This function checks if a given database connection is still valid (open). It serves as a
#' wrapper around `DBI::dbIsValid` and simplifies the process of verifying the connection status.
#'
#' @param db_connection A valid database connection object created by `DBI::dbConnect` or
#'        a similar DBI connection function.
#'
#' @return A logical value: `TRUE` if the connection is valid (open), otherwise `FALSE`.
#'
#' @seealso \code{\link[DBI]{dbIsValid}} for the underlying DBI function.
#'
#' @export
dbIsValid <- function(db_connection) {
  DBI::dbIsValid(db_connection)
}

#' List Table Names in a Database
#'
#' This function retrieves and displays the list of existing table names in the database connected
#' through the provided connection. It provides a quick overview of the database structure.
#'
#' @param db_connection A valid database connection object, typically created using `DBI::dbConnect`.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the table names are logged to the
#'        console. Default is `TRUE`.
#'
#' @return A character vector containing the names of the tables in the connected database.
#'
#' @seealso \code{\link[DBI]{dbListTables}} for the underlying DBI function used to retrieve table names.
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

#' Check Column Widths of a Table in a PostgreSQL Database
#'
#' This function checks whether the content of a specified table exceeds the maximum allowed
#' column widths defined in the PostgreSQL schema. It retrieves the column constraints from
#' `information_schema.columns` and verifies that the lengths of the table content adhere to these limits.
#'
#' @param db_connection A valid database connection object to the PostgreSQL database.
#' @param table_name A string specifying the name of the table to check. The name is converted
#'        to lowercase for PostgreSQL compatibility.
#' @param table A `data.table` representing the content of the table to be checked.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, details about the check are logged
#'        to the console. Default is `TRUE`.
#'
#' @return A logical value: `TRUE` if the table content meets the length constraints; otherwise,
#'         the function stops with an error message.
#'
#' @details The function iterates through each column and checks whether any values exceed the
#'          maximum length. For values exceeding the limit:
#'          - An error message is logged if the limit is small.
#'          - A truncation warning is logged if the limit is large, and the values are truncated.
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
#' This function inserts rows from a `data.table` or `data.frame` into a specified table in a
#' PostgreSQL database. The table name is converted to lowercase for PostgreSQL compatibility.
#' The function locks the database during the insertion process to ensure data consistency, then
#' unlocks it after the operation is complete.
#'
#' @param db_connection A valid database connection object, typically created using `DBI::dbConnect`.
#' @param table_name A string specifying the target table name in the PostgreSQL database.
#'                   The name is automatically converted to lowercase.
#' @param table A `data.table` or `data.frame` containing the rows to insert.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the operation details are logged
#'        to the console. Default is `TRUE`.
#' @param project_name A string representing the project associated with this database operation.
#' @param lock_id A string specifying the lock ID used during the database operation.
#'
#' @return The function does not return a value but logs details about the number of rows inserted
#'         and the time taken for the operation if `log = TRUE`.
#'
#' @details
#' - If the table contains rows (`nrow(table) > 0`), the rows are appended to the specified table.
#' - The database is locked before the insertion and unlocked afterward using the provided lock ID.
#' - The function logs the number of rows inserted and the duration of the operation.
#'
#' @export
dbAddContent <- function(db_connection, table_name, table, log = TRUE, project_name, lock_id = NULL) {
  # Convert table name to lower case for PostgreSQL
  table_name <- tolower(table_name)
  # Measure start time
  time0 <- Sys.time()
  # Get row count for reporting
  row_count <- nrow(table)
  if (row_count > 0) {
    # Append table content
    dbLock(db_connection, log, project_name, lock_id)
    RPostgres::dbAppendTable(db_connection, table_name, table)
    dbUnlock(db_connection, log, project_name, lock_id)
  }
  # Calculate and print duration of operation
  duration <- difftime(Sys.time(), time0, units = 'secs')
  if (log) {
    print(paste0('Inserted in ', table_name, ', ', row_count, ' rows (took ', duration, ' seconds)'))
  }
}

#' Delete All Rows from a PostgreSQL Table
#'
#' This function deletes all rows from a specified table in the PostgreSQL database. The table
#' name is converted to lowercase for PostgreSQL compatibility. The function locks the database
#' during the deletion process to ensure data consistency and unlocks it afterward.
#'
#' @param db_connection A valid database connection object created using `DBI::dbConnect`.
#' @param table_name A string specifying the name of the table from which all rows should be deleted.
#'                   The name is automatically converted to lowercase.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, details about the deletion operation
#'        are logged to the console. Default is `TRUE`.
#' @param project_name A string representing the project associated with this database operation.
#' @param lock_id A string specifying the lock ID used during the database operation.
#'
#' @return The function does not return a value but ensures all rows in the specified table are
#'         deleted.
#'
#' @details
#' - Locks the database before deletion and unlocks it afterward.
#' - Executes a `DELETE` SQL statement to remove all rows from the table.
#'
#' @export
dbDeleteContent <- function(db_connection, table_name, log = TRUE, project_name, lock_id = NULL) {
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  dbLock(db_connection, log, project_name, lock_id)
  DBI::dbExecute(db_connection, paste0('DELETE FROM ', table_name, ';'))
  dbUnlock(db_connection, log, project_name, lock_id)
}

#' Execute a SQL Statement on a Database Connection
#'
#' This function executes a given SQL statement on a specified PostgreSQL database connection.
#' It locks the database during the execution to ensure data consistency and unlocks it afterward.
#'
#' @param db_connection A valid database connection object.
#' @param statement A string representing the SQL statement to be executed.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the SQL statement is logged to the console.
#'        Default is `TRUE`.
#' @param project_name A string representing the project associated with this database operation.
#' @param lock_id A string specifying the lock ID used during the database operation.
#'
#' @return An integer value indicating the number of rows affected by the SQL statement.
#'
#' @details
#' - Locks the database before executing the SQL statement and unlocks it afterward.
#' - Logs the executed SQL statement if `log = TRUE`.
#'
#' @export
dbExecute <- function(db_connection, statement, log = TRUE, project_name, lock_id = NULL) {
  if (log) {
    cat(paste0("dbExecute:\n", statement, "\n"))
  }
  dbLock(db_connection, log, project_name, lock_id)
  DBI::dbExecute(db_connection, statement)
  dbUnlock(db_connection, log, project_name, lock_id)
}

#' Execute a SQL Query on a PostgreSQL Database
#'
#' This function executes a given SQL query on a specified PostgreSQL database connection.
#' It optionally logs the query, supports parameterized queries, and ensures data consistency by
#' locking and unlocking the database during execution.
#'
#' @param db_connection A valid database connection object.
#' @param query A string representing the SQL query to be executed.
#' @param params A list of parameters to be safely inserted into the SQL query, allowing for
#'        parameterized queries. Default is `NULL`.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the query is logged to the console.
#'        Default is `TRUE`.
#' @param project_name A string representing the project associated with this database operation.
#' @param lock_id A string specifying the lock ID used during the database operation.
#' @param readonly A logical value (`TRUE` or `FALSE`). If `TRUE`, the database remains in read-only
#'        mode after the operation. Default is `FALSE`.
#'
#' @return A `data.table` containing the results of the query.
#'
#' @details
#' - Locks the database before executing the query and unlocks it afterward.
#' - Supports dynamic queries with the `params` argument to prevent SQL injection.
#' - Converts the query result into a `data.table` for ease of use.
#'
#' @export
dbGetQuery <- function(db_connection, query, params = NULL, log = TRUE, project_name = NULL, lock_id = NULL, readonly = FALSE) {
  if (log) {
    cat(paste0("dbGetQuery:\n", query, "\n"))
  }
  dbLock(db_connection, log, project_name, lock_id)
  table <- data.table::as.data.table(DBI::dbGetQuery(db_connection, query, params = params))
  dbUnlock(db_connection, log, project_name, lock_id, readonly)
  return(table)
}

#' Read a Table from a PostgreSQL Database
#'
#' This function reads a table from a PostgreSQL database and returns it as a `data.table`.
#' It ensures compatibility with PostgreSQL by converting the table name to lowercase. The
#' database is locked during the read operation and unlocked afterward.
#'
#' @param db_connection A valid database connection object.
#' @param table_name A string specifying the name of the table to read. The table name will
#'        be converted to lowercase.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, details about the read operation
#'        are logged to the console. Default is `TRUE`.
#' @param project_name A string representing the project associated with this database operation.
#' @param lock_id A string specifying the lock ID used during the database operation.
#'
#' @return A `data.table` containing the contents of the specified table.
#'
#' @details
#' - Locks the database before reading the table and unlocks it afterward.
#' - Converts the table name to lowercase to comply with PostgreSQL's case sensitivity rules.
#'
#' @export
dbReadTable <- function(db_connection, table_name, log = TRUE, project_name, lock_id = NULL) {
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  dbLock(db_connection, log, project_name, lock_id)

  table <- data.table::as.data.table(DBI::dbReadTable(db_connection, table_name))
  dbUnlock(db_connection, log, project_name, lock_id, readonly = TRUE)
  return(table)
}

#' Check if a PostgreSQL Table is Empty
#'
#' This function checks whether a specified table in a PostgreSQL database contains any rows.
#' It executes a `COUNT(*)` query on the table and evaluates whether the count is zero.
#'
#' @param db_connection A valid database connection object.
#' @param table_name A string specifying the name of the table to check.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the SQL query is logged to the console.
#'        Default is `TRUE`.
#' @param project_name A string representing the name of the project whose lock should be reset.
#'
#' @return A logical value: `TRUE` if the table is empty, `FALSE` otherwise.
#'
#' @details
#' - The function executes a `SELECT COUNT(*)` query to determine the number of rows in the table.
#' - If the query returns zero, the function returns `TRUE`; otherwise, it returns `FALSE`.
#'
#' @export
dbIsTableEmpty <- function(db_connection, table_name, log = TRUE, project_name) {
  # SQL query to count rows in the table
  query <- paste0("SELECT COUNT(*) FROM ", table_name)
  if (log) {
    cat(paste0("dbIsTableEmpty:\n", query, "\n"))
  }
  # Execute the query and fetch the result
  result <- dbGetQuery(db_connection, query, log = FALSE, project_name = project_name, readonly = TRUE)
  # Return TRUE if the count is 0, indicating the table is empty
  return(result[1, 1] == 0)
}

#' Write Multiple Tables to a PostgreSQL Database
#'
#' This function writes multiple `data.table` or `data.frame` objects to specified tables in a
#' PostgreSQL database. It validates that the target tables exist and optionally checks if they
#' are empty before writing. The function can lock the database during the operation for consistency.
#'
#' @param tables A named list of `data.table` or `data.frame` objects to be written to the database.
#'        Each list element name corresponds to a target table name.
#' @param db_connection A valid database connection object.
#' @param stop_if_table_not_empty A logical value (`TRUE` or `FALSE`). If `TRUE`, the function stops
#'        execution if any target table is not empty. Default is `FALSE`.
#' @param close_db_connection A logical value (`TRUE` or `FALSE`). If `TRUE`, the database connection
#'        is closed after the operation. Default is `FALSE`.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs details about the
#'        operation to the console. Default is `TRUE`.
#' @param project_name A string representing the project associated with this database operation.
#' @param lock_id A string specifying the lock ID used during the database operation.
#'
#' @return `NULL`. The function is used for its side effects of writing data to the database.
#'
#' @details
#' - Validates the existence of all target tables in the database.
#' - Optionally stops the operation if `stop_if_table_not_empty` is `TRUE` and non-empty tables
#'   are detected.
#' - Writes the tables sequentially to their corresponding database tables.
#' - Optionally closes the database connection after the operation.
#'
#' @export
writeTablesToDatabase <- function(tables, db_connection, stop_if_table_not_empty = FALSE, close_db_connection = FALSE, log = TRUE, project_name, lock_id = NULL) {
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
      if (!dbIsTableEmpty(db_connection, table_name, log, project_name)) {
        non_empty_tables <- c(non_empty_tables, table_name)
      }
    }

    # If there are non-empty tables, raise an error and list them
    if (length(non_empty_tables) > 0) {
      stop(paste("The following tables are not empty. The cron job may not have completed yet:\n   ",
                 paste(non_empty_tables, collapse = "\n   ")))
    }
  }

  dbLock(db_connection, log, project_name, lock_id)
  # 2. Write tables to DB (only if all tables are empty or if `stop_if_table_not_empty` is FALSE)
  for (table_name in table_names) {
    table <- tables[[table_name]]
    # Proceed with writing table data to the database
    dbCheckContent(db_connection, table_name, table)  # Check column widths
    dbAddContent(db_connection, table_name, table, log)    # Add table content
  }
  dbUnlock(db_connection, log, project_name, lock_id)

  if (close_db_connection) {
    dbDisconnect(db_connection)
  }
}

#' Write a Single Table to a PostgreSQL Database
#'
#' This function writes a single `data.table` or `data.frame` to a specified table in a
#' PostgreSQL database. If no table name is provided, the name of the `data.table` variable
#' is used as the target table name. The function ensures data consistency by optionally
#' checking if the table is empty and locking the database during the operation.
#'
#' @param table A `data.table` or `data.frame` object to be written to the database.
#' @param db_connection A valid database connection object.
#' @param table_name A string specifying the target table name. If `NA`, the name of the
#'        `data.table` variable is used. Default is `NA`.
#' @param stop_if_table_not_empty A logical value (`TRUE` or `FALSE`). If `TRUE`, the function
#'        stops execution if the target table is not empty. Default is `FALSE`.
#' @param close_db_connection A logical value (`TRUE` or `FALSE`). If `TRUE`, the database
#'        connection is closed after the operation. Default is `FALSE`.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs details about
#'        the operation to the console. Default is `TRUE`.
#' @param lock_id A string specifying the lock ID used during the database operation.
#'
#' @return `NULL`. The function is used for its side effects of writing data to the database.
#'
#' @details
#' - If `table_name` is `NA`, the function extracts the variable name of the input `table` as
#'   the target table name.
#' - Ensures the table is empty if `stop_if_table_not_empty` is set to `TRUE`.
#' - Writes the `data.table` or `data.frame` to the target table in the database.
#' - Optionally closes the database connection after the operation.
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

#' Read Multiple Tables from a PostgreSQL Database
#'
#' This function reads multiple tables from a PostgreSQL database and returns them as a named list
#' of `data.table` objects. If no table names are specified, all tables in the database are read.
#' The function ensures compatibility with PostgreSQL by converting table names to lowercase
#' and handles views prefixed with `v_`.
#'
#' @param db_connection A valid database connection object.
#' @param table_names A character vector of table names to read. If `NA` (default), all tables
#'        in the database are read.
#' @param close_db_connection A logical value (`TRUE` or `FALSE`). If `TRUE`, the database
#'        connection is closed after the operation. Default is `FALSE`.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the function logs details about
#'        the operation to the console. Default is `TRUE`.
#' @param project_name A string representing the project associated with this database operation.
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
readTablesFromDatabase <- function(db_connection, table_names = NA, close_db_connection = FALSE, log = TRUE, project_name, lock_id = NULL) {
  db_table_names <- dbListTableNames(db_connection)
  if (isSimpleNA(table_names)) {
    table_names <- db_table_names
  }

  tables <- list()
  dbLock(db_connection, log, project_name, lock_id)
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
  dbUnlock(db_connection, log, project_name, lock_id, readonly = TRUE)
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

#' Get the Current Schema of a PostgreSQL Connection
#'
#' This function retrieves the current schema of an active PostgreSQL connection by executing
#' the query `SELECT current_schema();`.
#'
#' @param db_connection A valid database connection object to the PostgreSQL database.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the executed SQL query is logged
#'        to the console. Default is `TRUE`.
#' @param project_name A string representing the project associated with this database operation.
#'
#' @return A string representing the name of the current schema.
#'
#' @details
#' - Logs the executed query if `log = TRUE`.
#' - Uses the schema to identify tables and other database objects accessible in the connection.
#'
getCurrentSchema <- function(db_connection, log = TRUE, project_name) {
  # SQL query to retrieve the current schema
  query <- "SELECT current_schema();"
  if (log) {
    cat(paste0("getCurrentSchema:\n", query, "\n"))
  }
  # Execute the query and store the result
  result <- dbGetQuery(db_connection, query, params = NULL, log, project_name, lock_id = NULL, readonly = TRUE)
  # Return the schema name from the first row and column
  return(result$current_schema[1])
}

#' Retrieve Column Names and Data Types of a Database Table
#'
#' This function retrieves the column names and their corresponding data types for a specified
#' table in the current schema of a PostgreSQL database. It queries the `information_schema.columns`
#' system view to obtain this information.
#'
#' @param db_connection A valid database connection object to the PostgreSQL database.
#' @param table_name A string specifying the name of the table for which column information is retrieved.
#' @param log A logical value (`TRUE` or `FALSE`). If `TRUE`, the executed SQL query is logged to
#'        the console. Default is `TRUE`.
#' @param project_name A string representing the project associated with this database operation.
#'
#' @return A `data.frame` with two columns:
#'         - `column_name`: The names of the columns in the specified table.
#'         - `data_type`: The corresponding PostgreSQL data types of the columns.
#'
#' @details
#' - Retrieves column metadata from `information_schema.columns` for the current schema.
#' - Logs the executed SQL query if `log = TRUE`.
#'
#' @export
getDBTableColumns <- function(db_connection, table_name, log = TRUE, project_name) {
  # Get the current schema using the helper function
  schema <- getCurrentSchema(db_connection, log, project_name)
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
  result <- dbGetQuery(db_connection, query, params = NULL, log, project_name, lock_id = NULL, readonly = TRUE)
  return(result)
}

#' Convert Data Table Columns to PostgreSQL-Compatible Types
#'
#' This function converts the columns of a `data.table` to specified types based on a PostgreSQL
#' schema. It ensures that the data matches the database's expected column types, such as
#' integers, character strings, or timestamps.
#'
#' @param dt A `data.table` object containing the data to be converted.
#' @param db_columns A `data.frame` or `data.table` specifying the database schema, with the
#'        following columns:
#'        - `column_name`: The names of the columns in the data table.
#'        - `data_type`: The corresponding PostgreSQL data types, such as "integer",
#'          "character varying", "date", or "timestamp without time zone".
#'
#' @return A `data.table` with columns converted to the specified database-compatible types.
#'
#' @details
#' - Iterates through the columns of the input `data.table` and converts each to the specified type.
#' - Supports conversions to common PostgreSQL types, including integers, numeric values,
#'   character strings, dates, and timestamps.
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
#' @export
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

