$benchnum  = '628';
$benchname = 'pop2_s';
$exename   = 'speed_pop2';
$benchlang = 'F,C';
@base_exe  = ($exename);
use Config;

my $common_flags   = ' -I. -Inetcdf/include -D_MPISERIAL -D_NETCDF -D_USEBOX -DCCSMCOUPLED=1 -DNO_SHR_VMATH -DBLCKX=50 -DBLCKY=4 -DMXBLCKS=58 -DNO_GETTIMEOFDAY ';
$common_flags     .= ' -DSPEC_AUTO_BYTEORDER=0x'.$Config{'byteorder'};

$bench_fppflags   = '-w ' . $common_flags;
$bench_cflags     =         $common_flags;

$reltol = { 'ocn.log'   => 0.03 };
$abstol = { 'ocn.log'   => 0.03 };

@sources = (qw(
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
    netcdf/netcdf.f90
    netcdf/typeSizes.f90
    fort.F90
    mpi.c
    send.c
    recv.c
    collective.c
    req.c
    list.c
    handles.c
    comm.c
    group.c
    time.c
    pack.c
    m_IndexBin_char.F90
    m_IndexBin_integer.F90
    m_IndexBin_logical.F90
    m_List.F90
    m_MergeSorts.F90
    m_Filename.F90
    m_FcComms.F90
    m_Permuter.F90
    m_SortingTools.F90
    m_String.F90
    m_StrTemplate.F90
    m_chars.F90
    m_die.F90
    m_dropdead.F90
    m_FileResolv.F90
    m_flow.F90
    m_inpak90.F90
    m_ioutil.F90
    m_mall.F90
    m_mpif.F90
    m_mpif90.F90
    m_mpout.F90
    m_rankMerge.F90
    m_realkinds.F90
    m_stdio.F90
    m_TraceBack.F90
    m_zeit.F90
    get_zeits.c
    m_MCTWorld.F90
    m_AttrVect.F90
    m_GlobalMap.F90
    m_GlobalSegMap.F90
    m_GlobalSegMapComms.F90
    m_Accumulator.F90
    m_SparseMatrix.F90
    m_Navigator.F90
    m_AttrVectComms.F90
    m_AttrVectReduce.F90
    m_AccumulatorComms.F90
    m_GeneralGrid.F90
    m_GeneralGridComms.F90
    m_SpatialIntegral.F90
    m_SpatialIntegralV.F90
    m_MatAttrVectMul.F90
    m_Merge.F90
    m_GlobalToLocal.F90
    m_ExchangeMaps.F90
    m_ConvertMaps.F90
    m_SparseMatrixDecomp.F90
    m_SparseMatrixToMaps.F90
    m_SparseMatrixComms.F90
    m_SparseMatrixPlus.F90
    m_Router.F90
    m_Rearranger.F90
    m_Transfer.F90
    alloc_mod.F90
    box_rearrange.F90
    iompi_mod.F90
    ionf_mod.F90
    mct_rearrange.F90
    nf_mod.F90
    piodarray.F90
    pio.F90
    pio_kinds.F90
    piolib_mod.F90
    pio_mpi_utils.F90
    pionfatt_mod.F90
    pionfget_mod.F90
    pionfput_mod.F90
    pionfread_mod.F90
    pio_nf_utils.F90
    pionfwrite_mod.F90
    pio_quicksort.F90
    pio_spmd_utils.F90
    pio_support.F90
    pio_types.F90
    pio_utils.F90
    pnetcdfversion.c
    rearrange.F90
    topology.c
    dead_data_mod.F90
    dead_mct_mod.F90
    dead_mod.F90
    ESMF_AlarmClockMod.F90
    ESMF_AlarmMod.F90
    ESMF_BaseMod.F90
    ESMF_BaseTimeMod.F90
    ESMF_CalendarMod.F90
    ESMF_ClockMod.F90
    ESMF_FractionMod.F90
    ESMF_Mod.F90
    ESMF_Stubs.F90
    ESMF_TimeIntervalMod.F90
    ESMF_TimeMod.F90
    f_wrappers.c
    GPTLget_memusage.c
    GPTLprint_memusage.c
    GPTLutil.c
    mct_mod.F90
    Meat.F90
    perf_mod.F90
    perf_utils.F90
    seq_cdata_mod.F90
    seq_comm_mct.F90
    seq_drydep_mod.F90
    seq_flds_indices.F90
    seq_flds_mod.F90
    seq_infodata_mod.F90
    seq_io_mod.F90
    seq_timemgr_mod.F90
    shr_cal_mod.F90
    shr_const_mod.F90
    shr_dmodel_mod.F90
    shr_file_mod.F90
    shr_flux_mod.F90
    shr_jlcp.c
    shr_kind_mod.F90
    shr_log_mod.F90
    shr_map_mod.F90
    shr_mct_mod.F90
    shr_mem_mod.F90
    shr_mpi_mod.F90
    shr_msg_mod.F90
    shr_ncread_mod.F90
    shr_orb_mod.F90
    shr_pcdf_mod.F90
    shr_scam_mod.F90
    shr_strdata_mod.F90
    shr_stream_mod.F90
    shr_string_mod.F90
    shr_sys_mod.F90
    shr_timer_mod.F90
    shr_tInterp_mod.F90
    shr_vmath_fwrap.c
    shr_vmath_mod.F90
    threadutil.c
    wrf_error_fatal.F90
    wrf_message.F90
    atm_comp_mct.F90
    datm_comp_mod.F90
    datm_shr_mod.F90
    dlnd_comp_mod.F90
    lnd_comp_mct.F90
    dice_comp_mod.F90
    ice_comp_mct.F90
    POP_BlocksMod.F90
    POP_BroadcastMod.F90
    POP_CommMod.F90
    POP_ConfigMod.F90
    POP_ConstantsMod.F90
    POP_DistributionMod.F90
    POP_DomainSizeMod.F90
    POP_ErrorMod.F90
    POP_FieldMod.F90
    POP_FinalMod.F90
    POP_GridDimMod.F90
    POP_GridHorzMod.F90
    POP_GridVertMod.F90
    POP_HaloMod.F90
    POP_IOUnitsMod.F90
    POP_InitMod.F90
    POP_KindsMod.F90
    POP_MCT_vars_mod.F90
    POP_RedistributeMod.F90
    POP_ReductionsMod.F90
    POP_SolversMod.F90
    advection.F90
    baroclinic.F90
    barotropic.F90
    blocks.F90
    broadcast.F90
    budget_diagnostics.F90
    cfc11_mod.F90
    cfc_mod.F90
    check_mod.F90
    co2calc.F90
    communicate.F90
    constants.F90
    current_meters.F90
    diag_bsf.F90
    diagnostics.F90
    diags_on_lat_aux_grid.F90
    distribution.F90
    domain.F90
    domain_size.F90
    drifters.F90
    ecosys_mod.F90
    ecosys_parms.F90
    exit_mod.F90
    forcing.F90
    forcing_ap.F90
    forcing_coupled.F90
    forcing_fields.F90
    forcing_pt_interior.F90
    forcing_s_interior.F90
    forcing_sfwf.F90
    forcing_shf.F90
    forcing_tools.F90
    forcing_ws.F90
    gather_scatter.F90
    global_reductions.F90
    grid.F90
    history.F90
    hmix_aniso.F90
    hmix_del2.F90
    hmix_del4.F90
    hmix_gm.F90
    hmix_gm_submeso_share.F90
    horizontal_mix.F90
    hydro_sections.F90
    iage_mod.F90
    ice.F90
    initial.F90
    io.F90
    io_binary.F90
    io_ccsm.F90
    io_netcdf.F90
    io_pio.F90
    io_tools.F90
    io_types.F90
    kinds_mod.F90
    mix_submeso.F90
    movie.F90
    ms_balance.F90
    msg_mod.F90
    named_field_mod.F90
    ocn_communicator.F90
    ocn_comp_mct.F90
    operators.F90
    output.F90
    overflows.F90
    passive_tracer_tools.F90
    passive_tracers.F90
    pressure_grad.F90
    prognostic.F90
    qflux_mod.F90
    registry.F90
    restart.F90
    spacecurve_mod.F90
    state_mod.F90
    step_mod.F90
    surface_hgt.F90
    sw_absorption.F90
    tavg.F90
    tidal_mixing.F90
    time_management.F90
    timers.F90
    topostress.F90
    tracer_types.F90
    vertical_mix.F90
    vmix_const.F90
    vmix_kpp.F90
    vmix_rich.F90
    glc_comp_mct.F90
    ccsm_driver.F90
    map_atmatm_mct.F90
    map_atmice_mct.F90
    map_atmlnd_mct.F90
    map_atmocn_mct.F90
    map_glcglc_mct.F90
    map_iceice_mct.F90
    map_iceocn_mct.F90
    map_lndlnd_mct.F90
    map_ocnocn_mct.F90
    map_rofocn_mct.F90
    map_rofrof_mct.F90
    map_snoglc_mct.F90
    map_snosno_mct.F90
    mrg_x2a_mct.F90
    mrg_x2g_mct.F90
    mrg_x2i_mct.F90
    mrg_x2l_mct.F90
    mrg_x2o_mct.F90
    mrg_x2s_mct.F90
    seq_avdata_mod.F90
    seq_diag_mct.F90
    seq_domain_mct.F90
    seq_flux_mct.F90
    seq_frac_mct.F90
    seq_hist_mod.F90
    seq_rearr_mod.F90
    seq_rest_mod.F90
    ));

use IO::File;

sub pre_run {
    my ($me, @paths) = @_;
    my $NTHREADS = $me->accessor_nowarn('threads');
    $NTHREADS = 1 unless $NTHREADS > 0;

    # Fix up all *.in files
    for my $path (@paths) {
        for my $file ($me->input_files_base) {
            next unless $file =~ s#\.in$##o;
            my $fullpath = ::jp($path, $file);
            my $ifh = new IO::File '<'.$fullpath.'.in';
            if (!defined($ifh)) {
                ::Log(0, "ERROR: In pre_run() for $name, ${fullpath}.in could not be opened for reading: $!\n");
                return 1;
            }
            my $ofh = new IO::File '>'.$fullpath;
            if (!defined($ofh)) {
                ::Log(0, "ERROR: In pre_run() for $name, $fullpath could not be opened for writing: $!\n");
                return 1;
            }
            while(defined(my $line = <$ifh>)) {
                $line =~ s/ocn_nthreads = \d+/ocn_nthreads = $NTHREADS/;
                $ofh->print($line);
            }
            $ofh->close();
            $ifh->close();
        }
    }
    return 0;
}

sub invoke {
    my ($me) = @_;
    my $name = $me->name;

    return ({
            'command' => $me->exe_file,
            'args'    => [ ],
            'output'  => "$name.out",
            'error'   => "$name.err",
        });
}

%deps = (
    'netcdf/netcdf.f90' => [
        'netcdf/typeSizes.f90',
    ],
    'm_IndexBin_char.F90' => [
        'm_stdio.F90',
        'm_die.F90',
    ],
    'm_IndexBin_integer.F90' => [
        'm_stdio.F90',
        'm_die.F90',
    ],
    'm_IndexBin_logical.F90' => [
        'm_stdio.F90',
        'm_die.F90',
    ],
    'm_List.F90' => [
        'm_die.F90',
        'm_mall.F90',
        'm_String.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
    ],
    'm_MergeSorts.F90' => [
        'm_realkinds.F90',
        'm_stdio.F90',
        'm_die.F90',
    ],
    'm_FcComms.F90' => [
        'm_die.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
    ],
    'm_Permuter.F90' => [
        'm_die.F90',
        'm_realkinds.F90',
    ],
    'm_SortingTools.F90' => [
        'm_MergeSorts.F90',
        'm_IndexBin_integer.F90',
        'm_IndexBin_char.F90',
        'm_IndexBin_logical.F90',
        'm_rankMerge.F90',
        'm_Permuter.F90',
    ],
    'm_String.F90' => [
        'm_die.F90',
        'm_mall.F90',
        'm_mpif90.F90',
    ],
    'm_StrTemplate.F90' => [
        'm_chars.F90',
        'm_stdio.F90',
        'm_die.F90',
    ],
    'm_die.F90' => [
        'm_mpif90.F90',
        'm_mpout.F90',
        'm_flow.F90',
        'm_dropdead.F90',
        'm_stdio.F90',
    ],
    'm_dropdead.F90' => [
        'm_stdio.F90',
        'm_mpif90.F90',
    ],
    'm_FileResolv.F90' => [
        'm_StrTemplate.F90',
        'm_die.F90',
    ],
    'm_flow.F90' => [
        'm_chars.F90',
    ],
    'm_inpak90.F90' => [
        'm_stdio.F90',
        'm_realkinds.F90',
        'm_mpif90.F90',
        'm_die.F90',
        'm_mall.F90',
        'm_ioutil.F90',
    ],
    'm_ioutil.F90' => [
        'm_stdio.F90',
    ],
    'm_mall.F90' => [
        'm_realkinds.F90',
        'm_stdio.F90',
        'm_die.F90',
        'm_ioutil.F90',
        'm_chars.F90',
    ],
    'm_mpif90.F90' => [
        'm_mpif.F90',
        'm_realkinds.F90',
        'm_stdio.F90',
    ],
    'm_mpout.F90' => [
        'm_stdio.F90',
        'm_ioutil.F90',
        'm_dropdead.F90',
        'm_mpif90.F90',
    ],
    'm_rankMerge.F90' => [
        'm_realkinds.F90',
    ],
    'm_TraceBack.F90' => [
        'm_stdio.F90',
        'm_die.F90',
        'm_String.F90',
    ],
    'm_zeit.F90' => [
        'm_stdio.F90',
        'm_die.F90',
        'm_mpif90.F90',
        'm_ioutil.F90',
        'm_SortingTools.F90',
    ],
    'm_MCTWorld.F90' => [
        'm_List.F90',
        'm_mpif90.F90',
        'm_die.F90',
        'm_stdio.F90',
    ],
    'm_AttrVect.F90' => [
        'm_realkinds.F90',
        'm_List.F90',
        'm_mall.F90',
        'm_die.F90',
        'm_String.F90',
        'm_stdio.F90',
        'm_TraceBack.F90',
        'm_SortingTools.F90',
    ],
    'm_GlobalMap.F90' => [
        'm_mpif90.F90',
        'm_die.F90',
        'm_stdio.F90',
    ],
    'm_GlobalSegMap.F90' => [
        'm_mpif90.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_FcComms.F90',
        'm_MCTWorld.F90',
        'm_SortingTools.F90',
    ],
    'm_GlobalSegMapComms.F90' => [
        'm_mpif90.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_GlobalSegMap.F90',
        'm_MCTWorld.F90',
    ],
    'm_Accumulator.F90' => [
        'm_List.F90',
        'm_AttrVect.F90',
        'm_realkinds.F90',
        'm_stdio.F90',
        'm_die.F90',
        'm_mall.F90',
        'm_String.F90',
    ],
    'm_SparseMatrix.F90' => [
        'm_realkinds.F90',
        'm_AttrVect.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
        'm_String.F90',
        'm_TraceBack.F90',
        'm_List.F90',
    ],
    'm_Navigator.F90' => [
        'm_mall.F90',
        'm_die.F90',
        'm_stdio.F90',
    ],
    'm_AttrVectComms.F90' => [
        'm_AttrVect.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
        'm_die.F90',
        'm_List.F90',
        'm_realkinds.F90',
        'm_GlobalMap.F90',
        'm_FcComms.F90',
        'm_GlobalSegMap.F90',
        'm_String.F90',
    ],
    'm_AttrVectReduce.F90' => [
        'm_realkinds.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_AttrVect.F90',
        'm_List.F90',
        'm_mpif90.F90',
    ],
    'm_AccumulatorComms.F90' => [
        'm_stdio.F90',
        'm_die.F90',
        'm_mpif90.F90',
        'm_GlobalMap.F90',
        'm_AttrVect.F90',
        'm_Accumulator.F90',
        'm_AttrVectComms.F90',
        'm_GlobalSegMap.F90',
    ],
    'm_GeneralGrid.F90' => [
        'm_List.F90',
        'm_AttrVect.F90',
        'm_stdio.F90',
        'm_die.F90',
        'm_realkinds.F90',
        'm_String.F90',
        'm_TraceBack.F90',
    ],
    'm_GeneralGridComms.F90' => [
        'm_GeneralGrid.F90',
        'm_stdio.F90',
        'm_die.F90',
        'm_mpif90.F90',
        'm_MCTWorld.F90',
        'm_AttrVectComms.F90',
        'm_List.F90',
        'm_GlobalMap.F90',
        'm_GlobalSegMap.F90',
    ],
    'm_SpatialIntegral.F90' => [
        'm_stdio.F90',
        'm_die.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
        'm_AttrVect.F90',
        'm_GeneralGrid.F90',
        'm_SpatialIntegralV.F90',
        'm_List.F90',
        'm_String.F90',
        'm_AttrVectReduce.F90',
    ],
    'm_SpatialIntegralV.F90' => [
        'm_stdio.F90',
        'm_die.F90',
        'm_mpif90.F90',
        'm_realkinds.F90',
        'm_AttrVect.F90',
        'm_AttrVectReduce.F90',
        'm_List.F90',
    ],
    'm_MatAttrVectMul.F90' => [
        'm_realkinds.F90',
        'm_stdio.F90',
        'm_die.F90',
        'm_List.F90',
        'm_AttrVect.F90',
        'm_SparseMatrix.F90',
        'm_mpif90.F90',
        'm_String.F90',
        'm_Rearranger.F90',
        'm_SparseMatrixPlus.F90',
    ],
    'm_Merge.F90' => [
        'm_stdio.F90',
        'm_die.F90',
        'm_realkinds.F90',
        'm_List.F90',
        'm_AttrVect.F90',
        'm_GeneralGrid.F90',
        'm_String.F90',
    ],
    'm_GlobalToLocal.F90' => [
        'm_mpif90.F90',
        'm_die.F90',
        'm_GlobalSegMap.F90',
        'm_stdio.F90',
        'm_GlobalMap.F90',
        'm_Navigator.F90',
        'm_SparseMatrix.F90',
    ],
    'm_ExchangeMaps.F90' => [
        'm_mpif90.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_MCTWorld.F90',
        'm_GlobalMap.F90',
        'm_GlobalSegMap.F90',
        'm_ConvertMaps.F90',
    ],
    'm_ConvertMaps.F90' => [
        'm_GlobalMap.F90',
        'm_GlobalSegMap.F90',
        'm_stdio.F90',
        'm_die.F90',
        'm_MCTWorld.F90',
        'm_SortingTools.F90',
    ],
    'm_SparseMatrixDecomp.F90' => [
        'm_die.F90',
        'm_List.F90',
        'm_AttrVect.F90',
        'm_AttrVectComms.F90',
        'm_GlobalMap.F90',
        'm_GlobalSegMap.F90',
        'm_SparseMatrix.F90',
    ],
    'm_SparseMatrixToMaps.F90' => [
        'm_SparseMatrix.F90',
        'm_stdio.F90',
        'm_die.F90',
        'm_mpif90.F90',
        'm_List.F90',
        'm_GlobalSegMap.F90',
    ],
    'm_SparseMatrixComms.F90' => [
        'm_die.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
        'm_List.F90',
        'm_GlobalSegMap.F90',
        'm_SparseMatrix.F90',
        'm_SparseMatrixDecomp.F90',
        'm_AttrVectComms.F90',
        'm_GlobalMap.F90',
    ],
    'm_SparseMatrixPlus.F90' => [
        'm_String.F90',
        'm_SparseMatrix.F90',
        'm_Rearranger.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_mpif90.F90',
        'm_GlobalSegMap.F90',
        'm_SparseMatrixComms.F90',
        'm_SparseMatrixToMaps.F90',
        'm_GlobalToLocal.F90',
        'm_List.F90',
    ],
    'm_Router.F90' => [
        'm_realkinds.F90',
        'm_GlobalSegMap.F90',
        'm_ExchangeMaps.F90',
        'm_mpif90.F90',
        'm_die.F90',
        'm_GlobalToLocal.F90',
        'm_MCTWorld.F90',
        'm_Permuter.F90',
        'm_MergeSorts.F90',
        'm_stdio.F90',
    ],
    'm_Rearranger.F90' => [
        'm_Router.F90',
        'm_MCTWorld.F90',
        'm_GlobalSegMap.F90',
        'm_mpif90.F90',
        'm_die.F90',
        'm_stdio.F90',
        'm_AttrVect.F90',
        'm_realkinds.F90',
    ],
    'm_Transfer.F90' => [
        'm_MCTWorld.F90',
        'm_AttrVect.F90',
        'm_Router.F90',
        'm_mpif90.F90',
        'm_die.F90',
        'm_stdio.F90',
    ],
    'alloc_mod.F90' => [
        'pio_kinds.F90',
        'pio_types.F90',
        'pio_support.F90',
    ],
    'box_rearrange.F90' => [
        'pio_kinds.F90',
        'pio_types.F90',
        'pio_support.F90',
        'alloc_mod.F90',
        'pio_spmd_utils.F90',
    ],
    'iompi_mod.F90' => [
        'pio_kinds.F90',
        'pio_types.F90',
        'pio_support.F90',
        'alloc_mod.F90',
    ],
    'ionf_mod.F90' => [
        'alloc_mod.F90',
        'pio_kinds.F90',
        'pio_types.F90',
        'pio_utils.F90',
        'pio_support.F90',
        'netcdf/netcdf.f90',
    ],
    'mct_rearrange.F90' => [
        'pio_kinds.F90',
        'pio_types.F90',
        'alloc_mod.F90',
        'pio_support.F90',
    ],
    'nf_mod.F90' => [
        'alloc_mod.F90',
        'pio_kinds.F90',
        'pio_types.F90',
        'pio_support.F90',
        'pio_utils.F90',
        'netcdf/netcdf.f90',
    ],
    'piodarray.F90' => [
        'pio_types.F90',
        'pio_kinds.F90',
        'pio_support.F90',
        'pionfwrite_mod.F90',
        'pionfread_mod.F90',
        'iompi_mod.F90',
        'alloc_mod.F90',
        'rearrange.F90',
    ],
    'pio.F90' => [
        'pio_kinds.F90',
        'piolib_mod.F90',
        'pio_types.F90',
        'piodarray.F90',
        'nf_mod.F90',
        'pionfatt_mod.F90',
        'pionfput_mod.F90',
        'pionfget_mod.F90',
    ],
    'piolib_mod.F90' => [
        'pio_kinds.F90',
        'pio_types.F90',
        'alloc_mod.F90',
        'pio_support.F90',
        'ionf_mod.F90',
        'pionfread_mod.F90',
        'pionfwrite_mod.F90',
        'pio_mpi_utils.F90',
        'iompi_mod.F90',
        'rearrange.F90',
    ],
    'pio_mpi_utils.F90' => [
        'pio_support.F90',
        'pio_types.F90',
    ],
    'pionfatt_mod.F90' => [
        'pio_kinds.F90',
        'pio_types.F90',
        'pio_support.F90',
        'pio_utils.F90',
        'netcdf/netcdf.f90',
    ],
    'pionfget_mod.F90' => [
        'pio_kinds.F90',
        'pio_types.F90',
        'pio_utils.F90',
        'pio_support.F90',
        'netcdf/netcdf.f90',
    ],
    'pionfput_mod.F90' => [
        'pio_kinds.F90',
        'pio_types.F90',
        'pio_utils.F90',
        'pio_support.F90',
        'netcdf/netcdf.f90',
        'nf_mod.F90',
    ],
    'pionfread_mod.F90' => [
        'pio_types.F90',
        'pio_kinds.F90',
        'pio_utils.F90',
        'pio_support.F90',
        'alloc_mod.F90',
        'netcdf/netcdf.f90',
    ],
    'pio_nf_utils.F90' => [
        'pio_types.F90',
        'nf_mod.F90',
        'pionfget_mod.F90',
        'pionfput_mod.F90',
        'pio_kinds.F90',
        'pio_support.F90',
    ],
    'pionfwrite_mod.F90' => [
        'nf_mod.F90',
        'pio_types.F90',
        'pio_kinds.F90',
        'pio_utils.F90',
        'alloc_mod.F90',
        'pio_support.F90',
        'netcdf/netcdf.f90',
    ],
    'pio_quicksort.F90' => [
        'pio_kinds.F90',
    ],
    'pio_spmd_utils.F90' => [
        'pio_kinds.F90',
        'pio_support.F90',
    ],
    'pio_support.F90' => [
        'pio_kinds.F90',
    ],
    'pio_types.F90' => [
        'pio_kinds.F90',
        'netcdf/netcdf.f90',
    ],
    'pio_utils.F90' => [
        'pio_types.F90',
        'pio_kinds.F90',
        'pio_support.F90',
        'netcdf/netcdf.f90',
    ],
    'rearrange.F90' => [
        'pio_kinds.F90',
        'pio_types.F90',
        'pio_support.F90',
        'box_rearrange.F90',
    ],
    'dead_data_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'dead_mct_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'seq_flds_mod.F90',
        'shr_file_mod.F90',
        'mct_mod.F90',
        'dead_data_mod.F90',
    ],
    'dead_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'shr_file_mod.F90',
        'shr_sys_mod.F90',
        'dead_data_mod.F90',
    ],
    'ESMF_AlarmClockMod.F90' => [
        'ESMF_AlarmMod.F90',
        'ESMF_ClockMod.F90',
        'ESMF_TimeIntervalMod.F90',
        'ESMF_TimeMod.F90',
    ],
    'ESMF_AlarmMod.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_TimeIntervalMod.F90',
        'ESMF_TimeMod.F90',
    ],
    'ESMF_BaseTimeMod.F90' => [
        'ESMF_BaseMod.F90',
    ],
    'ESMF_CalendarMod.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_BaseTimeMod.F90',
    ],
    'ESMF_ClockMod.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_TimeIntervalMod.F90',
        'ESMF_TimeMod.F90',
        'ESMF_AlarmMod.F90',
    ],
    'ESMF_Mod.F90' => [
        'ESMF_AlarmMod.F90',
        'ESMF_BaseMod.F90',
        'ESMF_BaseTimeMod.F90',
        'ESMF_CalendarMod.F90',
        'ESMF_ClockMod.F90',
        'ESMF_FractionMod.F90',
        'ESMF_TimeIntervalMod.F90',
        'ESMF_TimeMod.F90',
        'ESMF_AlarmClockMod.F90',
        'ESMF_Stubs.F90',
    ],
    'ESMF_Stubs.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_CalendarMod.F90',
        'ESMF_TimeMod.F90',
    ],
    'ESMF_TimeIntervalMod.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_BaseTimeMod.F90',
        'ESMF_FractionMod.F90',
        'ESMF_CalendarMod.F90',
    ],
    'ESMF_TimeMod.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_BaseTimeMod.F90',
        'ESMF_TimeIntervalMod.F90',
        'ESMF_CalendarMod.F90',
    ],
    'mct_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_mpi_mod.F90',
        'shr_const_mod.F90',
        'shr_log_mod.F90',
        'm_MCTWorld.F90',
        'm_AttrVect.F90',
        'm_AttrVectComms.F90',
        'm_Accumulator.F90',
        'm_GeneralGrid.F90',
        'm_GeneralGridComms.F90',
        'm_Transfer.F90',
        'm_GlobalSegMap.F90',
        'm_GlobalSegMapComms.F90',
        'm_Rearranger.F90',
        'm_Router.F90',
        'm_SparseMatrixToMaps.F90',
        'm_SparseMatrix.F90',
        'm_SparseMatrixComms.F90',
        'm_SparseMatrixPlus.F90',
        'm_MatAttrVectMul.F90',
        'm_GlobalToLocal.F90',
        'm_List.F90',
        'm_String.F90',
        'm_die.F90',
        'm_inpak90.F90',
        'm_Permuter.F90',
        'm_MergeSorts.F90',
        'm_stdio.F90',
    ],
    'Meat.F90' => [
        'ESMF_BaseMod.F90',
        'ESMF_BaseTimeMod.F90',
        'ESMF_TimeMod.F90',
        'ESMF_TimeIntervalMod.F90',
        'ESMF_CalendarMod.F90',
        'ESMF_AlarmMod.F90',
        'ESMF_ClockMod.F90',
        'ESMF_FractionMod.F90',
    ],
    'perf_mod.F90' => [
        'perf_utils.F90',
    ],
    'seq_cdata_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'seq_infodata_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
    ],
    'seq_comm_mct.F90' => [
        'mct_mod.F90',
        'shr_sys_mod.F90',
        'shr_mpi_mod.F90',
        'shr_file_mod.F90',
    ],
    'seq_drydep_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'shr_file_mod.F90',
    ],
    'seq_flds_indices.F90' => [
        'shr_string_mod.F90',
        'shr_sys_mod.F90',
        'seq_flds_mod.F90',
        'seq_drydep_mod.F90',
        'mct_mod.F90',
    ],
    'seq_flds_mod.F90' => [
        'shr_sys_mod.F90',
        'seq_drydep_mod.F90',
        'mct_mod.F90',
        'shr_string_mod.F90',
    ],
    'seq_infodata_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'shr_orb_mod.F90',
        'shr_file_mod.F90',
        'shr_string_mod.F90',
        'shr_mpi_mod.F90',
        'seq_io_mod.F90',
    ],
    'seq_io_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'seq_comm_mct.F90',
        'seq_flds_mod.F90',
        'mct_mod.F90',
        'pio.F90',
        'shr_string_mod.F90',
        'shr_file_mod.F90',
        'shr_mpi_mod.F90',
    ],
    'seq_timemgr_mod.F90' => [
        'ESMF_Mod.F90',
        'shr_kind_mod.F90',
        'seq_comm_mct.F90',
        'shr_sys_mod.F90',
        'shr_cal_mod.F90',
        'shr_string_mod.F90',
        'shr_file_mod.F90',
        'shr_mpi_mod.F90',
        'seq_io_mod.F90',
    ],
    'shr_cal_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
        'ESMF_Mod.F90',
    ],
    'shr_const_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'shr_dmodel_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_kind_mod.F90',
        'shr_log_mod.F90',
        'shr_mpi_mod.F90',
        'mct_mod.F90',
        'perf_mod.F90',
        'pio.F90',
        'seq_flds_mod.F90',
        'shr_file_mod.F90',
        'shr_string_mod.F90',
        'shr_ncread_mod.F90',
        'shr_stream_mod.F90',
        'shr_map_mod.F90',
    ],
    'shr_file_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
    ],
    'shr_flux_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'shr_sys_mod.F90',
        'shr_log_mod.F90',
    ],
    'shr_infnan_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'shr_log_mod.F90' => [
        'shr_kind_mod.F90',
    ],
    'shr_map_mod.F90' => [
        'shr_const_mod.F90',
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_timer_mod.F90',
        'shr_log_mod.F90',
    ],
    'shr_mct_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_mpi_mod.F90',
        'shr_const_mod.F90',
        'mct_mod.F90',
        'shr_log_mod.F90',
        'shr_pcdf_mod.F90',
    ],
    'shr_mem_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_log_mod.F90',
    ],
    'shr_mpi_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_log_mod.F90',
    ],
    'shr_msg_mod.F90' => [
        'shr_file_mod.F90',
        'shr_log_mod.F90',
        'shr_sys_mod.F90',
    ],
    'shr_ncread_mod.F90' => [
        'shr_string_mod.F90',
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_file_mod.F90',
        'shr_log_mod.F90',
        'netcdf/netcdf.f90',
    ],
    'shr_orb_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_const_mod.F90',
        'shr_log_mod.F90',
    ],
    'shr_pcdf_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_const_mod.F90',
        'shr_log_mod.F90',
        'mct_mod.F90',
        'pio.F90',
    ],
    'shr_scam_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_file_mod.F90',
        'shr_log_mod.F90',
        'netcdf/netcdf.f90',
        'shr_strdata_mod.F90',
        'shr_dmodel_mod.F90',
        'mct_mod.F90',
    ],
    'shr_strdata_mod.F90' => [
        'shr_const_mod.F90',
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_mpi_mod.F90',
        'shr_file_mod.F90',
        'shr_log_mod.F90',
        'shr_stream_mod.F90',
        'shr_string_mod.F90',
        'shr_map_mod.F90',
        'shr_cal_mod.F90',
        'shr_orb_mod.F90',
        'shr_tInterp_mod.F90',
        'shr_dmodel_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'perf_mod.F90',
        'pio.F90',
    ],
    'shr_stream_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'shr_string_mod.F90',
        'shr_mpi_mod.F90',
        'shr_file_mod.F90',
        'shr_cal_mod.F90',
        'shr_log_mod.F90',
        'perf_mod.F90',
        'netcdf/netcdf.f90',
    ],
    'shr_string_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_cal_mod.F90',
        'shr_timer_mod.F90',
        'shr_log_mod.F90',
    ],
    'shr_sys_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_mpi_mod.F90',
        'shr_log_mod.F90',
    ],
    'shr_timer_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_log_mod.F90',
        'shr_sys_mod.F90',
    ],
    'shr_tInterp_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_cal_mod.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'shr_log_mod.F90',
        'shr_orb_mod.F90',
    ],
    'shr_vmath_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_log_mod.F90',
    ],
    'wrf_error_fatal.F90' => [
        'shr_sys_mod.F90',
    ],
    'atm_comp_mct.F90' => [
        'seq_cdata_mod.F90',
        'ESMF_Mod.F90',
        'mct_mod.F90',
        'datm_comp_mod.F90',
    ],
    'datm_comp_mod.F90' => [
        'shr_const_mod.F90',
        'shr_sys_mod.F90',
        'shr_kind_mod.F90',
        'shr_file_mod.F90',
        'shr_cal_mod.F90',
        'shr_mpi_mod.F90',
        'mct_mod.F90',
        'ESMF_Mod.F90',
        'perf_mod.F90',
        'shr_strdata_mod.F90',
        'shr_dmodel_mod.F90',
        'shr_pcdf_mod.F90',
        'datm_shr_mod.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
        'seq_timemgr_mod.F90',
        'seq_flds_indices.F90',
        'seq_flds_mod.F90',
    ],
    'datm_shr_mod.F90' => [
        'shr_const_mod.F90',
        'shr_file_mod.F90',
        'shr_dmodel_mod.F90',
        'shr_sys_mod.F90',
        'shr_kind_mod.F90',
        'seq_flds_mod.F90',
        'shr_cal_mod.F90',
        'shr_ncread_mod.F90',
        'mct_mod.F90',
        'shr_map_mod.F90',
    ],
    'dlnd_comp_mod.F90' => [
        'shr_sys_mod.F90',
        'shr_kind_mod.F90',
        'shr_file_mod.F90',
        'shr_mpi_mod.F90',
        'mct_mod.F90',
        'ESMF_Mod.F90',
        'perf_mod.F90',
        'shr_strdata_mod.F90',
        'shr_dmodel_mod.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
        'seq_timemgr_mod.F90',
        'seq_flds_indices.F90',
        'seq_flds_mod.F90',
    ],
    'lnd_comp_mct.F90' => [
        'seq_cdata_mod.F90',
        'ESMF_Mod.F90',
        'mct_mod.F90',
        'dlnd_comp_mod.F90',
    ],
    'dice_comp_mod.F90' => [
        'shr_const_mod.F90',
        'shr_sys_mod.F90',
        'shr_kind_mod.F90',
        'shr_file_mod.F90',
        'shr_mpi_mod.F90',
        'shr_flux_mod.F90',
        'shr_cal_mod.F90',
        'mct_mod.F90',
        'ESMF_Mod.F90',
        'perf_mod.F90',
        'shr_strdata_mod.F90',
        'shr_dmodel_mod.F90',
        'shr_pcdf_mod.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
        'seq_timemgr_mod.F90',
        'seq_flds_indices.F90',
        'seq_flds_mod.F90',
    ],
    'ice_comp_mct.F90' => [
        'seq_cdata_mod.F90',
        'ESMF_Mod.F90',
        'mct_mod.F90',
        'dice_comp_mod.F90',
    ],
    'POP_BlocksMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_DomainSizeMod.F90',
    ],
    'POP_BroadcastMod.F90' => [
        'POP_KindsMod.F90',
        'POP_CommMod.F90',
        'POP_ErrorMod.F90',
    ],
    'POP_CommMod.F90' => [
        'POP_KindsMod.F90',
        'ocn_communicator.F90',
    ],
    'POP_ConfigMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_CommMod.F90',
        'POP_BroadcastMod.F90',
    ],
    'POP_ConstantsMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_IOUnitsMod.F90',
        'netcdf/netcdf.f90',
        'shr_const_mod.F90',
    ],
    'POP_DistributionMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_BlocksMod.F90',
        'spacecurve_mod.F90',
    ],
    'POP_DomainSizeMod.F90' => [
        'POP_KindsMod.F90',
    ],
    'POP_ErrorMod.F90' => [
        'POP_KindsMod.F90',
        'POP_CommMod.F90',
        'POP_IOUnitsMod.F90',
        'io_types.F90',
    ],
    'POP_FieldMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_GridDimMod.F90',
        'POP_GridHorzMod.F90',
        'POP_GridVertMod.F90',
    ],
    'POP_FinalMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_IOUnitsMod.F90',
        'communicate.F90',
        'io_types.F90',
        'timers.F90',
    ],
    'POP_GridDimMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
    ],
    'POP_GridHorzMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
    ],
    'POP_GridVertMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
    ],
    'POP_HaloMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_CommMod.F90',
        'POP_BlocksMod.F90',
        'POP_ReductionsMod.F90',
        'POP_DistributionMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
    ],
    'POP_IOUnitsMod.F90' => [
        'POP_KindsMod.F90',
        'shr_sys_mod.F90',
        'shr_file_mod.F90',
    ],
    'POP_InitMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'kinds_mod.F90',
        'initial.F90',
        'domain.F90',
        'timers.F90',
        'time_management.F90',
    ],
    'POP_MCT_vars_mod.F90' => [
        'mct_mod.F90',
        'kinds_mod.F90',
    ],
    'POP_RedistributeMod.F90' => [
        'POP_KindsMod.F90',
        'POP_CommMod.F90',
        'POP_BlocksMod.F90',
        'POP_DistributionMod.F90',
        'POP_ErrorMod.F90',
    ],
    'POP_ReductionsMod.F90' => [
        'POP_KindsMod.F90',
        'POP_CommMod.F90',
        'POP_ErrorMod.F90',
        'POP_BlocksMod.F90',
        'POP_DistributionMod.F90',
        'POP_GridHorzMod.F90',
    ],
    'POP_SolversMod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_ConfigMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_BlocksMod.F90',
        'POP_DistributionMod.F90',
        'POP_GridHorzMod.F90',
        'POP_ReductionsMod.F90',
        'POP_RedistributeMod.F90',
        'POP_HaloMod.F90',
        'POP_FieldMod.F90',
        'POP_DomainSizeMod.F90',
        'domain.F90',
        'grid.F90',
    ],
    'advection.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'kinds_mod.F90',
        'constants.F90',
        'blocks.F90',
        'domain_size.F90',
        'communicate.F90',
        'distribution.F90',
        'grid.F90',
        'domain.F90',
        'broadcast.F90',
        'diagnostics.F90',
        'state_mod.F90',
        'operators.F90',
        'tavg.F90',
        'io_types.F90',
        'time_management.F90',
        'timers.F90',
        'exit_mod.F90',
        'prognostic.F90',
        'passive_tracers.F90',
        'registry.F90',
        'overflows.F90',
    ],
    'baroclinic.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'prognostic.F90',
        'broadcast.F90',
        'communicate.F90',
        'grid.F90',
        'advection.F90',
        'pressure_grad.F90',
        'horizontal_mix.F90',
        'vertical_mix.F90',
        'vmix_kpp.F90',
        'diagnostics.F90',
        'movie.F90',
        'state_mod.F90',
        'ice.F90',
        'time_management.F90',
        'io_types.F90',
        'tavg.F90',
        'forcing_fields.F90',
        'forcing_shf.F90',
        'forcing_sfwf.F90',
        'sw_absorption.F90',
        'forcing_pt_interior.F90',
        'forcing_s_interior.F90',
        'passive_tracers.F90',
        'exit_mod.F90',
        'overflows.F90',
    ],
    'barotropic.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'POP_SolversMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'prognostic.F90',
        'operators.F90',
        'grid.F90',
        'time_management.F90',
        'global_reductions.F90',
        'forcing_fields.F90',
        'forcing_ap.F90',
        'tavg.F90',
        'overflows.F90',
    ],
    'blocks.F90' => [
        'kinds_mod.F90',
        'exit_mod.F90',
        'domain_size.F90',
    ],
    'broadcast.F90' => [
        'kinds_mod.F90',
        'communicate.F90',
    ],
    'budget_diagnostics.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'kinds_mod.F90',
        'domain_size.F90',
        'diagnostics.F90',
        'domain.F90',
        'constants.F90',
        'prognostic.F90',
        'io.F90',
        'global_reductions.F90',
        'grid.F90',
        'exit_mod.F90',
        'ice.F90',
        'qflux_mod.F90',
        'tavg.F90',
        'time_management.F90',
        'forcing_sfwf.F90',
    ],
    'cfc11_mod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_IOUnitsMod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'exit_mod.F90',
        'communicate.F90',
        'prognostic.F90',
        'kinds_mod.F90',
        'constants.F90',
        'io.F90',
        'io_types.F90',
        'io_tools.F90',
        'tavg.F90',
        'timers.F90',
        'passive_tracer_tools.F90',
        'broadcast.F90',
        'grid.F90',
        'forcing_tools.F90',
        'time_management.F90',
    ],
    'cfc_mod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'exit_mod.F90',
        'communicate.F90',
        'constants.F90',
        'io_types.F90',
        'io_tools.F90',
        'tavg.F90',
        'passive_tracer_tools.F90',
        'broadcast.F90',
        'netcdf/netcdf.f90',
        'prognostic.F90',
        'grid.F90',
        'timers.F90',
        'forcing_tools.F90',
        'time_management.F90',
    ],
    'check_mod.F90' => [
        'kinds_mod.F90',
    ],
    'co2calc.F90' => [
        'constants.F90',
        'blocks.F90',
        'domain_size.F90',
        'kinds_mod.F90',
        'state_mod.F90',
        'shr_vmath_mod.F90',
        'shr_sys_mod.F90',
    ],
    'communicate.F90' => [
        'kinds_mod.F90',
        'POP_CommMod.F90',
    ],
    'constants.F90' => [
        'kinds_mod.F90',
        'shr_kind_mod.F90',
        'shr_const_mod.F90',
        'netcdf/netcdf.f90',
    ],
    'current_meters.F90' => [
        'kinds_mod.F90',
    ],
    'diag_bsf.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_GridHorzMod.F90',
        'POP_FieldMod.F90',
        'POP_HaloMod.F90',
        'kinds_mod.F90',
        'broadcast.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'exit_mod.F90',
        'global_reductions.F90',
        'gather_scatter.F90',
        'grid.F90',
        'io.F90',
        'registry.F90',
    ],
    'diagnostics.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_SolversMod.F90',
        'domain.F90',
        'constants.F90',
        'prognostic.F90',
        'time_management.F90',
        'io.F90',
        'broadcast.F90',
        'global_reductions.F90',
        'grid.F90',
        'forcing.F90',
        'forcing_fields.F90',
        'timers.F90',
        'exit_mod.F90',
        'tavg.F90',
        'movie.F90',
        'vmix_kpp.F90',
        'registry.F90',
        'io_tools.F90',
        'gather_scatter.F90',
    ],
    'diags_on_lat_aux_grid.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'kinds_mod.F90',
        'domain_size.F90',
        'domain.F90',
        'blocks.F90',
        'io.F90',
        'io_tools.F90',
        'exit_mod.F90',
        'grid.F90',
        'global_reductions.F90',
        'gather_scatter.F90',
        'constants.F90',
        'registry.F90',
        'timers.F90',
    ],
    'distribution.F90' => [
        'kinds_mod.F90',
        'communicate.F90',
        'blocks.F90',
        'spacecurve_mod.F90',
        'exit_mod.F90',
    ],
    'domain.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_DomainSizeMod.F90',
        'POP_BlocksMod.F90',
        'POP_DistributionMod.F90',
        'POP_HaloMod.F90',
        'kinds_mod.F90',
        'constants.F90',
        'communicate.F90',
        'broadcast.F90',
        'blocks.F90',
        'distribution.F90',
        'exit_mod.F90',
        'io_types.F90',
        'domain_size.F90',
    ],
    'domain_size.F90' => [
        'kinds_mod.F90',
    ],
    'drifters.F90' => [
        'kinds_mod.F90',
    ],
    'ecosys_mod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_GridHorzMod.F90',
        'POP_FieldMod.F90',
        'POP_HaloMod.F90',
        'kinds_mod.F90',
        'constants.F90',
        'communicate.F90',
        'broadcast.F90',
        'global_reductions.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'exit_mod.F90',
        'prognostic.F90',
        'grid.F90',
        'io.F90',
        'io_types.F90',
        'io_tools.F90',
        'tavg.F90',
        'timers.F90',
        'passive_tracer_tools.F90',
        'named_field_mod.F90',
        'forcing_tools.F90',
        'time_management.F90',
        'ecosys_parms.F90',
        'registry.F90',
        'co2calc.F90',
        'POP_MCT_vars_mod.F90',
        'shr_strdata_mod.F90',
        'shr_sys_mod.F90',
    ],
    'ecosys_parms.F90' => [
        'exit_mod.F90',
        'communicate.F90',
        'constants.F90',
        'kinds_mod.F90',
        'io_tools.F90',
        'io_types.F90',
        'broadcast.F90',
    ],
    'exit_mod.F90' => [
        'kinds_mod.F90',
        'communicate.F90',
        'constants.F90',
        'POP_IOUnitsMod.F90',
    ],
    'forcing.F90' => [
        'constants.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'grid.F90',
        'ice.F90',
        'forcing_ws.F90',
        'forcing_shf.F90',
        'forcing_sfwf.F90',
        'forcing_pt_interior.F90',
        'forcing_s_interior.F90',
        'forcing_ap.F90',
        'forcing_coupled.F90',
        'forcing_tools.F90',
        'passive_tracers.F90',
        'prognostic.F90',
        'tavg.F90',
        'movie.F90',
        'time_management.F90',
        'exit_mod.F90',
        'shr_sys_mod.F90',
        'sw_absorption.F90',
        'registry.F90',
        'forcing_fields.F90',
    ],
    'forcing_ap.F90' => [
        'kinds_mod.F90',
        'domain.F90',
        'constants.F90',
        'broadcast.F90',
        'io.F90',
        'forcing_tools.F90',
        'time_management.F90',
        'grid.F90',
        'exit_mod.F90',
    ],
    'forcing_coupled.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'io_types.F90',
        'communicate.F90',
        'global_reductions.F90',
        'constants.F90',
        'io.F90',
        'time_management.F90',
        'grid.F90',
        'prognostic.F90',
        'exit_mod.F90',
        'ice.F90',
        'forcing_shf.F90',
        'forcing_sfwf.F90',
        'forcing_ws.F90',
        'forcing_fields.F90',
        'timers.F90',
        'ms_balance.F90',
        'tavg.F90',
        'registry.F90',
        'named_field_mod.F90',
        'shr_orb_mod.F90',
    ],
    'forcing_fields.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'constants.F90',
        'domain_size.F90',
    ],
    'forcing_pt_interior.F90' => [
        'kinds_mod.F90',
        'domain.F90',
        'constants.F90',
        'broadcast.F90',
        'io.F90',
        'forcing_tools.F90',
        'time_management.F90',
        'prognostic.F90',
        'grid.F90',
        'exit_mod.F90',
    ],
    'forcing_s_interior.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'domain.F90',
        'constants.F90',
        'io.F90',
        'forcing_tools.F90',
        'time_management.F90',
        'prognostic.F90',
        'grid.F90',
        'exit_mod.F90',
    ],
    'forcing_sfwf.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'constants.F90',
        'io.F90',
        'grid.F90',
        'global_reductions.F90',
        'forcing_tools.F90',
        'forcing_shf.F90',
        'ice.F90',
        'time_management.F90',
        'prognostic.F90',
        'exit_mod.F90',
    ],
    'forcing_shf.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'constants.F90',
        'io.F90',
        'grid.F90',
        'forcing_tools.F90',
        'time_management.F90',
        'prognostic.F90',
        'exit_mod.F90',
    ],
    'forcing_tools.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'domain.F90',
        'constants.F90',
        'io.F90',
        'io_types.F90',
        'grid.F90',
        'time_management.F90',
        'exit_mod.F90',
    ],
    'forcing_ws.F90' => [
        'kinds_mod.F90',
        'constants.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'io.F90',
        'forcing_tools.F90',
        'time_management.F90',
        'grid.F90',
        'exit_mod.F90',
    ],
    'gather_scatter.F90' => [
        'kinds_mod.F90',
        'communicate.F90',
        'constants.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'domain_size.F90',
        'exit_mod.F90',
    ],
    'global_reductions.F90' => [
        'kinds_mod.F90',
        'communicate.F90',
        'constants.F90',
        'blocks.F90',
        'distribution.F90',
        'domain_size.F90',
        'domain.F90',
        'exit_mod.F90',
        'registry.F90',
    ],
    'grid.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'communicate.F90',
        'blocks.F90',
        'distribution.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'io.F90',
        'broadcast.F90',
        'gather_scatter.F90',
        'global_reductions.F90',
        'exit_mod.F90',
        'registry.F90',
    ],
    'history.F90' => [
        'kinds_mod.F90',
        'domain.F90',
        'constants.F90',
        'prognostic.F90',
        'grid.F90',
        'io.F90',
        'broadcast.F90',
        'time_management.F90',
        'forcing.F90',
        'forcing_fields.F90',
        'forcing_shf.F90',
        'exit_mod.F90',
    ],
    'hmix_aniso.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'communicate.F90',
        'distribution.F90',
        'domain.F90',
        'constants.F90',
        'broadcast.F90',
        'POP_ReductionsMod.F90',
        'gather_scatter.F90',
        'diagnostics.F90',
        'time_management.F90',
        'grid.F90',
        'io.F90',
        'exit_mod.F90',
    ],
    'hmix_del2.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'POP_ReductionsMod.F90',
        'blocks.F90',
        'communicate.F90',
        'distribution.F90',
        'domain_size.F90',
        'domain.F90',
        'broadcast.F90',
        'constants.F90',
        'topostress.F90',
        'diagnostics.F90',
        'io.F90',
        'grid.F90',
        'exit_mod.F90',
        'tavg.F90',
        'time_management.F90',
    ],
    'hmix_del4.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'POP_ReductionsMod.F90',
        'blocks.F90',
        'communicate.F90',
        'distribution.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'grid.F90',
        'broadcast.F90',
        'io.F90',
        'diagnostics.F90',
        'exit_mod.F90',
        'tavg.F90',
        'time_management.F90',
    ],
    'hmix_gm.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'constants.F90',
        'broadcast.F90',
        'grid.F90',
        'io.F90',
        'vertical_mix.F90',
        'vmix_kpp.F90',
        'state_mod.F90',
        'time_management.F90',
        'tavg.F90',
        'diagnostics.F90',
        'exit_mod.F90',
        'registry.F90',
        'hmix_gm_submeso_share.F90',
        'shr_sys_mod.F90',
        'timers.F90',
    ],
    'hmix_gm_submeso_share.F90' => [
        'registry.F90',
        'blocks.F90',
        'kinds_mod.F90',
        'grid.F90',
        'constants.F90',
        'state_mod.F90',
        'time_management.F90',
        'domain_size.F90',
        'domain.F90',
    ],
    'horizontal_mix.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_ConstantsMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'communicate.F90',
        'time_management.F90',
        'broadcast.F90',
        'grid.F90',
        'io_types.F90',
        'hmix_del2.F90',
        'hmix_del4.F90',
        'hmix_gm.F90',
        'hmix_aniso.F90',
        'topostress.F90',
        'tavg.F90',
        'timers.F90',
        'exit_mod.F90',
        'mix_submeso.F90',
        'hmix_gm_submeso_share.F90',
        'prognostic.F90',
        'vertical_mix.F90',
    ],
    'hydro_sections.F90' => [
        'kinds_mod.F90',
    ],
    'iage_mod.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_ErrorMod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'exit_mod.F90',
        'communicate.F90',
        'prognostic.F90',
        'kinds_mod.F90',
        'constants.F90',
        'io.F90',
        'io_types.F90',
        'io_tools.F90',
        'tavg.F90',
        'passive_tracer_tools.F90',
        'broadcast.F90',
        'grid.F90',
        'time_management.F90',
    ],
    'ice.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'constants.F90',
        'broadcast.F90',
        'communicate.F90',
        'io_types.F90',
        'time_management.F90',
        'exit_mod.F90',
        'prognostic.F90',
        'passive_tracers.F90',
        'grid.F90',
    ],
    'initial.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_SolversMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'communicate.F90',
        'budget_diagnostics.F90',
        'broadcast.F90',
        'prognostic.F90',
        'grid.F90',
        'io.F90',
        'io_tools.F90',
        'baroclinic.F90',
        'barotropic.F90',
        'pressure_grad.F90',
        'surface_hgt.F90',
        'vertical_mix.F90',
        'vmix_kpp.F90',
        'horizontal_mix.F90',
        'advection.F90',
        'diagnostics.F90',
        'state_mod.F90',
        'time_management.F90',
        'topostress.F90',
        'ice.F90',
        'output.F90',
        'tavg.F90',
        'forcing.F90',
        'forcing_sfwf.F90',
        'forcing_shf.F90',
        'forcing_ws.F90',
        'sw_absorption.F90',
        'passive_tracers.F90',
        'ecosys_mod.F90',
        'exit_mod.F90',
        'restart.F90',
        'ms_balance.F90',
        'forcing_coupled.F90',
        'global_reductions.F90',
        'timers.F90',
        'registry.F90',
        'qflux_mod.F90',
        'tidal_mixing.F90',
        'step_mod.F90',
        'gather_scatter.F90',
        'shr_ncread_mod.F90',
        'shr_map_mod.F90',
        'overflows.F90',
    ],
    'io.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'communicate.F90',
        'broadcast.F90',
        'exit_mod.F90',
        'domain.F90',
        'constants.F90',
        'io_netcdf.F90',
        'io_binary.F90',
        'io_types.F90',
    ],
    'io_binary.F90' => [
        'POP_CommMod.F90',
        'kinds_mod.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'communicate.F90',
        'broadcast.F90',
        'gather_scatter.F90',
        'exit_mod.F90',
        'io_types.F90',
    ],
    'io_ccsm.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'communicate.F90',
        'broadcast.F90',
        'exit_mod.F90',
        'domain.F90',
        'constants.F90',
        'io_netcdf.F90',
        'io_binary.F90',
        'io_types.F90',
        'io_tools.F90',
    ],
    'io_netcdf.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_ErrorMod.F90',
        'kinds_mod.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'communicate.F90',
        'broadcast.F90',
        'gather_scatter.F90',
        'exit_mod.F90',
        'io_types.F90',
        'io_tools.F90',
        'io_pio.F90',
        'pio.F90',
        'shr_sys_mod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
    ],
    'io_pio.F90' => [
        'kinds_mod.F90',
        'broadcast.F90',
        'communicate.F90',
        'exit_mod.F90',
        'POP_IOUnitsMod.F90',
        'io_types.F90',
        'pio.F90',
        'shr_string_mod.F90',
        'blocks.F90',
        'domain.F90',
        'POP_DomainSizeMod.F90',
    ],
    'io_tools.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'kinds_mod.F90',
        'io_types.F90',
        'communicate.F90',
    ],
    'io_types.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'kinds_mod.F90',
        'constants.F90',
        'communicate.F90',
        'broadcast.F90',
        'exit_mod.F90',
        'shr_file_mod.F90',
        'pio.F90',
    ],
    'mix_submeso.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_ErrorMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'domain.F90',
        'constants.F90',
        'broadcast.F90',
        'grid.F90',
        'io.F90',
        'vertical_mix.F90',
        'vmix_kpp.F90',
        'time_management.F90',
        'tavg.F90',
        'exit_mod.F90',
        'registry.F90',
        'communicate.F90',
        'hmix_gm_submeso_share.F90',
        'shr_sys_mod.F90',
    ],
    'movie.F90' => [
        'POP_IOUnitsMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'constants.F90',
        'prognostic.F90',
        'grid.F90',
        'time_management.F90',
        'registry.F90',
        'global_reductions.F90',
        'broadcast.F90',
        'io.F90',
        'exit_mod.F90',
    ],
    'ms_balance.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'kinds_mod.F90',
        'domain_size.F90',
        'domain.F90',
        'global_reductions.F90',
        'gather_scatter.F90',
        'grid.F90',
        'communicate.F90',
        'io_tools.F90',
        'ice.F90',
        'constants.F90',
        'time_management.F90',
    ],
    'msg_mod.F90' => [
        'kinds_mod.F90',
    ],
    'named_field_mod.F90' => [
        'kinds_mod.F90',
        'exit_mod.F90',
        'blocks.F90',
        'domain.F90',
    ],
    'ocn_comp_mct.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_MCT_vars_mod.F90',
        'mct_mod.F90',
        'ESMF_Mod.F90',
        'seq_flds_mod.F90',
        'seq_flds_indices.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
        'seq_timemgr_mod.F90',
        'shr_file_mod.F90',
        'shr_cal_mod.F90',
        'shr_sys_mod.F90',
        'perf_mod.F90',
        'ocn_communicator.F90',
        'kinds_mod.F90',
        'POP_InitMod.F90',
        'communicate.F90',
        'constants.F90',
        'blocks.F90',
        'domain.F90',
        'exit_mod.F90',
        'forcing_shf.F90',
        'forcing_sfwf.F90',
        'forcing_fields.F90',
        'forcing_coupled.F90',
        'ice.F90',
        'grid.F90',
        'global_reductions.F90',
        'io_tools.F90',
        'named_field_mod.F90',
        'prognostic.F90',
        'timers.F90',
        'diagnostics.F90',
        'output.F90',
        'step_mod.F90',
        'time_management.F90',
        'registry.F90',
        'POP_FinalMod.F90',
    ],
    'operators.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'grid.F90',
    ],
    'output.F90' => [
        'kinds_mod.F90',
        'domain.F90',
        'restart.F90',
        'history.F90',
        'movie.F90',
        'overflows.F90',
        'tavg.F90',
        'timers.F90',
    ],
    'overflows.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_BlocksMod.F90',
        'POP_CommMod.F90',
        'POP_ConfigMod.F90',
        'POP_DistributionMod.F90',
        'POP_DomainSizeMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'POP_RedistributeMod.F90',
        'POP_SolversMod.F90',
        'blocks.F90',
        'broadcast.F90',
        'communicate.F90',
        'constants.F90',
        'domain.F90',
        'exit_mod.F90',
        'global_reductions.F90',
        'grid.F90',
        'io_types.F90',
        'kinds_mod.F90',
        'prognostic.F90',
        'time_management.F90',
        'registry.F90',
        'gather_scatter.F90',
        'shr_sys_mod.F90',
    ],
    'passive_tracer_tools.F90' => [
        'kinds_mod.F90',
        'constants.F90',
        'domain_size.F90',
        'domain.F90',
        'exit_mod.F90',
        'communicate.F90',
        'prognostic.F90',
        'io_tools.F90',
        'io.F90',
        'io_types.F90',
    ],
    'passive_tracers.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_IOUnitsMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'communicate.F90',
        'broadcast.F90',
        'prognostic.F90',
        'forcing_shf.F90',
        'io_types.F90',
        'exit_mod.F90',
        'timers.F90',
        'tavg.F90',
        'constants.F90',
        'time_management.F90',
        'grid.F90',
        'registry.F90',
        'io_tools.F90',
        'ecosys_mod.F90',
        'cfc_mod.F90',
        'iage_mod.F90',
    ],
    'pressure_grad.F90' => [
        'kinds_mod.F90',
        'domain_size.F90',
        'blocks.F90',
        'constants.F90',
        'operators.F90',
        'grid.F90',
        'broadcast.F90',
        'communicate.F90',
        'io_types.F90',
        'state_mod.F90',
        'time_management.F90',
        'exit_mod.F90',
    ],
    'prognostic.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
    ],
    'qflux_mod.F90' => [
        'kinds_mod.F90',
        'constants.F90',
        'exit_mod.F90',
        'time_management.F90',
        'tavg.F90',
    ],
    'registry.F90' => [
        'kinds_mod.F90',
        'exit_mod.F90',
        'io_tools.F90',
    ],
    'restart.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'blocks.F90',
        'prognostic.F90',
        'broadcast.F90',
        'communicate.F90',
        'operators.F90',
        'grid.F90',
        'io.F90',
        'io_types.F90',
        'time_management.F90',
        'ice.F90',
        'forcing_fields.F90',
        'forcing_ap.F90',
        'forcing_ws.F90',
        'forcing_shf.F90',
        'forcing_sfwf.F90',
        'forcing_pt_interior.F90',
        'forcing_s_interior.F90',
        'exit_mod.F90',
        'registry.F90',
        'passive_tracers.F90',
        'overflows.F90',
    ],
    'spacecurve_mod.F90' => [
        'kinds_mod.F90',
    ],
    'state_mod.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'constants.F90',
        'grid.F90',
        'io.F90',
        'broadcast.F90',
        'time_management.F90',
        'exit_mod.F90',
        'shr_vmath_mod.F90',
    ],
    'step_mod.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_CommMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'prognostic.F90',
        'timers.F90',
        'grid.F90',
        'diagnostics.F90',
        'state_mod.F90',
        'time_management.F90',
        'baroclinic.F90',
        'barotropic.F90',
        'surface_hgt.F90',
        'tavg.F90',
        'forcing_fields.F90',
        'forcing.F90',
        'ice.F90',
        'passive_tracers.F90',
        'registry.F90',
        'communicate.F90',
        'io_types.F90',
        'budget_diagnostics.F90',
        'overflows.F90',
    ],
    'surface_hgt.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'prognostic.F90',
        'forcing_fields.F90',
        'grid.F90',
        'time_management.F90',
        'tavg.F90',
        'movie.F90',
    ],
    'sw_absorption.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'kinds_mod.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'io.F90',
        'io_types.F90',
        'grid.F90',
        'forcing_tools.F90',
        'time_management.F90',
        'prognostic.F90',
        'forcing_shf.F90',
        'tavg.F90',
        'exit_mod.F90',
        'registry.F90',
        'named_field_mod.F90',
    ],
    'tavg.F90' => [
        'POP_KindsMod.F90',
        'POP_IOUnitsMod.F90',
        'POP_ErrorMod.F90',
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'constants.F90',
        'prognostic.F90',
        'grid.F90',
        'time_management.F90',
        'global_reductions.F90',
        'broadcast.F90',
        'io.F90',
        'io_types.F90',
        'exit_mod.F90',
        'gather_scatter.F90',
        'operators.F90',
        'io_ccsm.F90',
        'io_tools.F90',
        'diag_bsf.F90',
        'diags_on_lat_aux_grid.F90',
        'registry.F90',
        'timers.F90',
    ],
    'tidal_mixing.F90' => [
        'kinds_mod.F90',
        'domain_size.F90',
        'domain.F90',
        'blocks.F90',
        'io.F90',
        'io_types.F90',
        'constants.F90',
        'exit_mod.F90',
        'grid.F90',
        'communicate.F90',
        'global_reductions.F90',
        'broadcast.F90',
        'tavg.F90',
    ],
    'time_management.F90' => [
        'kinds_mod.F90',
        'constants.F90',
        'blocks.F90',
        'domain_size.F90',
        'domain.F90',
        'broadcast.F90',
        'grid.F90',
        'io.F90',
        'io_tools.F90',
        'exit_mod.F90',
        'registry.F90',
    ],
    'timers.F90' => [
        'kinds_mod.F90',
        'constants.F90',
        'domain.F90',
        'global_reductions.F90',
        'io.F90',
        'exit_mod.F90',
        'perf_mod.F90',
    ],
    'topostress.F90' => [
        'POP_KindsMod.F90',
        'POP_ErrorMod.F90',
        'POP_FieldMod.F90',
        'POP_GridHorzMod.F90',
        'POP_HaloMod.F90',
        'domain.F90',
        'blocks.F90',
        'distribution.F90',
        'constants.F90',
        'io.F90',
        'grid.F90',
        'broadcast.F90',
        'exit_mod.F90',
    ],
    'tracer_types.F90' => [
        'kinds_mod.F90',
    ],
    'vertical_mix.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'constants.F90',
        'grid.F90',
        'state_mod.F90',
        'broadcast.F90',
        'io.F90',
        'timers.F90',
        'tavg.F90',
        'time_management.F90',
        'diagnostics.F90',
        'vmix_const.F90',
        'vmix_rich.F90',
        'vmix_kpp.F90',
        'exit_mod.F90',
        'prognostic.F90',
    ],
    'vmix_const.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'grid.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'broadcast.F90',
        'io.F90',
        'state_mod.F90',
        'exit_mod.F90',
    ],
    'vmix_kpp.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain_size.F90',
        'domain.F90',
        'constants.F90',
        'grid.F90',
        'broadcast.F90',
        'io.F90',
        'state_mod.F90',
        'exit_mod.F90',
        'sw_absorption.F90',
        'tavg.F90',
        'io_types.F90',
        'communicate.F90',
        'tidal_mixing.F90',
        'registry.F90',
        'prognostic.F90',
        'time_management.F90',
    ],
    'vmix_rich.F90' => [
        'kinds_mod.F90',
        'blocks.F90',
        'distribution.F90',
        'domain.F90',
        'constants.F90',
        'grid.F90',
        'broadcast.F90',
        'io.F90',
        'state_mod.F90',
        'time_management.F90',
        'exit_mod.F90',
    ],
    'glc_comp_mct.F90' => [
        'mct_mod.F90',
        'ESMF_Mod.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'ccsm_driver.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_const_mod.F90',
        'shr_file_mod.F90',
        'shr_scam_mod.F90',
        'shr_map_mod.F90',
        'shr_mpi_mod.F90',
        'shr_mem_mod.F90',
        'mct_mod.F90',
        'perf_mod.F90',
        'ESMF_Mod.F90',
        'atm_comp_mct.F90',
        'lnd_comp_mct.F90',
        'ocn_comp_mct.F90',
        'ice_comp_mct.F90',
        'glc_comp_mct.F90',
        'seq_avdata_mod.F90',
        'seq_diag_mct.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'seq_timemgr_mod.F90',
        'seq_infodata_mod.F90',
        'seq_cdata_mod.F90',
        'seq_domain_mct.F90',
        'seq_flux_mct.F90',
        'seq_frac_mct.F90',
        'seq_rest_mod.F90',
        'seq_hist_mod.F90',
        'seq_io_mod.F90',
        'mrg_x2a_mct.F90',
        'mrg_x2l_mct.F90',
        'mrg_x2o_mct.F90',
        'mrg_x2i_mct.F90',
        'mrg_x2g_mct.F90',
        'mrg_x2s_mct.F90',
        'map_atmlnd_mct.F90',
        'map_atmice_mct.F90',
        'map_atmocn_mct.F90',
        'map_iceocn_mct.F90',
        'map_rofocn_mct.F90',
        'map_snoglc_mct.F90',
        'map_ocnocn_mct.F90',
        'map_iceice_mct.F90',
        'map_lndlnd_mct.F90',
        'map_rofrof_mct.F90',
        'map_atmatm_mct.F90',
        'map_glcglc_mct.F90',
        'map_snosno_mct.F90',
    ],
    'map_atmatm_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
    ],
    'map_atmice_mct.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_flds_indices.F90',
        'seq_cdata_mod.F90',
        'seq_comm_mct.F90',
        'seq_infodata_mod.F90',
        'm_die.F90',
    ],
    'map_atmlnd_mct.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_const_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_flds_indices.F90',
        'seq_infodata_mod.F90',
        'm_die.F90',
    ],
    'map_atmocn_mct.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_const_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_flds_indices.F90',
        'seq_infodata_mod.F90',
        'm_die.F90',
    ],
    'map_glcglc_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
    ],
    'map_iceice_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
    ],
    'map_iceocn_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_cdata_mod.F90',
        'seq_comm_mct.F90',
    ],
    'map_lndlnd_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
    ],
    'map_ocnocn_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
    ],
    'map_rofocn_mct.F90' => [
        'shr_sys_mod.F90',
        'shr_mct_mod.F90',
        'mct_mod.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'map_rofrof_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
    ],
    'map_snoglc_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_cdata_mod.F90',
        'seq_comm_mct.F90',
    ],
    'map_snosno_mct.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_rearr_mod.F90',
    ],
    'mrg_x2a_mct.F90' => [
        'shr_kind_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
    ],
    'mrg_x2g_mct.F90' => [
        'shr_kind_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
    ],
    'mrg_x2i_mct.F90' => [
        'shr_kind_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'mrg_x2l_mct.F90' => [
        'shr_kind_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
    ],
    'mrg_x2o_mct.F90' => [
        'shr_kind_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'mrg_x2s_mct.F90' => [
        'shr_kind_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
    ],
    'seq_avdata_mod.F90' => [
        'shr_kind_mod.F90',
        'mct_mod.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'seq_diag_mct.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_mpi_mod.F90',
        'shr_const_mod.F90',
        'mct_mod.F90',
        'ESMF_Mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_timemgr_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'seq_domain_mct.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_mpi_mod.F90',
        'mct_mod.F90',
        'seq_cdata_mod.F90',
        'seq_comm_mct.F90',
        'seq_infodata_mod.F90',
        'map_atmlnd_mct.F90',
        'map_atmocn_mct.F90',
        'map_atmice_mct.F90',
        'map_iceocn_mct.F90',
        'map_snoglc_mct.F90',
    ],
    'seq_flux_mct.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_flux_mod.F90',
        'shr_orb_mod.F90',
        'mct_mod.F90',
        'seq_flds_indices.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
    ],
    'seq_frac_mct.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_const_mod.F90',
        'mct_mod.F90',
        'seq_cdata_mod.F90',
        'map_iceocn_mct.F90',
        'map_atmice_mct.F90',
        'map_atmocn_mct.F90',
        'map_atmlnd_mct.F90',
        'seq_comm_mct.F90',
    ],
    'seq_hist_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_cal_mod.F90',
        'mct_mod.F90',
        'ESMF_Mod.F90',
        'seq_avdata_mod.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
        'seq_timemgr_mod.F90',
        'seq_io_mod.F90',
    ],
    'seq_rearr_mod.F90' => [
        'shr_sys_mod.F90',
        'mct_mod.F90',
        'seq_flds_mod.F90',
        'seq_cdata_mod.F90',
        'seq_comm_mct.F90',
        'seq_diag_mct.F90',
        'shr_kind_mod.F90',
    ],
    'seq_rest_mod.F90' => [
        'shr_kind_mod.F90',
        'shr_sys_mod.F90',
        'shr_mpi_mod.F90',
        'shr_cal_mod.F90',
        'shr_file_mod.F90',
        'mct_mod.F90',
        'ESMF_Mod.F90',
        'seq_avdata_mod.F90',
        'seq_diag_mct.F90',
        'seq_comm_mct.F90',
        'seq_cdata_mod.F90',
        'seq_infodata_mod.F90',
        'seq_timemgr_mod.F90',
        'seq_io_mod.F90',
    ],

);

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
