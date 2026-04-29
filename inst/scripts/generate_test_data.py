import numpy as np

np.save(
    "inst/extdata/test_longdtype.npy", np.array([1, 2, 3], dtype = "int32")
)
