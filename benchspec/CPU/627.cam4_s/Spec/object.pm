$benchnum  = '627';
$benchname = 'cam4_s';
$exename   = 'cam4_s';
$benchlang = 'F,C';
@base_exe  = qw(cam4_s cam4_validate_627);
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
$abstol = {
    'cam4_validate'   => 1.0e-16,
    'default' => undef,
};

my $all_lang_inc   = ' -I. -Iinclude -Inetcdf/include';
my $all_lang_flags = '-DNO_SHR_VMATH -DCO2A -DPERGRO -DPLON=144 -DPLAT=96 -DPLEV=26 -DPCNST=3'
                   . ' -DPCOLS=4 -DPTRM=1 -DPTRN=1 -DPTRK=1 -DSTAGGERED -D_NETCDF -DNO_R16'
                   . $all_lang_inc.' -DUSE_COSP';

$bench_fppflags    = $all_lang_flags
                   . ' -w -DHIDE_MPI -D_MPISERIAL -DNO_MPI2';

$bench_fflags      = $all_lang_inc;

$bench_cflags      = $all_lang_flags
                   . ' -DSPEC_AUTO_BYTEORDER=0x'.$Config{'byteorder'};

%workloads = (
    'test'       => [ [ '527.cam4_r' ] ],
    'train'      => [ [ '527.cam4_r' ] ],
    'refspeed'   => [ [ '527.cam4_r' ] ],
    'refrate'    => [ [ '527.cam4_r' ] ],
);

$sources = '527.cam4_r';

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

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
