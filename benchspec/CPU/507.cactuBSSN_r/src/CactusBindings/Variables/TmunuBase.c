/*@@
   @file    TmunuBase.c
   @author  Automatically generated by GridFuncStuff.pl
   @desc
            Creates the CCTK variables for thorn TmunuBase
   @enddesc
 @@*/



#include <stddef.h>

#ifdef SPEC 
#include "TmunuBase/cctk.h" 
#define THORN_DIR "TmunuBase" 
#else 
#include "TmunuBase/cctk.h"
#endif /* END SPEC */ 
#ifdef SPEC 
#include "TmunuBase/cctk_Arguments.h" 
#else 
#include "TmunuBase/cctk_Arguments.h"
#endif /* END SPEC */ 
#include "cctk_Parameter.h"
#include "cctk_WarnLevel.h"
#include "cctki_Groups.h"
#include "cctki_FortranWrappers.h"
#include "TmunuBase/cctk_ScheduleFunctions.h"

int CactusBindingsVariables_TmunuBase_Initialise(void);
static int CCTKi_BindingsFortranWrapperTmunuBase(void *_GH, void *fpointer);

static int CCTKi_BindingsFortranWrapperTmunuBase(void *_GH, void *fpointer)
{
  cGH const *const GH = _GH;
  const int _cctk_zero = 0;
  void (*function)(TMUNUBASE_C2F_PROTO);
  DECLARE_TMUNUBASE_C2F
  INITIALISE_TMUNUBASE_C2F
  (void) (_cctk_zero + 0);

  function = (void (*) (TMUNUBASE_C2F_PROTO)) fpointer;
  function (PASS_TMUNUBASE_C2F (GH));

  return (0);
}

int CactusBindingsVariables_TmunuBase_Initialise(void)
{
  const char * warn_mixeddim_gfs = "";
  int warn_mixeddim = 0;
  const CCTK_INT *allow_mixeddim_gfs;


  allow_mixeddim_gfs = CCTK_ParameterGet ("allow_mixeddim_gfs", "Cactus", 0);

  if (CCTKi_CreateGroup ("STRESS_ENERGY_STATE", "TMUNUBASE", "TMUNUBASE",
                         "SCALAR", "INT", "PUBLIC",
                         0, 1,
                         "CONSTANT",
                         "", "",
                         "",
                         NULL,
                         1,
                         "stress_energy_state") == 1)
  {
    warn_mixeddim_gfs = "stress_energy_state";
    warn_mixeddim = 0;
  }
  if (CCTKi_CreateGroup ("STRESS_ENERGY_SCALAR", "TMUNUBASE", "TMUNUBASE",
                         "GF", "REAL", "PUBLIC",
                         3, 3,
                         "DEFAULT",
                         "", "",
                         "tensortypealias=\"Scalar\" ProlongationParameter=\"TmunuBase::prolongation_type\"",
                         NULL,
                         1,
                         "eTtt") == 1)
  {
    warn_mixeddim_gfs = "stress_energy_scalar";
    warn_mixeddim = 3;
  }
  if (CCTKi_CreateGroup ("STRESS_ENERGY_VECTOR", "TMUNUBASE", "TMUNUBASE",
                         "GF", "REAL", "PUBLIC",
                         3, 3,
                         "DEFAULT",
                         "", "",
                         "tensortypealias=\"D\" ProlongationParameter=\"TmunuBase::prolongation_type\"",
                         NULL,
                         3,
                         "eTtx",
                         "eTty",
                         "eTtz") == 1)
  {
    warn_mixeddim_gfs = "stress_energy_vector";
    warn_mixeddim = 3;
  }
  if (CCTKi_CreateGroup ("STRESS_ENERGY_TENSOR", "TMUNUBASE", "TMUNUBASE",
                         "GF", "REAL", "PUBLIC",
                         3, 3,
                         "DEFAULT",
                         "", "",
                         "tensortypealias=\"DD_sym\" ProlongationParameter=\"TmunuBase::prolongation_type\"",
                         NULL,
                         6,
                         "eTxx",
                         "eTxy",
                         "eTxz",
                         "eTyy",
                         "eTyz",
                         "eTzz") == 1)
  {
    warn_mixeddim_gfs = "stress_energy_tensor";
    warn_mixeddim = 3;
  }
  if (CCTKi_CreateGroup ("STRESS_ENERGY_2_STATE", "TMUNUBASE", "TMUNUBASE",
                         "SCALAR", "INT", "PROTECTED",
                         0, 1,
                         "CONSTANT",
                         "", "",
                         "",
                         NULL,
                         1,
                         "stress_energy_2_state") == 1)
  {
    warn_mixeddim_gfs = "stress_energy_2_state";
    warn_mixeddim = 0;
  }
  if (CCTKi_CreateGroup ("STRESS_ENERGY_2_SCALAR", "TMUNUBASE", "TMUNUBASE",
                         "GF", "REAL", "PROTECTED",
                         3, 1,
                         "DEFAULT",
                         "", "",
                         "tensortypealias=\"Scalar\" checkpoint=\"no\" prolongation=\"none\"",
                         NULL,
                         1,
                         "eT2tt") == 1)
  {
    warn_mixeddim_gfs = "stress_energy_2_scalar";
    warn_mixeddim = 3;
  }
  if (CCTKi_CreateGroup ("STRESS_ENERGY_2_VECTOR", "TMUNUBASE", "TMUNUBASE",
                         "GF", "REAL", "PROTECTED",
                         3, 1,
                         "DEFAULT",
                         "", "",
                         "tensortypealias=\"D\" checkpoint=\"no\" prolongation=\"none\"",
                         NULL,
                         3,
                         "eT2tx",
                         "eT2ty",
                         "eT2tz") == 1)
  {
    warn_mixeddim_gfs = "stress_energy_2_vector";
    warn_mixeddim = 3;
  }
  if (CCTKi_CreateGroup ("STRESS_ENERGY_2_TENSOR", "TMUNUBASE", "TMUNUBASE",
                         "GF", "REAL", "PROTECTED",
                         3, 1,
                         "DEFAULT",
                         "", "",
                         "tensortypealias=\"DD_sym\" checkpoint=\"no\" prolongation=\"none\"",
                         NULL,
                         6,
                         "eT2xx",
                         "eT2xy",
                         "eT2xz",
                         "eT2yy",
                         "eT2yz",
                         "eT2zz") == 1)
  {
    warn_mixeddim_gfs = "stress_energy_2_tensor";
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

  CCTKi_RegisterFortranWrapper("TmunuBase", CCTKi_BindingsFortranWrapperTmunuBase);

  return 0;
}
