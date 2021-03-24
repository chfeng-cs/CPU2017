/*@@
   @header  Time/CParameters.h
   @author  Automatically generated by CreateParameterBindings.pl
   @desc
            Declares parameters of thorn Time
   @enddesc
 @@*/


#ifndef _TIME_PARAMETERS_H_
#define _TIME_PARAMETERS_H_ 1

#include "CParameterStructNames.h"
#include "ParameterCGlobal.h"
#include "ParameterCRestrictedTIME.h"
#include "ParameterCPrivateTIME.h"
#include "ParameterCRestrictedCACTUS.h"

#define DECLARE_CCTK_PARAMETERS \
  DECLARE_GLOBAL_PARAMETER_STRUCT_PARAMS \
  DECLARE_RESTRICTED_TIME_STRUCT_PARAMS \
  DECLARE_PRIVATE_TIME_STRUCT_PARAMS \
  CCTK_DECLARE_INIT (CCTK_REAL const, cctk_final_time, CCTK_PARAMETER__Cactus__cctk_final_time); \
  CCTK_DECLARE_INIT (const char * const, terminate, CCTK_PARAMETER__Cactus__terminate); \

#ifndef CCTK_PARAMETER__Cactus__cctk_final_time
#  define CCTK_PARAMETER__Cactus__cctk_final_time RESTRICTED_CACTUS_STRUCT.cctk_final_time
#endif
#ifndef CCTK_PARAMETER__Cactus__terminate
#  define CCTK_PARAMETER__Cactus__terminate RESTRICTED_CACTUS_STRUCT.terminate
#endif

#endif  /* _TIME_PARAMETERS_H_ */

