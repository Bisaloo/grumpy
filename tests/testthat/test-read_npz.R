test_that("read_npz() works", {
  res <- system.file("extdata", "test.npz", package = "grumpy") |>
    read_npz() |>
    expect_no_condition()

  expect_type(res, "list")
  expect_equal(length(res), 2)

  # Mixed types are preserved
  expect_identical(res[[1]], array(c(1L, 2L, 3L), dim = 3L))
  expect_identical(res[[2]], array(c(4.0, 5.0, 6.0), dim = 3L))
})
