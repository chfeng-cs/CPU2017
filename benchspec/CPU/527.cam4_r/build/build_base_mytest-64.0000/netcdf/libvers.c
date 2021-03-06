/*
 *	Copyright 1996, University Corporation for Atmospheric Research
 *      See netcdf/COPYRIGHT file for copying and redistribution conditions.
 */
/* $Id: libvers.c,v 2.6 1999/11/02 16:49:30 steve Exp $ */

#include "netcdf.h"

/*
 * A version string.
 */
#define SKIP_LEADING_GARBAGE 33	/* # of chars prior to the actual version */
#define XSTRING(x)	#x
#define STRING(x)	XSTRING(x)
static const char nc_libvers[] =
#if !defined(SPEC)
	"\044Id: \100(#) netcdf library version " STRING(VERSION) " of "__DATE__" "__TIME__" $";
#else
	"\044Id: \100(#) netcdf library version " STRING(VERSION) " $";
#endif

const char *
nc_inq_libvers(void)
{
	return &nc_libvers[SKIP_LEADING_GARBAGE];
}

#if MAKE_PROGRAM /* TEST JIG */
#include <stdio.h>

main()
{
	(void) printf("Version: %s\n", nc_inq_libvers());
	return 0;
}
#endif
