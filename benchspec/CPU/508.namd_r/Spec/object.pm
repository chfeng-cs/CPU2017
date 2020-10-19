$benchnum  = '508';
$benchname = 'namd_r';
$exename   = 'namd_r';
$benchlang = 'CXX';
@base_exe  = ($exename);

$abstol =  0.00005;
$bench_cxxflags = "-DNAMD_DISABLE_SSE -DSPEC_AUTO_SUPPRESS_OPENMP";

%workloads = (
    'refspeed' => [ 'refrate' ],
);

@sources = (qw(
    Compute.C
    ComputeList.C
    ComputeNonbondedFEP.C
    ComputeNonbondedLES.C
    ComputeNonbondedPProf.C
    ComputeNonbondedStd.C
    ComputeNonbondedUtil.C
    LJTable.C
    Molecule.C
    Patch.C
    PatchList.C
    ResultSet.C
    SimParameters.C
    erf.C
    spec_namd.C
));

sub invoke {
    my ($me) = @_;
    my $name = $me->name;
    $name =~ s/_[rs]$//;
    my ($arguments, @temp) = main::read_file("${name}.in");
    chomp($arguments);

    return ({ 'command' => $me->exe_file,
            'args'    => [ split(/\s+/, $arguments) ],
            'error'   => "$name.err",
            'output'  => "$name.out",
        });
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
