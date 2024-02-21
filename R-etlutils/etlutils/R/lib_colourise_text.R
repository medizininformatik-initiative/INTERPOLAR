###
#
# Deprecated!!! Don't use these functions in future! Use function ansi() and cat_ansi() instead!
#
###

#' Create escape ansi code for colored printing
#'
#' @param code An integer of length 1, the code of the color or an ansi code.
#'
#' @return A character of length 1, the escaped ansi code.
ansi_escape <- function(code) {
  paste0("\033[", code, "m")
}

#' Check if R CMD is Running
#'
#' This function checks if R CMD is currently running by examining the 'R_TESTS' environment variable.
#'
#' @export
rcmd_running <- function() {
  nchar(Sys.getenv('R_TESTS')) != 0
}

#' Colourise text for display in the terminal.
#'
#' If R is not currently running in a system that supports terminal colours
#' the text will be returned unchanged.
#'
#' Allowed colours are: black, blue, brown, cyan, dark gray, green, light
#' blue, light cyan, light gray, light green, light purple, light red,
#' purple, red, white, yellow
#'
#' @param text character vector
#' @param fg foreground colour, defaults to white
#' @param bg background colour, defaults to transparent
#' @export
#' @examples
#' cat_colourised("Red\n", "red")
#' cat_colourised("White on red\n", "white", "red")
colourise <- function(text, fg = "dark gray", bg = NULL) {
  # terms and codes
  # 16 foreground colors
  .fg_colours <- c(
    "black"        = "0;30",
    "red"          = "0;31",
    "green"        = "0;32",
    "brown"        = "0;33",
    "blue"         = "0;34",
    "purple"       = "0;35",
    "cyan"         = "0;36",
    "light gray"   = "0;37",
    "dark gray"    = "1;30",
    "light red"    = "1;31",
    "light green"  = "1;32",
    "yellow"       = "1;33",
    "light blue"   = "1;34",
    "light purple" = "1;35",
    "light cyan"   = "1;36",
    "white"        = "1;37"
  )
  # 8 background colors
  .bg_colours <- c(
    "black"      = "40",
    "red"        = "41",
    "green"      = "42",
    "brown"      = "43",
    "blue"       = "44",
    "purple"     = "45",
    "cyan"       = "46",
    "light gray" = "47"
  )
  # get name of currently used terminal
  term <- Sys.getenv()["TERM"]

  # allowed terminal types
  colour_terms <- c("xterm-color","xterm-256color", "screen", "screen-256color")

  # if there are running programs or terminal type is unknown, return unchanged text
  if (rcmd_running() || !any(term %in% colour_terms, na.rm = TRUE)) {
    return(text)
  }

  # map color name to color code
  col <- .fg_colours[tolower(fg)]

  # if color name was not allowed, set col to dark gray
  if (is.na(col)) col <- "dark gray"

  # if a background color was given, paste it behind the foreground color
  if (!is.null(bg)) {
    col <- paste0(col, .bg_colours[tolower(bg)], sep = ";")
  }

  # init color mode
  init  <- ansi_escape(col)

  # reset color mode
  reset <- ansi_escape("0")

  # paste all together
  paste0(init, text, reset)
}

#' Colorize and Print Text with Customization
#'
#' This function colorizes and prints text with specified foreground and background colors.
#'
#' @param msg The text message to be colorized and printed.
#' @param fg The foreground color. Defaults to NULL.
#' @param bg The background color. Defaults to NULL.
#'
#' @export
cat_colourised <- function(msg, fg = NULL, bg = NULL) {
  cat(colourise(text = msg, fg = fg, bg = bg))
}

#' Print Text in Light Green Color
#'
#' This function prints text in light green color.
#'
#' @param msg The text message to be printed.
#' @param bg The background color. Defaults to NULL.
#'
#' @export
cat_green <- function(msg, bg = NULL) {
  cat_colourised(msg, fg = "light green", bg = bg)
}

#' Print Text in Light Red Color
#'
#' This function prints text in light red color.
#'
#' @param msg The text message to be printed.
#' @param bg The background color. Defaults to NULL.
#'
#' @export
cat_red <- function(msg, bg = NULL) {
  cat_colourised(msg, fg = "light red", bg = bg)
}

#' Print "OK" in Light Green Color
#'
#' This function prints "OK" in light green color.
#'
#' @param msg The text message to be printed. Defaults to "OK".
#' @param bg The background color. Defaults to NULL.
#'
#' @export
cat_ok <- function(msg = "OK\n", bg = NULL) {
  cat_green(msg, bg = bg)
}

#' Print "ERROR" in Light Red Color
#'
#' This function prints "ERROR" in light red color.
#'
#' @param msg The text message to be printed. Defaults to "ERROR".
#' @param bg The background color. Defaults to NULL.
#'
#' @export
cat_error <- function(msg = "ERROR\n", bg = NULL) {
  cat_red(msg, bg = bg)
}

