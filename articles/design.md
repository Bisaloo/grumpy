# Design principles

## Scope

**Reading** `.npy` and `.npz` files in R.

Writing is out of scope. When working across multiple languages, one
should prefer high-performance interoperable format (parquet, zarr,
etc.).

## FAQ

### Why not use `reticulate`?

### Why is this package slow?

This package is optimized for performance as much as base R allows. We
could get better performance by using a lower-level language under the
hood, but this package only exist as a crutch if you have received a
`.npy` or `.npz` file and want to read it in R.

For better performance when exchanging data across languages, one should
prefer high-performance interoperable format (parquet, zarr, etc.).
