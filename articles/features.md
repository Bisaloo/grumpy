# Supported features

## Data types

The following data types are supported:

- `|?`

- `|b1`

- `>f2`

- `<f2`

- `>f4`

- `<f4`

- `>f8`

- `<f8`

- `|i1`

- `<i2`

- `>i2`

- `>i4`

- `<i4`

- `>i8`

- `<i8`

- `|O`

- `|u1`

- `>u2`

- `<u2`

- `<u4`

- `>u4`

- `<u8`

- `>u8`

- structured data types (record arrays). Each element of the array is a
  combination of multiple fields, which can be of different data types.

> **Caveats**
>
> - `int64`, `uint32` and `uint64` data types are currently limited to
>   the maximum value of `int32`. Larger values are set to
>   `NA_integer_`. Future plans are laid out in
>   https://github.com/Bisaloo/grumpy/issues/13.

The following data types are not yet supported, because we are unsure of
their use cases. If you need support for any of these, please [open an
issue](https://github.com/Bisaloo/grumpy/issues).

- `b*`: signed byte
- `B*`: unsigned byte
- `c64`: complex-floating point
- `c128`: double-precision complex floating point
- `m8`: timedelta
- `M8`: datetime

## Dimensions

Any number of dimensions is supported, including zero-dimensional arrays
(scalar values) and one-dimensional arrays (vectors). The shape of the
original NumPy array is preserved in the output R object, and can be
accessed with the [`dim()`](https://rdrr.io/r/base/dim.html) function.
