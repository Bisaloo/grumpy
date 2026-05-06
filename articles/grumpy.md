# Getting started with grumpy

``` r

library(grumpy)
```

## Motivation

This package allows users to read a wide variety of `.npy` and `.npz`
files in R. These file formats are commonly used in Python for storing
NumPy arrays and compressed archives of arrays, respectively. By
providing a convenient interface for reading these files, `grumpy`
enables R users to easily access and work with data that has been saved
in these formats, facilitating interoperability between Python and R.

We envision users may want to perform some steps of their data analysis
in Python and others in R.

It is thus important to be able to read and write files in both
languages.

Note however we would usually push users towards more advanced and
performant formats such as Zarr for large datasets. Zarr datasets are
supported for example by the `{Rarr}` Bioconductor package.

## Using grumpy

Most users are expected to mostly want to use
[`grumpy::read_npy()`](https://hugogruson.fr/grumpy/reference/read_npy.md)
and
[`grumpy::read_npz()`](https://hugogruson.fr/grumpy/reference/read_npz.md)
to read `.npy` and `.npz` files, respectively. These functions will
return R objects that are equivalent to the original NumPy arrays,
allowing users to easily manipulate and analyze the data in R.

``` r

read_npy(system.file("extdata", "test_2d.npy", package = "grumpy"))
#>      [,1] [,2] [,3] [,4]
#> [1,]    0    3    6    9
#> [2,]    1    4    7   10
#> [3,]    2    5    8   11
```

### Structured datatypes

One notable example are structured datatypes, where each element of the
array is a record with named fields. To keep the output consistent and
as conceptually close as possible to the original NumPy array, `grumpy`
returns a list of list, with a
[`dim()`](https://rdrr.io/r/base/dim.html) attribute to preserve the
original shape of the array.

It behaves like a standard R array, but each element is a list of the
fields of the original structured datatype.

Note that in many cases, this is not efficient for any downstream
analysis, and users may want to convert the output to a more standard R
data structure such as a `data.frame` or `data.table` for easier
manipulation.
