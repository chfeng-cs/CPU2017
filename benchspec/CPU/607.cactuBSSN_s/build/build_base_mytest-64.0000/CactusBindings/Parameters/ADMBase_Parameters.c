/*@@
   @file    ADMBase_Parameters.c
   @author  Automatically generated by CreateParameterBindings.pl
   @desc
            Creates/extends parameters for this thorn
   @enddesc
 @@*/


#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "cctk_Config.h"
#include "cctk_Constants.h"
#include "ParameterBindings.h"
#include "CParameterStructNames.h"

/* structure containing all private parameters of thorn ADMBase */
struct
{
  int dummy_parameter;
} PRIVATE_ADMBASE_STRUCT;


/* structure containing all restricted parameters of thorn ADMBase */
struct
{
  const char * admbase_boundary_condition;
  const char * dtlapse_evolution_method;
  const char * dtshift_evolution_method;
  const char * evolution_method;
  const char * initial_data;
  const char * initial_dtlapse;
  const char * initial_dtshift;
  const char * initial_lapse;
  const char * initial_shift;
  const char * lapse_evolution_method;
  const char * lapse_prolongation_type;
  const char * metric_prolongation_type;
  const char * metric_type;
  const char * shift_evolution_method;
  const char * shift_prolongation_type;
  CCTK_INT lapse_timelevels;
  CCTK_INT metric_timelevels;
  CCTK_INT shift_timelevels;
} RESTRICTED_ADMBASE_STRUCT;


int CCTKi_BindingsCreateADMBaseParameters(void);
int CCTKi_BindingsCreateADMBaseParameters(void)
{
  CCTKi_ParameterCreate("admbase_boundary_condition",
                        "ADMBase",
                        "STRING",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Boundary condition for ADMBase variables",
                        "flat",
                        &(RESTRICTED_ADMBASE_STRUCT.admbase_boundary_condition),
                        0,
                        NULL,
                        1,
                        "", "must be a registered boundary condition");

  CCTKi_ParameterCreate("dtlapse_evolution_method",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "The dtlapse evolution method",
                        "static",
                        &(RESTRICTED_ADMBASE_STRUCT.dtlapse_evolution_method),
                        0,
                        NULL,
                        1,
                        "static", "dtlapse is not evolved");

  CCTKi_ParameterCreate("dtshift_evolution_method",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "The dtshift evolution method",
                        "static",
                        &(RESTRICTED_ADMBASE_STRUCT.dtshift_evolution_method),
                        0,
                        NULL,
                        1,
                        "static", "shift is not evolved");

  CCTKi_ParameterCreate("evolution_method",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "The metric an extrinsic curvature evolution method",
                        "static",
                        &(RESTRICTED_ADMBASE_STRUCT.evolution_method),
                        0,
                        NULL,
                        2,
                        "none", "The metric and extrinsic curvature are not evolved",
                        "static", "The metric and extrinsic curvature are not evolved");

  CCTKi_ParameterCreate("initial_data",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Initial metric and extrinsic curvature datasets",
                        "Cartesian Minkowski",
                        &(RESTRICTED_ADMBASE_STRUCT.initial_data),
                        0,
                        NULL,
                        1,
                        "Cartesian Minkowski", "Minkowski values in cartesian coordinates");

  CCTKi_ParameterCreate("initial_dtlapse",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Initial dtlapse value",
                        "none",
                        &(RESTRICTED_ADMBASE_STRUCT.initial_dtlapse),
                        0,
                        NULL,
                        2,
                        "none", "Dtlapse is inactive",
                        "zero", "Dtlapse is zero");

  CCTKi_ParameterCreate("initial_dtshift",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Initial dtshift value",
                        "none",
                        &(RESTRICTED_ADMBASE_STRUCT.initial_dtshift),
                        0,
                        NULL,
                        2,
                        "none", "Dtshift is inactive",
                        "zero", "Dtshift is zero");

  CCTKi_ParameterCreate("initial_lapse",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Initial lapse value",
                        "one",
                        &(RESTRICTED_ADMBASE_STRUCT.initial_lapse),
                        0,
                        NULL,
                        1,
                        "one", "Uniform lapse");

  CCTKi_ParameterCreate("initial_shift",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Initial shift value",
                        "zero",
                        &(RESTRICTED_ADMBASE_STRUCT.initial_shift),
                        0,
                        NULL,
                        2,
                        "none", "Shift is inactive",
                        "zero", "Shift is zero");

  CCTKi_ParameterCreate("lapse_evolution_method",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "The lapse evolution method",
                        "static",
                        &(RESTRICTED_ADMBASE_STRUCT.lapse_evolution_method),
                        0,
                        NULL,
                        1,
                        "static", "lapse is not evolved");

  CCTKi_ParameterCreate("lapse_prolongation_type",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "The kind of boundary prolongation for the lapse",
                        "Lagrange",
                        &(RESTRICTED_ADMBASE_STRUCT.lapse_prolongation_type),
                        0,
                        NULL,
                        2,
                        "Lagrange", "standard prolongation (requires several time levels)",
                        "none", "no prolongation (use this if you do not have enough time levels active)");

  CCTKi_ParameterCreate("lapse_timelevels",
                        "ADMBase",
                        "INT",
                        "RESTRICTED",
                        CCTK_STEERABLE_RECOVER,
                        "Number of time levels for the lapse",
                        "1",
                        &(RESTRICTED_ADMBASE_STRUCT.lapse_timelevels),
                        0,
                        NULL,
                        1,
                        "0:3", "");

  CCTKi_ParameterCreate("metric_prolongation_type",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "The kind of boundary prolongation for the metric and extrinsic curvature",
                        "Lagrange",
                        &(RESTRICTED_ADMBASE_STRUCT.metric_prolongation_type),
                        0,
                        NULL,
                        2,
                        "Lagrange", "standard prolongation (requires several time levels)",
                        "none", "no prolongation (use this if you do not have enough time levels active)");

  CCTKi_ParameterCreate("metric_timelevels",
                        "ADMBase",
                        "INT",
                        "RESTRICTED",
                        CCTK_STEERABLE_RECOVER,
                        "Number of time levels for the metric and extrinsic curvature",
                        "1",
                        &(RESTRICTED_ADMBASE_STRUCT.metric_timelevels),
                        0,
                        NULL,
                        1,
                        "0:3", "");

  CCTKi_ParameterCreate("metric_type",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "The semantics of the metric variables (physical, static conformal, etc)",
                        "physical",
                        &(RESTRICTED_ADMBASE_STRUCT.metric_type),
                        0,
                        NULL,
                        1,
                        "physical", "metric and extrinsic curvature are the physical ones");

  CCTKi_ParameterCreate("shift_evolution_method",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "The shift evolution method",
                        "static",
                        &(RESTRICTED_ADMBASE_STRUCT.shift_evolution_method),
                        0,
                        NULL,
                        1,
                        "static", "shift is not evolved");

  CCTKi_ParameterCreate("shift_prolongation_type",
                        "ADMBase",
                        "KEYWORD",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "The kind of boundary prolongation for the shift",
                        "Lagrange",
                        &(RESTRICTED_ADMBASE_STRUCT.shift_prolongation_type),
                        0,
                        NULL,
                        2,
                        "Lagrange", "standard prolongation (requires several time levels)",
                        "none", "no prolongation (use this if you do not have enough time levels active)");

  CCTKi_ParameterCreate("shift_timelevels",
                        "ADMBase",
                        "INT",
                        "RESTRICTED",
                        CCTK_STEERABLE_RECOVER,
                        "Number of time levels for the shift",
                        "1",
                        &(RESTRICTED_ADMBASE_STRUCT.shift_timelevels),
                        0,
                        NULL,
                        1,
                        "0:3", "");

  return 0;
}

int CCTKi_BindingsADMBaseParameterExtensions(void);
int CCTKi_BindingsADMBaseParameterExtensions(void)
{
  return 0;
}
