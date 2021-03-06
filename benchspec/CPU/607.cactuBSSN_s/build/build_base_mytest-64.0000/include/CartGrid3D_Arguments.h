/*@@
   @header  CartGrid3D_Arguments.h
   @author  Automatically generated by GridFuncStuff.pl
   @desc
            Defines macros to declare/define/pass function arguments
            in calls from C to Fortran for thorn CartGrid3D
   @enddesc
 @@*/


#ifdef FCODE
#define DECLARE_CARTGRID3D_PRIVATE_FARGUMENTS \


#define CARTGRID3D_PRIVATE_FARGUMENTS \


#endif /* FCODE */

#ifdef CCODE
#define DECLARE_CARTGRID3D_PRIVATE_CARGUMENTS \


#define DECLARE_CARTGRID3D_PRIVATE_C2F \


#define INITIALISE_CARTGRID3D_PRIVATE_C2F \


#define CARTGRID3D_PRIVATE_C2F_PROTO \


#define PASS_CARTGRID3D_PRIVATE_C2F(GH) \


#endif /* CCODE */

#ifdef FCODE
#define DECLARE_CARTGRID3D_PROTECTED_FARGUMENTS \


#define CARTGRID3D_PROTECTED_FARGUMENTS \


#endif /* FCODE */

#ifdef CCODE
#define DECLARE_CARTGRID3D_PROTECTED_CARGUMENTS \


#define DECLARE_CARTGRID3D_PROTECTED_C2F \


#define INITIALISE_CARTGRID3D_PROTECTED_C2F \


#define CARTGRID3D_PROTECTED_C2F_PROTO \


#define PASS_CARTGRID3D_PROTECTED_C2F(GH) \


#endif /* CCODE */

#ifdef FCODE
#define DECLARE_CARTGRID3D_PUBLIC_FARGUMENTS \
CCTK_DECLARE(CCTK_REAL,coarse_dx,)&&\
CCTK_DECLARE(CCTK_REAL,coarse_dy,)&&\
CCTK_DECLARE(CCTK_REAL,coarse_dz,)&&\
CCTK_DECLARE(CCTK_REAL,r,(cctk_ash1,cctk_ash2,cctk_ash3))&&\
CCTK_DECLARE(CCTK_REAL,x,(cctk_ash1,cctk_ash2,cctk_ash3))&&\
CCTK_DECLARE(CCTK_REAL,y,(cctk_ash1,cctk_ash2,cctk_ash3))&&\
CCTK_DECLARE(CCTK_REAL,z,(cctk_ash1,cctk_ash2,cctk_ash3))&&\


#define CARTGRID3D_PUBLIC_FARGUMENTS \
coarse_dx,coarse_dy,coarse_dz,r,x,y,z

#endif /* FCODE */

#ifdef CCODE
#define DECLARE_CARTGRID3D_PUBLIC_CARGUMENTS \
static int cctki_vi_coarse_dx = -100; \
if (cctki_vi_coarse_dx == -100) cctki_vi_coarse_dx = CCTK_VarIndex("grid::coarse_dx"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, coarse_dx, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_coarse_dx)); \
static int cctki_vi_coarse_dy = -100; \
if (cctki_vi_coarse_dy == -100) cctki_vi_coarse_dy = CCTK_VarIndex("grid::coarse_dy"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, coarse_dy, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_coarse_dy)); \
static int cctki_vi_coarse_dz = -100; \
if (cctki_vi_coarse_dz == -100) cctki_vi_coarse_dz = CCTK_VarIndex("grid::coarse_dz"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, coarse_dz, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_coarse_dz)); \
static int cctki_vi_r = -100; \
if (cctki_vi_r == -100) cctki_vi_r = CCTK_VarIndex("grid::r"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, r, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_r)); \
static int cctki_vi_x = -100; \
if (cctki_vi_x == -100) cctki_vi_x = CCTK_VarIndex("grid::x"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, x, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_x)); \
static int cctki_vi_y = -100; \
if (cctki_vi_y == -100) cctki_vi_y = CCTK_VarIndex("grid::y"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, y, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_y)); \
static int cctki_vi_z = -100; \
if (cctki_vi_z == -100) cctki_vi_z = CCTK_VarIndex("grid::z"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, z, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_z));

#define DECLARE_CARTGRID3D_PUBLIC_C2F \
static int CCTKARGNUM_coarse_dx = -1; \
static int CCTKGROUPNUM_gridspacings = -1; \
static int CCTKARGNUM_coarse_dy = -1; \
static int CCTKARGNUM_coarse_dz = -1; \
static int CCTKARGNUM_r = -1; \
static int CCTKGROUPNUM_coordinates = -1; \
static int CCTKARGNUM_x = -1; \
static int CCTKARGNUM_y = -1; \
static int CCTKARGNUM_z = -1;

#define INITIALISE_CARTGRID3D_PUBLIC_C2F \
if(CCTKARGNUM_coarse_dx == -1) CCTKARGNUM_coarse_dx = CCTK_VarIndex("grid::coarse_dx"); \
if(CCTKGROUPNUM_gridspacings == -1) CCTKGROUPNUM_gridspacings = CCTK_GroupIndex("grid::gridspacings"); \
if(CCTKARGNUM_coarse_dy == -1) CCTKARGNUM_coarse_dy = CCTK_VarIndex("grid::coarse_dy"); \
if(CCTKARGNUM_coarse_dz == -1) CCTKARGNUM_coarse_dz = CCTK_VarIndex("grid::coarse_dz"); \
if(CCTKARGNUM_r == -1) CCTKARGNUM_r = CCTK_VarIndex("grid::r"); \
if(CCTKGROUPNUM_coordinates == -1) CCTKGROUPNUM_coordinates = CCTK_GroupIndex("grid::coordinates"); \
if(CCTKARGNUM_x == -1) CCTKARGNUM_x = CCTK_VarIndex("grid::x"); \
if(CCTKARGNUM_y == -1) CCTKARGNUM_y = CCTK_VarIndex("grid::y"); \
if(CCTKARGNUM_z == -1) CCTKARGNUM_z = CCTK_VarIndex("grid::z");

#define CARTGRID3D_PUBLIC_C2F_PROTO \
CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *

#define PASS_CARTGRID3D_PUBLIC_C2F(GH) \
(CCTK_REAL *)(PASS_REFERENCE(coarse_dx, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(coarse_dy, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(coarse_dz, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(r, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(x, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(y, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(z, 0))

#endif /* CCODE */

#ifdef FCODE
#define CARTGRID3D_FARGUMENTS _CCTK_FARGUMENTS, CARTGRID3D_PUBLIC_FARGUMENTS

#define DECLARE_CARTGRID3D_FARGUMENTS _DECLARE_CCTK_FARGUMENTS DECLARE_CARTGRID3D_PUBLIC_FARGUMENTS

#endif /* FCODE */

#ifdef CCODE
#define DECLARE_CARTGRID3D_CARGUMENTS _DECLARE_CCTK_CARGUMENTS DECLARE_CARTGRID3D_PUBLIC_CARGUMENTS

#define CARTGRID3D_C2F_PROTO _CCTK_C2F_PROTO, CARTGRID3D_PUBLIC_C2F_PROTO

#define PASS_CARTGRID3D_C2F(GH) _PASS_CCTK_C2F(GH), PASS_CARTGRID3D_PUBLIC_C2F(GH)

#define DECLARE_CARTGRID3D_C2F _DECLARE_CCTK_C2F DECLARE_CARTGRID3D_PUBLIC_C2F

#define INITIALISE_CARTGRID3D_C2F _INITIALISE_CCTK_C2F INITIALISE_CARTGRID3D_PUBLIC_C2F

#define CARTGRID3D_CARGUMENTS cGH *cctkGH

#endif /* CCODE */
