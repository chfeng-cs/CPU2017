#
# Makefile for specinvoke on Windows with MinGW GCC
# Copyright 2009-2016 Standard Performance Evaluation Corporation
#
# $Id: Makefile 4355 2016-05-26 21:05:46Z CloyceS $

BITS  ?= 64

all: specinvoke.exe
CC     = gcc
CFLAGS = -m$(BITS) -O3 -Wall -Wextra -Wno-pedantic-ms-format -pedantic -std=gnu99 -I. -I.. -DNO_NEED_PID_T
# In case specsh.exe is available, this ensures that it's not used
SHELL  = cmd

SOURCES = ../specinvoke.c ../win32.c ../getopt.c
OBJS = $(SOURCES:.c=.o)

specinvoke.exe: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

cleanobjs:
	del /s /q /f $(subst /,\\,$(OBJS))
	del /s /q /f ..\*.pdb ..\*.ilk ..\*.obj ..\*.o

clean: cleanobjs
	del /s /q /f specinvoke.exe

distclean: clean

%.o: %.c ../specinvoke.h
	$(CC) $(CFLAGS) -c -o $@ $<
