style_mode <- if (length(commandArgs(trailingOnly = TRUE))) {
  commandArgs(trailingOnly = TRUE)[[1L]]
} else {
  "full"
}

if (!style_mode %in% c("full", "changed")) {
  stop("Usage: Rscript tools/check-style.R [full|changed]", call. = FALSE)
}

if (identical(style_mode, "changed")) {
  source("tools/style-changed.R")
} else {
  source("tools/style.R")
}

diff_result <- system2("git", c("diff", "--exit-code", "--", existing_style_paths))
if (!identical(diff_result, 0L)) {
  stop(
    paste(
      "R code is not formatted.",
      "Run `Rscript tools/style-full.R`, review the diff, and commit the changes."
    ),
    call. = FALSE
  )
}
