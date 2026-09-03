interpolarStylerStyle <- function() {
  style_transformer <- styler::tidyverse_style(
    indent_by = 2L,
    strict = FALSE
  )
  strict_transformer <- styler::tidyverse_style(
    indent_by = 2L,
    strict = TRUE
  )

  style_transformer$line_break$set_line_break_before_closing_call <-
    strict_transformer$line_break$set_line_break_before_closing_call
  style_transformer$line_break$set_line_break_after_opening_if_call_is_multi_line <-
    strict_transformer$line_break$set_line_break_after_opening_if_call_is_multi_line

  style_transformer
}
