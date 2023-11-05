import numpy as np
from moocore.c_bindings import ffi


def np2d_to_double_array(x):
    x = np.ascontiguousarray(x)
    nrows = ffi.cast("int", x.shape[0])
    ncols = ffi.cast("int", x.shape[1])
    x_p = ffi.from_buffer("double []", x)
    return x_p, nrows, ncols


def np1d_to_double_array(x):
    x = np.ascontiguousarray(x)
    size = ffi.cast("int", x.shape[0])
    x = ffi.from_buffer("double []", x)
    return x, size


def atleast_1d_of_length_n(x, n):
    x = np.atleast_1d(x)
    if len(x) == 1:
        x = np.full((n), x[0])
    elif x.shape[0] != n:
        raise ValueError(
            f"array must have same number of elements as data columns {x.shape[0]} != {n}"
        )
    return x

