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

test_that("input repository paths resolve with and without a dot prefix", {
  test_dir <- tempfile("etlutils-input-repo-")
  input_repo_root <- file.path(test_dir, "Input-Repo")
  configured_path <- file.path(input_repo_root, "custom-source")
  target_dir <- file.path(configured_path, "LOINC_Mapping")
  sibling_target <- file.path(input_repo_root, "unused-copy", "LOINC_Mapping")
  dir.create(target_dir, recursive = TRUE)
  dir.create(sibling_target, recursive = TRUE)
  old_working_directory <- setwd(test_dir)
  on.exit(setwd(old_working_directory), add = TRUE)

  expect_equal(
    getInputRepoRootPath("Input-Repo/custom-source"),
    normalizePath(input_repo_root)
  )
  expect_equal(
    getInputRepoRootPath("./Input-Repo/custom-source"),
    normalizePath(input_repo_root)
  )
  expect_equal(
    findUniqueInputRepoPath("Input-Repo/custom-source", "LOINC_Mapping", "directory"),
    normalizePath(target_dir)
  )
})

test_that("input repository lookup falls back upwards and rejects ambiguity", {
  test_dir <- tempfile("etlutils-input-repo-")
  input_repo_root <- file.path(test_dir, "Input-Repo")
  configured_path <- file.path(input_repo_root, "configured", "nested")
  first_target <- file.path(input_repo_root, "source-a", "LOINC_Mapping")
  target_above_input_repo <- file.path(test_dir, "outside", "LOINC_Mapping")
  dir.create(configured_path, recursive = TRUE)
  dir.create(first_target, recursive = TRUE)
  dir.create(target_above_input_repo, recursive = TRUE)

  expect_equal(
    findUniqueInputRepoPath(configured_path, "LOINC_Mapping", "directory"),
    normalizePath(first_target)
  )

  second_target <- file.path(input_repo_root, "source-b", "LOINC_Mapping")
  dir.create(second_target, recursive = TRUE)
  expect_error(
    findUniqueInputRepoPath(configured_path, "LOINC_Mapping", "directory"),
    "Multiple input repository paths named 'LOINC_Mapping'"
  )
  expect_true(is.na(findUniqueInputRepoPath(
    configured_path,
    "not-present.xlsx",
    "file",
    required = FALSE
  )))
})
