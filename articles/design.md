# Design principles

## Scope

**Reading** `.npy` and `.npz` files in R.

Writing is out of scope. When working across multiple languages, one
should prefer high-performance interoperable format (parquet, zarr,
etc.).

## FAQ

### Why not use `reticulate`?

- When reading `.npy` files with
  [reticulate](https://rstudio.github.io/reticulate/), at some point in
  time, two or three copies of the data are made in memory. This can be
  problematic for large files. With
  [grumpy](https://hugogruson.fr/grumpy/), two copies of the data are
  made in memory, with plans to make just one copy in the cases where
  the data type matches R native types.

- Reading data with [reticulate](https://rstudio.github.io/reticulate/)
  requires a Python installation and additional python packages, which
  users in restricted environments may not have access to.
  [grumpy](https://hugogruson.fr/grumpy/) is a pure R package with no
  external dependencies. This is especially important as we expect
  [grumpy](https://hugogruson.fr/grumpy/) to be used deep in the
  dependency graph of other packages, and we want to minimize the number
  of dependencies.

- A dedicated R package gives us more flexibility in how edge cases such
  as 64 bits integers are handled.
  [reticulate](https://rstudio.github.io/reticulate/) automatically and
  silently converts 64 bits integers to double, which is a sensible
  default for many use cases. But we may want to have more control over
  this behavior, and [grumpy](https://hugogruson.fr/grumpy/) will allow
  us to do that in the future. Another good example are structured data
  types (record arrays), which are returned as data.frames, not arrays,
  with [reticulate](https://rstudio.github.io/reticulate/).
