newPseudonymTestInputRepoPath <- function(prefix = "input-repo-") {
  input_repo_path <- file.path(tempfile(prefix), "Input-Repo", "custom-source")
  dir.create(input_repo_path, recursive = TRUE)
  input_repo_path
}
