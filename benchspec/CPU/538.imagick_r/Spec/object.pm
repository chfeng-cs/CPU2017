$benchnum  = '538';
$benchname = 'imagick_r';
$exename   = 'imagick_r';
$benchlang = 'C';
@base_exe  = qw(imagick_r imagevalidate_538);

$reltol = 0.01;

$need_math = 'yes';

%sources = (
    'imagick_r' => [ qw(
        coders/tga.c
        filters/analyze.c
        magick/accelerate.c
        magick/animate.c
        magick/annotate.c
        magick/artifact.c
        magick/attribute.c
        magick/blob.c
        magick/cache-view.c
        magick/cache.c
        magick/channel.c
        magick/cipher.c
        magick/client.c
        magick/coder.c
        magick/color.c
        magick/colormap.c
        magick/colorspace.c
        magick/compare.c
        magick/composite.c
        magick/compress.c
        magick/configure.c
        magick/constitute.c
        magick/decorate.c
        magick/delegate.c
        magick/display.c
        magick/distort.c
        magick/distribute-cache.c
        magick/draw.c
        magick/effect.c
        magick/enhance.c
        magick/exception.c
        magick/feature.c
        magick/fourier.c
        magick/fx.c
        magick/gem.c
        magick/geometry.c
        magick/hashmap.c
        magick/histogram.c
        magick/identify.c
        magick/image.c
        magick/layer.c
        magick/list.c
        magick/locale.c
        magick/log.c
        magick/magic.c
        magick/magick.c
        magick/matrix.c
        magick/memory.c
        magick/mime.c
        magick/module.c
        magick/monitor.c
        magick/montage.c
        magick/morphology.c
        magick/option.c
        magick/paint.c
        magick/pixel.c
        magick/policy.c
        magick/prepress.c
        magick/profile.c
        magick/property.c
        magick/quantize.c
        magick/quantum-export.c
        magick/quantum-import.c
        magick/quantum.c
        magick/random.c
        magick/registry.c
        magick/resample.c
        magick/resize.c
        magick/resource.c
        magick/segment.c
        magick/semaphore.c
        magick/shear.c
        magick/signature.c
        magick/splay-tree.c
        magick/static.c
        magick/statistic.c
        magick/stream.c
        magick/string.c
        magick/threshold.c
        magick/timer.c
        magick/token.c
        magick/transform.c
        magick/type.c
        magick/utility.c
        magick/version.c
        magick/xml-tree.c
        utilities/convert.c
        wand/convert.c
        wand/drawing-wand.c
        wand/magick-image.c
        wand/magick-wand.c
        wand/mogrify.c
        wand/pixel-wand.c
        wand/magick-property.c
        wand/pixel-iterator.c
        wand/wand.c
        magick/deprecate.c
        ) ],
    'imagevalidate_538' => [ qw(
        image_validator/ImageValidator.c
        ) ],
);

if (($^O =~ /MSWin32/i || $ENV{'SPEC_USE_WINDOWS_SOURCES_ANYWAY'}) && !$ENV{'SPEC_NOT_REALLY_WINDOWS'}) {
    push @{$sources{'imagick_r'}}, 'magick/nt-base.c';
}

# Setup for 238.oimagick
$sources{'openmp_imagick'} = $sources{'imagick_r'};
$sources{'imagevalidate_238'} = $sources{'imagevalidate_538'};

# Setup for 638.imagick_s
$sources{'imagick_s'} = $sources{'imagick_r'};
$sources{'imagevalidate_638'} = $sources{'imagevalidate_538'};

$bench_flags = '-I. -DSPEC_AUTO_SUPPRESS_OPENMP';

use File::Basename;

sub compare_commands {
    my ($me) = @_;
    my @rc = getruns($me, qr/^\s*imagevalidate/);
    my @badexe = grep { $_->{'notfound'} ne '' } @rc;

    if (@badexe) {
        die "Unknown executable '$badexe->{'notfound'}' encountered in compare_command() in ". __FILE__ ."\n";
    }

    # Fix up the names of the imagevalidate file arguments
    my ($comparefiles) = $me->compare_files_hash;
    foreach my $run (@rc) {
        my $file = basename(pop(@{$run->{'args'}}), '.tga');
        my $origfile = $comparefiles->{$file.'_expected.tga'} || "COULD_NOT_LOCATE_${file}_expected.tga_FILE";
        push @{$run->{'args'}}, $file.'_output.tga', $origfile;
    }

    return @rc;
}

sub invoke {
    my ($me) = @_;
    my @rc = getruns($me, qr/^convert/);
    my @badexe = grep { $_->{'notfound'} ne '' } @rc;

    if (@badexe) {
        die "Unknown executable '$badexe->{'notfound'}' encountered in invoke() in ". __FILE__ ."\n";
    }
    return @rc;
}

sub getruns {
    my ($me, $filter) = @_;
    my @rc;

    my @runs = grep { m{$filter} } main::read_file('control');
    my %exes = ();
    foreach my $exe ($me->exe_files) {
        my $baseexe = basename($exe);
        $baseexe =~ s/_(?:base|peak).*//;
        $baseexe =~ s/^openmp_//;
        $baseexe =~ s/_[rs]$//;
        $baseexe =~ s/_538$//;
        $baseexe =~ s/imagick_//;
        $baseexe =~ s/imagick/convert/;
        $exes{$baseexe} = $exe;
    }

    foreach my $run (@runs) {
        my ($exe, $output, $error, @args) = split(/\s+/, $run);
        if (exists ($exes{$exe})) {
            push @rc, {
                'command' => $exes{$exe},
                'args'    => [ @args ],
                'output'  => "$output",
                'error'   => "$error",
            };
        } else {
            # This should never happen
            return { 'notfound' => $exe };
        }
    }
    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
