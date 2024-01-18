###
#
# Deperecated!
#
# Use functions ansi() and cat_ansi() defined in instead!
#
###

# # 16 foreground colors
# ANSI_COLORS <- list(
#   "black"        = 0,
#   "darkred"      = 1,
#   "green"        = 2,
#   "brown"        = 3,
#   "blue"         = 4,
#   "purple"       = 5,
#   "cyan"         = 6,
#   "gray"         = 7,
#   "lightgray"    = 8,
#   "red"          = 9,
#   "lightgreen"   = 10,
#   "yellow"       = 11,
#   "lightblue"    = 12,
#   "magenta"      = 13,
#   "lightcyan"    = 14,
#   "white"        = 15
# )
#' Styled String
#'
#' Format strings with ANSI escape codes for text styling.
#'
#' @param ... Character vectors to be styled.
#' @param sep Separator between the styled strings.
#' @param fg Foreground color (0-15).
#' @param bg Background color (0-15).
#' @param bold Use bold text.
#' @param italic Use italic text.
#' @param underline Underline text.
#' @param slowblink Use slow blink effect.
#' @param rapidblink Use rapid blink effect.
#' @param invert Invert text colors.
#' @param strike_out Strike out text.
#'
#' @return A styled string.
#' @export
styled_string <- function( #old name str.
    ...,
    sep        = '',
    fg         = NULL,
    bg         = NULL,
    bold       = FALSE,
    italic     = FALSE,
    underline  = FALSE,
    slowblink  = FALSE,
    rapidblink = FALSE,
    invert     = FALSE,
    strike_out = FALSE
) {
  # collect all passed strings
  strings <- list(...)

  # if there are no strings, return
  if (length(strings) < 1) {
    return(strings)
  }

  # foreground and background have to be between 0 and 15
  # if 7 < color, sub 8 and add 60 for brighter color code
  if (!is.null(fg)) {
    fg <- as.integer(fg) %% 16
    if (7 < fg) fg <- fg + 52
  }
  if (!is.null(bg)) {
    bg <- as.integer(bg) %% 16
    if (7 < bg) bg <- bg + 52
  }

  # map arguments to its codes and paste them separated by a ;
  codes <- paste0(
    c(       1,      3,         4,         5,          6,      7,          9)[
      c(bold, italic, underline, slowblink, rapidblink, invert, strike_out)
    ],
    collapse = ';'
  )

  # if all arguments were FALSE set codes to NULL
  if (codes == '') codes <- NULL

  # create color codes
  colors <- paste(c(30 + fg, 40 + bg), collapse = ';')

  # if no colors present, return NULL
  if (colors == '') colors <- NULL

  # collect codes and colors
  codes <- paste0(c(codes, colors), collapse = ';')

  # only paste the strings, if no codes given, otherwise paste the strings and surround them with ansi-codes
  if (0 < length(codes)){
    paste0('\033[', codes, 'm', paste(strings, collapse = sep), '\033[0m')
  } else {
    paste(strings, collapse = sep)
  }
}
