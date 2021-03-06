/*
  Copyright 1999-2014 ImageMagick Studio LLC, a non-profit organization
  dedicated to making software imaging solutions freely available.
  
  You may not use this file except in compliance with the License.
  obtain a copy of the License at
  
    http://www.imagemagick.org/script/license.php
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  MagickCore version methods.
*/
#ifndef _MAGICKCORE_VERSION_H
#define _MAGICKCORE_VERSION_H

#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif

/*
  Define declarations.
*/
#if defined(SPEC)
# define MagickPackageName "ImageMagick (CPU2017 version)"
#else
#define MagickPackageName "ImageMagick"
#endif
#define MagickCopyright  "Copyright (C) 1999-2014 ImageMagick Studio LLC"
#define MagickSVNRevision  "15698"
#define MagickLibVersion  0x689
#define MagickLibVersionText  "6.8.9"
#define MagickLibVersionNumber  2,0,0
#define MagickLibAddendum  "-1"
#define MagickLibInterface  2
#define MagickLibMinInterface  2
#if defined(SPEC)
# define MagickPlatform "generic"
#else
#if defined(_WINDOWS)
#  if defined(_WIN64)
#    define MagickPlatform "x64"
#  else
#    define MagickPlatform "x86"
#  endif
#else
#define MagickPlatform  "x86_64"
#endif
#endif /* !SPEC */
#define MagickppLibVersionText  "6.8.9"
#define MagickppLibVersionNumber  3:0:0
#define MagickppLibAddendum  "-1"
#define MagickppLibInterface  3
#define MagickppLibMinInterface  3
#define MagickReleaseDate  "2014-05-09"
#define MagickChangeDate   "20140509"
#define MagickFeatures "DPC OpenMP"
#define MagickDelegates "tiff"
#define MagickHomeURL  "file:///usr/share/doc/ImageMagick-6/index.html"
#if defined(SPEC)
# define MagickAuthoritativeURL  "http://www.spec.org/cpu2017 (http://www.imagemagick.org for the original version)"
#else
#define MagickAuthoritativeURL  "http://www.imagemagick.org"
#endif
#if (MAGICKCORE_QUANTUM_DEPTH == 8)
#define MagickQuantumDepth  "Q8"
#define MagickQuantumRange  "255"
#elif (MAGICKCORE_QUANTUM_DEPTH == 16)
#define MagickQuantumDepth  "Q16"
#define MagickQuantumRange  "65535"
#elif (MAGICKCORE_QUANTUM_DEPTH == 32)
#define MagickQuantumDepth  "Q32"
#define MagickQuantumRange  "4294967295"
#elif (MAGICKCORE_QUANTUM_DEPTH == 64)
#define MagickQuantumDepth  "Q64"
#define MagickQuantumRange  "18446744073709551615.0"
#else
#define MagickQuantumDepth  "Q?"
#define MagickQuantumRange  "?"
#endif
#define MagickVersion  \
  MagickPackageName " " MagickLibVersionText MagickLibAddendum " " \
  MagickQuantumDepth " " MagickPlatform " " MagickReleaseDate " " \
  MagickAuthoritativeURL

extern MagickExport char
  *GetMagickHomeURL(void);

extern MagickExport const char
  *GetMagickCopyright(void),
  *GetMagickDelegates(void),
  *GetMagickFeatures(void),
  *GetMagickPackageName(void),
  *GetMagickQuantumDepth(size_t *),
  *GetMagickQuantumRange(size_t *),
  *GetMagickReleaseDate(void),
  *GetMagickVersion(size_t *);

extern MagickExport void
  ListMagickVersion(FILE *);

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

#endif
