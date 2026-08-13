# Beyond grumpy and `.npy` files

In the other vignettes, we mentioned that whenever possible, we would
recommend users to use more advanced and performant formats such as
[Zarr](https://zarr-specs.readthedocs.io/en/latest/v3/core/). Zarr is
particularly well-suited for `array`s or `matrix`es in R.

In this short vignette, we show how one would write and read Zarr files
in R, using the [Rarr](https://huber-group-embl.github.io/Rarr/)
package.

We also quickly and informally benchmark the performance of these
formats against `.npy` files, using the
[grumpy](https://hugogruson.fr/grumpy/) package.

``` r

library(grumpy)
library(Rarr)
```

## Introduction to Zarr

If you are now understanding how the `.npy` file format works, the Zarr
format is a natural extension of it. Zarr is a chunked, compressed,
N-dimensional array storage format. Each chunk of data corresponds to a
small sub-array of the original array, and is stored in a separate file,
**in a format nearly identical to `.npy`**. The chunk is then usually
compressed with high-performance compression algorithms such as `zlib`,
`blosc`, or `zstd`.

One benefit of this chunked approach is that it allows for efficient
reading and writing of large arrays, as only the necessary chunks need
to be read or written, rather than the entire array. This is
particularly useful for large datasets that do not fit into memory, as
it allows for out-of-core processing of the data. It also provides
strong benefits when some chunks are “empty” (e.g. filled with zeros,
such as the white/black background of an image), as these chunks can be
skipped during reading and writing, and thus reduce the overall storage
requirements of the dataset.

``` r

x <- matrix(0, nrow = 1e4, ncol = 1e4)
x[300:400, 700:800] <- seq_len(101 * 101)

f_zarr <- withr::local_tempfile(fileext = ".zarr")

Rarr::write_zarr_array(x, f_zarr, chunk_dim = c(100, 100), compressor = NULL)
```

## Storage size comparison

An equivalent `.npy` is 800 MB (`10 000 * 10 000 * 8` bytes). Let’s look
at the size of the Zarr file on disk:

``` r

size <- list.files(f_zarr, full.names = TRUE, recursive = TRUE) |>
  file.info() |>
  subset(select = "size") |>
  sum()
size
```

    [1] 320579

**Without compression**, the equivalent Zarr data is thus 320 kB on
disk, so `round(8e8 / size)` times smaller than the `.npy` file. We
could also use compression to further reduce the size of the Zarr file
on disk, but this is out of scope for this vignette.

## Decoding speed comparison

We can also compare the speed of reading the `.npy` file with
[grumpy](https://hugogruson.fr/grumpy/) and the Zarr file with
[Rarr](https://huber-group-embl.github.io/Rarr/). To do so, we need to
actually generate the data. We do it via
[reticulate](https://rstudio.github.io/reticulate/) because writing
`.npy` files is out of scope for
[grumpy](https://hugogruson.fr/grumpy/).

``` r

library(reticulate)
np <- import("numpy")
```

    Downloading uv...Done!

``` r

f_npy <- withr::local_tempfile(fileext = ".npy")
np$save(f_npy, x)
```

``` r

bm <- bench::mark(
  grumpy = read_npy(f_npy),
  zarr = read_zarr_array(f_zarr),
  iterations = 50
)
```

    Warning: Some expressions had a GC in every iteration; so filtering is
    disabled.

``` r

bm
```

    # A tibble: 2 × 6
      expression      min   median `itr/sec` mem_alloc `gc/sec`
      <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
    1 grumpy        307ms    320ms      3.08    1.49GB     1.91
    2 zarr          816ms    869ms      1.13  782.44MB     7.08

``` r

summary(bm, relative = TRUE)
```

    Warning: Some expressions had a GC in every iteration; so filtering is
    disabled.

    # A tibble: 2 × 6
      expression   min median `itr/sec` mem_alloc `gc/sec`
      <bch:expr> <dbl>  <dbl>     <dbl>     <dbl>    <dbl>
    1 grumpy      1      1         2.73      1.95     1
    2 zarr        2.66   2.72      1         1        3.71

There is a small time penalty for reading the Zarr file, since the
various chunks need to be read and concatenated together, but the memory
footprint is much smaller, and the Zarr file is much smaller on disk.
This is particularly important for large datasets that do not fit into
memory, as it allows for out-of-core processing of the data.
