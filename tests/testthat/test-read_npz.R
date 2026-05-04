test_that("read_npz() works", {
  res <- system.file("extdata", "test.npz", package = "grumpy") |>
    read_npz() |>
    expect_no_condition()

  expect_type(res, "list")
  expect_length(res, 2L)

  # Mixed types are preserved
  expect_identical(res[[1L]], array(c(1L, 2L, 3L), dim = 3L))
  expect_identical(res[[2L]], array(c(4.0, 5.0, 6.0), dim = 3L))
})
