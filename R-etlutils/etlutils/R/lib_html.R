# Save widget data verbatim after Pandoc has embedded the page's resources.
# Keeping JSON out of Pandoc avoids constructing its document tree for large tables.
saveHtmlWidgetPage <- function(widget, output_file, title) {
  work_dir <- tempfile("html-export-", tmpdir = dirname(output_file))
  dir.create(work_dir)
  work_dir <- normalizePath(work_dir, winslash = "/", mustWork = TRUE)
  on.exit(unlink(work_dir, recursive = TRUE), add = TRUE)

  rendered <- htmltools::renderTags(htmltools::as.tags(widget, standalone = TRUE))
  dependencies <- lapply(rendered$dependencies, function(dependency) {
    htmltools::copyDependencyToDir(dependency, work_dir, mustWork = TRUE)
  })
  header_file <- file.path(work_dir, "header.html")
  writeLines(c(
    as.character(htmltools::tags$title(title)),
    as.character(htmltools::renderDependencies(dependencies, srcType = "file")),
    rendered$head
  ), header_file, useBytes = TRUE)

  # htmlwidgets emits escaped JSON in these script elements, so a closing script
  # tag cannot occur inside a payload, including when a cell contains HTML text.
  matches <- gregexpr(
    '<script type="application/json" data-for="[^"]+">',
    rendered$html,
    perl = TRUE
  )[[1]]
  if (matches[1] == -1L) matches <- integer()
  # Search closing tags literally: matching a whole large JSON block with PCRE
  # can exceed its match limit and accidentally send the data through Pandoc.
  closing_tags <- gregexpr("</script>", rendered$html, fixed = TRUE)[[1]]
  ends <- closing_tags[findInterval(matches, closing_tags) + 1L] + 8L
  if (anyNA(ends)) stop("Widget data script has no closing tag.")
  marker_prefix <- paste0("INTERPOLAR_WIDGET_", basename(work_dir), "_")
  if (grepl(marker_prefix, rendered$html, fixed = TRUE)) {
    stop("HTML export marker conflicts with page content.")
  }
  payload_files <- file.path(work_dir, paste0("payload-", seq_along(matches), ".html"))
  input_file <- file.path(work_dir, "page.md")
  input_con <- file(input_file, "wb")
  tryCatch(
    {
      writeLines("``````````{=html}", input_con)
      start <- 1L
      for (i in seq_along(matches)) {
        writeLines(substr(rendered$html, start, matches[i] - 1L), input_con, useBytes = TRUE)
        writeLines(paste0("<!--", marker_prefix, i, "-->"), input_con)
        writeLines(substr(rendered$html, matches[i], ends[i]),
          payload_files[i],
          useBytes = TRUE
        )
        start <- ends[i] + 1L
      }
      writeLines(substring(rendered$html, start), input_con, useBytes = TRUE)
      writeLines("``````````", input_con)
    },
    finally = close(input_con)
  )
  rm(rendered)

  template_file <- file.path(work_dir, "template.html")
  writeLines(c(
    "<!DOCTYPE html>", "<html>", "<head>", '<meta charset="utf-8"/>',
    "$for(header-includes)$", "$header-includes$", "$endfor$", "</head>",
    '<body style="background-color: white;">', "$body$", "</body>", "</html>"
  ), template_file)
  embedded_file <- file.path(work_dir, "embedded.html")
  rmarkdown::pandoc_convert(
    input_file,
    from = "markdown", to = "html", output = embedded_file,
    options = c(
      "--self-contained", "--template", template_file,
      "--include-in-header", header_file
    )
  )

  result_file <- file.path(work_dir, "complete.html")
  result_con <- file(result_file, "wb")
  restored <- integer(length(matches))
  tryCatch(
    {
      for (line in readLines(embedded_file, warn = FALSE, encoding = "UTF-8")) {
        index <- match(trimws(line), paste0("<!--", marker_prefix, seq_along(matches), "-->"))
        if (is.na(index)) {
          writeLines(line, result_con, useBytes = TRUE)
        } else {
          payload_con <- file(payload_files[index], "rb")
          tryCatch(repeat {
            chunk <- readBin(payload_con, "raw", n = 1048576L)
            if (!length(chunk)) break
            writeBin(chunk, result_con)
          }, finally = close(payload_con))
          restored[index] <- restored[index] + 1L
        }
      }
    },
    finally = close(result_con)
  )
  if (any(restored != 1L)) stop("Pandoc did not preserve all widget data placeholders.")
  # Publish only a complete document; failed exports leave the previous file intact.
  if (!file.rename(result_file, output_file)) stop("Could not publish HTML page: ", output_file)
  invisible(NULL)
}
