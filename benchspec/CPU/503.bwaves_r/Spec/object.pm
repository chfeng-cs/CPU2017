$benchnum  = '503';
$benchname = 'bwaves_r';
$exename   = 'bwaves_r';
$benchlang = 'F';       # was F77, in the olden days
@base_exe  = ($exename);

$bench_fppflags = '-w -DSPEC_AUTO_SUPPRESS_OPENMP';

$reltol = {
    'bwaves_1.out'    => 0.015,
    'bwaves_2.out'    => 0.015,
    'bwaves_3.out'    => 0.015,
    'bwaves_4.out'    => 0.015,
    'test1_dqnrm.log' => 0.001,
    'test2_dqnrm.log' => 0.001,
    'train1_dqnrm.log' => 0.001,
    'train2_dqnrm.log' => 0.001,
    'refspeed1_dqnrm.log' => 0.001,
    'refspeed2_dqnrm.log' => 0.001,
    'refrate1_dqnrm.log' => 0.001,
    'refrate2_dqnrm.log' => 0.001,
    'refrate3_dqnrm.log' => 0.001,
    'refrate4_dqnrm.log' => 0.001,
    'default' => undef,
};

$abstol = {
    'bwaves_1.out'   => 1.0e-16,
    'bwaves_2.out'   => 1.0e-16,
    'bwaves_3.out'   => 1.0e-16,
    'bwaves_4.out'   => 1.0e-16,
    'test1_resid.log' => 1.0e-6,
    'test2_resid.log' => 1.0e-6,
    'train1_resid.log' => 1.0e-6,
    'train2_resid.log' => 1.0e-6,
    'refspeed1_resid.log' => 1.0e-6,
    'refspeed2_resid.log' => 1.0e-6,
    'refrate1_resid.log' => 1.0e-6,
    'refrate2_resid.log' => 1.0e-6,
    'refrate3_resid.log' => 1.0e-6,
    'refrate4_resid.log' => 1.0e-6,
    'default' => undef,
};

@sources = (qw(
    block_solver.F
    flow_lam.F
    flux_lam.F
    jacobian_lam.F
    shell_lam.F
    fill1.F
    fill2.F
    ));

sub invoke {
    my ($me) = @_;
    my (@rc);

    my @temp = main::read_file('control');
    my $exe = $me->exe_file;

    for my $line (@temp) {
        my ($dirname) = split(/\s+/, $line);
        next if $dirname =~ m/^\s*(?:#|$)/;
        push (@rc, { 'command' => $exe,
                'args'    => [ "$dirname" ],
                'input'   => "$dirname.in",
                'output'  => "$dirname.out",
                'error'   => "$dirname.err",
            });
    }
    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
