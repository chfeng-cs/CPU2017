$benchnum  = '525';
$benchname = 'x264_r';
$exename   = 'x264_r';
$benchlang = 'C';
$need_math = 'yes';
@base_exe  = (qw/x264_r ldecod_r imagevalidate_525/);

$reltol = { 'default'   => 0.085 };

use Config;
$bench_flags = '-Ildecod_src/inc -Ix264_src -Ix264_src/extras -Ix264_src/common -DSPEC_AUTO_SUPPRESS_OPENMP -DSPEC_AUTO_BYTEORDER=0x'.$Config{'byteorder'};

# No point in continuing if one of the workloads fails
$dependent_workloads = 1;

%workloads = (
    'refspeed' => [ 'refrate' ],
);

%sources=(
    'x264_r' => [ qw(
        x264_src/common/mc.c
        x264_src/common/predict.c
        x264_src/common/pixel.c
        x264_src/common/macroblock.c
        x264_src/common/frame.c
        x264_src/common/dct.c
        x264_src/common/cpu.c
        x264_src/common/cabac.c
        x264_src/common/common.c
        x264_src/common/mdate.c
        x264_src/common/rectangle.c
        x264_src/common/set.c
        x264_src/common/quant.c
        x264_src/common/deblock.c
        x264_src/common/vlc.c
        x264_src/common/mvpred.c
        x264_src/encoder/analyse.c
        x264_src/encoder/me.c
        x264_src/encoder/ratecontrol.c
        x264_src/encoder/set.c
        x264_src/encoder/macroblock.c
        x264_src/encoder/cabac.c
        x264_src/encoder/cavlc.c
        x264_src/encoder/encoder.c
        x264_src/encoder/lookahead.c
        x264_src/input/timecode.c
        x264_src/input/yuv.c
        x264_src/input/y4m.c
        x264_src/output/raw.c
        x264_src/output/matroska.c
        x264_src/output/matroska_ebml.c
        x264_src/output/flv.c
        x264_src/output/flv_bytestream.c
        x264_src/input/thread.c
        x264_src/x264.c
        x264_src/extras/getopt.c
        )],
    'ldecod_r' => [qw(
        ldecod_src/nal.c
        ldecod_src/mbuffer_mvc.c
        ldecod_src/image.c
        ldecod_src/mb_access.c
        ldecod_src/memalloc.c
        ldecod_src/mc_prediction.c
        ldecod_src/mb_prediction.c
        ldecod_src/intra4x4_pred_mbaff.c
        ldecod_src/loop_filter_mbaff.c
        ldecod_src/context_ini.c
        ldecod_src/configfile.c
        ldecod_src/cabac.c
        ldecod_src/sei.c
        ldecod_src/leaky_bucket.c
        ldecod_src/filehandle.c
        ldecod_src/errorconcealment.c
        ldecod_src/decoder_test.c
        ldecod_src/img_process.c
        ldecod_src/mv_prediction.c
        ldecod_src/fmo.c
        ldecod_src/output.c
        ldecod_src/mc_direct.c
        ldecod_src/rtp.c
        ldecod_src/nalucommon.c
        ldecod_src/config_common.c
        ldecod_src/intra_chroma_pred.c
        ldecod_src/transform8x8.c
        ldecod_src/blk_prediction.c
        ldecod_src/intra8x8_pred_mbaff.c
        ldecod_src/erc_do_i.c
        ldecod_src/io_tiff.c
        ldecod_src/mbuffer.c
        ldecod_src/block.c
        ldecod_src/intra4x4_pred.c
        ldecod_src/transform.c
        ldecod_src/annexb.c
        ldecod_src/ldecod.c
        ldecod_src/macroblock.c
        ldecod_src/vlc.c
        ldecod_src/parset.c
        ldecod_src/loop_filter_normal.c
        ldecod_src/parsetcommon.c
        ldecod_src/erc_do_p.c
        ldecod_src/loopFilter.c
        ldecod_src/intra16x16_pred_mbaff.c
        ldecod_src/intra4x4_pred_normal.c
        ldecod_src/intra16x16_pred_normal.c
        ldecod_src/win32.c
        ldecod_src/intra16x16_pred.c
        ldecod_src/intra8x8_pred_normal.c
        ldecod_src/io_raw.c
        ldecod_src/img_io.c
        ldecod_src/nalu.c
        ldecod_src/quant.c
        ldecod_src/intra8x8_pred.c
        ldecod_src/erc_api.c
        ldecod_src/header.c
        ldecod_src/biaridecod.c
        ldecod_src/input.c
        )],
    'imagevalidate_525' => [qw(
        image_validator/ImageValidator.c
        )],

);

# Setup for 625.x264_s
foreach my $exe (keys %sources) {
    my $newexe = $exe;
    $newexe =~ s/_r$/_s/;
    $newexe =~ s/_525/_625/;
    $sources{$newexe} = $sources{$exe};
}

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
