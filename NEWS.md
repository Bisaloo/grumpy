# grumpy (development version)

## Significant new features

* `read_npy()` gains a new `lazy` argument. When `lazy = TRUE`, raw bytes are
  read lazily using ALTREP and mmap against the `.npy` file on disk, resulting
  in much better speed & memory performance. This is following a feature
  request from @btraven00 in #11.
* `read_npz()` gains a new `arrays` argument to allow reading only a subset of
  the arrays in the npz container.

## Minor improvements

* Elements of structured datatypes are now named if names were provided during
the dataset creation.
* `read_npz()` now adds names to the list it returns. The names are the names
of the bundled `.npy` files without the file extension.

# grumpy 0.1.1

* The package title and description have been revised based on CRAN feedback.
* The return value for `convert_bytes_to_array()` is now documented. 

# grumpy 0.1.0

* Initial beta release.
