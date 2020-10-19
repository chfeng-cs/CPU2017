$benchnum  = '549';
$benchname = 'fotonik3d_r';
$exename   = 'fotonik3d_r';
$benchlang = 'F';
@base_exe  = ($exename);

$floatcompare = 1;
$obiwan       = 1;
$reltol       = 1e-10;
$abstol       = 1e-27;

$bench_flags='-I. -DSPEC_AUTO_SUPPRESS_OPENMP';

@sources = (qw(
    parameter.f90
    globalvar.F90
    readline.f90
    power.F90
    calcflops.F90
    communicate.F90
    huygens.F90
    update.F90
    material.F90
    mur.F90
    PlaneSource.F90
    PEC.F90
    init.F90
    leapfrog.F90
    timerRoutine.f90
    UPML.F90
    yeemain.F90
    writeout.F90
    MPI_dummy.F90
    ));

sub generate_inputs {
    return (
        { 
            'command'   => ::jp($ENV{SPEC}, "bin", "specxz"),
            'args'      => [ '-dc', 'OBJ.dat.xz' ],
            'output'    => 'OBJ.dat',
            'error'     => 'OBJ.dat.gen.err',
            'generates' => [ 
                [ "OBJ.dat", undef ]
            ]
        }
    );
}



sub invoke {
    my ($me) = @_;

    return ({
            'command' => $me->exe_file,
            'args'    => [ ],
            'output'  => $me->name.'.log',
            'error'   => $me->name.'.err',
        });
}

%deps = (
    'calcflops.F90' => [
        'globalvar.F90',
        'power.F90',
        'PlaneSource.F90',
        'parameter.f90',
    ],
    'communicate.F90' => [
        'globalvar.F90',
        'parameter.f90',
    ],
    'globalvar.F90' => [
        'parameter.f90',
    ],
    'huygens.F90' => [
        'globalvar.F90',
        'parameter.f90',
    ],
    'init.F90' => [
        'globalvar.F90',
        'huygens.F90',
        'update.F90',
        'mur.F90',
        'PlaneSource.F90',
        'PEC.F90',
        'power.F90',
        'material.F90',
        'UPML.F90',
        'communicate.F90',
    ],
    'leapfrog.F90' => [
        'parameter.f90',
        'globalvar.F90',
        'huygens.F90',
        'update.F90',
        'mur.F90',
        'PEC.F90',
        'PlaneSource.F90',
        'power.F90',
        'material.F90',
        'UPML.F90',
        'communicate.F90',
    ],
    'material.F90' => [
        'globalvar.F90',
        'parameter.f90',
        'readline.f90',
    ],
    'mur.F90' => [
        'globalvar.F90',
        'material.F90',
        'parameter.f90',
    ],
    'PEC.F90' => [
        'globalvar.F90',
        'parameter.f90',
    ],
    'PlaneSource.F90' => [
        'globalvar.F90',
        'parameter.f90',
        'readline.f90',
    ],
    'power.F90' => [
        'globalvar.F90',
        'parameter.f90',
    ],
    'update.F90' => [
        'globalvar.F90',
        'parameter.f90',
    ],
    'UPML.F90' => [
        'globalvar.F90',
        'material.F90',
        'parameter.f90',
    ],
    'yeemain.F90' => [
        'mur.F90',
        'PEC.F90',
        'PlaneSource.F90',
        'power.F90',
        'communicate.F90',
        'globalvar.F90',
        'UPML.F90',
    ],
    'writeout.F90' => [
        'globalvar.F90',
        'parameter.f90',
    ],
    'MPI_dummy.F90' => [
        'parameter.f90',
    ],
);

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
