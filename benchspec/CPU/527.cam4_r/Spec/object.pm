$benchnum  = '527';
$benchname = 'cam4_r';
$exename   = 'cam4_r';
$benchlang = 'F,C';
@base_exe  = qw(cam4_r cam4_validate_527);
use Config;

$compwhite = 1;

$binary = {
    'cam4' => 1,
    'cam4_validate' => 1,
    'default' => undef,
};

$reltol = {
    'cam4_validate'    => 0.015,
    'default' => undef,
};

my $all_lang_inc   = ' -I. -Iinclude -Inetcdf/include';
my $all_lang_flags = '-DNO_SHR_VMATH -DCO2A -DPERGRO -DPLON=144 -DPLAT=96 -DPLEV=26 -DPCNST=3'
                   . ' -DPCOLS=4 -DPTRM=1 -DPTRN=1 -DPTRK=1 -DSTAGGERED -D_NETCDF -DNO_R16'
                   . $all_lang_inc.' -DSPEC_AUTO_SUPPRESS_OPENMP';

$bench_fppflags    = $all_lang_flags
                   . ' -w -DHIDE_MPI -D_MPISERIAL -DNO_MPI2';

$bench_fflags      = $all_lang_inc;

$bench_cflags      = $all_lang_flags
                   . ' -DSPEC_AUTO_BYTEORDER=0x'.$Config{'byteorder'};

%sources = (
    'cam4_r' => [ qw(
        ESMF_BaseMod.F90
        ESMF_BaseTimeMod.F90
        ESMF_FractionMod.F90
        ESMF_CalendarMod.F90
        ESMF_TimeIntervalMod.F90
        ESMF_Stubs.F90
        ESMF_TimeMod.F90
        ESMF_AlarmMod.F90
        ESMF_ClockMod.F90
        ESMF_AlarmClockMod.F90
        ESMF_Mod.F90
        cam_logfile.F90
        debugutilitiesmodule.F90
        decompmodule.F90
        shr_kind_mod.F90
        ghostmodule.F90
        perf_utils.F90
        shr_log_mod.F90
        shr_mpi_mod.F90
        shr_sys_mod.F90
        shr_file_mod.F90
        string_utils.F90
        namelist_utils.F90
        perf_mod.F90
        mod_comm.F90
        parutilitiesmodule.F90
        mpishorthand.F90
        abortutils.F90
        units.F90
        spmd_utils.F90
        fv_control_mod.F90
        pft_module.F90
        dynamics_vars.F90
        FVperf_module.F90
        GPTLget_memusage.c
        GPTLprint_memusage.c
        GPTLutil.c
        MISR_simulator.F90
        Meat.F90
        pmgrid.F90
        dycore.F90
        pio_kinds.F90
        pio_support.F90
        pio_types.F90
        pio_msg_mod.F90
        alloc_mod.F90
        pio_utils.F90
        nf_mod.F90
        pionfput_mod.F90
        pionfatt_mod.F90
        pio_spmd_utils.F90
        calcdisplace_mod.F90
        box_rearrange.F90
        rearrange.F90
        pionfread_mod.F90
        iompi_mod.F90
        pionfwrite_mod.F90
        piodarray.F90
        ionf_mod.F90
        calcdecomp.F90
        pio_mpi_utils.F90
        piolib_mod.F90
        pionfget_mod.F90
        pio.F90
        shr_timer_mod.F90
        shr_string_mod.F90
        shr_const_mod.F90
        shr_cal_mod.F90
        time_manager.F90
        ppgrid.F90
        physconst.F90
        constituents.F90
        commap.F90
        infnan.F90
        pspect.F90
        rgrid.F90
        spmd_dyn.F90
        hycoef.F90
        dyn_grid.F90
        m_chars.F90
        m_flow.F90
        m_stdio.F90
        m_mpif.F90
        m_realkinds.F90
        m_mpif90.F90
        m_dropdead.F90
        m_ioutil.F90
        m_mpout.F90
        m_die.F90
        m_MergeSorts.F90
        phys_grid.F90
        ioFileMod.F90
        cam_history_support.F90
        cam_control_mod.F90
        m_mall.F90
        m_String.F90
        m_rankMerge.F90
        m_IndexBin_logical.F90
        m_Permuter.F90
        m_IndexBin_char.F90
        m_IndexBin_integer.F90
        m_SortingTools.F90
        m_List.F90
        m_TraceBack.F90
        m_AttrVect.F90
        m_GlobalMap.F90
        m_FcComms.F90
        m_MCTWorld.F90
        m_GlobalSegMap.F90
        m_AttrVectComms.F90
        m_SparseMatrix.F90
        m_SparseMatrixDecomp.F90
        m_SparseMatrixComms.F90
        m_Navigator.F90
        m_GlobalToLocal.F90
        m_SparseMatrixToMaps.F90
        m_ConvertMaps.F90
        m_ExchangeMaps.F90
        m_Router.F90
        m_Rearranger.F90
        m_SparseMatrixPlus.F90
        m_GeneralGrid.F90
        m_Transfer.F90
        m_inpak90.F90
        m_GlobalSegMapComms.F90
        m_Accumulator.F90
        m_MatAttrVectMul.F90
        m_GeneralGridComms.F90
        mct_mod.F90
        seq_comm_mct.F90
        seq_drydep_mod.F90
        seq_flds_mod.F90
        seq_io_mod.F90
        cam_pio_utils.F90
        sat_hist.F90
        solar_data.F90
        shr_orb_mod.F90
        shr_tInterp_mod.F90
        shr_stream_mod.F90
        shr_pcdf_mod.F90
        shr_mct_mod.F90
        shr_map_mod.F90
        shr_ncread_mod.F90
        shr_dmodel_mod.F90
        shr_strdata_mod.F90
        shr_scam_mod.F90
        wrap_nf.F90
        scamMod.F90
        error_messages.F90
        interpolate_data.F90
        geopotential.F90
        ref_pres.F90
        phys_control.F90
        physics_types.F90
        time_utils.F90
        repro_sum_mod.F90
        phys_gmean.F90
        mo_constants.F90
        m_types.F90
        mo_flbc.F90
        chem_surfvals.F90
        cam_history_buffers.F90
        filenames.F90
        cosp_share.F90
        interp_mod.F90
        cam_history.F90
        advect_tend.F90
        phys_buffer.F90
        ghg_data.F90
        radconstants.F90
        radae.F90
        quicksort.F90
        radlw.F90
        pkg_cldoptics.F90
        phys_debug_util.F90
        conv_water.F90
        param_cldoptics.F90
        mo_util.F90
        rad_solar_var.F90
        cmparray_mod.F90
        radsw.F90
        phys_prop.F90
        rad_constituents.F90
        wv_saturation.F90
        modal_aer_opt.F90
        aer_rad_props.F90
        camsrfexch_types.F90
        radiation_data.F90
        cosp_constants.F90
        cosp_utils.F90
        radar_simulator_types.f90
        cosp_types.F90
        modis_simulator.F90
        cosp_modis_simulator.F90
        cosp_lidar.F90
        cosp_misr_simulator.F90
        llnl_stats.F90
        lmd_ipsl_stats.F90
        cosp_stats.F90
        atmos_lib.f90
        mrgrnk.f90
        array_lib.f90
        format_input.f90
        math_lib.f90
        optics_lib.f90
        cosp_radar.F90
        cosp_isccp_simulator.F90
        cosp_simulator.F90
        cosp.F90
        cospsimulator_intr.F90
        chemistry.F90
        radheat.F90
        radiation.F90
        horizontal_interpolate.F90
        polar_avg.F90
        tracer_data.F90
        prescribed_ghg.F90
        prescribed_aero.F90
        trb_mtn_stress.F90
        phys_debug.F90
        hb_diff.F90
        upper_bc.F90
        molec_diff.F90
        diffusion_solver.F90
        eddy_diff.F90
        vertical_diffusion.F90
        boundarydata.F90
        cam3_ozone_data.F90
        aoa_tracers.F90
        iondrag.F90
        cam3_aero_data.F90
        tracers_suite.F90
        tracers.F90
        tropopause.F90
        prescribed_volcaero.F90
        prescribed_ozone.F90
        aircraft_emit.F90
        modal_aero_deposition.F90
        aerodep_flx.F90
        advnce.F90
        drydep_mod.F90
        wetdep.F90
        dust_sediment_mod.F90
        dust_intr.F90
        progseasalts_intr.F90
        scyc.F90
        aerosol_intr.F90
        history_scam.F90
        xpavg_mod.F90
        ncdio_atm.F90
        metdata.F90
        co2_data_flux.F90
        co2_cycle.F90
        buffer.F90
        comsrf.F90
        restart_physics.F90
        pfixer.F90
        ctem.F90
        diag_module.F90
        dyn_comp.F90
        dyn_internal_state.F90
        restart_dynamics.F90
        cam_restart.F90
        readinitial.F90
        history_defaults.F90
        error_function.F90
        uw_conv.F90
        uwshcu.F90
        cldwat.F90
        zm_conv.F90
        hk_conv.F90
        convect_shallow.F90
        cloud_fraction.F90
        cldwat2m_macro.F90
        ndrop.F90
        cldwat2m_micro.F90
        microp_aero.F90
        microp_driver.F90
        pkg_cld_sediment.F90
        stratiform.F90
        inidat.F90
        startup_initialconds.F90
        inital.F90
        check_energy.F90
        dp_coupling.F90
        fv_prints.F90
        stepon.F90
        ionosphere.F90
        cloud_diagnostics.F90
        cloud_rad_props.F90
        tidal_diag.F90
        constituent_burden.F90
        cam_diagnostics.F90
        flux_avg.F90
        macrop_driver.F90
        gw_drag.F90
        zm_conv_intr.F90
        convect_deep.F90
        rayleigh_friction.F90
        majorsp_diffusion.F90
        sslt_rebin.F90
        physpkg.F90
        cam_comp.F90
        seq_infodata_mod.F90
        seq_cdata_mod.F90
        runtime_opts.F90
        cam_cpl_indices.F90
        seq_timemgr_mod.F90
        atm_comp_mct.F90
        benergy.F90
        binary_io.F90
        bnddyi.F90
        seq_flds_indices.F90
        seq_diag_mct.F90
        seq_rearr_mod.F90
        map_ocnocn_mct.F90
        mrg_x2s_mct.F90
        ice_comp_mct.F90
        mrg_x2o_mct.F90
        seq_avdata_mod.F90
        seq_hist_mod.F90
        mrg_x2a_mct.F90
        map_iceocn_mct.F90
        seq_map_mod.F90
        map_atmlnd_mct.F90
        map_atmice_mct.F90
        map_snoglc_mct.F90
        map_atmocn_mct.F90
        seq_domain_mct.F90
        seq_rest_mod.F90
        mrg_x2l_mct.F90
        seq_frac_mct.F90
        shr_flux_mod.F90
        seq_flux_mct.F90
        map_lndlnd_mct.F90
        map_iceice_mct.F90
        map_glcglc_mct.F90
        lnd_comp_mct.F90
        ocn_types.F90
        ocn_comp.F90
        ocn_comp_mct.F90
        map_rofrof_mct.F90
        map_atmatm_mct.F90
        map_rofocn_mct.F90
        shr_mem_mod.F90
        map_snosno_mct.F90
        mrg_x2g_mct.F90
        mrg_x2i_mct.F90
        glc_comp_mct.F90
        ccsm_comp_mod.F90
        ccsm_driver.F90
        tp_core.F90
        sw_core.F90
        cd_core.F90
        cldsav.F90
        collective.c
        comm.c
        comspe.F90
        cpslec.F90
        d2a3dijk.F90
        d2a3dikj.F90
        dadadj.F90
        datetime.F90
        diag_dynvar_ic.F90
        mean_module.F90
        dryairm.F90
        dsd.f90
        mapz_module.F90
        epvd.F90
        esinti.F90
        f_wrappers.c
        fft99.F90
        fill_module.F90
        fort.F90
        gases.f90
        gauaw_mod.F90
        geopk.F90
        get_zeits.c
        gffgch.F90
        gptl.c
        gptl_papi.c
        group.c
        handles.c
        hirsbtpar.f90
        hirsbt.f90
        icarus.F90
        initcom.F90
        initindx.F90
        intp_util.F90
        iop_surf.F90
        lidar_simulator.F90
        list.c
        load_hydrometeor_classes.f90
        m_AccumulatorComms.F90
        m_AttrVectReduce.F90
        m_StrTemplate.F90
        m_FileResolv.F90
        m_Filename.F90
        m_Merge.F90
        m_SpatialIntegralV.F90
        m_SpatialIntegral.F90
        m_zeit.F90
        marsaglia.F90
        mcshallow.F90
        pio_quicksort.F90
        mct_rearrange.F90
        miesubs.F90
        mo_msis_ubc.F90
        mo_regrider.F90
        mo_solar_parms.F90
        mpi.c
        msise00.F90
        p_d_adjust.F90
        pack.c
        par_vecsum.F90
        par_xsum.F90
        pf_to_mr.F90
        pio_msg_callbacks.F90
        pio_msg_getput_callbacks.F90
        pio_nf_utils.F90
        pkez.F90
        prec_scops.F90
        puminterfaces.F90
        qneg3.F90
        qneg4.F90
        radar_simulator.f90
        recv.c
        redistributemodule.F90
        req.c
        scops.F90
        send.c
        sgexx.F90
        shr_jlcp.c
        shr_msg_mod.F90
        shr_vmath_fwrap.c
        shr_vmath_mod.F90
        srchutil.F90
        srfxfer.F90
        sulchem.F90
        te_map.F90
        threadutil.c
        time.c
        topology.c
        tphysac.F90
        tphysbc.F90
        tphysidl.F90
        trac2d.F90
        trunc.F90
        tsinti.F90
        uv3s_update.F90
        virtem.F90
        vrtmap.F90
        wrap_mpi.F90
        wrf_error_fatal.F90
        wrf_message.F90
        zeff.f90
        zenith.F90
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
        netcdf/fort-v2compat.c
        netcdf/fort-var1io.c
        netcdf/fort-varaio.c
        netcdf/fort-vario.c
        netcdf/fort-varmio.c
        netcdf/fort-varsio.c
        netcdf/libvers.c
        netcdf/nc.c
        netcdf/ncx.c
        netcdf/posixio.c
        netcdf/putget.c
        netcdf/string.c
        netcdf/v1hpg.c
        netcdf/v2i.c
        netcdf/var.c
        netcdf/typeSizes.f90
        netcdf/netcdf.f90
        spec_qsort/spec_qsort.c
        )],
    'cam4_validate_527' => [ qw(
        validate-cam.f90
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
        netcdf/fort-v2compat.c
        netcdf/fort-var1io.c
        netcdf/fort-varaio.c
        netcdf/fort-vario.c
        netcdf/fort-varmio.c
        netcdf/fort-varsio.c
        netcdf/libvers.c
        netcdf/nc.c
        netcdf/ncx.c
        netcdf/posixio.c
        netcdf/putget.c
        netcdf/string.c
        netcdf/v1hpg.c
        netcdf/v2i.c
        netcdf/var.c
        netcdf/typeSizes.f90
        netcdf/netcdf.f90
        spec_qsort/spec_qsort.c
        )],
);

# Setup for 227.ocam4
$sources{'openmp_cam4'} = $sources{'cam4_r'};
$sources{'cam4_validate_227'} = $sources{'cam4_validate_527'};
# Setup for 627.cam4_s
$sources{'cam4_s'} = $sources{'cam4_r'};
$sources{'cam4_validate_627'} = $sources{'cam4_validate_527'};

sub compare_commands {
    my ($me) = @_;
    my @rc;
    my ($comparefiles) = $me->compare_files_hash;
    my ($cam4_validate_exe) = (grep { /^cam4_validate/i } $me->exe_files);
    my $expected = $comparefiles->{'h0_ctrl.nc'} || "COULD_NOT_LOCATE_h0_ctrl.nc_FILE";

    push @rc, (
        {
            'command' => $cam4_validate_exe,
            'args'    => [ 10, 0.0035, $expected, 'h0.nc' ],
            'output'  => 'cam4_validate.txt',
            'error'   => "${cam4_validate_exe}.err",
        }
    );

    return @rc;
}

sub invoke {
    my ($me) = @_;
    my $name;
    my @rc;

    foreach my $exe (grep { !/^cam4_validate/i } $me->exe_files) {
        push @rc, (
            {
                'command' => $exe,
                'args'    => [ ],
                'output'  => "$exe.txt",
                'error'   => "$exe.err",
            }
        );
    }
    return @rc;
}


%deps = (

    'ESMF_BaseTimeMod.F90' => [
        'ESMF_BaseMod.F90',
    ],
    'ESMF_CalendarMod.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_BaseTimeMod.F90',
    ],
    'ESMF_TimeIntervalMod.F90' => [
        'ESMF_BaseTimeMod.F90',
        'ESMF_FractionMod.F90',
        'ESMF_BaseMod.F90',
        'ESMF_CalendarMod.F90',
    ],
    'ESMF_Stubs.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_CalendarMod.F90',
    ],
    'ESMF_TimeMod.F90' => [
        'ESMF_TimeIntervalMod.F90',
        'ESMF_BaseTimeMod.F90',
        'ESMF_BaseMod.F90',
        'ESMF_CalendarMod.F90',
        'ESMF_Stubs.F90',
    ],
    'ESMF_AlarmMod.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_TimeIntervalMod.F90',
        'ESMF_TimeMod.F90',
    ],
    'ESMF_ClockMod.F90' => [
        'ESMF_AlarmMod.F90',
        'ESMF_BaseMod.F90',
        'ESMF_TimeIntervalMod.F90',
        'ESMF_TimeMod.F90',
    ],
    'ESMF_AlarmClockMod.F90' => [
        'ESMF_AlarmMod.F90',
        'ESMF_ClockMod.F90',
        'ESMF_TimeIntervalMod.F90',
        'ESMF_TimeMod.F90',
    ],
    'ESMF_Mod.F90' => [
        'ESMF_TimeIntervalMod.F90',
        'ESMF_BaseTimeMod.F90',
        'ESMF_FractionMod.F90',
        'ESMF_TimeMod.F90',
        'ESMF_AlarmMod.F90',
        'ESMF_AlarmClockMod.F90',
        'ESMF_BaseMod.F90',
        'ESMF_ClockMod.F90',
        'ESMF_CalendarMod.F90',
        'ESMF_Stubs.F90',
    ],
    'debugutilitiesmodule.F90' => [
        'cam_logfile.F90',
    ],
    'decompmodule.F90' => [
        'cam_logfile.F90',
        'debugutilitiesmodule.F90',
    ],
    'ghostmodule.F90' => [
        'decompmodule.F90',
        'debugutilitiesmodule.F90',
    ],
    'shr_log_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'shr_mpi_mod.F90' => [
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
    ],
    'shr_sys_mod.F90' => [
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
        'shr_mpi_mod.F90',
    ],
    'shr_file_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
    ],
    'namelist_utils.F90' => [
        'string_utils.F90',
    ],
    'perf_mod.F90' => [
        'perf_utils.F90',
        'shr_sys_mod.F90',
        'shr_file_mod.F90',
        'shr_kind_mod.F90',
        'namelist_utils.F90',
        'shr_mpi_mod.F90',
    ],
    'mod_comm.F90' => [
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
    ],
    'parutilitiesmodule.F90' => [
        'decompmodule.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'ghostmodule.F90',
        'mod_comm.F90',
        'debugutilitiesmodule.F90',
    ],
    'abortutils.F90' => [
        'shr_sys_mod.F90',
        'cam_logfile.F90',
        'mpishorthand.F',
    ],
    'units.F90' => [
        'shr_file_mod.F90',
        'abortutils.F90',
    ],
    'spmd_utils.F90' => [
        'mpishorthand.F',
        'units.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
    ],
    'fv_control_mod.F90' => [
        'spmd_utils.F90',
        'abortutils.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'units.F90',
    ],
    'pft_module.F90' => [
        'fv_control_mod.F90',
        'shr_kind_mod.F90',
    ],
    'dynamics_vars.F90' => [
        'parutilitiesmodule.F90',
        'fv_control_mod.F90',
        'decompmodule.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'pft_module.F90',
        'cam_logfile.F90',
        'ghostmodule.F90',
        'mod_comm.F90',
    ],
    'FVperf_module.F90' => [
        'dynamics_vars.F90',
        'perf_mod.F90',
        'mod_comm.F90',
    ],
    'Meat.F90' => [
        'ESMF_TimeIntervalMod.F90',
        'ESMF_BaseTimeMod.F90',
        'ESMF_FractionMod.F90',
        'ESMF_TimeMod.F90',
        'ESMF_AlarmMod.F90',
        'ESMF_ClockMod.F90',
        'ESMF_BaseMod.F90',
        'ESMF_CalendarMod.F90',
    ],
    'pmgrid.F90' => [
        'decompmodule.F90',
        'shr_kind_mod.F90',
    ],
    'dycore.F90' => [
        'pmgrid.F90',
    ],
    'pio_kinds.F90' => [
        'netcdf/netcdf.f90',
    ],
    'pio_support.F90' => [
        'pio_kinds.F90',
    ],
    'pio_types.F90' => [
        'pio_kinds.F90',
    ],
    'pio_msg_mod.F90' => [
        'pio_support.F90',
        'pio_types.F90',
        'perf_mod.F90',
        'pio_kinds.F90',
    ],
    'alloc_mod.F90' => [
        'pio_kinds.F90',
        'pio_support.F90',
        'pio_types.F90',
    ],
    'pio_utils.F90' => [
        'pio_support.F90',
        'pio_types.F90',
        'pio_kinds.F90',
    ],
    'nf_mod.F90' => [
        'pio_msg_mod.F90',
        'alloc_mod.F90',
        'pio_support.F90',
        'perf_mod.F90',
        'pio_kinds.F90',
        'pio_utils.F90',
        'pio_types.F90',
    ],
    'pionfput_mod.F90' => [
        'pio_support.F90',
        'nf_mod.F90',
        'pio_types.F90',
        'pio_msg_mod.F90',
        'perf_mod.F90',
        'pio_kinds.F90',
        'pio_utils.F90',
    ],
    'pionfatt_mod.F90' => [
        'pio_support.F90',
        'pio_types.F90',
        'pio_msg_mod.F90',
        'pio_kinds.F90',
        'pio_utils.F90',
    ],
    'pio_spmd_utils.F90' => [
        'pio_support.F90',
        'pio_kinds.F90',
    ],
    'calcdisplace_mod.F90' => [
        'pio_support.F90',
        'pio_kinds.F90',
    ],
    'box_rearrange.F90' => [
        'pio_spmd_utils.F90',
        'alloc_mod.F90',
        'pio_support.F90',
        'calcdisplace_mod.F90',
        'pio_kinds.F90',
        'pio_types.F90',
    ],
    'rearrange.F90' => [
        'box_rearrange.F90',
        'pio_support.F90',
        'pio_types.F90',
        'perf_mod.F90',
        'pio_kinds.F90',
    ],
    'pionfread_mod.F90' => [
        'alloc_mod.F90',
        'pio_support.F90',
        'pio_types.F90',
        'perf_mod.F90',
        'pio_kinds.F90',
        'pio_utils.F90',
    ],
    'iompi_mod.F90' => [
        'alloc_mod.F90',
        'pio_support.F90',
        'perf_mod.F90',
        'pio_kinds.F90',
        'pio_types.F90',
    ],
    'pionfwrite_mod.F90' => [
        'alloc_mod.F90',
        'pio_support.F90',
        'nf_mod.F90',
        'pio_types.F90',
        'perf_mod.F90',
        'pio_kinds.F90',
        'pio_utils.F90',
    ],
    'piodarray.F90' => [
        'alloc_mod.F90',
        'pio_support.F90',
        'rearrange.F90',
        'pio_types.F90',
        'pio_msg_mod.F90',
        'pionfread_mod.F90',
        'perf_mod.F90',
        'iompi_mod.F90',
        'pio_kinds.F90',
        'pionfwrite_mod.F90',
    ],
    'ionf_mod.F90' => [
        'alloc_mod.F90',
        'pio_support.F90',
        'perf_mod.F90',
        'pio_kinds.F90',
        'pio_utils.F90',
        'pio_types.F90',
    ],
    'calcdecomp.F90' => [
        'pio_support.F90',
        'pio_kinds.F90',
        'pio_types.F90',
    ],
    'pio_mpi_utils.F90' => [
        'pio_support.F90',
        'pio_types.F90',
    ],
    'piolib_mod.F90' => [
        'alloc_mod.F90',
        'pio_support.F90',
        'rearrange.F90',
        'ionf_mod.F90',
        'calcdecomp.F90',
        'pio_types.F90',
        'pio_mpi_utils.F90',
        'pio_msg_mod.F90',
        'pionfread_mod.F90',
        'perf_mod.F90',
        'calcdisplace_mod.F90',
        'iompi_mod.F90',
        'pio_kinds.F90',
        'pionfwrite_mod.F90',
    ],
    'pionfget_mod.F90' => [
        'pio_support.F90',
        'pio_types.F90',
        'pio_msg_mod.F90',
        'perf_mod.F90',
        'pio_kinds.F90',
        'pio_utils.F90',
    ],
    'pio.F90' => [
        'pionfput_mod.F90',
        'pionfatt_mod.F90',
        'nf_mod.F90',
        'piodarray.F90',
        'piolib_mod.F90',
        'pio_types.F90',
        'pionfget_mod.F90',
        'pio_kinds.F90',
    ],
    'shr_timer_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
    ],
    'shr_string_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
        'shr_timer_mod.F90',
    ],
    'shr_const_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'shr_cal_mod.F90' => [
        'ESMF_Mod.F90',
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_string_mod.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
    ],
    'time_manager.F90' => [
        'spmd_utils.F90',
        'ESMF_Mod.F90',
        'dycore.F90',
        'mpishorthand.F',
        'pio.F90',
        'string_utils.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'shr_cal_mod.F90',
    ],
    'physconst.F90' => [
        'spmd_utils.F90',
        'abortutils.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'shr_const_mod.F90',
        'namelist_utils.F90',
        'ppgrid.F90',
        'units.F90',
    ],
    'constituents.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'commap.F90' => [
        'pmgrid.F90',
        'shr_kind_mod.F90',
    ],
    'infnan.F90' => [
        'shr_kind_mod.F90',
    ],
    'rgrid.F90' => [
        'infnan.F90',
        'pmgrid.F90',
        'pspect.F90',
    ],
    'spmd_dyn.F90' => [
        'spmd_utils.F90',
        'parutilitiesmodule.F90',
        'infnan.F90',
        'pmgrid.F90',
        'mpishorthand.F',
        'units.F90',
        'fv_control_mod.F90',
        'abortutils.F90',
        'decompmodule.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'ghostmodule.F90',
    ],
    'hycoef.F90' => [
        'pio.F90',
        'spmd_utils.F90',
        'abortutils.F90',
        'pmgrid.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'dyn_grid.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'commap.F90',
        'rgrid.F90',
        'spmd_dyn.F90',
        'abortutils.F90',
        'pmgrid.F90',
        'shr_kind_mod.F90',
        'hycoef.F90',
        'cam_logfile.F90',
        'shr_const_mod.F90',
    ],
    'm_flow.F90' => [
        'm_chars.F90',
    ],
    'm_mpif90.F90' => [
        'm_stdio.F90',
        'm_mpif.F90',
        'm_realkinds.F90',
    ],
    'm_dropdead.F90' => [
        'm_stdio.F90',
        'm_mpif90.F90',
    ],
    'm_ioutil.F90' => [
        'm_stdio.F90',
    ],
    'm_mpout.F90' => [
        'm_ioutil.F90',
        'm_dropdead.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
    ],
    'm_die.F90' => [
        'm_flow.F90',
        'm_dropdead.F90',
        'm_stdio.F90',
        'm_mpout.F90',
        'm_mpif90.F90',
    ],
    'm_MergeSorts.F90' => [
        'm_die.F90',
        'm_stdio.F90',
        'm_realkinds.F90',
    ],
    'phys_grid.F90' => [
        'dyn_grid.F90',
        'physconst.F90',
        'spmd_utils.F90',
        'spmd_dyn.F90',
        'abortutils.F90',
        'dycore.F90',
        'pmgrid.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'mod_comm.F90',
        'm_MergeSorts.F90',
    ],
    'ioFileMod.F90' => [
        'spmd_utils.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'cam_history_support.F90' => [
        'spmd_utils.F90',
        'pio.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'cam_control_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'm_mall.F90' => [
        'm_ioutil.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_chars.F90',
        'm_realkinds.F90',
    ],
    'm_String.F90' => [
        'm_mall.F90',
        'm_die.F90',
        'm_mpif90.F90',
    ],
    'm_rankMerge.F90' => [
        'm_realkinds.F90',
    ],
    'm_IndexBin_logical.F90' => [
        'm_die.F90',
        'm_stdio.F90',
    ],
    'm_Permuter.F90' => [
        'm_die.F90',
        'm_realkinds.F90',
    ],
    'm_IndexBin_char.F90' => [
        'm_die.F90',
        'm_stdio.F90',
    ],
    'm_IndexBin_integer.F90' => [
        'm_die.F90',
        'm_stdio.F90',
    ],
    'm_SortingTools.F90' => [
        'm_rankMerge.F90',
        'm_IndexBin_logical.F90',
        'm_Permuter.F90',
        'm_IndexBin_char.F90',
        'm_MergeSorts.F90',
        'm_IndexBin_integer.F90',
    ],
    'm_List.F90' => [
        'm_String.F90',
        'm_mall.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
    ],
    'm_TraceBack.F90' => [
        'm_String.F90',
        'm_die.F90',
        'm_stdio.F90',
    ],
    'm_AttrVect.F90' => [
        'm_String.F90',
        'm_SortingTools.F90',
        'm_List.F90',
        'm_mall.F90',
        'm_die.F90',
        'm_TraceBack.F90',
        'm_stdio.F90',
        'm_realkinds.F90',
    ],
    'm_GlobalMap.F90' => [
        'm_die.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
    ],
    'm_FcComms.F90' => [
        'm_die.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_MCTWorld.F90' => [
        'm_List.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
    ],
    'm_GlobalSegMap.F90' => [
        'm_SortingTools.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_FcComms.F90',
        'm_MCTWorld.F90',
        'm_mpif90.F90',
    ],
    'm_AttrVectComms.F90' => [
        'm_AttrVect.F90',
        'm_String.F90',
        'm_List.F90',
        'm_GlobalMap.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_FcComms.F90',
        'm_GlobalSegMap.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_SparseMatrix.F90' => [
        'm_AttrVect.F90',
        'm_String.F90',
        'm_List.F90',
        'm_die.F90',
        'm_TraceBack.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_SparseMatrixDecomp.F90' => [
        'm_AttrVect.F90',
        'm_List.F90',
        'm_GlobalMap.F90',
        'm_AttrVectComms.F90',
        'm_die.F90',
        'm_SparseMatrix.F90',
        'm_GlobalSegMap.F90',
    ],
    'm_SparseMatrixComms.F90' => [
        'm_List.F90',
        'm_GlobalMap.F90',
        'm_AttrVectComms.F90',
        'm_die.F90',
        'm_SparseMatrixDecomp.F90',
        'm_stdio.F90',
        'm_SparseMatrix.F90',
        'm_GlobalSegMap.F90',
        'm_mpif90.F90',
    ],
    'm_Navigator.F90' => [
        'm_mall.F90',
        'm_die.F90',
        'm_stdio.F90',
    ],
    'm_GlobalToLocal.F90' => [
        'm_GlobalMap.F90',
        'm_die.F90',
        'm_Navigator.F90',
        'm_stdio.F90',
        'm_SparseMatrix.F90',
        'm_GlobalSegMap.F90',
        'm_mpif90.F90',
    ],
    'm_SparseMatrixToMaps.F90' => [
        'm_List.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_SparseMatrix.F90',
        'm_GlobalSegMap.F90',
        'm_mpif90.F90',
    ],
    'm_ConvertMaps.F90' => [
        'm_SortingTools.F90',
        'm_GlobalMap.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_GlobalSegMap.F90',
        'm_MCTWorld.F90',
    ],
    'm_ExchangeMaps.F90' => [
        'm_GlobalMap.F90',
        'm_ConvertMaps.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_GlobalSegMap.F90',
        'm_MCTWorld.F90',
        'm_mpif90.F90',
    ],
    'm_Router.F90' => [
        'm_GlobalToLocal.F90',
        'm_ExchangeMaps.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_GlobalSegMap.F90',
        'm_MCTWorld.F90',
        'm_Permuter.F90',
        'm_MergeSorts.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_Rearranger.F90' => [
        'm_AttrVect.F90',
        'm_Router.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_GlobalSegMap.F90',
        'm_MCTWorld.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_SparseMatrixPlus.F90' => [
        'm_SparseMatrixComms.F90',
        'm_String.F90',
        'm_List.F90',
        'm_GlobalToLocal.F90',
        'm_SparseMatrixToMaps.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_SparseMatrix.F90',
        'm_GlobalSegMap.F90',
        'm_Rearranger.F90',
        'm_mpif90.F90',
    ],
    'm_GeneralGrid.F90' => [
        'm_AttrVect.F90',
        'm_String.F90',
        'm_List.F90',
        'm_die.F90',
        'm_TraceBack.F90',
        'm_stdio.F90',
        'm_realkinds.F90',
    ],
    'm_Transfer.F90' => [
        'm_AttrVect.F90',
        'm_Router.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_MCTWorld.F90',
        'm_mpif90.F90',
    ],
    'm_inpak90.F90' => [
        'm_ioutil.F90',
        'm_mall.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_GlobalSegMapComms.F90' => [
        'm_die.F90',
        'm_stdio.F90',
        'm_GlobalSegMap.F90',
        'm_MCTWorld.F90',
        'm_mpif90.F90',
    ],
    'm_Accumulator.F90' => [
        'm_AttrVect.F90',
        'm_String.F90',
        'm_List.F90',
        'm_mall.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_realkinds.F90',
    ],
    'm_MatAttrVectMul.F90' => [
        'm_AttrVect.F90',
        'm_SparseMatrixPlus.F90',
        'm_String.F90',
        'm_List.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_SparseMatrix.F90',
        'm_Rearranger.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_GeneralGridComms.F90' => [
        'm_List.F90',
        'm_GlobalMap.F90',
        'm_AttrVectComms.F90',
        'm_GeneralGrid.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_GlobalSegMap.F90',
        'm_MCTWorld.F90',
        'm_mpif90.F90',
    ],
    'mct_mod.F90' => [
        'm_AttrVect.F90',
        'm_SparseMatrixPlus.F90',
        'm_String.F90',
        'm_SparseMatrixComms.F90',
        'm_List.F90',
        'shr_sys_mod.F90',
        'm_AttrVectComms.F90',
        'm_GlobalToLocal.F90',
        'm_Router.F90',
        'm_GeneralGrid.F90',
        'm_SparseMatrixToMaps.F90',
        'm_die.F90',
        'm_Transfer.F90',
        'shr_kind_mod.F90',
        'm_stdio.F90',
        'm_SparseMatrix.F90',
        'm_Rearranger.F90',
        'm_GlobalSegMap.F90',
        'm_inpak90.F90',
        'shr_const_mod.F90',
        'm_GlobalSegMapComms.F90',
        'm_Accumulator.F90',
        'm_MatAttrVectMul.F90',
        'm_GeneralGridComms.F90',
        'shr_mpi_mod.F90',
        'm_MCTWorld.F90',
        'm_Permuter.F90',
        'shr_log_mod.F90',
        'm_MergeSorts.F90',
    ],
    'seq_comm_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'shr_file_mod.F90',
        'shr_mpi_mod.F90',
    ],
    'seq_drydep_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_file_mod.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
    ],
    'seq_flds_mod.F90' => [
        'shr_sys_mod.F90',
        'seq_drydep_mod.F90',
        'mct_mod.F90',
        'shr_string_mod.F90',
    ],
    'seq_io_mod.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'pio.F90',
        'shr_string_mod.F90',
        'shr_file_mod.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'shr_mpi_mod.F90',
        'seq_flds_mod.F90',
        'shr_cal_mod.F90',
    ],
    'cam_pio_utils.F90' => [
        'dyn_grid.F90',
        'spmd_utils.F90',
        'pio.F90',
        'cam_history_support.F90',
        'shr_string_mod.F90',
        'phys_grid.F90',
        'pio_support.F90',
        'abortutils.F90',
        'dycore.F90',
        'cam_control_mod.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'seq_io_mod.F90',
        'ppgrid.F90',
    ],
    'sat_hist.F90' => [
        'dyn_grid.F90',
        'spmd_utils.F90',
        'phys_grid.F90',
        'mpishorthand.F',
        'ioFileMod.F90',
        'ppgrid.F90',
        'cam_pio_utils.F90',
        'units.F90',
        'physconst.F90',
        'time_manager.F90',
        'pio.F90',
        'cam_history_support.F90',
        'string_utils.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'pionfwrite_mod.F90',
    ],
    'solar_data.F90' => [
        'spmd_utils.F90',
        'infnan.F90',
        'ioFileMod.F90',
        'units.F90',
        'cam_pio_utils.F90',
        'time_manager.F90',
        'physconst.F90',
        'pio.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
    ],
    'shr_orb_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
    ],
    'shr_tInterp_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_orb_mod.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'shr_cal_mod.F90',
    ],
    'shr_stream_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_string_mod.F90',
        'shr_file_mod.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'shr_const_mod.F90',
        'shr_mpi_mod.F90',
        'shr_cal_mod.F90',
    ],
    'shr_pcdf_mod.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'shr_log_mod.F90',
        'pio.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
    ],
    'shr_mct_mod.F90' => [
        'shr_pcdf_mod.F90',
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'shr_log_mod.F90',
        'pio.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'shr_mpi_mod.F90',
    ],
    'shr_map_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'shr_timer_mod.F90',
    ],
    'shr_ncread_mod.F90' => [
        'netcdf/netcdf.f90',
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_string_mod.F90',
        'shr_file_mod.F90',
        'shr_kind_mod.F90',
    ],
    'shr_dmodel_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_stream_mod.F90',
        'mct_mod.F90',
        'shr_log_mod.F90',
        'pio.F90',
        'shr_map_mod.F90',
        'shr_string_mod.F90',
        'shr_file_mod.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'shr_const_mod.F90',
        'shr_mpi_mod.F90',
        'seq_flds_mod.F90',
        'shr_ncread_mod.F90',
    ],
    'shr_strdata_mod.F90' => [
        'shr_tInterp_mod.F90',
        'shr_sys_mod.F90',
        'shr_stream_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'shr_log_mod.F90',
        'pio.F90',
        'shr_orb_mod.F90',
        'shr_map_mod.F90',
        'shr_string_mod.F90',
        'shr_file_mod.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'shr_const_mod.F90',
        'shr_mpi_mod.F90',
        'shr_dmodel_mod.F90',
        'shr_cal_mod.F90',
    ],
    'shr_scam_mod.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'shr_log_mod.F90',
        'pio.F90',
        'shr_strdata_mod.F90',
        'shr_file_mod.F90',
        'shr_kind_mod.F90',
        'shr_dmodel_mod.F90',
        'shr_ncread_mod.F90',
    ],
    'wrap_nf.F90' => [
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'scamMod.F90' => [
        'pmgrid.F90',
        'shr_scam_mod.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'wrap_nf.F90',
        'constituents.F90',
    ],
    'error_messages.F90' => [
        'netcdf/netcdf.f90',
        'abortutils.F90',
        'cam_logfile.F90',
    ],
    'interpolate_data.F90' => [
        'abortutils.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'geopotential.F90' => [
        'dycore.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'ref_pres.F90' => [
        'dyn_grid.F90',
        'ppgrid.F90',
        'shr_kind_mod.F90',
    ],
    'phys_control.F90' => [
        'spmd_utils.F90',
        'abortutils.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'ppgrid.F90',
        'units.F90',
    ],
    'physics_types.F90' => [
        'physconst.F90',
        'infnan.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'dycore.F90',
        'pmgrid.F90',
        'geopotential.F90',
        'scamMod.F90',
        'phys_control.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'shr_const_mod.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'time_utils.F90' => [
        'time_manager.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'repro_sum_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
    ],
    'phys_gmean.F90' => [
        'dyn_grid.F90',
        'physconst.F90',
        'spmd_utils.F90',
        'repro_sum_mod.F90',
        'rgrid.F90',
        'phys_grid.F90',
        'dycore.F90',
        'mpishorthand.F',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'mo_constants.F90' => [
        'physconst.F90',
        'shr_kind_mod.F90',
    ],
    'mo_flbc.F90' => [
        'time_manager.F90',
        'pio.F90',
        'spmd_utils.F90',
        'time_utils.F90',
        'commap.F90',
        'string_utils.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'interpolate_data.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'phys_gmean.F90',
        'ioFileMod.F90',
        'cam_logfile.F90',
        'mo_constants.F90',
        'ppgrid.F90',
        'm_types.F90',
        'constituents.F90',
        'cam_pio_utils.F90',
    ],
    'chem_surfvals.F90' => [
        'physconst.F90',
        'time_manager.F90',
        'spmd_utils.F90',
        'infnan.F90',
        'abortutils.F90',
        'error_messages.F90',
        'interpolate_data.F90',
        'mpishorthand.F',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'ioFileMod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'mo_flbc.F90',
        'ppgrid.F90',
        'm_types.F90',
        'constituents.F90',
        'units.F90',
    ],
    'cam_history_buffers.F90' => [
        'dyn_grid.F90',
        'physconst.F90',
        'time_manager.F90',
        'pio.F90',
        'cam_history_support.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_pio_utils.F90',
    ],
    'filenames.F90' => [
        'time_manager.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'cosp_share.F90' => [
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'interp_mod.F90' => [
        'pio.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
    ],
    'cam_history.F90' => [
        'physconst.F90',
        'time_manager.F90',
        'sat_hist.F90',
        'dyn_grid.F90',
        'pio.F90',
        'spmd_utils.F90',
        'cam_history_support.F90',
        'string_utils.F90',
        'solar_data.F90',
        'rgrid.F90',
        'shr_sys_mod.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'dycore.F90',
        'pmgrid.F90',
        'cam_control_mod.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
        'hycoef.F90',
        'perf_mod.F90',
        'ioFileMod.F90',
        'chem_surfvals.F90',
        'cam_logfile.F90',
        'cam_history_buffers.F90',
        'pspect.F90',
        'filenames.F90',
        'ppgrid.F90',
        'cosp_share.F90',
        'interp_mod.F90',
        'cam_pio_utils.F90',
        'units.F90',
    ],
    'advect_tend.F90' => [
        'time_manager.F90',
        'shr_kind_mod.F90',
        'dynamics_vars.F90',
        'constituents.F90',
        'cam_history.F90',
    ],
    'phys_buffer.F90' => [
        'dyn_grid.F90',
        'pio.F90',
        'spmd_utils.F90',
        'string_utils.F90',
        'infnan.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'cam_pio_utils.F90',
    ],
    'ghg_data.F90' => [
        'physconst.F90',
        'phys_buffer.F90',
        'abortutils.F90',
        'error_messages.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'chem_surfvals.F90',
        'ppgrid.F90',
    ],
    'radconstants.F90' => [
        'abortutils.F90',
        'shr_kind_mod.F90',
    ],
    'radae.F90' => [
        'spmd_utils.F90',
        'infnan.F90',
        'pmgrid.F90',
        'phys_control.F90',
        'ioFileMod.F90',
        'radconstants.F90',
        'ppgrid.F90',
        'cam_pio_utils.F90',
        'pio.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
        'filenames.F90',
    ],
    'quicksort.F90' => [
        'shr_kind_mod.F90',
    ],
    'radlw.F90' => [
        'radae.F90',
        'cam_history.F90',
        'phys_control.F90',
        'radconstants.F90',
        'quicksort.F90',
        'ppgrid.F90',
        'abortutils.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
    ],
    'pkg_cldoptics.F90' => [
        'phys_control.F90',
        'ppgrid.F90',
        'physconst.F90',
        'shr_kind_mod.F90',
    ],
    'phys_debug_util.F90' => [
        'spmd_utils.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'units.F90',
    ],
    'conv_water.F90' => [
        'physconst.F90',
        'phys_buffer.F90',
        'abortutils.F90',
        'cam_history.F90',
        'phys_control.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'phys_debug_util.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'param_cldoptics.F90' => [
        'physconst.F90',
        'pkg_cldoptics.F90',
        'phys_buffer.F90',
        'cam_history.F90',
        'conv_water.F90',
        'phys_control.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'mo_util.F90' => [
        'shr_kind_mod.F90',
    ],
    'rad_solar_var.F90' => [
        'solar_data.F90',
        'radconstants.F90',
        'mo_util.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
    ],
    'cmparray_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'radsw.F90' => [
        'rad_solar_var.F90',
        'solar_data.F90',
        'cam_history.F90',
        'cmparray_mod.F90',
        'phys_control.F90',
        'radconstants.F90',
        'quicksort.F90',
        'ppgrid.F90',
        'abortutils.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'phys_prop.F90' => [
        'spmd_utils.F90',
        'pio.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'ioFileMod.F90',
        'radconstants.F90',
        'cam_logfile.F90',
        'cam_pio_utils.F90',
    ],
    'rad_constituents.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'cam_history.F90',
        'mpishorthand.F',
        'radconstants.F90',
        'ppgrid.F90',
        'units.F90',
        'physconst.F90',
        'phys_prop.F90',
        'abortutils.F90',
        'error_messages.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'constituents.F90',
    ],
    'wv_saturation.F90' => [
        'spmd_utils.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'modal_aer_opt.F90' => [
        'physconst.F90',
        'pio.F90',
        'spmd_utils.F90',
        'cam_history_support.F90',
        'phys_buffer.F90',
        'abortutils.F90',
        'cam_history.F90',
        'mpishorthand.F',
        'phys_control.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'ioFileMod.F90',
        'radconstants.F90',
        'cam_logfile.F90',
        'rad_constituents.F90',
        'namelist_utils.F90',
        'ppgrid.F90',
        'constituents.F90',
        'units.F90',
        'cam_pio_utils.F90',
    ],
    'aer_rad_props.F90' => [
        'physconst.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_history_support.F90',
        'radconstants.F90',
        'phys_buffer.F90',
        'rad_constituents.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'constituents.F90',
        'abortutils.F90',
        'cam_history.F90',
        'modal_aer_opt.F90',
        'phys_control.F90',
    ],
    'camsrfexch_types.F90' => [
        'infnan.F90',
        'phys_grid.F90',
        'seq_drydep_mod.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'radiation_data.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'cam_history.F90',
        'phys_control.F90',
        'mpishorthand.F',
        'ppgrid.F90',
        'units.F90',
        'cam_history_support.F90',
        'abortutils.F90',
        'camsrfexch_types.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'rad_constituents.F90',
        'namelist_utils.F90',
        'constituents.F90',
    ],
    'cosp_utils.F90' => [
        'cosp_constants.F90',
    ],
    'cosp_types.F90' => [
        'cosp_constants.F90',
        'cosp_utils.F90',
        'radar_simulator_types.f90',
    ],
    'modis_simulator.F90' => [
        'cosp_constants.F90',
        'abortutils.F90',
    ],
    'cosp_modis_simulator.F90' => [
        'cosp_constants.F90',
        'cosp_types.F90',
        'modis_simulator.F90',
    ],
    'cosp_lidar.F90' => [
        'cosp_constants.F90',
        'cosp_types.F90',
    ],
    'cosp_misr_simulator.F90' => [
        'cosp_constants.F90',
        'cosp_types.F90',
    ],
    'llnl_stats.F90' => [
        'cosp_constants.F90',
    ],
    'lmd_ipsl_stats.F90' => [
        'llnl_stats.F90',
    ],
    'cosp_stats.F90' => [
        'cosp_constants.F90',
        'cosp_types.F90',
        'lmd_ipsl_stats.F90',
        'llnl_stats.F90',
    ],
    'array_lib.f90' => [
        'mrgrnk.f90',
    ],
    'format_input.f90' => [
        'array_lib.f90',
    ],
    'math_lib.f90' => [
        'mrgrnk.f90',
        'array_lib.f90',
    ],
    'cosp_radar.F90' => [
        'cosp_constants.F90',
        'atmos_lib.f90',
        'cosp_types.F90',
        'cosp_utils.F90',
        'mrgrnk.f90',
        'format_input.f90',
        'radar_simulator_types.f90',
        'array_lib.f90',
        'math_lib.f90',
        'optics_lib.f90',
    ],
    'cosp_isccp_simulator.F90' => [
        'cosp_constants.F90',
        'cosp_types.F90',
    ],
    'cosp_simulator.F90' => [
        'cosp_lidar.F90',
        'cosp_types.F90',
        'cosp_misr_simulator.F90',
        'cosp_stats.F90',
        'cosp_radar.F90',
        'cosp_modis_simulator.F90',
        'cosp_isccp_simulator.F90',
    ],
    'cosp.F90' => [
        'cosp_types.F90',
        'cosp_simulator.F90',
        'cosp_modis_simulator.F90',
    ],
    'cospsimulator_intr.F90' => [
        'time_manager.F90',
        'physconst.F90',
        'spmd_utils.F90',
        'cosp_constants.F90',
        'cosp_types.F90',
        'cam_history_support.F90',
        'phys_buffer.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'cam_history.F90',
        'cmparray_mod.F90',
        'error_messages.F90',
        'interpolate_data.F90',
        'camsrfexch_types.F90',
        'mpishorthand.F',
        'phys_control.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'rad_constituents.F90',
        'namelist_utils.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'cosp_share.F90',
        'cosp_modis_simulator.F90',
        'constituents.F90',
        'units.F90',
        'cam_pio_utils.F90',
        'cosp.F90',
    ],
    'chemistry.F90' => [
        'pio.F90',
        'phys_buffer.F90',
        'camsrfexch_types.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
    ],
    'radheat.F90' => [
        'phys_buffer.F90',
        'pmgrid.F90',
        'chemistry.F90',
        'ppgrid.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
    ],
    'radiation.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'radae.F90',
        'phys_grid.F90',
        'cam_history.F90',
        'interpolate_data.F90',
        'phys_control.F90',
        'radconstants.F90',
        'pspect.F90',
        'radlw.F90',
        'param_cldoptics.F90',
        'ppgrid.F90',
        'radsw.F90',
        'time_manager.F90',
        'physconst.F90',
        'shr_orb_mod.F90',
        'cam_history_support.F90',
        'aer_rad_props.F90',
        'abortutils.F90',
        'error_messages.F90',
        'camsrfexch_types.F90',
        'cam_control_mod.F90',
        'scamMod.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'rad_constituents.F90',
        'radiation_data.F90',
        'cospsimulator_intr.F90',
        'cosp_share.F90',
        'radheat.F90',
    ],
    'horizontal_interpolate.F90' => [
        'abortutils.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'shr_const_mod.F90',
    ],
    'polar_avg.F90' => [
        'dyn_grid.F90',
        'repro_sum_mod.F90',
        'phys_grid.F90',
        'dycore.F90',
        'mpishorthand.F',
        'ppgrid.F90',
        'shr_kind_mod.F90',
    ],
    'tracer_data.F90' => [
        'dyn_grid.F90',
        'spmd_utils.F90',
        'horizontal_interpolate.F90',
        'phys_buffer.F90',
        'shr_sys_mod.F90',
        'phys_grid.F90',
        'dycore.F90',
        'interpolate_data.F90',
        'mpishorthand.F',
        'ioFileMod.F90',
        'mo_constants.F90',
        'ppgrid.F90',
        'polar_avg.F90',
        'cam_pio_utils.F90',
        'physconst.F90',
        'time_manager.F90',
        'pio.F90',
        'string_utils.F90',
        'mo_util.F90',
        'shr_file_mod.F90',
        'abortutils.F90',
        'cam_control_mod.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
    ],
    'prescribed_ghg.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'cam_history.F90',
        'mpishorthand.F',
        'ppgrid.F90',
        'tracer_data.F90',
        'units.F90',
        'physconst.F90',
        'pio.F90',
        'string_utils.F90',
        'abortutils.F90',
        'error_messages.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
    ],
    'prescribed_aero.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'cam_history.F90',
        'mpishorthand.F',
        'ppgrid.F90',
        'tracer_data.F90',
        'units.F90',
        'pio.F90',
        'string_utils.F90',
        'abortutils.F90',
        'error_messages.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
    ],
    'trb_mtn_stress.F90' => [
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'phys_debug.F90' => [
        'camsrfexch_types.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'phys_debug_util.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'hb_diff.F90' => [
        'spmd_utils.F90',
        'phys_debug.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'upper_bc.F90' => [
        'physics_types.F90',
        'shr_kind_mod.F90',
    ],
    'molec_diff.F90' => [
        'physconst.F90',
        'infnan.F90',
        'abortutils.F90',
        'phys_control.F90',
        'physics_types.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'upper_bc.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'diffusion_solver.F90' => [
        'time_manager.F90',
        'phys_control.F90',
        'phys_debug_util.F90',
        'cam_logfile.F90',
    ],
    'eddy_diff.F90' => [
        'physconst.F90',
        'time_manager.F90',
        'abortutils.F90',
        'cam_history.F90',
        'phys_control.F90',
        'phys_debug_util.F90',
        'cam_logfile.F90',
        'diffusion_solver.F90',
        'ppgrid.F90',
    ],
    'vertical_diffusion.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'infnan.F90',
        'cam_history.F90',
        'phys_control.F90',
        'trb_mtn_stress.F90',
        'ppgrid.F90',
        'hb_diff.F90',
        'time_manager.F90',
        'physconst.F90',
        'molec_diff.F90',
        'abortutils.F90',
        'geopotential.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
        'wv_saturation.F90',
        'diffusion_solver.F90',
        'eddy_diff.F90',
        'constituents.F90',
    ],
    'boundarydata.F90' => [
        'time_manager.F90',
        'physconst.F90',
        'spmd_utils.F90',
        'infnan.F90',
        'abortutils.F90',
        'error_messages.F90',
        'interpolate_data.F90',
        'mpishorthand.F',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'ioFileMod.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
    ],
    'cam3_ozone_data.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'boundarydata.F90',
        'phys_buffer.F90',
        'abortutils.F90',
        'cam_history.F90',
        'mpishorthand.F',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'ppgrid.F90',
        'units.F90',
    ],
    'aoa_tracers.F90' => [
        'dyn_grid.F90',
        'time_manager.F90',
        'physconst.F90',
        'physics_types.F90',
        'spmd_utils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'phys_grid.F90',
        'ppgrid.F90',
        'abortutils.F90',
        'constituents.F90',
        'cam_history.F90',
        'dycore.F90',
        'units.F90',
        'mpishorthand.F',
    ],
    'iondrag.F90' => [
        'phys_buffer.F90',
        'abortutils.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'cam3_aero_data.F90' => [
        'physconst.F90',
        'time_manager.F90',
        'spmd_utils.F90',
        'boundarydata.F90',
        'phys_buffer.F90',
        'infnan.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'error_messages.F90',
        'interpolate_data.F90',
        'mpishorthand.F',
        'scamMod.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'ioFileMod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'ppgrid.F90',
        'shr_scam_mod.F90',
        'units.F90',
    ],
    'tracers_suite.F90' => [
        'ppgrid.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
    ],
    'tracers.F90' => [
        'cam_history.F90',
        'ppgrid.F90',
        'physconst.F90',
        'tracers_suite.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'constituents.F90',
    ],
    'tropopause.F90' => [
        'dyn_grid.F90',
        'spmd_utils.F90',
        'phys_grid.F90',
        'cam_history.F90',
        'interpolate_data.F90',
        'mpishorthand.F',
        'ioFileMod.F90',
        'ppgrid.F90',
        'cam_pio_utils.F90',
        'units.F90',
        'time_manager.F90',
        'physconst.F90',
        'pio.F90',
        'cam_history_support.F90',
        'abortutils.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
    ],
    'prescribed_volcaero.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'cam_history.F90',
        'mpishorthand.F',
        'ppgrid.F90',
        'tracer_data.F90',
        'units.F90',
        'physconst.F90',
        'pio.F90',
        'tropopause.F90',
        'string_utils.F90',
        'abortutils.F90',
        'error_messages.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
    ],
    'prescribed_ozone.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'cam_history.F90',
        'phys_control.F90',
        'mpishorthand.F',
        'ppgrid.F90',
        'tracer_data.F90',
        'units.F90',
        'physconst.F90',
        'pio.F90',
        'string_utils.F90',
        'abortutils.F90',
        'error_messages.F90',
        'cam_control_mod.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
    ],
    'aircraft_emit.F90' => [
        'physconst.F90',
        'physics_types.F90',
        'spmd_utils.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'phys_buffer.F90',
        'cam_logfile.F90',
        'string_utils.F90',
        'namelist_utils.F90',
        'phys_grid.F90',
        'ppgrid.F90',
        'tracer_data.F90',
        'constituents.F90',
        'abortutils.F90',
        'cam_history.F90',
        'units.F90',
        'mpishorthand.F',
    ],
    'modal_aero_deposition.F90' => [
        'abortutils.F90',
        'camsrfexch_types.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'aerodep_flx.F90' => [
        'physics_types.F90',
        'spmd_utils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'ppgrid.F90',
        'modal_aero_deposition.F90',
        'tracer_data.F90',
        'abortutils.F90',
        'cam_history.F90',
        'camsrfexch_types.F90',
        'units.F90',
        'mpishorthand.F',
    ],
    'advnce.F90' => [
        'ghg_data.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'radiation.F90',
        'chemistry.F90',
        'perf_mod.F90',
        'prescribed_ghg.F90',
        'chem_surfvals.F90',
        'prescribed_aero.F90',
        'phys_buffer.F90',
        'vertical_diffusion.F90',
        'cam3_ozone_data.F90',
        'solar_data.F90',
        'aoa_tracers.F90',
        'iondrag.F90',
        'cam3_aero_data.F90',
        'ppgrid.F90',
        'tracers.F90',
        'prescribed_volcaero.F90',
        'prescribed_ozone.F90',
        'aircraft_emit.F90',
        'aerodep_flx.F90',
        'camsrfexch_types.F90',
        'radheat.F90',
    ],
    'drydep_mod.F90' => [
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'wetdep.F90' => [
        'phys_control.F90',
        'ppgrid.F90',
        'physconst.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'dust_sediment_mod.F90' => [
        'physconst.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
    ],
    'dust_intr.F90' => [
        'error_function.F90',
        'physconst.F90',
        'pio.F90',
        'spmd_utils.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'cam_history.F90',
        'interpolate_data.F90',
        'camsrfexch_types.F90',
        'phys_control.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'ioFileMod.F90',
        'drydep_mod.F90',
        'wetdep.F90',
        'cam_logfile.F90',
        'mo_constants.F90',
        'ppgrid.F90',
        'dust_sediment_mod.F90',
        'constituents.F90',
        'aerodep_flx.F90',
        'cam_pio_utils.F90',
    ],
    'progseasalts_intr.F90' => [
        'spmd_utils.F90',
        'phys_grid.F90',
        'cam_history.F90',
        'phys_control.F90',
        'drydep_mod.F90',
        'wetdep.F90',
        'mo_constants.F90',
        'ppgrid.F90',
        'dust_sediment_mod.F90',
        'time_manager.F90',
        'physconst.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'wv_saturation.F90',
        'constituents.F90',
    ],
    'scyc.F90' => [
        'cam_logfile.F90',
    ],
    'aerosol_intr.F90' => [
        'time_manager.F90',
        'physconst.F90',
        'physics_types.F90',
        'spmd_utils.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'dust_intr.F90',
        'drydep_mod.F90',
        'progseasalts_intr.F90',
        'wetdep.F90',
        'phys_buffer.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'phys_grid.F90',
        'ppgrid.F90',
        'abortutils.F90',
        'constituents.F90',
        'scyc.F90',
        'cam_history.F90',
        'units.F90',
        'camsrfexch_types.F90',
        'mpishorthand.F',
        'phys_control.F90',
    ],
    'history_scam.F90' => [
        'cam_history.F90',
        'pmgrid.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'xpavg_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'ncdio_atm.F90' => [
        'dyn_grid.F90',
        'spmd_utils.F90',
        'pio.F90',
        'string_utils.F90',
        'xpavg_mod.F90',
        'shr_sys_mod.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'dycore.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'shr_scam_mod.F90',
        'constituents.F90',
        'cam_pio_utils.F90',
    ],
    'metdata.F90' => [
        'time_manager.F90',
        'pio.F90',
        'spmd_utils.F90',
        'string_utils.F90',
        'shr_sys_mod.F90',
        'infnan.F90',
        'dynamics_vars.F90',
        'phys_grid.F90',
        'ncdio_atm.F90',
        'shr_file_mod.F90',
        'abortutils.F90',
        'cam_history.F90',
        'pmgrid.F90',
        'camsrfexch_types.F90',
        'cam_control_mod.F90',
        'mpishorthand.F',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'hycoef.F90',
        'perf_mod.F90',
        'ioFileMod.F90',
        'cam_logfile.F90',
        'shr_const_mod.F90',
        'ppgrid.F90',
        'mod_comm.F90',
        'shr_cal_mod.F90',
        'cam_pio_utils.F90',
    ],
    'co2_data_flux.F90' => [
        'time_manager.F90',
        'spmd_utils.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'error_messages.F90',
        'interpolate_data.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'ioFileMod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
    ],
    'co2_cycle.F90' => [
        'time_manager.F90',
        'physconst.F90',
        'spmd_utils.F90',
        'co2_data_flux.F90',
        'abortutils.F90',
        'cam_history.F90',
        'mpishorthand.F',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'chem_surfvals.F90',
        'namelist_utils.F90',
        'ppgrid.F90',
        'constituents.F90',
        'units.F90',
    ],
    'buffer.F90' => [
        'infnan.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'comsrf.F90' => [
        'infnan.F90',
        'abortutils.F90',
        'cam_control_mod.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'restart_physics.F90' => [
        'dyn_grid.F90',
        'spmd_utils.F90',
        'prescribed_ghg.F90',
        'phys_buffer.F90',
        'radae.F90',
        'phys_grid.F90',
        'chemistry.F90',
        'ioFileMod.F90',
        'ppgrid.F90',
        'prescribed_ozone.F90',
        'cam_pio_utils.F90',
        'units.F90',
        'pio.F90',
        'prescribed_aero.F90',
        'prescribed_volcaero.F90',
        'abortutils.F90',
        'co2_cycle.F90',
        'cam_control_mod.F90',
        'camsrfexch_types.F90',
        'shr_kind_mod.F90',
        'radiation.F90',
        'cam_logfile.F90',
        'cospsimulator_intr.F90',
        'buffer.F90',
        'comsrf.F90',
        'constituents.F90',
    ],
    'pfixer.F90' => [
        'time_manager.F90',
        'spmd_utils.F90',
        'parutilitiesmodule.F90',
        'commap.F90',
        'dynamics_vars.F90',
        'metdata.F90',
        'spmd_dyn.F90',
        'abortutils.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'hycoef.F90',
        'cam_logfile.F90',
        'mod_comm.F90',
    ],
    'ctem.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'parutilitiesmodule.F90',
        'dynamics_vars.F90',
        'abortutils.F90',
        'cam_history.F90',
        'pmgrid.F90',
        'interpolate_data.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'hycoef.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'units.F90',
    ],
    'diag_module.F90' => [
        'dynamics_vars.F90',
        'shr_kind_mod.F90',
        'mod_comm.F90',
    ],
    'dyn_comp.F90' => [
        'physconst.F90',
        'time_manager.F90',
        'spmd_utils.F90',
        'pio.F90',
        'parutilitiesmodule.F90',
        'infnan.F90',
        'fv_control_mod.F90',
        'dynamics_vars.F90',
        'metdata.F90',
        'spmd_dyn.F90',
        'pfixer.F90',
        'abortutils.F90',
        'cam_history.F90',
        'dycore.F90',
        'pmgrid.F90',
        'phys_control.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'hycoef.F90',
        'perf_mod.F90',
        'ctem.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'mod_comm.F90',
        'constituents.F90',
        'diag_module.F90',
    ],
    'dyn_internal_state.F90' => [
        'dynamics_vars.F90',
    ],
    'restart_dynamics.F90' => [
        'dyn_grid.F90',
        'dynamics_vars.F90',
        'pmgrid.F90',
        'hycoef.F90',
        'cam_pio_utils.F90',
        'time_manager.F90',
        'pio.F90',
        'fv_control_mod.F90',
        'metdata.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'dyn_comp.F90',
        'dyn_internal_state.F90',
        'constituents.F90',
    ],
    'cam_restart.F90' => [
        'time_manager.F90',
        'pio.F90',
        'spmd_utils.F90',
        'rgrid.F90',
        'infnan.F90',
        'restart_physics.F90',
        'phys_grid.F90',
        'spmd_dyn.F90',
        'abortutils.F90',
        'cam_history.F90',
        'dycore.F90',
        'pmgrid.F90',
        'camsrfexch_types.F90',
        'mpishorthand.F',
        'restart_dynamics.F90',
        'shr_kind_mod.F90',
        'radiation.F90',
        'ioFileMod.F90',
        'chem_surfvals.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
        'dyn_comp.F90',
        'filenames.F90',
        'ppgrid.F90',
        'cam_pio_utils.F90',
        'units.F90',
    ],
    'readinitial.F90' => [
        'pmgrid.F90',
        'pio.F90',
        'abortutils.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'history_defaults.F90' => [
        'cam_history.F90',
        'dycore.F90',
        'pmgrid.F90',
        'phys_control.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'uw_conv.F90' => [
        'error_function.F90',
        'abortutils.F90',
        'cam_logfile.F90',
    ],
    'uwshcu.F90' => [
        'spmd_utils.F90',
        'cam_history.F90',
        'mpishorthand.F',
        'ppgrid.F90',
        'units.F90',
        'abortutils.F90',
        'error_function.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'wv_saturation.F90',
        'constituents.F90',
    ],
    'cldwat.F90' => [
        'spmd_utils.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'dycore.F90',
        'pmgrid.F90',
        'cam_control_mod.F90',
        'phys_control.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'comsrf.F90',
        'units.F90',
    ],
    'zm_conv.F90' => [
        'spmd_utils.F90',
        'phys_grid.F90',
        'cldwat.F90',
        'dycore.F90',
        'phys_control.F90',
        'mpishorthand.F',
        'ppgrid.F90',
        'units.F90',
        'physconst.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'wv_saturation.F90',
        'constituents.F90',
    ],
    'hk_conv.F90' => [
        'spmd_utils.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'dycore.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'constituents.F90',
        'units.F90',
    ],
    'convect_shallow.F90' => [
        'time_manager.F90',
        'uw_conv.F90',
        'physconst.F90',
        'spmd_utils.F90',
        'uwshcu.F90',
        'phys_buffer.F90',
        'abortutils.F90',
        'cam_history.F90',
        'pmgrid.F90',
        'phys_control.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'zm_conv.F90',
        'hk_conv.F90',
        'cam_logfile.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'cloud_fraction.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'phys_buffer.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'dycore.F90',
        'phys_control.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'chemistry.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'units.F90',
    ],
    'cldwat2m_macro.F90' => [
        'physconst.F90',
        'time_manager.F90',
        'spmd_utils.F90',
        'abortutils.F90',
        'cam_history.F90',
        'shr_kind_mod.F90',
        'cloud_fraction.F90',
        'phys_debug_util.F90',
        'cam_logfile.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'ndrop.F90' => [
        'time_manager.F90',
        'physconst.F90',
        'phys_grid.F90',
        'error_function.F90',
        'abortutils.F90',
        'cam_history.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'cldwat2m_micro.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'cam_history.F90',
        'phys_control.F90',
        'shr_kind_mod.F90',
        'cldwat2m_macro.F90',
        'cam_logfile.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
    ],
    'microp_aero.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'error_function.F90',
        'abortutils.F90',
        'cam_history.F90',
        'phys_control.F90',
        'shr_kind_mod.F90',
        'cldwat2m_macro.F90',
        'cam_logfile.F90',
        'rad_constituents.F90',
        'ndrop.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'microp_driver.F90' => [
        'time_manager.F90',
        'physconst.F90',
        'phys_buffer.F90',
        'convect_shallow.F90',
        'abortutils.F90',
        'cam_history.F90',
        'cldwat.F90',
        'dycore.F90',
        'conv_water.F90',
        'phys_control.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cldwat2m_macro.F90',
        'phys_debug_util.F90',
        'cam_logfile.F90',
        'rad_constituents.F90',
        'ndrop.F90',
        'cldwat2m_micro.F90',
        'microp_aero.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'pkg_cld_sediment.F90' => [
        'spmd_utils.F90',
        'pkg_cldoptics.F90',
        'cldwat.F90',
        'mpishorthand.F',
        'ppgrid.F90',
        'units.F90',
        'physconst.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
    ],
    'stratiform.F90' => [
        'pkg_cldoptics.F90',
        'phys_buffer.F90',
        'convect_shallow.F90',
        'cldwat.F90',
        'cam_history.F90',
        'dycore.F90',
        'phys_control.F90',
        'chemistry.F90',
        'cldwat2m_macro.F90',
        'ppgrid.F90',
        'time_manager.F90',
        'physconst.F90',
        'pkg_cld_sediment.F90',
        'abortutils.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cloud_fraction.F90',
        'perf_mod.F90',
        'phys_debug_util.F90',
        'cam_logfile.F90',
        'cldwat2m_micro.F90',
        'microp_aero.F90',
        'constituents.F90',
    ],
    'inidat.F90' => [
        'dyn_grid.F90',
        'physconst.F90',
        'pio.F90',
        'spmd_utils.F90',
        'cam_history_support.F90',
        'commap.F90',
        'aoa_tracers.F90',
        'aerosol_intr.F90',
        'fv_control_mod.F90',
        'dynamics_vars.F90',
        'phys_grid.F90',
        'spmd_dyn.F90',
        'ncdio_atm.F90',
        'abortutils.F90',
        'pmgrid.F90',
        'co2_cycle.F90',
        'cam_control_mod.F90',
        'phys_control.F90',
        'mpishorthand.F',
        'microp_driver.F90',
        'shr_kind_mod.F90',
        'chemistry.F90',
        'cam_logfile.F90',
        'dyn_comp.F90',
        'dyn_internal_state.F90',
        'tracers.F90',
        'stratiform.F90',
        'constituents.F90',
        'mod_comm.F90',
    ],
    'startup_initialconds.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'radae.F90',
        'ioFileMod.F90',
        'readinitial.F90',
        'cam_pio_utils.F90',
        'pio.F90',
        'shr_kind_mod.F90',
        'history_defaults.F90',
        'dyn_comp.F90',
        'buffer.F90',
        'filenames.F90',
        'inidat.F90',
        'comsrf.F90',
    ],
    'inital.F90' => [
        'dynamics_vars.F90',
        'phys_grid.F90',
        'startup_initialconds.F90',
        'shr_kind_mod.F90',
        'chem_surfvals.F90',
        'ref_pres.F90',
        'dyn_comp.F90',
        'dyn_internal_state.F90',
    ],
    'check_energy.F90' => [
        'time_manager.F90',
        'physconst.F90',
        'spmd_utils.F90',
        'phys_buffer.F90',
        'abortutils.F90',
        'cam_history.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'phys_gmean.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'dp_coupling.F90' => [
        'physconst.F90',
        'phys_buffer.F90',
        'rgrid.F90',
        'dynamics_vars.F90',
        'metdata.F90',
        'phys_grid.F90',
        'spmd_dyn.F90',
        'abortutils.F90',
        'pmgrid.F90',
        'check_energy.F90',
        'geopotential.F90',
        'phys_control.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'ctem.F90',
        'cam_logfile.F90',
        'shr_const_mod.F90',
        'dyn_comp.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'fv_prints.F90' => [
        'parutilitiesmodule.F90',
        'repro_sum_mod.F90',
        'dynamics_vars.F90',
        'phys_grid.F90',
        'camsrfexch_types.F90',
        'mpishorthand.F',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'phys_gmean.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'stepon.F90' => [
        'spmd_utils.F90',
        'advect_tend.F90',
        'phys_buffer.F90',
        'shr_sys_mod.F90',
        'dynamics_vars.F90',
        'pmgrid.F90',
        'mpishorthand.F',
        'hycoef.F90',
        'ppgrid.F90',
        'time_manager.F90',
        'physconst.F90',
        'commap.F90',
        'fv_control_mod.F90',
        'abortutils.F90',
        'camsrfexch_types.F90',
        'cam_control_mod.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'dp_coupling.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'dyn_comp.F90',
        'dyn_internal_state.F90',
        'constituents.F90',
        'fv_prints.F90',
    ],
    'ionosphere.F90' => [
        'phys_buffer.F90',
        'abortutils.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
    ],
    'cloud_diagnostics.F90' => [
        'phys_buffer.F90',
        'physics_types.F90',
    ],
    'cloud_rad_props.F90' => [
        'phys_buffer.F90',
        'physics_types.F90',
        'radconstants.F90',
        'ppgrid.F90',
    ],
    'tidal_diag.F90' => [
        'cam_history.F90',
        'ppgrid.F90',
        'time_manager.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
    ],
    'constituent_burden.F90' => [
        'physconst.F90',
        'cam_history.F90',
        'shr_kind_mod.F90',
        'physics_types.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'cam_diagnostics.F90' => [
        'time_manager.F90',
        'physconst.F90',
        'tidal_diag.F90',
        'phys_buffer.F90',
        'infnan.F90',
        'abortutils.F90',
        'cam_history.F90',
        'dycore.F90',
        'check_energy.F90',
        'co2_cycle.F90',
        'constituent_burden.F90',
        'interpolate_data.F90',
        'cam_control_mod.F90',
        'camsrfexch_types.F90',
        'phys_control.F90',
        'scamMod.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'chemistry.F90',
        'buffer.F90',
        'wv_saturation.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'flux_avg.F90' => [
        'phys_buffer.F90',
        'phys_debug.F90',
        'phys_grid.F90',
        'camsrfexch_types.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'macrop_driver.F90' => [
        'time_manager.F90',
        'physconst.F90',
        'phys_buffer.F90',
        'convect_shallow.F90',
        'cldwat.F90',
        'cam_history.F90',
        'phys_control.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cloud_fraction.F90',
        'perf_mod.F90',
        'cldwat2m_macro.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'gw_drag.F90' => [
        'spmd_utils.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'cam_history.F90',
        'dycore.F90',
        'phys_control.F90',
        'mpishorthand.F',
        'scamMod.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'namelist_utils.F90',
        'ppgrid.F90',
        'units.F90',
    ],
    'zm_conv_intr.F90' => [
        'spmd_utils.F90',
        'phys_buffer.F90',
        'phys_grid.F90',
        'cam_history.F90',
        'pmgrid.F90',
        'phys_control.F90',
        'ppgrid.F90',
        'time_manager.F90',
        'physconst.F90',
        'check_energy.F90',
        'error_messages.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'zm_conv.F90',
        'cam_logfile.F90',
        'constituents.F90',
    ],
    'convect_deep.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'phys_buffer.F90',
        'abortutils.F90',
        'cam_history.F90',
        'pmgrid.F90',
        'phys_control.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'gw_drag.F90',
        'ppgrid.F90',
        'constituents.F90',
        'zm_conv_intr.F90',
    ],
    'rayleigh_friction.F90' => [
        'spmd_utils.F90',
        'ppgrid.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'majorsp_diffusion.F90' => [
        'abortutils.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'sslt_rebin.F90' => [
        'phys_buffer.F90',
        'cam_history.F90',
        'ppgrid.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'constituents.F90',
    ],
    'physpkg.F90' => [
        'spmd_utils.F90',
        'rad_solar_var.F90',
        'prescribed_ghg.F90',
        'phys_buffer.F90',
        'cam3_ozone_data.F90',
        'solar_data.F90',
        'aerosol_intr.F90',
        'infnan.F90',
        'convect_shallow.F90',
        'phys_grid.F90',
        'ionosphere.F90',
        'cloud_diagnostics.F90',
        'cloud_rad_props.F90',
        'cam_history.F90',
        'cam_diagnostics.F90',
        'cldwat.F90',
        'dycore.F90',
        'conv_water.F90',
        'mpishorthand.F',
        'phys_control.F90',
        'chemistry.F90',
        'flux_avg.F90',
        'ppgrid.F90',
        'prescribed_ozone.F90',
        'aircraft_emit.F90',
        'polar_avg.F90',
        'macrop_driver.F90',
        'time_manager.F90',
        'physconst.F90',
        'pio.F90',
        'prescribed_aero.F90',
        'tropopause.F90',
        'aer_rad_props.F90',
        'aoa_tracers.F90',
        'metdata.F90',
        'ncdio_atm.F90',
        'prescribed_volcaero.F90',
        'abortutils.F90',
        'convect_deep.F90',
        'rayleigh_friction.F90',
        'check_energy.F90',
        'co2_cycle.F90',
        'camsrfexch_types.F90',
        'cam_control_mod.F90',
        'startup_initialconds.F90',
        'scamMod.F90',
        'microp_driver.F90',
        'shr_kind_mod.F90',
        'physics_types.F90',
        'cloud_fraction.F90',
        'radiation.F90',
        'perf_mod.F90',
        'phys_gmean.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
        'phys_debug_util.F90',
        'vertical_diffusion.F90',
        'rad_constituents.F90',
        'gw_drag.F90',
        'buffer.F90',
        'iondrag.F90',
        'cam3_aero_data.F90',
        'majorsp_diffusion.F90',
        'tracers.F90',
        'comsrf.F90',
        'sslt_rebin.F90',
        'constituents.F90',
        'stratiform.F90',
        'aerodep_flx.F90',
        'radheat.F90',
    ],
    'cam_comp.F90' => [
        'time_manager.F90',
        'history_scam.F90',
        'spmd_utils.F90',
        'phys_buffer.F90',
        'infnan.F90',
        'shr_sys_mod.F90',
        'metdata.F90',
        'abortutils.F90',
        'cam_history.F90',
        'cam_restart.F90',
        'dycore.F90',
        'pmgrid.F90',
        'startup_initialconds.F90',
        'cam_control_mod.F90',
        'camsrfexch_types.F90',
        'mpishorthand.F',
        'scamMod.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'inital.F90',
        'history_defaults.F90',
        'stepon.F90',
        'cam_logfile.F90',
        'dyn_comp.F90',
        'ppgrid.F90',
        'physpkg.F90',
        'units.F90',
        'cam_pio_utils.F90',
    ],
    'seq_infodata_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_orb_mod.F90',
        'shr_string_mod.F90',
        'shr_file_mod.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_io_mod.F90',
        'shr_mpi_mod.F90',
    ],
    'seq_cdata_mod.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'runtime_opts.F90' => [
        'spmd_utils.F90',
        'uwshcu.F90',
        'prescribed_ghg.F90',
        'phys_buffer.F90',
        'repro_sum_mod.F90',
        'cam3_ozone_data.F90',
        'solar_data.F90',
        'phys_grid.F90',
        'cldwat.F90',
        'cam_restart.F90',
        'cam_diagnostics.F90',
        'cam_history.F90',
        'dycore.F90',
        'pmgrid.F90',
        'mpishorthand.F',
        'phys_control.F90',
        'chemistry.F90',
        'chem_surfvals.F90',
        'pspect.F90',
        'prescribed_ozone.F90',
        'aircraft_emit.F90',
        'units.F90',
        'sat_hist.F90',
        'physconst.F90',
        'time_manager.F90',
        'shr_string_mod.F90',
        'prescribed_aero.F90',
        'tropopause.F90',
        'pkg_cld_sediment.F90',
        'rgrid.F90',
        'aoa_tracers.F90',
        'metdata.F90',
        'prescribed_volcaero.F90',
        'abortutils.F90',
        'rayleigh_friction.F90',
        'check_energy.F90',
        'modal_aer_opt.F90',
        'co2_cycle.F90',
        'cam_control_mod.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
        'cloud_fraction.F90',
        'radiation.F90',
        'zm_conv.F90',
        'phys_debug_util.F90',
        'hk_conv.F90',
        'cam_logfile.F90',
        'radiation_data.F90',
        'rad_constituents.F90',
        'gw_drag.F90',
        'namelist_utils.F90',
        'cospsimulator_intr.F90',
        'iondrag.F90',
        'filenames.F90',
        'cam3_aero_data.F90',
        'tracers.F90',
        'constituents.F90',
        'aerodep_flx.F90',
        'radheat.F90',
    ],
    'cam_cpl_indices.F90' => [
        'seq_drydep_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
    ],
    'seq_timemgr_mod.F90' => [
        'ESMF_Mod.F90',
        'shr_sys_mod.F90',
        'shr_string_mod.F90',
        'shr_file_mod.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_io_mod.F90',
        'shr_mpi_mod.F90',
        'shr_cal_mod.F90',
    ],
    'atm_comp_mct.F90' => [
        'physconst.F90',
        'time_manager.F90',
        'dyn_grid.F90',
        'spmd_utils.F90',
        'pio.F90',
        'cam_comp.F90',
        'ESMF_Mod.F90',
        'dust_intr.F90',
        'shr_sys_mod.F90',
        'phys_grid.F90',
        'shr_file_mod.F90',
        'seq_drydep_mod.F90',
        'abortutils.F90',
        'cam_history.F90',
        'cam_restart.F90',
        'pmgrid.F90',
        'co2_cycle.F90',
        'camsrfexch_types.F90',
        'cam_control_mod.F90',
        'scamMod.F90',
        'phys_control.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'radiation.F90',
        'perf_mod.F90',
        'seq_cdata_mod.F90',
        'ioFileMod.F90',
        'cam_logfile.F90',
        'runtime_opts.F90',
        'shr_const_mod.F90',
        'filenames.F90',
        'ppgrid.F90',
        'cam_cpl_indices.F90',
        'constituents.F90',
        'mct_mod.F90',
        'seq_timemgr_mod.F90',
        'seq_flds_mod.F90',
        'seq_infodata_mod.F90',
        'cam_pio_utils.F90',
    ],
    'benergy.F90' => [
        'dynamics_vars.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'mod_comm.F90',
    ],
    'binary_io.F90' => [
        'spmd_utils.F90',
        'spmd_dyn.F90',
        'abortutils.F90',
        'pmgrid.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'bnddyi.F90' => [
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'seq_flds_indices.F90' => [
        'shr_sys_mod.F90',
        'seq_drydep_mod.F90',
        'mct_mod.F90',
        'shr_string_mod.F90',
        'seq_flds_mod.F90',
    ],
    'seq_diag_mct.F90' => [
        'ESMF_Mod.F90',
        'shr_sys_mod.F90',
        'seq_timemgr_mod.F90',
        'mct_mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'shr_const_mod.F90',
        'shr_mpi_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'seq_rearr_mod.F90' => [
        'shr_sys_mod.F90',
        'seq_diag_mct.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'seq_flds_mod.F90',
    ],
    'map_ocnocn_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
        'mct_mod.F90',
    ],
    'mrg_x2s_mct.F90' => [
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
    ],
    'ice_comp_mct.F90' => [
        'ESMF_Mod.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'mrg_x2o_mct.F90' => [
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'seq_avdata_mod.F90' => [
        'mct_mod.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'seq_hist_mod.F90' => [
        'ESMF_Mod.F90',
        'shr_sys_mod.F90',
        'seq_timemgr_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'seq_avdata_mod.F90',
        'seq_io_mod.F90',
        'seq_infodata_mod.F90',
        'shr_cal_mod.F90',
    ],
    'mrg_x2a_mct.F90' => [
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
    ],
    'map_iceocn_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
    ],
    'seq_map_mod.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
    ],
    'map_atmlnd_mct.F90' => [
        'seq_map_mod.F90',
        'shr_sys_mod.F90',
        'seq_flds_indices.F90',
        'm_die.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'shr_const_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'map_atmice_mct.F90' => [
        'seq_map_mod.F90',
        'shr_sys_mod.F90',
        'seq_flds_indices.F90',
        'm_die.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'map_snoglc_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
    ],
    'map_atmocn_mct.F90' => [
        'seq_map_mod.F90',
        'shr_sys_mod.F90',
        'seq_flds_indices.F90',
        'm_die.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'shr_const_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'seq_domain_mct.F90' => [
        'shr_sys_mod.F90',
        'map_iceocn_mct.F90',
        'map_atmlnd_mct.F90',
        'mct_mod.F90',
        'map_atmice_mct.F90',
        'seq_comm_mct.F90',
        'map_snoglc_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'map_atmocn_mct.F90',
        'shr_mpi_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'seq_rest_mod.F90' => [
        'ESMF_Mod.F90',
        'shr_sys_mod.F90',
        'seq_diag_mct.F90',
        'seq_timemgr_mod.F90',
        'mct_mod.F90',
        'shr_file_mod.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'seq_avdata_mod.F90',
        'seq_io_mod.F90',
        'shr_mpi_mod.F90',
        'seq_infodata_mod.F90',
        'shr_cal_mod.F90',
    ],
    'mrg_x2l_mct.F90' => [
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
    ],
    'seq_frac_mct.F90' => [
        'shr_sys_mod.F90',
        'map_iceocn_mct.F90',
        'map_atmlnd_mct.F90',
        'mct_mod.F90',
        'map_atmice_mct.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'map_atmocn_mct.F90',
        'shr_const_mod.F90',
    ],
    'shr_flux_mod.F90' => [
        'shr_sys_mod.F90',
        'phys_control.F90',
        'shr_log_mod.F90',
        'physconst.F90',
        'shr_kind_mod.F90',
    ],
    'seq_flux_mct.F90' => [
        'shr_sys_mod.F90',
        'shr_flux_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'shr_orb_mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'map_lndlnd_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
        'mct_mod.F90',
    ],
    'map_iceice_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
        'mct_mod.F90',
    ],
    'map_glcglc_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
        'mct_mod.F90',
    ],
    'lnd_comp_mct.F90' => [
        'ESMF_Mod.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'ocn_types.F90' => [
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'ocn_comp.F90' => [
        'physconst.F90',
        'phys_grid.F90',
        'ocn_types.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'ocn_comp_mct.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'ESMF_Mod.F90',
        'shr_sys_mod.F90',
        'phys_grid.F90',
        'ocn_types.F90',
        'seq_flds_indices.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'seq_cdata_mod.F90',
        'ppgrid.F90',
        'ocn_comp.F90',
        'seq_timemgr_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'map_rofrof_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
        'mct_mod.F90',
    ],
    'map_atmatm_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
        'mct_mod.F90',
    ],
    'map_rofocn_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_cdata_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'shr_mem_mod.F90' => [
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
    ],
    'map_snosno_mct.F90' => [
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
        'mct_mod.F90',
    ],
    'mrg_x2g_mct.F90' => [
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
    ],
    'mrg_x2i_mct.F90' => [
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'shr_kind_mod.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'glc_comp_mct.F90' => [
        'ESMF_Mod.F90',
        'seq_cdata_mod.F90',
        'mct_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'ccsm_comp_mod.F90' => [
        'map_ocnocn_mct.F90',
        'mrg_x2s_mct.F90',
        'ice_comp_mct.F90',
        'shr_orb_mod.F90',
        'mrg_x2o_mct.F90',
        'ESMF_Mod.F90',
        'shr_map_mod.F90',
        'seq_hist_mod.F90',
        'mrg_x2a_mct.F90',
        'atm_comp_mct.F90',
        'seq_domain_mct.F90',
        'map_atmice_mct.F90',
        'seq_rest_mod.F90',
        'shr_sys_mod.F90',
        'mrg_x2l_mct.F90',
        'seq_frac_mct.F90',
        'seq_diag_mct.F90',
        'shr_file_mod.F90',
        'seq_flds_indices.F90',
        'seq_flux_mct.F90',
        'map_lndlnd_mct.F90',
        'map_iceice_mct.F90',
        'map_iceocn_mct.F90',
        'map_glcglc_mct.F90',
        'lnd_comp_mct.F90',
        'seq_comm_mct.F90',
        'map_snoglc_mct.F90',
        'ocn_comp_mct.F90',
        'shr_kind_mod.F90',
        'map_rofrof_mct.F90',
        'map_atmlnd_mct.F90',
        'map_atmatm_mct.F90',
        'perf_mod.F90',
        'seq_cdata_mod.F90',
        'map_rofocn_mct.F90',
        'seq_avdata_mod.F90',
        'map_atmocn_mct.F90',
        'shr_mem_mod.F90',
        'shr_const_mod.F90',
        'seq_io_mod.F90',
        'shr_mpi_mod.F90',
        'shr_scam_mod.F90',
        'map_snosno_mct.F90',
        'mrg_x2g_mct.F90',
        'mrg_x2i_mct.F90',
        'seq_timemgr_mod.F90',
        'mct_mod.F90',
        'glc_comp_mct.F90',
        'seq_infodata_mod.F90',
        'shr_cal_mod.F90',
    ],
    'ccsm_driver.F90' => [
        'ESMF_Mod.F90',
        'shr_sys_mod.F90',
        'perf_mod.F90',
        'ccsm_comp_mod.F90',
    ],
    'tp_core.F90' => [
        'shr_kind_mod.F90',
    ],
    'sw_core.F90' => [
        'tp_core.F90',
        'dynamics_vars.F90',
        'shr_kind_mod.F90',
        'pft_module.F90',
    ],
    'cd_core.F90' => [
        'spmd_utils.F90',
        'sw_core.F90',
        'fv_control_mod.F90',
        'dynamics_vars.F90',
        'metdata.F90',
        'abortutils.F90',
        'mpishorthand.F',
        'shr_kind_mod.F90',
        'pft_module.F90',
        'cam_logfile.F90',
        'mod_comm.F90',
        'FVperf_module.F90',
    ],
    'cldsav.F90' => [
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'comspe.F90' => [
        'pmgrid.F90',
        'shr_kind_mod.F90',
        'pspect.F90',
    ],
    'cpslec.F90' => [
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'd2a3dijk.F90' => [
        'parutilitiesmodule.F90',
        'dynamics_vars.F90',
        'shr_kind_mod.F90',
        'mod_comm.F90',
    ],
    'd2a3dikj.F90' => [
        'parutilitiesmodule.F90',
        'repro_sum_mod.F90',
        'dynamics_vars.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'mod_comm.F90',
    ],
    'dadadj.F90' => [
        'physconst.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'cam_control_mod.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
    ],
    'diag_dynvar_ic.F90' => [
        'dynamics_vars.F90',
        'cam_history.F90',
        'shr_kind_mod.F90',
        'constituents.F90',
    ],
    'mean_module.F90' => [
        'parutilitiesmodule.F90',
        'commap.F90',
        'repro_sum_mod.F90',
        'dynamics_vars.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
    ],
    'dryairm.F90' => [
        'dynamics_vars.F90',
        'cam_control_mod.F90',
        'shr_kind_mod.F90',
        'mean_module.F90',
        'cam_logfile.F90',
        'constituents.F90',
    ],
    'dsd.f90' => [
        'array_lib.f90',
        'math_lib.f90',
    ],
    'mapz_module.F90' => [
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'FVperf_module.F90',
    ],
    'epvd.F90' => [
        'parutilitiesmodule.F90',
        'dynamics_vars.F90',
        'shr_kind_mod.F90',
        'mapz_module.F90',
        'mod_comm.F90',
    ],
    'esinti.F90' => [
        'shr_kind_mod.F90',
        'wv_saturation.F90',
    ],
    'fft99.F90' => [
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'fill_module.F90' => [
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'gauaw_mod.F90' => [
        'abortutils.F90',
        'shr_kind_mod.F90',
    ],
    'geopk.F90' => [
        'parutilitiesmodule.F90',
        'dynamics_vars.F90',
        'spmd_dyn.F90',
        'decompmodule.F90',
        'shr_kind_mod.F90',
        'mod_comm.F90',
    ],
    'gffgch.F90' => [
        'physconst.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'hirsbt.f90' => [
        'time_manager.F90',
        'physconst.F90',
        'hirsbtpar.f90',
        'shr_kind_mod.F90',
        'ppgrid.F90',
    ],
    'initcom.F90' => [
        'physconst.F90',
        'spmd_utils.F90',
        'commap.F90',
        'rgrid.F90',
        'abortutils.F90',
        'pmgrid.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'pspect.F90',
    ],
    'initindx.F90' => [
        'physconst.F90',
        'ghg_data.F90',
        'spmd_utils.F90',
        'prescribed_ghg.F90',
        'prescribed_aero.F90',
        'phys_buffer.F90',
        'cam3_ozone_data.F90',
        'string_utils.F90',
        'aoa_tracers.F90',
        'aerosol_intr.F90',
        'convect_shallow.F90',
        'ionosphere.F90',
        'prescribed_volcaero.F90',
        'convect_deep.F90',
        'cam_diagnostics.F90',
        'check_energy.F90',
        'co2_cycle.F90',
        'conv_water.F90',
        'cam_control_mod.F90',
        'phys_control.F90',
        'microp_driver.F90',
        'shr_kind_mod.F90',
        'radiation.F90',
        'chemistry.F90',
        'vertical_diffusion.F90',
        'gw_drag.F90',
        'iondrag.F90',
        'flux_avg.F90',
        'cam3_aero_data.F90',
        'tracers.F90',
        'sslt_rebin.F90',
        'prescribed_ozone.F90',
        'stratiform.F90',
        'constituents.F90',
        'aircraft_emit.F90',
        'macrop_driver.F90',
    ],
    'intp_util.F90' => [
        'phys_grid.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
    ],
    'iop_surf.F90' => [
        'physconst.F90',
        'camsrfexch_types.F90',
        'scamMod.F90',
        'ppgrid.F90',
    ],
    'load_hydrometeor_classes.f90' => [
        'radar_simulator_types.f90',
    ],
    'm_AccumulatorComms.F90' => [
        'm_AttrVect.F90',
        'm_GlobalMap.F90',
        'm_AttrVectComms.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_GlobalSegMap.F90',
        'm_Accumulator.F90',
        'm_mpif90.F90',
    ],
    'm_AttrVectReduce.F90' => [
        'm_AttrVect.F90',
        'm_List.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_StrTemplate.F90' => [
        'm_die.F90',
        'm_stdio.F90',
        'm_chars.F90',
    ],
    'm_FileResolv.F90' => [
        'm_StrTemplate.F90',
        'm_die.F90',
    ],
    'm_Merge.F90' => [
        'm_AttrVect.F90',
        'm_String.F90',
        'm_List.F90',
        'm_GeneralGrid.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_realkinds.F90',
    ],
    'm_SpatialIntegralV.F90' => [
        'm_AttrVect.F90',
        'm_List.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_AttrVectReduce.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_SpatialIntegral.F90' => [
        'm_AttrVect.F90',
        'm_SpatialIntegralV.F90',
        'm_String.F90',
        'm_List.F90',
        'm_GeneralGrid.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_AttrVectReduce.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_zeit.F90' => [
        'm_SortingTools.F90',
        'm_ioutil.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
    ],
    'marsaglia.F90' => [
        'shr_kind_mod.F90',
    ],
    'mcshallow.F90' => [
        'error_function.F90',
        'cam_history.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
    ],
    'pio_quicksort.F90' => [
        'pio_kinds.F90',
    ],
    'mct_rearrange.F90' => [
        'm_AttrVect.F90',
        'alloc_mod.F90',
        'pio_support.F90',
        'm_Rearranger.F90',
        'm_GlobalSegMap.F90',
        'pio_quicksort.F90',
        'pio_kinds.F90',
        'm_MCTWorld.F90',
        'pio_types.F90',
    ],
    'mo_msis_ubc.F90' => [
        'physconst.F90',
        'time_manager.F90',
        'spmd_utils.F90',
        'phys_grid.F90',
        'abortutils.F90',
        'pmgrid.F90',
        'shr_kind_mod.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
        'constituents.F90',
    ],
    'mo_regrider.F90' => [
        'abortutils.F90',
        'dycore.F90',
        'scamMod.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'ppgrid.F90',
    ],
    'mo_solar_parms.F90' => [
        'time_manager.F90',
        'pio.F90',
        'spmd_utils.F90',
        'time_utils.F90',
        'abortutils.F90',
        'error_messages.F90',
        'shr_kind_mod.F90',
        'ioFileMod.F90',
        'cam_logfile.F90',
        'cam_pio_utils.F90',
    ],
    'msise00.F90' => [
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'p_d_adjust.F90' => [
        'parutilitiesmodule.F90',
        'repro_sum_mod.F90',
        'dynamics_vars.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
    ],
    'par_vecsum.F90' => [
        'parutilitiesmodule.F90',
        'shr_kind_mod.F90',
    ],
    'par_xsum.F90' => [
        'parutilitiesmodule.F90',
        'repro_sum_mod.F90',
        'dynamics_vars.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'FVperf_module.F90',
    ],
    'pio_msg_callbacks.F90' => [
        'pio_support.F90',
        'piolib_mod.F90',
        'pio.F90',
        'pio_msg_mod.F90',
        'pio_kinds.F90',
    ],
    'pio_msg_getput_callbacks.F90' => [
        'pio_support.F90',
        'pio.F90',
        'pio_msg_mod.F90',
        'pio_kinds.F90',
    ],
    'pio_nf_utils.F90' => [
        'pio_support.F90',
        'pionfput_mod.F90',
        'nf_mod.F90',
        'pio_types.F90',
        'pionfget_mod.F90',
        'pio_kinds.F90',
    ],
    'pkez.F90' => [
        'shr_kind_mod.F90',
    ],
    'puminterfaces.F90' => [
        'parutilitiesmodule.F90',
        'decompmodule.F90',
        'shr_kind_mod.F90',
    ],
    'qneg3.F90' => [
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'qneg4.F90' => [
        'phys_grid.F90',
        'ppgrid.F90',
        'physconst.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
        'constituents.F90',
    ],
    'radar_simulator.f90' => [
        'mrgrnk.f90',
        'radar_simulator_types.f90',
        'array_lib.f90',
        'math_lib.f90',
        'optics_lib.f90',
    ],
    'redistributemodule.F90' => [
        'parutilitiesmodule.F90',
        'decompmodule.F90',
        'shr_kind_mod.F90',
        'debugutilitiesmodule.F90',
    ],
    'sgexx.F90' => [
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'shr_infnan_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'shr_msg_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_file_mod.F90',
    ],
    'shr_vmath_mod.F90' => [
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
    ],
    'srchutil.F90' => [
        'shr_kind_mod.F90',
    ],
    'srfxfer.F90' => [
        'cam_history.F90',
        'chem_surfvals.F90',
        'ppgrid.F90',
        'physconst.F90',
        'co2_cycle.F90',
        'cam_control_mod.F90',
        'camsrfexch_types.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'comsrf.F90',
        'constituents.F90',
    ],
    'sulchem.F90' => [
        'cam_history.F90',
        'ppgrid.F90',
        'physconst.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
    ],
    'te_map.F90' => [
        'dynamics_vars.F90',
        'phys_control.F90',
        'shr_kind_mod.F90',
        'mapz_module.F90',
        'cam_logfile.F90',
        'mod_comm.F90',
    ],
    'tphysac.F90' => [
        'phys_buffer.F90',
        'aerosol_intr.F90',
        'ionosphere.F90',
        'cam_diagnostics.F90',
        'dycore.F90',
        'phys_control.F90',
        'chemistry.F90',
        'flux_avg.F90',
        'ppgrid.F90',
        'time_manager.F90',
        'physconst.F90',
        'aoa_tracers.F90',
        'abortutils.F90',
        'rayleigh_friction.F90',
        'check_energy.F90',
        'cam_control_mod.F90',
        'camsrfexch_types.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
        'vertical_diffusion.F90',
        'gw_drag.F90',
        'iondrag.F90',
        'majorsp_diffusion.F90',
        'tracers.F90',
        'constituents.F90',
    ],
    'tphysbc.F90' => [
        'phys_buffer.F90',
        'aerosol_intr.F90',
        'convect_shallow.F90',
        'cloud_diagnostics.F90',
        'cam_history.F90',
        'cam_diagnostics.F90',
        'dycore.F90',
        'phys_control.F90',
        'ppgrid.F90',
        'macrop_driver.F90',
        'time_manager.F90',
        'physconst.F90',
        'tropopause.F90',
        'convect_deep.F90',
        'check_energy.F90',
        'camsrfexch_types.F90',
        'microp_driver.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'radiation.F90',
        'perf_mod.F90',
        'sslt_rebin.F90',
        'constituents.F90',
        'stratiform.F90',
    ],
    'tphysidl.F90' => [
        'phys_grid.F90',
        'cam_history.F90',
        'ppgrid.F90',
        'time_manager.F90',
        'physconst.F90',
        'abortutils.F90',
        'check_energy.F90',
        'physics_types.F90',
        'shr_kind_mod.F90',
        'ref_pres.F90',
        'cam_logfile.F90',
    ],
    'trac2d.F90' => [
        'parutilitiesmodule.F90',
        'tp_core.F90',
        'dynamics_vars.F90',
        'FVperf_module.F90',
        'fill_module.F90',
        'shr_kind_mod.F90',
        'mod_comm.F90',
    ],
    'tsinti.F90' => [
        'cam_control_mod.F90',
        'shr_kind_mod.F90',
    ],
    'uv3s_update.F90' => [
        'parutilitiesmodule.F90',
        'dynamics_vars.F90',
        'cam_history.F90',
        'shr_kind_mod.F90',
        'mod_comm.F90',
    ],
    'virtem.F90' => [
        'shr_kind_mod.F90',
    ],
    'vrtmap.F90' => [
        'srchutil.F90',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'cam_logfile.F90',
    ],
    'wrap_mpi.F90' => [
        'mpishorthand.F',
        'abortutils.F90',
        'shr_kind_mod.F90',
        'perf_mod.F90',
        'cam_logfile.F90',
    ],
    'wrf_error_fatal.F90' => [
        'shr_sys_mod.F90',
    ],
    'zeff.f90' => [
        'math_lib.f90',
        'optics_lib.f90',
    ],
    'zenith.F90' => [
        'shr_orb_mod.F90',
        'cam_control_mod.F90',
        'shr_kind_mod.F90',
    ],

    'netcdf/netcdf.f90' => [
        'netcdf/typeSizes.f90',
    ],
    'netcdf/netcdf_test.f90' => [
        'netcdf/netcdf.f90',
        'netcdf/typeSizes.f90',
    ],
    'validate-cam.f90' => [
        'netcdf/netcdf.f90',
    ],

);

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
