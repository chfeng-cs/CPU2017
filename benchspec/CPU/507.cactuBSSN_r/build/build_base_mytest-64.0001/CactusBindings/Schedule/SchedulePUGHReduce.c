/*@@
   @file       SchedulePUGHReduce.c
   @author     Automatically generated by CreateScheduleBindings.pl
   @desc
               Creates the schedule and parameter recovery bindings 
               for thorn PUGHReduce
   @enddesc
@@*/


#ifdef SPEC 
#include "PUGHReduce/cctk.h" 
#define THORN_DIR "PUGHReduce" 
#else 
#include "PUGHReduce/cctk.h"
#endif /* END SPEC */ 
#include "PUGHReduce/CParameters.h"
#include "cctki_ScheduleBindings.h"
#include "PUGHReduce/cctk_ScheduleFunctions.h"

/* Prototypes for Fortran schedule bindings functions to be registered */
/* Note that this is a cheat, we just need a function pointer. */


void CCTKi_BindingsSchedule_PUGHReduce(void);
void CCTKi_BindingsSchedule_PUGHReduce(void)
{
  DECLARE_CCTK_PARAMETERS
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleFunction((void *)PUGHReduce_Startup,
                           "PUGHReduce_Startup",
                           "PUGHReduce",
                           "Reduce",
                           "Startup routine",
                           "CCTK_STARTUP",
                           "C",
                           0,  /* Number of STORAGE  groups   */
                           0,  /* Number of COMM     groups   */
                           0,  /* Number of TRIGGERS groups   */
                           0, /* Number of SYNC     groups    */
                           0, /* Number of WRITES clauses     */
                           0, /* Number of READS clauses      */
                           0, /* Number of Options            */
                           0, /* Number of BEFORE   routines  */
                           0, /* Number of AFTER    routines  */
                           0, /* Number of WHILE    variables */
                           0, /* Number of IF       variables */
                           cctkschedulei_tlevelarray  /* Array of timelevel data for storage groups */,
                           "");
  }
}

/*@@
  @routine    CCTKi_BindingsParameterRecovery_PUGHReduce
  @author     Automatically generated by CreateScheduleBindings.pl
  @desc
              Creates the parameter recovery bindings for thorn PUGHReduce
  @enddesc
@@*/

int CCTKi_BindingsParameterRecovery_PUGHReduce(void);
int CCTKi_BindingsParameterRecovery_PUGHReduce(void)
{
  /* this thorn doesn't define any parameter recovery routines */
  return (0);
}
