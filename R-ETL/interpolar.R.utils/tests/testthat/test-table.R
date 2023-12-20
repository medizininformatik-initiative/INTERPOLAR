test_that('Test isValidTable()', {
  expect_false(isValidTable(NA))
  expect_false(isValidTable(NULL))
  expect_false(isValidTable(data.table()))
  expect_false(isValidTable(data.table(col1 = c(NA, NA))))
  expect_true(isValidTable(data.table(col1 = 'AAA')))
})


test_that('Test addTableRow', {
  # Create a sample data table
  dt <- data.table(
    ID = 1:5,
    Name = c("Alice", "Bob", "Charlie", "David", "Eve"),
    Score = c(85, 92, 78, 65, 97)
  )
  expect_equal(nrow(dt), 5)

  # Add a new row to the data table
  # addTableRow converts all columns to character
  dt <- addTableRow(dt, 6, 'Frank', 88)

  expect_equal(nrow(dt), 6)
  expect_equal(dt[6][[1]], '6')
  expect_equal(dt[6][[2]], 'Frank')
  expect_equal(dt[6][[3]], '88')
})
