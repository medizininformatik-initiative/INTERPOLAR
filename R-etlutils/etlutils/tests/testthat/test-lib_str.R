
#################
# reverseString #
#################

# Tests for reverseString function
test_that("reverseString works correctly", {
  expect_equal(reverseString("abc"), "cba")
  expect_equal(reverseString("hello"), "olleh")
  expect_equal(reverseString("R programming"), "gnimmargorp R")
  expect_equal(reverseString(""), "")
  expect_equal(reverseString("a"), "a")
})
