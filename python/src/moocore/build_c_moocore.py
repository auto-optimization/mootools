"""C library compilation config

This script is part of the compilation of the C library using CFFi. 

Every time a new C function is created, its prototype must be added to the `ffibuilder.cdef` function call

The header files required must be placed in the first argument of `ffibuilder.set_source`, and any additional `.C` files must be added to the `sources` argument of `ffibuilder.set_source`

"""
import os
import cffi

ffibuilder = cffi.FFI()

file_path = os.path.dirname(os.path.realpath(__file__))
libmoocore_path = os.path.join(file_path, "libmoocore")

with open("src/moocore/libmoocore.h") as f:
    ffibuilder.cdef(f.read())


ffibuilder.set_source(
    "moocore._libmoocore",
    """
    #include "io.h"
    #include "hv.h"   
    #include "igd.h" 
    #include "nondominated.h"
    #include "epsilon.h"
    #include "eaf.h"
    """,
    sources= [ "src/moocore/libmoocore/" + f for f in [
        "avl.c",
        "eaf.c",
        "eaf3d.c",
        "hv.c",
        "io.c",
        "libutil.c", # For fatal_error()
    ]],
    include_dirs=[libmoocore_path],
    extra_compile_args = ["-flto", "-march=native", "-Ofast"],
    extra_link_args = ["-flto",  "-march=native", "-Ofast"],
)

if __name__ == "__main__":
    ffibuilder.compile(verbose=True)
