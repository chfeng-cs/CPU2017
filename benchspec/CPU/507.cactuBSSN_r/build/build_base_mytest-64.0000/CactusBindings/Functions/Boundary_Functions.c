/*@@
   @file    Boundary_Functions.c
   @author  Automatically generated by CreateFunctionBindings.pl
   @desc
            The wrappers for functions provided by thorn Boundary.
   @enddesc
 @@*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cctk_Flesh.h"
#include "cctk_WarnLevel.h"

static CCTK_INT (*CCTK_FptrBdry_Boundary_RegisterPhysicalBCfunction_pointer)(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles);
static CCTK_INT CCTK_WrapBdry_Boundary_RegisterPhysicalBCfunction_pointer(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles);
CCTK_INT CCTK_WrapBdry_Boundary_RegisterPhysicalBCfunction_pointer(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles)
{
  return (*CCTK_FptrBdry_Boundary_RegisterPhysicalBCfunction_pointer)(&GH , &num_vars , var_indices , faces , boundary_widths , table_handles);
}

extern CCTK_INT Bdry_Boundary_RegisterPhysicalBC(const CCTK_POINTER_TO_CONST GH ,
 CCTK_INT (*const function_pointer)(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles) ,
 CCTK_STRING bc_name);
static CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_RegisterPhysicalBC(const CCTK_POINTER_TO_CONST* GH ,
 CCTK_INT (*const function_pointer)(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles) ,
 CCTK_STRING bc_name);
CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_RegisterPhysicalBC(const CCTK_POINTER_TO_CONST* GH ,
 CCTK_INT (*const function_pointer)(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles) ,
 CCTK_STRING bc_name)
{
  CCTK_FptrBdry_Boundary_RegisterPhysicalBCfunction_pointer = function_pointer;

  return (Bdry_Boundary_RegisterPhysicalBC)(*GH , CCTK_WrapBdry_Boundary_RegisterPhysicalBCfunction_pointer , bc_name);
}


extern CCTK_INT Bdry_Boundary_SelectGroupForBC(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 CCTK_STRING group_name, CCTK_STRING bc_name);
static CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectGroupForBC(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 CCTK_STRING group_name, CCTK_STRING bc_name);
CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectGroupForBC(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 CCTK_STRING group_name, CCTK_STRING bc_name)
{


  return (Bdry_Boundary_SelectGroupForBC)(*GH , *faces , *boundary_width , *table_handle , group_name , bc_name);
}


extern CCTK_INT Bdry_Boundary_SelectGroupForBCI(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 const CCTK_INT group_index ,
 CCTK_STRING bc_name);
static CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectGroupForBCI(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 const CCTK_INT* group_index ,
 CCTK_STRING bc_name);
CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectGroupForBCI(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 const CCTK_INT* group_index ,
 CCTK_STRING bc_name)
{


  return (Bdry_Boundary_SelectGroupForBCI)(*GH , *faces , *boundary_width , *table_handle , *group_index , bc_name);
}


extern CCTK_INT Bdry_Boundary_SelectVarForBC(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 CCTK_STRING var_name, CCTK_STRING bc_name);
static CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectVarForBC(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 CCTK_STRING var_name, CCTK_STRING bc_name);
CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectVarForBC(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 CCTK_STRING var_name, CCTK_STRING bc_name)
{


  return (Bdry_Boundary_SelectVarForBC)(*GH , *faces , *boundary_width , *table_handle , var_name , bc_name);
}


extern CCTK_INT Bdry_Boundary_SelectVarForBCI(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 const CCTK_INT var_index ,
 CCTK_STRING bc_name);
static CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectVarForBCI(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 const CCTK_INT* var_index ,
 CCTK_STRING bc_name);
CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectVarForBCI(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 const CCTK_INT* var_index ,
 CCTK_STRING bc_name)
{


  return (Bdry_Boundary_SelectVarForBCI)(*GH , *faces , *boundary_width , *table_handle , *var_index , bc_name);
}


extern CCTK_INT Bdry_Boundary_SelectedGVs(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT array_size ,
 CCTK_INT* var_indicies ,
 CCTK_INT* faces ,
 CCTK_INT* boundary_widths ,
 CCTK_INT* table_handles ,
 CCTK_STRING bc_name);
static CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectedGVs(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* array_size ,
 CCTK_INT* var_indicies ,
 CCTK_INT* faces ,
 CCTK_INT* boundary_widths ,
 CCTK_INT* table_handles ,
 CCTK_STRING bc_name);
CCTK_INT CCTK_Wrapper_CtoF_Bdry_Boundary_SelectedGVs(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* array_size ,
 CCTK_INT* var_indicies ,
 CCTK_INT* faces ,
 CCTK_INT* boundary_widths ,
 CCTK_INT* table_handles ,
 CCTK_STRING bc_name)
{


  return (Bdry_Boundary_SelectedGVs)(*GH , *array_size , var_indicies , faces , boundary_widths , table_handles , bc_name);
}

CCTK_INT Register_Boundary(void);
CCTK_INT AliasBoundary_RegisterPhysicalBC_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST GH ,
 CCTK_INT (*const function_pointer)(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles) ,
 CCTK_STRING bc_name));
CCTK_INT AliasBoundary_RegisterPhysicalBC_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* GH ,
 CCTK_INT (*const function_pointer)(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles) ,
 CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectGroupForBC_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 CCTK_STRING group_name, CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectGroupForBC_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 CCTK_STRING group_name, CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectGroupForBCI_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 const CCTK_INT group_index ,
 CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectGroupForBCI_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 const CCTK_INT* group_index ,
 CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectVarForBC_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 CCTK_STRING var_name, CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectVarForBC_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 CCTK_STRING var_name, CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectVarForBCI_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 const CCTK_INT var_index ,
 CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectVarForBCI_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_width ,
 const CCTK_INT* table_handle ,
 const CCTK_INT* var_index ,
 CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectedGVs_C(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT array_size ,
 CCTK_INT* var_indicies ,
 CCTK_INT* faces ,
 CCTK_INT* boundary_widths ,
 CCTK_INT* table_handles ,
 CCTK_STRING bc_name));
CCTK_INT AliasBoundary_SelectedGVs_F(CCTK_INT (*func)(const CCTK_POINTER_TO_CONST* GH ,
 const CCTK_INT* array_size ,
 CCTK_INT* var_indicies ,
 CCTK_INT* faces ,
 CCTK_INT* boundary_widths ,
 CCTK_INT* table_handles ,
 CCTK_STRING bc_name));
CCTK_INT Register_Boundary(void)
{
  CCTK_INT ierr;

  ierr = 0;

  ierr += AliasBoundary_RegisterPhysicalBC_F(CCTK_Wrapper_CtoF_Bdry_Boundary_RegisterPhysicalBC);
  ierr += AliasBoundary_RegisterPhysicalBC_C(Bdry_Boundary_RegisterPhysicalBC);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasBoundary_SelectGroupForBC_F(CCTK_Wrapper_CtoF_Bdry_Boundary_SelectGroupForBC);
  ierr += AliasBoundary_SelectGroupForBC_C(Bdry_Boundary_SelectGroupForBC);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasBoundary_SelectGroupForBCI_F(CCTK_Wrapper_CtoF_Bdry_Boundary_SelectGroupForBCI);
  ierr += AliasBoundary_SelectGroupForBCI_C(Bdry_Boundary_SelectGroupForBCI);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasBoundary_SelectVarForBC_F(CCTK_Wrapper_CtoF_Bdry_Boundary_SelectVarForBC);
  ierr += AliasBoundary_SelectVarForBC_C(Bdry_Boundary_SelectVarForBC);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasBoundary_SelectVarForBCI_F(CCTK_Wrapper_CtoF_Bdry_Boundary_SelectVarForBCI);
  ierr += AliasBoundary_SelectVarForBCI_C(Bdry_Boundary_SelectVarForBCI);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  ierr += AliasBoundary_SelectedGVs_F(CCTK_Wrapper_CtoF_Bdry_Boundary_SelectedGVs);
  ierr += AliasBoundary_SelectedGVs_C(Bdry_Boundary_SelectedGVs);
  if (ierr)
  {
    CCTK_Warn(0, __LINE__, __FILE__, "Bindings",
              "Function already registered!");
  }
  return ierr;
}
