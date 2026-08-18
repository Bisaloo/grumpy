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
languages. Note however that `grumpy` does not support writing as we
want to explicitly encourage users to use dedicated formats designed for
interoperability.

In particular, the following formats are designed for large datasets,
high-performance, and partial or lazy reading, including on cloud
storage:

- if you are working with array-like data (the most likely use case for
  `.npy` files), we recommend using
  [Zarr](https://zarr-specs.readthedocs.io/en/latest/v3/core/) instead.
  Zarr datasets are supported by the
  [Rarr](https://huber-group-embl.github.io/Rarr/) Bioconductor package.
- if you are working with tabular data, we recommend using [Apache
  Arrow](https://arrow.apache.org/) instead. Arrow datasets are
  supported by the [arrow](https://github.com/apache/arrow/) CRAN
  package.

## Using grumpy

Use [`read_npy()`](https://hugogruson.fr/grumpy/reference/read_npy.md)
and [`read_npz()`](https://hugogruson.fr/grumpy/reference/read_npz.md)
to read `.npy` and `.npz` files, respectively. These functions will
return R objects that are equivalent to the original NumPy arrays,
allowing users to easily manipulate and analyze the data in R.

``` r

read_npy(system.file("extdata", "test_2d.npy", package = "grumpy"))
```

         [,1] [,2] [,3] [,4]
    [1,]    0    3    6    9
    [2,]    1    4    7   10
    [3,]    2    5    8   11

### Structured datatypes

A more complex data structure is provided by structured datatypes, where
each element of the array is a record with named fields.

To keep the output consistent and as conceptually close as possible to
the original NumPy array, `grumpy` returns a list of list, with a
[`dim()`](https://rdrr.io/r/base/dim.html) attribute to preserve the
original shape of the array.

It behaves like a standard R array, but each element is a list of the
fields of the original structured datatype.

``` r

struct <- read_npy(
  system.file("extdata", "test_structured.npy", package = "grumpy")
)
struct
```

         [,1]   [,2]   [,3]   [,4]
    [1,] list,3 list,3 list,3 list,3
    [2,] list,3 list,3 list,3 list,3

``` r

dim(struct)
```

    [1] 2 4

``` r

struct[[1L]]
```

    $id
    [1] 1

    $value
    [1] 3.14

    $name
    [1] "Alice"

Note that in many cases, this is not efficient for any downstream
analysis, and users may want to convert the output to a more standard R
data structure such as a `data.frame` or `data.table` for easier
manipulation.

``` r

unlist(struct) |>
  matrix(ncol = length(struct[[1L]]), byrow = TRUE) |>
  as.data.frame()
```

      V1    V2      V3
    1  1  3.14   Alice
    2  2  2.71     Bob
    3  3  1.62 Charlie
    4  4     0    Dave
    5  5    -1     Eve
    6  6     2   Frank
    7  7 33.12   Grace
    8  8  13.9    Hugo

Doing so loses the original shape of the array, but it is unclear if
this is a problem in practice, as structured datatypes are often used to
store what should be tabular data.
