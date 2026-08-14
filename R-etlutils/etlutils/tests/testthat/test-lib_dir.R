test_that("createDIRS creates a cache without a previous module run", {
  test_dir <- tempfile("etlutils-create-dirs-")
  dir.create(test_dir)
  old_working_directory <- setwd(test_dir)
  on.exit(setwd(old_working_directory), add = TRUE)

  module_dirs <- expect_no_warning(createDIRS("first_run"))

  expect_true(is.na(module_dirs[["last_local_dir"]]))
  expect_true(dir.exists(file.path("outputLocal", "first_run", "cache")))
})

test_that("createDIRS moves an existing cache to the next module run", {
  test_dir <- tempfile("etlutils-create-dirs-")
  dir.create(test_dir)
  old_working_directory <- setwd(test_dir)
  on.exit(setwd(old_working_directory), add = TRUE)

  createDIRS("repeated_run")
  cache_file <- file.path("outputLocal", "repeated_run", "cache", "cached-value.txt")
  writeLines("cached", cache_file)

  module_dirs <- expect_no_warning(createDIRS("repeated_run"))

  expect_true(dir.exists(module_dirs[["last_local_dir"]]))
  expect_true(file.exists(file.path("outputLocal", "repeated_run", "cache", "cached-value.txt")))
})
