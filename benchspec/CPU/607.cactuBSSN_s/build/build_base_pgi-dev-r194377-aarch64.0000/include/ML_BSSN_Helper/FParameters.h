#define DECLARE_CCTK_PARAMETERS \
CCTK_DECLARE(CCTK_INT,ML_BSSN_MaxNumConstrainedVars,)&&\
COMMON /ML_BSSN_Helperpriv/ML_BSSN_MaxNumConstrainedVars&&\
CCTK_DECLARE(CCTK_STRING,CCTKH0,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH1,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH2,)&&\
CCTK_DECLARE(CCTK_STRING,evolution_method,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH3,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH4,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH5,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH6,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH7,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH8,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH9,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH11,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH13,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH14,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH15,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH10,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH12,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH16,)&&\
COMMON /ADMBASErest/CCTKH0, CCTKH1, CCTKH2, evolution_method, CCTKH3, CCTKH4, CCTKH5, CCTKH6, CCTKH7, CCTKH8, CCTKH9, CCTKH11, CCTKH13, CCTKH14, CCTKH15, CCTKH10, CCTKH12, CCTKH16&&\
CCTK_DECLARE(CCTK_INT,radpower,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH17,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH18,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH19,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH20,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH21,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH22,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH23,)&&\
COMMON /BOUNDARYrest/radpower, CCTKH17, CCTKH18, CCTKH19, CCTKH20, CCTKH21, CCTKH22, CCTKH23&&\
CCTK_DECLARE(CCTK_STRING,CCTKH27,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH28,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH29,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH31,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH24,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH25,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH26,)&&\
CCTK_DECLARE(CCTK_INT,boundary_width,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH30,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH32,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH33,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH34,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH35,)&&\
COMMON /GENERICFDrest/CCTKH27, CCTKH28, CCTKH29, CCTKH31, CCTKH24, CCTKH25, CCTKH26, boundary_width, CCTKH30, CCTKH32, CCTKH33, CCTKH34, CCTKH35&&\
CCTK_DECLARE(CCTK_INT,CCTKH36,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH37,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH38,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH39,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH40,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH41,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH42,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH43,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH44,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH45,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH46,)&&\
CCTK_DECLARE(CCTK_INT,MoL_Num_Constrained_Vars,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH47,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH48,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH49,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH50,)&&\
COMMON /METHODOFLINESrest/CCTKH36, CCTKH37, CCTKH38, CCTKH39, CCTKH40, CCTKH41, CCTKH42, CCTKH43, CCTKH44, CCTKH45, CCTKH46, MoL_Num_Constrained_Vars, CCTKH47, CCTKH48, CCTKH49, CCTKH50&&\
CCTK_DECLARE(CCTK_REAL,CCTKH51,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH52,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH53,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH54,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH55,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH90,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH91,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH93,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH94,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH95,)&&\
CCTK_DECLARE(CCTK_REAL,CCTKH96,)&&\
CCTK_DECLARE(CCTK_REAL,harmonicF,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH97,)&&\
CCTK_DECLARE(CCTK_STRING,calculate_ADMBase_variables_at,)&&\
CCTK_DECLARE(CCTK_STRING,my_initial_boundary_condition,)&&\
CCTK_DECLARE(CCTK_STRING,my_rhs_boundary_condition,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH56,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH57,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH58,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH59,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH60,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH61,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH62,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH63,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH64,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH65,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH66,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH67,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH68,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH69,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH70,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH71,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH72,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH73,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH74,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH75,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH76,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH77,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH78,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH79,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH80,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH81,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH82,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH83,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH84,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH85,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH86,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH87,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH88,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH89,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH92,)&&\
CCTK_DECLARE(CCTK_INT,conformalMethod,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH98,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH99,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH100,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH101,)&&\
CCTK_DECLARE(CCTK_INT,rhs_timelevels,)&&\
CCTK_DECLARE(CCTK_INT,timelevels,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH102,)&&\
COMMON /ML_BSSNrest/CCTKH51, CCTKH52, CCTKH53, CCTKH54, CCTKH55, CCTKH90, CCTKH91, CCTKH93, CCTKH94, CCTKH95, CCTKH96, harmonicF, CCTKH97, calculate_ADMBase_variables_at, my_initial_boundary_condition, my_rhs_boundary_condition, CCTKH56, CCTKH57, CCTKH58, CCTKH59, CCTKH60, CCTKH61, CCTKH62, CCTKH63, CCTKH64, CCTKH65, CCTKH66, CCTKH67, CCTKH68, CCTKH69, CCTKH70, CCTKH71, CCTKH72, CCTKH73, CCTKH74, CCTKH75, CCTKH76, CCTKH77, CCTKH78, CCTKH79, CCTKH80, CCTKH81, CCTKH82, CCTKH83, CCTKH84, CCTKH85, CCTKH86, CCTKH87, CCTKH88, CCTKH89, CCTKH92, conformalMethod, CCTKH98, CCTKH99, CCTKH100, CCTKH101, rhs_timelevels, timelevels, CCTKH102&&\

