/*@@
   @file    CoordBase_Parameters.c
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

/* structure containing all private parameters of thorn CoordBase */
struct
{
  CCTK_REAL dx;
  CCTK_REAL dy;
  CCTK_REAL dz;
  CCTK_REAL xextent;
  CCTK_REAL xmax;
  CCTK_REAL xmin;
  CCTK_REAL yextent;
  CCTK_REAL ymax;
  CCTK_REAL ymin;
  CCTK_REAL zextent;
  CCTK_REAL zmax;
  CCTK_REAL zmin;
  const char * domainsize;
  const char * spacing;
  CCTK_INT boundary_internal_x_lower;
  CCTK_INT boundary_internal_x_upper;
  CCTK_INT boundary_internal_y_lower;
  CCTK_INT boundary_internal_y_upper;
  CCTK_INT boundary_internal_z_lower;
  CCTK_INT boundary_internal_z_upper;
  CCTK_INT boundary_shiftout_x_lower;
  CCTK_INT boundary_shiftout_x_upper;
  CCTK_INT boundary_shiftout_y_lower;
  CCTK_INT boundary_shiftout_y_upper;
  CCTK_INT boundary_shiftout_z_lower;
  CCTK_INT boundary_shiftout_z_upper;
  CCTK_INT boundary_size_x_lower;
  CCTK_INT boundary_size_x_upper;
  CCTK_INT boundary_size_y_lower;
  CCTK_INT boundary_size_y_upper;
  CCTK_INT boundary_size_z_lower;
  CCTK_INT boundary_size_z_upper;
  CCTK_INT boundary_staggered_x_lower;
  CCTK_INT boundary_staggered_x_upper;
  CCTK_INT boundary_staggered_y_lower;
  CCTK_INT boundary_staggered_y_upper;
  CCTK_INT boundary_staggered_z_lower;
  CCTK_INT boundary_staggered_z_upper;
  CCTK_INT ncells_x;
  CCTK_INT ncells_y;
  CCTK_INT ncells_z;
  CCTK_INT zero_origin_x;
  CCTK_INT zero_origin_y;
  CCTK_INT zero_origin_z;
} PRIVATE_COORDBASE_STRUCT;


/* structure containing all restricted parameters of thorn CoordBase */
struct
{
  int dummy_parameter;
} RESTRICTED_COORDBASE_STRUCT;


int CCTKi_BindingsCreateCoordBaseParameters(void);
int CCTKi_BindingsCreateCoordBaseParameters(void)
{
  CCTKi_ParameterCreate("boundary_internal_x_lower",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Do the boundary points extend inwards at the lower x face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_internal_x_lower),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_internal_x_upper",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Do the boundary points extend inwards at the upper x face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_internal_x_upper),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_internal_y_lower",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Do the boundary points extend inwards at the lower y face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_internal_y_lower),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_internal_y_upper",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Do the boundary points extend inwards at the upper y face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_internal_y_upper),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_internal_z_lower",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Do the boundary points extend inwards at the lower z face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_internal_z_lower),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_internal_z_upper",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Do the boundary points extend inwards at the upper z face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_internal_z_upper),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_shiftout_x_lower",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Offset between the boundary location and the first boundary point at the lower x face",
                        "0",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_shiftout_x_lower),
                        0,
                        NULL,
                        1,
                        "*:*", "when not staggered: use 0 for an open, 1 for a closed manifold");

  CCTKi_ParameterCreate("boundary_shiftout_x_upper",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Offset between the boundary location and the first boundary point at the upper x face",
                        "0",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_shiftout_x_upper),
                        0,
                        NULL,
                        1,
                        "*:*", "when not staggered: use 0 for an open, 1 for a closed manifold");

  CCTKi_ParameterCreate("boundary_shiftout_y_lower",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Offset between the boundary location and the first boundary point at the lower y face",
                        "0",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_shiftout_y_lower),
                        0,
                        NULL,
                        1,
                        "*:*", "when not staggered: use 0 for an open, 1 for a closed manifold");

  CCTKi_ParameterCreate("boundary_shiftout_y_upper",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Offset between the boundary location and the first boundary point at the upper y face",
                        "0",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_shiftout_y_upper),
                        0,
                        NULL,
                        1,
                        "*:*", "when not staggered: use 0 for an open, 1 for a closed manifold");

  CCTKi_ParameterCreate("boundary_shiftout_z_lower",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Offset between the boundary location and the first boundary point at the lower z face",
                        "0",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_shiftout_z_lower),
                        0,
                        NULL,
                        1,
                        "*:*", "when not staggered: use 0 for an open, 1 for a closed manifold");

  CCTKi_ParameterCreate("boundary_shiftout_z_upper",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Offset between the boundary location and the first boundary point at the upper z face",
                        "0",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_shiftout_z_upper),
                        0,
                        NULL,
                        1,
                        "*:*", "when not staggered: use 0 for an open, 1 for a closed manifold");

  CCTKi_ParameterCreate("boundary_size_x_lower",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Boundary zones at the lower x face",
                        "1",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_size_x_lower),
                        0,
                        NULL,
                        1,
                        "0:*", "");

  CCTKi_ParameterCreate("boundary_size_x_upper",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Boundary zones at the upper x face",
                        "1",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_size_x_upper),
                        0,
                        NULL,
                        1,
                        "0:*", "");

  CCTKi_ParameterCreate("boundary_size_y_lower",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Boundary zones at the lower y face",
                        "1",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_size_y_lower),
                        0,
                        NULL,
                        1,
                        "0:*", "");

  CCTKi_ParameterCreate("boundary_size_y_upper",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Boundary zones at the upper y face",
                        "1",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_size_y_upper),
                        0,
                        NULL,
                        1,
                        "0:*", "");

  CCTKi_ParameterCreate("boundary_size_z_lower",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Boundary zones at the lower z face",
                        "1",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_size_z_lower),
                        0,
                        NULL,
                        1,
                        "0:*", "");

  CCTKi_ParameterCreate("boundary_size_z_upper",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Boundary zones at the upper z face",
                        "1",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_size_z_upper),
                        0,
                        NULL,
                        1,
                        "0:*", "");

  CCTKi_ParameterCreate("boundary_staggered_x_lower",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Is the boundary is staggered about the grid points at the lower x face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_staggered_x_lower),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_staggered_x_upper",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Is the boundary is staggered about the grid points at the upper x face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_staggered_x_upper),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_staggered_y_lower",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Is the boundary is staggered about the grid points at the lower y face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_staggered_y_lower),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_staggered_y_upper",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Is the boundary is staggered about the grid points at the upper y face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_staggered_y_upper),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_staggered_z_lower",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Is the boundary is staggered about the grid points at the lower z face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_staggered_z_lower),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("boundary_staggered_z_upper",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Is the boundary is staggered about the grid points at the upper z face?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.boundary_staggered_z_upper),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("domainsize",
                        "CoordBase",
                        "KEYWORD",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Domain size specification",
                        "minmax",
                        &(PRIVATE_COORDBASE_STRUCT.domainsize),
                        0,
                        NULL,
                        3,
                        "minmax", "lower and upper boundary locations",
                        "extent", "coordinate extent",
                        "spacing", "grid spacing and number of grid cells");

  CCTKi_ParameterCreate("dx",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Grid spacing in x direction",
                        "1.0",
                        &(PRIVATE_COORDBASE_STRUCT.dx),
                        0,
                        NULL,
                        1,
                        "(0:*)", "");

  CCTKi_ParameterCreate("dy",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Grid spacing in y direction",
                        "1.0",
                        &(PRIVATE_COORDBASE_STRUCT.dy),
                        0,
                        NULL,
                        1,
                        "(0:*)", "");

  CCTKi_ParameterCreate("dz",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Grid spacing in z direction",
                        "1.0",
                        &(PRIVATE_COORDBASE_STRUCT.dz),
                        0,
                        NULL,
                        1,
                        "(0:*)", "");

  CCTKi_ParameterCreate("ncells_x",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Number of grid cells in x direction",
                        "1",
                        &(PRIVATE_COORDBASE_STRUCT.ncells_x),
                        0,
                        NULL,
                        1,
                        "0:*", "");

  CCTKi_ParameterCreate("ncells_y",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Number of grid cells in y direction",
                        "1",
                        &(PRIVATE_COORDBASE_STRUCT.ncells_y),
                        0,
                        NULL,
                        1,
                        "0:*", "");

  CCTKi_ParameterCreate("ncells_z",
                        "CoordBase",
                        "INT",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Number of grid cells in z direction",
                        "1",
                        &(PRIVATE_COORDBASE_STRUCT.ncells_z),
                        0,
                        NULL,
                        1,
                        "0:*", "");

  CCTKi_ParameterCreate("spacing",
                        "CoordBase",
                        "KEYWORD",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Grid spacing specification",
                        "gridspacing",
                        &(PRIVATE_COORDBASE_STRUCT.spacing),
                        0,
                        NULL,
                        2,
                        "gridspacing", "grid spacing",
                        "numcells", "number of grid cells");

  CCTKi_ParameterCreate("xextent",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Domain extent in x direction",
                        "1.0",
                        &(PRIVATE_COORDBASE_STRUCT.xextent),
                        0,
                        NULL,
                        1,
                        "(0:*)", "");

  CCTKi_ParameterCreate("xmax",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Location of upper x boundary",
                        "1.0",
                        &(PRIVATE_COORDBASE_STRUCT.xmax),
                        0,
                        NULL,
                        1,
                        "(*:*)", "");

  CCTKi_ParameterCreate("xmin",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Location of lower x boundary",
                        "0.0",
                        &(PRIVATE_COORDBASE_STRUCT.xmin),
                        0,
                        NULL,
                        1,
                        "(*:*)", "");

  CCTKi_ParameterCreate("yextent",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Domain extent in y direction",
                        "1.0",
                        &(PRIVATE_COORDBASE_STRUCT.yextent),
                        0,
                        NULL,
                        1,
                        "(0:*)", "");

  CCTKi_ParameterCreate("ymax",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Location of upper y boundary",
                        "1.0",
                        &(PRIVATE_COORDBASE_STRUCT.ymax),
                        0,
                        NULL,
                        1,
                        "(*:*)", "");

  CCTKi_ParameterCreate("ymin",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Location of lower y boundary",
                        "0.0",
                        &(PRIVATE_COORDBASE_STRUCT.ymin),
                        0,
                        NULL,
                        1,
                        "(*:*)", "");

  CCTKi_ParameterCreate("zero_origin_x",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Is the lower boundary located at x=0?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.zero_origin_x),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("zero_origin_y",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Is the lower boundary located at y=0?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.zero_origin_y),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("zero_origin_z",
                        "CoordBase",
                        "BOOLEAN",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Is the lower boundary located at z=0?",
                        "no",
                        &(PRIVATE_COORDBASE_STRUCT.zero_origin_z),
                        0,
                        NULL,
                        0);

  CCTKi_ParameterCreate("zextent",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Domain extent in z direction",
                        "1.0",
                        &(PRIVATE_COORDBASE_STRUCT.zextent),
                        0,
                        NULL,
                        1,
                        "(0:*)", "");

  CCTKi_ParameterCreate("zmax",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Location of upper z boundary",
                        "1.0",
                        &(PRIVATE_COORDBASE_STRUCT.zmax),
                        0,
                        NULL,
                        1,
                        "(*:*)", "");

  CCTKi_ParameterCreate("zmin",
                        "CoordBase",
                        "REAL",
                        "PRIVATE",
                        CCTK_STEERABLE_NEVER,
                        "Location of lower z boundary",
                        "0.0",
                        &(PRIVATE_COORDBASE_STRUCT.zmin),
                        0,
                        NULL,
                        1,
                        "(*:*)", "");

  return 0;
}

int CCTKi_BindingsCoordBaseParameterExtensions(void);
int CCTKi_BindingsCoordBaseParameterExtensions(void)
{
  return 0;
}
