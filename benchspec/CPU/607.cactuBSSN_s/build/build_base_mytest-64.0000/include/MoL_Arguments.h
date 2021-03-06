/*@@
   @header  MoL_Arguments.h
   @author  Automatically generated by GridFuncStuff.pl
   @desc
            Defines macros to declare/define/pass function arguments
            in calls from C to Fortran for thorn MoL
   @enddesc
 @@*/


#ifdef FCODE
#define DECLARE_MOL_PRIVATE_FARGUMENTS \
INTEGER ErrorEstimate_length&&\
INTEGER SandRScratchSpace_length&&\
INTEGER ScratchSpaceSlow_length&&\
INTEGER ScratchSpace_length&&\
INTEGER X0RKAlphaCoefficients&&\
INTEGER X0RKBetaCoefficients&&\
INTEGER X1RKAlphaCoefficients&&\
CCTK_DECLARE(CCTK_REAL,Count,)&&\
CCTK_DECLARE(CCTK_REAL,Error,)&&\
CCTK_DECLARE(CCTK_REAL,ErrorEstimate,(cctk_ash1,cctk_ash2,cctk_ash3,ErrorEstimate_length))&&\
CCTK_DECLARE(CCTK_REAL,EstimatedDt,)&&\
CCTK_DECLARE(CCTK_INT,MoL_Intermediate_Step,)&&\
CCTK_DECLARE(CCTK_INT,MoL_SlowPostStep,)&&\
CCTK_DECLARE(CCTK_INT,MoL_SlowStep,)&&\
CCTK_DECLARE(CCTK_INT,MoL_Stepsize_Bad,)&&\
CCTK_DECLARE(CCTK_REAL,Original_Delta_Time,)&&\
CCTK_DECLARE(CCTK_REAL,Original_Time,)&&\
CCTK_DECLARE(CCTK_REAL,RKAlphaCoefficients,(X0RKAlphaCoefficients,X1RKAlphaCoefficients))&&\
CCTK_DECLARE(CCTK_REAL,RKBetaCoefficients,(X0RKBetaCoefficients))&&\
CCTK_DECLARE(CCTK_REAL,SandRScratchSpace,(cctk_ash1,cctk_ash2,cctk_ash3,SandRScratchSpace_length))&&\
CCTK_DECLARE(CCTK_REAL,ScratchSpace,(cctk_ash1,cctk_ash2,cctk_ash3,ScratchSpace_length))&&\
CCTK_DECLARE(CCTK_REAL,ScratchSpaceSlow,(cctk_ash1,cctk_ash2,cctk_ash3,ScratchSpaceSlow_length))&&\


#define MOL_PRIVATE_FARGUMENTS \
ErrorEstimate_length,SandRScratchSpace_length,ScratchSpaceSlow_length,ScratchSpace_length,X0RKAlphaCoefficients,X0RKBetaCoefficients,X1RKAlphaCoefficients,Count,Error,ErrorEstimate,EstimatedDt,MoL_Intermediate_Step,MoL_SlowPostStep,MoL_SlowStep,MoL_Stepsize_Bad,Original_Delta_Time,Original_Time,RKAlphaCoefficients,RKBetaCoefficients,SandRScratchSpace,ScratchSpace,ScratchSpaceSlow

#endif /* FCODE */

#ifdef CCODE
#define DECLARE_MOL_PRIVATE_CARGUMENTS \
static int cctki_vi_Count = -100; \
if (cctki_vi_Count == -100) cctki_vi_Count = CCTK_VarIndex("MoL::Count"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, Count, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_Count)); \
static int cctki_vi_Error = -100; \
if (cctki_vi_Error == -100) cctki_vi_Error = CCTK_VarIndex("MoL::Error"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, Error, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_Error)); \
static int cctki_vi_ErrorEstimate = -100; \
if (cctki_vi_ErrorEstimate == -100) cctki_vi_ErrorEstimate = CCTK_VarIndex("MoL::ErrorEstimate[0]"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, ErrorEstimate, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_ErrorEstimate)); \
static int cctki_vi_EstimatedDt = -100; \
if (cctki_vi_EstimatedDt == -100) cctki_vi_EstimatedDt = CCTK_VarIndex("MoL::EstimatedDt"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, EstimatedDt, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_EstimatedDt)); \
static int cctki_vi_MoL_Intermediate_Step = -100; \
if (cctki_vi_MoL_Intermediate_Step == -100) cctki_vi_MoL_Intermediate_Step = CCTK_VarIndex("MoL::MoL_Intermediate_Step"); \
CCTK_DECLARE_INIT (CCTK_INT * restrict const, MoL_Intermediate_Step, (CCTK_INT *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_MoL_Intermediate_Step)); \
static int cctki_vi_MoL_SlowPostStep = -100; \
if (cctki_vi_MoL_SlowPostStep == -100) cctki_vi_MoL_SlowPostStep = CCTK_VarIndex("MoL::MoL_SlowPostStep"); \
CCTK_DECLARE_INIT (CCTK_INT * restrict const, MoL_SlowPostStep, (CCTK_INT *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_MoL_SlowPostStep)); \
static int cctki_vi_MoL_SlowStep = -100; \
if (cctki_vi_MoL_SlowStep == -100) cctki_vi_MoL_SlowStep = CCTK_VarIndex("MoL::MoL_SlowStep"); \
CCTK_DECLARE_INIT (CCTK_INT * restrict const, MoL_SlowStep, (CCTK_INT *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_MoL_SlowStep)); \
static int cctki_vi_MoL_Stepsize_Bad = -100; \
if (cctki_vi_MoL_Stepsize_Bad == -100) cctki_vi_MoL_Stepsize_Bad = CCTK_VarIndex("MoL::MoL_Stepsize_Bad"); \
CCTK_DECLARE_INIT (CCTK_INT * restrict const, MoL_Stepsize_Bad, (CCTK_INT *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_MoL_Stepsize_Bad)); \
static int cctki_vi_Original_Delta_Time = -100; \
if (cctki_vi_Original_Delta_Time == -100) cctki_vi_Original_Delta_Time = CCTK_VarIndex("MoL::Original_Delta_Time"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, Original_Delta_Time, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_Original_Delta_Time)); \
static int cctki_vi_Original_Time = -100; \
if (cctki_vi_Original_Time == -100) cctki_vi_Original_Time = CCTK_VarIndex("MoL::Original_Time"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, Original_Time, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_Original_Time)); \
static int cctki_vi_RKAlphaCoefficients = -100; \
if (cctki_vi_RKAlphaCoefficients == -100) cctki_vi_RKAlphaCoefficients = CCTK_VarIndex("MoL::RKAlphaCoefficients"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, RKAlphaCoefficients, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_RKAlphaCoefficients)); \
static int cctki_vi_RKBetaCoefficients = -100; \
if (cctki_vi_RKBetaCoefficients == -100) cctki_vi_RKBetaCoefficients = CCTK_VarIndex("MoL::RKBetaCoefficients"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, RKBetaCoefficients, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_RKBetaCoefficients)); \
static int cctki_vi_SandRScratchSpace = -100; \
if (cctki_vi_SandRScratchSpace == -100) cctki_vi_SandRScratchSpace = CCTK_VarIndex("MoL::SandRScratchSpace[0]"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, SandRScratchSpace, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_SandRScratchSpace)); \
static int cctki_vi_ScratchSpace = -100; \
if (cctki_vi_ScratchSpace == -100) cctki_vi_ScratchSpace = CCTK_VarIndex("MoL::ScratchSpace[0]"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, ScratchSpace, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_ScratchSpace)); \
static int cctki_vi_ScratchSpaceSlow = -100; \
if (cctki_vi_ScratchSpaceSlow == -100) cctki_vi_ScratchSpaceSlow = CCTK_VarIndex("MoL::ScratchSpaceSlow[0]"); \
CCTK_DECLARE_INIT (CCTK_REAL * restrict const, ScratchSpaceSlow, (CCTK_REAL *) CCTKi_VarDataPtrI(cctkGH, 0, cctki_vi_ScratchSpaceSlow));

#define DECLARE_MOL_PRIVATE_C2F \
static int CCTKARGNUM_Count = -1; \
static int CCTKGROUPNUM_ErrorScalars = -1; \
static int CCTKARGNUM_Error = -1; \
static int CCTKARGNUM_ErrorEstimate = -1; \
static int CCTKGROUPNUM_ErrorEstimate = -1; \
static int CCTKARGNUM_EstimatedDt = -1; \
static int CCTKARGNUM_MoL_Intermediate_Step = -1; \
static int CCTKGROUPNUM_MoL_Counters = -1; \
static int CCTKARGNUM_MoL_SlowPostStep = -1; \
static int CCTKARGNUM_MoL_SlowStep = -1; \
static int CCTKARGNUM_MoL_Stepsize_Bad = -1; \
static int CCTKARGNUM_Original_Delta_Time = -1; \
static int CCTKGROUPNUM_MoL_Original_Time = -1; \
static int CCTKARGNUM_Original_Time = -1; \
static int CCTKARGNUM_RKAlphaCoefficients = -1; \
static int CCTKGROUPNUM_RKAlphaCoefficients = -1; \
static int CCTKARGNUM_RKBetaCoefficients = -1; \
static int CCTKGROUPNUM_RKBetaCoefficients = -1; \
static int CCTKARGNUM_SandRScratchSpace = -1; \
static int CCTKGROUPNUM_SandRScratchSpace = -1; \
static int CCTKARGNUM_ScratchSpace = -1; \
static int CCTKGROUPNUM_ScratchSpace = -1; \
static int CCTKARGNUM_ScratchSpaceSlow = -1; \
static int CCTKGROUPNUM_ScratchSpaceSlow = -1;

#define INITIALISE_MOL_PRIVATE_C2F \
if(CCTKARGNUM_Count == -1) CCTKARGNUM_Count = CCTK_VarIndex("MoL::Count"); \
if(CCTKGROUPNUM_ErrorScalars == -1) CCTKGROUPNUM_ErrorScalars = CCTK_GroupIndex("MoL::ErrorScalars"); \
if(CCTKARGNUM_Error == -1) CCTKARGNUM_Error = CCTK_VarIndex("MoL::Error"); \
if(CCTKARGNUM_ErrorEstimate == -1) CCTKARGNUM_ErrorEstimate = CCTK_VarIndex("MoL::ErrorEstimate[0]"); \
if(CCTKGROUPNUM_ErrorEstimate == -1) CCTKGROUPNUM_ErrorEstimate = CCTK_GroupIndex("MoL::ErrorEstimate"); \
if(CCTKARGNUM_EstimatedDt == -1) CCTKARGNUM_EstimatedDt = CCTK_VarIndex("MoL::EstimatedDt"); \
if(CCTKARGNUM_MoL_Intermediate_Step == -1) CCTKARGNUM_MoL_Intermediate_Step = CCTK_VarIndex("MoL::MoL_Intermediate_Step"); \
if(CCTKGROUPNUM_MoL_Counters == -1) CCTKGROUPNUM_MoL_Counters = CCTK_GroupIndex("MoL::MoL_Counters"); \
if(CCTKARGNUM_MoL_SlowPostStep == -1) CCTKARGNUM_MoL_SlowPostStep = CCTK_VarIndex("MoL::MoL_SlowPostStep"); \
if(CCTKARGNUM_MoL_SlowStep == -1) CCTKARGNUM_MoL_SlowStep = CCTK_VarIndex("MoL::MoL_SlowStep"); \
if(CCTKARGNUM_MoL_Stepsize_Bad == -1) CCTKARGNUM_MoL_Stepsize_Bad = CCTK_VarIndex("MoL::MoL_Stepsize_Bad"); \
if(CCTKARGNUM_Original_Delta_Time == -1) CCTKARGNUM_Original_Delta_Time = CCTK_VarIndex("MoL::Original_Delta_Time"); \
if(CCTKGROUPNUM_MoL_Original_Time == -1) CCTKGROUPNUM_MoL_Original_Time = CCTK_GroupIndex("MoL::MoL_Original_Time"); \
if(CCTKARGNUM_Original_Time == -1) CCTKARGNUM_Original_Time = CCTK_VarIndex("MoL::Original_Time"); \
if(CCTKARGNUM_RKAlphaCoefficients == -1) CCTKARGNUM_RKAlphaCoefficients = CCTK_VarIndex("MoL::RKAlphaCoefficients"); \
if(CCTKGROUPNUM_RKAlphaCoefficients == -1) CCTKGROUPNUM_RKAlphaCoefficients = CCTK_GroupIndex("MoL::RKAlphaCoefficients"); \
if(CCTKARGNUM_RKBetaCoefficients == -1) CCTKARGNUM_RKBetaCoefficients = CCTK_VarIndex("MoL::RKBetaCoefficients"); \
if(CCTKGROUPNUM_RKBetaCoefficients == -1) CCTKGROUPNUM_RKBetaCoefficients = CCTK_GroupIndex("MoL::RKBetaCoefficients"); \
if(CCTKARGNUM_SandRScratchSpace == -1) CCTKARGNUM_SandRScratchSpace = CCTK_VarIndex("MoL::SandRScratchSpace[0]"); \
if(CCTKGROUPNUM_SandRScratchSpace == -1) CCTKGROUPNUM_SandRScratchSpace = CCTK_GroupIndex("MoL::SandRScratchSpace"); \
if(CCTKARGNUM_ScratchSpace == -1) CCTKARGNUM_ScratchSpace = CCTK_VarIndex("MoL::ScratchSpace[0]"); \
if(CCTKGROUPNUM_ScratchSpace == -1) CCTKGROUPNUM_ScratchSpace = CCTK_GroupIndex("MoL::ScratchSpace"); \
if(CCTKARGNUM_ScratchSpaceSlow == -1) CCTKARGNUM_ScratchSpaceSlow = CCTK_VarIndex("MoL::ScratchSpaceSlow[0]"); \
if(CCTKGROUPNUM_ScratchSpaceSlow == -1) CCTKGROUPNUM_ScratchSpaceSlow = CCTK_GroupIndex("MoL::ScratchSpaceSlow");

#define MOL_PRIVATE_C2F_PROTO \
const int *,const int *,const int *,const int *,const int *,const int *,const int *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_INT *,CCTK_INT *,CCTK_INT *,CCTK_INT *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *,CCTK_REAL *

#define PASS_MOL_PRIVATE_C2F(GH) \
PASS_GROUPLEN(MoL, ErrorEstimate),\
PASS_GROUPLEN(MoL, SandRScratchSpace),\
PASS_GROUPLEN(MoL, ScratchSpaceSlow),\
PASS_GROUPLEN(MoL, ScratchSpace),\
PASS_GROUPSIZE(RKAlphaCoefficients, 0),\
PASS_GROUPSIZE(RKBetaCoefficients, 0),\
PASS_GROUPSIZE(RKAlphaCoefficients, 1),\
(CCTK_REAL *)(PASS_REFERENCE(Count, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(Error, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(ErrorEstimate, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(EstimatedDt, 0)),\
(CCTK_INT *)(PASS_REFERENCE(MoL_Intermediate_Step, 0)),\
(CCTK_INT *)(PASS_REFERENCE(MoL_SlowPostStep, 0)),\
(CCTK_INT *)(PASS_REFERENCE(MoL_SlowStep, 0)),\
(CCTK_INT *)(PASS_REFERENCE(MoL_Stepsize_Bad, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(Original_Delta_Time, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(Original_Time, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(RKAlphaCoefficients, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(RKBetaCoefficients, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(SandRScratchSpace, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(ScratchSpace, 0)),\
(CCTK_REAL *)(PASS_REFERENCE(ScratchSpaceSlow, 0))

#endif /* CCODE */

#ifdef FCODE
#define DECLARE_MOL_PROTECTED_FARGUMENTS \


#define MOL_PROTECTED_FARGUMENTS \


#endif /* FCODE */

#ifdef CCODE
#define DECLARE_MOL_PROTECTED_CARGUMENTS \


#define DECLARE_MOL_PROTECTED_C2F \


#define INITIALISE_MOL_PROTECTED_C2F \


#define MOL_PROTECTED_C2F_PROTO \


#define PASS_MOL_PROTECTED_C2F(GH) \


#endif /* CCODE */

#ifdef FCODE
#define DECLARE_MOL_PUBLIC_FARGUMENTS \


#define MOL_PUBLIC_FARGUMENTS \


#endif /* FCODE */

#ifdef CCODE
#define DECLARE_MOL_PUBLIC_CARGUMENTS \


#define DECLARE_MOL_PUBLIC_C2F \


#define INITIALISE_MOL_PUBLIC_C2F \


#define MOL_PUBLIC_C2F_PROTO \


#define PASS_MOL_PUBLIC_C2F(GH) \


#endif /* CCODE */

#ifdef FCODE
#define MOL_FARGUMENTS _CCTK_FARGUMENTS, MOL_PRIVATE_FARGUMENTS

#define DECLARE_MOL_FARGUMENTS _DECLARE_CCTK_FARGUMENTS DECLARE_MOL_PRIVATE_FARGUMENTS

#endif /* FCODE */

#ifdef CCODE
#define DECLARE_MOL_CARGUMENTS _DECLARE_CCTK_CARGUMENTS DECLARE_MOL_PRIVATE_CARGUMENTS

#define MOL_C2F_PROTO _CCTK_C2F_PROTO, MOL_PRIVATE_C2F_PROTO

#define PASS_MOL_C2F(GH) _PASS_CCTK_C2F(GH), PASS_MOL_PRIVATE_C2F(GH)

#define DECLARE_MOL_C2F _DECLARE_CCTK_C2F DECLARE_MOL_PRIVATE_C2F

#define INITIALISE_MOL_C2F _INITIALISE_CCTK_C2F INITIALISE_MOL_PRIVATE_C2F

#define MOL_CARGUMENTS cGH *cctkGH

#endif /* CCODE */
