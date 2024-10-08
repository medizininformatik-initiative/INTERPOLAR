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
dbCheckContent <- function(db_connection, table_name, table) {
  # Convert table name to lowercase for PostgreSQL compatibility
  table_name <- tolower(table_name)

  # Construct SQL query to retrieve column widths
  sql_query <- paste0("SELECT column_name, character_maximum_length
                     FROM information_schema.columns
                     WHERE table_name = '", table_name, "'")

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
#'
#' @export
dbAddContent <- function(db_connection, table_name, table) {
  # Convert table name to lower case for PostgreSQL
  table_name <- tolower(table_name)
  # Measure start time
  time0 <- Sys.time()
  # Get row count for reporting
  row_count <- nrow(table)
  if (row_count > 0) {
    # Append table content
    db_insert_result <- RPostgres::dbAppendTable(db_connection, table_name, table)
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
#'
#' @return An integer value indicating the number of rows affected by the delete operation. For
#'         a successful deletion, this will be the number of rows that were in the table prior
#'         to deletion.
#'
#' @export
dbDeleteContent <- function(db_connection, table_name) {
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  DBI::dbExecute(db_connection, paste0('DELETE FROM ', table_name, ';'))
}

#' Execute a SQL Statement on a Database Connection
#'
#' This function executes a given SQL statement on a specified database connection.
#'
#' @param db_connection A database connection object.
#' @param statement A string representing the SQL statement to be executed.
#' @param log logical value indicating whether the statement should be logged to the console.
#' Default is TRUE.
#'
#' @return The number of rows affected by the SQL statement.
#'
#' @export
dbExecute <- function(db_connection, statement, log = TRUE) {
  if (log) {
    cat(statement, "\n")
  }
  DBI::dbExecute(db_connection, statement)
}

#' Execute a SQL Query on a Database Connection
#'
#' This function executes a given SQL query on a specified database connection.
#'
#' @param db_connection A database connection object.
#' @param query A string representing the SQL query to be executed.
#' @param log logical value indicating whether the statement should be logged to the console.
#' Default is TRUE.
#'
#' @return The result of the SQL query.
#'
#' @export
dbGetQuery <- function(db_connection, query, log = TRUE) {
  if (log) {
    cat(query, "\n")
  }
  data.table::as.data.table(DBI::dbGetQuery(db_connection, query))
}

#' Execute a SQL Query on a Database with Automatic Connection Management
#'
#' This function establishes a database connection using the provided credentials,
#' executes the specified SQL query, and then disconnects from the database.
#'
#' @param dbname A string representing the name of the database.
#' @param host A string representing the database host.
#' @param port An integer representing the port number to connect to.
#' @param user A string representing the username for authentication.
#' @param password A string representing the password for authentication.
#' @param schema A string representing the schema to be used within the database.
#' @param query A string representing the SQL query to be executed.
#' @param log A logical value indicating whether the SQL statement should be logged to the console.
#' Default is TRUE.
#'
#' @return A data.table containing the result of the SQL query.
#'
#' @export
dbConnectAndGetQuery <- function(dbname, host, port, user, password, schema, query, log = TRUE) {
  db_connection <- dbConnect(dbname, host, port, user, password, schema)
  result <- dbGetQuery(db_connection, query, log)
  dbDisconnect(db_connection)
  return(result)
}

#' Read a Table from a PostgreSQL Database
#'
#' This function reads a table from a PostgreSQL database and returns it as a data table.
#' PostgreSQL only accepts lower case table names, so the table name is converted to lower case.
#'
#' @param db_connection A DBI connection object to the PostgreSQL database.
#' @param table_name A character string specifying the name of the table to read.
#'        The table name will be converted to lower case.
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
dbReadTable <- function(db_connection, table_name) {
  # Postgres only accepts lower case names -> convert them hard here
  table_name <- tolower(table_name)
  data.table::as.data.table(DBI::dbReadTable(db_connection, table_name))
}

#' Write Multiple Tables to Database
#'
#' This function writes multiple tables to a specified database schema. It can optionally clear
#' existing content before inserting new data.
#'
#' @param tables A named list of data frames representing the tables to be written to the database.
#' @param dbname A string representing the name of the database.
#' @param host A string representing the database host.
#' @param port An integer representing the port number to connect to the database.
#' @param user A string representing the database user name.
#' @param password A string representing the database user password.
#' @param schema A string representing the database schema.
#' @param clear_before_insert A logical value indicating whether to clear existing data in the
#' tables before inserting new data. Default is FALSE.
#'
#' @return NULL. The function is used for its side effects of writing data to the database.
#'
#' @examples
#' \dontrun{
#' tables <- list(
#'   table1 = data.frame(col1 = 1:3, col2 = letters[1:3]),
#'   table2 = data.frame(col1 = 4:6, col2 = letters[4:6])
#' )
#' writeTablesTablesToDatabase(
#'   tables,
#'   dbname = "dbname",
#'   host = "host",
#'   port = 5432,
#'   user = "user",
#'   password = "password",
#'   schema = "schema"
#' )
#' }
#'
#' @export
createConnectionAndWriteTablesToDatabase <- function(tables, dbname, host, port, user, password, schema, clear_before_insert = FALSE) {
  db_connection <- dbConnect(dbname, host, port, user, password, schema)
  writeTablesToDatabase(tables, db_connection, clear_before_insert, close_db_connection = TRUE)
}

#' Write Multiple Tables to Database
#'
#' This function writes multiple tables to a specified database schema. It can optionally clear
#' existing content before inserting new data.
#'
#' @param tables A named list of data frames representing the tables to be written to the database.
#' @param db_connection A database connection from where the tables should be read.
#' @param clear_before_insert A logical value indicating whether to clear existing data in the
#' tables before inserting new data. Default is FALSE.
#' @param close_db_connection If TRUE the database connection will be closed at the end of the
#'                            process. Default is FALSE.
#'
#' @return NULL. The function is used for its side effects of writing data to the database.
#'
#' @export
writeTablesToDatabase <- function(tables, db_connection, clear_before_insert = FALSE, close_db_connection = FALSE) {
  table_names <- names(tables)
  db_table_names <- dbListTableNames(db_connection)

  # write tables to DB
  for (table_name in table_names) {
    if (table_name %in% db_table_names) {
      table <- tables[[table_name]]
      if (clear_before_insert) {
        dbDeleteContent(db_connection, table_name)
      }
      # Check column widths of table content
      dbCheckContent(db_connection, table_name, table)
      # Add table content to DB
      dbAddContent(db_connection, table_name, table)
    } else {
      warning(paste("Table", table_name, "not found in database"))
    }
  }
  if (close_db_connection) {
    dbDisconnect(db_connection)
  }
}

#' Write a Data Table to a Database
#'
#' This function writes a single data.table to a specified database. If the table name is not
#' provided, the function uses the name of the data.table variable. The user can choose to clear
#' existing table contents before writing new data by setting `clear_before_insert` to TRUE.
#'
#' @param table A data.table object to be written to the database.
#' @param db_connection A database connection to which the table should be written.
#' @param table_name A character string representing the name of the table in the database. If not provided,
#'                   the name of the data.table variable is used.
#' @param clear_before_insert A logical flag indicating whether to clear the table contents
#'                            before inserting new data. Defaults to FALSE.
#' @param close_db_connection If TRUE, the database connection will be closed at the end of the
#'                            process. Default is FALSE.
#'
#' @return NULL. The function is used for its side effects of writing data to the database.
#'
#' @export
writeTableToDatabase <- function(table, db_connection, table_name = NA, clear_before_insert = FALSE, close_db_connection = FALSE) {
  if (is.na(table_name)) {
    table_name <- as.character(sys.call()[2]) # get the table variable name
  }
  tables <- list(table)
  names(tables) <- table_name
  writeTablesToDatabase(tables, db_connection, clear_before_insert, close_db_connection)
}

#' Read Multiple Tables from Database
#'
#' This function reads multiple tables from a specified database schema. If no table names are provided,
#' it reads all available tables in the schema.
#'
#' @param dbname A string representing the name of the database.
#' @param host A string representing the database host.
#' @param port An integer representing the port number to connect to the database.
#' @param user A string representing the database user name.
#' @param password A string representing the database user password.
#' @param schema A string representing the database schema.
#' @param table_names A character vector of table names to read. If NA, all tables are read.
#'
#' @return A named list of data frames representing the tables read from the database.
#'
#' @examples
#' \dontrun{
#' tables <- readTablesFromDatabase(
#'   dbname = "dbname",
#'   host = "host",
#'   port = 5432,
#'   user = "user",
#'   password = "password",
#'   schema = "schema"
#' )
#' }
#'
#' @export
createConnectionAndReadTablesFromDatabase <- function(dbname, host, port, user, password, schema, table_names = NA) {
  db_connection <- dbConnect(dbname, host, port, user, password, schema)
  readTablesFromDatabase(db_connection, table_names, TRUE)
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
#'
#' @return A named list of data frames representing the tables read from the database.
#'
#' @export
readTablesFromDatabase <- function(db_connection, table_names = NA, close_db_connection = FALSE) {

  db_table_names <- dbListTableNames(db_connection)
  if (isSimpleNA(table_names)) {
    table_names <- db_table_names
  }

  tables <- list()
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
