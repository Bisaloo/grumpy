# grumpy (development version)

## Significant new features

* `read_npy()` gains a new `lazy` argument. When `lazy = TRUE`, raw bytes are
  read lazily using ALTREP and mmap against the `.npy` file on disk, resulting
  in much better speed & memory performance. This is following a feature
  request from @btraven00 in #11. 

# grumpy 0.1.1

* The package title and description have been revised based on CRAN feedback.
* The return value for `convert_bytes_to_array()` is now documented. 

# grumpy 0.1.0

* Initial beta release.
