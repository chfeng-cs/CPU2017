$benchnum  = '625';
$benchname = 'x264_s';
$exename   = 'x264_s';
$benchlang = 'C';
$need_math = 'yes';
@base_exe  = (qw/x264_s ldecod_s imagevalidate_625/);

$reltol = {'default'   => 0.085 };

use Config;
$bench_flags = '-Ildecod_src/inc -Ix264_src -Ix264_src/extras -Ix264_src/common -DSPEC_AUTO_BYTEORDER=0x'.$Config{'byteorder'};

# No point in continuing if one of the workloads fails
$dependent_workloads = 1;

%workloads = (
    'test'       => [ [ '525.x264_r' ] ],
    'train'      => [ [ '525.x264_r' ] ],
    'refspeed'   => [ [ '525.x264_r' ] ],
    'refrate'    => [ [ '525.x264_r' ] ],
);

$sources = '525.x264_r';

use File::Basename;
use Carp;
use Cwd;

# returns a list of hashes containing commands to run and the files they will
# generate.  May be called OUTSIDE of a run directory to just get the list of
# files.
sub generate_inputs {
    my ($me) = @_;

    my @runs;
    my ($files) = $me->input_files_hash;

    # Look in the data directory by default for the control file
    $control_file = exists($files->{'control'}) ? $files->{'control'} : 'control';

    my @maxframes = ::read_file($control_file) or confess("ERROR: During input generation -- unable to open '$control_file' ");
    my ($org_x264, $yuv_output, $yuv_md5, $new_x24, $size, $seek_val, $frames, $frames2, $yuvdump, @validframes) = split /\s+/, $maxframes[0];

    my ($exefile) = (grep { /^ldecod/ } ($me->exe_files));
    confess("Couldn't find ldecod binary to run") unless defined($exefile) and $exefile ne '';
    my $filebase = "inputgen_".basename($exefile, $me->os_exe_ext)."_x264";

    # Decode the h.264 file to create the raw YUV file that the compressor
    # will work on
    return (
        {
            'command'   => $exefile,
            'args'      => [ '-i', $org_x264, '-o', $yuv_output ],
            'output'    => "${filebase}.out",
            'error'     => "${filebase}.err",
            'generates' => [
                [ $yuv_output, (length($yuv_md5) == 32) ? $yuv_md5 : undef ]
            ],
        },
    );
}

sub compare_commands {
    my ($me) = @_;
    my (@rc);
    my @maxframes = ::read_file('control') or confess("ERROR: During run setup -- unable to open 'control' in run directory at ".cwd().' ');
    my ($org_x264, $yuv_output, $yuv_md5, $new_x24, $size, $seek_val, $frames, $frames2, $yuvdump, @validframes) = split /\s+/, $maxframes[0];
    my ($imagevalidate_exe) = (grep { /^imagevalidate/ } $me->exe_files);
    my @cmd;
    my ($comparefiles) = $me->compare_files_hash;

    foreach my $frame (@validframes) {
        my $origfile = $comparefiles->{"frame_${frame}.org.tga"} || "COULD_NOT_LOCATE_frame_${frame}.org.tga_FILE";
        @cmd = (qw(-avg -threshold 0.5 -maxthreshold 20), "frame_${frame}.yuv", $origfile);
        push @rc, (
            {
                'command' => $imagevalidate_exe,
                'args'    => [ @cmd ],
                'output'  => "imagevalidate_frame_${frame}.out",
                'error'   => "imagevalidate_frame_${frame}.err",
            }
        );
    }

    return @rc;
}

sub invoke {
    my ($me) = @_;
    my (@rc);
    my @maxframes = ::read_file('control') or confess("ERROR: During run setup -- unable to open 'control' in run directory at ".cwd().' ');
    my ($org_x264, $yuv_output, $yuv_md5, $new_x24, $size, $seek_val, $frames, $frames2, $yuvdump, @validframes) = split /\s+/, $maxframes[0];
    my ($x264_exe) = (grep { /^x264/ } $me->exe_files);
    my @cmd;
    my @dumpyuv = ($yuvdump ne '') ? ('--dumpyuv', $yuvdump) : ();
    my @io = ('-o', $new_x24, $yuv_output, $size);

    if ($frames2) {
        # Two-pass encode of frames 0-$frames
        my $filebase = sprintf "run_%0*d-%d_%s_x264", int(log($frames) / log(10)) + 1, 0, $frames, basename($x264_exe, '.exe');
        @cmd = (qw(--pass 1 --stats x264_stats.log --bitrate 1000 --frames), $frames, @io);
        push @rc, {
            'command' => $x264_exe,
            'args'    => [ @cmd ],
            'output'  => $filebase.'_pass1.out',
            'error'   => $filebase.'_pass1.err',
        };

        # run pass 2 using the stat file
        @cmd = (qw(--pass 2 --stats x264_stats.log --bitrate 1000), @dumpyuv, '--frames', $frames, @io);
        push @rc, {
            'command' => $x264_exe,
            'args'    => [ @cmd ],
            'output'  => $filebase.'_pass2.out',
            'error'   => $filebase.'_pass2.err',
        };

        # Single-pass encode of frames $seek_val-$frames2
        $filebase = sprintf "run_%0*d-%d_%s_x264", int(log($frames2) / log(10)) + 1, $seek_val, $frames2, basename($x264_exe, '.exe');
        @cmd = ('--seek', $seek_val, @dumpyuv, '--frames', $frames2, @io);
        push @rc, {
            'command' => $x264_exe,
            'args'    => [ @cmd ],
            'output'  => $filebase.'.out',
            'error'   => $filebase.'.err',
        };

    } else {

        # Single-pass encode
        my $filebase = sprintf "run_%0*d-%d_%s_x264", int(log($frames) / log(10)) + 1, 0, $frames, basename($x264_exe, '.exe');
        @cmd = (@dumpyuv, '--frames', $frames, @io);
        push @rc, {
            'command' => $x264_exe,
            'args'    => [ @cmd ],
            'output'  => $filebase.'.out',
            'error'   => $filebase.'.err',
        };

    }

    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
