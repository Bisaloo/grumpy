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

test_that("read_npz() works with arrays argument", {
  full_read <- system.file("extdata", "test.npz", package = "grumpy") |>
    read_npz()

  partial_character <- system.file("extdata", "test.npz", package = "grumpy") |>
    read_npz(arrays = "y") |>
    expect_no_condition()

  expect_identical(partial_character[[1L]], full_read[["y"]])

  partial_numeric <- system.file("extdata", "test.npz", package = "grumpy") |>
    read_npz(arrays = 2L) |>
    expect_no_condition()

  expect_identical(partial_numeric[[1L]], full_read[["y"]])
})
