/*@@
   @file    SymBase_Functions.c
   @author  Automatically generated by CreateFunctionBindings.pl
   @desc
            The wrappers for functions provided by thorn SymBase.
   @enddesc
 @@*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cctk_Flesh.h"
#include "cctk_WarnLevel.h"



extern CCTK_INT SymBase_GetSymmetryBoundaries(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT size ,
 CCTK_INT* symbnd);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_GetSymmetryBoundaries(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* size ,
 CCTK_INT* symbnd);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_GetSymmetryBoundaries(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* size ,
 CCTK_INT* symbnd)
{


  return (SymBase_GetSymmetryBoundaries)(*cctkGH , *size , symbnd);
}


extern CCTK_INT SymBase_SymmetryHandleOfName(CCTK_STRING sym_name);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryHandleOfName(CCTK_STRING sym_name);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryHandleOfName(CCTK_STRING sym_name)
{


  return (SymBase_SymmetryHandleOfName)(sym_name);
}


extern CCTK_INT SymBase_SymmetryInterpolate(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT N_dims ,
 const CCTK_INT local_interp_handle ,
 const CCTK_INT param_table_handle ,
 const CCTK_INT coord_system_handle ,
 const CCTK_INT N_interp_points ,
 const CCTK_INT interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryInterpolate(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryInterpolate(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays)
{


  return (SymBase_SymmetryInterpolate)(*cctkGH , *N_dims , *local_interp_handle , *param_table_handle , *coord_system_handle , *N_interp_points , *interp_coords_type , interp_coords , *N_input_arrays , input_array_indices , *N_output_arrays , output_array_types , output_arrays);
}


extern CCTK_INT SymBase_SymmetryInterpolateFaces(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT N_dims ,
 const CCTK_INT local_interp_handle ,
 const CCTK_INT param_table_handle ,
 const CCTK_INT coord_system_handle ,
 const CCTK_INT N_interp_points ,
 const CCTK_INT interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT faces);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryInterpolateFaces(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT* faces);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryInterpolateFaces(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT* faces)
{


  return (SymBase_SymmetryInterpolateFaces)(*cctkGH , *N_dims , *local_interp_handle , *param_table_handle , *coord_system_handle , *N_interp_points , *interp_coords_type , interp_coords , *N_input_arrays , input_array_indices , *N_output_arrays , output_array_types , output_arrays , *faces);
}


extern CCTK_POINTER_TO_CONST SymBase_SymmetryNameOfHandle(const CCTK_INT sym_handle);
static CCTK_POINTER_TO_CONST CCTK_Wrapper_CtoF_SymBase_SymmetryNameOfHandle(const CCTK_INT* sym_handle);
CCTK_POINTER_TO_CONST CCTK_Wrapper_CtoF_SymBase_SymmetryNameOfHandle(const CCTK_INT* sym_handle)
{


  return (SymBase_SymmetryNameOfHandle)(*sym_handle);
}


extern CCTK_INT SymBase_SymmetryRegister(CCTK_STRING sym_name);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegister(CCTK_STRING sym_name);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegister(CCTK_STRING sym_name)
{


  return (SymBase_SymmetryRegister)(sym_name);
}


extern CCTK_INT SymBase_SymmetryRegisterGI(const CCTK_POINTER cctkGH ,
 const CCTK_INT sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 const CCTK_INT group_index);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGI(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 const CCTK_INT* group_index);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGI(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 const CCTK_INT* group_index)
{


  return (SymBase_SymmetryRegisterGI)(*cctkGH , *sym_handle , which_faces , symmetry_zone_width , *group_index);
}


extern CCTK_INT SymBase_SymmetryRegisterGN(const CCTK_POINTER cctkGH ,
 const CCTK_INT sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 CCTK_STRING group_name);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGN(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 CCTK_STRING group_name);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGN(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 CCTK_STRING group_name)
{


  return (SymBase_SymmetryRegisterGN)(*cctkGH , *sym_handle , which_faces , symmetry_zone_width , group_name);
}


extern CCTK_INT SymBase_SymmetryRegisterGrid(const CCTK_POINTER cctkGH ,
 const CCTK_INT sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGrid(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGrid(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width)
{


  return (SymBase_SymmetryRegisterGrid)(*cctkGH , *sym_handle , which_faces , symmetry_zone_width);
}
static CCTK_INT (*CCTK_FptrSymBase_SymmetryRegisterGridInterpolatorsymmetry_interpolate)(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT* faces);
static CCTK_INT CCTK_WrapSymBase_SymmetryRegisterGridInterpolatorsymmetry_interpolate(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT N_dims ,
 const CCTK_INT local_interp_handle ,
 const CCTK_INT param_table_handle ,
 const CCTK_INT coord_system_handle ,
 const CCTK_INT N_interp_points ,
 const CCTK_INT interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT faces);
CCTK_INT CCTK_WrapSymBase_SymmetryRegisterGridInterpolatorsymmetry_interpolate(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT N_dims ,
 const CCTK_INT local_interp_handle ,
 const CCTK_INT param_table_handle ,
 const CCTK_INT coord_system_handle ,
 const CCTK_INT N_interp_points ,
 const CCTK_INT interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT faces)
{
  return (*CCTK_FptrSymBase_SymmetryRegisterGridInterpolatorsymmetry_interpolate)(&cctkGH , &N_dims , &local_interp_handle , &param_table_handle , &coord_system_handle , &N_interp_points , &interp_coords_type , interp_coords , &N_input_arrays , input_array_indices , &N_output_arrays , output_array_types , output_arrays , &faces);
}

extern CCTK_INT SymBase_SymmetryRegisterGridInterpolator(const CCTK_POINTER cctkGH ,
 const CCTK_INT sym_handle ,
 CCTK_INT (*const symmetry_interpolate)(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT N_dims ,
 const CCTK_INT local_interp_handle ,
 const CCTK_INT param_table_handle ,
 const CCTK_INT coord_system_handle ,
 const CCTK_INT N_interp_points ,
 const CCTK_INT interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT faces));
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGridInterpolator(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 CCTK_INT (*const symmetry_interpolate)(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT* faces));
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGridInterpolator(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 CCTK_INT (*const symmetry_interpolate)(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT* faces))
{
  CCTK_FptrSymBase_SymmetryRegisterGridInterpolatorsymmetry_interpolate = symmetry_interpolate;

  return (SymBase_SymmetryRegisterGridInterpolator)(*cctkGH , *sym_handle , CCTK_WrapSymBase_SymmetryRegisterGridInterpolatorsymmetry_interpolate);
}


extern CCTK_INT SymBase_SymmetryTableHandleForGI(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT group_index);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryTableHandleForGI(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* group_index);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryTableHandleForGI(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* group_index)
{


  return (SymBase_SymmetryTableHandleForGI)(*cctkGH , *group_index);
}


extern CCTK_INT SymBase_SymmetryTableHandleForGN(const CCTK_POINTER_TO_CONST cctkGH ,
 CCTK_STRING group_name);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryTableHandleForGN(const CCTK_POINTER_TO_CONST* cctkGH ,
 CCTK_STRING group_name);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryTableHandleForGN(const CCTK_POINTER_TO_CONST* cctkGH ,
 CCTK_STRING group_name)
{


  return (SymBase_SymmetryTableHandleForGN)(*cctkGH , group_name);
}


extern CCTK_INT SymBase_SymmetryTableHandleForGrid(const CCTK_POINTER_TO_CONST cctkGH);
static CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryTableHandleForGrid(const CCTK_POINTER_TO_CONST* cctkGH);
CCTK_INT CCTK_Wrapper_CtoF_SymBase_SymmetryTableHandleForGrid(const CCTK_POINTER_TO_CONST* cctkGH)
{


  return (SymBase_SymmetryTableHandleForGrid)(*cctkGH);
}

CCTK_INT Register_SymBase(void);
CCTK_INT AliasGetSymmetryBoundaries_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT size ,
 CCTK_INT* symbnd));
CCTK_INT AliasGetSymmetryBoundaries_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* size ,
 CCTK_INT* symbnd));
CCTK_INT AliasSymmetryHandleOfName_C(CCTK_INT (*func)(CCTK_STRING sym_name));
CCTK_INT AliasSymmetryHandleOfName_F(CCTK_INT (*func)(CCTK_STRING sym_name));
CCTK_INT AliasSymmetryInterpolate_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT N_dims ,
 const CCTK_INT local_interp_handle ,
 const CCTK_INT param_table_handle ,
 const CCTK_INT coord_system_handle ,
 const CCTK_INT N_interp_points ,
 const CCTK_INT interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays));
CCTK_INT AliasSymmetryInterpolate_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays));
CCTK_INT AliasSymmetryInterpolateFaces_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT N_dims ,
 const CCTK_INT local_interp_handle ,
 const CCTK_INT param_table_handle ,
 const CCTK_INT coord_system_handle ,
 const CCTK_INT N_interp_points ,
 const CCTK_INT interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT faces));
CCTK_INT AliasSymmetryInterpolateFaces_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT* faces));
CCTK_INT AliasSymmetryNameOfHandle_C(CCTK_POINTER_TO_CONST (*func)(const CCTK_INT sym_handle));
CCTK_INT AliasSymmetryNameOfHandle_F(CCTK_POINTER_TO_CONST (*func)(const CCTK_INT* sym_handle));
CCTK_INT AliasSymmetryRegister_C(CCTK_INT (*func)(CCTK_STRING sym_name));
CCTK_INT AliasSymmetryRegister_F(CCTK_INT (*func)(CCTK_STRING sym_name));
CCTK_INT AliasSymmetryRegisterGI_C(CCTK_INT (*func)(const CCTK_POINTER cctkGH ,
 const CCTK_INT sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 const CCTK_INT group_index));
CCTK_INT AliasSymmetryRegisterGI_F(CCTK_INT (*func)(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 const CCTK_INT* group_index));
CCTK_INT AliasSymmetryRegisterGN_C(CCTK_INT (*func)(const CCTK_POINTER cctkGH ,
 const CCTK_INT sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 CCTK_STRING group_name));
CCTK_INT AliasSymmetryRegisterGN_F(CCTK_INT (*func)(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width ,
 CCTK_STRING group_name));
CCTK_INT AliasSymmetryRegisterGrid_C(CCTK_INT (*func)(const CCTK_POINTER cctkGH ,
 const CCTK_INT sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width));
CCTK_INT AliasSymmetryRegisterGrid_F(CCTK_INT (*func)(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 const CCTK_INT* which_faces ,
 const CCTK_INT* symmetry_zone_width));
CCTK_INT AliasSymmetryRegisterGridInterpolator_C(CCTK_INT (*func)(const CCTK_POINTER cctkGH ,
 const CCTK_INT sym_handle ,
 CCTK_INT (*const symmetry_interpolate)(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT N_dims ,
 const CCTK_INT local_interp_handle ,
 const CCTK_INT param_table_handle ,
 const CCTK_INT coord_system_handle ,
 const CCTK_INT N_interp_points ,
 const CCTK_INT interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT faces)));
CCTK_INT AliasSymmetryRegisterGridInterpolator_F(CCTK_INT (*func)(const CCTK_POINTER* cctkGH ,
 const CCTK_INT* sym_handle ,
 CCTK_INT (*const symmetry_interpolate)(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* N_dims ,
 const CCTK_INT* local_interp_handle ,
 const CCTK_INT* param_table_handle ,
 const CCTK_INT* coord_system_handle ,
 const CCTK_INT* N_interp_points ,
 const CCTK_INT* interp_coords_type ,
 const CCTK_POINTER_TO_CONST* interp_coords ,
 const CCTK_INT* N_input_arrays ,
 const CCTK_INT* input_array_indices ,
 const CCTK_INT* N_output_arrays ,
 const CCTK_INT* output_array_types ,
 const CCTK_POINTER* output_arrays ,
 const CCTK_INT* faces)));
CCTK_INT AliasSymmetryTableHandleForGI_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT group_index));
CCTK_INT AliasSymmetryTableHandleForGI_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* cctkGH ,
 const CCTK_INT* group_index));
CCTK_INT AliasSymmetryTableHandleForGN_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST cctkGH ,
 CCTK_STRING group_name));
CCTK_INT AliasSymmetryTableHandleForGN_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* cctkGH ,
 CCTK_STRING group_name));
CCTK_INT AliasSymmetryTableHandleForGrid_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST cctkGH));
CCTK_INT AliasSymmetryTableHandleForGrid_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* cctkGH));
CCTK_INT Register_SymBase(void)
{
  CCTK_INT ierr;

  ierr = 0;

  ierr += AliasGetSymmetryBoundaries_F(CCTK_Wrapper_CtoF_SymBase_GetSymmetryBoundaries);
  ierr += AliasGetSymmetryBoundaries_C(SymBase_GetSymmetryBoundaries);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryHandleOfName_F(CCTK_Wrapper_CtoF_SymBase_SymmetryHandleOfName);
  ierr += AliasSymmetryHandleOfName_C(SymBase_SymmetryHandleOfName);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryInterpolate_F(CCTK_Wrapper_CtoF_SymBase_SymmetryInterpolate);
  ierr += AliasSymmetryInterpolate_C(SymBase_SymmetryInterpolate);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryInterpolateFaces_F(CCTK_Wrapper_CtoF_SymBase_SymmetryInterpolateFaces);
  ierr += AliasSymmetryInterpolateFaces_C(SymBase_SymmetryInterpolateFaces);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryNameOfHandle_F(CCTK_Wrapper_CtoF_SymBase_SymmetryNameOfHandle);
  ierr += AliasSymmetryNameOfHandle_C(SymBase_SymmetryNameOfHandle);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryRegister_F(CCTK_Wrapper_CtoF_SymBase_SymmetryRegister);
  ierr += AliasSymmetryRegister_C(SymBase_SymmetryRegister);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryRegisterGI_F(CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGI);
  ierr += AliasSymmetryRegisterGI_C(SymBase_SymmetryRegisterGI);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryRegisterGN_F(CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGN);
  ierr += AliasSymmetryRegisterGN_C(SymBase_SymmetryRegisterGN);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryRegisterGrid_F(CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGrid);
  ierr += AliasSymmetryRegisterGrid_C(SymBase_SymmetryRegisterGrid);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryRegisterGridInterpolator_F(CCTK_Wrapper_CtoF_SymBase_SymmetryRegisterGridInterpolator);
  ierr += AliasSymmetryRegisterGridInterpolator_C(SymBase_SymmetryRegisterGridInterpolator);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryTableHandleForGI_F(CCTK_Wrapper_CtoF_SymBase_SymmetryTableHandleForGI);
  ierr += AliasSymmetryTableHandleForGI_C(SymBase_SymmetryTableHandleForGI);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryTableHandleForGN_F(CCTK_Wrapper_CtoF_SymBase_SymmetryTableHandleForGN);
  ierr += AliasSymmetryTableHandleForGN_C(SymBase_SymmetryTableHandleForGN);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasSymmetryTableHandleForGrid_F(CCTK_Wrapper_CtoF_SymBase_SymmetryTableHandleForGrid);
  ierr += AliasSymmetryTableHandleForGrid_C(SymBase_SymmetryTableHandleForGrid);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  return ierr;
}
