auditTable <- function(path, title) {
  lines <- readLines(path, warn = FALSE)
  start <- match(title, lines)
  stopifnot(!is.na(start))
  rest <- lines[seq.int(start + 1L, length(lines))]
  end <- match("", rest)
  if (!is.na(end)) rest <- head(rest, end - 1L)
  utils::read.delim(text = paste(rest, collapse = "\n"), check.names = FALSE)
}
