# Resolve the checkout/image root independently of the caller's working directory.
script_argument <- grep("^--file=", commandArgs(), value = TRUE)
if (length(script_argument) != 1L) stop("Start this script with Rscript.")
script_path <- normalizePath(sub("^--file=", "", script_argument), mustWork = TRUE)
project_root <- dirname(dirname(script_path))
source(file.path(project_root, "R-cdstoolchain", "Snapshot_Pseudonymization_Cli.R"))
source(file.path(project_root, "R-cdstoolchain", "Database_Connection_Diagnostics.R"))
runDatabaseConnectionDiagnostics(project_root)
