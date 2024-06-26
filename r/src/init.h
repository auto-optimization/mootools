/* .Call calls */
DECLARE_CALL(SEXP, compute_eaf_C, SEXP DATA, SEXP CUMSIZES, SEXP PERCENTILE)
DECLARE_CALL(SEXP, compute_eafdiff_C, SEXP DATA, SEXP CUMSIZES, SEXP INTERVALS)
DECLARE_CALL(SEXP, compute_eafdiff_polygon_C, SEXP DATA, SEXP CUMSIZES, SEXP INTERVALS)
DECLARE_CALL(SEXP, compute_eafdiff_rectangles_C, SEXP DATA, SEXP CUMSIZES, SEXP INTERVALS)
DECLARE_CALL(SEXP, R_read_datasets, SEXP FILENAME)
DECLARE_CALL(SEXP, hypervolume_C, SEXP DATA, SEXP REFERENCE)
DECLARE_CALL(SEXP, hv_contributions_C, SEXP DATA, SEXP REFERENCE)
DECLARE_CALL(void, normalise_C, SEXP DATA, SEXP RANGE, SEXP LBOUND, SEXP UBOUND, SEXP MAXIMISE)
DECLARE_CALL(SEXP, is_nondominated_C, SEXP DATA, SEXP MAXIMISE, SEXP KEEP_WEAKLY)
DECLARE_CALL(SEXP, pareto_ranking_C, SEXP DATA)
DECLARE_CALL(SEXP, epsilon_mul_C, SEXP DATA, SEXP REFERENCE, SEXP MAXIMISE)
DECLARE_CALL(SEXP, epsilon_add_C, SEXP DATA, SEXP REFERENCE, SEXP MAXIMISE)
DECLARE_CALL(SEXP, igd_C, SEXP DATA, SEXP REFERENCE, SEXP MAXIMISE)
DECLARE_CALL(SEXP, igd_plus_C, SEXP DATA, SEXP REFERENCE, SEXP MAXIMISE)
DECLARE_CALL(SEXP, avg_hausdorff_dist_C, SEXP DATA, SEXP REFERENCE, SEXP MAXIMISE, SEXP P)
DECLARE_CALL(SEXP, rect_weighted_hv2d_C, SEXP DATA, SEXP RECTANGLES)
DECLARE_CALL(SEXP, whv_hype_C, SEXP DATA, SEXP IDEAL, SEXP REFERENCE, SEXP NSAMPLES, SEXP DIST, SEXP SEED, SEXP MU)

