# see `help(run_script, package = 'touchstone')` on how to run this
# interactively

# TODO OPTIONAL Add directories you want to be available in this file or during the
# benchmarks.
# touchstone::pin_assets("some/dir")

# installs branches to benchmark
touchstone::branch_install()

touchstone::benchmark_run(
  pkg_load = library(grumpy),
  n = 100
)

# Types ----------

# bool
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_bool = read_npy("inst/extdata/test_bool.npy"),
  n = 100
)

# float32
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_float32 = read_npy("inst/extdata/test_float32.npy"),
  n = 100
)

# float64
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_float64 = read_npy("inst/extdata/test_float64.npy"),
  n = 100
)

# int8
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_int8 = read_npy("inst/extdata/test_int8.npy"),
  n = 100
)

# int16
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_int16 = read_npy("inst/extdata/test_int16.npy"),
  n = 100
)

# int32
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_int32 = read_npy("inst/extdata/test_int32.npy"),
  n = 100
)

# string
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_string = read_npy("inst/extdata/test_str_bytes.npy"),
  n = 100
)

# unicode
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_unicode = read_npy("inst/extdata/test_str_unicode.npy"),
  n = 100
)

# uint8
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_uint8 = read_npy("inst/extdata/test_uint8.npy"),
  n = 100
)

# uint16
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_uint16 = read_npy("inst/extdata/test_uint16.npy"),
  n = 100
)

# uint32
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_uint32 = read_npy("inst/extdata/test_uint32.npy"),
  n = 100
)

# uint64
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_uint64 = read_npy("inst/extdata/test_uint64.npy"),
  n = 100
)

# More ----------

# npz
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_npz = read_npz("inst/extdata/test.npz"),
  n = 100
)

# bigendian
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_bigendian = read_npy("inst/extdata/test_bigendian.npy"),
  n = 100
)

# empty
touchstone::benchmark_run(
  {
    library(grumpy)
  },
  read_empty = read_npy("inst/extdata/test_empty.npy"),
  n = 100
)

touchstone::benchmark_analyze()
