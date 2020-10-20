/*@@
   @file    CartGrid3D.c
   @author  Automatically generated by GridFuncStuff.pl
   @desc
            Creates the CCTK variables for thorn CartGrid3D
   @enddesc
 @@*/



#include <stddef.h>

#ifdef SPEC 
#include "CartGrid3D/cctk.h" 
#define THORN_DIR "CartGrid3D" 
#else 
#include "CartGrid3D/cctk.h"
#endif /* END SPEC */ 
#ifdef SPEC 
#include "CartGrid3D/cctk_Arguments.h" 
#else 
#include "CartGrid3D/cctk_Arguments.h"
#endif /* END SPEC */ 
#include "cctk_Parameter.h"
#include "cctk_WarnLevel.h"
#include "cctki_Groups.h"
#include "cctki_FortranWrappers.h"
#include "CartGrid3D/cctk_ScheduleFunctions.h"

int CactusBindingsVariables_CartGrid3D_Initialise(void);
static int CCTKi_BindingsFortranWrapperCartGrid3D(void *_GH, void *fpointer);

static int CCTKi_BindingsFortranWrapperCartGrid3D(void *_GH, void *fpointer)
{
  cGH const *const GH = _GH;
  const int _cctk_zero = 0;
  void (*function)(CARTGRID3D_C2F_PROTO);
  DECLARE_CARTGRID3D_C2F
  INITIALISE_CARTGRID3D_C2F
  (void) (_cctk_zero + 0);

  function = (void (*) (CARTGRID3D_C2F_PROTO)) fpointer;
  function (PASS_CARTGRID3D_C2F (GH));

  return (0);
}

int CactusBindingsVariables_CartGrid3D_Initialise(void)
{
  const char * warn_mixeddim_gfs = "";
  int warn_mixeddim = 0;
  const CCTK_INT *allow_mixeddim_gfs;


  allow_mixeddim_gfs = CCTK_ParameterGet ("allow_mixeddim_gfs", "Cactus", 0);

  if (CCTKi_CreateGroup ("GRIDSPACINGS", "CARTGRID3D", "GRID",
                         "SCALAR", "REAL", "PUBLIC",
                         0, 1,
                         "CONSTANT",
                         "", "",
                         "Checkpoint=\"no\"",
                         NULL,
                         3,
                         "coarse_dx",
                         "coarse_dy",
                         "coarse_dz") == 1)
  {
    warn_mixeddim_gfs = "gridspacings";
    warn_mixeddim = 0;
  }
  if (CCTKi_CreateGroup ("COORDINATES", "CARTGRID3D", "GRID",
                         "GF", "REAL", "PUBLIC",
                         3, 1,
                         "DEFAULT",
                         "", "",
                         "Prolongation=\"None\" Checkpoint=\"no\"",
                         NULL,
                         4,
                         "x",
                         "y",
                         "z",
                         "r") == 1)
  {
    warn_mixeddim_gfs = "coordinates";
    warn_mixeddim = 3;
  }

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

  CCTKi_RegisterFortranWrapper("CartGrid3D", CCTKi_BindingsFortranWrapperCartGrid3D);

  return 0;
}