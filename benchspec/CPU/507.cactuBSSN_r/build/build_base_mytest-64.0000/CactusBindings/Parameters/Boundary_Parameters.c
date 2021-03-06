/*@@
   @file    Boundary_Parameters.c
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

/* structure containing all private parameters of thorn Boundary */
struct
{
  int dummy_parameter;
} PRIVATE_BOUNDARY_STRUCT;


/* structure containing all restricted parameters of thorn Boundary */
struct
{
  CCTK_INT radpower;
  CCTK_INT register_copy;
  CCTK_INT register_flat;
  CCTK_INT register_none;
  CCTK_INT register_radiation;
  CCTK_INT register_robin;
  CCTK_INT register_scalar;
  CCTK_INT register_static;
} RESTRICTED_BOUNDARY_STRUCT;


int CCTKi_BindingsCreateBoundaryParameters(void);
int CCTKi_BindingsCreateBoundaryParameters(void)
{
  CCTKi_ParameterCreate("radpower",
                        "Boundary",
                        "INT",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Power of decay rate in extrapolation used in radiative boundaries",
                        "-1",
                        &(RESTRICTED_BOUNDARY_STRUCT.radpower),
                        0,
                        NULL,
                        1,
                        ":", "A negative value switches off this feature");

  CCTKi_ParameterCreate("register_copy",
                        "Boundary",
                        "BOOLEAN",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Register routine to handle the 'Copy' boundary condition",
                        "yes",
                        &(RESTRICTED_BOUNDARY_STRUCT.register_copy),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("register_flat",
                        "Boundary",
                        "BOOLEAN",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Register routine to handle the 'Flat' boundary condition",
                        "yes",
                        &(RESTRICTED_BOUNDARY_STRUCT.register_flat),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("register_none",
                        "Boundary",
                        "BOOLEAN",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Register routine to handle the 'None' boundary condition",
                        "yes",
                        &(RESTRICTED_BOUNDARY_STRUCT.register_none),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("register_radiation",
                        "Boundary",
                        "BOOLEAN",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Register routine to handle the 'Radiation' boundary condition",
                        "yes",
                        &(RESTRICTED_BOUNDARY_STRUCT.register_radiation),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("register_robin",
                        "Boundary",
                        "BOOLEAN",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Register routine to handle the 'Robin' boundary condition",
                        "yes",
                        &(RESTRICTED_BOUNDARY_STRUCT.register_robin),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("register_scalar",
                        "Boundary",
                        "BOOLEAN",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Register routine to handle the 'Scalar' boundary condition",
                        "yes",
                        &(RESTRICTED_BOUNDARY_STRUCT.register_scalar),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("register_static",
                        "Boundary",
                        "BOOLEAN",
                        "RESTRICTED",
                        CCTK_STEERABLE_NEVER,
                        "Register routine to handle the 'Static' boundary condition",
                        "yes",
                        &(RESTRICTED_BOUNDARY_STRUCT.register_static),
                        0,
                        NULL,
                        0);

  return 0;
}

int CCTKi_BindingsBoundaryParameterExtensions(void);
int CCTKi_BindingsBoundaryParameterExtensions(void)
{
  return 0;
}
