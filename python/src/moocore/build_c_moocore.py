"""C library compilation config

This script is part of the compilation of the C library using CFFi. 

Every time a new C function is created, its prototype must be added to the `ffibuilder.cdef` function call

The header files required must be placed in the first argument of `ffibuilder.set_source`, and any additional `.C` files must be added to the `sources` argument of `ffibuilder.set_source`

"""
import os
import cffi

ffibuilder = cffi.FFI()

# FIXME: Can we generate this automatically or read it from a pyeaf.h file?
ffibuilder.cdef(
    """
    int read_datasets(const char * filename, double **data_p, int *ncols_p, int *datasize_p);
    double fpli_hv(const double *data, int d, int n, const double *ref);
    double IGD (const double *data, int nobj, int npoints, const double *ref, int ref_size, const bool * maximise);
    double IGD_plus (const double *data, int nobj, int npoints, const double *ref, int ref_size, const bool * maximise);
    double avg_Hausdorff_dist (const double *data, int nobj, int npoints, const double *ref, int ref_size, const bool * maximise, unsigned int p);
    double epsilon_additive (const double *data, int nobj, int npoints, const double *ref, int ref_size, const bool * maximise);
    double epsilon_mult (const double *data, int nobj, int npoints, const double *ref, int ref_size, const bool * maximise);
    bool * is_nondominated (const double * data, int nobj, int npoint, const bool * maximise, bool keep_weakly);
    void agree_normalise (double *data, int nobj, int npoint, const bool * maximise, const double lower_range, const double upper_range, const double *lbound, const double *ubound);
    double * eaf_compute_matrix (int *eaf_npoints, double * data, int nobj, const int *cumsizes, int nruns, const double * percentile, int nlevels);
    """
)

file_path = os.path.dirname(os.path.realpath(__file__))
libmoocore_path = os.path.join(file_path, "libmoocore")
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
        "cmdline.c", # For fatal_error()
    ]],
    include_dirs=[libmoocore_path],
#    extra_compile_args = ["-flto"],
#    extra_link_args = ["-flto"],
)

if __name__ == "__main__":
    ffibuilder.compile(verbose=True)
