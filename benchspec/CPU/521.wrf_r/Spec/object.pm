$benchnum  = '521';
$benchname = 'wrf_r';
$exename   = 'wrf_r';
$benchlang = 'F,C';
@base_exe = qw(wrf_r diffwrf_521);

$compwhite = 1;
$calctol = 0;   # Outputs are all PASS/FAIL

$binary = {
    'wrf' => 1,
    'diffwrf' => 1,
    'default' => undef,
};

%sources = (
    'wrf_r' => [ qw(
        ESMF_Alarm.F90
        ESMF_AlarmClock.F90
        ESMF_Base.F90
        ESMF_BaseTime.F90
        ESMF_Calendar.F90
        ESMF_Clock.F90
        ESMF_Fraction.F90
        ESMF_Mod.F90
        ESMF_Stubs.F90
        ESMF_Time.F90
        ESMF_TimeInterval.F90
        Meat.F90
        adapt_timestep_em.F90
        alloc_2d.c
        apply_bitmap.c
        bobrand.c
        c1f2kb.F90
        c1f2kf.F90
        c1f3kb.F90
        c1f3kf.F90
        c1f4kb.F90
        c1f4kf.F90
        c1f5kb.F90
        c1f5kf.F90
        c1fgkb.F90
        c1fgkf.F90
        c1fm1b.F90
        c1fm1f.F90
        c_code.c
        cfft1b.F90
        cfft1i.F90
        cfftmb.F90
        cfftmf.F90
        cfftmi.F90
        cmf2kb.F90
        cmf2kf.F90
        cmf3kb.F90
        cmf3kf.F90
        cmf4kb.F90
        cmf4kf.F90
        cmf5kb.F90
        cmf5kf.F90
        cmfgkb.F90
        cmfgkf.F90
        cmfm1b.F90
        cmfm1f.F90
        collect_on_comm.c
        cosq1b.F90
        cosq1f.F90
        cosq1i.F90
        cosqb1.F90
        cosqf1.F90
        cosqmb.F90
        cosqmf.F90
        cosqmi.F90
        couple_or_uncouple_em.F90
        d1f2kb.F90
        d1f2kf.F90
        d1f3kb.F90
        d1f3kf.F90
        d1f4kb.F90
        d1f4kf.F90
        d1f5kb.F90
        d1f5kf.F90
        d1fgkb.F90
        d1fgkf.F90
        data.c
        dfft1b.F90
        dfft1f.F90
        dfft1i.F90
        dfftb1.F90
        dfftf1.F90
        dffti1.F90
        dfi.F90
        field_routines.F90
        flt2ieee.c
        gbyte.c
        get_region_center.c
        grib1_routines.c
        grib_dec.c
        grib_enc.c
        grib_seek.c
        grib_uthin.c
        gribgetbds.c
        gribgetbms.c
        gribgetgds.c
        gribgetpds.c
        gribhdr2file.c
        gribmap.c
        gribputbds.c
        gribputgds.c
        gribputpds.c
        gridnav.c
        hires_timer.c
        init_dec_struct.c
        init_gribhdr.c
        init_modules.F90
        init_modules_em.F90
        input_wrf.F90
        interp_fcn.F90
        io_int.F90
        io_int_idx.c
        landread.c
        ld_dec_lookup.c
        ld_grib_origctrs.c
        libmassv.F90
        mcsqb1.F90
        mcsqf1.F90
        mediation_feedback_domain.F90
        mediation_force_domain.F90
        mediation_integrate.F90
        mediation_interp_domain.F90
        mediation_wrfmain.F90
        misc.c
        module_advect_em.F90
        module_after_all_rk_steps.F90
        module_alloc_space_0.F90
        module_alloc_space_1.F90
        module_alloc_space_2.F90
        module_alloc_space_3.F90
        module_alloc_space_4.F90
        module_alloc_space_5.F90
        module_alloc_space_6.F90
        module_alloc_space_7.F90
        module_alloc_space_8.F90
        module_alloc_space_9.F90
        module_avgflx_em.F90
        module_bc.F90
        module_bc_em.F90
        module_bc_time_utilities.F90
        module_big_step_utilities_em.F90
        module_bl_acm.F90
        module_bl_boulac.F90
        module_bl_camuwpbl_driver.F90
        module_bl_fogdes.F90
        module_bl_gbmpbl.F90
        module_bl_gfs.F90
        module_bl_gfs2011.F90
        module_bl_gwdo.F90
        module_bl_mfshconvpbl.F90
        module_bl_mrf.F90
        module_bl_myjpbl.F90
        module_bl_myjurb.F90
        module_bl_mynn.F90
        module_bl_qnsepbl.F90
        module_bl_qnsepbl09.F90
        module_bl_temf.F90
        module_bl_ysu.F90
        module_cam_bl_diffusion_solver.F90
        module_cam_bl_eddy_diff.F90
        module_cam_cldwat.F90
        module_cam_constituents.F90
        module_cam_error_function.F90
        module_cam_esinti.F90
        module_cam_gffgch.F90
        module_cam_molec_diff.F90
        module_cam_mp_cldwat2m_micro.F90
        module_cam_mp_conv_water.F90
        module_cam_mp_microp_aero.F90
        module_cam_mp_modal_aero_initialize_data_phys.F90
        module_cam_mp_ndrop.F90
        module_cam_mp_qneg3.F90
        module_cam_mp_radconstants.F90
        module_cam_physconst.F90
        module_cam_shr_const_mod.F90
        module_cam_shr_kind_mod.F90
        module_cam_support.F90
        module_cam_trb_mtn_stress.F90
        module_cam_upper_bc.F90
        module_cam_wv_saturation.F90
        module_check_a_mundo.F90
        module_comm_dm.F90
        module_comm_dm_0.F90
        module_comm_dm_1.F90
        module_comm_dm_2.F90
        module_comm_dm_3.F90
        module_comm_dm_4.F90
        module_comm_nesting_dm.F90
        module_configure.F90
        module_convtrans_prep.F90
        module_cpl.F90
        module_cpl_oasis3.F90
        module_cu_bmj.F90
        module_cu_camzm.F90
        module_cu_camzm_driver.F90
        module_cu_g3.F90
        module_cu_gd.F90
        module_cu_gf.F90
        module_cu_kf.F90
        module_cu_kfeta.F90
        module_cu_mesosas.F90
        module_cu_nsas.F90
        module_cu_osas.F90
        module_cu_sas.F90
        module_cu_tiedtke.F90
        module_cumulus_driver.F90
        module_damping_em.F90
        module_data_cam_mam_aero.F90
        module_data_cam_mam_asect.F90
        module_data_gocart_dust.F90
        module_date_time.F90
        module_diag_afwa.F90
        module_diag_afwa_hail.F90
        module_diag_cl.F90
        module_diag_misc.F90
        module_diag_pld.F90
        module_diagnostics_driver.F90
        module_diffusion_em.F90
        module_dm.F90
        module_domain.F90
        module_domain_type.F90
        module_driver_constants.F90
        module_em.F90
        module_fdda_psufddagd.F90
        module_fdda_spnudging.F90
        module_fddagd_driver.F90
        module_fddaobs_driver.F90
        module_fddaobs_rtfdda.F90
        module_first_rk_step_part1.F90
        module_first_rk_step_part2.F90
        module_force_scm.F90
        module_fr_fire_atm.F90
        module_fr_fire_core.F90
        module_fr_fire_driver.F90
        module_fr_fire_driver_wrf.F90
        module_fr_fire_model.F90
        module_fr_fire_phys.F90
        module_fr_fire_util.F90
        module_gfs_funcphys.F90
        module_gfs_machine.F90
        module_gfs_physcons.F90
        module_init_utilities.F90
        module_integrate.F90
        module_intermediate_nmm.F90
        module_internal_header_util.F90
        module_interp_store.F90
        module_io.F90
        module_io_domain.F90
        module_io_quilt.F90
        module_io_wrf.F90
        module_lightning_driver.F90
        module_llxy.F90
        module_ltng_cpmpr92z.F90
        module_ltng_crmpr92.F90
        module_ltng_iccg.F90
        module_ltng_lpi.F90
        module_machine.F90
        module_microphysics_driver.F90
        module_microphysics_zero_out.F90
        module_mixactivate.F90
        module_model_constants.F90
        module_mp_HWRF.F90
        module_mp_cammgmp_driver.F90
        module_mp_etanew.F90
        module_mp_etaold.F90
        module_mp_fast_sbm.F90
        module_mp_full_sbm.F90
        module_mp_gsfcgce.F90
        module_mp_kessler.F90
        module_mp_lin.F90
        module_mp_milbrandt2mom.F90
        module_mp_morr_two_moment.F90
        module_mp_nssl_2mom.F90
        module_mp_radar.F90
        module_mp_sbu_ylin.F90
        module_mp_thompson.F90
        module_mp_wdm5.F90
        module_mp_wdm6.F90
        module_mp_wsm3.F90
        module_mp_wsm5.F90
        module_mp_wsm6.F90
        module_nesting.F90
        module_optional_input.F90
        module_pbl_driver.F90
        module_physics_addtendc.F90
        module_physics_init.F90
        module_polarfft.F90
        module_progtm.F90
        module_quilt_outbuf_ops.F90
        module_ra_HWRF.F90
        module_ra_aerosol.F90
        module_ra_cam.F90
        module_ra_cam_support.F90
        module_ra_clWRF_support.F90
        module_ra_flg.F90
        module_ra_gfdleta.F90
        module_ra_goddard.F90
        module_ra_gsfcsw.F90
        module_ra_hs.F90
        module_ra_rrtm.F90
        module_ra_sw.F90
        module_radiation_driver.F90
        module_sf_3dpwp.F90
        module_sf_bem.F90
        module_sf_bep.F90
        module_sf_bep_bem.F90
        module_sf_clm.F90
        module_sf_fogdes.F90
        module_sf_gfdl.F90
        module_sf_gfs.F90
        module_sf_idealscmsfclay.F90
        module_sf_lake.F90
        module_sf_myjsfc.F90
        module_sf_mynn.F90
        module_sf_noah_seaice.F90
        module_sf_noah_seaice_drv.F90
        module_sf_noahdrv.F90
        module_sf_noahlsm.F90
        module_sf_noahlsm_glacial_only.F90
        module_sf_noahmp_glacier.F90
        module_sf_noahmp_groundwater.F90
        module_sf_noahmpdrv.F90
        module_sf_noahmplsm.F90
        module_sf_ocean_driver.F90
        module_sf_oml.F90
        module_sf_pxlsm.F90
        module_sf_pxlsm_data.F90
        module_sf_pxsfclay.F90
        module_sf_qnsesfc.F90
        module_sf_ruclsm.F90
        module_sf_scmflux.F90
        module_sf_scmskintemp.F90
        module_sf_sfcdiags.F90
        module_sf_sfcdiags_ruclsm.F90
        module_sf_sfclay.F90
        module_sf_sfclayrev.F90
        module_sf_slab.F90
        module_sf_ssib.F90
        module_sf_sstskin.F90
        module_sf_temfsfclay.F90
        module_sf_tmnupdate.F90
        module_sf_urban.F90
        module_shallowcu_driver.F90
        module_shcu_camuwshcu.F90
        module_shcu_camuwshcu_driver.F90
        module_shcu_grims.F90
        module_small_step_em.F90
        module_soil_pre.F90
        module_solvedebug_em.F90
        module_state_description.F90
        module_stoch.F90
        module_streams.F90
        module_surface_driver.F90
        module_symbols_util.F90
        module_tiles.F90
        module_timing.F90
        module_utility.F90
        module_wind_fitch.F90
        module_wrf_error.F90
        module_wrf_top.F90
        mradb2.F90
        mradb3.F90
        mradb4.F90
        mradb5.F90
        mradbg.F90
        mradf2.F90
        mradf3.F90
        mradf4.F90
        mradf5.F90
        mradfg.F90
        mrftb1.F90
        mrftf1.F90
        mrfti1.F90
        msntb1.F90
        msntf1.F90
        my_strtok.c
        nest_init_utils.F90
        netcdf/attr.c
        netcdf/dim.c
        netcdf/error.c
        netcdf/fort-attio.c
        netcdf/fort-control.c
        netcdf/fort-dim.c
        netcdf/fort-genatt.c
        netcdf/fort-geninq.c
        netcdf/fort-genvar.c
        netcdf/fort-lib.c
        netcdf/fort-misc.c
        netcdf/fort-varaio.c
        netcdf/libvers.c
        netcdf/nc.c
        netcdf/ncio.c
        netcdf/ncx.c
        netcdf/putget.c
        netcdf/string.c
        netcdf/v1hpg.c
        netcdf/v2i.c
        netcdf/var.c
        nl_get_0_routines.F90
        nl_get_1_routines.F90
        nl_get_2_routines.F90
        nl_get_3_routines.F90
        nl_get_4_routines.F90
        nl_get_5_routines.F90
        nl_get_6_routines.F90
        nl_get_7_routines.F90
        nl_set_0_routines.F90
        nl_set_1_routines.F90
        nl_set_2_routines.F90
        nl_set_6_routines.F90
        nl_set_7_routines.F90
        output_wrf.F90
        pack_spatial.c
        pack_utils.c
        period.c
        r1f2kb.F90
        r1f2kf.F90
        r1f3kb.F90
        r1f3kf.F90
        r1f4kb.F90
        r1f4kf.F90
        r1f5kb.F90
        r1f5kf.F90
        r1fgkb.F90
        r1fgkf.F90
        r4_factor.F90
        r4_mcfti1.F90
        r4_tables.F90
        r8_factor.F90
        r8_mcfti1.F90
        r8_tables.F90
        read_grib.c
        reg_parse.c
        rfft1b.F90
        rfft1f.F90
        rfft1i.F90
        rfftb1.F90
        rfftf1.F90
        rffti1.F90
        rfftmb.F90
        rfftmf.F90
        rfftmi.F90
        rsl_bcast.c
        set_bytes.c
        set_timekeeping.F90
        setfeenv.c
        sint.F90
        solve_em.F90
        solve_interface.F90
        start_domain.F90
        start_em.F90
        symtab_gen.c
        task_for_point.c
        track_driver.F90
        track_input.F90
        trim.c
        type.c
        upd_child_errmsg.c
        wrf.F90
        wrf_bdyin.F90
        wrf_bdyout.F90
        wrf_debug.F90
        wrf_ext_read_field.F90
        wrf_ext_write_field.F90
        wrf_fddaobs_in.F90
        wrf_io.F90
        wrf_num_bytes_between.c
        wrf_shutdown.F90
        wrf_timeseries.F90
        wrf_tsin.F90
        xercon.F90
        xerfft.F90
        z1f2kb.F90
        z1f2kf.F90
        z1f3kb.F90
        z1f3kf.F90
        z1f4kb.F90
        z1f4kf.F90
        z1f5kb.F90
        z1f5kf.F90
        z1fgkb.F90
        z1fgkf.F90
        z1fm1b.F90
        z1fm1f.F90
        zmf2kb.F90
        zmf2kf.F90
        zmf3kb.F90
        zmf3kf.F90
        zmf4kb.F90
        zmf4kf.F90
        zmf5kb.F90
        zmf5kf.F90
        zmfgkb.F90
        zmfgkf.F90
        )],
    'diffwrf_521'=> [ qw(
        ESMF_Alarm.F90
        ESMF_AlarmClock.F90
        ESMF_Base.F90
        ESMF_BaseTime.F90
        ESMF_Calendar.F90
        ESMF_Clock.F90
        ESMF_Mod.F90
        ESMF_Stubs.F90
        ESMF_Time.F90
        ESMF_TimeInterval.F90
        Meat.F90
        adapt_timestep_em.F90
        c1f2kb.F90
        c1f3kb.F90
        c1f4kb.F90
        c1f5kb.F90
        c1fgkb.F90
        c1fm1b.F90
        c_code.c
        cfft1b.F90
        cfft1i.F90
        collect_on_comm.c
        couple_or_uncouple_em.F90
        data.c
        diffwrf.F90
        field_routines.F90
        hires_timer.c
        input_wrf.F90
        interp_fcn.F90
        io_int.F90
        libmassv.F90
        mediation_wrfmain.F90
        misc.c
        module_alloc_space_0.F90
        module_alloc_space_1.F90
        module_alloc_space_2.F90
        module_alloc_space_3.F90
        module_alloc_space_4.F90
        module_alloc_space_5.F90
        module_alloc_space_6.F90
        module_alloc_space_7.F90
        module_alloc_space_8.F90
        module_alloc_space_9.F90
        module_avgflx_em.F90
        module_bc.F90
        module_bc_em.F90
        module_bc_time_utilities.F90
        module_bl_acm.F90
        module_bl_boulac.F90
        module_bl_camuwpbl_driver.F90
        module_bl_gbmpbl.F90
        module_bl_gfs.F90
        module_bl_gfs2011.F90
        module_bl_mfshconvpbl.F90
        module_bl_mrf.F90
        module_bl_myjpbl.F90
        module_bl_myjurb.F90
        module_bl_mynn.F90
        module_bl_qnsepbl.F90
        module_bl_qnsepbl09.F90
        module_bl_temf.F90
        module_bl_ysu.F90
        module_cam_bl_diffusion_solver.F90
        module_cam_bl_eddy_diff.F90
        module_cam_cldwat.F90
        module_cam_constituents.F90
        module_cam_error_function.F90
        module_cam_esinti.F90
        module_cam_gffgch.F90
        module_cam_molec_diff.F90
        module_cam_mp_cldwat2m_micro.F90
        module_cam_mp_conv_water.F90
        module_cam_mp_microp_aero.F90
        module_cam_mp_modal_aero_initialize_data_phys.F90
        module_cam_mp_ndrop.F90
        module_cam_mp_qneg3.F90
        module_cam_mp_radconstants.F90
        module_cam_physconst.F90
        module_cam_support.F90
        module_cam_trb_mtn_stress.F90
        module_cam_upper_bc.F90
        module_cam_wv_saturation.F90
        module_comm_dm.F90
        module_comm_dm_0.F90
        module_comm_dm_1.F90
        module_comm_dm_2.F90
        module_comm_dm_3.F90
        module_comm_dm_4.F90
        module_comm_nesting_dm.F90
        module_configure.F90
        module_cpl.F90
        module_cpl_oasis3.F90
        module_cu_bmj.F90
        module_cu_camzm.F90
        module_cu_camzm_driver.F90
        module_cu_g3.F90
        module_cu_gd.F90
        module_cu_kf.F90
        module_cu_kfeta.F90
        module_cu_mesosas.F90
        module_cu_nsas.F90
        module_cu_osas.F90
        module_cu_sas.F90
        module_cu_tiedtke.F90
        module_data_cam_mam_aero.F90
        module_date_time.F90
        module_diag_pld.F90
        module_dm.F90
        module_domain.F90
        module_domain_type.F90
        module_driver_constants.F90
        module_fdda_psufddagd.F90
        module_fdda_spnudging.F90
        module_fddaobs_rtfdda.F90
        module_fr_fire_atm.F90
        module_fr_fire_core.F90
        module_fr_fire_driver.F90
        module_fr_fire_driver_wrf.F90
        module_fr_fire_model.F90
        module_fr_fire_phys.F90
        module_fr_fire_util.F90
        module_gfs_funcphys.F90
        module_internal_header_util.F90
        module_io.F90
        module_io_domain.F90
        module_io_quilt.F90
        module_io_wrf.F90
        module_lightning_driver.F90
        module_llxy.F90
        module_ltng_cpmpr92z.F90
        module_ltng_crmpr92.F90
        module_ltng_iccg.F90
        module_ltng_lpi.F90
        module_machine.F90
        module_model_constants.F90
        module_mp_cammgmp_driver.F90
        module_mp_etanew.F90
        module_mp_etaold.F90
        module_mp_fast_sbm.F90
        module_mp_full_sbm.F90
        module_mp_milbrandt2mom.F90
        module_mp_morr_two_moment.F90
        module_mp_nssl_2mom.F90
        module_mp_radar.F90
        module_mp_thompson.F90
        module_mp_wdm5.F90
        module_mp_wdm6.F90
        module_mp_wsm3.F90
        module_mp_wsm5.F90
        module_mp_wsm6.F90
        module_physics_init.F90
        module_ra_cam.F90
        module_ra_cam_support.F90
        module_ra_clWRF_support.F90
        module_ra_gfdleta.F90
        module_ra_gsfcsw.F90
        module_ra_hs.F90
        module_ra_rrtm.F90
        module_ra_sw.F90
        module_sf_bem.F90
        module_sf_bep.F90
        module_sf_bep_bem.F90
        module_sf_lake.F90
        module_sf_myjsfc.F90
        module_sf_mynn.F90
        module_sf_noah_seaice.F90
        module_sf_noahdrv.F90
        module_sf_noahlsm.F90
        module_sf_noahlsm_glacial_only.F90
        module_sf_noahmp_glacier.F90
        module_sf_noahmp_groundwater.F90
        module_sf_noahmpdrv.F90
        module_sf_noahmplsm.F90
        module_sf_oml.F90
        module_sf_pxlsm.F90
        module_sf_pxlsm_data.F90
        module_sf_pxsfclay.F90
        module_sf_qnsesfc.F90
        module_sf_ruclsm.F90
        module_sf_sfclay.F90
        module_sf_sfclayrev.F90
        module_sf_slab.F90
        module_sf_temfsfclay.F90
        module_sf_urban.F90
        module_shcu_camuwshcu.F90
        module_shcu_grims.F90
        module_state_description.F90
        module_stoch.F90
        module_streams.F90
        module_symbols_util.F90
        module_tiles.F90
        module_timing.F90
        module_utility.F90
        module_wind_fitch.F90
        module_wrf_error.F90
        mradb2.F90
        mradb3.F90
        mradb4.F90
        mradb5.F90
        mradbg.F90
        mradf2.F90
        mradf3.F90
        mradf4.F90
        mradf5.F90
        mradfg.F90
        mrftb1.F90
        mrftf1.F90
        mrfti1.F90
        my_strtok.c
        netcdf/attr.c
        netcdf/dim.c
        netcdf/error.c
        netcdf/fort-attio.c
        netcdf/fort-control.c
        netcdf/fort-dim.c
        netcdf/fort-genatt.c
        netcdf/fort-geninq.c
        netcdf/fort-genvar.c
        netcdf/fort-lib.c
        netcdf/fort-misc.c
        netcdf/fort-varaio.c
        netcdf/libvers.c
        netcdf/nc.c
        netcdf/ncio.c
        netcdf/ncx.c
        netcdf/putget.c
        netcdf/string.c
        netcdf/v1hpg.c
        netcdf/v2i.c
        netcdf/var.c
        nl_get_0_routines.F90
        nl_get_1_routines.F90
        nl_get_2_routines.F90
        nl_get_3_routines.F90
        nl_get_4_routines.F90
        nl_get_5_routines.F90
        nl_get_6_routines.F90
        nl_get_7_routines.F90
        nl_set_0_routines.F90
        nl_set_1_routines.F90
        nl_set_2_routines.F90
        nl_set_7_routines.F90
        output_wrf.F90
        pack_utils.c
        period.c
        r4_factor.F90
        r4_mcfti1.F90
        r4_tables.F90
        reg_parse.c
        rfftmb.F90
        rfftmf.F90
        rfftmi.F90
        rsl_bcast.c
        sint.F90
        start_domain.F90
        start_em.F90
        symtab_gen.c
        task_for_point.c
        track_driver.F90
        track_input.F90
        type.c
        wrf_bdyin.F90
        wrf_bdyout.F90
        wrf_debug.F90
        wrf_ext_read_field.F90
        wrf_ext_write_field.F90
        wrf_io.F90
        wrf_num_bytes_between.c
        wrf_timeseries.F90
        wrf_tsin.F90
        xercon.F90
        xerfft.F90
        ) ],
);

# Setup for 221.owrf
$sources{'openmp_wrf'} = $sources{'wrf_r'};
$sources{'diffwrf_221'} = $sources{'diffwrf_521'};
# Setup for 621.wrf_s
$sources{'wrf_s'} = $sources{'wrf_r'};
$sources{'diffwrf_621'} = $sources{'diffwrf_521'};


$bench_fppflags = '-w -m literal.pm -I. -I./inc -I./netcdf/include -DDM_PARALLEL -DEM_CORE=1 -DNMM_CORE=0 -DNMM_MAX_DIM=2600 -DCOAMPS_CORE=0 -DDA_CORE=0 -DEXP_CORE=0 -DIWORDSIZE=4 -DDWORDSIZE=8 -DRWORDSIZE=4 -DLWORDSIZE=4 -DNETCDF -DINTIO -DCONFIG_BUF_LEN=32768 -DMAX_DOMAINS_F=21 -DNMM_NEST=0 -DMAX_HISTORY=25 -DSPEC_AUTO_SUPPRESS_OPENMP';

$bench_flags = '-I. -I./netcdf/include -I./inc -DSTUBMPI -DSPEC_AUTO_SUPPRESS_OPENMP';

$bench_cflags = '-DSPEC_AUTO_BYTEORDER=0x'.$::Config{'byteorder'};

sub compare_commands {
    my ($me) = @_;
    my $name;
    my @rc;
    my ($comparefiles) = $me->compare_files_hash;

    my ($exe) = (grep { /^diffwrf/ } $me->exe_files);
    my @temp = main::read_file('control');
    foreach my $run (@temp) {
        my ($file1, $file2, $ext) = split (/\s+/, $run);
        $file1 = exists($comparefiles->{$file1}) ? $comparefiles->{$file1} : $file1;
        $file2 = exists($comparefiles->{$file2}) ? $comparefiles->{$file2} : $file2;
        push @rc, (
            {
                'command' => $exe,
                'args'    => [ $file1, $file2 ],
                'output'  => "diffwrf_output_$ext\.txt",
                'error'   => "diffwrf_$ext\.err",
            }
        );
    }

    return @rc;
}

sub invoke {
    my ($me) = @_;
    my $name;
    my @rc;
    my ($exe) = (grep { !/^diffwrf/ } $me->exe_files);

    return (
        {
            'command' => $exe,
            'args'    => [ ],
            'output'  => "rsl.out.0000",
            'error'   => "wrf.err",
        }
    );
}

%deps = (
    'ESMF_Alarm.F90' => [
        'ESMF_Base.F90',
        'ESMF_Time.F90',
        'ESMF_TimeInterval.F90',
    ],
    'ESMF_AlarmClock.F90' => [
        'ESMF_Alarm.F90',
        'ESMF_Clock.F90',
        'ESMF_Time.F90',
        'ESMF_TimeInterval.F90',
    ],
    'ESMF_BaseTime.F90' => [
        'ESMF_Base.F90',
    ],
    'ESMF_Calendar.F90' => [
        'ESMF_Base.F90',
        'ESMF_BaseTime.F90',
    ],
    'ESMF_Clock.F90' => [
        'ESMF_Alarm.F90',
        'ESMF_Base.F90',
        'ESMF_Time.F90',
        'ESMF_TimeInterval.F90',
    ],
    'ESMF_Mod.F90' => [
        'ESMF_Alarm.F90',
        'ESMF_AlarmClock.F90',
        'ESMF_Base.F90',
        'ESMF_BaseTime.F90',
        'ESMF_Calendar.F90',
        'ESMF_Clock.F90',
        'ESMF_Fraction.F90',
        'ESMF_Stubs.F90',
        'ESMF_Time.F90',
        'ESMF_TimeInterval.F90',
    ],
    'ESMF_Stubs.F90' => [
        'ESMF_Base.F90',
        'ESMF_Calendar.F90',
    ],
    'ESMF_Time.F90' => [
        'ESMF_Base.F90',
        'ESMF_BaseTime.F90',
        'ESMF_Calendar.F90',
        'ESMF_Stubs.F90',
        'ESMF_TimeInterval.F90',
    ],
    'ESMF_TimeInterval.F90' => [
        'ESMF_Base.F90',
        'ESMF_BaseTime.F90',
        'ESMF_Calendar.F90',
        'ESMF_Fraction.F90',
    ],
    'Meat.F90' => [
        'ESMF_Alarm.F90',
        'ESMF_Base.F90',
        'ESMF_BaseTime.F90',
        'ESMF_Calendar.F90',
        'ESMF_Clock.F90',
        'ESMF_Fraction.F90',
        'ESMF_Time.F90',
        'ESMF_TimeInterval.F90',
    ],
    'adapt_timestep_em.F90' => [
        'module_bc_em.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
    ],
    'couple_or_uncouple_em.F90' => [
        'module_bc.F90',
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_machine.F90',
        'module_state_description.F90',
        'module_tiles.F90',
    ],
    'dfi.F90' => [
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_io_domain.F90',
        'module_machine.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_utility.F90',
    ],
    'diffwrf.F90' => [
        'wrf_io.F90',
    ],
    'f_xpose.F90' => [
        'f_pack.F90',
    ],
    'field_routines.F90' => [
        'wrf_io.F90',
    ],
    'init_modules.F90' => [
        'io_int.F90',
        'module_bc.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_io.F90',
        'module_io_quilt.F90',
        'module_io_wrf.F90',
        'module_machine.F90',
        'module_model_constants.F90',
        'module_nesting.F90',
        'module_tiles.F90',
        'module_timing.F90',
        'module_wrf_error.F90',
    ],
    'input_wrf.F90' => [
        'module_bc_time_utilities.F90',
        'module_configure.F90',
        'module_date_time.F90',
        'module_domain.F90',
        'module_io.F90',
        'module_io_wrf.F90',
        'module_state_description.F90',
        'module_utility.F90',
    ],
    'interp_domain_em.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_state_description.F90',
    ],
    'interp_fcn.F90' => [
        'module_configure.F90',
        'module_dm.F90',
        'module_interp_store.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_timing.F90',
        'module_wrf_error.F90',
    ],
    'io_int.F90' => [
        'module_internal_header_util.F90',
    ],
    'mediation_feedback_domain.F90' => [
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_intermediate_nmm.F90',
        'module_timing.F90',
    ],
    'mediation_force_domain.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_intermediate_nmm.F90',
        'module_timing.F90',
    ],
    'mediation_integrate.F90' => [
        'module_bc_time_utilities.F90',
        'module_configure.F90',
        'module_date_time.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_io_domain.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_streams.F90',
        'module_timing.F90',
        'module_utility.F90',
    ],
    'mediation_interp_domain.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_timing.F90',
    ],
    'mediation_nest_move.F90' => [
        'module_compute_geop.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_streams.F90',
        'module_timing.F90',
        'module_utility.F90',
    ],
    'mediation_wrfmain.F90' => [
        'module_bc_time_utilities.F90',
        'module_configure.F90',
        'module_domain.F90',
        'module_io.F90',
        'module_io_domain.F90',
        'module_timing.F90',
        'module_utility.F90',
    ],
    'module_advect_em.F90' => [
        'module_bc.F90',
        'module_model_constants.F90',
        'module_wrf_error.F90',
    ],
    'module_after_all_rk_steps.F90' => [
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_diagnostics_driver.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_state_description.F90',
    ],
    'module_alloc_space_0.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_alloc_space_1.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_alloc_space_2.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_alloc_space_3.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_alloc_space_4.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_alloc_space_5.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_alloc_space_6.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_alloc_space_7.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_alloc_space_8.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_alloc_space_9.F90' => [
        'module_configure.F90',
        'module_domain_type.F90',
    ],
    'module_avgflx_em.F90' => [
        'module_bc.F90',
        'module_model_constants.F90',
        'module_wrf_error.F90',
    ],
    'module_bc.F90' => [
        'module_configure.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_bc_em.F90' => [
        'module_bc.F90',
        'module_configure.F90',
        'module_wrf_error.F90',
    ],
    'module_bc_time_utilities.F90' => [
        'module_utility.F90',
    ],
    'module_big_step_utilities_em.F90' => [
        'module_configure.F90',
        'module_llxy.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_bl_camuwpbl_driver.F90' => [
        'module_cam_bl_diffusion_solver.F90',
        'module_cam_bl_eddy_diff.F90',
        'module_cam_constituents.F90',
        'module_cam_molec_diff.F90',
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_cam_trb_mtn_stress.F90',
        'module_cam_wv_saturation.F90',
        'module_data_cam_mam_aero.F90',
        'module_model_constants.F90',
    ],
    'module_bl_fogdes.F90' => [
        'module_bl_mynn.F90',
        'module_model_constants.F90',
    ],
    'module_bl_gbmpbl.F90' => [
        'module_model_constants.F90',
    ],
    'module_bl_gfs.F90' => [
        'module_gfs_machine.F90',
        'module_gfs_physcons.F90',
    ],
    'module_bl_gfs2011.F90' => [
        'module_gfs_machine.F90',
        'module_gfs_physcons.F90',
    ],
    'module_bl_mfshconvpbl.F90' => [
        'module_model_constants.F90',
    ],
    'module_bl_myjpbl.F90' => [
        'module_model_constants.F90',
    ],
    'module_bl_myjurb.F90' => [
        'module_model_constants.F90',
    ],
    'module_bl_mynn.F90' => [
        'module_model_constants.F90',
        'module_state_description.F90',
    ],
    'module_bl_qnsepbl.F90' => [
        'module_model_constants.F90',
    ],
    'module_bl_qnsepbl09.F90' => [
        'module_model_constants.F90',
    ],
    'module_cam_bl_diffusion_solver.F90' => [
        'module_cam_support.F90',
    ],
    'module_cam_bl_eddy_diff.F90' => [
        'module_cam_bl_diffusion_solver.F90',
        'module_cam_support.F90',
    ],
    'module_cam_cldwat.F90' => [
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_cam_wv_saturation.F90',
    ],
    'module_cam_constituents.F90' => [
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
    ],
    'module_cam_esinti.F90' => [
        'module_cam_shr_kind_mod.F90',
        'module_cam_wv_saturation.F90',
    ],
    'module_cam_gffgch.F90' => [
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
    ],
    'module_cam_infnan.F90' => [
        'module_cam_shr_kind_mod.F90',
    ],
    'module_cam_molec_diff.F90' => [
        'module_cam_constituents.F90',
        'module_cam_support.F90',
        'module_cam_upper_bc.F90',
    ],
    'module_cam_mp_cldwat2m_micro.F90' => [
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_cam_wv_saturation.F90',
    ],
    'module_cam_mp_conv_water.F90' => [
        'module_cam_constituents.F90',
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
    ],
    'module_cam_mp_microp_aero.F90' => [
        'module_cam_constituents.F90',
        'module_cam_error_function.F90',
        'module_cam_mp_ndrop.F90',
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_cam_wv_saturation.F90',
        'module_data_cam_mam_aero.F90',
    ],
    'module_cam_mp_modal_aero_initialize_data_phys.F90' => [
        'module_data_cam_mam_aero.F90',
    ],
    'module_cam_mp_ndrop.F90' => [
        'module_cam_constituents.F90',
        'module_cam_error_function.F90',
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_cam_wv_saturation.F90',
        'module_data_cam_mam_aero.F90',
    ],
    'module_cam_mp_qneg3.F90' => [
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
    ],
    'module_cam_mp_radconstants.F90' => [
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
    ],
    'module_cam_physconst.F90' => [
        'module_cam_shr_const_mod.F90',
        'module_cam_shr_kind_mod.F90',
    ],
    'module_cam_shr_const_mod.F90' => [
        'module_cam_shr_kind_mod.F90',
    ],
    'module_cam_support.F90' => [
        'module_cam_shr_kind_mod.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_cam_trb_mtn_stress.F90' => [
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
    ],
    'module_cam_upper_bc.F90' => [
        'module_cam_constituents.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
    ],
    'module_cam_wv_saturation.F90' => [
        'module_cam_gffgch.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_wrf_error.F90',
    ],
    'module_check_a_mundo.F90' => [
        'module_configure.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_comm_dm.F90' => [
        'module_comm_dm_0.F90',
        'module_comm_dm_1.F90',
        'module_comm_dm_2.F90',
        'module_comm_dm_3.F90',
        'module_comm_dm_4.F90',
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_state_description.F90',
    ],
    'module_comm_dm_0.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_state_description.F90',
    ],
    'module_comm_dm_1.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_state_description.F90',
    ],
    'module_comm_dm_2.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_state_description.F90',
    ],
    'module_comm_dm_3.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_state_description.F90',
    ],
    'module_comm_dm_4.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_state_description.F90',
    ],
    'module_comm_nesting_dm.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_state_description.F90',
    ],
    'module_configure.F90' => [
        'module_domain_type.F90',
        'module_driver_constants.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_cpl.F90' => [
        'module_configure.F90',
        'module_cpl_oasis3.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_model_constants.F90',
    ],
    'module_cpl_oasis3.F90' => [
        'module_domain.F90',
        'module_driver_constants.F90',
    ],
    'module_cu_bmj.F90' => [
        'module_model_constants.F90',
    ],
    'module_cu_camzm.F90' => [
        'module_cam_cldwat.F90',
        'module_cam_constituents.F90',
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_cam_wv_saturation.F90',
    ],
    'module_cu_camzm_driver.F90' => [
        'module_cam_constituents.F90',
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_cam_wv_saturation.F90',
        'module_cu_camzm.F90',
        'module_data_cam_mam_asect.F90',
        'module_model_constants.F90',
        'module_mp_cammgmp_driver.F90',
        'module_state_description.F90',
    ],
    'module_cu_kf.F90' => [
        'module_wrf_error.F90',
    ],
    'module_cu_kfeta.F90' => [
        'module_wrf_error.F90',
    ],
    'module_cu_mesosas.F90' => [
        'module_gfs_funcphys.F90',
        'module_gfs_machine.F90',
        'module_gfs_physcons.F90',
    ],
    'module_cu_osas.F90' => [
        'module_gfs_funcphys.F90',
        'module_gfs_machine.F90',
        'module_gfs_physcons.F90',
    ],
    'module_cu_sas.F90' => [
        'module_gfs_funcphys.F90',
        'module_gfs_machine.F90',
        'module_gfs_physcons.F90',
    ],
    'module_cumulus_driver.F90' => [
        'module_comm_dm.F90',
        'module_cu_bmj.F90',
        'module_cu_camzm_driver.F90',
        'module_cu_g3.F90',
        'module_cu_gd.F90',
        'module_cu_gf.F90',
        'module_cu_kf.F90',
        'module_cu_kfeta.F90',
        'module_cu_mesosas.F90',
        'module_cu_nsas.F90',
        'module_cu_osas.F90',
        'module_cu_sas.F90',
        'module_cu_tiedtke.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_damping_em.F90' => [
        'module_wrf_error.F90',
    ],
    'module_data_cam_mam_aero.F90' => [
        'module_cam_constituents.F90',
        'module_cam_mp_radconstants.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
    ],
    'module_data_cam_mam_asect.F90' => [
        'module_cam_shr_kind_mod.F90',
        'module_data_cam_mam_aero.F90',
    ],
    'module_date_time.F90' => [
        'module_configure.F90',
        'module_model_constants.F90',
        'module_utility.F90',
        'module_wrf_error.F90',
    ],
    'module_diag_afwa.F90' => [
        'module_configure.F90',
        'module_diag_afwa_hail.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_streams.F90',
        'module_utility.F90',
    ],
    'module_diag_cl.F90' => [
        'module_configure.F90',
        'module_dm.F90',
    ],
    'module_diag_misc.F90' => [
        'module_dm.F90',
    ],
    'module_diag_pld.F90' => [
        'module_model_constants.F90',
    ],
    'module_diagnostics_driver.F90' => [
        'module_configure.F90',
        'module_diag_afwa.F90',
        'module_diag_cl.F90',
        'module_diag_misc.F90',
        'module_diag_pld.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_lightning_driver.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
    ],
    'module_diffusion_em.F90' => [
        'module_bc.F90',
        'module_big_step_utilities_em.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
    ],
    'module_dm.F90' => [
        'module_comm_dm.F90',
        'module_comm_dm_3.F90',
        'module_comm_nesting_dm.F90',
        'module_configure.F90',
        'module_cpl.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_machine.F90',
        'module_state_description.F90',
        'module_timing.F90',
        'module_utility.F90',
        'module_wrf_error.F90',
    ],
    'module_domain.F90' => [
        'module_alloc_space_0.F90',
        'module_alloc_space_1.F90',
        'module_alloc_space_2.F90',
        'module_alloc_space_3.F90',
        'module_alloc_space_4.F90',
        'module_alloc_space_5.F90',
        'module_alloc_space_6.F90',
        'module_alloc_space_7.F90',
        'module_alloc_space_8.F90',
        'module_alloc_space_9.F90',
        'module_configure.F90',
        'module_domain_type.F90',
        'module_driver_constants.F90',
        'module_machine.F90',
        'module_utility.F90',
        'module_wrf_error.F90',
    ],
    'module_domain_type.F90' => [
        'module_driver_constants.F90',
        'module_streams.F90',
        'module_utility.F90',
    ],
    'module_em.F90' => [
        'module_advect_em.F90',
        'module_big_step_utilities_em.F90',
        'module_configure.F90',
        'module_damping_em.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_llxy.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
    ],
    'module_fdda_psufddagd.F90' => [
        'module_model_constants.F90',
    ],
    'module_fdda_spnudging.F90' => [
        'module_dm.F90',
        'module_domain.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_fddagd_driver.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_fdda_psufddagd.F90',
        'module_fdda_spnudging.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
    ],
    'module_fddaobs_driver.F90' => [
        'module_domain.F90',
        'module_fddaobs_rtfdda.F90',
        'module_model_constants.F90',
    ],
    'module_fddaobs_rtfdda.F90' => [
        'module_dm.F90',
        'module_domain.F90',
        'module_model_constants.F90',
    ],
    'module_first_rk_step_part1.F90' => [
        'module_big_step_utilities_em.F90',
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_convtrans_prep.F90',
        'module_cumulus_driver.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_em.F90',
        'module_fddagd_driver.F90',
        'module_force_scm.F90',
        'module_fr_fire_driver_wrf.F90',
        'module_model_constants.F90',
        'module_pbl_driver.F90',
        'module_radiation_driver.F90',
        'module_shallowcu_driver.F90',
        'module_state_description.F90',
        'module_surface_driver.F90',
        'module_utility.F90',
    ],
    'module_first_rk_step_part2.F90' => [
        'module_bc.F90',
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_diffusion_em.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_em.F90',
        'module_fddaobs_driver.F90',
        'module_model_constants.F90',
        'module_physics_addtendc.F90',
        'module_state_description.F90',
        'module_stoch.F90',
    ],
    'module_force_scm.F90' => [
        'module_init_utilities.F90',
    ],
    'module_fr_fire_atm.F90' => [
        'module_fr_fire_util.F90',
        'module_model_constants.F90',
    ],
    'module_fr_fire_core.F90' => [
        'module_fr_fire_phys.F90',
        'module_fr_fire_util.F90',
    ],
    'module_fr_fire_driver.F90' => [
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_fr_fire_core.F90',
        'module_fr_fire_model.F90',
        'module_fr_fire_phys.F90',
        'module_fr_fire_util.F90',
        'module_model_constants.F90',
    ],
    'module_fr_fire_driver_wrf.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_fr_fire_atm.F90',
        'module_fr_fire_driver.F90',
        'module_fr_fire_util.F90',
    ],
    'module_fr_fire_model.F90' => [
        'module_fr_fire_core.F90',
        'module_fr_fire_phys.F90',
        'module_fr_fire_util.F90',
    ],
    'module_fr_fire_phys.F90' => [
        'module_fr_fire_util.F90',
        'module_model_constants.F90',
    ],
    'module_fr_fire_util.F90' => [
        'module_dm.F90',
        'module_wrf_error.F90',
    ],
    'module_gfs_funcphys.F90' => [
        'module_gfs_machine.F90',
        'module_gfs_physcons.F90',
    ],
    'module_gfs_physcons.F90' => [
        'module_gfs_machine.F90',
    ],
    'module_initialize_real.F90' => [
        'module_bc.F90',
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_date_time.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_io_domain.F90',
        'module_llxy.F90',
        'module_model_constants.F90',
        'module_optional_input.F90',
        'module_polarfft.F90',
        'module_soil_pre.F90',
        'module_state_description.F90',
        'module_timing.F90',
    ],
    'module_integrate.F90' => [
        'module_configure.F90',
        'module_cpl.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_nesting.F90',
        'module_timing.F90',
        'module_utility.F90',
    ],
    'module_intermediate_nmm.F90' => [
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_state_description.F90',
        'module_timing.F90',
    ],
    'module_interp_store.F90' => [
        'module_domain_type.F90',
    ],
    'module_io.F90' => [
        'module_configure.F90',
        'module_dm.F90',
        'module_driver_constants.F90',
        'module_state_description.F90',
        'module_streams.F90',
    ],
    'module_io_domain.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_io.F90',
        'module_io_wrf.F90',
        'module_state_description.F90',
        'module_utility.F90',
    ],
    'module_io_quilt.F90' => [
        'module_configure.F90',
        'module_cpl.F90',
        'module_dm.F90',
        'module_internal_header_util.F90',
        'module_quilt_outbuf_ops.F90',
        'module_state_description.F90',
        'module_timing.F90',
        'module_wrf_error.F90',
    ],
    'module_io_wrf.F90' => [
        'module_date_time.F90',
        'module_streams.F90',
        'module_wrf_error.F90',
    ],
    'module_lightning_driver.F90' => [
        'module_dm.F90',
        'module_ltng_cpmpr92z.F90',
        'module_ltng_crmpr92.F90',
        'module_ltng_iccg.F90',
        'module_ltng_lpi.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_utility.F90',
        'module_wrf_error.F90',
    ],
    'module_llxy.F90' => [
        'module_wrf_error.F90',
    ],
    'module_ltng_cpmpr92z.F90' => [
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_ltng_crmpr92.F90' => [
        'module_dm.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_ltng_iccg.F90' => [
        'module_utility.F90',
    ],
    'module_machine.F90' => [
        'module_driver_constants.F90',
    ],
    'module_microphysics_driver.F90' => [
        'module_configure.F90',
        'module_data_cam_mam_aero.F90',
        'module_domain.F90',
        'module_mixactivate.F90',
        'module_model_constants.F90',
        'module_mp_HWRF.F90',
        'module_mp_cammgmp_driver.F90',
        'module_mp_etanew.F90',
        'module_mp_etaold.F90',
        'module_mp_fast_sbm.F90',
        'module_mp_full_sbm.F90',
        'module_mp_gsfcgce.F90',
        'module_mp_kessler.F90',
        'module_mp_lin.F90',
        'module_mp_milbrandt2mom.F90',
        'module_mp_morr_two_moment.F90',
        'module_mp_nssl_2mom.F90',
        'module_mp_sbu_ylin.F90',
        'module_mp_thompson.F90',
        'module_mp_wdm5.F90',
        'module_mp_wdm6.F90',
        'module_mp_wsm3.F90',
        'module_mp_wsm5.F90',
        'module_mp_wsm6.F90',
        'module_state_description.F90',
        'module_utility.F90',
        'module_wrf_error.F90',
    ],
    'module_microphysics_zero_out.F90' => [
        'module_configure.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_mixactivate.F90' => [
        'module_model_constants.F90',
        'module_radiation_driver.F90',
    ],
    'module_mp_cammgmp_driver.F90' => [
        'module_cam_cldwat.F90',
        'module_cam_constituents.F90',
        'module_cam_mp_cldwat2m_micro.F90',
        'module_cam_mp_conv_water.F90',
        'module_cam_mp_microp_aero.F90',
        'module_cam_mp_ndrop.F90',
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_cam_wv_saturation.F90',
        'module_configure.F90',
        'module_data_cam_mam_aero.F90',
        'module_data_cam_mam_asect.F90',
        'module_state_description.F90',
    ],
    'module_mp_fast_sbm.F90' => [
        'module_mp_radar.F90',
    ],
    'module_mp_full_sbm.F90' => [
        'module_mp_radar.F90',
    ],
    'module_mp_gsfcgce.F90' => [
        'module_domain.F90',
        'module_mp_radar.F90',
        'module_utility.F90',
    ],
    'module_mp_lin.F90' => [
        'module_domain.F90',
        'module_mp_radar.F90',
        'module_utility.F90',
    ],
    'module_mp_milbrandt2mom.F90' => [
        'module_model_constants.F90',
        'module_wrf_error.F90',
    ],
    'module_mp_morr_two_moment.F90' => [
        'module_domain.F90',
        'module_model_constants.F90',
        'module_mp_radar.F90',
        'module_utility.F90',
    ],
    'module_mp_radar.F90' => [
        'module_wrf_error.F90',
    ],
    'module_mp_thompson.F90' => [
        'module_dm.F90',
        'module_domain.F90',
        'module_mp_radar.F90',
        'module_wrf_error.F90',
    ],
    'module_mp_wdm5.F90' => [
        'module_domain.F90',
        'module_mp_radar.F90',
        'module_utility.F90',
    ],
    'module_mp_wdm6.F90' => [
        'module_domain.F90',
        'module_mp_radar.F90',
        'module_utility.F90',
    ],
    'module_mp_wsm5.F90' => [
        'module_domain.F90',
        'module_mp_radar.F90',
        'module_utility.F90',
    ],
    'module_mp_wsm6.F90' => [
        'module_domain.F90',
        'module_mp_radar.F90',
        'module_utility.F90',
    ],
    'module_nesting.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_machine.F90',
        'module_utility.F90',
    ],
    'module_optional_input.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_io_domain.F90',
        'module_io_wrf.F90',
    ],
    'module_pbl_driver.F90' => [
        'module_bl_acm.F90',
        'module_bl_boulac.F90',
        'module_bl_camuwpbl_driver.F90',
        'module_bl_fogdes.F90',
        'module_bl_gbmpbl.F90',
        'module_bl_gfs.F90',
        'module_bl_gfs2011.F90',
        'module_bl_gwdo.F90',
        'module_bl_mfshconvpbl.F90',
        'module_bl_mrf.F90',
        'module_bl_myjpbl.F90',
        'module_bl_myjurb.F90',
        'module_bl_mynn.F90',
        'module_bl_qnsepbl.F90',
        'module_bl_qnsepbl09.F90',
        'module_bl_temf.F90',
        'module_bl_ysu.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_wind_fitch.F90',
    ],
    'module_physics_addtendc.F90' => [
        'module_configure.F90',
        'module_cu_kf.F90',
        'module_cu_kfeta.F90',
        'module_state_description.F90',
    ],
    'module_physics_init.F90' => [
        'module_bl_acm.F90',
        'module_bl_boulac.F90',
        'module_bl_camuwpbl_driver.F90',
        'module_bl_gbmpbl.F90',
        'module_bl_gfs.F90',
        'module_bl_gfs2011.F90',
        'module_bl_mfshconvpbl.F90',
        'module_bl_mrf.F90',
        'module_bl_myjpbl.F90',
        'module_bl_myjurb.F90',
        'module_bl_mynn.F90',
        'module_bl_qnsepbl.F90',
        'module_bl_qnsepbl09.F90',
        'module_bl_temf.F90',
        'module_bl_ysu.F90',
        'module_cam_constituents.F90',
        'module_cam_esinti.F90',
        'module_cam_mp_modal_aero_initialize_data_phys.F90',
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_configure.F90',
        'module_cu_bmj.F90',
        'module_cu_camzm_driver.F90',
        'module_cu_g3.F90',
        'module_cu_gd.F90',
        'module_cu_kf.F90',
        'module_cu_kfeta.F90',
        'module_cu_mesosas.F90',
        'module_cu_nsas.F90',
        'module_cu_osas.F90',
        'module_cu_sas.F90',
        'module_cu_tiedtke.F90',
        'module_data_cam_mam_aero.F90',
        'module_domain.F90',
        'module_fdda_psufddagd.F90',
        'module_fdda_spnudging.F90',
        'module_fddaobs_rtfdda.F90',
        'module_llxy.F90',
        'module_model_constants.F90',
        'module_mp_HWRF.F90',
        'module_mp_cammgmp_driver.F90',
        'module_mp_etanew.F90',
        'module_mp_etaold.F90',
        'module_mp_fast_sbm.F90',
        'module_mp_full_sbm.F90',
        'module_mp_milbrandt2mom.F90',
        'module_mp_morr_two_moment.F90',
        'module_mp_nssl_2mom.F90',
        'module_mp_thompson.F90',
        'module_mp_wdm5.F90',
        'module_mp_wdm6.F90',
        'module_mp_wsm3.F90',
        'module_mp_wsm5.F90',
        'module_mp_wsm6.F90',
        'module_ra_HWRF.F90',
        'module_ra_cam.F90',
        'module_ra_cam_support.F90',
        'module_ra_gfdleta.F90',
        'module_ra_gsfcsw.F90',
        'module_ra_hs.F90',
        'module_ra_rrtm.F90',
        'module_ra_sw.F90',
        'module_sf_bep.F90',
        'module_sf_bep_bem.F90',
        'module_sf_clm.F90',
        'module_sf_gfdl.F90',
        'module_sf_lake.F90',
        'module_sf_myjsfc.F90',
        'module_sf_mynn.F90',
        'module_sf_noahdrv.F90',
        'module_sf_noahmpdrv.F90',
        'module_sf_oml.F90',
        'module_sf_pxlsm.F90',
        'module_sf_pxsfclay.F90',
        'module_sf_qnsesfc.F90',
        'module_sf_ruclsm.F90',
        'module_sf_sfclay.F90',
        'module_sf_sfclayrev.F90',
        'module_sf_slab.F90',
        'module_sf_temfsfclay.F90',
        'module_sf_urban.F90',
        'module_shcu_camuwshcu.F90',
        'module_shcu_grims.F90',
        'module_state_description.F90',
        'module_wind_fitch.F90',
        'module_wrf_error.F90',
    ],
    'module_polarfft.F90' => [
        'module_comm_dm.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_progtm.F90' => [
        'module_gfs_machine.F90',
    ],
    'module_quilt_outbuf_ops.F90' => [
        'module_state_description.F90',
        'module_timing.F90',
    ],
    'module_ra_HWRF.F90' => [
        'module_configure.F90',
        'module_model_constants.F90',
        'module_mp_HWRF.F90',
    ],
    'module_ra_aerosol.F90' => [
        'module_wrf_error.F90',
    ],
    'module_ra_cam.F90' => [
        'module_cam_constituents.F90',
        'module_cam_support.F90',
        'module_ra_cam_support.F90',
        'module_ra_clWRF_support.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_ra_cam_support.F90' => [
        'module_cam_support.F90',
        'module_wrf_error.F90',
    ],
    'module_ra_clWRF_support.F90' => [
        'module_wrf_error.F90',
    ],
    'module_ra_gfdleta.F90' => [
        'module_configure.F90',
        'module_model_constants.F90',
        'module_mp_etanew.F90',
    ],
    'module_ra_rrtm.F90' => [
        'module_ra_clWRF_support.F90',
        'module_wrf_error.F90',
    ],
    'module_radiation_driver.F90' => [
        'module_bc.F90',
        'module_comm_dm.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_model_constants.F90',
        'module_ra_HWRF.F90',
        'module_ra_aerosol.F90',
        'module_ra_cam.F90',
        'module_ra_flg.F90',
        'module_ra_gfdleta.F90',
        'module_ra_goddard.F90',
        'module_ra_gsfcsw.F90',
        'module_ra_hs.F90',
        'module_ra_rrtm.F90',
        'module_ra_sw.F90',
        'module_state_description.F90',
        'module_wrf_error.F90',
    ],
    'module_sf_bep.F90' => [
        'module_sf_urban.F90',
    ],
    'module_sf_bep_bem.F90' => [
        'module_sf_bem.F90',
        'module_sf_urban.F90',
    ],
    'module_sf_clm.F90' => [
        'module_cam_shr_const_mod.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_configure.F90',
        'module_date_time.F90',
        'module_sf_urban.F90',
        'module_wrf_error.F90',
    ],
    'module_sf_fogdes.F90' => [
        'module_bl_mynn.F90',
        'module_model_constants.F90',
    ],
    'module_sf_gfdl.F90' => [
        'module_gfs_funcphys.F90',
        'module_gfs_machine.F90',
        'module_gfs_physcons.F90',
    ],
    'module_sf_gfs.F90' => [
        'module_gfs_funcphys.F90',
        'module_gfs_machine.F90',
        'module_gfs_physcons.F90',
        'module_progtm.F90',
    ],
    'module_sf_lake.F90' => [
        'module_model_constants.F90',
        'module_wrf_error.F90',
    ],
    'module_sf_myjsfc.F90' => [
        'module_dm.F90',
        'module_model_constants.F90',
    ],
    'module_sf_mynn.F90' => [
        'module_bl_mynn.F90',
        'module_model_constants.F90',
        'module_sf_sfclay.F90',
    ],
    'module_sf_noah_seaice.F90' => [
        'module_model_constants.F90',
        'module_sf_noahlsm.F90',
    ],
    'module_sf_noah_seaice_drv.F90' => [
        'module_sf_noah_seaice.F90',
        'module_state_description.F90',
    ],
    'module_sf_noahdrv.F90' => [
        'module_data_gocart_dust.F90',
        'module_sf_bep.F90',
        'module_sf_bep_bem.F90',
        'module_sf_noahlsm.F90',
        'module_sf_noahlsm_glacial_only.F90',
        'module_sf_urban.F90',
        'module_wrf_error.F90',
    ],
    'module_sf_noahlsm.F90' => [
        'module_model_constants.F90',
    ],
    'module_sf_noahlsm_glacial_only.F90' => [
        'module_model_constants.F90',
        'module_sf_noahlsm.F90',
    ],
    'module_sf_noahmp_groundwater.F90' => [
        'module_sf_noahlsm.F90',
    ],
    'module_sf_noahmpdrv.F90' => [
        'module_data_gocart_dust.F90',
        'module_ra_gfdleta.F90',
        'module_sf_noah_seaice.F90',
        'module_sf_noahdrv.F90',
        'module_sf_noahmp_glacier.F90',
        'module_sf_noahmp_groundwater.F90',
        'module_sf_noahmplsm.F90',
        'module_sf_urban.F90',
    ],
    'module_sf_noahmplsm.F90' => [
        'module_model_constants.F90',
        'module_sf_myjsfc.F90',
        'module_sf_noahlsm.F90',
        'module_sf_sfclay.F90',
    ],
    'module_sf_ocean_driver.F90' => [
        'module_sf_3dpwp.F90',
        'module_sf_oml.F90',
        'module_state_description.F90',
    ],
    'module_sf_pxlsm.F90' => [
        'module_model_constants.F90',
        'module_sf_pxlsm_data.F90',
    ],
    'module_sf_qnsesfc.F90' => [
        'module_dm.F90',
        'module_model_constants.F90',
    ],
    'module_sf_ruclsm.F90' => [
        'module_data_gocart_dust.F90',
        'module_model_constants.F90',
        'module_wrf_error.F90',
    ],
    'module_sf_sstskin.F90' => [
        'module_wrf_error.F90',
    ],
    'module_shallowcu_driver.F90' => [
        'module_dm.F90',
        'module_domain.F90',
        'module_model_constants.F90',
        'module_shcu_camuwshcu_driver.F90',
        'module_shcu_grims.F90',
        'module_state_description.F90',
    ],
    'module_shcu_camuwshcu.F90' => [
        'module_cam_constituents.F90',
        'module_cam_error_function.F90',
        'module_cam_support.F90',
        'module_cam_wv_saturation.F90',
        'module_data_cam_mam_aero.F90',
        'module_state_description.F90',
    ],
    'module_shcu_camuwshcu_driver.F90' => [
        'module_cam_constituents.F90',
        'module_cam_physconst.F90',
        'module_cam_shr_kind_mod.F90',
        'module_cam_support.F90',
        'module_cam_wv_saturation.F90',
        'module_data_cam_mam_asect.F90',
        'module_mp_cammgmp_driver.F90',
        'module_shcu_camuwshcu.F90',
        'module_state_description.F90',
    ],
    'module_small_step_em.F90' => [
        'module_configure.F90',
        'module_model_constants.F90',
    ],
    'module_soil_pre.F90' => [
        'module_date_time.F90',
        'module_state_description.F90',
    ],
    'module_stoch.F90' => [
        'module_configure.F90',
    ],
    'module_surface_driver.F90' => [
        'module_cpl.F90',
        'module_model_constants.F90',
        'module_sf_clm.F90',
        'module_sf_fogdes.F90',
        'module_sf_gfdl.F90',
        'module_sf_gfs.F90',
        'module_sf_idealscmsfclay.F90',
        'module_sf_lake.F90',
        'module_sf_myjsfc.F90',
        'module_sf_mynn.F90',
        'module_sf_noah_seaice_drv.F90',
        'module_sf_noahdrv.F90',
        'module_sf_noahmp_groundwater.F90',
        'module_sf_noahmpdrv.F90',
        'module_sf_ocean_driver.F90',
        'module_sf_pxlsm.F90',
        'module_sf_pxsfclay.F90',
        'module_sf_qnsesfc.F90',
        'module_sf_ruclsm.F90',
        'module_sf_scmflux.F90',
        'module_sf_scmskintemp.F90',
        'module_sf_sfcdiags.F90',
        'module_sf_sfcdiags_ruclsm.F90',
        'module_sf_sfclay.F90',
        'module_sf_sfclayrev.F90',
        'module_sf_slab.F90',
        'module_sf_ssib.F90',
        'module_sf_sstskin.F90',
        'module_sf_temfsfclay.F90',
        'module_sf_tmnupdate.F90',
        'module_state_description.F90',
    ],
    'module_symbols_util.F90' => [
        'ESMF_Mod.F90',
    ],
    'module_tiles.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_machine.F90',
        'module_wrf_error.F90',
    ],
    'module_timing.F90' => [
        'module_wrf_error.F90',
    ],
    'module_utility.F90' => [
        'module_symbols_util.F90',
    ],
    'module_wind_fitch.F90' => [
        'module_configure.F90',
        'module_dm.F90',
        'module_driver_constants.F90',
        'module_llxy.F90',
        'module_model_constants.F90',
    ],
    'module_wps_io_arw.F90' => [
        'module_domain.F90',
        'module_internal_header_util.F90',
        'module_optional_input.F90',
        'module_soil_pre.F90',
    ],
    'module_wrf_top.F90' => [
        'module_check_a_mundo.F90',
        'module_configure.F90',
        'module_cpl.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_integrate.F90',
        'module_machine.F90',
        'module_nesting.F90',
        'module_timing.F90',
        'module_wrf_error.F90',
    ],
    'ndown_em.F90' => [
        'module_bc.F90',
        'module_big_step_utilities_em.F90',
        'module_check_a_mundo.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_domain_type.F90',
        'module_driver_constants.F90',
        'module_get_file_names.F90',
        'module_initialize_real.F90',
        'module_integrate.F90',
        'module_io_domain.F90',
        'module_machine.F90',
        'module_optional_input.F90',
        'module_soil_pre.F90',
        'module_timing.F90',
        'module_utility.F90',
        'module_wrf_error.F90',
    ],
    'nest_init_utils.F90' => [
        'module_bc.F90',
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_machine.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_tiles.F90',
    ],
    'netcdf/netcdf.f90' => [
        'netcdf/typeSizes.f90',
    ],
    'netcdf/netcdf_test.f90' => [
        'netcdf/netcdf.f90',
        'netcdf/typeSizes.f90',
    ],
    'nl_get_0_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_get_1_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_get_2_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_get_3_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_get_4_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_get_5_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_get_6_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_get_7_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_set_0_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_set_1_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_set_2_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_set_3_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_set_4_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_set_5_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_set_6_routines.F90' => [
        'module_configure.F90',
    ],
    'nl_set_7_routines.F90' => [
        'module_configure.F90',
    ],
    'nup_em.F90' => [
        'module_bc.F90',
        'module_big_step_utilities_em.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_domain_type.F90',
        'module_driver_constants.F90',
        'module_get_file_names.F90',
        'module_initialize_real.F90',
        'module_integrate.F90',
        'module_io_domain.F90',
        'module_machine.F90',
        'module_optional_input.F90',
        'module_soil_pre.F90',
        'module_streams.F90',
        'module_timing.F90',
        'module_utility.F90',
        'module_wrf_error.F90',
    ],
    'output_wrf.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_domain_type.F90',
        'module_io.F90',
        'module_io_wrf.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
        'module_utility.F90',
        'module_wrf_error.F90',
    ],
    'real_em.F90' => [
        'module_bc.F90',
        'module_bc_time_utilities.F90',
        'module_big_step_utilities_em.F90',
        'module_check_a_mundo.F90',
        'module_configure.F90',
        'module_date_time.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_initialize_real.F90',
        'module_io_domain.F90',
        'module_machine.F90',
        'module_optional_input.F90',
        'module_state_description.F90',
        'module_symbols_util.F90',
        'module_timing.F90',
        'module_utility.F90',
        'module_wps_io_arw.F90',
    ],
    'set_timekeeping.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_utility.F90',
    ],
    'shift_domain_em.F90' => [
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_domain_type.F90',
        'module_state_description.F90',
        'module_timing.F90',
    ],
    'solve_em.F90' => [
        'module_after_all_rk_steps.F90',
        'module_avgflx_em.F90',
        'module_bc.F90',
        'module_bc_em.F90',
        'module_big_step_utilities_em.F90',
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_cpl.F90',
        'module_diffusion_em.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_domain_type.F90',
        'module_driver_constants.F90',
        'module_em.F90',
        'module_fddaobs_driver.F90',
        'module_first_rk_step_part1.F90',
        'module_first_rk_step_part2.F90',
        'module_llxy.F90',
        'module_machine.F90',
        'module_microphysics_driver.F90',
        'module_microphysics_zero_out.F90',
        'module_model_constants.F90',
        'module_physics_addtendc.F90',
        'module_polarfft.F90',
        'module_small_step_em.F90',
        'module_solvedebug_em.F90',
        'module_state_description.F90',
        'module_tiles.F90',
        'module_utility.F90',
    ],
    'solve_interface.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_timing.F90',
        'module_wrf_error.F90',
    ],
    'start_domain.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
    ],
    'start_em.F90' => [
        'module_avgflx_em.F90',
        'module_bc.F90',
        'module_bc_em.F90',
        'module_comm_dm.F90',
        'module_configure.F90',
        'module_diag_pld.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_fr_fire_driver_wrf.F90',
        'module_lightning_driver.F90',
        'module_model_constants.F90',
        'module_physics_init.F90',
        'module_state_description.F90',
        'module_stoch.F90',
        'module_tiles.F90',
    ],
    'tc_em.F90' => [
        'module_bc.F90',
        'module_bc_time_utilities.F90',
        'module_big_step_utilities_em.F90',
        'module_configure.F90',
        'module_date_time.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_driver_constants.F90',
        'module_initialize_real.F90',
        'module_io_domain.F90',
        'module_llxy.F90',
        'module_machine.F90',
        'module_optional_input.F90',
        'module_state_description.F90',
        'module_symbols_util.F90',
        'module_timing.F90',
        'module_utility.F90',
    ],
    'track_driver.F90' => [
        'module_configure.F90',
        'module_date_time.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_llxy.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
    ],
    'track_input.F90' => [
        'module_domain.F90',
        'module_utility.F90',
    ],
    'wrf.F90' => [
        'module_wrf_top.F90',
    ],
    'wrf_bdyin.F90' => [
        'module_bc_time_utilities.F90',
        'module_configure.F90',
        'module_date_time.F90',
        'module_domain.F90',
        'module_io.F90',
        'module_io_wrf.F90',
        'module_state_description.F90',
        'module_utility.F90',
    ],
    'wrf_bdyout.F90' => [
        'module_configure.F90',
        'module_domain.F90',
        'module_io.F90',
        'module_io_wrf.F90',
        'module_state_description.F90',
        'module_utility.F90',
        'module_wrf_error.F90',
    ],
    'wrf_debug.F90' => [
        'module_wrf_error.F90',
    ],
    'wrf_ext_read_field.F90' => [
        'module_io.F90',
        'module_state_description.F90',
        'module_timing.F90',
        'module_wrf_error.F90',
    ],
    'wrf_ext_write_field.F90' => [
        'module_io.F90',
        'module_state_description.F90',
        'module_timing.F90',
        'module_wrf_error.F90',
    ],
    'wrf_fddaobs_in.F90' => [
        'module_configure.F90',
        'module_date_time.F90',
        'module_domain.F90',
        'module_llxy.F90',
        'module_model_constants.F90',
    ],
    'wrf_timeseries.F90' => [
        'module_configure.F90',
        'module_dm.F90',
        'module_domain.F90',
        'module_llxy.F90',
        'module_model_constants.F90',
        'module_state_description.F90',
    ],
    'wrf_tsin.F90' => [
        'module_domain.F90',
        'module_utility.F90',
    ],
);

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
