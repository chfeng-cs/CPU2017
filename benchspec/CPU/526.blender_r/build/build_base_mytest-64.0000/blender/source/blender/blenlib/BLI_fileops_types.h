/*
 * ***** BEGIN GPL LICENSE BLOCK *****
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * The Original Code is Copyright (C) 2001-2002 by NaN Holding BV.
 * All rights reserved.
 *
 * The Original Code is: all of this file.
 *
 * Contributor(s): none yet.
 *
 * ***** END GPL LICENSE BLOCK *****
 */

#ifndef __BLI_FILEOPS_TYPES_H__
#define __BLI_FILEOPS_TYPES_H__

/** \file BLI_fileops_types.h
 *  \ingroup bli
 *  \brief Some types for dealing with directories.
 */

#if defined(SPEC_LINUX)
// For stat(2) types and macros
# include <sys/types.h>
# include <unistd.h>
#endif
#include <sys/stat.h>

#if defined(WIN32) && !defined(FREE_WINDOWS)
typedef unsigned int mode_t;
#endif

struct ImBuf;

struct direntry {
	mode_t  type;
	char   *relname;
	char   *path;
#ifdef WIN32 /* keep in sync with the definition of BLI_stat_t in BLI_fileops.h */
#  if defined(_MSC_VER) || defined(__MINGW64__)
	struct _stat64 s;
#  elif defined(__MINGW32__)
	struct _stati64 s;
#  else
	struct _stat s;
#  endif
#else
	struct stat s;
#endif
	unsigned int flags;
	char    size[16];
	char    mode1[4];
	char    mode2[4];
	char    mode3[4];
	char    owner[16];
	char    time[8];
	char    date[16];
	char    extra[16];
	void   *poin;
	int     nr;
	struct ImBuf *image;
	unsigned int selflag; /* selection flag */
};

struct dirlink {
	struct dirlink *next, *prev;
	char *name;
};

#if defined(SPEC)
// Provide some default values for non-POSIX mode bits, if not available
// Ideally these will match whatever the system tests against for S_ISDIR,
// etc, but if it doesn't it's probably not a big deal.
# if !defined(S_IFDIR)
#  define S_IFDIR 0040000
# endif
# if !defined(S_IFREG)
#  define S_IFREG 0100000
# endif
#endif /* SPEC */

#endif /* __BLI_FILEOPS_TYPES_H__ */

