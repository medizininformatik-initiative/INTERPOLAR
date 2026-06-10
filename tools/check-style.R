source("tools/style.R")

diff_result <- system2("git", c("diff", "--exit-code", "--", existing_style_paths))
if (!identical(diff_result, 0L)) {
  stop(
    paste(
      "R code is not formatted.",
      "Run `Rscript tools/style.R`, review the diff, and commit the changes."
    ),
    call. = FALSE
  )
}
