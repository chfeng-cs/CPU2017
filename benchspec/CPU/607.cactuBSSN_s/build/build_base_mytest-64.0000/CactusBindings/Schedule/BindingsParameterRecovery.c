/*@@
   @file       BindingsParameterRecovery.c
   @author     Automatically generated by CreateScheduleBindings.pl
   @desc
               Calls all the thorn parameter recovery bindings file if the thorns are active.
   @enddesc
  @@*/

#include "cctk_ActiveThorns.h"

/* Prototypes for functions to be registered. */
int CCTKi_BindingsParameterRecovery_ADMBase(void);
int CCTKi_BindingsParameterRecovery_ADMCoupling(void);
int CCTKi_BindingsParameterRecovery_ADMMacros(void);
int CCTKi_BindingsParameterRecovery_Boundary(void);
int CCTKi_BindingsParameterRecovery_Cactus(void);
int CCTKi_BindingsParameterRecovery_CartGrid3D(void);
int CCTKi_BindingsParameterRecovery_CoordBase(void);
int CCTKi_BindingsParameterRecovery_CoordGauge(void);
int CCTKi_BindingsParameterRecovery_Fortran(void);
int CCTKi_BindingsParameterRecovery_GaugeWave(void);
int CCTKi_BindingsParameterRecovery_GenericFD(void);
int CCTKi_BindingsParameterRecovery_IOASCII(void);
int CCTKi_BindingsParameterRecovery_IOBasic(void);
int CCTKi_BindingsParameterRecovery_IOUtil(void);
int CCTKi_BindingsParameterRecovery_LocalReduce(void);
int CCTKi_BindingsParameterRecovery_ML_BSSN(void);
int CCTKi_BindingsParameterRecovery_ML_BSSN_Helper(void);
int CCTKi_BindingsParameterRecovery_MoL(void);
int CCTKi_BindingsParameterRecovery_PUGH(void);
int CCTKi_BindingsParameterRecovery_PUGHInterp(void);
int CCTKi_BindingsParameterRecovery_PUGHReduce(void);
int CCTKi_BindingsParameterRecovery_PUGHSlab(void);
int CCTKi_BindingsParameterRecovery_StaticConformal(void);
int CCTKi_BindingsParameterRecovery_SymBase(void);
int CCTKi_BindingsParameterRecovery_Time(void);
int CCTKi_BindingsParameterRecovery_TmunuBase(void);
int CCTKi_BindingsParameterRecoveryInitialise(void);

int CCTKi_BindingsParameterRecoveryInitialise(void)
{
  int result;
  int retval = 0;

  do
  {
    if(CCTK_IsThornActive("ADMBase"))
    {
      result = CCTKi_BindingsParameterRecovery_ADMBase();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("ADMCoupling"))
    {
      result = CCTKi_BindingsParameterRecovery_ADMCoupling();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("ADMMacros"))
    {
      result = CCTKi_BindingsParameterRecovery_ADMMacros();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("Boundary"))
    {
      result = CCTKi_BindingsParameterRecovery_Boundary();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("Cactus"))
    {
      result = CCTKi_BindingsParameterRecovery_Cactus();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("CartGrid3D"))
    {
      result = CCTKi_BindingsParameterRecovery_CartGrid3D();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("CoordBase"))
    {
      result = CCTKi_BindingsParameterRecovery_CoordBase();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("CoordGauge"))
    {
      result = CCTKi_BindingsParameterRecovery_CoordGauge();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("Fortran"))
    {
      result = CCTKi_BindingsParameterRecovery_Fortran();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("GaugeWave"))
    {
      result = CCTKi_BindingsParameterRecovery_GaugeWave();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("GenericFD"))
    {
      result = CCTKi_BindingsParameterRecovery_GenericFD();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("IOASCII"))
    {
      result = CCTKi_BindingsParameterRecovery_IOASCII();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("IOBasic"))
    {
      result = CCTKi_BindingsParameterRecovery_IOBasic();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("IOUtil"))
    {
      result = CCTKi_BindingsParameterRecovery_IOUtil();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("LocalReduce"))
    {
      result = CCTKi_BindingsParameterRecovery_LocalReduce();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("ML_BSSN"))
    {
      result = CCTKi_BindingsParameterRecovery_ML_BSSN();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("ML_BSSN_Helper"))
    {
      result = CCTKi_BindingsParameterRecovery_ML_BSSN_Helper();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("MoL"))
    {
      result = CCTKi_BindingsParameterRecovery_MoL();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("PUGH"))
    {
      result = CCTKi_BindingsParameterRecovery_PUGH();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("PUGHInterp"))
    {
      result = CCTKi_BindingsParameterRecovery_PUGHInterp();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("PUGHReduce"))
    {
      result = CCTKi_BindingsParameterRecovery_PUGHReduce();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("PUGHSlab"))
    {
      result = CCTKi_BindingsParameterRecovery_PUGHSlab();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("StaticConformal"))
    {
      result = CCTKi_BindingsParameterRecovery_StaticConformal();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("SymBase"))
    {
      result = CCTKi_BindingsParameterRecovery_SymBase();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("Time"))
    {
      result = CCTKi_BindingsParameterRecovery_Time();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
    if(CCTK_IsThornActive("TmunuBase"))
    {
      result = CCTKi_BindingsParameterRecovery_TmunuBase();
      if (result != 0)
        retval = result;
      if (retval > 0)
        break;
    }
  } while (0);

  return retval;
}
