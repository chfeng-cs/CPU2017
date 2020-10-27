/*@@
   @file       ScheduleTmunuBase.c
   @author     Automatically generated by CreateScheduleBindings.pl
   @desc
               Creates the schedule and parameter recovery bindings 
               for thorn TmunuBase
   @enddesc
@@*/


#ifdef SPEC 
#include "TmunuBase/cctk.h" 
#define THORN_DIR "TmunuBase" 
#else 
#include "TmunuBase/cctk.h"
#endif /* END SPEC */ 
#include "TmunuBase/CParameters.h"
#include "cctki_ScheduleBindings.h"
#include "TmunuBase/cctk_ScheduleFunctions.h"

/* Prototypes for Fortran schedule bindings functions to be registered */
/* Note that this is a cheat, we just need a function pointer. */
#if defined(SPEC_NO_UNDERSCORE)
extern int tmunubase_setstressenergystate(void);
extern int tmunubase_settmunu(void);
extern int tmunubase_zerotmunu(void);
extern int tmunubase_copytmunu(void);
#else
extern int tmunubase_setstressenergystate_(void);
extern int tmunubase_settmunu_(void);
extern int tmunubase_zerotmunu_(void);
extern int tmunubase_copytmunu_(void);
#endif

void CCTKi_BindingsSchedule_TmunuBase(void);
void CCTKi_BindingsSchedule_TmunuBase(void)
{
  DECLARE_CCTK_PARAMETERS
  if(!(1 >= 0 && 1  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_state")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 1, "TmunuBase::stress_energy_state", CCTK_MaxTimeLevels("TmunuBase::stress_energy_state"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_state",1);
  if(!(1 >= 0 && 1  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_2_state")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 1, "TmunuBase::stress_energy_2_state", CCTK_MaxTimeLevels("TmunuBase::stress_energy_2_state"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_2_state",1);
  {
    int cctkschedulei_tlevelarray[] = {0};
#if defined(SPEC_NO_UNDERSCORE)
    CCTKi_ScheduleFunction((void *)tmunubase_setstressenergystate,
#else
    CCTKi_ScheduleFunction((void *)tmunubase_setstressenergystate_,
#endif
                           "TmunuBase_SetStressEnergyState",
                           "TmunuBase",
                           "TmunuBase",
                           "Set the stress_energy_state variable",
                           "CCTK_WRAGH",
                           "Fortran",
                           0,  /* Number of STORAGE  groups   */
                           0,  /* Number of COMM     groups   */
                           0,  /* Number of TRIGGERS groups   */
                           0, /* Number of SYNC     groups    */
                           0, /* Number of WRITES clauses     */
                           0, /* Number of READS clauses      */
                           1, /* Number of Options            */
                           1, /* Number of BEFORE   routines  */
                           0, /* Number of AFTER    routines  */
                           0, /* Number of WHILE    variables */
                           0, /* Number of IF       variables */
                           cctkschedulei_tlevelarray  /* Array of timelevel data for storage groups */,
                           "global",
                           "",
                           "MoL_Register");
  }
if (stress_energy_storage)
{
  if (timelevels == 1)
  {
  if(!(1 >= 0 && 1  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_scalar")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 1, "TmunuBase::stress_energy_scalar", CCTK_MaxTimeLevels("TmunuBase::stress_energy_scalar"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_scalar",1);
  if(!(1 >= 0 && 1  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_vector")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 1, "TmunuBase::stress_energy_vector", CCTK_MaxTimeLevels("TmunuBase::stress_energy_vector"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_vector",1);
  if(!(1 >= 0 && 1  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_tensor")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 1, "TmunuBase::stress_energy_tensor", CCTK_MaxTimeLevels("TmunuBase::stress_energy_tensor"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_tensor",1);
  }
  else if (timelevels == 2)
  {
  if(!(2 >= 0 && 2  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_scalar")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 2, "TmunuBase::stress_energy_scalar", CCTK_MaxTimeLevels("TmunuBase::stress_energy_scalar"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_scalar",2);
  if(!(2 >= 0 && 2  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_vector")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 2, "TmunuBase::stress_energy_vector", CCTK_MaxTimeLevels("TmunuBase::stress_energy_vector"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_vector",2);
  if(!(2 >= 0 && 2  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_tensor")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 2, "TmunuBase::stress_energy_tensor", CCTK_MaxTimeLevels("TmunuBase::stress_energy_tensor"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_tensor",2);
  }
  else if (timelevels == 3)
  {
  if(!(3 >= 0 && 3  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_scalar")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 3, "TmunuBase::stress_energy_scalar", CCTK_MaxTimeLevels("TmunuBase::stress_energy_scalar"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_scalar",3);
  if(!(3 >= 0 && 3  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_vector")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 3, "TmunuBase::stress_energy_vector", CCTK_MaxTimeLevels("TmunuBase::stress_energy_vector"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_vector",3);
  if(!(3 >= 0 && 3  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_tensor")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 3, "TmunuBase::stress_energy_tensor", CCTK_MaxTimeLevels("TmunuBase::stress_energy_tensor"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_tensor",3);
  }
  if (support_old_CalcTmunu_mechanism)
  {
  if(!(1 >= 0 && 1  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_2_scalar")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 1, "TmunuBase::stress_energy_2_scalar", CCTK_MaxTimeLevels("TmunuBase::stress_energy_2_scalar"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_2_scalar",1);
  if(!(1 >= 0 && 1  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_2_vector")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 1, "TmunuBase::stress_energy_2_vector", CCTK_MaxTimeLevels("TmunuBase::stress_energy_2_vector"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_2_vector",1);
  if(!(1 >= 0 && 1  <= CCTK_MaxTimeLevels("TmunuBase::stress_energy_2_tensor")))
      CCTK_VWarn(0, __LINE__, __FILE__, CCTK_THORNSTRING,
                 "Tried to schedule %d timelevels for group '%s' in schedule.ccl.\n"
                 "Value must be between 0 and %d (inclusive)",
                 1, "TmunuBase::stress_energy_2_tensor", CCTK_MaxTimeLevels("TmunuBase::stress_energy_2_tensor"));
  CCTKi_ScheduleGroupStorage("TmunuBase::stress_energy_2_tensor",1);
  }
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleGroup("SetTmunu",
"SetTmunu",
                        "TmunuBase",
                        "TmunuBase",
                        "Calculate the stress-energy tensor",
                        "CCTK_INITIAL",
                        0,  /* Number of STORAGE  groups   */
                        0,  /* Number of COMM     groups   */
                        0,  /* Number of TRIGGERS groups   */
                        0, /* Number of SYNC     groups    */
                        0, /* Number of WRITES clauses     */
                        0, /* Number of READS clauses      */
                        0, /* Number of Options            */
                        0, /* Number of BEFORE   routines  */
                        3, /* Number of AFTER    routines  */
                        0, /* Number of WHILE    variables */
                        0, /* Number of IF       variables */
                        cctkschedulei_tlevelarray  /* Array of timelevel data for storage groups */,
                        "",
                        "ADMBase_InitialData",
                        "ADMBase_InitialGauge",
                        "Whisky_Initial");
  }
  if (stress_energy_at_RHS)
  {
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleGroup("SetTmunu",
"SetTmunu",
                        "TmunuBase",
                        "TmunuBase",
                        "Group for calculating the stress-energy tensor",
                        "MoL_PostStep",
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
                        "ADMBase_SetADMVars");
  }
  }
  if (support_old_CalcTmunu_mechanism)
  {
  {
    int cctkschedulei_tlevelarray[] = {0};
#if defined(SPEC_NO_UNDERSCORE)
    CCTKi_ScheduleFunction((void *)tmunubase_settmunu,
#else
    CCTKi_ScheduleFunction((void *)tmunubase_settmunu_,
#endif
                           "TmunuBase_SetTmunu",
                           "TmunuBase",
                           "TmunuBase",
                           "Calculate the stress-energy tensor using the old CalcTmunu mechanism",
                           "SetTmunu",
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
  else
  {
  {
    int cctkschedulei_tlevelarray[] = {0};
#if defined(SPEC_NO_UNDERSCORE)
    CCTKi_ScheduleFunction((void *)tmunubase_zerotmunu,
#else
    CCTKi_ScheduleFunction((void *)tmunubase_zerotmunu_,
#endif
                           "TmunuBase_ZeroTmunu",
                           "TmunuBase",
                           "TmunuBase",
                           "Initialise the stress-energy tensor to zero",
                           "SetTmunu",
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
  {
    int cctkschedulei_tlevelarray[] = {0};
    CCTKi_ScheduleGroup("AddToTmunu",
"AddToTmunu",
                        "TmunuBase",
                        "TmunuBase",
                        "Add to the stress-energy tensor here",
                        "SetTmunu",
                        0,  /* Number of STORAGE  groups   */
                        0,  /* Number of COMM     groups   */
                        0,  /* Number of TRIGGERS groups   */
                        0, /* Number of SYNC     groups    */
                        0, /* Number of WRITES clauses     */
                        0, /* Number of READS clauses      */
                        0, /* Number of Options            */
                        0, /* Number of BEFORE   routines  */
                        2, /* Number of AFTER    routines  */
                        0, /* Number of WHILE    variables */
                        0, /* Number of IF       variables */
                        cctkschedulei_tlevelarray  /* Array of timelevel data for storage groups */,
                        "",
                        "TmunuBase_SetTmunu",
                        "TmunuBase_ZeroTmunu");
  }
  if (support_old_CalcTmunu_mechanism)
  {
  {
    int cctkschedulei_tlevelarray[] = {0};
#if defined(SPEC_NO_UNDERSCORE)
    CCTKi_ScheduleFunction((void *)tmunubase_copytmunu,
#else
    CCTKi_ScheduleFunction((void *)tmunubase_copytmunu_,
#endif
                           "TmunuBase_CopyTmunu",
                           "TmunuBase",
                           "TmunuBase",
                           "Copy the stress-energy tensor",
                           "SetTmunu",
                           "Fortran",
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
                           "AddToTmunu");
  }
  }
} /* if stress_energy_storage */
}

/*@@
  @routine    CCTKi_BindingsParameterRecovery_TmunuBase
  @author     Automatically generated by CreateScheduleBindings.pl
  @desc
              Creates the parameter recovery bindings for thorn TmunuBase
  @enddesc
@@*/

int CCTKi_BindingsParameterRecovery_TmunuBase(void);
int CCTKi_BindingsParameterRecovery_TmunuBase(void)
{
  /* this thorn doesn't define any parameter recovery routines */
  return (0);
}