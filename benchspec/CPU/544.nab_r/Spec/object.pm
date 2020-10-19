$benchnum  = '544';
$benchname = 'nab_r';
$exename   = 'nab_r';
$benchlang = 'C';
@base_exe  = ($exename);

$reltol = 0.01;
$skipreltol = 2;

@sources = (qw(
    nabmd.c
    sff.c
    nblist.c
    prm.c
    memutil.c
    molio.c
    molutil.c
    errormsg.c
    binpos.c
    rand2.c
    select_atoms.c
    reslib.c
    database.c
    traceback.c
    chirvol.c
    specrand/specrand.c
    regex-alpha/regcomp.c
    regex-alpha/regerror.c
    regex-alpha/regexec.c
    regex-alpha/regfree.c
    ));

$need_math = 'yes';
$bench_flags = "-Ispecrand -Iregex-alpha -DNDEBUG -DNOPERFLIB -DNOREDUCE -DSPEC_AUTO_SUPPRESS_OPENMP";

sub invoke {
    my ($me) = @_;
    my (@rc);

    my @temp = main::read_file('control');
    my $exe = $me->exe_file;

    for my $line (@temp) {
        my ($dirname, $seed, $steps) = split(/\s+/, $line);
        $steps = 1000 unless defined($steps) && ($steps > 0);
        next if $dirname =~ m/^\s*(?:#|$)/;
        push @rc, {
            'command' => $exe,
            'args'    => [ $dirname, $seed, $steps ],
            'output'  => "$dirname.out",
            'error'   => "$dirname.err",
        };
    }
    return @rc;
}

%srcdeps = (
    'nabmd.c' => [
        'nabcode.h',
    ],
    'nblist.c' => [
        'defreal.h',
    ],
    'sff.c' => [
        'nab.h',
        'defreal.h',
        'nabtypes.h',
        'memutil.h',
        'eff.c',
        'intersect.c',
        'gbsa.c',
        'debug.h',
    ],
    'prm.c' => [
        'nab.h',
        'defreal.h',
        'nabtypes.h',
        'errormsg.h',
    ],
    'memutil.c' => [
        'nab.h',
        'defreal.h',
        'nabtypes.h',
    ],
    'molio.c' => [
        'nab.h',
        'defreal.h',
        'nabtypes.h',
    ],
    'molutil.c' => [
        'nab.h',
        'defreal.h',
        'nabtypes.h',
        'errormsg.h',
        'memutil.h',
    ],
    'errormsg.c' => [
        'errormsg.h',
    ],
    'binpos.c' => [
        'memutil.h',
    ],
    'rand2.c' => [
        'defreal.h',
    ],
    'select_atoms.c' => [
        'nab.h',
        'defreal.h',
        'nabtypes.h',
    ],
    'reslib.c' => [
        'nab.h',
        'defreal.h',
        'nabtypes.h',
        'errormsg.h',
        'memutil.h',
        'chirvol.h',
        'database.h',
    ],
    'database.c' => [
        'database.h',
    ],
    'traceback.c' => [
        'errormsg.h',
    ],
    'chirvol.c' => [
        'nab.h',
        'defreal.h',
        'nabtypes.h',
    ],
);

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
