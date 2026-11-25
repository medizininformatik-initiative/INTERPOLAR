test_that("peak memory uses the Linux high-water mark rather than current RSS", {
  expect_identical(parseProcessPeakMemoryKiB(c("VmRSS:\t100 kB", "VmHWM:\t2048 kB")), 2048)
  expect_identical(parseProcessPeakMemoryKiB("VmHWM: 0 kB"), 0)
  expect_true(is.na(parseProcessPeakMemoryKiB(character())))
  expect_true(is.na(parseProcessPeakMemoryKiB("VmHWM: unavailable")))
  expect_true(is.na(parseProcessPeakMemoryKiB(c("VmHWM: 1 kB", "VmHWM: 2 kB"))))
  expect_true(is.na(parseProcessPeakMemoryKiB("VmHWM: 1024 MB")))
})
