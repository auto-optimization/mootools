#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Error.h>
#include <R_ext/Memory.h>

#include "common.h"

#define CHECK_ARG_IS_NUMERIC_VECTOR(A)					\
    if (!Rf_isReal(A) || !Rf_isVector(A))					\
	Rf_error("Argument '" #A "' is not a numeric vector");

#define CHECK_ARG_IS_INT_VECTOR(A)					\
    if (!Rf_isInteger(A) || !Rf_isVector(A))					\
	Rf_error("Argument '" #A "' is not an integer vector");

#define CHECK_ARG_IS_LOGICAL_VECTOR(A)					\
    if (!Rf_isLogical(A) || !Rf_isVector(A))					\
	Rf_error("Argument '" #A "' is not a logical vector");

/* The C API of R is awfully ugly and unpractical (and poorly
   documented). These wrappers make it a little more bearable. */

#define Rexp(VAR) Rexp_##VAR

#define new_real_matrix(VAR, DIM1, DIM2)                                 \
    SEXP Rexp_##VAR; double *VAR;                                        \
    PROTECT(Rexp_##VAR = Rf_allocMatrix(REALSXP, (DIM1), (DIM2)));          \
    nprotected++; VAR = REAL(Rexp_##VAR)

#define new_real_vector(VAR, DIM)                                        \
    SEXP Rexp_##VAR; double *VAR;                                        \
    PROTECT(Rexp_##VAR = Rf_allocVector(REALSXP, (DIM)));                   \
    nprotected++; VAR = REAL(Rexp_##VAR)

#define new_int_vector(VAR, DIM)                                        \
    SEXP Rexp_##VAR; int *VAR;                                          \
    PROTECT(Rexp_##VAR = Rf_allocVector(INTSXP, (DIM)));                   \
    nprotected++; VAR = INTEGER(Rexp_##VAR)

#define new_string_vector(VAR, DIM)                                            \
    SEXP Rexp_##VAR; int Rexp_##VAR##_len = 0;                                 \
    PROTECT(Rexp_##VAR = Rf_allocVector(STRSXP, (DIM)));                          \
    nprotected++

#define string_vector_push_back(VAR, ELEMENT)                                  \
    SET_STRING_ELT(Rexp_##VAR, Rexp_##VAR##_len, Rf_mkChar(ELEMENT));             \
    Rexp_##VAR##_len++

#define new_list(LISTVAR, LENGTH)                                              \
    SEXP Rexp_##LISTVAR; int Rexp_##LISTVAR##_len = 0;                         \
    PROTECT(Rexp_##LISTVAR = Rf_allocVector(VECSXP, (LENGTH)));                   \
    ++nprotected

#define new_logical_vector(VAR, DIM)                                           \
    SEXP Rexp_##VAR; int *VAR;                                                 \
    PROTECT(Rexp_##VAR = Rf_allocVector(LGLSXP, (DIM)));                          \
    nprotected++; VAR = LOGICAL(Rexp_##VAR)

#define list_len(VAR) Rexp_##VAR##_len

#define list_push_back(LISTVAR, ELEMENT)                                       \
    SET_VECTOR_ELT(Rexp_##LISTVAR, Rexp_##LISTVAR##_len, Rexp_##ELEMENT);      \
    Rexp_##LISTVAR##_len++

#define set_names(VAR, NAMES)                                                  \
    Rf_setAttrib(Rexp_##VAR, R_NamesSymbol, Rexp_##NAMES)

#define set_attribute(VAR, ATTRIBUTE, VALUE)                                   \
    Rf_setAttrib(Rexp_##VAR, Rf_install(ATTRIBUTE), Rexp_##VALUE)

/*
 * Unpack an integer vector stored in SEXP S.
 */
#define SEXP_2_DOUBLE_VECTOR(S, I, N)                \
    CHECK_ARG_IS_NUMERIC_VECTOR(S);                  \
    double *I = REAL(S);                             \
    const R_len_t N = Rf_length(S);

#define SEXP_2_INT_VECTOR(S, I, N)               \
    CHECK_ARG_IS_INT_VECTOR(S);                  \
    int *I = INTEGER(S);                         \
    const R_len_t N = Rf_length(S);

#define SEXP_2_LOGICAL_VECTOR(S, I, N)               \
    CHECK_ARG_IS_LOGICAL_VECTOR(S);                  \
    int *I = LOGICAL(S);                             \
    const R_len_t N = Rf_length(S);

#define SEXP_2_INT(S,VAR)                                               \
    int VAR = Rf_asInteger(S);                                             \
    if (VAR == NA_INTEGER)                                              \
        Rf_error ("Argument '" #S "' is not an integer");

#define SEXP_2_LOGICAL(S,VAR)                                           \
    int VAR = Rf_asLogical(S);                                             \
    if (VAR == NA_LOGICAL)                                              \
        Rf_error ("Argument '" #S "' is not a logical");

#define SEXP_2_STRING(S,var)                                            \
    if (!Rf_isString(S) || Rf_length(S) != 1)                                 \
        Rf_error ("Argument '" #S "' is not a string");                    \
    const char * var = CHAR(STRING_ELT(S,0));

static inline void
bool_2_logical_vector(int *dst, const bool *src, size_t n)
{
    for (size_t i = 0; i < n; i++)
        dst[i] = src[i];
}

/* FIXME: Measure if this is faster than the R implementation of t()  */
static inline void
double_transpose(double *dst, const double *src,
                 const size_t nrows, const size_t ncols)
{
    size_t j, i, pos = 0;
    
    for (j = 0; j < ncols; j++) {
        for (i = 0; i < nrows; i++) {
            dst[pos] = src[j + i * ncols];
            pos++;
        }
    }
}

static inline SEXP
set_colnames(SEXP matrix, const char *const * names, size_t names_len)
{
    int nprotected=0;
    SEXP dimnames = Rf_getAttrib(matrix, R_DimNamesSymbol);
    if (dimnames == R_NilValue) {
        PROTECT(dimnames = Rf_allocVector(VECSXP, 2));
        nprotected++;
    }
       
    new_string_vector (colnames, names_len);
    for (size_t k = 0; k < names_len; k++) {
        string_vector_push_back (colnames, names[k]);
    }
    SET_VECTOR_ELT(dimnames, 1, Rexp(colnames));
    Rf_setAttrib(matrix, R_DimNamesSymbol, dimnames);

    UNPROTECT(nprotected);
    return(matrix);
}
