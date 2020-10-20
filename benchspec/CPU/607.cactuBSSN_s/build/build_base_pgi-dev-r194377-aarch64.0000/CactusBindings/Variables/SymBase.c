/*@@
   @file    SymBase.c
   @author  Automatically generated by GridFuncStuff.pl
   @desc
            Creates the CCTK variables for thorn SymBase
   @enddesc
 @@*/



#include <stddef.h>

#ifdef SPEC 
#include "SymBase/cctk.h" 
#define THORN_DIR "SymBase" 
#else 
#include "SymBase/cctk.h"
#endif /* END SPEC */ 
#ifdef SPEC 
#include "SymBase/cctk_Arguments.h" 
#else 
#include "SymBase/cctk_Arguments.h"
#endif /* END SPEC */ 
#include "cctk_Parameter.h"
#include "cctk_WarnLevel.h"
#include "cctki_Groups.h"
#include "cctki_FortranWrappers.h"
#include "SymBase/cctk_ScheduleFunctions.h"

int CactusBindingsVariables_SymBase_Initialise(void);
static int CCTKi_BindingsFortranWrapperSymBase(void *_GH, void *fpointer);

static int CCTKi_BindingsFortranWrapperSymBase(void *_GH, void *fpointer)
{
  cGH const *const GH = _GH;
  const int _cctk_zero = 0;
  void (*function)(SYMBASE_C2F_PROTO);
  DECLARE_SYMBASE_C2F
  INITIALISE_SYMBASE_C2F
  (void) (_cctk_zero + 0);

  function = (void (*) (SYMBASE_C2F_PROTO)) fpointer;
  function (PASS_SYMBASE_C2F (GH));

  return (0);
}

int CactusBindingsVariables_SymBase_Initialise(void)
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

  CCTKi_RegisterFortranWrapper("SymBase", CCTKi_BindingsFortranWrapperSymBase);

  return 0;
}
