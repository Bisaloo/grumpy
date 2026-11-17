# Changelog

## grumpy (development version)

### Bug fixes

- grumpy no longer errors with an obscure error on large headers. This
  typically could happen for long or complex structured datatypes.
  Thanks to a report from Rohit Goswami as part of the rOpenSci review.
- grumpy no longer read past the string buffer for `|S` type. The
  user-facing consequence is faster processing of array with `|S` type.
  Thanks to a report from Rohit Goswami as part of the rOpenSci review.
- Code chunks using the Rarr package in the `beyond.Rmd` vignette now
  run conditionally on the presence of the Rarr package, as requested by
  the CRAN team.
- A clear error message is now returned when the `.npy` doesn’t contain
  the expected number of bytes. This could happen in the case of, e.g.,
  a partial or interrupted download. Thanks to a report from Rohit
  Goswami as part of the rOpenSci review.
- `|S0` and `<U0` types (which can no longer be written by recent
  versions of NumPy) no longer error, and now return an array of `""`,
  modelled on NumPy’s behaviour. Thanks to a report from Rohit Goswami
  as part of the rOpenSci review.

## grumpy 0.2.0

CRAN release: 2026-11-16

### Significant new features

- [`read_npy()`](https://hugogruson.fr/grumpy/reference/read_npy.md)
  gains a new `lazy` argument. When `lazy = TRUE`, raw bytes are read
  lazily using ALTREP and mmap against the `.npy` file on disk,
  resulting in much better speed & memory performance. This is following
  a feature request from [@btraven00](https://github.com/btraven00) in
  [\#11](https://github.com/Bisaloo/grumpy/issues/11).
- [`read_npz()`](https://hugogruson.fr/grumpy/reference/read_npz.md)
  gains a new `arrays` argument to allow reading only a subset of the
  arrays in the npz container.
- Integers that don’t fit in the `int32` range are now automatically and
  silently converted to `double`s, in line with what base R is doing.
  This is following feature requests from Robrecht Cannoodt and Gabriel
  Hoffman in downstream dependencies.

### Minor improvements

- Elements of structured datatypes are now named if names were provided
  during the dataset creation.
- [`read_npz()`](https://hugogruson.fr/grumpy/reference/read_npz.md) now
  adds names to the list it returns. The names are the names of the
  bundled `.npy` files without the file extension.

## grumpy 0.1.1

CRAN release: 2026-05-19

- The package title and description have been revised based on CRAN
  feedback.
- The return value for
  [`convert_bytes_to_array()`](https://hugogruson.fr/grumpy/reference/convert_bytes_to_array.md)
  is now documented.

## grumpy 0.1.0

- Initial beta release.
