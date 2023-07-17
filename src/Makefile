#-----------------------------------------------------------------------

#  Makefile for mootools

VERSION = 1.0.$(REVISION)

#-----------------------------------------------------------------------

#                        Copyright (c) 2007, 2008, 2009, 2010
#           Manuel Lopez-Ibanez  <manuel.lopez-ibanez@manchester.ac.uk>

#  This program is free software (software libre); you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.

#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, you can obtain a copy of the GNU
#  General Public License at:
#                  http://www.gnu.org/copyleft/gpl.html
#  or by writing to:
#            Free Software Foundation, Inc., 59 Temple Place,
#                  Suite 330, Boston, MA 02111-1307 USA
#
#-----------------------------------------------------------------------
# IMPORTANT NOTE: Please be aware that the fact that this program is
# released as Free Software does not excuse you from scientific
# propriety, which obligates you to give appropriate credit! If you
# write a scientific paper describing research that made substantive
# use of this program, it is your obligation as a scientist to
# acknowledge its use.  Moreover, as a personal note, I would
# appreciate it if you would email manuel.lopez-ibanez@manchester.ac.uk with
# citations of papers referencing this work so I can mention them to
# my funding agent and tenure committee.
#-----------------------------------------------------------------------
DEBUG?=1
BINDIR:=.

## Define source files
SRCS  = igd.c epsilon.c dominatedsets.c nondominated.c io.c ndsort.c hv_contrib.c hv.c pareto.c whv.c whv_hype.c
HEADERS = io.h io_priv.h common.h gcc_attribs.h igd.h epsilon.h nondominated.h hv.h cmdline.h whv.h whv_hype.h
OBJS  = $(SRCS:.c=.o)
DIST_OTHER_FILES = Makefile README LICENSE git_version *.mk

-include Makevars
# We do not need $(GSL_LIBS) yet because we don't compile whv_hype.c into any executable.
EXE_LDFLAGS=-lm 

ECHO = @echo "$(1)"

include gitversion.mk
include gcc.mk

EXE_CFLAGS += $(OPT_CFLAGS) $(GSL_CFLAGS) $(WARN_CFLAGS) \
	-D_GNU_SOURCE -DDEBUG=$(DEBUG) -DVERSION=\"$(VERSION)\" -DMARCH='"$(gcc-guess-march)"'

igd = $(BINDIR)/igd$(EXE)
epsilon = $(BINDIR)/epsilon$(EXE)
dominatedsets = $(BINDIR)/dominatedsets$(EXE)
nondominated = $(BINDIR)/nondominated$(EXE)
ndsort = $(BINDIR)/ndsort$(EXE)

.PHONY : all clean distclean dist default 

default: Makevars $(igd) $(epsilon) $(dominatedsets) $(nondominated) $(ndsort)

configure: configure.ac
	autoreconf configure.ac

Makevars: configure Makevars.in
	./configure

$(igd) : OBJS=igd.o io.o
$(igd) : igd.o io.o $(HEADERS)

$(epsilon) : OBJS=epsilon.o io.o
$(epsilon) : epsilon.o io.o $(HEADERS)

$(dominatedsets) : OBJS=dominatedsets.o io.o
$(dominatedsets) : dominatedsets.o io.o $(HEADERS)


$(nondominated) : OBJS=nondominated.o io.o
$(nondominated) : nondominated.o io.o $(HEADERS)

include libhv.mk

$(ndsort) : OBJS=ndsort.o pareto.o io.o hv_contrib.c $(HV_OBJS)
$(ndsort) : $(OBJS) $(HEADERS)

$(igd) $(epsilon) $(nondominated) $(dominatedsets) $(ndsort):
	@mkdir -p $(BINDIR)
	$(call ECHO,--> Building $@ version $(VERSION) <---)
	$(CC) -o $@  $(OBJS) $(EXE_CFLAGS) $(CFLAGS) $(EXE_LDFLAGS)

$(OBJS) : $(HEADERS)

clean :
	@$(RM) config.status config.log Makevars
	$(call ECHO,---> Removing $(igd) <---)
	@$(RM) $(igd)

	$(call ECHO,---> Removing $(epsilon) <---)
	@$(RM) $(epsilon)

	$(call ECHO,---> Removing $(dominatedsets) <---)
	@$(RM) $(dominatedsets)

	$(call ECHO,---> Removing $(nondominated) <---)
	@$(RM) $(nondominated)

	$(call ECHO,---> Removing $(ndsort) <---)
	@$(RM) $(ndsort)

	$(call ECHO,---> Removing object files: $(OBJS) <---)
	@$(RM) $(OBJS) $(HV_OBJS)

all : clean
	$(MAKE) default

%.o : %.c
	$(CC) $(CPPFLAGS) $(EXE_CFLAGS) $(CFLAGS) -c -o $@ $<

DIST_SRC_FILES =  $(DIST_OTHER_FILES) $(OBJS:.o=.c) $(HEADERS) 
DIST_SRC := mootools-$(VERSION)-src
dist : DEBUG=0
dist : CDEBUG=
dist : all
	@(mkdir -p ../$(DIST_SRC) \
	&& rsync -rlpC --exclude=.svn $(DIST_SRC_FILES) ../$(DIST_SRC)/ \
	&& cd .. \
	&& tar cf - $(DIST_SRC) | gzip -f9 > $(DIST_SRC).tar.gz \
	&& rm -rf ./$(DIST_SRC)/* && rmdir ./$(DIST_SRC)/ \
	&& echo "$(DIST_SRC).tar.gz created." && cd $(PWD) )

TAGS: *.c *.h
	etags *.c *.h
