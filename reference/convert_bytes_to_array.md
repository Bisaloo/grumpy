# Convert raw bytes to an R array based on the specified data type information

This is a replacement for
[`readBin()`](https://rdrr.io/r/base/readBin.html) that can handle the
various data types and endianness specified in the .npy file header.

## Usage

``` r
convert_bytes_to_array(bytes, what, shape, size, endian)
```

## Arguments

- bytes:

  A raw vector containing the bytes to convert

- what:

  A character specifying the base type to convert to (e.g., `"float"`,
  `"int"`, `"string"`, etc.)

- shape:

  A numeric vector with desired shape of the output array

- size:

  A numeric value with the number of bytes per element for the specified
  type

- endian:

  The endianness of the data (`"little"`, `"big"`, or `NA` for
  single-byte types)

## Examples

``` r
x <- matrix(c(3L, 6L, 2L, 1L, 12L, 0L), nrow = 2, ncol = 3)
x
#>      [,1] [,2] [,3]
#> [1,]    3    2   12
#> [2,]    6    1    0

writeBin(c(x), raw()) |>
  convert_bytes_to_array("int", shape = c(2L, 3L), size = 4L, endian = "little")
#>      [,1] [,2] [,3]
#> [1,]    3    2   12
#> [2,]    6    1    0
```
