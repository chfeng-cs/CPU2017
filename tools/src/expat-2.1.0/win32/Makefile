#
# expat Makefile for MinGW GCC on Windows
# Copyright 2011 Standard Performance Evaluation Corporation
#
# $Id: Makefile 3751 2015-12-07 20:14:30Z CloyceS $

all: libexpat.a

CC=gcc
CFLAGS=-O2 -I. -I../lib -fexceptions -DHAVE_EXPAT_CONFIG_H -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers

LIBSRC = $(addprefix ../lib/, \
            xmlparse.c xmltok.c xmlrole.c \
          )

XMLWFSRC = $(addprefix ../xmlwf/, \
              xmlwf.c xmlfile.c codepage.c readfilemap.c \
            )

LIBOBJS = $(LIBSRC:.c=.o)
XMLWFOBJS = $(XMLWFSRC:.c=.o)

libexpat.a: $(LIBOBJS) ../lib/expat_config.h
	$(AR) r $@ $(LIBOBJS)

../lib/expat_config.h: expat_config.h
	copy expat_config.h ..\lib\expat_config.h

xmlwf.exe: $(XMLWFOBJS) libexpat.a
	$(CC) $(CFLAGS) -o $@ $(XMLWFOBJS) -L. -lexpat

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@ 

.c.i:
	$(CC) $(CFLAGS) -C -E $< > $@

clean:
	del /s /f /q ..\lib\expat_config.h ..\lib\*.o ..\xmlwf\*.o *.o *.exe *.pdb libexpat.a

distclean: clean
