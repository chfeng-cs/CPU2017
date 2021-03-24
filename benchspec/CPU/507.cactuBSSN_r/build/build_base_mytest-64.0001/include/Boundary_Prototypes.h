/*@@
   @header  Boundary_Prototypes.h
   @author  Automatically generated by CreateFunctionBindings.pl
   @desc
            Prototypes for overloaded functions used by this thorn
   @enddesc
  @@*/


#ifndef _BOUNDARY_PROTOTYPES_H_
#define _BOUNDARY_PROTOTYPES_H_  1

#ifdef CCODE
#ifdef __cplusplus
extern "C" {
#endif

CCTK_INT Boundary_RegisterPhysicalBC(const CCTK_POINTER_TO_CONST GH ,
 CCTK_INT (*const function_pointer)(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles) ,
 CCTK_STRING bc_name);
CCTK_INT Bdry_Boundary_RegisterPhysicalBC(const CCTK_POINTER_TO_CONST GH ,
 CCTK_INT (*const function_pointer)(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT num_vars ,
 const CCTK_INT* var_indices ,
 const CCTK_INT* faces ,
 const CCTK_INT* boundary_widths ,
 const CCTK_INT* table_handles) ,
 CCTK_STRING bc_name);

CCTK_INT Boundary_SelectGroupForBC(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 CCTK_STRING group_name, CCTK_STRING bc_name);
CCTK_INT Bdry_Boundary_SelectGroupForBC(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 CCTK_STRING group_name, CCTK_STRING bc_name);

CCTK_INT Boundary_SelectGroupForBCI(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 const CCTK_INT group_index ,
 CCTK_STRING bc_name);
CCTK_INT Bdry_Boundary_SelectGroupForBCI(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 const CCTK_INT group_index ,
 CCTK_STRING bc_name);

CCTK_INT Boundary_SelectVarForBC(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 CCTK_STRING var_name, CCTK_STRING bc_name);
CCTK_INT Bdry_Boundary_SelectVarForBC(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 CCTK_STRING var_name, CCTK_STRING bc_name);

CCTK_INT Boundary_SelectVarForBCI(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 const CCTK_INT var_index ,
 CCTK_STRING bc_name);
CCTK_INT Bdry_Boundary_SelectVarForBCI(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT faces ,
 const CCTK_INT boundary_width ,
 const CCTK_INT table_handle ,
 const CCTK_INT var_index ,
 CCTK_STRING bc_name);

CCTK_INT Boundary_SelectedGVs(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT array_size ,
 CCTK_INT* var_indicies ,
 CCTK_INT* faces ,
 CCTK_INT* boundary_widths ,
 CCTK_INT* table_handles ,
 CCTK_STRING bc_name);
CCTK_INT Bdry_Boundary_SelectedGVs(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT array_size ,
 CCTK_INT* var_indicies ,
 CCTK_INT* faces ,
 CCTK_INT* boundary_widths ,
 CCTK_INT* table_handles ,
 CCTK_STRING bc_name);

CCTK_INT SymmetryTableHandleForGrid(const CCTK_POINTER_TO_CONST cctkGH);

#ifdef __cplusplus
}
#endif
#endif /* CCODE */

#ifdef FCODE
#ifdef F90CODE
#define DECLARE_BOUNDARY_FUNCTIONS _DECLARE_CCTK_FUNCTIONS \
  interface &&\
     CCTK_INT function Boundary_RegisterPhysicalBC (GH, function_pointer, bc_name) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       external function_pointer &&\
       CCTK_INT function_pointer &&\
       character(*) bc_name &&\
     end function Boundary_RegisterPhysicalBC &&\
  end interface &&\
  interface &&\
     CCTK_INT function Boundary_SelectGroupForBC (GH, faces, boundary_width, table_handle, group_name, bc_name) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       CCTK_INT faces &&\
       CCTK_INT boundary_width &&\
       CCTK_INT table_handle &&\
       character(*) group_name &&\
       character(*) bc_name &&\
     end function Boundary_SelectGroupForBC &&\
  end interface &&\
  interface &&\
     CCTK_INT function Boundary_SelectGroupForBCI (GH, faces, boundary_width, table_handle, group_index, bc_name) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       CCTK_INT faces &&\
       CCTK_INT boundary_width &&\
       CCTK_INT table_handle &&\
       CCTK_INT group_index &&\
       character(*) bc_name &&\
     end function Boundary_SelectGroupForBCI &&\
  end interface &&\
  interface &&\
     CCTK_INT function Boundary_SelectVarForBC (GH, faces, boundary_width, table_handle, var_name, bc_name) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       CCTK_INT faces &&\
       CCTK_INT boundary_width &&\
       CCTK_INT table_handle &&\
       character(*) var_name &&\
       character(*) bc_name &&\
     end function Boundary_SelectVarForBC &&\
  end interface &&\
  interface &&\
     CCTK_INT function Boundary_SelectVarForBCI (GH, faces, boundary_width, table_handle, var_index, bc_name) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       CCTK_INT faces &&\
       CCTK_INT boundary_width &&\
       CCTK_INT table_handle &&\
       CCTK_INT var_index &&\
       character(*) bc_name &&\
     end function Boundary_SelectVarForBCI &&\
  end interface &&\
  interface &&\
     CCTK_INT function Boundary_SelectedGVs (GH, array_size, var_indicies, faces, boundary_widths, table_handles, bc_name) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       CCTK_INT array_size &&\
       CCTK_INT var_indicies(*) &&\
       CCTK_INT faces(*) &&\
       CCTK_INT boundary_widths(*) &&\
       CCTK_INT table_handles(*) &&\
       character(*) bc_name &&\
     end function Boundary_SelectedGVs &&\
  end interface &&\
  interface &&\
     CCTK_INT function SymmetryTableHandleForGrid (cctkGH) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST cctkGH &&\
     end function SymmetryTableHandleForGrid &&\
  end interface &&\

#else /* ! F90CODE */

#define DECLARE_BOUNDARY_FUNCTIONS _DECLARE_CCTK_FUNCTIONS \
  external Boundary_RegisterPhysicalBC &&\
  CCTK_INT Boundary_RegisterPhysicalBC &&\
  external Boundary_SelectGroupForBC &&\
  CCTK_INT Boundary_SelectGroupForBC &&\
  external Boundary_SelectGroupForBCI &&\
  CCTK_INT Boundary_SelectGroupForBCI &&\
  external Boundary_SelectVarForBC &&\
  CCTK_INT Boundary_SelectVarForBC &&\
  external Boundary_SelectVarForBCI &&\
  CCTK_INT Boundary_SelectVarForBCI &&\
  external Boundary_SelectedGVs &&\
  CCTK_INT Boundary_SelectedGVs &&\
  external SymmetryTableHandleForGrid &&\
  CCTK_INT SymmetryTableHandleForGrid &&\

#endif /* ! F90CODE */
#endif /* FCODE */

#endif

