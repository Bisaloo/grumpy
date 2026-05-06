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
