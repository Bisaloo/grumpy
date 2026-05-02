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
  time, two (sometimes 3) copies of the data are made in memory: one in
  Python and one in R. This can be problematic for large files. With
  [grumpy](https://hugogruson.fr/grumpy/), only one copy of the data is
  made in memory.
- Reading data with [reticulate](https://rstudio.github.io/reticulate/)
  requires a Python installation and additional python packages, which
  users in restricted environments may not have access to.
  [grumpy](https://hugogruson.fr/grumpy/) is a pure R package with no
  external dependencies.
