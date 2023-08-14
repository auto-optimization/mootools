/*************************************************************************

 eaf.h: prototypes and shared types of eaf and eaf-test

 ---------------------------------------------------------------------

                    Copyright (c) 2006, 2007, 2008
                  Carlos Fonseca <cmfonsec@ualg.pt>
          Manuel Lopez-Ibanez <manuel.lopez-ibanez@manchester.ac.uk>

 This program is free software (software libre); you can redistribute
 it and/or modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2 of the
 License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, you can obtain a copy of the GNU
 General Public License at:
                 http://www.gnu.org/copyleft/gpl.html
 or by writing to:
           Free Software Foundation, Inc., 59 Temple Place,
                 Suite 330, Boston, MA 02111-1307 USA

 ----------------------------------------------------------------------

*************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <float.h>
#include <math.h>

#include "common.h"

#ifdef R_PACKAGE
#define R_NO_REMAP
#include <R.h>
#define EAF_MALLOC(WHAT, NMEMB, TYPE)                                          \
    do { WHAT = malloc (NMEMB * sizeof(TYPE));                                 \
        if (!WHAT) {                                                           \
            Rf_error(__FILE__ ": %s = malloc (%u * %u) failed",                \
                     #WHAT, (unsigned int) NMEMB, (unsigned int) sizeof(TYPE)); } \
    } while (0)
#else
#define EAF_MALLOC(WHAT, NMEMB, TYPE)                                          \
    do { WHAT = malloc (NMEMB * sizeof(TYPE));                                 \
        if (!WHAT) { perror (__FILE__ ": " #WHAT ); exit (EXIT_FAILURE); }     \
    } while(0)
#endif // R_PACKAGE

#include "io.h"

/* If the input are always integers, adjusting this type will
   certainly improve performance.  */
#ifndef objective_t
#define objective_t double
#endif
#if objective_t == double
# define objective_MAX INFINITY
# define objective_MIN -INFINITY
# define objective_t_scanf_format "%lf"
# define read_objective_t_data read_double_data
#else
# define objective_MAX INT_MAX
# define objective_MIN INT_MIN
# define objective_t_scanf_format "%d"
# define read_objective_t_data read_int_data
#endif

#include "bit_array.h"

typedef struct {
    int nobj; /* FIXME: there is no point to store this here.  */
    int nruns;
    size_t size;
    size_t maxsize;
    int nreallocs;
    bit_array *bit_attained;
    bool *attained;
    objective_t *data;
} eaf_t;


void
eaf_print_attsurf (eaf_t *,
                   FILE *coord_file, /* output file (coordinates)           */
                   FILE *indic_file, /* output file (attainment indicators) */
                   FILE *diff_file); /* output file (difference nruns/2)    */

eaf_t * eaf_create (int nobj, int nruns, int npoints);
void eaf_delete (eaf_t * eaf);
objective_t *
eaf_store_point_help (eaf_t * eaf, int nobj, const int *save_attained);

static inline int eaf_totalpoints (eaf_t **eaf, int n)
{
    int totalpoints = 0;
    int k;
    for (k = 0; k < n; k++) {
        totalpoints += eaf[k]->size;
    }
    return totalpoints;
}

eaf_t **
eaf2d (const objective_t *data,    /* the objective vectors            */
       const int *cumsize,         /* the cumulative sizes of the runs */
       int nruns,		   /* the number of runs               */
       const int *attlevel,        /* the desired attainment levels    */
       int nlevels                 /* the number of att levels         */
    );

eaf_t **
eaf3d (objective_t *data, const int *cumsize, int nruns,
       const int *attlevel, const int nlevels);

static inline eaf_t **
attsurf (objective_t *data,    /* the objective vectors            */
         int nobj,                   /* the number of objectives         */
         const int *cumsize,         /* the cumulative sizes of the runs */
         int nruns,		     /* the number of runs               */
         const int *attlevel,        /* the desired attainment levels    */
         int nlevels                 /* the number of att levels         */
    )
{
    switch (nobj) {
      case 2:
          return eaf2d (data, cumsize, nruns, attlevel, nlevels);
          break;
      case 3:
          return eaf3d (data, cumsize, nruns, attlevel, nlevels);
          break;
      default:
          fatal_error("this implementation only supports two or three dimensions.\n");
    }
}

static inline void
attained_left_right (const bit_array *attained, int division, int total,
                     int *count_left, int *count_right)
{
    eaf_assert (division < total);
    int count_l = 0;
    int count_r = 0;
    int k;

    for (k = 0; k < division; k++)
        if (bit_array_get(attained,  k)) count_l++;
    for (k = division; k < total; k++)
        if (bit_array_get(attained,  k)) count_r++;

    *count_left = count_l;
    *count_right = count_r;
}

static inline int percentile2level (double p, int n)
{
    const double tolerance = sqrt(DBL_EPSILON);
    double x = (n * p) / 100.0;
    int level = (x - floor(x) <= tolerance)
        ? (int) floor(x) : (int) ceil(x);
    
    eaf_assert(level <= n);
    eaf_assert(level >= 0);
    if (level < 1) level = 1;
    return level;
}



#define cvector_assert(X) eaf_assert(X)
#include "cvector.h"
vector_define(vector_objective, objective_t)
vector_define(vector_int, int)

typedef struct {
    vector_objective xy;
    vector_int col;
} eaf_polygon_t;

#define eaf_compute_area eaf_compute_polygon

eaf_polygon_t *eaf_compute_polygon (eaf_t **eaf, int nlevels);
eaf_polygon_t *eaf_compute_polygon_old (eaf_t **eaf, int nlevels);
void eaf_print_polygon (FILE* stream, eaf_t **eaf, int nlevels);
eaf_polygon_t * eaf_compute_rectangles (eaf_t **eaf, int nlevels);

