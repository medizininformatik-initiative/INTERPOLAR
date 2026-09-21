test_that("dbWithLock preserves results, visibility and lock arguments", {
  events <- list()
  testthat::local_mocked_bindings(
    dbLock = function(lock_id) events[[length(events) + 1L]] <<- list("lock", lock_id),
    dbUnlock = function(lock_id, readonly) events[[length(events) + 1L]] <<- list("unlock", lock_id, readonly)
  )
  result <- withVisible(dbWithLock("test", TRUE, invisible(42L)))
  expect_identical(result, list(value = 42L, visible = FALSE))
  expect_identical(events, list(list("lock", "test"), list("unlock", "test", TRUE)))
})

test_that("dbWithLock preserves the original condition when unlocking fails", {
  original_error <- structure(list(message = "SQL failed", call = NULL), class = c("sql_error", "error", "condition"))
  testthat::local_mocked_bindings(
    dbLock = function(...) NULL,
    dbUnlock = function(...) stop("unlock failed")
  )
  expect_message(
    result <- tryCatch(dbWithLock("test", FALSE, stop(original_error)), error = identity),
    "Additionally failed to unlock database: unlock failed",
    fixed = TRUE
  )
  expect_identical(result, original_error)
  expect_error(dbWithLock("test", FALSE, 42L), "unlock failed", fixed = TRUE)
})

test_that("dbWithLock does not unlock after a failed lock or suppress operation errors", {
  unlocked <- FALSE
  testthat::local_mocked_bindings(
    dbLock = function(...) stop("lock failed"),
    dbUnlock = function(...) unlocked <<- TRUE
  )
  expect_error(dbWithLock("test", FALSE, stop("must not run")), "lock failed", fixed = TRUE)
  expect_false(unlocked)
  testthat::local_mocked_bindings(dbLock = function(...) NULL)
  expect_error(dbWithLock(NULL, FALSE, stop("SQL failed")), "SQL failed", fixed = TRUE)
  expect_true(unlocked)
})

test_that("database entry points retain SQL failures through nested cleanup", {
  testthat::local_mocked_bindings(
    dbLock = function(...) NULL,
    dbUnlock = function(lock_id, ...) {
      if (!is.null(lock_id)) stop("unlock failed")
    },
    dbLog = function(...) NULL,
    dbWithRetry = function(...) stop("SQL failed"),
    dbListTableNames = function(...) "test",
    dbGetReadOnlyColumns = function(...) character(),
    dbCheckColumsWidthBeforeWrite = function(...) NULL
  )
  operations <- list(
    function() dbExecute("SELECT broken", "test"),
    function() dbGetQuery("SELECT broken", lock_id = "test"),
    function() dbReadTable("test", "test"),
    function() dbReadTables("test", "test"),
    function() dbAddContent("test", data.table::data.table(id = 1L), "test"),
    function() dbWriteTables(list(test = data.table::data.table(id = 1L)), "test")
  )
  for (operation in operations) {
    expect_message(
      expect_error(operation(), "SQL failed", fixed = TRUE),
      "Additionally failed to unlock database: unlock failed",
      fixed = TRUE
    )
  }
})

test_that("database reads and writes retain successful results and unlock once", {
  unlocked <- list()
  testthat::local_mocked_bindings(
    dbLock = function(...) NULL,
    dbUnlock = function(lock_id, readonly) unlocked[[length(unlocked) + 1L]] <<- list(lock_id, readonly),
    dbLog = function(...) NULL,
    dbWithRetry = function(...) 3L
  )
  expect_identical(dbExecute("UPDATE test", "write"), 3L)
  expect_identical(dbGetQuery("SELECT test", lock_id = "read", readonly = TRUE), 3L)
  expect_identical(dbReadTable("TEST", "table"), 3L)
  expect_identical(unlocked, list(list("write", FALSE), list("read", TRUE), list("table", TRUE)))
})

test_that("dbReset retains a query error and closes its connection", {
  disconnected <- FALSE
  testthat::local_mocked_bindings(
    dbGetAdminConnection = function() "test connection",
    dbLock = function(...) NULL,
    dbUnlock = function(...) stop("unlock failed")
  )
  testthat::local_mocked_bindings(
    dbGetQuery = function(...) stop("SQL failed"),
    dbDisconnect = function(...) disconnected <<- TRUE,
    .package = "DBI"
  )
  expect_message(expect_error(dbReset(), "SQL failed", fixed = TRUE), "unlock failed", fixed = TRUE)
  expect_true(disconnected)
})

test_that("dbAddContent preserves normalization and logs before unlocking", {
  events <- character()
  testthat::local_mocked_bindings(
    dbGetReadOnlyColumns = function(...) "generated",
    dbLock = function(...) events <<- c(events, "lock"),
    dbUnlock = function(...) events <<- c(events, "unlock"),
    dbWithRetry = function(...) events <<- c(events, "append"),
    dbLog = function(...) events <<- c(events, "log")
  )
  table <- data.table::data.table(id = 1L, text = "", generated = 2L)
  dbAddContent("TEST", table, "test")
  expect_identical(names(table), c("id", "text"))
  expect_true(is.na(table$text))
  expect_identical(events, c("lock", "append", "log", "unlock"))
  events <- character()
  dbAddContent("TEST", table[0], "test")
  expect_identical(events, character())
})
