/*@@
   @file       SchedulePUGHSlab.c
   @author     Automatically generated by CreateScheduleBindings.pl
   @desc
               Creates the schedule and parameter recovery bindings 
               for thorn PUGHSlab
   @enddesc
@@*/


#ifdef SPEC 
#include "PUGHSlab/cctk.h" 
#define THORN_DIR "PUGHSlab" 
#else 
#include "PUGHSlab/cctk.h"
#endif /* END SPEC */ 
#include "PUGHSlab/CParameters.h"
#include "cctki_ScheduleBindings.h"
#include "PUGHSlab/cctk_ScheduleFunctions.h"

/* Prototypes for Fortran schedule bindings functions to be registered */
/* Note that this is a cheat, we just need a function pointer. */


void CCTKi_BindingsSchedule_PUGHSlab(void);
void CCTKi_BindingsSchedule_PUGHSlab(void)
{
  DECLARE_CCTK_PARAMETERS
}

/*@@
  @routine    CCTKi_BindingsParameterRecovery_PUGHSlab
  @author     Automatically generated by CreateScheduleBindings.pl
  @desc
              Creates the parameter recovery bindings for thorn PUGHSlab
  @enddesc
@@*/

int CCTKi_BindingsParameterRecovery_PUGHSlab(void);
int CCTKi_BindingsParameterRecovery_PUGHSlab(void)
{
  /* this thorn doesn't define any parameter recovery routines */
  return (0);
}
