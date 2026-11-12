test_that("single-file export retains complete widget data and dependencies", {
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  output_dir <- withr::local_tempdir()
  input <- data.table::data.table(
    id = seq_len(6003L),
    text = rep(c("Größe & Öl", "</script><p>example</p>", NA_character_), 2001L),
    date = as.Date("2025-01-01") + seq_len(6003L),
    flag = rep(c(TRUE, FALSE, NA), 2001L)
  )
  original <- data.table::copy(input)
  widget <- DT::datatable(
    input,
    elementId = "full-table", extensions = "Buttons",
    options = list(dom = "Bfrtip", buttons = c("csv", "excel"))
  )
  baseline <- file.path(output_dir, "baseline.html")
  htmlwidgets::saveWidget(widget, baseline, selfcontained = FALSE)
  output <- file.path(output_dir, "single.html")
  saveHtmlWidgetPage(widget, output, "Complete table")

  document <- xml2::read_html(output)
  payload <- xml2::xml_text(xml2::xml_find_first(document, "//script[@data-for='full-table']"))
  expected <- xml2::xml_text(xml2::xml_find_first(
    xml2::read_html(baseline),
    "//script[@data-for='full-table']"
  ))
  expect_identical(payload, expected)
  data <- jsonlite::fromJSON(payload, simplifyMatrix = FALSE)$x$data
  expect_length(data[[2]], 6003L)
  expect_equal(data[[2]], input$id)
  expect_identical(input, original)
  references <- xml2::xml_find_all(document, "//script[@src] | //link[@href]")
  expect_length(references, 0L)
  expect_gt(length(xml2::xml_find_all(document, "//script[not(@type)]")), 0L)
  expect_false(dir.exists(sub(".html$", "_files", output)))
  expect_length(list.files(output_dir, pattern = "^html-export-"), 0L)
})

test_that("large payloads never enter Pandoc", {
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  output_dir <- withr::local_tempdir()
  original_convert <- rmarkdown::pandoc_convert
  testthat::local_mocked_bindings(
    pandoc_convert = function(input, ...) {
      stopifnot(file.info(input)$size < 10000)
      original_convert(input, ...)
    }, .package = "rmarkdown"
  )
  value <- strrep("x", 11000000L)
  widget <- htmlwidgets::createWidget(
    "large",
    x = list(value = value),
    package = "htmlwidgets", elementId = "large"
  )
  output <- file.path(output_dir, "large.html")
  expect_no_warning(saveHtmlWidgetPage(widget, output, "Large payload"))
  html <- paste(readLines(output, warn = FALSE), collapse = "\n")
  expect_true(grepl(value, html, fixed = TRUE))
  expect_length(list.files(output_dir), 1L)
})

test_that("pages retain multiple tables, empty tables and embedded body images", {
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  output_dir <- withr::local_tempdir()
  image_file <- file.path(output_dir, "pixel.png")
  writeBin(jsonlite::base64_dec(paste0(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8",
    "/x8AAwMCAO+aD1sAAAAASUVORK5CYII="
  )), image_file)
  rlang::local_bindings(
    MODULE_DIRS = list(local_dir = output_dir, global_dir = output_dir),
    .env = .GlobalEnv
  )
  content <- list(
    DT::datatable(data.frame(id = 1:2), elementId = "first"),
    DT::datatable(data.frame(id = integer()), elementId = "empty"),
    htmltools::tags$img(src = image_file)
  )
  for (location in c("local", "global")) {
    writeHtmlPage(content, output_location = location, pagename = location)
    output <- file.path(output_dir, "reports", paste0(location, "_", Sys.Date(), ".html"))
    document <- xml2::read_html(output)
    expect_length(xml2::xml_find_all(document, "//script[@type='application/json']"), 3L)
    expect_length(xml2::xml_find_all(document, "//hr"), 2L)
    expect_match(xml2::xml_attr(xml2::xml_find_first(document, "//img"), "src"), "^data:image/png")
    empty <- jsonlite::fromJSON(xml2::xml_text(xml2::xml_find_first(
      document,
      "//script[@data-for='empty']"
    )))
    expect_length(empty$x$data[[1]], 0L)
  }
  expect_length(list.files(file.path(output_dir, "reports")), 2L)
})

test_that("failed exports preserve existing pages and clean temporary files", {
  output_dir <- withr::local_tempdir()
  output <- file.path(output_dir, "report.html")
  writeLines("existing report", output)
  testthat::local_mocked_bindings(
    pandoc_convert = function(...) stop("embedding failed"), .package = "rmarkdown"
  )
  expect_error(
    saveHtmlWidgetPage(DT::datatable(data.frame(id = 1L)), output, "Test"),
    "embedding failed"
  )
  expect_identical(readLines(output), "existing report")
  expect_identical(list.files(output_dir), "report.html")
})

test_that("lost data placeholders fail before publishing", {
  output_dir <- withr::local_tempdir()
  output <- file.path(output_dir, "report.html")
  testthat::local_mocked_bindings(
    pandoc_convert = function(input, from, to, output, options) writeLines("incomplete", output),
    .package = "rmarkdown"
  )
  expect_error(
    saveHtmlWidgetPage(DT::datatable(data.frame(id = 1L)), output, "Test"),
    "did not preserve all widget data"
  )
  expect_length(list.files(output_dir), 0L)
})

test_that("URL dependencies are embedded together with local dependencies", {
  skip_if_not(rmarkdown::pandoc_available("2.0"))
  output_dir <- withr::local_tempdir()
  writeLines("window.interpolarUrlDependency = true;", file.path(output_dir, "remote.js"))
  writeLines(".url-dependency { color: rgb(1, 2, 3); }", file.path(output_dir, "remote.css"))
  # A file URL exercises href-only dependencies without requiring network access.
  dependency <- htmltools::htmlDependency(
    "url-dependency", "1.0",
    src = list(href = paste0("file://", output_dir)),
    script = "remote.js", stylesheet = "remote.css"
  )
  widget <- DT::datatable(data.frame(id = 1:3), elementId = "url-table")
  widget$dependencies <- c(widget$dependencies, list(dependency))
  output <- file.path(output_dir, "single.html")
  saveHtmlWidgetPage(widget, output, "URL dependencies")
  document <- xml2::read_html(output)
  expect_match(paste(xml2::xml_text(xml2::xml_find_all(document, "//script")), collapse = "\n"),
    "window.interpolarUrlDependency = true;",
    fixed = TRUE
  )
  expect_match(paste(xml2::xml_text(xml2::xml_find_all(document, "//style")), collapse = "\n"),
    ".url-dependency",
    fixed = TRUE
  )
  expect_length(xml2::xml_find_all(document, "//script[@src] | //link[@href]"), 0L)
  expect_length(xml2::xml_find_all(
    document,
    "//script[@type='application/json' and @data-for='url-table']"
  ), 1L)
})

test_that("payload extraction and restoration preserve multiple data blocks", {
  output_dir <- withr::local_tempdir()
  input <- file.path(output_dir, "input.md")
  embedded <- file.path(output_dir, "embedded.html")
  output <- file.path(output_dir, "output.html")
  scripts <- c(
    '<script type="application/json" data-for="first">{"text":"Größe \\u003c/script>"}</script>',
    '<script type="application/json" data-for="second">{"value":null}</script>'
  )
  payloads <- extractHtmlWidgetPayloads(paste(scripts, collapse = "\n"), output_dir, input)
  expect_length(payloads$markers, 2L)
  expect_identical(vapply(payloads$files, readLines, character(1), USE.NAMES = FALSE), scripts)
  expect_false(any(grepl('"text"|"value"', readLines(input))))
  writeLines(c("<body>", payloads$markers, "</body>"), embedded)
  restoreHtmlWidgetPayloads(embedded, output, payloads)
  expect_identical(readLines(output), c("<body>", scripts, "</body>"))

  writeLines(rep(payloads$markers, each = 2L), embedded)
  expect_error(
    restoreHtmlWidgetPayloads(embedded, output, payloads),
    "did not preserve all widget data"
  )
  writeLines(payloads$markers[1], embedded)
  expect_error(
    restoreHtmlWidgetPayloads(embedded, output, payloads),
    "did not preserve all widget data"
  )
})

test_that("payload helpers support plain HTML and reject unterminated widget scripts", {
  output_dir <- withr::local_tempdir()
  input <- file.path(output_dir, "input.md")
  embedded <- file.path(output_dir, "embedded.html")
  output <- file.path(output_dir, "output.html")
  payloads <- extractHtmlWidgetPayloads("<p>Plain HTML</p>", output_dir, input)
  expect_identical(payloads, list(markers = character(), files = character()))
  writeLines("<p>Plain HTML</p>", embedded)
  restoreHtmlWidgetPayloads(embedded, output, payloads)
  expect_identical(readLines(output), "<p>Plain HTML</p>")
  expect_error(extractHtmlWidgetPayloads(
    '<script type="application/json" data-for="broken">{}', output_dir, input
  ), "no closing tag")
})
