styler::cache_deactivate()

style_transformer <- styler::tidyverse_style(
  indent_by = 2L,
  strict = FALSE
)

style_paths <- c(
  "R-cds2db",
  "R-cdstoolchain",
  "R-dataprocessor",
  "R-db2frontend",
  "R-etlutils",
  "Postgres-cds_hub/R-initcdstoolchain"
)

existing_style_paths <- style_paths[dir.exists(style_paths)]

invisible(lapply(existing_style_paths, function(style_path) {
  styler::style_dir(
    path = style_path,
    recursive = TRUE,
    transformers = style_transformer,
    filetype = "R",
    include_roxygen_examples = FALSE
  )
}))
