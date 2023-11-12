#include <stdlib.h> // for NULL
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP compute_eaf_C(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP compute_eafdiff_area_C(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP compute_eafdiff_rectangles_C(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP compute_eafdiff_C(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP R_read_datasets(SEXP);
extern SEXP hypervolume_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT, SEXP REFERENCE);
extern SEXP hv_contributions_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT, SEXP REFERENCE);
extern void normalise_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT,
                        SEXP RANGE, SEXP LBOUND, SEXP UBOUND, SEXP MAXIMISE);

extern SEXP is_nondominated_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT, SEXP MAXIMISE, SEXP KEEP_WEAKLY);
extern SEXP pareto_ranking_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT);
extern SEXP epsilon_mul_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT,
                          SEXP REFERENCE, SEXP REFERENCE_SIZE, SEXP MAXIMISE);
extern SEXP epsilon_add_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT,
                          SEXP REFERENCE, SEXP REFERENCE_SIZE, SEXP MAXIMISE);
extern SEXP igd_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT,
                  SEXP REFERENCE, SEXP REFERENCE_SIZE, SEXP MAXIMISE);
extern SEXP igd_plus_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT,
                       SEXP REFERENCE, SEXP REFERENCE_SIZE, SEXP MAXIMISE);
extern SEXP
avg_hausdorff_dist_C(SEXP DATA, SEXP NOBJ, SEXP NPOINT,
                     SEXP REFERENCE, SEXP REFERENCE_SIZE, SEXP MAXIMISE,
                     SEXP P);
extern SEXP
rect_weighted_hv2d_C(SEXP DATA, SEXP NPOINT, SEXP RECTANGLES, SEXP RECTANGLES_NROW);

extern SEXP
whv_hype_C(SEXP DATA, SEXP NPOINTS, SEXP IDEAL, SEXP REFERENCE,
           SEXP DIST, SEXP SEED, SEXP NSAMPLES);


#define DECLARE_CALL_ENTRY(NAME, NARGS) \
    {#NAME, (DL_FUNC) &NAME, NARGS},

static const R_CallMethodDef CallEntries[] = {
    DECLARE_CALL_ENTRY(compute_eaf_C,          5)
    DECLARE_CALL_ENTRY(compute_eafdiff_area_C, 5)
    DECLARE_CALL_ENTRY(compute_eafdiff_rectangles_C, 5)
    DECLARE_CALL_ENTRY(compute_eafdiff_C,      5)
    DECLARE_CALL_ENTRY(R_read_datasets,         1)
    DECLARE_CALL_ENTRY(hypervolume_C,          4)
    DECLARE_CALL_ENTRY(hv_contributions_C,     4)
    DECLARE_CALL_ENTRY(normalise_C,            7)
    DECLARE_CALL_ENTRY(is_nondominated_C, 5)
    DECLARE_CALL_ENTRY(pareto_ranking_C,  3)
    DECLARE_CALL_ENTRY(rect_weighted_hv2d_C, 4)
    DECLARE_CALL_ENTRY(whv_hype_C, 7)
    DECLARE_CALL_ENTRY(epsilon_add_C,          6)
    DECLARE_CALL_ENTRY(epsilon_mul_C,          6)
    DECLARE_CALL_ENTRY(igd_C,                  6)
    DECLARE_CALL_ENTRY(igd_plus_C,             6)
    DECLARE_CALL_ENTRY(avg_hausdorff_dist_C,   7)
    {NULL, NULL, 0}
};

void R_init_moocore(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
