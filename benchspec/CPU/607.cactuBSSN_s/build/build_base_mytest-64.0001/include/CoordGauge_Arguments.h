/*@@
   @header  CoordGauge_Arguments.h
   @author  Automatically generated by GridFuncStuff.pl
   @desc
            Defines macros to declare/define/pass function arguments
            in calls from C to Fortran for thorn CoordGauge
   @enddesc
 @@*/


#ifdef FCODE
#define DECLARE_COORDGAUGE_PRIVATE_FARGUMENTS \


#define COORDGAUGE_PRIVATE_FARGUMENTS \


#endif /* FCODE */

#ifdef CCODE
#define DECLARE_COORDGAUGE_PRIVATE_CARGUMENTS \


#define DECLARE_COORDGAUGE_PRIVATE_C2F \


#define INITIALISE_COORDGAUGE_PRIVATE_C2F \


#define COORDGAUGE_PRIVATE_C2F_PROTO \


#define PASS_COORDGAUGE_PRIVATE_C2F(GH) \


#endif /* CCODE */

#ifdef FCODE
#define DECLARE_COORDGAUGE_PROTECTED_FARGUMENTS \


#define COORDGAUGE_PROTECTED_FARGUMENTS \


#endif /* FCODE */

#ifdef CCODE
#define DECLARE_COORDGAUGE_PROTECTED_CARGUMENTS \


#define DECLARE_COORDGAUGE_PROTECTED_C2F \


#define INITIALISE_COORDGAUGE_PROTECTED_C2F \


#define COORDGAUGE_PROTECTED_C2F_PROTO \


#define PASS_COORDGAUGE_PROTECTED_C2F(GH) \


#endif /* CCODE */

#ifdef FCODE
#define DECLARE_COORDGAUGE_PUBLIC_FARGUMENTS \
CCTK_DECLARE(CCTK_INT,active_slicing_handle,)&&\


#define COORDGAUGE_PUBLIC_FARGUMENTS \
active_slicing_handle

#endif /* FCODE */

#ifdef CCODE
#define DECLARE_COORDGAUGE_PUBLIC_CARGUMENTS \
static int cctki_vi_active_slicing_handle = -100; \
if (cctki_vi_active_slicing_handle == -100) cctki_vi_active_slicing_handle = CCTK_VarIndex("CoordGauge::active_slicing_handle"); \
CCTK_DECLARE_INIT (CCTK_INT * restrict const, active_slicing_handle, (CCTK_INT *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_active_slicing_handle));

#define DECLARE_COORDGAUGE_PUBLIC_C2F \
static int CCTKARGNUM_active_slicing_handle = -1; \
static int CCTKGROUPNUM_slicing_flags = -1;

#define INITIALISE_COORDGAUGE_PUBLIC_C2F \
if(CCTKARGNUM_active_slicing_handle == -1) CCTKARGNUM_active_slicing_handle = CCTK_VarIndex("CoordGauge::active_slicing_handle"); \
if(CCTKGROUPNUM_slicing_flags == -1) CCTKGROUPNUM_slicing_flags = CCTK_GroupIndex("CoordGauge::slicing_flags");

#define COORDGAUGE_PUBLIC_C2F_PROTO \
CCTK_INT *

#define PASS_COORDGAUGE_PUBLIC_C2F(GH) \
(CCTK_INT *)(PASS_REFERENCE(active_slicing_handle, 0))

#endif /* CCODE */

#ifdef FCODE
#define COORDGAUGE_FARGUMENTS _CCTK_FARGUMENTS, COORDGAUGE_PUBLIC_FARGUMENTS

#define DECLARE_COORDGAUGE_FARGUMENTS _DECLARE_CCTK_FARGUMENTS DECLARE_COORDGAUGE_PUBLIC_FARGUMENTS

#endif /* FCODE */

#ifdef CCODE
#define DECLARE_COORDGAUGE_CARGUMENTS _DECLARE_CCTK_CARGUMENTS DECLARE_COORDGAUGE_PUBLIC_CARGUMENTS

#define COORDGAUGE_C2F_PROTO _CCTK_C2F_PROTO, COORDGAUGE_PUBLIC_C2F_PROTO

#define PASS_COORDGAUGE_C2F(GH) _PASS_CCTK_C2F(GH), PASS_COORDGAUGE_PUBLIC_C2F(GH)

#define DECLARE_COORDGAUGE_C2F _DECLARE_CCTK_C2F DECLARE_COORDGAUGE_PUBLIC_C2F

#define INITIALISE_COORDGAUGE_C2F _INITIALISE_CCTK_C2F INITIALISE_COORDGAUGE_PUBLIC_C2F

#define COORDGAUGE_CARGUMENTS cGH *cctkGH

#endif /* CCODE */
