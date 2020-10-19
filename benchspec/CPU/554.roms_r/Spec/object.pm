$benchnum  = '554';
$benchname = 'roms_r';
$exename   = 'roms_r';
$benchlang = 'F';
@base_exe  = ($exename);

$bench_fppflags = '-w -m literal-single.pm -m c-comment.pm -I. -DBENCHMARK -DNestedGrids=1 -DNO_GETTIMEOFDAY -DSPEC_AUTO_SUPPRESS_OPENMP';
$bench_fflags = '-I.';

$bench_cflags = '-I. -DSPEC_AUTO_SUPPRESS_OPENMP';

$reltol = 1.0e-7;
$abstol = 1.0e-7;

@sources = (qw(
    bbl.F90
    bc_2d.F90
    exchange_2d.F90
    mod_param.F90
    mod_kinds.F90
    mod_grid.F90
    mod_scalars.F90
    mod_bbl.F90
    mod_forces.F90
    mod_ocean.F90
    mod_sediment.F90
    mod_parallel.F90
    mod_iounits.F90
    mod_strings.F90
    mod_stepping.F90
    mp_exchange.F90
    bc_3d.F90
    exchange_3d.F90
    bc_bry2d.F90
    bc_bry3d.F90
    bulk_flux.F90
    mod_mixing.F90
    bvf_mix.F90
    conv_2d.F90
    conv_3d.F90
    conv_bry2d.F90
    conv_bry3d.F90
    diag.F90
    analytical.F90
    distribute.F90
    mod_ncparam.F90
    mod_biology.F90
    mod_eclight.F90
    mod_boundary.F90
    mod_clima.F90
    mod_sources.F90
    mod_netcdf.F90
    strings.F90
    forcing.F90
    mod_coupling.F90
    frc_adjust.F90
    get_data.F90
    mod_obs.F90
    get_idata.F90
    mod_tides.F90
    nf_fread3d.F90
    nf_fread4d.F90
    gls_corstep.F90
    tkebc_im.F90
    gls_prestep.F90
    hmixing.F90
    ini_fields.F90
    set_depth.F90
    t3dbc_im.F90
    u2dbc_im.F90
    u3dbc_im.F90
    v2dbc_im.F90
    v3dbc_im.F90
    zetabc.F90
    initial.F90
    ini_adjust.F90
    mod_fourdvar.F90
    state_addition.F90
    state_copy.F90
    metrics.F90
    ocean_coupler.F90
    mod_coupler.F90
    roms_export.F90
    roms_import.F90
    omega.F90
    rho_eos.F90
    mod_eoscoef.F90
    set_massflux.F90
    stiffness.F90
    wpoints.F90
    mod_storage.F90
    interp_floats.F90
    lmd_bkpp.F90
    shapiro.F90
    lmd_skpp.F90
    lmd_swfrac.F90
    lmd_vmix.F90
    main2d.F90
    dotproduct.F90
    obc_adjust.F90
    oi_update.F90
    radiation_stress.F90
    mod_diags.F90
    set_avg.F90
    mod_average.F90
    set_tides.F90
    set_vbc.F90
    step2d.F90
    obc_volcons.F90
    wetdry.F90
    step_floats.F90
    mod_floats.F90
    vwalk_floats.F90
    utility.F90
    main3d.F90
    biology.F90
    my25_corstep.F90
    my25_prestep.F90
    rhs3d.F90
    pre_step3d.F90
    prsgrd.F90
    t3dmix.F90
    uv3dmix.F90
    sediment.F90
    sed_bed.F90
    sed_bedload.F90
    sed_fluxes.F90
    sed_settling.F90
    sed_surface.F90
    set_zeta.F90
    step3d_t.F90
    mpdata_adiff.F90
    step3d_uv.F90
    wvelocity.F90
    output.F90
    set_data.F90
    set_2dfld.F90
    set_3dfld.F90
    abort.F90
    ocean_control.F90
    back_cost.F90
    cgradient.F90
    nf_fread2d.F90
    nf_fread2d_bry.F90
    nf_fread3d_bry.F90
    state_dotprod.F90
    state_initialize.F90
    state_scale.F90
    cost_grad.F90
    normalization.F90
    nf_fwrite2d.F90
    nf_fwrite3d.F90
    white_noise.F90
    nrutil.F90
    packing.F90
    posterior.F90
    posterior_var.F90
    state_product.F90
    propagator.F90
    random_ic.F90
    sum_grad.F90
    zeta_balance.F90
    checkadj.F90
    checkdefs.F90
    checkerror.F90
    checkvars.F90
    close_io.F90
    congrad.F90
    def_avg.F90
    def_var.F90
    def_diags.F90
    def_dim.F90
    def_error.F90
    def_floats.F90
    def_gst.F90
    def_hessian.F90
    def_his.F90
    def_impulse.F90
    def_info.F90
    def_ini.F90
    def_lanczos.F90
    def_mod.F90
    def_norm.F90
    def_rst.F90
    def_station.F90
    def_tides.F90
    extract_obs.F90
    extract_sta.F90
    frc_weak.F90
    gasdev.F90
    get_2dfld.F90
    get_2dfldr.F90
    get_3dfld.F90
    get_3dfldr.F90
    get_bounds.F90
    get_cycle.F90
    get_date.F90
    get_grid.F90
    get_gst.F90
    get_ngfld.F90
    get_ngfldr.F90
    get_state.F90
    get_varcoords.F90
    grid_coords.F90
    interpolate.F90
    ini_lanczos.F90
    inp_par.F90
    ran_state.F90
    lubksb.F90
    ludcmp.F90
    mp_routines.F90
    nf_fwrite2d_bry.F90
    nf_fwrite3d_bry.F90
    nf_fwrite4d.F90
    obs_cost.F90
    obs_depth.F90
    obs_initial.F90
    obs_read.F90
    obs_write.F90
    ran1.F90
    regrid.F90
    rep_matrix.F90
    set_2dfldr.F90
    set_3dfldr.F90
    set_diags.F90
    set_ngfld.F90
    set_ngfldr.F90
    set_scoord.F90
    set_weights.F90
    stats_modobs.F90
    timers.F90
    wrt_avg.F90
    wrt_diags.F90
    wrt_error.F90
    wrt_floats.F90
    wrt_gst.F90
    wrt_hessian.F90
    wrt_his.F90
    wrt_impulse.F90
    wrt_info.F90
    wrt_ini.F90
    wrt_rst.F90
    wrt_station.F90
    wrt_tides.F90
    mod_arrays.F90
    mod_nesting.F90
    esmf_roms.F90
    master.F90
    ));

sub invoke {
    my ($me) = @_;
    my $name = $me->name;
    my @rc;

    my $exe = $me->exe_file;
    foreach my $input ($me->input_files_base) {
        next if $input =~ /varinfo.dat/;
        my $outname = $input;
        $outname =~ s/\.in.x$//;
        push @rc, {
            'command' => $me->exe_file,
            'args'    => [ ],
            'output'  => "$outname.log",
            'error'   => "$outname.err",
            'input'   => "$outname.in.x",
        };
    }
    return @rc;
}

%deps = (
    'bc_2d.F90' => [
        'mod_param.F90',
        'exchange_2d.F90',
        'mod_grid.F90',
        'mod_scalars.F90',
    ],
    'exchange_2d.F90' => [
        'mod_param.F90',
    ],
    'mod_param.F90' => [
        'mod_kinds.F90',
    ],
    'mod_grid.F90' => [
        'mod_kinds.F90',
        'mod_param.F90',
    ],
    'mod_scalars.F90' => [
        'mod_param.F90',
    ],
    'mod_forces.F90' => [
        'mod_kinds.F90',
        'mod_param.F90',
    ],
    'mod_ocean.F90' => [
        'mod_kinds.F90',
        'mod_param.F90',
    ],
    'mod_parallel.F90' => [
        'mod_param.F90',
        'mod_strings.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
    ],
    'mod_iounits.F90' => [
        'mod_param.F90',
    ],
    'mod_stepping.F90' => [
        'mod_param.F90',
    ],
    'bc_3d.F90' => [
        'mod_param.F90',
        'exchange_3d.F90',
        'mod_grid.F90',
        'mod_scalars.F90',
    ],
    'exchange_3d.F90' => [
        'mod_param.F90',
    ],
    'bc_bry2d.F90' => [
        'mod_param.F90',
        'mod_scalars.F90',
    ],
    'bc_bry3d.F90' => [
        'mod_param.F90',
        'mod_scalars.F90',
    ],
    'bulk_flux.F90' => [
        'mod_param.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
        'mod_kinds.F90',
    ],
    'mod_mixing.F90' => [
        'mod_kinds.F90',
        'mod_param.F90',
        'mod_scalars.F90',
    ],
    'diag.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
    ],
    'analytical.F90' => [
        'mod_param.F90',
        'mod_forces.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
        'mod_grid.F90',
        'mod_parallel.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
    ],
    'mod_ncparam.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
    ],
    'mod_netcdf.F90' => [
        'mod_kinds.F90',
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
        'mod_ncparam.F90',
    ],
    'mod_coupling.F90' => [
        'mod_kinds.F90',
        'mod_param.F90',
    ],
    'get_data.F90' => [
        'mod_param.F90',
        'mod_boundary.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
        'mod_stepping.F90',
    ],
    'nf_fread3d.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'nf_fread4d.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'ini_fields.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_coupling.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
        'exchange_3d.F90',
        'set_depth.F90',
        't3dbc_im.F90',
        'u3dbc_im.F90',
        'v3dbc_im.F90',
        'u2dbc_im.F90',
        'v2dbc_im.F90',
        'zetabc.F90',
    ],
    'set_depth.F90' => [
        'mod_param.F90',
        'mod_coupling.F90',
        'mod_grid.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
        'exchange_3d.F90',
    ],
    't3dbc_im.F90' => [
        'mod_param.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_boundary.F90',
        'mod_grid.F90',
        'mod_scalars.F90',
    ],
    'u2dbc_im.F90' => [
        'mod_param.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_boundary.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_scalars.F90',
    ],
    'u3dbc_im.F90' => [
        'mod_param.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_boundary.F90',
        'mod_grid.F90',
        'mod_scalars.F90',
    ],
    'v2dbc_im.F90' => [
        'mod_param.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_boundary.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_scalars.F90',
    ],
    'v3dbc_im.F90' => [
        'mod_param.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_boundary.F90',
        'mod_grid.F90',
        'mod_scalars.F90',
    ],
    'zetabc.F90' => [
        'mod_param.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_boundary.F90',
        'mod_grid.F90',
        'mod_scalars.F90',
    ],
    'initial.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_ocean.F90',
        'mod_scalars.F90',
        'mod_stepping.F90',
        'analytical.F90',
        'metrics.F90',
        'set_depth.F90',
        'omega.F90',
        'rho_eos.F90',
        'set_massflux.F90',
        'stiffness.F90',
    ],
    'state_addition.F90' => [
        'mod_param.F90',
    ],
    'state_copy.F90' => [
        'mod_param.F90',
    ],
    'metrics.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
        'set_depth.F90',
    ],
    'omega.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_ocean.F90',
        'mod_scalars.F90',
        'bc_3d.F90',
    ],
    'rho_eos.F90' => [
        'mod_param.F90',
        'mod_coupling.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_eoscoef.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
        'exchange_3d.F90',
    ],
    'mod_eoscoef.F90' => [
        'mod_kinds.F90',
    ],
    'set_massflux.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'exchange_3d.F90',
    ],
    'stiffness.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_ocean.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
    ],
    'shapiro.F90' => [
        'mod_param.F90',
    ],
    'lmd_skpp.F90' => [
        'mod_param.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'bc_2d.F90',
    ],
    'lmd_swfrac.F90' => [
        'mod_param.F90',
        'mod_mixing.F90',
        'mod_scalars.F90',
    ],
    'lmd_vmix.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'lmd_skpp.F90',
        'mod_scalars.F90',
        'bc_3d.F90',
    ],
    'set_vbc.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_forces.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'bc_2d.F90',
    ],
    'step2d.F90' => [
        'mod_param.F90',
        'mod_coupling.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
        'u2dbc_im.F90',
        'v2dbc_im.F90',
        'zetabc.F90',
    ],
    'utility.F90' => [
        'mod_kinds.F90',
    ],
    'main3d.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
        'mod_stepping.F90',
        'bulk_flux.F90',
        'diag.F90',
        'ini_fields.F90',
        'lmd_vmix.F90',
        'omega.F90',
        'rho_eos.F90',
        'rhs3d.F90',
        'set_depth.F90',
        'set_massflux.F90',
        'set_vbc.F90',
        'set_zeta.F90',
        'step2d.F90',
        'step3d_t.F90',
        'step3d_uv.F90',
        'wvelocity.F90',
    ],
    'rhs3d.F90' => [
        'mod_param.F90',
        'mod_coupling.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'pre_step3d.F90',
        'prsgrd.F90',
        't3dmix.F90',
        'uv3dmix.F90',
        'mod_scalars.F90',
    ],
    'pre_step3d.F90' => [
        'mod_param.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'exchange_3d.F90',
        't3dbc_im.F90',
    ],
    'prsgrd.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
    ],
    't3dmix.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
    ],
    'uv3dmix.F90' => [
        'mod_param.F90',
        'mod_coupling.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
    ],
    'set_zeta.F90' => [
        'mod_param.F90',
        'mod_coupling.F90',
        'mod_ocean.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
    ],
    'step3d_t.F90' => [
        'mod_param.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
        'exchange_3d.F90',
        't3dbc_im.F90',
    ],
    'step3d_uv.F90' => [
        'mod_param.F90',
        'mod_coupling.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
        'exchange_3d.F90',
        'u3dbc_im.F90',
        'v3dbc_im.F90',
    ],
    'wvelocity.F90' => [
        'mod_param.F90',
        'mod_coupling.F90',
        'mod_grid.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'bc_3d.F90',
        'exchange_2d.F90',
    ],
    'output.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'set_data.F90' => [
        'mod_param.F90',
        'mod_boundary.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ncparam.F90',
        'mod_ocean.F90',
        'mod_stepping.F90',
        'mod_scalars.F90',
        'analytical.F90',
        'exchange_2d.F90',
        'set_2dfld.F90',
        'set_3dfld.F90',
    ],
    'set_2dfld.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
        'exchange_2d.F90',
    ],
    'set_3dfld.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
        'exchange_3d.F90',
    ],
    'abort.F90' => [
        'ocean_control.F90',
    ],
    'ocean_control.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
        'mod_ncparam.F90',
    ],
    'nf_fread2d.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'nf_fread2d_bry.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'nf_fread3d_bry.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'state_dotprod.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_ncparam.F90',
    ],
    'state_initialize.F90' => [
        'mod_param.F90',
    ],
    'state_scale.F90' => [
        'mod_param.F90',
    ],
    'nf_fwrite2d.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'nf_fwrite3d.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'white_noise.F90' => [
        'mod_kinds.F90',
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_scalars.F90',
        'nrutil.F90',
    ],
    'nrutil.F90' => [
        'mod_kinds.F90',
    ],
    'state_product.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_ncparam.F90',
    ],
    'checkadj.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
        'mod_strings.F90',
        'strings.F90',
    ],
    'checkdefs.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
        'mod_strings.F90',
    ],
    'checkerror.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
    ],
    'checkvars.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'close_io.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'def_var.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'def_dim.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'def_his.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
        'def_var.F90',
    ],
    'def_info.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
        'mod_strings.F90',
        'def_var.F90',
    ],
    'def_rst.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
        'def_var.F90',
    ],
    'extract_sta.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_grid.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
    ],
    'gasdev.F90' => [
        'mod_kinds.F90',
        'nrutil.F90',
    ],
    'get_2dfld.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
        'nf_fread2d.F90',
        'nf_fread3d.F90',
    ],
    'get_3dfld.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
        'nf_fread3d.F90',
    ],
    'get_bounds.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_ncparam.F90',
    ],
    'get_cycle.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'get_date.F90' => [
        'mod_kinds.F90',
    ],
    'get_ngfld.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'get_state.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_mixing.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_ocean.F90',
        'mod_scalars.F90',
        'mod_stepping.F90',
        'mod_strings.F90',
        'nf_fread2d.F90',
        'nf_fread3d.F90',
        'nf_fread4d.F90',
        'strings.F90',
    ],
    'get_varcoords.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'interpolate.F90' => [
        'mod_kinds.F90',
        'mod_param.F90',
        'mod_scalars.F90',
    ],
    'inp_par.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
        'ran_state.F90',
        'mod_netcdf.F90',
        'mod_strings.F90',
        'mod_kinds.F90',
    ],
    'ran_state.F90' => [
        'mod_kinds.F90',
        'nrutil.F90',
    ],
    'lubksb.F90' => [
        'mod_kinds.F90',
    ],
    'ludcmp.F90' => [
        'mod_kinds.F90',
    ],
    'mp_routines.F90' => [
        'mod_kinds.F90',
    ],
    'nf_fwrite2d_bry.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'nf_fwrite3d_bry.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'nf_fwrite4d.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
    ],
    'ran1.F90' => [
        'mod_kinds.F90',
        'ran_state.F90',
    ],
    'regrid.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
        'interpolate.F90',
    ],
    'set_ngfld.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_scalars.F90',
    ],
    'set_scoord.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
    ],
    'set_weights.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
    ],
    'timers.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_strings.F90',
    ],
    'wrt_his.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_coupling.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_mixing.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_ocean.F90',
        'mod_scalars.F90',
        'mod_stepping.F90',
        'nf_fwrite2d.F90',
        'nf_fwrite3d.F90',
        'omega.F90',
    ],
    'wrt_info.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_scalars.F90',
        'nf_fwrite2d.F90',
        'strings.F90',
    ],
    'wrt_rst.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_grid.F90',
        'mod_iounits.F90',
        'mod_mixing.F90',
        'mod_ncparam.F90',
        'mod_netcdf.F90',
        'mod_ocean.F90',
        'mod_scalars.F90',
        'mod_stepping.F90',
        'nf_fwrite2d.F90',
        'nf_fwrite3d.F90',
    ],
    'mod_arrays.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_coupling.F90',
        'mod_forces.F90',
        'mod_grid.F90',
        'mod_mixing.F90',
        'mod_ocean.F90',
    ],
    'master.F90' => [
        'mod_param.F90',
        'mod_parallel.F90',
        'mod_iounits.F90',
        'mod_scalars.F90',
        'ocean_control.F90',
    ],

);

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
