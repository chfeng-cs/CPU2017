/*@@
   @header  IOUtil_Prototypes.h
   @author  Automatically generated by CreateFunctionBindings.pl
   @desc
            Prototypes for overloaded functions used by this thorn
   @enddesc
  @@*/


#ifndef _IOUTIL_PROTOTYPES_H_
#define _IOUTIL_PROTOTYPES_H_  1

#ifdef CCODE
#ifdef __cplusplus
extern "C" {
#endif

CCTK_INT Coord_GetDefaultSystem(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT systemdim);

CCTK_INT IO_TruncateOutputFiles(const CCTK_POINTER_TO_CONST GH);
CCTK_INT IOUtil_TruncateOutputFiles(const CCTK_POINTER_TO_CONST GH);

#ifdef __cplusplus
}
#endif
#endif /* CCODE */

#ifdef FCODE
#ifdef F90CODE
#define DECLARE_IOUTIL_FUNCTIONS _DECLARE_CCTK_FUNCTIONS \
  interface &&\
     CCTK_INT function Coord_GetDefaultSystem (GH, systemdim) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       CCTK_INT systemdim &&\
     end function Coord_GetDefaultSystem &&\
  end interface &&\
  interface &&\
     CCTK_INT function IO_TruncateOutputFiles (GH) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
     end function IO_TruncateOutputFiles &&\
  end interface &&\

#else /* ! F90CODE */

#define DECLARE_IOUTIL_FUNCTIONS _DECLARE_CCTK_FUNCTIONS \
  external Coord_GetDefaultSystem &&\
  CCTK_INT Coord_GetDefaultSystem &&\
  external IO_TruncateOutputFiles &&\
  CCTK_INT IO_TruncateOutputFiles &&\

#endif /* ! F90CODE */
#endif /* FCODE */

#endif
