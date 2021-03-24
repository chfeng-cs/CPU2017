/*@@
   @file       ScheduleFortran.c
   @author     Automatically generated by CreateScheduleBindings.pl
   @desc
               Creates the schedule and parameter recovery bindings 
               for thorn Fortran
   @enddesc
@@*/


#ifdef SPEC 
#include "Fortran/cctk.h" 
#define THORN_DIR "Fortran" 
#else 
#include "Fortran/cctk.h"
#endif /* END SPEC */ 
#include "Fortran/CParameters.h"
#include "cctki_ScheduleBindings.h"
#include "Fortran/cctk_ScheduleFunctions.h"

/* Prototypes for Fortran schedule bindings functions to be registered */
/* Note that this is a cheat, we just need a function pointer. */
extern int checkfortranparameters_(void);

void CCTKi_BindingsSchedule_Fortran(void);
void CCTKi_BindingsSchedule_Fortran(void)
{
  DECLARE_CCTK_PARAMETERS
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleFunction((void *)checkfortranparameters_,
                           "CheckFortranParameters",
                           "Fortran",
                           "Fortran",
                           "Test whether Fortran parameters work correctly",
                           "CCTK_PARAMCHECK",
                           "Fortran",
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
  @routine    CCTKi_BindingsParameterRecovery_Fortran
  @author     Automatically generated by CreateScheduleBindings.pl
  @desc
              Creates the parameter recovery bindings for thorn Fortran
  @enddesc
@@*/

int CCTKi_BindingsParameterRecovery_Fortran(void);
int CCTKi_BindingsParameterRecovery_Fortran(void)
{
  /* this thorn doesn't define any parameter recovery routines */
  return (0);
}