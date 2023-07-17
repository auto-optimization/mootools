#ifndef   	LIBMISC_COMMON_H_
# define   	LIBMISC_COMMON_H_

#ifdef R_PACKAGE
#define R_NO_REMAP
#include <R.h>
#define eaf_assert(EXP)                                                       \
    do { if (!(EXP)) { Rf_error("eaf package: error: assertion failed: '%s' at %s:%d",    \
                             #EXP, __FILE__, __LINE__);}} while(0)
#define fatal_error(...) Rf_error(__VA_ARGS__)
#define errprintf Rf_error
#define warnprintf Rf_warning
#include "gcc_attribs.h"
#else
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include "gcc_attribs.h"
#include <assert.h>
#define eaf_assert(X) assert(X)
#define Rprintf(...) printf(__VA_ARGS__)
void fatal_error(const char * format,...) __attribute__ ((format(printf, 1, 2))) __noreturn __unused;
void errprintf(const char * format,...) __attribute__ ((format(printf, 1, 2)));
void warnprintf(const char *format,...)  __attribute__ ((format(printf, 1, 2)));
#endif

#if __GNUC__ >= 3
#define MAX(x,y) __extension__({                        \
            __typeof__(x) _x__ = (x);                   \
            __typeof__(y) _y__ = (y);                   \
            _x__ > _y__ ? _x__ : _y__; })
#define MIN(x,y) __extension__({                        \
            __typeof__(x) _x__ = (x);                   \
            __typeof__(y) _y__ = (y);                   \
            _x__ < _y__ ? _x__ : _y__; })
#define CLAMP(x, xmin, xmax) __extension__({                                   \
            __typeof__(x) _x__ = (x);                                          \
            __typeof__(x) _xmin__ = (xmin);                                    \
            __typeof__(x) _xmax__ = (xmax);                                    \
            _x__ < _xmin__ ? _xmin__ : _x__ > _xmax__ ? _xmax__ : _x__; })
#else
#define MAX(x,y) ((x) > (y) ? (x) : (y))
#define MIN(x,y) ((x) < (y) ? (x) : (y))
#define CLAMP(x, xmin, xmax) MAX(xim, MIN(x, xmax))
#endif


#define DEBUG_DO(X)     do{ X;} while(0)
#define DEBUG_NOT_DO(X) while(0){ X;}

#if DEBUG >= 1
#define DEBUG1(X) DEBUG_DO(X)
#else  
#define DEBUG1(X) DEBUG_NOT_DO(X)
#endif

#if DEBUG >= 2
#define DEBUG2(X) DEBUG_DO(X)
#else  
#define DEBUG2(X) DEBUG_NOT_DO(X)
#endif

#if DEBUG >= 3
#define DEBUG3(X) DEBUG_DO(X)
#else  
#define DEBUG3(X) DEBUG_NOT_DO(X)
#endif

#if DEBUG >= 4
#define DEBUG4(X) DEBUG_DO(X)
#else  
#define DEBUG4(X) DEBUG_NOT_DO(X)
#endif

#ifndef R_PACKAGE
#define DEBUG2_PRINT(...) DEBUG2 (fprintf (stderr,  __VA_ARGS__))
#else
#define DEBUG2_PRINT(...) DEBUG2 (Rprintf ( __VA_ARGS__))
#endif

#define DEBUG2_FUNPRINT(...)                    \
    do { DEBUG2_PRINT ("%s(): ", __FUNCTION__); \
         DEBUG2_PRINT (__VA_ARGS__); } while(0)


/* This is deprecated. See https://www.gnu.org/software/libc/manual/html_node/Heap-Consistency-Checking.html
#if DEBUG >= 1
#ifndef MALLOC_CHECK_
#define MALLOC_CHECK_ 3
#endif
#endif
*/
#include <stdbool.h>
#define TRUE  true
#define FALSE false

#ifndef ignore_unused_result
#define ignore_unused_result(X)  do { if(X) {}} while(0);
#endif

typedef unsigned long ulong;
typedef long long longlong;

static inline const char *str_is_default(bool flag)
{
    return flag ? "(default)" : "";
}

#endif 	    /* !LIBMISC_COMMON_H_ */
