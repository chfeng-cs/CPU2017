/*@@
   @header  CoordBase_Prototypes.h
   @author  Automatically generated by CreateFunctionBindings.pl
   @desc
            Prototypes for overloaded functions used by this thorn
   @enddesc
  @@*/


#ifndef _COORDBASE_PROTOTYPES_H_
#define _COORDBASE_PROTOTYPES_H_  1

#ifdef CCODE
#ifdef __cplusplus
extern "C" {
#endif

CCTK_INT ConvertFromExteriorBoundary(const CCTK_INT size ,
 CCTK_REAL* physical_min ,
 CCTK_REAL* physical_max ,
 CCTK_REAL* interior_min ,
 CCTK_REAL* interior_max ,
 const CCTK_REAL* exterior_min ,
 const CCTK_REAL* exterior_max ,
 const CCTK_REAL* spacing);
CCTK_INT CoordBase_ConvertFromExteriorBoundary(const CCTK_INT size ,
 CCTK_REAL* physical_min ,
 CCTK_REAL* physical_max ,
 CCTK_REAL* interior_min ,
 CCTK_REAL* interior_max ,
 const CCTK_REAL* exterior_min ,
 const CCTK_REAL* exterior_max ,
 const CCTK_REAL* spacing);

CCTK_INT ConvertFromInteriorBoundary(const CCTK_INT size ,
 CCTK_REAL* physical_min ,
 CCTK_REAL* physical_max ,
 const CCTK_REAL* interior_min ,
 const CCTK_REAL* interior_max ,
 CCTK_REAL* exterior_min ,
 CCTK_REAL* exterior_max ,
 const CCTK_REAL* spacing);
CCTK_INT CoordBase_ConvertFromInteriorBoundary(const CCTK_INT size ,
 CCTK_REAL* physical_min ,
 CCTK_REAL* physical_max ,
 const CCTK_REAL* interior_min ,
 const CCTK_REAL* interior_max ,
 CCTK_REAL* exterior_min ,
 CCTK_REAL* exterior_max ,
 const CCTK_REAL* spacing);

CCTK_INT ConvertFromPhysicalBoundary(const CCTK_INT size ,
 const CCTK_REAL* physical_min ,
 const CCTK_REAL* physical_max ,
 CCTK_REAL* interior_min ,
 CCTK_REAL* interior_max ,
 CCTK_REAL* exterior_min ,
 CCTK_REAL* exterior_max ,
 const CCTK_REAL* spacing);
CCTK_INT CoordBase_ConvertFromPhysicalBoundary(const CCTK_INT size ,
 const CCTK_REAL* physical_min ,
 const CCTK_REAL* physical_max ,
 CCTK_REAL* interior_min ,
 CCTK_REAL* interior_max ,
 CCTK_REAL* exterior_min ,
 CCTK_REAL* exterior_max ,
 const CCTK_REAL* spacing);

CCTK_INT Coord_CoordHandle(const CCTK_POINTER_TO_CONST GH ,
 CCTK_STRING coordname, CCTK_STRING systemname);
CCTK_INT CoordBase_CoordHandle(const CCTK_POINTER_TO_CONST GH ,
 CCTK_STRING coordname, CCTK_STRING systemname);

CCTK_INT Coord_CoordRegister(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT systemhandle ,
 const CCTK_INT direction ,
 CCTK_STRING coordname);
CCTK_INT CoordBase_CoordRegister(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT systemhandle ,
 const CCTK_INT direction ,
 CCTK_STRING coordname);

CCTK_INT Coord_GetDefaultSystem(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT systemdim);
CCTK_INT CoordBase_GetDefaultSystem(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT systemdim);

CCTK_INT Coord_GroupSystem(const CCTK_POINTER_TO_CONST GH ,
 CCTK_STRING groupname);
CCTK_INT CoordBase_GroupSystem(const CCTK_POINTER_TO_CONST GH ,
 CCTK_STRING groupname);

CCTK_INT Coord_SetDefaultSystem(const CCTK_POINTER_TO_CONST GH ,
 CCTK_STRING systemname);
CCTK_INT CoordBase_SetDefaultSystem(const CCTK_POINTER_TO_CONST GH ,
 CCTK_STRING systemname);

CCTK_INT Coord_SystemHandle(const CCTK_POINTER_TO_CONST GH ,
 CCTK_STRING systemname);
CCTK_INT CoordBase_SystemHandle(const CCTK_POINTER_TO_CONST GH ,
 CCTK_STRING systemname);

CCTK_INT Coord_SystemRegister(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT dim ,
 CCTK_STRING systemname);
CCTK_INT CoordBase_SystemRegister(const CCTK_POINTER_TO_CONST GH ,
 const CCTK_INT dim ,
 CCTK_STRING systemname);

CCTK_INT GetBoundarySizesAndTypes(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT size ,
 CCTK_INT* bndsize ,
 CCTK_INT* is_ghostbnd ,
 CCTK_INT* is_symbnd ,
 CCTK_INT* is_physbnd);
CCTK_INT CoordBase_GetBoundarySizesAndTypes(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT size ,
 CCTK_INT* bndsize ,
 CCTK_INT* is_ghostbnd ,
 CCTK_INT* is_symbnd ,
 CCTK_INT* is_physbnd);

CCTK_INT GetBoundarySpecification(const CCTK_INT size ,
 CCTK_INT* nboundaryzones ,
 CCTK_INT* is_internal ,
 CCTK_INT* is_staggered ,
 CCTK_INT* shiftout);
CCTK_INT CoordBase_GetBoundarySpecification(const CCTK_INT size ,
 CCTK_INT* nboundaryzones ,
 CCTK_INT* is_internal ,
 CCTK_INT* is_staggered ,
 CCTK_INT* shiftout);

CCTK_INT GetDomainSpecification(const CCTK_INT size ,
 CCTK_REAL* physical_min ,
 CCTK_REAL* physical_max ,
 CCTK_REAL* interior_min ,
 CCTK_REAL* interior_max ,
 CCTK_REAL* exterior_min ,
 CCTK_REAL* exterior_max ,
 CCTK_REAL* spacing);
CCTK_INT CoordBase_GetDomainSpecification(const CCTK_INT size ,
 CCTK_REAL* physical_min ,
 CCTK_REAL* physical_max ,
 CCTK_REAL* interior_min ,
 CCTK_REAL* interior_max ,
 CCTK_REAL* exterior_min ,
 CCTK_REAL* exterior_max ,
 CCTK_REAL* spacing);

CCTK_INT MultiPatch_GetBbox(const CCTK_POINTER_TO_CONST cctkGH ,
 const CCTK_INT size ,
 CCTK_INT* bbox);

CCTK_INT MultiPatch_GetBoundarySpecification(const CCTK_INT map ,
 const CCTK_INT size ,
 CCTK_INT* nboundaryzones ,
 CCTK_INT* is_internal ,
 CCTK_INT* is_staggered ,
 CCTK_INT* shiftout);

CCTK_INT MultiPatch_GetMap(const CCTK_POINTER_TO_CONST cctkGH);

CCTK_INT SymmetryTableHandleForGrid(const CCTK_POINTER_TO_CONST cctkGH);

#ifdef __cplusplus
}
#endif
#endif /* CCODE */

#ifdef FCODE
#ifdef F90CODE
#define DECLARE_COORDBASE_FUNCTIONS _DECLARE_CCTK_FUNCTIONS \
  interface &&\
     CCTK_INT function ConvertFromExteriorBoundary (size, physical_min, physical_max, interior_min, interior_max, exterior_min, exterior_max, spacing) &&\
       implicit none &&\
       CCTK_INT size &&\
       CCTK_REAL physical_min(*) &&\
       CCTK_REAL physical_max(*) &&\
       CCTK_REAL interior_min(*) &&\
       CCTK_REAL interior_max(*) &&\
       CCTK_REAL exterior_min(*) &&\
       CCTK_REAL exterior_max(*) &&\
       CCTK_REAL spacing(*) &&\
     end function ConvertFromExteriorBoundary &&\
  end interface &&\
  interface &&\
     CCTK_INT function ConvertFromInteriorBoundary (size, physical_min, physical_max, interior_min, interior_max, exterior_min, exterior_max, spacing) &&\
       implicit none &&\
       CCTK_INT size &&\
       CCTK_REAL physical_min(*) &&\
       CCTK_REAL physical_max(*) &&\
       CCTK_REAL interior_min(*) &&\
       CCTK_REAL interior_max(*) &&\
       CCTK_REAL exterior_min(*) &&\
       CCTK_REAL exterior_max(*) &&\
       CCTK_REAL spacing(*) &&\
     end function ConvertFromInteriorBoundary &&\
  end interface &&\
  interface &&\
     CCTK_INT function ConvertFromPhysicalBoundary (size, physical_min, physical_max, interior_min, interior_max, exterior_min, exterior_max, spacing) &&\
       implicit none &&\
       CCTK_INT size &&\
       CCTK_REAL physical_min(*) &&\
       CCTK_REAL physical_max(*) &&\
       CCTK_REAL interior_min(*) &&\
       CCTK_REAL interior_max(*) &&\
       CCTK_REAL exterior_min(*) &&\
       CCTK_REAL exterior_max(*) &&\
       CCTK_REAL spacing(*) &&\
     end function ConvertFromPhysicalBoundary &&\
  end interface &&\
  interface &&\
     CCTK_INT function Coord_CoordHandle (GH, coordname, systemname) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       character(*) coordname &&\
       character(*) systemname &&\
     end function Coord_CoordHandle &&\
  end interface &&\
  interface &&\
     CCTK_INT function Coord_CoordRegister (GH, systemhandle, direction, coordname) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       CCTK_INT systemhandle &&\
       CCTK_INT direction &&\
       character(*) coordname &&\
     end function Coord_CoordRegister &&\
  end interface &&\
  interface &&\
     CCTK_INT function Coord_GetDefaultSystem (GH, systemdim) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       CCTK_INT systemdim &&\
     end function Coord_GetDefaultSystem &&\
  end interface &&\
  interface &&\
     CCTK_INT function Coord_GroupSystem (GH, groupname) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       character(*) groupname &&\
     end function Coord_GroupSystem &&\
  end interface &&\
  interface &&\
     CCTK_INT function Coord_SetDefaultSystem (GH, systemname) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       character(*) systemname &&\
     end function Coord_SetDefaultSystem &&\
  end interface &&\
  interface &&\
     CCTK_INT function Coord_SystemHandle (GH, systemname) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       character(*) systemname &&\
     end function Coord_SystemHandle &&\
  end interface &&\
  interface &&\
     CCTK_INT function Coord_SystemRegister (GH, dim, systemname) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST GH &&\
       CCTK_INT dim &&\
       character(*) systemname &&\
     end function Coord_SystemRegister &&\
  end interface &&\
  interface &&\
     CCTK_INT function GetBoundarySizesAndTypes (cctkGH, size, bndsize, is_ghostbnd, is_symbnd, is_physbnd) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST cctkGH &&\
       CCTK_INT size &&\
       CCTK_INT bndsize(*) &&\
       CCTK_INT is_ghostbnd(*) &&\
       CCTK_INT is_symbnd(*) &&\
       CCTK_INT is_physbnd(*) &&\
     end function GetBoundarySizesAndTypes &&\
  end interface &&\
  interface &&\
     CCTK_INT function GetBoundarySpecification (size, nboundaryzones, is_internal, is_staggered, shiftout) &&\
       implicit none &&\
       CCTK_INT size &&\
       CCTK_INT nboundaryzones(*) &&\
       CCTK_INT is_internal(*) &&\
       CCTK_INT is_staggered(*) &&\
       CCTK_INT shiftout(*) &&\
     end function GetBoundarySpecification &&\
  end interface &&\
  interface &&\
     CCTK_INT function GetDomainSpecification (size, physical_min, physical_max, interior_min, interior_max, exterior_min, exterior_max, spacing) &&\
       implicit none &&\
       CCTK_INT size &&\
       CCTK_REAL physical_min(*) &&\
       CCTK_REAL physical_max(*) &&\
       CCTK_REAL interior_min(*) &&\
       CCTK_REAL interior_max(*) &&\
       CCTK_REAL exterior_min(*) &&\
       CCTK_REAL exterior_max(*) &&\
       CCTK_REAL spacing(*) &&\
     end function GetDomainSpecification &&\
  end interface &&\
  interface &&\
     CCTK_INT function MultiPatch_GetBbox (cctkGH, size, bbox) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST cctkGH &&\
       CCTK_INT size &&\
       CCTK_INT bbox(*) &&\
     end function MultiPatch_GetBbox &&\
  end interface &&\
  interface &&\
     CCTK_INT function MultiPatch_GetBoundarySpecification (map, size, nboundaryzones, is_internal, is_staggered, shiftout) &&\
       implicit none &&\
       CCTK_INT map &&\
       CCTK_INT size &&\
       CCTK_INT nboundaryzones(*) &&\
       CCTK_INT is_internal(*) &&\
       CCTK_INT is_staggered(*) &&\
       CCTK_INT shiftout(*) &&\
     end function MultiPatch_GetBoundarySpecification &&\
  end interface &&\
  interface &&\
     CCTK_INT function MultiPatch_GetMap (cctkGH) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST cctkGH &&\
     end function MultiPatch_GetMap &&\
  end interface &&\
  interface &&\
     CCTK_INT function SymmetryTableHandleForGrid (cctkGH) &&\
       implicit none &&\
       CCTK_POINTER_TO_CONST cctkGH &&\
     end function SymmetryTableHandleForGrid &&\
  end interface &&\

#else /* ! F90CODE */

#define DECLARE_COORDBASE_FUNCTIONS _DECLARE_CCTK_FUNCTIONS \
  external ConvertFromExteriorBoundary &&\
  CCTK_INT ConvertFromExteriorBoundary &&\
  external ConvertFromInteriorBoundary &&\
  CCTK_INT ConvertFromInteriorBoundary &&\
  external ConvertFromPhysicalBoundary &&\
  CCTK_INT ConvertFromPhysicalBoundary &&\
  external Coord_CoordHandle &&\
  CCTK_INT Coord_CoordHandle &&\
  external Coord_CoordRegister &&\
  CCTK_INT Coord_CoordRegister &&\
  external Coord_GetDefaultSystem &&\
  CCTK_INT Coord_GetDefaultSystem &&\
  external Coord_GroupSystem &&\
  CCTK_INT Coord_GroupSystem &&\
  external Coord_SetDefaultSystem &&\
  CCTK_INT Coord_SetDefaultSystem &&\
  external Coord_SystemHandle &&\
  CCTK_INT Coord_SystemHandle &&\
  external Coord_SystemRegister &&\
  CCTK_INT Coord_SystemRegister &&\
  external GetBoundarySizesAndTypes &&\
  CCTK_INT GetBoundarySizesAndTypes &&\
  external GetBoundarySpecification &&\
  CCTK_INT GetBoundarySpecification &&\
  external GetDomainSpecification &&\
  CCTK_INT GetDomainSpecification &&\
  external MultiPatch_GetBbox &&\
  CCTK_INT MultiPatch_GetBbox &&\
  external MultiPatch_GetBoundarySpecification &&\
  CCTK_INT MultiPatch_GetBoundarySpecification &&\
  external MultiPatch_GetMap &&\
  CCTK_INT MultiPatch_GetMap &&\
  external SymmetryTableHandleForGrid &&\
  CCTK_INT SymmetryTableHandleForGrid &&\

#endif /* ! F90CODE */
#endif /* FCODE */

#endif
