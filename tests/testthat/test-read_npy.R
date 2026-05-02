test_that("different types work", {
  system.file("extdata", "test_int32.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c(1L, 2L, 3L), dim = 3L))

  system.file("extdata", "test_int8.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c(-128L, 0L, 127L), dim = 3L))

  system.file("extdata", "test_int16.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c(-32768L, 0L, 32767L), dim = 3L))

  system.file("extdata", "test_int64.npy", package = "grumpy") |>
    read_npy() |>
    expect_identical(array(c(-2L, 73L, 38L), dim = 3L)) |>
    expect_warning("overflow")

  system.file("extdata", "test_uint8.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c(0L, 128L, 255L), dim = 3L))

  system.file("extdata", "test_uint16.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c(0L, 1000L, 65535L), dim = 3L))

  system.file("extdata", "test_float32.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_equal(array(c(1.5, -2.5, 3.14), dim = 3L), tolerance = 1e-6)

  system.file("extdata", "test_float64.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c(1.5, -2.5, 3.14), dim = 3L))

  system.file("extdata", "test_bool.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c(TRUE, FALSE, TRUE), dim = 3L))
})

test_that("big endian files work", {
  system.file("extdata", "test_bigendian.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c(1.0, 2.0, 3.0), dim = 3L))
})

test_that("higher-dimension arrays work", {
  system.file("extdata", "test_2d.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(0:5, dim = c(2L, 3L)))

  system.file("extdata", "test_3d.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(0:23, dim = c(2L, 3L, 4L)))
})

test_that("fortran order arrays work", {
  system.file("extdata", "test_fortran.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(matrix(0:5, nrow = 2L, ncol = 3L, byrow = TRUE))
})

test_that("string dtypes raise an informative error", {
  system.file("extdata", "test_str_unicode.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c("foo", "bar", "baz"), dim = 3L))

  system.file("extdata", "test_str_bytes.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(c("foo", "bar", "baz"), dim = 3L))
})

test_that("scalar or empty arrays work", {
  system.file("extdata", "test_scalar.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(42))

  system.file("extdata", "test_empty.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_length(0)
})
