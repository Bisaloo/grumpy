test_that("different types work", {
  system.file("extdata", "test_int32.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(1L:12L, dim = 12L))

  system.file("extdata", "test_int8.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(
      c(-128L, -100L, -64L, -32L, -16L, -8L, -4L, -2L, -1L, 0L, 64L, 127L),
      dim = 12L
    ))

  system.file("extdata", "test_int16.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(
      c(
        -32768L,
        -16384L,
        -8192L,
        -4096L,
        -2048L,
        -1024L,
        -512L,
        -256L,
        -128L,
        0L,
        16383L,
        32767L
      ),
      dim = 12L
    ))

  system.file("extdata", "test_int64.npy", package = "grumpy") |>
    read_npy() |>
    expect_identical(array(-5L:6L, dim = 12L)) |>
    expect_warning("overflow")

  system.file("extdata", "test_uint8.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(
      c(0L, 10L, 20L, 50L, 100L, 128L, 150L, 175L, 200L, 210L, 240L, 255L),
      dim = 12L
    ))

  system.file("extdata", "test_uint16.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(
      c(
        0L,
        100L,
        1000L,
        5000L,
        10000L,
        20000L,
        32767L,
        40000L,
        50000L,
        55000L,
        60000L,
        65535L
      ),
      dim = 12L
    ))

  system.file("extdata", "test_uint32.npy", package = "grumpy") |>
    read_npy() |>
    expect_identical(array(
      c(
        0L,
        1L,
        10L,
        100L,
        1000L,
        10000L,
        100000L,
        1000000L,
        65536L,
        16777216L,
        NA_integer_,
        NA_integer_
      ),
      dim = 12L
    )) |>
    expect_warning("overflow")

  system.file("extdata", "test_float32.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_equal(
      array(
        c(
          1.5,
          -2.5,
          3.14,
          0.0,
          -1.0,
          100.0,
          -100.0,
          0.001,
          1e6,
          -1e6,
          1.23456,
          -9.87654
        ),
        dim = 12L
      ),
      tolerance = 1e-6
    )

  system.file("extdata", "test_float64.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(
      c(
        1.5,
        -2.5,
        3.14,
        0.0,
        -1.0,
        100.0,
        -100.0,
        0.001,
        1e6,
        -1e6,
        1.23456789,
        -9.87654321
      ),
      dim = 12L
    ))

  system.file("extdata", "test_bool.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(
      c(
        TRUE,
        FALSE,
        TRUE,
        TRUE,
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        TRUE,
        TRUE,
        FALSE,
        TRUE
      ),
      dim = 12L
    ))
})

test_that("big endian files work", {
  system.file("extdata", "test_bigendian.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(as.double(1:12), dim = 12L))
})

test_that("higher-dimension arrays work", {
  system.file("extdata", "test_2d.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(0:11, dim = c(3L, 4L)))

  system.file("extdata", "test_3d.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(0:23, dim = c(2L, 3L, 4L)))
})

test_that("fortran order arrays work", {
  system.file("extdata", "test_fortran.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(matrix(0:11, nrow = 3L, ncol = 4L, byrow = TRUE))
})

test_that("string dtypes raise an informative error", {
  system.file("extdata", "test_str_unicode.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(
      c(
        '¡Hola mundo!',
        'Hej Världen!',
        'Servus Woid!',
        'Hei maailma!',
        'Xin chào thế giới',
        'Njatjeta Botë!',
        'Γεια σου κόσμε!',
        'こんにちは世界',
        '世界，你好！',
        'Helló, világ!',
        'Zdravo svete!',
        'เฮลโลเวิลด์'
      ),
      dim = 12L
    ))

  system.file("extdata", "test_str_bytes.npy", package = "grumpy") |>
    read_npy() |>
    expect_no_condition() |>
    expect_identical(array(
      c(
        "foo",
        "bar",
        "baz",
        "qux",
        "hello",
        "world",
        "alpha",
        "beta",
        "gamma",
        "delta",
        "eps",
        "zeta"
      ),
      dim = 12L
    ))
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
