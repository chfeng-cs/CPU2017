/*@@
   @file    Boundary.c
   @author  Automatically generated by GridFuncStuff.pl
   @desc
            Creates the CCTK variables for thorn Boundary
   @enddesc
 @@*/



#include <stddef.h>

#ifdef SPEC 
#include "Boundary/cctk.h" 
#define THORN_DIR "Boundary" 
#else 
#include "Boundary/cctk.h"
#endif /* END SPEC */ 
#ifdef SPEC 
#include "Boundary/cctk_Arguments.h" 
#else 
#include "Boundary/cctk_Arguments.h"
#endif /* END SPEC */ 
#include "cctk_Parameter.h"
#include "cctk_WarnLevel.h"
#include "cctki_Groups.h"
#include "cctki_FortranWrappers.h"
#include "Boundary/cctk_ScheduleFunctions.h"

int CactusBindingsVariables_Boundary_Initialise(void);
static int CCTKi_BindingsFortranWrapperBoundary(void *_GH, void *fpointer);

static int CCTKi_BindingsFortranWrapperBoundary(void *_GH, void *fpointer)
{
  cGH const *const GH = _GH;
  const int _cctk_zero = 0;
  void (*function)(BOUNDARY_C2F_PROTO);
  DECLARE_BOUNDARY_C2F
  INITIALISE_BOUNDARY_C2F
  (void) (_cctk_zero + 0);

  function = (void (*) (BOUNDARY_C2F_PROTO)) fpointer;
  function (PASS_BOUNDARY_C2F (GH));

  return (0);
}

int CactusBindingsVariables_Boundary_Initialise(void)
{
  const char * warn_mixeddim_gfs = "";
  int warn_mixeddim = 0;
  const CCTK_INT *allow_mixeddim_gfs;


  allow_mixeddim_gfs = CCTK_ParameterGet ("allow_mixeddim_gfs", "Cactus", 0);


  if (*warn_mixeddim_gfs)
  {
    if (allow_mixeddim_gfs && *allow_mixeddim_gfs)
    {
      CCTK_VWarn (2, __LINE__, __FILE__, "Cactus",
                  "CCTKi_CreateGroup: Working dimension already set, "
                  "creating GF group '%s' with different dimension %d",
                  warn_mixeddim_gfs, warn_mixeddim);
    }
    else
    {
      CCTK_VWarn (0, __LINE__, __FILE__, "Cactus",
                  "CCTKi_CreateGroup: Working dimension already set, "
                  "cannot create GF group '%s' with dimension %d",
                  warn_mixeddim_gfs, warn_mixeddim);
    }
 }

  CCTKi_RegisterFortranWrapper("Boundary", CCTKi_BindingsFortranWrapperBoundary);

  return 0;
}