/*@@
   @file       ScheduleCoordGauge.c
   @author     Automatically generated by CreateScheduleBindings.pl
   @desc
               Creates the schedule and parameter recovery bindings 
               for thorn CoordGauge
   @enddesc
@@*/


#ifdef SPEC 
#include "CoordGauge/cctk.h" 
#define THORN_DIR "CoordGauge" 
#else 
#include "CoordGauge/cctk.h"
#endif /* END SPEC */ 
#include "CoordGauge/CParameters.h"
#include "cctki_ScheduleBindings.h"
#include "CoordGauge/cctk_ScheduleFunctions.h"

/* Prototypes for Fortran schedule bindings functions to be registered */
/* Note that this is a cheat, we just need a function pointer. */


void CCTKi_BindingsSchedule_CoordGauge(void);
void CCTKi_BindingsSchedule_CoordGauge(void)
{
  DECLARE_CCTK_PARAMETERS
  if(!(1 >= 0 && 1  <= CCTK_MaxTimeLevels("CoordGauge::slicing_flags")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 1, "CoordGauge::slicing_flags", CCTK_MaxTimeLevels("CoordGauge::slicing_flags"));
  CCTKi_ScheduleGroupStorage("CoordGauge::slicing_flags",1);
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleFunction((void *)Einstein_ActivateSlicing,
                           "Einstein_ActivateSlicing",
                           "CoordGauge",
                           "CoordGauge",
                           "Initialize slicing, setup priorities for mixed slicings",
                           "CCTK_WRAGH",
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
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleFunction((void *)Einstein_SetNextSlicing,
                           "Einstein_SetNextSlicing",
                           "CoordGauge",
                           "CoordGauge",
                           "Identify the slicing for the next iteration",
                           "CCTK_WRAGH",
                           "C",
                           0,  /* Number of STORAGE  groups   */
                           0,  /* Number of COMM     groups   */
                           0,  /* Number of TRIGGERS groups   */
                           0, /* Number of SYNC     groups    */
                           0, /* Number of WRITES clauses     */
                           0, /* Number of READS clauses      */
                           0, /* Number of Options            */
                           0, /* Number of BEFORE   routines  */
                           1, /* Number of AFTER    routines  */
                           0, /* Number of WHILE    variables */
                           0, /* Number of IF       variables */
                           cctkschedulei_tlevelarray  /* Array of timelevel data for storage groups */,
                           "",
                           "Einstein_ActivateSlicing");
  }
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleFunction((void *)Einstein_SetNextSlicing,
                           "Einstein_SetNextSlicing",
                           "CoordGauge",
                           "CoordGauge",
                           "Identify the slicing for the next iteration",
                           "CCTK_PRESTEP",
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
if(CCTK_Equals(lapse_evolution_method, "coordgauge")||
   CCTK_Equals(shift_evolution_method, "coordgauge"))
{
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleGroup("CoordGauge",
"CoordGauge",
                        "CoordGauge",
                        "CoordGauge",
                        "Coordinate Gauge group",
                        "CCTK_PRESTEP",
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
  if(CCTK_Equals(lapse_evolution_method, "coordgauge"))
  {
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleGroup("LapseSelect",
"LapseSelect",
                        "CoordGauge",
                        "CoordGauge",
                        "Lapse Selection Group",
                        "CoordGauge",
                        0,  /* Number of STORAGE  groups   */
                        0,  /* Number of COMM     groups   */
                        0,  /* Number of TRIGGERS groups   */
                        0, /* Number of SYNC     groups    */
                        0, /* Number of WRITES clauses     */
                        0, /* Number of READS clauses      */
                        0, /* Number of Options            */
                        1, /* Number of BEFORE   routines  */
                        0, /* Number of AFTER    routines  */
                        0, /* Number of WHILE    variables */
                        0, /* Number of IF       variables */
                        cctkschedulei_tlevelarray  /* Array of timelevel data for storage groups */,
                        "",
                        "PickCoordGauge");
  }
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleGroup("LapseApply",
"LapseApply",
                        "CoordGauge",
                        "CoordGauge",
                        "Lapse Application Group",
                        "CoordGauge",
                        0,  /* Number of STORAGE  groups   */
                        0,  /* Number of COMM     groups   */
                        0,  /* Number of TRIGGERS groups   */
                        0, /* Number of SYNC     groups    */
                        0, /* Number of WRITES clauses     */
                        0, /* Number of READS clauses      */
                        0, /* Number of Options            */
                        0, /* Number of BEFORE   routines  */
                        1, /* Number of AFTER    routines  */
                        0, /* Number of WHILE    variables */
                        0, /* Number of IF       variables */
                        cctkschedulei_tlevelarray  /* Array of timelevel data for storage groups */,
                        "",
                        "PickCoordGauge");
  }
  }
  if(CCTK_Equals(shift_evolution_method, "coordgauge"))
  {
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleGroup("ShiftSelect",
"ShiftSelect",
                        "CoordGauge",
                        "CoordGauge",
                        "Shift Selection Group",
                        "CoordGauge",
                        0,  /* Number of STORAGE  groups   */
                        0,  /* Number of COMM     groups   */
                        0,  /* Number of TRIGGERS groups   */
                        0, /* Number of SYNC     groups    */
                        0, /* Number of WRITES clauses     */
                        0, /* Number of READS clauses      */
                        0, /* Number of Options            */
                        1, /* Number of BEFORE   routines  */
                        0, /* Number of AFTER    routines  */
                        0, /* Number of WHILE    variables */
                        0, /* Number of IF       variables */
                        cctkschedulei_tlevelarray  /* Array of timelevel data for storage groups */,
                        "",
                        "PickCoordGauge");
  }
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleGroup("ShiftApply",
"ShiftApply",
                        "CoordGauge",
                        "CoordGauge",
                        "Shift Application Group",
                        "CoordGauge",
                        0,  /* Number of STORAGE  groups   */
                        0,  /* Number of COMM     groups   */
                        0,  /* Number of TRIGGERS groups   */
                        0, /* Number of SYNC     groups    */
                        0, /* Number of WRITES clauses     */
                        0, /* Number of READS clauses      */
                        0, /* Number of Options            */
                        0, /* Number of BEFORE   routines  */
                        1, /* Number of AFTER    routines  */
                        0, /* Number of WHILE    variables */
                        0, /* Number of IF       variables */
                        cctkschedulei_tlevelarray  /* Array of timelevel data for storage groups */,
                        "",
                        "PickCoordGauge");
  }
  }
}
}

/*@@
  @routine    CCTKi_BindingsParameterRecovery_CoordGauge
  @author     Automatically generated by CreateScheduleBindings.pl
  @desc
              Creates the parameter recovery bindings for thorn CoordGauge
  @enddesc
@@*/

int CCTKi_BindingsParameterRecovery_CoordGauge(void);
int CCTKi_BindingsParameterRecovery_CoordGauge(void)
{
  /* this thorn doesn't define any parameter recovery routines */
  return (0);
}
