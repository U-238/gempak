#
#	Makefile for GEMPAK 6.0
#		Builds program makefiles
#		Unidata 11/99 Chiz
#
include $(CONFIGDIR)/$(MAKEINC)

COBJS = 

PROG = spctxt
PROG.c = spctxt.c
 

LIBINC = \
	$(GEMLIB) \
	$(OS_LIB)/textlib.a \
	$(CGEMLIB) \
	$(GEMLIB)

all : $(PROG)

$(PROG): $(LIBINC) $(PROG.c)
	$(COMPILE.c) $(PROG.c) 
	$(LINK.f) $(NOFORMAIN) $@.o $(LIBINC) -lm -o $@

clean:
	$(RM) *.o $(PROG)

install: $(PROG)
	$(INSTALL) $(PROG) $(OS_BIN)

