# Design principles

## Scope

**Reading** `.npy` and `.npz` files in R.

Writing is out of scope. When working across multiple languages, one
should prefer high-performance interoperable formats
([parquet](https://parquet.apache.org/),
[Zarr](https://zarr-specs.readthedocs.io/en/latest/v3/core/), etc.).

## Dependencies

Because [grumpy](https://hugogruson.fr/grumpy/) is a intended to be used
deep in the dependency graph of other packages, we want to minimize the
number of dependencies. There is currently no dependency, and no new
dependency should be added unless it provides a significant performance
improvement.

## Function signatures

### Inputs

- The first argument of
  [`read_npy()`](https://hugogruson.fr/grumpy/reference/read_npy.md) and
  [`read_npz()`](https://hugogruson.fr/grumpy/reference/read_npz.md) is
  named `file` and is a connection or the path to the file to read. This
  is consistent with base R functions such as
  [`read.csv()`](https://rdrr.io/r/utils/read.table.html),
  [`readRDS()`](https://rdrr.io/r/base/readRDS.html), etc.

### Outputs

- The output of
  [`read_npy()`](https://hugogruson.fr/grumpy/reference/read_npy.md) is
  always an array (i.e.,
  [`is.array()`](https://rdrr.io/r/base/array.html) is `TRUE`), even for
  structured datatypes. This is to keep the output consistent and as
  conceptually close as possible to the original NumPy array.
- The output of
  [`read_npz()`](https://hugogruson.fr/grumpy/reference/read_npz.md) is
  always a named list of arrays, even if the `.npz` file contains only
  one array. A stable output type is important for downstream analysis.

## FAQ

### Why not use `reticulate`?

- When reading `.npy` files with
  [reticulate](https://rstudio.github.io/reticulate/), at some point in
  time, two (one in Python and one in R) or three copies of the data are
  held in memory. This can be problematic for large files. With
  [grumpy](https://hugogruson.fr/grumpy/), one (for types matching R
  native types; i.e., `int32`, `float64`/`double`) or two copies of the
  data are held in memory.

  ``` r

  f <- tempfile(fileext = ".npy")
  np <- reticulate::import("numpy")
  x <- np$random$rand(1000L, 1000L)
  np$save(f, x)

  microbenchmark::microbenchmark(
    reticulate = {
      x <- np$load(f)
    },
    grumpy = {
      x <- grumpy::read_npy(f)
    },
    times = 1e3
  )
  ```

      Unit: milliseconds
             expr      min       lq     mean   median       uq      max neval
       reticulate 1.244979 1.561211 3.238004 1.710594 3.391494 142.5985  1000
           grumpy 1.928769 2.234361 6.350905 2.557514 4.208203 204.4202  1000

  ``` r

  ## On platform that support it, lazy reading offers even better performance for large files
  if (Sys.info()[["sysname"]] %in% c("Linux", "Darwin")) {
    microbenchmark::microbenchmark(
      reticulate = {
        x <- np$load(f)
      },
      grumpy = {
        x <- grumpy::read_npy(f, lazy = TRUE)
      },
      times = 1e3
    )
  }
  ```

      Unit: microseconds
             expr      min        lq     mean   median       uq      max neval
       reticulate 1092.281 1380.0100 3157.891 1551.757 2999.559 148097.7  1000
           grumpy  387.509  572.9955 2052.921  744.186 1145.755 140116.2  1000

- Reading data with [reticulate](https://rstudio.github.io/reticulate/)
  requires a Python installation and additional python packages, which
  users in restricted environments may not have access to.
  [grumpy](https://hugogruson.fr/grumpy/) is a pure R package with no
  external dependencies. This is especially important as we expect
  [grumpy](https://hugogruson.fr/grumpy/) to be used deep in the
  dependency graph of other packages, and we want to minimize the number
  of dependencies.

- A dedicated R package gives us more flexibility in how edge cases such
  as 64-bit integers are handled.
  [reticulate](https://rstudio.github.io/reticulate/) automatically and
  silently converts 64-bit integers to double, which is a sensible
  default for many use cases. But we may want to have more control over
  this behavior, and [grumpy](https://hugogruson.fr/grumpy/) will allow
  us to do that in the future. Another good example are structured data
  types (record arrays), which are returned as `data.frame`s, not
  `array`s, with [reticulate](https://rstudio.github.io/reticulate/).
