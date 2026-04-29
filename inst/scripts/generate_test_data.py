import numpy as np

# Integer types
np.save("inst/extdata/test_int32.npy", np.array([1, 2, 3], dtype="int32"))
np.save("inst/extdata/test_int8.npy", np.array([-128, 0, 127], dtype="int8"))
np.save("inst/extdata/test_int16.npy", np.array([-32768, 0, 32767], dtype="int16"))
np.save("inst/extdata/test_int64.npy", np.array([-2**32, 0, 2**32], dtype="int64"))

# Unsigned integer (stored as integer in R)
np.save("inst/extdata/test_uint8.npy", np.array([0, 128, 255], dtype="uint8"))
np.save("inst/extdata/test_uint16.npy", np.array([0, 1000, 65535], dtype="uint16"))

# Float types
np.save("inst/extdata/test_float32.npy", np.array([1.5, -2.5, 3.14], dtype="float32"))
np.save("inst/extdata/test_float64.npy", np.array([1.5, -2.5, 3.14], dtype="float64"))

# Boolean
np.save("inst/extdata/test_bool.npy", np.array([True, False, True], dtype="bool"))

# Big-endian
np.save("inst/extdata/test_bigendian.npy", np.array([1.0, 2.0, 3.0], dtype=">f4"))

# 2-D array (C order)
np.save("inst/extdata/test_2d.npy", np.arange(6, dtype="int32").reshape(2, 3))

# 3-D array
np.save("inst/extdata/test_3d.npy", np.arange(24, dtype="int32").reshape(2, 3, 4))

# Fortran order (column-major)
np.save("inst/extdata/test_fortran.npy", np.asfortranarray(np.arange(6, dtype="int32").reshape(2, 3)))

# Single element
np.save("inst/extdata/test_scalar.npy", np.array([42.0], dtype="float32"))

# Empty array
np.save("inst/extdata/test_empty.npy", np.array([], dtype="float32"))

# String types (unicode and byte strings)
np.save("inst/extdata/test_str_unicode.npy", np.array(["foo", "bar", "baz"], dtype="U3"))
np.save("inst/extdata/test_str_bytes.npy", np.array([b"foo", b"bar", b"baz"], dtype="S3"))
