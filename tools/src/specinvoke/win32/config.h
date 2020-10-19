/* config.h.  Generated from config.h.in by configure.  */
/* Copyright 1997-2015 Standard Performance Evaluation Corporation */
/* $Id: config.h 4311 2016-05-18 14:23:16Z CloyceS $ */

#define NEED_PID_T

/* Turn off some warnings */
#if !defined(_CRT_SECURE_NO_DEPRECATE)
#define _CRT_SECURE_NO_DEPRECATE 1
#endif

/*
 * These defines are just to determine which header files exist.
 */
#define HAVE_ERRNO_H 1
#define HAVE_FCNTL_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_SYS_TIMEB_H 1
#define HAVE_SYS_TIME_H 1
#define HAVE_SYS_TYPES_H 1
/* #undef HAVE_SYS_WAIT_H */
#define HAVE_STRING_H 1
#define HAVE_UNISTD_H 1
#define HAVE_STDBOOL_H 1

/*
 * Check for certain functions
 */
/* #undef HAVE_WAITPID */
#define HAVE_STRERROR 1
/* #undef HAVE_NANOSLEEP */
#define HAVE_USLEEP 1
/* #undef HAVE_SELECT */

/*
 * Define if <time.h> and <sys/time.h> may be included together
 */
#define TIME_WITH_SYS_TIME 1

/* Editor settings: (please leave this at the end of the file)
 * vim: set filetype=c syntax=c shiftwidth=4 tabstop=8 expandtab nosmarttab ai:
 */
