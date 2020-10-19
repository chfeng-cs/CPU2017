#define DECLARE_CCTK_PARAMETERS \
CCTK_DECLARE(CCTK_REAL,AlphaDriver,)&&\
CCTK_DECLARE(CCTK_REAL,BetaDriver,)&&\
CCTK_DECLARE(CCTK_REAL,EpsDiss,)&&\
CCTK_DECLARE(CCTK_REAL,LapseACoeff,)&&\
CCTK_DECLARE(CCTK_REAL,LapseAdvectionCoeff,)&&\
CCTK_DECLARE(CCTK_REAL,MinimumLapse,)&&\
CCTK_DECLARE(CCTK_REAL,ShiftAdvectionCoeff,)&&\
CCTK_DECLARE(CCTK_REAL,ShiftBCoeff,)&&\
CCTK_DECLARE(CCTK_REAL,ShiftGammaCoeff,)&&\
CCTK_DECLARE(CCTK_REAL,SpatialBetaDriverRadius,)&&\
CCTK_DECLARE(CCTK_REAL,SpatialShiftGammaCoeffRadius,)&&\
CCTK_DECLARE(CCTK_REAL,harmonicF,)&&\
CCTK_DECLARE(CCTK_STRING,UseSpatialBetaDriver,)&&\
CCTK_DECLARE(CCTK_STRING,calculate_ADMBase_variables_at,)&&\
CCTK_DECLARE(CCTK_STRING,my_initial_boundary_condition,)&&\
CCTK_DECLARE(CCTK_STRING,my_rhs_boundary_condition,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_Advect_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_Advect_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_Dissipation_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_Dissipation_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_InitGamma_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_InitGamma_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_InitRHS_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_InitRHS_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_MaxNumArrayEvolvedVars,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_MaxNumEvolvedVars,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_Minkowski_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_Minkowski_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_RHSStaticBoundary_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_RHSStaticBoundary_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_RHS_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_RHS_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_boundary_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_boundary_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_constraints_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_constraints_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertFromADMBaseGamma_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertFromADMBaseGamma_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertFromADMBase_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertFromADMBase_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertToADMBaseDtLapseShiftBoundary_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertToADMBaseDtLapseShiftBoundary_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertToADMBaseDtLapseShift_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertToADMBaseDtLapseShift_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertToADMBaseFakeDtLapseShift_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertToADMBaseFakeDtLapseShift_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertToADMBase_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_convertToADMBase_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_enforce_calc_every,)&&\
CCTK_DECLARE(CCTK_INT,ML_BSSN_enforce_calc_offset,)&&\
CCTK_DECLARE(CCTK_INT,ShiftAlphaPower,)&&\
CCTK_DECLARE(CCTK_INT,conformalMethod,)&&\
CCTK_DECLARE(CCTK_INT,fdOrder,)&&\
CCTK_DECLARE(CCTK_INT,harmonicN,)&&\
CCTK_DECLARE(CCTK_INT,harmonicShift,)&&\
CCTK_DECLARE(CCTK_INT,other_timelevels,)&&\
CCTK_DECLARE(CCTK_INT,rhs_timelevels,)&&\
CCTK_DECLARE(CCTK_INT,timelevels,)&&\
CCTK_DECLARE(CCTK_INT,verbose,)&&\
COMMON /ML_BSSNrest/AlphaDriver, BetaDriver, EpsDiss, LapseACoeff, LapseAdvectionCoeff, MinimumLapse, ShiftAdvectionCoeff, ShiftBCoeff, ShiftGammaCoeff, SpatialBetaDriverRadius, SpatialShiftGammaCoeffRadius, harmonicF, UseSpatialBetaDriver, calculate_ADMBase_variables_at, my_initial_boundary_condition, my_rhs_boundary_condition, ML_BSSN_Advect_calc_every, ML_BSSN_Advect_calc_offset, ML_BSSN_Dissipation_calc_every, ML_BSSN_Dissipation_calc_offset, ML_BSSN_InitGamma_calc_every, ML_BSSN_InitGamma_calc_offset, ML_BSSN_InitRHS_calc_every, ML_BSSN_InitRHS_calc_offset, ML_BSSN_MaxNumArrayEvolvedVars, ML_BSSN_MaxNumEvolvedVars, ML_BSSN_Minkowski_calc_every, ML_BSSN_Minkowski_calc_offset, ML_BSSN_RHSStaticBoundary_calc_every, ML_BSSN_RHSStaticBoundary_calc_offset, ML_BSSN_RHS_calc_every, ML_BSSN_RHS_calc_offset, ML_BSSN_boundary_calc_every, ML_BSSN_boundary_calc_offset, ML_BSSN_constraints_calc_every, ML_BSSN_constraints_calc_offset, ML_BSSN_convertFromADMBaseGamma_calc_every, ML_BSSN_convertFromADMBaseGamma_calc_offset, ML_BSSN_convertFromADMBase_calc_every, ML_BSSN_convertFromADMBase_calc_offset, ML_BSSN_convertToADMBaseDtLapseShiftBoundary_calc_every, ML_BSSN_convertToADMBaseDtLapseShiftBoundary_calc_offset, ML_BSSN_convertToADMBaseDtLapseShift_calc_every, ML_BSSN_convertToADMBaseDtLapseShift_calc_offset, ML_BSSN_convertToADMBaseFakeDtLapseShift_calc_every, ML_BSSN_convertToADMBaseFakeDtLapseShift_calc_offset, ML_BSSN_convertToADMBase_calc_every, ML_BSSN_convertToADMBase_calc_offset, ML_BSSN_enforce_calc_every, ML_BSSN_enforce_calc_offset, ShiftAlphaPower, conformalMethod, fdOrder, harmonicN, harmonicShift, other_timelevels, rhs_timelevels, timelevels, verbose&&\
CCTK_DECLARE(CCTK_REAL,A_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,A_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,A_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,At11_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,At11_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,At11_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,At12_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,At12_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,At12_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,At13_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,At13_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,At13_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,At22_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,At22_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,At22_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,At23_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,At23_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,At23_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,At33_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,At33_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,At33_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,B1_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,B1_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,B1_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,B2_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,B2_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,B2_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,B3_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,B3_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,B3_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,ML_Gamma_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,ML_Gamma_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,ML_Gamma_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,ML_curv_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,ML_curv_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,ML_curv_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,ML_dtlapse_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,ML_dtlapse_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,ML_dtlapse_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,ML_dtshift_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,ML_dtshift_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,ML_dtshift_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,ML_lapse_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,ML_lapse_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,ML_lapse_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,ML_log_confac_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,ML_log_confac_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,ML_log_confac_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,ML_metric_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,ML_metric_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,ML_metric_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,ML_shift_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,ML_shift_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,ML_shift_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,ML_trace_curv_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,ML_trace_curv_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,ML_trace_curv_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,Xt1_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,Xt1_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,Xt1_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,Xt2_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,Xt2_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,Xt2_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,Xt3_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,Xt3_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,Xt3_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,alpha_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,alpha_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,alpha_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,beta1_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,beta1_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,beta1_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,beta2_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,beta2_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,beta2_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,beta3_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,beta3_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,beta3_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,gt11_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,gt11_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,gt11_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,gt12_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,gt12_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,gt12_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,gt13_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,gt13_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,gt13_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,gt22_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,gt22_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,gt22_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,gt23_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,gt23_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,gt23_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,gt33_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,gt33_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,gt33_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,phi_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,phi_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,phi_bound_speed,)&&\
CCTK_DECLARE(CCTK_REAL,trK_bound_limit,)&&\
CCTK_DECLARE(CCTK_REAL,trK_bound_scalar,)&&\
CCTK_DECLARE(CCTK_REAL,trK_bound_speed,)&&\
CCTK_DECLARE(CCTK_STRING,A_bound,)&&\
CCTK_DECLARE(CCTK_STRING,At11_bound,)&&\
CCTK_DECLARE(CCTK_STRING,At12_bound,)&&\
CCTK_DECLARE(CCTK_STRING,At13_bound,)&&\
CCTK_DECLARE(CCTK_STRING,At22_bound,)&&\
CCTK_DECLARE(CCTK_STRING,At23_bound,)&&\
CCTK_DECLARE(CCTK_STRING,At33_bound,)&&\
CCTK_DECLARE(CCTK_STRING,B1_bound,)&&\
CCTK_DECLARE(CCTK_STRING,B2_bound,)&&\
CCTK_DECLARE(CCTK_STRING,B3_bound,)&&\
CCTK_DECLARE(CCTK_STRING,ML_Gamma_bound,)&&\
CCTK_DECLARE(CCTK_STRING,ML_curv_bound,)&&\
CCTK_DECLARE(CCTK_STRING,ML_dtlapse_bound,)&&\
CCTK_DECLARE(CCTK_STRING,ML_dtshift_bound,)&&\
CCTK_DECLARE(CCTK_STRING,ML_lapse_bound,)&&\
CCTK_DECLARE(CCTK_STRING,ML_log_confac_bound,)&&\
CCTK_DECLARE(CCTK_STRING,ML_metric_bound,)&&\
CCTK_DECLARE(CCTK_STRING,ML_shift_bound,)&&\
CCTK_DECLARE(CCTK_STRING,ML_trace_curv_bound,)&&\
CCTK_DECLARE(CCTK_STRING,Xt1_bound,)&&\
CCTK_DECLARE(CCTK_STRING,Xt2_bound,)&&\
CCTK_DECLARE(CCTK_STRING,Xt3_bound,)&&\
CCTK_DECLARE(CCTK_STRING,alpha_bound,)&&\
CCTK_DECLARE(CCTK_STRING,apply_dissipation,)&&\
CCTK_DECLARE(CCTK_STRING,beta1_bound,)&&\
CCTK_DECLARE(CCTK_STRING,beta2_bound,)&&\
CCTK_DECLARE(CCTK_STRING,beta3_bound,)&&\
CCTK_DECLARE(CCTK_STRING,dt_lapse_shift_method,)&&\
CCTK_DECLARE(CCTK_STRING,gt11_bound,)&&\
CCTK_DECLARE(CCTK_STRING,gt12_bound,)&&\
CCTK_DECLARE(CCTK_STRING,gt13_bound,)&&\
CCTK_DECLARE(CCTK_STRING,gt22_bound,)&&\
CCTK_DECLARE(CCTK_STRING,gt23_bound,)&&\
CCTK_DECLARE(CCTK_STRING,gt33_bound,)&&\
CCTK_DECLARE(CCTK_STRING,my_boundary_condition,)&&\
CCTK_DECLARE(CCTK_STRING,my_initial_data,)&&\
CCTK_DECLARE(CCTK_STRING,phi_bound,)&&\
CCTK_DECLARE(CCTK_STRING,trK_bound,)&&\
COMMON /ML_BSSNpriv/A_bound_limit, A_bound_scalar, A_bound_speed, At11_bound_limit, At11_bound_scalar, At11_bound_speed, At12_bound_limit, At12_bound_scalar, At12_bound_speed, At13_bound_limit, At13_bound_scalar, At13_bound_speed, At22_bound_limit, At22_bound_scalar, At22_bound_speed, At23_bound_limit, At23_bound_scalar, At23_bound_speed, At33_bound_limit, At33_bound_scalar, At33_bound_speed, B1_bound_limit, B1_bound_scalar, B1_bound_speed, B2_bound_limit, B2_bound_scalar, B2_bound_speed, B3_bound_limit, B3_bound_scalar, B3_bound_speed, ML_Gamma_bound_limit, ML_Gamma_bound_scalar, ML_Gamma_bound_speed, ML_curv_bound_limit, ML_curv_bound_scalar, ML_curv_bound_speed, ML_dtlapse_bound_limit, ML_dtlapse_bound_scalar, ML_dtlapse_bound_speed, ML_dtshift_bound_limit, ML_dtshift_bound_scalar, ML_dtshift_bound_speed, ML_lapse_bound_limit, ML_lapse_bound_scalar, ML_lapse_bound_speed, ML_log_confac_bound_limit, ML_log_confac_bound_scalar, ML_log_confac_bound_speed, ML_metric_bound_limit, ML_metric_bound_scalar, ML_metric_bound_speed, ML_shift_bound_limit, ML_shift_bound_scalar, ML_shift_bound_speed, ML_trace_curv_bound_limit, ML_trace_curv_bound_scalar, ML_trace_curv_bound_speed, Xt1_bound_limit, Xt1_bound_scalar, Xt1_bound_speed, Xt2_bound_limit, Xt2_bound_scalar, Xt2_bound_speed, Xt3_bound_limit, Xt3_bound_scalar, Xt3_bound_speed, alpha_bound_limit, alpha_bound_scalar, alpha_bound_speed, beta1_bound_limit, beta1_bound_scalar, beta1_bound_speed, beta2_bound_limit, beta2_bound_scalar, beta2_bound_speed, beta3_bound_limit, beta3_bound_scalar, beta3_bound_speed, gt11_bound_limit, gt11_bound_scalar, gt11_bound_speed, gt12_bound_limit, gt12_bound_scalar, gt12_bound_speed, gt13_bound_limit, gt13_bound_scalar, gt13_bound_speed, gt22_bound_limit, gt22_bound_scalar, gt22_bound_speed, gt23_bound_limit, gt23_bound_scalar, gt23_bound_speed, gt33_bound_limit, gt33_bound_scalar, gt33_bound_speed, phi_bound_limit, phi_bound_scalar, phi_bound_speed, trK_bound_limit, trK_bound_scalar, trK_bound_speed, A_bound, At11_bound, At12_bound, At13_bound, At22_bound, At23_bound, At33_bound, B1_bound, B2_bound, B3_bound, ML_Gamma_bound, ML_curv_bound, ML_dtlapse_bound, ML_dtshift_bound, ML_lapse_bound, ML_log_confac_bound, ML_metric_bound, ML_shift_bound, ML_trace_curv_bound, Xt1_bound, Xt2_bound, Xt3_bound, alpha_bound, apply_dissipation, beta1_bound, beta2_bound, beta3_bound, dt_lapse_shift_method, gt11_bound, gt12_bound, gt13_bound, gt22_bound, gt23_bound, gt33_bound, my_boundary_condition, my_initial_data, phi_bound, trK_bound&&\
CCTK_DECLARE(CCTK_STRING,CCTKH0,)&&\
CCTK_DECLARE(CCTK_STRING,dtlapse_evolution_method,)&&\
CCTK_DECLARE(CCTK_STRING,dtshift_evolution_method,)&&\
CCTK_DECLARE(CCTK_STRING,evolution_method,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH1,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH2,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH3,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH4,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH5,)&&\
CCTK_DECLARE(CCTK_STRING,lapse_evolution_method,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH6,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH8,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH10,)&&\
CCTK_DECLARE(CCTK_STRING,shift_evolution_method,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH11,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH7,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH9,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH12,)&&\
COMMON /ADMBASErest/CCTKH0, dtlapse_evolution_method, dtshift_evolution_method, evolution_method, CCTKH1, CCTKH2, CCTKH3, CCTKH4, CCTKH5, lapse_evolution_method, CCTKH6, CCTKH8, CCTKH10, shift_evolution_method, CCTKH11, CCTKH7, CCTKH9, CCTKH12&&\
CCTK_DECLARE(CCTK_STRING,CCTKH16,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH17,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH18,)&&\
CCTK_DECLARE(CCTK_STRING,CCTKH20,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH13,)&&\
CCTK_DECLARE(CCTK_INT,assume_stress_energy_state,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH14,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH15,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH19,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH21,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH22,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH23,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH24,)&&\
COMMON /GENERICFDrest/CCTKH16, CCTKH17, CCTKH18, CCTKH20, CCTKH13, assume_stress_energy_state, CCTKH14, CCTKH15, CCTKH19, CCTKH21, CCTKH22, CCTKH23, CCTKH24&&\
CCTK_DECLARE(CCTK_INT,CCTKH25,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH26,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH27,)&&\
CCTK_DECLARE(CCTK_INT,MoL_Num_ArrayEvolved_Vars,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH28,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH29,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH30,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH31,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH32,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH33,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH34,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH35,)&&\
CCTK_DECLARE(CCTK_INT,MoL_Num_Evolved_Vars,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH36,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH37,)&&\
CCTK_DECLARE(CCTK_INT,CCTKH38,)&&\
COMMON /METHODOFLINESrest/CCTKH25, CCTKH26, CCTKH27, MoL_Num_ArrayEvolved_Vars, CCTKH28, CCTKH29, CCTKH30, CCTKH31, CCTKH32, CCTKH33, CCTKH34, CCTKH35, MoL_Num_Evolved_Vars, CCTKH36, CCTKH37, CCTKH38&&\

