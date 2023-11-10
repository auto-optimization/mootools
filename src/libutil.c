/* Functions that behave differently for library code and command-line code. */

#include "common.h"

#ifndef R_PACKAGE
void fatal_error(const char *format,...)
{
    va_list ap;
    va_start(ap, format);
    vfprintf(stderr, format, ap);
    va_end(ap);
    exit(EXIT_FAILURE);
}
#endif // R_PACKAGE

