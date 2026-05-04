import numpy as np

# Integer types
np.save("inst/extdata/test_int32.npy", np.arange(1, 13, dtype="int32"))
np.save("inst/extdata/test_int8.npy", np.array([-128, -100, -64, -32, -16, -8, -4, -2, -1, 0, 64, 127], dtype="int8"))
np.save("inst/extdata/test_int16.npy", np.array([-32768, -16384, -8192, -4096, -2048, -1024, -512, -256, -128, 0, 16383, 32767], dtype="int16"))
np.save("inst/extdata/test_int64.npy", np.arange(-5, 7, dtype="int64"))
np.save("inst/extdata/test_int64_overflowing.npy", np.array([-2**32, -2**31, -2**16, -2**8, 0, 1, 2**8, 2**16, 2**31, 2**32, 2**48, 2**63 - 1], dtype="int64"))

# Unsigned integer (stored as integer in R)
np.save("inst/extdata/test_uint8.npy", np.array([0, 10, 20, 50, 100, 128, 150, 175, 200, 210, 240, 255], dtype="uint8"))
np.save("inst/extdata/test_uint16.npy", np.array([0, 100, 1000, 5000, 10000, 20000, 32767, 40000, 50000, 55000, 60000, 65535], dtype="uint16"))
np.save("inst/extdata/test_uint32.npy", np.array([0, 1, 10, 100, 1000, 10000, 100000, 1000000, 2**16, 2**24, 2**31, 2**32 - 1], dtype="uint32"))
np.save("inst/extdata/test_uint64.npy", np.array([0, 1, 10, 100, 1000, 10000, 100000, 2**16, 2**32, 2**48, 2**63, 2**64 - 1], dtype="uint64"))

# Float types
np.save("inst/extdata/test_float32.npy", np.array([1.5, -2.5, 3.14, 0.0, -1.0, 100.0, -100.0, 0.001, 1e6, -1e6, 1.23456, -9.87654], dtype="float32"))
np.save("inst/extdata/test_float64.npy", np.array([1.5, -2.5, 3.14, 0.0, -1.0, 100.0, -100.0, 0.001, 1e6, -1e6, 1.23456789, -9.87654321], dtype="float64"))

# Boolean
np.save("inst/extdata/test_bool.npy", np.array([True, False, True, True, False, False, True, False, True, True, False, True], dtype="bool"))

# Big-endian
np.save("inst/extdata/test_bigendian.npy", np.arange(1.0, 13.0, dtype=">f4"))

# 2-D array (C order)
np.save("inst/extdata/test_2d.npy", np.arange(12, dtype="int32").reshape(3, 4))

# 3-D array
np.save("inst/extdata/test_3d.npy", np.arange(24, dtype="int32").reshape(2, 3, 4))

# Fortran order (column-major)
np.save("inst/extdata/test_fortran.npy", np.asfortranarray(np.arange(12, dtype="int32").reshape(3, 4)))

# Single element
np.save("inst/extdata/test_scalar.npy", np.array([42.0], dtype="float32"))

# Empty array
np.save("inst/extdata/test_empty.npy", np.array([], dtype="float32"))

# String types (unicode and byte strings)
np.save("inst/extdata/test_str_unicode.npy", np.array(['¡Hola mundo!', 'Hej Världen!', 'Servus Woid!', 'Hei maailma!', 'Xin chào thế giới', 'Njatjeta Botë!', 'Γεια σου κόσμε!', 'こんにちは世界', '世界，你好！', 'Helló, világ!', 'Zdravo svete!', 'เฮลโลเวิลด์'], dtype="U20"))
np.save("inst/extdata/test_str_bytes.npy", np.array([b"foo", b"bar", b"baz", b"qux", b"hello", b"world", b"alpha", b"beta", b"gamma", b"delta", b"eps", b"zeta"], dtype="S5"))

# NPZ archive (multiple arrays)
np.savez(
    "inst/extdata/test.npz",
    x=np.array([1, 2, 3], dtype="int32"),
    y=np.array([4.0, 5.0, 6.0], dtype="float64"),
)
