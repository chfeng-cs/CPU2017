$benchnum  = '511';
$benchname = 'povray_r';
$exename   = 'povray_r';
$benchlang = 'CXX,C';
@base_exe  = (qw/povray_r imagevalidate_511/);

$need_math = 'yes';

$reltol    = 0.06;

$bench_flags = '-Ifrontend -Ibase -I. -Ispec_qsort -DSPEC_AUTO_SUPPRESS_OPENMP';

%workloads = (
    'refspeed' => [ 'refrate' ],
);

%sources = (
    'povray_r' => [ qw(
        atmosph.cpp bbox.cpp bcyl.cpp benchmark.cpp bezier.cpp blob.cpp boxes.cpp bsphere.cpp camera.cpp
        chi2.cpp colour.cpp colutils.cpp cones.cpp csg.cpp discs.cpp express.cpp fncode.cpp fnintern.cpp
        fnpovfpu.cpp fnsyntax.cpp fpmetric.cpp fractal.cpp function.cpp hcmplx.cpp hfield.cpp histogra.cpp
        iff.cpp image.cpp interior.cpp isosurf.cpp lathe.cpp lbuffer.cpp lightgrp.cpp lighting.cpp mathutil.cpp
        matrices.cpp media.cpp mesh.cpp normal.cpp objects.cpp octree.cpp optout.cpp parse.cpp parsestr.cpp parstxtr.cpp
        pattern.cpp pgm.cpp photons.cpp pigment.cpp planes.cpp point.cpp poly.cpp polygon.cpp polysolv.cpp povmsend.cpp
        povmsrec.cpp povray.cpp pov_mem.cpp pov_util.cpp ppm.cpp prism.cpp quadrics.cpp quatern.cpp radiosit.cpp rad_data.cpp
        ray.cpp rendctrl.cpp render.cpp renderio.cpp reswords.cpp sor.cpp spheres.cpp sphsweep.cpp splines.cpp statspov.cpp
        super.cpp targa.cpp texture.cpp tokenize.cpp torus.cpp triangle.cpp truetype.cpp txttest.cpp userdisp.cpp userio.cpp
        vbuffer.cpp vlbuffer.cpp warps.cpp
        base/fileinputoutput.cpp
        base/povms.cpp
        base/povmscpp.cpp
        base/processoptions.cpp
        base/stringutilities.cpp
        base/textstream.cpp
        base/textstreambuffer.cpp
        frontend/defaultplatformbase.cpp
        frontend/defaultrenderfrontend.cpp
        frontend/messageoutput.cpp
        frontend/processrenderoptions.cpp
        frontend/renderfrontend.cpp
        spec_qsort/spec_qsort.c
        )],

    'imagevalidate_511' => [qw(
        image_validator/ImageValidator.c
        )],
);

# Set up for 611.povray_s
$sources{'povray_s'} = $sources{'povray_r'};
$sources{'imagevalidate_611'} = $sources{'imagevalidate_511'};

use File::Basename;

sub compare_commands {
    my ($me) = @_;
    my @rc;
    my ($imagevalidate_exe) = (grep { /^imagevalidate/ } $me->exe_files);

    foreach my $origfile (sort grep { /\Q.org.tga\E$/ } $me->compare_files_abs) {
        my $outfile = basename($origfile, '.org.tga').'.tga';
        push @rc, (
            {
                'command' => $imagevalidate_exe,
                'args'    => [ $outfile, $origfile ],
                'output'  => "imagevalidate_${outfile}.out",
                'error'   => "imagevalidate_${outfile}.err",
            }
        );
    }

    return @rc;
}

sub invoke {
    my ($me) = @_;
    my @rc;
    my ($povray_exe) = (grep { /^povray/i } $me->exe_files);

    foreach my $file (sort grep { /\.ini$/ } $me->input_files_base) {
        (my $name = $file) =~ s/\.ini$//;
        push @rc, (
            {
                'command' => $povray_exe,
                'args'    => [ $file ],
                'output'  => "${name}.stdout",
                'error'   => "${name}.stderr",
            }
        );
    }

    return @rc;
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
