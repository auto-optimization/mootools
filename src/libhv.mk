# -*- Makefile-gmake -*-
HV_SRCS    = hv.c
HV_HDRS    = hv.h
HV_OBJS    = $(HV_SRCS:.c=.o)

## Dependencies:
$(HV_OBJS): $(HV_HDRS)
