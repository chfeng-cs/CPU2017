#
#  ps.pl - produces PostScript and PDF output (using the PSPDF API)
#  Copyright 1999-2019 Standard Performance Evaluation Corporation
#
#  Authors:  Christopher Chan-Nui
#            Cloyce D. Spradling
#
# $Id: ps.pl 6255 2019-06-11 15:37:45Z CloyceS $

use strict;
use PSPDF;
use resultgraph;
use File::Basename;
use Cwd;
use URI;
use List::Util qw(min max reduce sum);

require 'util.pl';

our ($name, $extension, $synonyms, $part_of_all, $non_default);
our ($invalid, @nc, $is_nc, %nc_info, $sortdir);

my $inch = $PSPDF::inch;

$name      = 'PostScript';
$extension = 'ps';
$synonyms  = { map { lc($_) => 1 } ($name, $extension, qw(printer print)) };

my $ps_version = '$LastChangedRevision: 6255 $ '; # Make emacs happier
$ps_version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$non_default = 1;  # You must ask for it by name
$part_of_all = 1;  # unless you ask for 'all'
$::tools_versions{'ps.pl'} = $ps_version;
my %tunecolor = %PSPDF::tunecolor;
my $base_shade = 0.9;

my $debug = 0;
my $min_font_size = 6;
my $fixed_font = $PSPDF::fixed_font;
my $prop_font = $PSPDF::prop_font;
my $prop_bold_font = $PSPDF::prop_bold_font;

$invalid   = 0;                 # Innocent until proven guilty
@nc   = ();                     # Innocent until proven guilty
$is_nc = 0;

sub format () {
    my($me, $r, $path) = @_;

    my @output = SPEC_report($r, 'PS', $path);
    return (\@output, []);
}

############################################################################
# PS/PDF Formatting routines

my $mode     = 'PS'; # Just the default
# We need a margin, let's use 0.5 inch
my $margin = 0.5 * $inch;

sub debug_clone {
    my ($config, $sb, $st, $tb, $tt) = @_;
    %{$config->{'results'}{$tb}{$tt}{'data'}[0]} = %{$config->{'results'}{$sb}{$st}{'data'}[0]};
    bless $config->{'results'}{$tb}{$tt}{'data'}[0],
    ref ($config->{'results'}{$sb}{$st}{'data'}[0]);
};

sub SPEC_report {
    my ($config, $mymode, $path) = @_;
    my ($width, $height, $hsize);

    $mode = $mymode;
    $mode = 'PS' if $mode eq '';
    my ($fn, $base_url);
    # Get a non-relative path.
    $path = ::unrel_path($path);
    if (defined($::website_formatter) && $::website_formatter) {
        # Strip the base off of the path, leaving the filename and whatever
        # hierarchy it's in.
        ($fn = $path) =~ s#^\Q$::report_base\E/*##;
        if (defined($::format_for_publication) && $::format_for_publication) {
            # Strip out the _second_ path component so that the URL will come
            # out right.
            my @pathcomp = split(m#/#, $fn);
            splice @pathcomp, 1, 1;
            $fn = ::jp(@pathcomp);
        }
        $fn =~ s/\.\Q${mode}\E$//i;
        $base_url = $::report_url_base.'/'.$fn;
    } else {
        $base_url = $fn = basename($path, '.'.lc($mode));
    }

    if ($config->{'invalid'} ||
        (((ref($config->{'errors'}) eq 'ARRAY') && @{$config->{'errors'}}))) {
        $invalid = 1;
    } else {
        $invalid = 0;
    }
    @nc = ::allof($config->{'nc'});
    if (@nc) {
        if (::istrue($config->{'nc_is_cd'})) {
            $is_nc = 3; # CD
        } elsif (::istrue($config->{'nc_is_na'})) {
            $is_nc = 2; # NA
        } else {
            $is_nc = 1; # NC
        }
    } else {
        $is_nc = 0;
    }

    my $pspdf = new PSPDF($mode, ::istrue($config->power));
    if (exists ($pspdf->{'error'}) and $pspdf->{'error'} ne '') {
        # PDF probably couldn't be initialized
        ::Log(0, "Couldn't initialize PostScript to PDF layer:\n$pspdf->{'error'}\n");
        return '';
    }
    my @gmtimes = gmtime(time);
    $gmtimes[5] += 1900;
    $gmtimes[4]++;
    $pspdf->CreationDate(sprintf("D:%04d%02d%02d%02d%02d+00'00'", @gmtimes[5,4,3,2,1,0]));

    $pspdf->Creator("SPEC $::suite v".$config->{'suitever'});
    $pspdf->Producer("SPEC $::suite PS/PDF formatter v$ps_version");

    # Collect things correctly, even if they're arrays
    my %things = ::get_tester_info($config);
    foreach my $thing (keys %things) {
        $things{$thing} = join(' ', @{$things{$thing}});
    }
    my $title = $things{'hw_vendor'}.': '.$things{'hw_model'};

    $pspdf->Author ($things{'tester'});
    if ($things{'test_sponsor'} ne $things{'hw_vendor'}) {
        $title .= ' (test sponsored by '.$things{'test_sponsor'};
        if ($things{'tester'} ne $things{'test_sponsor'}) {
            $title .= '; tested by '.$things{'tester'};
        }
        $title .= ')';
    }
    $pspdf->Title ($title);
    my $subj = sprintf('%sSPEC %s Result', ($invalid) ? 'Invalid ' : '',
        ::munge_metric(joinup($config->{'metric'}), $config->{'runmode'}));
    $pspdf->Subject($subj);

    $pspdf->open();

    ($width, $height) = SPEC_newpage($pspdf, $config);

    # Draw the Graph
    $hsize = ResultGraph::draw ($pspdf, 0, $height, $width, $height, $config, $is_nc);
    return undef unless defined($hsize);
    $height -= $hsize;

    # Draw the Detail boxes
    my $did_continue = 0;
    if ($::lcsuite ne 'mpi2007') {
        ($did_continue, $hsize, $height) = SPEC_detail($pspdf, 0, $height, $width, $height, $config);
        return undef unless defined($hsize);
    }

    # The CPU subcommittee has decreed that the results table shall be at the
    # top of the second page, with notes, errors, and flags following.
    # I think errors are important, though, so they go first.
    if ((ref($config->{'errors'}) eq 'ARRAY') &&
        (@{$config->{'errors'}}+0 > 0)) {
        my @tmperrs = auto_link(@{$config->{'errors'}});
        ($did_continue, $width, $height) = do_section($pspdf, $config,
                                                      $width, $height,
                                                      'title' => 'Errors',
                                                      'title_color' => $tunecolor{'error'},
                                                      'content' => \@tmperrs );
        # XXX Is this really supposed to be 0?  Should it be undef or ''?
        return 0 if ($width == 0);
    }
    if ($pspdf->{'pagenum'} < 2 and $::lcsuite ne 'mpi2007') {
        # No errors, or the errors didn't spill out onto the second page,
        # so the table gets a fresh page.
        $pspdf->grestore();
        end_page($pspdf);
        ($width, $height) = SPEC_newpage($pspdf, $config);
    }

    # Draw the Table
    $height = SPEC_table ($pspdf, 0, $height, $width, $height, $config);
    return undef unless defined($height);

    if ($::lcsuite eq 'mpi2007') {
        ($did_continue, $hsize, $height) = SPEC_mpi_detail($pspdf, 0, $height, $width, $height, $config);
        return undef unless defined($hsize);
        $height -= 10;
        $pspdf->setgray(0);
        $pspdf->moveto(0, $height);
        $pspdf->lineto($width, $height);
        $pspdf->stroke();
    }

    # Do the notes sections
    ($did_continue, $width, $height) = SPEC_notes($pspdf, $config, $width, $height, $did_continue, $config->notes);
    # XXX Is this really supposed to be 0?  Should it be undef or ''?
    return 0 if ($width == 0);

    # Do the flags report
    ($did_continue, $width, $height) = SPEC_flags ($pspdf, $config, $width, $height, $fn.'.flags.html', $base_url.'.flags.html');
    return undef unless defined($height);

    # Finally, the footer paragraph with the trademarks, etc.
    ($did_continue, $width, $height) = SPEC_trademarks ($pspdf, $config, $width, $height);
    return undef unless defined($height);

    $pspdf->grestore();
    end_page($pspdf);
    if ($is_nc == 0) {
        # Now encode/attach the raw file
        if (defined($config->{'compraw'})) {
            my %whatcomp = ( '*' => 'BASE64', '&' => 'BZIP2', '@' => 'GZIP' );
            my $whatcomp = 'BASE64';
            if ($config->{'compraw'} =~ /^([\@\&\*])/) {
                $whatcomp = $whatcomp{$1};
            }
            $pspdf->add_raw(basename($fn, '.'.lc($mode)).'.rsf', ' '.$whatcomp, $config->{'compraw'});
        } elsif (defined($config->{'rawfile'})) {
            $pspdf->add_raw(basename($fn, '.'.lc($mode)).'.rsf', '', $config->{'rawfile'});
        } else {
            ::Log(0, "Encoding problem?  There is no raw file to embed in the result file.\n");
        }
    }
    $pspdf->close();

    my @unbalanced_saves = $pspdf->get_saves();
    if (@unbalanced_saves) {
        ::Log(0, "ERROR: Unbalanced graphics states from ".join(', ', map { ref($_) eq 'ARRAY' && join(':', @{$_}) } @unbalanced_saves)."\n");
        return undef;
    }

    if ($mode eq 'PDF') {
        return $pspdf->output();
    } else {
        return split("\n", $pspdf->output());
    }
}

sub SPEC_newpage {
    my ($p, $config) = @_;

    #$p->begin_page(::istrue($config->power) ? 'letter_landscape' : 'letter');
    $p->begin_page('letter');
    $p->set_font($prop_font, 18);

    my $width  = $p->{'width'};
    my $height = $p->{'height'};

    $p->gsave();
    $height -= $margin * 2;
    $width  -= $margin * 2;
    $p->translate($margin, $margin);

    # Draw a box for the page
    $p->setlinewidth(0.4);
    $p->rect(0,0, $width,$height);
    $p->stroke();
    $p->setlinewidth(0.2);

    # Draw the advertisement at the bottom
    my $hsize = 0.25 * $inch;
    SPEC_advertisement($p, 0, 0, $width, $hsize);
    $height -= $hsize;
    $p->translate(0,$hsize);

    $p->{'mx'} = $margin;
    $p->{'my'} = $margin + $hsize;

    # Draw the Banner Bar
    $hsize = 0.5 * $inch;
    $height -= $hsize;
    SPEC_banner($p, 0, $height, $width, $hsize, $config);

    # Draw the Title Bar
    $hsize = $inch * (($::lcsuite eq 'accel' or ::istrue($config->power)) ? 1.125 : 0.75);
    $height -= $hsize;
    SPEC_title($p, 0, $height, $width, $hsize, $config);

    # Draw the info bars
    $hsize = 0.17 * $inch;
    my $origheight = $height;
    $height -= SPEC_infobar($p, 9, $height, $width - 9, $hsize, $config,
        [ # License and test date
            # Label                     Key            Width(%) Tag(%)
            [ $::suite.' License:'    , 'license_num' , 0.72,   0.20, ],
            [ 'Test Date:'            , 'test_date'   , 0.28,   0.65, ],
        ],
        [ # Sponsor and hardware availability
            # Label                     Key            Width(%) Tag(%)
            [ 'Test Sponsor:'         , 'test_sponsor', 0.72,   0.20, ],
            [ 'Hardware Availability:', 'hw_avail'    , 0.28,   0.65, ],
        ],
        [ # Tester and software availability
            # Label                     Key            Width(%) Tag(%)
            [ 'Tested by:'            , 'tester'      , 0.72,   0.20, ],
            [ 'Software Availability:', 'sw_avail'    , 0.28,   0.65, ],
        ],
    );

    # Draw a border for the infobars
    $p->gsave();
    {
        $p->rect(0, $origheight, $width, $height - $origheight);
        $p->stroke();
    }
    $p->grestore();


    # Thicken the bottom border
    $p->gsave();
    {
        $p->moveto(0, $height);
        $p->setlinewidth(0.4);
        $p->lineto($width, $height);
        $p->stroke();
    }
    $p->grestore();

    # Draw the NC/NA box (text will be done in end_page)
    if ($is_nc) {
        my $fontsize = 14;
        $nc_info{'indent'} = 0.375 * $inch;

        $p->gsave();
        {
            if (!exists($nc_info{'font_size'})) {
                # Blaze through and find the longest line -- it'll be used to
                # figure the font size
                my $maxwidth;
                while (!defined($maxwidth) or $maxwidth > $width) {
                    $maxwidth = max(map { $p->stringwidth($_, $fontsize, $prop_bold_font) + ($nc_info{'indent'} * 2) } @nc);
                    $fontsize-- if $maxwidth > $width;
                }
                $nc_info{'fonthsize'} = $p->string_CapHeight($fontsize, $prop_bold_font) * 2.5;
                $nc_info{'hsize'} = $nc_info{'fonthsize'} * (@nc-1) + (0.5 * $inch);
            }
            $nc_info{'height'} = $height;
            $p->translate(0, $height-$nc_info{'hsize'});
            $p->rect(0,0, $width, $nc_info{'hsize'});
            $p->stroke();
        }
        $p->grestore();
        $height -= $nc_info{'hsize'};
    }

    return ($width, $height);
}

sub SPEC_logo {
    my ($p, $x, $y, $width, $height) = @_;
    my $fontsize=72;

    # Make the logo area a hyperlink in the PDF
    if ($p->{'mode'} eq 'PDF') {
        my $ant = $p->{'page'}->annotation;
        (my $url = $::report_url_base) =~ s{(https?://[^/]+/).*}{$1};
        $url = '/' unless ($url =~ /^https?:/);
        $ant->url($url);
        $ant->rect($p->{'mx'}, $p->{'my'},
                   $p->{'mx'} + $width, $p->{'my'} + $height);
        #$ant->border(0.1, 0.1, 0.5); # YYY Only for debugging!
    }

    $p->gsave();
    $p->rect(0,0, $width,$height);
    $p->stroke();
    my $border = min($width, $height) * 0.05;
    $p->translate($x + $border, $y + $border);
    $width -= $border * 2;
    $height -= $border * 2;

    # Find out what the correct scale for the text is
    my $i = 0.5;
    $p->set_font($prop_bold_font);
    $fontsize = $p->string_calcsize('specr', $width, $height * 0.3, undef, undef);
    $p->set_font($prop_bold_font, $fontsize);

    # Print text for bottom
    $p->set_text_pos($width / 2, abs($p->string_Descender()));
    $p->show_center('spec', undef, 'https://www.spec.org/');

    my $tm_x = ($width + $p->stringwidth('spec')) / 2;
    my $tm_y = ($p->string_XHeight() / 3 * 2) + abs($p->string_Descender());
    $p->set_font('Symbol', $fontsize / 3);
    $p->set_text_pos($tm_x, $tm_y);
    $p->show('\322', 0, undef, ('noescape' => 1, 'doencode' => 1));

    # Print Grid
    my $grid_bottom = $p->string_MaxHeight($fontsize, $prop_bold_font);
    my $gridsize = $height - $grid_bottom;
    $gridsize = $width if $width < $gridsize;
    $p->translate(($width-$gridsize)/2, $grid_bottom);

    for ($i = 0; $i <= 4; $i++) {
        $p->moveto ($i/4 * $gridsize,                0);
        $p->lineto ($i/4 * $gridsize,        $gridsize);
        $p->moveto (               0, $i/4 * $gridsize);
        $p->lineto (       $gridsize, $i/4 * $gridsize);
    }
    $p->stroke();

    # Print the curve
    $p->setcolor([235,0,0]);
    for ($i = 11; $i <= 11; $i++)  {
        my $x1 = $i/16 * $gridsize;
        my $y1 =  4/16 * $gridsize;
        my $x2 = 12/16 * $gridsize;
        my $y2 = (16-$i)/16 * $gridsize;
        $p->moveto ( 3/16 * $gridsize,  3/16 * $gridsize);
        $p->curveto( $x1,$y1, $x2,$y2,
            13/16 * $gridsize, 13/16 * $gridsize);
        $p->stroke();
    }
    $p->setgray(0);
    $p->grestore();

    return 1;
}

sub SPEC_banner {
    my ($p, $x, $y, $width, $height, $config) = @_;
    my $bigfontsize = $height * 0.65;
    my $fontsize = $height * 0.2;
    my $copyright_msg  = 'Copyright '.::copyright_dates().' Standard Performance Evaluation Corporation';
    $p->gsave();
    $p->translate($x,$y);
    $p->rect(0,0, $width,$height);
    $p->stroke();

    if (!$invalid # Invalid results should never get the SPEC Seal of Reviewal
        and defined($::website_formatter) and $::website_formatter
        and defined($::format_for_publication) and $::format_for_publication) {
        SPEC_logo($p, 0, 0, $height, $height);
    }

    $p->set_font($prop_bold_font, $bigfontsize);
    $p->set_text_pos($width/2, $height-$bigfontsize*0.79);
    $p->linkto_center('SPEC '.::munge_metric($config->{'metric'}, $config->{'runmode'})." Result", undef, 'tmsearch' => 1);

    $p->set_font($prop_font, $fontsize);
    my $w = $p->stringwidth($copyright_msg);
    $p->set_text_pos(($width - $w)/2, $height-$bigfontsize*1.02 - $fontsize);
    $p->show($copyright_msg);
    $p->grestore();
    return 1;
}

sub SPEC_advertisement {
    my ($p, $x, $y, $width, $height) = @_;
    $p->gsave();
    {
        $p->translate($x,$y);
        $p->rect_fill(0,0, $width,$height, 0.95, undef, 1);

        my $company = 'Standard Performance Evaluation Corporation';
        my $url     = 'https://www.spec.org/';
        my $email   = 'info@spec.org';
        my $page    = 'Page '.$p->{'pagenum'};

        # Do the page number first; it gets the left 1/4th of the line
        my $font_size = min(10, $p->string_calcsize($page, $width / 4, $height * 0.8, undef, undef, $prop_font));
        $p->set_font($prop_font, $font_size);
        my $line_pad = ($height - $p->string_MaxHeight()) / 2;
        $x = my $margin = $p->string_MaxWidth() / 2;
        $y = $p->baseline($line_pad);

        $p->set_text_pos($x, $y);
        $p->show('Page '.$p->{'pagenum'});

        # Figure the font size to make the SPEC info fit.
        $font_size = min(10, $p->string_calcsize($company, $width * 3/4 - $margin * 4, $height * 0.8, undef, undef, $prop_font));
        $p->set_font($prop_font, $font_size);
        $line_pad = ($height - $p->string_MaxHeight()) / 2;
        $margin = $p->string_MaxWidth() / 2;
        $x = ($width / 4) + $margin;
        $y = $p->baseline($line_pad);

        my $display = "$company ($email)";
        $p->set_text_pos($width / 2 - $p->stringwidth($display) / 2, $y);
        $p->show($company);
        $p->set_text_pos($width / 2 + $p->stringwidth($display) / 2, $y);
        $p->show_right("($email)", undef, 'mailto:'.$email);

        $p->set_text_pos($width - $margin, $y);
        $p->show_right($url, undef, $url);
    }
    $p->grestore();
    return 1;
}

sub SPEC_infobar {
    my ($p, $x, $y, $width, $hsize, $config, @sections) = @_;
    my $height = 0;
    my $border = min($width, $hsize) * 0.2;
    $width -= $border * 2;

    # Get a list of all of the items that will be printed so we can figure
    # out the height of each section's box and the overall font size for
    # the labels and values.
    my %things = map { $_->[1] => 1 } map { @$_ } @sections;

    # Now figure out some things about each of the things, including:
    # - list of all the values (one per line)
    # - longest string (for figuring font size later)
    my %longest;
    foreach my $thing (keys %things) {
        $things{$thing} = [ ::allof($config->accessor_nowarn($thing)) ];
        # Get the maximum [ width, text ] for all of the values.  Not just
        # max(length($_)) for all strings because of proportional font.
        $longest{$thing} = reduce { $a->[0] > $b->[0] ? $a : $b } map { [ $p->stringwidth($_, undef, $prop_font), $_ ] } @{$things{$thing}};
        $longest{$thing} = $longest{$thing}->[1]; # We just want the string
    }

    # Figure out the font size to use such that all items fit in their
    # allotted space, and all the font sizes used are identical.
    my @sizes;
    foreach my $section (@sections) {
        foreach my $item (@$section) {
            my $item_width = $width * $item->[2];
            my $tagwidth = $item_width * $item->[3] - $border;
            my $valwidth = $item_width - $tagwidth - $border;
            next unless $longest{$item->[1]} ne '';
            push @sizes, (
                $p->string_calcsize($longest{$item->[1]}, $valwidth, $hsize, undef, '', $prop_font),
                $p->string_calcsize($item->[0], $tagwidth, $hsize, undef, '', $prop_bold_font),
            );
        }
    }
    my $font_size = min(@sizes);

    $p->gsave();
    {
        $p->translate($x + $border, $y);
        my $string_base = abs($p->string_Descender($font_size, $prop_font));
        foreach my $section (@sections) {
            $height -= $hsize;
            my $section_lines = max(map { @{$things{$_->[1]}}+0 } @$section);
            my $xpos = 0;
            foreach my $item (@$section) {
                my ($name, $key, $item_width, $tagwidth) = @$item;
                # $item_width is fraction of TOTAL line width
                $item_width *= $width;
                # $tagwidth is fraction of ITEM width
                $tagwidth *= $item_width;
                for(my $i = 0; $i < @{$things{$key}}; $i++) {
                    if ($i == 0) {
                        # Print the label
                        $p->set_font($prop_bold_font, $font_size);
                        $p->set_text_pos($xpos, $height + $string_base);
                        $p->linkto($name, undef, 'tmsearch' => 1);
                        $p->set_font($prop_font, $font_size);
                    }
                    # Print the value
                    my $line = $things{$key}->[$i];
                    $p->set_text_pos($xpos + $tagwidth, $height - ($i * $hsize) + $string_base);
                    $p->show($line);
                }
                $xpos += $item_width;
            }
            $height -= ($hsize * ($section_lines - 1));
        }
    }
    $p->grestore();
    return -$height + $border;
}

# Given the upper left corner
sub SPEC_info_box {
    my ($p, $x, $y, $width, $height, $config, $list, $size, $section) = @_;
    #print "\nSPEC_info_box(p=$p, x=$x, y=$y, width=$width, height=$height, config=$config, list=$list, size=$size, section=\"$section\")\n";
    my $finished = 1;
    $p->set_font($prop_font, $size*1.2);

    # Find the widest tag
    my $namewidth = max(map { $p->stringwidth($_->[0].':', $size) } grep { ::ref_type($_) eq 'ARRAY' } @$list);

    # Snug up the values next to their tags; as CPU gets older, the
    # subcommittee is NOT demanding that things get less verbose
    my $valpos = $namewidth + $p->string_MaxCapWidth($size) / 2;

    # Padding factor for text lines.  An extra 5% at the top and bottom, based
    # on the font size used on the line.
    my $row_pad_factor = 1.2;

    my $hsize = 0;
    my $items_done = 0;
    my $row_height = $p->string_MaxHeight($size, $prop_font) * $row_pad_factor;
    for my $item (@$list) {
        my $reftype = ::ref_type($item);
        if ($reftype eq '') {
            # This is a box heading
            if ($hsize + $row_height + ($p->string_MaxHeight($size * 1.2, $prop_bold_font) * $row_pad_factor) >= $height) {
                # This line plus one more info line would overflow the page
                $finished = 0;
                last;
            }
            $p->set_font($prop_bold_font, $size * 1.2);
            $hsize += $p->string_MaxHeight() * $row_pad_factor;
            $p->set_text_pos($x + $width / 2, $y - $hsize);
            $hsize += $p->string_MaxHeight() * ($row_pad_factor - 1); # Nudge it down a little
            $p->linkto_center($item, undef, 'section' => $section, 'tmsearch' => 1);
        } elsif ($reftype eq 'ARRAY') {
            my ($name, @vals) = @$item;

            # Figure out what font size to use that will allow the value to
            # fit into the available horizontal space.
            my $mysize = $size;
            for my $subval (grep { ::ref_type($_) ne 'HASH' } @vals) {
                my $testtxt = '';
                my ($line) = auto_link($subval);
                foreach my $chunk (@{$line}) {
                    my ($url, $txt) = @{$chunk};
                    if (defined($url)) {
                        $testtxt .= scalar(get_url_filename($url, $txt));
                    } else {
                        $testtxt .= $txt;
                    }
                }
                my $rc = $p->string_calcsize($testtxt, $width-$valpos, $row_height,
                    $min_font_size, "Your '$name' field is too long; %s size font will be unreadable!\n");
                return ($finished, 0) if $rc == 0;
                $mysize = $rc if $rc < $mysize;
            }
            if ($hsize + $row_height + ($p->string_MaxHeight($mysize) * $row_pad_factor * (@vals-1)) >= $height) {
                # This item would overflow the page; bail
                $finished = 0;
                last;
            }
            $hsize += $row_height;

            # The item title
            $p->set_font($prop_font, $size);
            $p->set_text_pos($x, $y - $hsize);
            $p->linkto("$name:", undef, 'section' => $section, 'tmsearch' => 1);

            # The item content
            $p->set_font($prop_font, $mysize);
            my $content_row_height = $p->string_MaxHeight() * $row_pad_factor;
            # When a line of large text is aligned next to a line of smaller
            # text, it can look like the smaller text has a lower baseline.
            # In order to compensate for that (and to conserve vertical space)
            # we'll bump each row of item content up by half the difference in
            # the row heights.  For non-scaled text there will be no bump.
            my $row_height_bump = ($row_height - $content_row_height) / 2;

            my $dest = undef;
            for my $subval (@vals) {
                if ((::ref_type($subval) eq 'HASH')) {
                    # It's the destination for the next item
                    $dest = $subval;
                    next;
                }
                my $dx = 0;
                $p->set_text_pos($x + $valpos, $y - $hsize + $row_height_bump);
                my ($line) = auto_link($subval);
                foreach my $chunk (@{$line}) {
                    my ($url, $txt) = @{$chunk};
                    my $strwidth;
                    if (defined($url)) {
                        # For info items, show only the filename part (if
                        # possible)
                        (my $filename, $url) = get_url_filename($url, $txt);
                        $strwidth = $p->stringwidth($filename);
                        $p->show($filename, undef, $url);
                    } else {
                        $strwidth = $p->stringwidth($txt);
                        $p->show($txt, undef, $dest);
                        $dest = undef;
                    }
                    $dx += $strwidth;
                    $p->set_text_pos($x + $valpos + $dx, $y - $hsize);
                }
                $hsize += $content_row_height;
            }
            $hsize -= $content_row_height if @vals;
        } else {
            ::Log(0, "SPEC_info_length: list contains bogus element ref type!\n");
            return (0, undef);
        }
        $items_done++;
    }
    $items_done = 0 if $finished;
    return ($items_done, $finished, $hsize);
}

sub SPEC_table {
    my ($p, $x, $y, $width, $height, $config) = @_;

    my ($rate, $what) = (($config->runmode =~ /rate$/) ? 1 : 0, 'copies');
    if ($::lcsuite eq 'mpi2007') {
        ($rate, $what) = (1, 'ranks');
    } elsif ($::lcsuite eq 'omp2012') {
        ($rate, $what) = (1, 'threads');
    } elsif (!$rate and $::lcsuite eq 'cpu2017') {
        ($rate, $what) = (2, 'threads');
    }

    my ($by_tune,
        $num_tune_fields, $num_result_fields,
        $tune_cols, $table_cols,
        @fields) = ::get_results_table_field_list($config, $rate, $what);

    # Generate the list of table titles based on the field list.
    # 'notune' fields are only dumped once.  Otherwise, fields
    # without 'result' set are output once per tuning level.
    my %titles = (
        'base' => [],
        'peak' => [],
    );
    my %metric_cols = (
        'ratio'        => undef,
        'energy_ratio' => undef,
    );
    my %tune_active = map { $_ => 1 } @{$config->tunelist};

    foreach my $tune (qw(base peak)) {
        next unless !$by_tune or $tune_active{$tune};
        my @titles;
        for(my $resnum = 0; $resnum < 3; $resnum++) {
            foreach my $fieldref (@fields) {
                next if $fieldref->{'notune'} and $resnum != 0;
                next unless $fieldref->{'result'} or $resnum == 0;
                push @titles, [
                    $fieldref->{'notune'} ? '' : $tune,                        # "state" (tuning level)
                    $fieldref->{'border'},                                      # additional border width
                    ($fieldref->{'noheader'} and $fieldref->{'val'} ne 'name') ? '' : $fieldref->{'label'},        # heading
                    $fieldref,
                ];
            }
        }
        $titles{$tune} = [ @titles ];

        # Figure out under which columns the metrics should be put. This will
        # be the same regardless of whether there are one or two tables.
        if ($by_tune or $tune eq 'peak') {
            my %looking_for = %metric_cols;
            for(my $colnum = 0; $colnum < @titles; $colnum++) {
                foreach my $col (keys %looking_for) {
                    if ($titles[$colnum][3]->{'val'} eq $col) {
                        $metric_cols{$col} = $colnum;
                        delete $looking_for{$col};
                    }
                }
                last unless %looking_for;
            }
        }
    }
    if (!$by_tune) {
        # Single table, so filter the notune fields out of the peak section
        # and append them to base.
        push @{$titles{'base'}}, grep { $_->[0] ne '' } @{$titles{'peak'}};
        delete $titles{'peak'};
    }

    # Figure out if there will be an NC marking, and if so what.
    my $nc_str = '';
    if ($is_nc) {
        if ($is_nc == 3) {
            $nc_str = 'CD';
        } elsif ($is_nc == 2) {
            $nc_str = 'NA';
        } else {
            $nc_str = 'NC';
        }
    }

    # Marshall all the results so we can figure out per-column decimal points
    # and widths and stuff like that.
    my %residx = ();
    my %results = ();
    my @dp_list = ();
    foreach my $tune (qw(base peak)) {
        next unless !$by_tune or $tune_active{$tune};
        ::marshall_results($config, $tune, \@fields, $nc_str, $by_tune, $tune_active{$tune}, \%results, \%residx, \@dp_list, $debug);
        if ($by_tune) {
            $height = SPEC_draw_single_table($p, $x, $y, $width, $height, $config, \%results, $titles{$tune}, \%metric_cols, \@dp_list, $by_tune ? $tune : '');
            %results = ();
            @dp_list = ();
        } else {
            next;
        }
    }
    if (!$by_tune) {
        $height = SPEC_draw_single_table($p, $x, $y, $width, $height, $config, \%results, $titles{'base'}, \%metric_cols, \@dp_list, '');
    }

    return $height;
}

sub SPEC_draw_single_table {
    my ($p, $x, $y, $width, $height, $config, $results, $titles, $metric_cols, $dp_list, $by_tune) = @_;
    $by_tune = ucfirst($by_tune);
    my $table_width = $width;
    my $label_width = 0;
    my $msg = [
        'Results appear in the ',
        [ qq|$::auto_docs_url_base/result-fields.html#RunOrder|, 'order in which they were run' ],
        '. Bold underlined text ',
        [ qq|$::auto_docs_url_base/result-fields.html#Median|, 'indicates a median measurement' ],
        '.'
    ];

    # Guaranteed not to exceed font sizes.  These will be adjusted if
    # necessary by size_result_table_columns().
    my %font_by_weight = (
        'normal' => [ $prop_font,      10 ],
        'bold'   => [ $prop_bold_font, 8.5 ],
    );

    my @column_start = size_result_table_columns($p, $table_width, $titles, $results, \%font_by_weight);

    # Figure out sizes for the table rows based on the height of the
    # largest combination likely to be seen (normal size, normal or bold
    # weight).  We use cap height instead of MaxHeight because there are
    # no descenders or ascenders on the numbers, and thus no need to compensate
    # for them.
    my $row_height = 2 * max(
        map { $p->string_CapHeight($font_by_weight{'normal'}->[1], $font_by_weight{$_}->[0]) } qw(bold normal)
    );
    # We're not using $p->baseline() here because the numbers never have
    # descenders, and the CapHeight/2 padding is enough to handle the ones
    # in the benchmark and metric names.  So the numbers will be nicely
    # vertically centered, and the labels may look a little low, but nothing
    # should clash.
    my $row_pad = $row_height / 4;

    # If there's not enough room on the page to print the title, the
    # headings, and at least one or two rows of data, just start a new page.
    # The raw font size is a very conservative swag for the height of a row
    # with that font size.
    if ($height < 20 + $row_height * 4) {
        $p->grestore();
        end_page($p);
        ($width, $height) = SPEC_newpage($p, $config);
    }

    my $divide_y = undef;
    $p->gsave();
    {
        $p->translate($x, 0);

        $height = SPEC_table_title($p, $width, $height,
                                   \@column_start, $by_tune,
                                   $titles, \%font_by_weight, $table_width, 0);

        # Remember the y pos so a dividing line can be drawn later
        # (It could be done in SPEC_table_title, but then the shading in the
        #  benchmark name boxes will destroy it.)
        $divide_y = $height;

        $p->set_font(@{$font_by_weight{'normal'}});

        # This must match what's used in the width calculations done in
        # size_result_table_columns()
        my $padding = $p->string_MaxCapWidth() / 2;

        # Do the table
        my $rowshade = 1;
        my @borders = ();
        for my $bench (sort keys %{$config->benchmarks}) {
            if ($height <= $row_height * 4) {
                # No room for a row and the 3 footer rows; time for a new page

                # Do the borders that need to be done
                do_borders($p, @borders) if @borders;
                @borders = ();

                # Do the black dividing lines
                $p->setgray(0);
                $p->setlinewidth(0.3);

                # In PDF, rects are filled by default!
                $p->moveto(0, $height - $row_height);
                $p->lineto(0, $divide_y);
                $p->lineto($width, $divide_y);
                $p->lineto($width, $height - $row_height);
                $p->rect(0, $height - $row_height, $width, $row_height);
                $p->stroke();

                # And the message about the continuation and format
                $height -= $row_height;
                my @tmp_msg = @{$msg};
                $tmp_msg[0] = "Table continues on next page. ".$tmp_msg[0];
                $p->fit_link_center(\@tmp_msg, $padding, $height + ($row_height * 0.15),
                                    $width - ($padding * 2), $row_height * 0.7);

                $p->grestore(); # To match the one at the top of this block
                $p->grestore(); # To match the one you get from newpage
                end_page($p);
                ($width, $height) = SPEC_newpage($p, $config);
                $height = SPEC_table_title($p, $width, $height,
                                           \@column_start, $by_tune,
                                           $titles, \%font_by_weight, $table_width, 1);
                $divide_y = $height;

                $p->gsave(); # To match the one at the end...
                $p->set_font(@{$font_by_weight{'normal'}});
            }
            $height -= $row_height;

            # $results->{$bench} is an array of items, one per column.  The
            # result columns items are hashes that look like:
            # {
            #     'dp' => 0
            #     'is_result' => 1,
            #     'name' => 'time',
            #     'preformatted' => '0',
            #     'rounded_value' => 10027,
            #     'selected' => 1,
            #     'sig_hack' => 1,
            #     'tune' => 'base',
            #     'value' => '10027.088299',
            # },
            # {
            #     'dp' => 2,
            #     'is_result' => 1,
            #     'name' => 'ratio',
            #     'preformatted' => '0',
            #     'rounded_value' => '1.00',
            #     'selected' => 1,
            #     'sig_hack' => undef,
            #     'tune' => 'base'
            #     'value' => '1.000091',
            # }
            # The 'dp' field, together with the value from $dp_list->[$i], can
            # be used to figure out how many invisible '0' to tack onto the
            # end of the string to make the decimal points in the columns
            # match up.

            # Make a copy of the result columns with an entry for the
            # benchmark name appended.  We'll iterate starting at -1
            # to print it first, and then the index variable for the result
            # columns will match up with the indices in @$dp_list.
            my @columns = (
                @{$results->{$bench}},
                {
                    'name' => 'name',
                    'align' => 'left',
                    'value' => $bench,
                },
            );
            for (my $i = -1; $i < @columns-1; $i++) {
                my $colref = $columns[$i];

                # The value used will be the 'rounded_value' unless the field
                # is preformatted or the rounded_value isn't available.
                my $val = ($colref->{'preformatted'} or !defined($colref->{'rounded_value'})) ? $colref->{'value'} : $colref->{'rounded_value'};

                # Columns for median results will be underlined.
                my $ul = $colref->{'selected'} ? 0.5 : 0;

                # Alignment for the columns is determined as follows:
                # - as specified, if the column specifies it
                # - right aligned for columns with preformatted values
                # - otherwise, the column is decimal aligned
                my $align = $colref->{'align'} || ($colref->{'preformatted'} ? 'right' : 'decimal');
                my $url;
                if ($colref->{'name'} eq 'name') {
                    # Link it
                    $url = $::bench_url_base."/${val}.html";
                } elsif ($colref->{'selected'}) {
                    $url = $::auto_docs_url_base."/result-fields.html#Median";
                }

                # @column_start is aligned with @$titles, which is one off
                # from @columns, since @columns contains only results.
                my $col_start = $column_start[$i + 1];
                my $col_width = $column_start[$i + 2] - $col_start;
                if (!$colref->{'is_result'}) {
                    $p->rect_fill($col_start, $height, $col_width, $row_height, $base_shade + (1 - $base_shade) / 2);
                }
                $p->gsave();
                {
                    $p->setlinewidth(0.10);
                    $p->setgray(0.50);
                    # To have alternating rows shaded, just remove the '0 and'
                    if (0 and !$colref->{'is_result'} and $rowshade) {
                        $p->rect_fill($col_start, $height, $col_width, $row_height, 0.93, undef, 1);
                    } else {
                        $p->rect($col_start, $height, $col_width, $row_height);
                        $p->stroke();
                    }

                    # Don't attempt to draw borders now, or the shaded boxes
                    # will destroy half of the line width, and it'll look
                    # strange.
                    my $right_border = $titles->[$i + 1]->[3]->{'border'};
                    if (ref($right_border) eq 'ARRAY' and @$right_border) {
                        my $tmp_currtune = $titles->[$i + 1]->[0];
                        my $tmp_nexttune = $titles->[$i + 2]->[0];
                        # The sizes will be for when the column is in the middle of the
                        # tuning section (default) or when it's the last column before
                        # the end of the tuning section.
                        my $border_selector = $tmp_currtune ne $tmp_nexttune ? 1 : 0;
                        my $border_width = $right_border->[$border_selector];
                        $border_width = $right_border->[0] unless defined($border_width);

                        push @borders, [
                            $col_start + $col_width, $height,
                            $row_height, $border_width,
                        ]
                    }
                }
                $p->grestore();
                if ($val ne '') {
                    $p->setcolor($tunecolor{$colref->{'tune'}});
                    if ($colref->{'selected'}) {
                        # Just set the weight, not the size too.  Otherwise the
                        # result table ends up looking like a ransom note.
                        $p->set_font($font_by_weight{'bold'}->[0]);
                    }
                    if ($align eq 'left') {
                        $p->set_text_pos($col_start + $padding, $height + $row_pad);
                        $p->show($val, $ul, $url);
                    } elsif ($align eq 'right') {
                        $p->set_text_pos($col_start + $col_width - $padding, $height + $row_pad);
                        $p->show_right($val, $ul, $url);
                    } elsif ($align eq 'decimal') {
                        my $align_width = get_dp_align_width($p, $dp_list->[$i], $colref->{'dp'});
                        $p->set_text_pos($col_start + $col_width - $padding - $align_width, $height + $row_pad);
                        $p->show_right($val, $ul, $url);
                    }
                    $p->setgray(0) if $colref->{'tune'} eq 'peak';
                    $p->set_font(@{$font_by_weight{'normal'}}) if $colref->{'selected'};
                }
            }
        }

        # Do those darker borders
        do_borders($p, @borders) if @borders;

        $p->setcolor(0);
        $p->setlinewidth(0.3);

        # Do the outline of the results part of the table.  Done as lines
        # because in PDF, rects are filled by default!
        $p->moveto(0, $height);
        $p->lineto(0, $divide_y);
        $p->lineto($width, $divide_y);
        $p->lineto($width, $height);
        $p->stroke();

        # Add the metrics to the bottom of the table
        my @metric_types = grep { defined($metric_cols->{$_}) } keys %$metric_cols;
        my %means_starts = (map { $_ => $column_start[$metric_cols->{$_}] } @metric_types);
        my $unit_width = min(map { $means_starts{$_} } keys %means_starts);
        my %means_width = (
            map { $_ => $column_start[$metric_cols->{$_} + 1] - $means_starts{$_} }
            @metric_types
        );
        # column-1 because $dp_list->[0] is the first _result_ column
        my %means_dp = (map { $_ => $dp_list->[$metric_cols->{$_} - 1] } @metric_types);
        (undef, my %means) = ::get_means($config, $is_nc);
        my @sizes;
        foreach my $mean (sort keys %means) {
            (my $type = $mean) =~ s/(base|peak)/ratio/;
            $type = 'energy_ratio' if $type eq 'ratioenergy';
            my $meanref = $means{$mean};
            if (!$meanref->{'ispower'} or ::istrue($config->power)) {
                push @sizes, (
                    # '0' is a swag at MaxDigitWidth (and usually a pretty
                    # good one)
                    $p->string_calcsize('0'.$meanref->{'units'}.' =0', $unit_width, $row_height * 0.6, $font_by_weight{'bold'}, undef, $prop_bold_font),
                );
            }
        }
        my $size = min($font_by_weight{'normal'}->[1], grep { $_ > 0 } @sizes);
        $p->set_font($font_by_weight{'bold'}->[0], $font_by_weight{'normal'}->[1]);

        foreach my $mean (sort keys %means) {
            next if $by_tune ne '' and $mean !~ /$by_tune/i;
            next if $means{$mean}->{'ispower'} and !::istrue($config->power);
            (my $type = $mean) =~ s/(base|peak)/ratio/;
            my $tune = $1;
            $type = 'energy_ratio' if $type eq 'ratioenergy';

            $height -= $row_height;
            $p->setcolor(0);
            $p->rect(0, $height, $width, $row_height);
            $p->stroke();

            $p->setcolor($tunecolor{$tune});

            # Show the metric name
            $p->set_font($font_by_weight{'bold'}->[0], $size);
            $p->set_text_pos($unit_width - $p->string_MaxWidth(), $height + $p->baseline(($row_height - $p->string_MaxHeight())/2));
            $p->linkto_right($means{$mean}->{'units'}.' =', undef, 'tmsearch' => 1);

            # And the value
            if ($means{$mean}->{'formatted'} =~ /\d/) {
                $p->set_font($font_by_weight{'bold'}->[0], $font_by_weight{'normal'}->[1]);
                my $align_width = get_dp_align_width($p, $means_dp{$type}, $means{$mean}->{'dp'});
                $p->set_text_pos($means_starts{$type} + $means_width{$type} - $padding - $align_width, $height + $row_pad);
                $p->show_right($means{$mean}->{'formatted'});
            } else {
                # Make it look more like the units and less (maybe) like the values.
                $p->set_text_pos($unit_width + $p->string_MaxDigitWidth(), $height + $p->baseline(($row_height - $p->string_MaxHeight())/2));
                $p->show($means{$mean}->{'formatted'});
            }
        }

        # And the message about the continuation and format
        $height -= $row_height;
        $p->setcolor(0);
        $p->rect(0, $height, $width, $row_height);
        $p->stroke();
        $p->set_font($prop_font);
        $p->fit_link_center($msg, $padding, $height + ($row_height * 0.15),
                            $width - ($padding * 2), $row_height * 0.7);
    }
    $p->grestore();
    return $height;
}

sub do_borders {
    my ($p, @borders) = @_;

    # Do the darker borders
    if (@borders) {
        $p->setgray(0);
        #$p->setcolor($tunecolor{'error'});
        for my $borderref (@borders) {
            my ($x, $y, $h, $width) = @{$borderref};
            $p->setlinewidth($width);
            $p->moveto($x, $y);
            $p->rlineto(0, $h);
        }
        $p->stroke();
        #$p->setgray(0);
    }
}

sub SPEC_table_title {
    my ($p, $width, $height, $column_start, $by_tune, $titles, $fontsize, $table_width, $cont) = @_;

    # Add a dummy title to ensure that the last title label gets printed
    my @titles = (@$titles, [ 0, undef ]);
    my @cols   = (@$column_start,   $column_start->[$#{$column_start}]);

    # Number of rows the entire header section will be.
    # Minimum is the maximum number of lines for any given label.
    my $header_rows = max(map { split(/\n/, $_->[2]) + 0 } @titles);

    # If this table is for multiple tuning levels, it will
    # need another header row; otherwise the tuning level will
    # be in the table title
    if ($by_tune ne '') {
        $by_tune .= ' ';
    } else {
        $header_rows++;
    }

    # Do the title
    $p->moveto(0, $height);
    $p->lineto($width, $height);
    $p->stroke();
    $p->set_font($fontsize->{'bold'}->[0], 16);
    my $pad = $p->string_MaxHeight() * 0.2;
    $height -= $p->string_MaxHeight() + $pad + $p->baseline($pad);
    $p->set_text_pos($width/2, $height + $p->baseline($pad));
    if ($cont) {
        $p->linkto_center($by_tune.'Results Table (Continued)', undef, 'tmsearch' => 1);
    } else {
        $p->linkto_center($by_tune.'Results Table', undef, 'tmsearch' => 1);
    }

    # Do the title boxes
    $p->set_font(@{$fontsize->{'bold'}});
    my $row_height = $p->string_MaxHeight();
    $pad = $row_height * 0.2;
    $row_height += ($pad * 2);
    my $header_height = $row_height * $header_rows;
    $height -= $header_height;

    my $num_titles = @titles+0;
    my $currtune = undef;
    my $titlebarx = 0;
    my @borders = ();
    for (my $i = 0; $i < $num_titles; $i++) {
        my $col_width = $column_start->[$i+1] - $column_start->[$i];
        my ($tune, $right_border, $str) = @{$titles[$i]};

        $p->gsave();
        {
            $p->setgray(0);
            if ($tune eq 'base') {
                # Base, so shade it
                $p->rect_fill($column_start->[$i], $height, $col_width,
                    $header_height, $base_shade, undef, 1);
            } else {
                $p->rect($column_start->[$i], $height, $col_width,
                    $header_height);
                $p->stroke();
            }
        }
        $p->grestore();
        if ($tune ne $currtune) {
            if ($currtune ne '' and $by_tune eq '') {
                # The end of a tuning level title bar; draw it and reset the
                # state
                my $barwidth = $column_start->[$i] - $titlebarx;
                # Plop down a box to remove the lines drawn previously
                $p->rect_fill($titlebarx, $height + $header_height - $row_height,
                    $barwidth, $row_height,
                    ($currtune eq 'base') ? $base_shade : 1, undef, 1);

                $p->set_text_pos($titlebarx + ($barwidth / 2),
                    $height + $header_height - $row_height + $p->baseline($pad));
                if ($currtune eq 'peak') {
                    $p->gsave();
                    $p->setcolor($tunecolor{'peak'});
                }
                $p->show_center(ucfirst($currtune), undef, undef, 'tmsearch' => 1);
                $p->grestore() if ($currtune eq 'peak');
            }
            $titlebarx = $column_start->[$i];
            $currtune = $tune;
        }
        if (ref($right_border) eq 'ARRAY' and @$right_border) {
            # The sizes will be for when the column is in the middle of the
            # tuning section (default) or when it's the last column before
            # the end of the tuning section.
            my $border_selector = $currtune ne $titles[$i+1]->[0] ? 1 : 0;
            my $border_width = $right_border->[$border_selector];
            $border_width = $right_border->[0] unless defined($border_width);

            # Does the border go the whole height of the header, or just to
            # the bottom of the bar that indicates the tuning level?
            my $border_rows = $header_rows;
            if ($border_width < 1 and $by_tune eq '') {
                # There is a tuning level row in the table, and the border should
                # not extend through it.
                $border_rows--;
            }

            push @borders, [ $column_start->[$i] + $col_width, $height,
                             $border_rows * $row_height, $border_width ]
        }
        if (defined($str)) {
            if ($currtune eq 'peak') {
                $p->gsave();
                $p->setcolor($tunecolor{'peak'});
            }
            $p->set_text_pos($column_start->[$i] + ($col_width / 2), $height + $p->baseline($pad));
            $p->linkto_center($str, undef, 'tmsearch' => 1);
            $p->grestore() if ($currtune eq 'peak');
        }
    }

    # Draw a slightly darker line to separate the heading from the data
    $p->setgray(0);
    $p->moveto(0, $height);
    $p->lineto($width, $height);
    $p->stroke();

    do_borders($p, @borders) if (@borders);

    return $height;
}

# This is an odd one, the Y position is the TOP of the box, not the bottom
# as with all of the others, and it returns 0 on error, otherwise it
# returns the length (height) used.
sub SPEC_detail {
    my ($p, $x, $y, $width, $height, $config) = @_;
    my ($str, $size, $len);
    my $fontsize = 10;
    my $did_continue = 0;

    my @sections = (
        ( 'Hardware', 0, [ $config->hardware ] ),
        ( 'Software', 0, [ $config->software ] ),
    );
    splice @sections, 2, 0, ( 'Accelerator', [ $config->accelerator ] ) if $::lcsuite eq 'accel';
    foreach my $powerref (::make_meter_sections($config, $config->power_info)) {
        my ($section_title, @items) = @$powerref;
        push @sections, $section_title, $section_title eq 'Power', [ @items ];
    }

    while (@sections) {
        my ($l_title, $l_fullwidth, $l_items,
            $r_title, $r_fullwidth, $r_items) = splice(@sections, 0, 6);
        if ($l_fullwidth == 0) {
            # Left side isn't full-width and there's no right side; add a
            # dummy section.
            if (!defined($r_title)) {
                $r_title = '';
                $r_fullwidth = 0;
                $r_items = [];
            }
        } elsif (defined($r_title)) {
            # "Left" side is full-width; put the right side back on the list
            unshift @sections, $r_title, $r_fullwidth, $r_items;
            $r_title = $r_items = undef;
        }
        my $tmp_did_continue = 0;

        ($width, $height, $x, $y, $tmp_did_continue, my $hsize) = SPEC_LR_boxes($p,
            $x, $y, $width, $height, $config, $fontsize,
            $l_title, $l_items,
            $r_title, $r_items);

        return (0, 0, $height) if !defined($tmp_did_continue);

        $len += $hsize;
        $height -= $hsize;
        $y -= $hsize;
        $did_continue |= $tmp_did_continue;
    }

    return ($did_continue, $len, $height);
}

# This was a copy of SPEC_detail, so it's odd in the same way (the Y position
# is the TOP of the box, not the bottom, and it returns 0 on error, otherwise
# it returns the length (height) used).
sub SPEC_mpi_detail {
    my ($p, $x, $y, $width, $height, $config) = @_;
    my ($str, $size, $hsize);
    my $len = 0;
    my $fontsize = 10;
    my $did_continue = 0;

    # First make a list of all the sections.  This is pre-done so that
    # anchor names can be uniquified if necessary.
    my @items = ();
    my %anchors = ();
    my %seen_anchors = ();
    for my $item (qw(node interconnect)) {
        next unless exists($config->{$item}) && (::ref_type($config->{$item}) eq 'HASH');
        my $iref = $config->{$item};

        # Get a list of things; interconnects are ordered primarily by
        # 'order' and secondarily by 'label' (lexically).  Nodes are the
        # same, but the most primary key is whether or not purpose contains
        # "compute".
        my @itemlist;
        if ($item eq 'node') {
            @itemlist = sort {
            $iref->{$a}->{'purpose'} !~ /compute/i <=> $iref->{$b}->{'purpose'} !~ /compute/i ||
            $iref->{$a}->{'order'} <=> $iref->{$b}->{'order'} ||
            $iref->{$a}->{'label'} cmp $iref->{$b}->{'label'}
            } keys %{$iref};
        } else {
            @itemlist = sort {
            $iref->{$a}->{'order'} <=> $iref->{$b}->{'order'} ||
            $iref->{$a}->{'label'} cmp $iref->{$b}->{'label'}
            } keys %{$iref};
        }

        foreach my $system (@itemlist) {
            push @items, [ $item, $system ];
            if ($p->{'mode'} eq 'PDF') {
                $anchors{$item.$system} = PDF::API2::NamedDestination->new_api($p->{'pdf'});
            }
        }
    }


    # Do the benchmark description and the node/interconnect TOC

    # It's desired that the system TOC fit into the "hardware summary".  So
    # fake up the necessary fields and tweak up the list of fields to make
    # it happen.
    my @hw_fields = @{$::mpi_info{'hardware'}};
    # Find the splice position; it's right after "system_class"
    my $i;
    for($i = 1; $i <= @hw_fields; $i++) {
        last if $hw_fields[$i-1]->[0] eq 'system_class';
    }

    my %tmp_sections = ();
    foreach my $item (qw(node interconnect)) {
        my @systems = map { $_->[1] } grep { $_->[0] eq $item } @items;
        my @itemnames = ($item);
        foreach my $system (@systems) {
            my $label = $config->{$item}->{$system}->{'label'} || $system;
            my @subsystems = ($item);
            if ($item eq 'node') {
                # Nodes additionally need to be differentiated by purpose
                @subsystems = map { lc($_)."_$item" } split(/(?:\s+(?!server)|,)+/i, $config->{$item}->{$system}->{'purpose'});
            }
            my $desc = [ $anchors{$item.$system}, $label ];
            foreach my $subsys (@subsystems) {
                push @{$tmp_sections{$subsys}}, $desc;
            }
        }
    }
    # Order for sections is compute nodes, interconnects, everything else
    # (sorted by purpose, I guess...)
    my @added = ();
    foreach my $sec (qw(compute_node interconnect), sort keys %tmp_sections) {
        if (exists $tmp_sections{$sec}) {
            my $title = $sec;
            $title =~ s/_/ /g;
            # Capitalize all the words
            $title =~ s/(\S+)/ucfirst($1)/ge;
            $title .= 's' if (@{$tmp_sections{$sec}} > 1);

            # Fix up the fileserver->file server mess
            $title =~ s/^Fileserver/File Server/i;

            splice @hw_fields, $i, 0, [ "ZZZadded_$sec", $title, 1 ];
            $i++;
            for(my $j = 0; $j < @{$tmp_sections{$sec}}; $j++) {
                my $newitem = sprintf "ZZZadded_%s%03d", $sec, $j;
                $config->{$newitem} = $tmp_sections{$sec}->[$j];
                push @added, $newitem;
            }
            delete $tmp_sections{$sec};
        }
    }


    my @sections = (
        ( 'Hardware Summary', 0, [ $config->info_format(\@hw_fields) ] ),
        ( 'Software Summary', 0, [ $config->info_format($::mpi_info{'software'})] ),
    );
    foreach my $powerref (::make_meter_sections($config, $config->info_format($::mpi_info{'power'}))) {
        my ($section_title, @items) = @$powerref;
        push @sections, $section_title, $section_title eq 'Power', [ @items ];
    }

    while (@sections) {
        my ($l_title, $l_fullwidth, $l_items,
            $r_title, $r_fullwidth, $r_items) = splice(@sections, 0, 6);
        if ($l_fullwidth == 0) {
            if (!defined($r_title)) {
                $r_title = '';
                $r_fullwidth = 0;
                $r_items = [];
            }
        } elsif (defined($r_title)) {
            # "Left" side is full-width; put the right side back on the list
            unshift @sections, $r_title, $r_fullwidth, $r_items;
            $r_title = $r_items = undef;
        }
        my $tmp_did_continue = 0;

        ($width, $height, $x, $y, $tmp_did_continue, $hsize) = SPEC_LR_boxes($p,
            $x, $y, $width, $height, $config, $fontsize,
            $l_title, $l_items,
            $r_title, $r_items);

        return (0, 0, $height) if !defined($tmp_did_continue);
        if (@sections) {
            $height -= $hsize;
            $y -= $hsize;
        }
        $did_continue |= $tmp_did_continue;
    }

    # Now remove the added fields, so that they don't pollute other results
    foreach my $tmpitem (@added) {
        delete $config->{$tmpitem};
    }

    # Do the system descriptions and notes
    for my $iref (@items) {
        my ($item, $system) = @{$iref};
        my $inforef = $config->{$item}->{$system};

        # Give the previously-created NamedDestination a destination
        $anchors{$item.$system}->link($p->{'page'}, -xyz => [ 0, $y, 0 ]) if $p->{'mode'} eq 'PDF';

        my ($hw_info, $sw_info) = ::mpi_info_munge($config, $item, $system);

        # Do the info boxes
        ($width, $height, $x, $y, $did_continue, $hsize) = SPEC_LR_boxes($p,
            $x, $y, $width, $height, $config, $fontsize,
            'Hardware', [ $config->info_format($hw_info) ],
            'Software', [ $config->info_format($sw_info) ],
            ucfirst($item).' Description: '.$inforef->{'label'},
            ucfirst($item));
        return (0, 0, $height) if !defined($did_continue);
        $height -= $hsize;
        $len += $hsize;
        $y -= $hsize;

        # Do the notes for this thing...
        my ($tmp_continue, $width, $tmpheight) = SPEC_notes($p, $config, $width, $height, $did_continue, $config->notes("${item}_${system}_"), ucfirst($item));
        $hsize = ($height - $tmpheight);
        $height -= $hsize;
        $len += $hsize;
        $y -= $hsize;

    }
    # Add a little padding
    $height += 4;
    $len += 4;

    return ($did_continue, $len, $height);
}

# Does a pair of side-by-side info boxes, unless the title and info for the
# right side is undef, in which case it does just one full-width info box.
sub SPEC_LR_boxes {
    my ($p, $x, $y, $width, $height, $config, $fontsize, $l_title, $l_info, $r_title, $r_info, $title, $section) = @_;
    #print "\nSPEC_LR_boxes(p=$p, x=$x, y=$y, width=$width, height=$height, config=$config, fontsize=$fontsize, \"$l_title\", $l_info, \"$r_title\", $r_info, \"$title\", \"$section\")\n";

    my $len;
    my ($left_len, $right_len, $l_finished, $r_finished) = (0,0,0,!defined($r_title));
    my @l_info = ::ref_type($l_info) eq 'ARRAY' ? @$l_info : ();
    my @r_info = ::ref_type($r_info) eq 'ARRAY' ? @$r_info : ();
    my $did_continue = 0;
    my $tries = 0;
    $title = '' unless defined($title);

    $p->gsave();
    {
        my ($l_seen, $r_seen) = (0, 0);
        while (!$l_finished or !$r_finished) {
            my $border = $p->string_MaxCapWidth($fontsize, $prop_font) / 2;
            my $line_height = $p->string_MaxHeight($fontsize, $prop_font) * 2;
            my $cont_line = $p->string_MaxHeight(8, $prop_font) * 1.5;
            my $title_height = $title ne '' ? 20 : 0;

            # If there's not enough room on the page for the title plus a few
            # lines of info, start a new page
            if ($y < (($title_height * 2) + ($line_height * 3) + $cont_line)
                    or ((!$l_finished or !$r_finished) and $tries > 0)) {
                $p->grestore(); # Match the one before the loop
                $p->grestore(); # Match the one from newpage
                end_page($p);
                ($width, $height) = SPEC_newpage($p, $config);
                $p->gsave(); # Match the one after the loop
                $y = $height;
                $len = 0;
                $did_continue = 1 if $l_seen || $r_seen;
            }

            if ($title ne '') {
                # Output the title
                $height -= $title_height;
                $y -= $title_height;
                $p->moveto(0, $height);
                $p->rect_fill(0, $height, $width, $title_height, 0.93, undef, 1);
                my $tmpsize = $p->string_calcsize($title, $width / 2, $height);
                $p->set_font($prop_bold_font, $tmpsize);
                $p->set_text_pos($width/2, $height + $p->string_CapHeight() / 2);
                $p->show_center($title, undef, 'tmsearch' => 1);
            }

            my $split = defined($r_title) ? $width * 0.5 : $width;
            if (!$l_finished) {
                my $title = ($did_continue) ? "$l_title (Continued)" : $l_title;
                ($l_seen, $l_finished, $left_len) = SPEC_info_box ($p,
                    $x+$border, $y,
                    $split-$border*2,
                    $height - $border - $title_height - $cont_line,
                    $config,
                    [
                        $title, @l_info,
                    ],
                    $fontsize,
                    $section);
                if ($left_len == 0) {
                    $p->grestore();
                    return ($width, $height, $x, $y, undef, $len);
                }
                # Eliminate the items that were done
                splice(@l_info, 0, $l_seen - 1);
            } else {
                $left_len = 0;
            }

            if (!$r_finished) {
                my $title = ($did_continue) ? "$r_title (Continued)" : $r_title;
                ($r_seen, $r_finished, $right_len) = SPEC_info_box ($p,
                    $x+$border+$split, $y,
                    $width-$split-$border*2,
                    $height - $border - $title_height - $cont_line,
                    $config,
                    [
                        $title, @r_info,
                    ],
                    $fontsize,
                    $section);
                if ($right_len == 0) {
                    $p->grestore();
                    return ($width, $height, $x, $y, undef, $len);
                }
                # Eliminate the items that were done
                splice(@r_info, 0, $r_seen - 1);
            } else {
                $right_len = 0;
            }

            $len = max($left_len, $right_len);
            $len += $border + $title_height;

            # Note that there is a continuation if necessary
            my $iscont = '(Continued on next page)';
            if (!$l_finished or !$r_finished) {
                $len += $cont_line;
                $p->gsave();
                my $cont_width = $split - ($border * 2);
                my $tmpsize = min(8, $p->string_calcsize($iscont, $cont_width,
                            $cont_line * 2/3, undef, undef, $prop_bold_font));
                $p->set_font($prop_bold_font, $tmpsize);
                my $cont_pad = ($cont_line - $p->string_MaxHeight()) / 2;
                if (!$l_finished) {
                    $p->set_text_pos($x + $border + ($cont_width / 2),
                        $y - $len + $p->baseline($cont_pad));
                    $p->show_center($iscont);
                }
                if (!$r_finished) {
                    $p->set_text_pos($x + $border + ($cont_width / 2) + $split,
                        $y - $len + $p->baseline($cont_pad));
                    $p->show_center($iscont);
                }
                $p->grestore();
            }

            $p->rect($x, $y-$len, $width, $len);
            $p->rect($x, $y-$len, $split, $len);
            $p->stroke();

            $tries++;
        }
    }
    $p->grestore();

    return($width, $height, $x, $y, $did_continue, $len);
}

sub SPEC_title_right {
    my ($p, $x, $y, $width, $height, $config) = @_;
    my ($str, $size);
    $p->gsave();
    {
        $p->translate($x,$y);
        $p->setcolor(0);

        # Shade the base metric area
        $p->rect_fill(0, $height / 2, $width, $height / 2, 0.9);

        # Box in the whole thing
        $p->rect(0,0, $width,$height);
        $p->stroke();

        # Leave a little space around the sides
        my $border = min($width, $height) * 0.1;
        $p->translate ($border, 0);
        $width  -= $border * 2;
        my $initial_size = 18;

        $p->set_font($prop_font, $initial_size);

        # Figure out the size of the font that we're going to use for all of
        # the metrics (needed so that the things can be nicely centered
        # vertically)
        (undef, my %means) = ::get_means($config, $is_nc);
        my @tmpstr;
        foreach my $meanref (values %means) {
            if (!$meanref->{'ispower'}
                    or (::istrue($config->power) and $config->power_is_official())) {
                # The two extra spaces before the '=' are for the "(tm)" (may be
                # added) # and the actual space that will be displayed.
                $meanref->{'str'} = $meanref->{'units'}.'  = '.$meanref->{'formatted'};
                push @tmpstr, $meanref->{'str'};
            }
        }
        my $line_height = $height / @tmpstr;
        $size = min(map {
                        $p->string_calcsize($_, $width, $line_height * 0.75, 0.1,
                        "ERROR: metric string ('$_') is too long!")
                    } @tmpstr);
        return 0 if ($size <= 0);
        $p->set_font($prop_font, $size, 1);
        my $string_base = ($line_height - $p->string_MaxHeight()) / 2;

        my $line = 0;
        # Items in reverse order as we populate from bottom up
        foreach my $tune (qw(peak base)) {
            $p->setcolor($tunecolor{$tune});
            foreach my $item (grep { $_->{'str'} ne '' } map { $means{$_} } ($tune.'energy', $tune)) {
                $p->set_text_pos(0, ($line_height * $line) + $p->baseline($string_base));
                $p->linkto($item->{'units'}.' = ', undef, 'tmsearch' => 1);
                $p->set_text_pos($width, ($line_height * $line) + $p->baseline($string_base));
                $p->show_right($item->{'formatted'});
                $line++;
            }
        }
    }
    $p->grestore();

    return 1;
}

sub SPEC_title_left {
    my ($p, $x, $y, $width, $height, $config) = @_;
    my $initial_size = 25;  # Pretty big, eh?

    # TODO: Replace "::allof(<fieldname>)" farther down with references to %things,
    #       since most of that stuff is already fetched by get_tester_info.
    my %things = ::get_tester_info($config);

    my %id_map =('vendor' => 'hw_vendor', 'model' => 'hw_model' );
    if ($::lcsuite eq 'mpi2007') {
        %id_map = ('vendor' => 'system_vendor', 'model' => 'system_name' );
    }

    $p->gsave();
    $p->translate($x,$y);
    # Make the box outline
    $p->rect(0,0, $width,$height);
    $p->stroke();

    $p->set_font($prop_font, $initial_size);

    # Arrange for a little space on the sides
    my $border = min($width, $height) * 0.05;
    $width  -= $border * 2;
    $p->translate ($border, 0);

    # Treat the two areas separately in terms of font size.
    my $size;
    my @lines = ([
            $id_map{'model'}, $config->accessor_nowarn($id_map{'model'})
        ]);
    if ($::lcsuite eq 'accel') {
        push @lines, [
            'hw_accel_name', $config->accessor_nowarn('hw_accel_name')
        ];
    }
    my $lines = @lines + 1; # vendor/sponsor is separate, but it's still a line
    my $line_height = $height / $lines;

    # test_sponsor needs to be attached to hw_vendor when they differ
    # This is a fairly rare occurance, so rather than retooling all
    # of the infrastructure to accomodate mixed-font-size strings
    # (especially when they need to be relatively different), just
    # split the area normally used for hw_vendor into two differently-
    # sized areas for hw_vendor and test_sponsor.
    my @hw_vendor = ::allof($config->accessor_nowarn($id_map{'vendor'}));
    my @test_sponsor = ::allof($config->accessor_nowarn('test_sponsor'));
    if (join(' ', @hw_vendor) eq join(' ', @test_sponsor)) {
        # The normal case; sponsor is vendor
        $size = $p->strings_fit(0, $height - $line_height, $width, $line_height,
            $min_font_size, $initial_size, $id_map{'vendor'}, @hw_vendor);
    } else {
        # Print both
        my $third_box = $line_height / 3;
        $test_sponsor[0] = '(Test Sponsor: '.$test_sponsor[0];
        $test_sponsor[$#test_sponsor] .= ')';
        $size = $p->strings_fit(0, $height - $line_height, $width, $third_box,
            $min_font_size / 3, $initial_size, 'test_sponsor', @test_sponsor);
        if ($size) {
            $size = $p->strings_fit(0, $height - $line_height + $third_box, $width, $third_box * 2,
                $min_font_size, $initial_size, $id_map{'vendor'}, @hw_vendor);
        }
    }

    if ($size) {
        for (my $i = 0; $i < @lines; $i++) {
            my ($thing, @values) = @{$lines[$i]};
            $size = $p->strings_fit(0, $i * $line_height, $width, $line_height,
                $min_font_size, $initial_size, $thing, @values);
            last if ($size <= 0);
        }
    }

    $p->grestore();

    return ($size <= 0) ? 0 : 1;
}

sub SPEC_title {
    my ($p, $x, $y, $width, $height, $config) = @_;
    my $rc = 0;
    my $split = $width * 0.56;
    $rc = SPEC_title_left ($p, $x,            $y, $split, $height, $config);
    return 0 if $rc == 0;
    $rc = SPEC_title_right($p, $split, $y, $width-$split, $height, $config);
    return $rc;
}

sub SPEC_flags {
    my ($p, $r, $width, $height, $flagfile, $flagurl) = @_;
    #print "\nSPEC_flags(p=$p, r=$r, width=$width, height=$height, flagfile=$flagfile, flagurl=$flagurl)\n";
    my $did_continue;
    my @output = ();
    my %opts = ();

    if (defined($::website_formatter) && $::website_formatter) {
        $flagfile = $flagurl;
    }

    # These will be handy for the flags section
    my $rf = $r->{'reduced_flags'};
    return undef unless (::ref_type($rf) eq 'HASH');
    my @benches = sort keys %{$rf->{'benchlist'}};
    my @tunes = sort keys %{$rf->{'tunelist'}};
    my @classes = sort keys %{$rf->{'classlist'}};
    my $indent = $rf->{'maxbench'} + $rf->{'maxtune'} + 5;

    # Do the unknown and forbidden flags.
    foreach my $class (qw(forbidden unknown)) {
        next unless ::check_elem(undef, $rf, 'flaglist', $class);
        # Flags of the class exist for at least one benchmark, so
        # make lists of them.  They'll be formatted and output later.
        my $classref = $rf->{'flaglist'}->{$class};
        @output = ();
        for my $tune (sort @tunes) {
            for my $bench (sort keys %{$classref}) {
                next unless ::check_elem('ARRAY', $classref, $bench, $tune);
                my @flags = @{$classref->{$bench}->{$tune}};
                if ($class eq 'unknown') {
                    # This just looks scary because we want the flags and variable
                    # names in a fixed-width font, and everything else proportional.
                    # And because the "unknown" flags may be long, we take care to
                    # break them up.
                    my @tmpflags = ();
                    foreach my $flagref (@flags) {
                        my @lines = ::wrap_lines([ $flagref->[1] ],
                            78 - $indent,
                            '',
                            0, 1);
                        my $tmpflag = [
                            [ '"',           'font' => $prop_font ],
                            [ shift(@lines), 'font' => $fixed_font, 'mid_flag' => @lines+0 ]
                        ];
                        while (@lines) {
                            push @tmpflags, $tmpflag;
                            $tmpflag = [
                                [ shift(@lines), 'font' => $fixed_font, 'mid_flag' => 1 ]
                            ];
                        }
                        my @inflag =  (
                            [ '(in ',         'font' => $prop_font ],
                            [ join(', ', @{$flagref->[0]}), 'font' => $fixed_font ],
                            [ ')',            'font' => $prop_font ]
                        );
                        if ($indent + length($tmpflag->[0]->[0]) + sum(map { length($_->[0]) } ([ "\" " ], @inflag)) > 78) {
                            # Just tack on the quote and put the variable name on the
                            # next line.
                            push @{$tmpflag}, [ '"', 'font' => $prop_font, 'mid_flag' => 1 ];
                            push @tmpflags, $tmpflag;
                            $tmpflag = [ @inflag ];
                        } else {
                            $inflag[0]->[0] = '" '.$inflag[0]->[0];
                            push @{$tmpflag}, @inflag;
                        }
                        push @tmpflags, $tmpflag;
                    }
                    @flags = @tmpflags;
                }
                push @output, dump_lines($bench,
                                         $indent, $bench, $tune,
                                         { 'url' => $flagfile }, @flags), '';
            }
            if (@output) {
                # Some flags were done; output the section
                %opts = ('title' => ucfirst($tune).' '.ucfirst($class).' Flags',
                         'content' => \@output,
                         'content_font' => $fixed_font,
                     );
                if ($class eq 'forbidden') {
                    $opts{'title_color'} = $tunecolor{'error'};
                }
                my $cont;
                ($cont, $width, $height) = do_section($p, $r, $width, $height, %opts);
                $did_continue += $cont;
                return undef if ($width == 0);
            }
        }
    }

    # Do all the other flags in a way that aggregates as much as possible.
    # Well, maybe.  Sometimes they're a LITTLE more expanded than they could
    # be.

    # First, figure out which form we'll use.  Will it be 0ld sk00l
    # Compiler (merged)
    # Portability (merged)
    # Base Optimization   -+- Maybe merged
    # Peak Optimization   -+
    # Other (merged)
    # ?
    # Or will it be the new style
    # Base Compiler Invocation
    # Base Portability Flags
    # Base Optimization
    # Base Other Flags
    # Peak Compiler Invocation (maybe with a back-ref to base)
    # Peak Portability Flags (maybe with a back-ref to base)
    # Peak Optimization (maybe with a back-ref to base)
    # Peak Other (maybe with a back-ref to base)
    # ?
    my $section_order = 1; # 0ld Sk00l by default
    foreach my $class (qw(compiler portability other)) {
        next unless exists $rf->{'allmatch'}->{$class};
        $section_order = $rf->{'allmatch'}->{$class};
        last unless $section_order;
    }
    # If any of the above sections don't match for all languages across all
    # tuning levels, we'll go to the "new style" order.

    my %class2title = (
        'compiler'     => 'Compiler Invocation',
        'portability'  => 'Portability Flags',
        'optimization' => 'Optimization Flags',
        'runtime'      => 'Runtime Environment',
        'other'        => 'Other Flags' );
    my $onetune = $tunes[0];
    foreach my $tune (@tunes) {
        foreach my $class (qw(runtime compiler portability optimization other)) {
            # Skip this tuning level pass if we're doing the old order, and EITHER
            # 1. it's the first trip through and the class is 'other'
            # or
            # 2. it's the second trip through and the class is 'compiler' or 'portability'
            # or
            # 3. it's the second trip through, the class is 'optimization', and allmatch is set
            # This is done so that the merged "other" section can come after optimization
            next if ($section_order == 1 &&
                (($tune eq $onetune && $class eq 'other') ||
                    ($tune ne $onetune && ($class eq 'compiler' || $class eq 'portability')) ||
                    ($tune ne $onetune && $class eq 'optimization' && $rf->{'allmatch'}->{$class} == 1)));
            %opts = (
                'title' => $class2title{$class},
                'content_font' => $fixed_font,
            );
            @output = ();
            my $mismatch = 0;
            my $printed_title = 0;
            my %langstodo = map { $_ => 1 } keys %{$rf->{'langlist'}};
            my %donebench = ();

            # Easy case first -- if we're doing new section order and allmatch
            # for this class is set and this isn't the base tuning, just
            # output the "Same as ..." message
            if ($section_order == 0 &&
                exists($rf->{'allmatch'}->{$class}) &&
                $rf->{'allmatch'}->{$class} == 1 &&
                $tune ne $onetune) {
                $opts{'title'} = ucfirst($tune).' '.$class2title{$class};
                $opts{'content'} = [ 'Same as '.ucfirst($onetune).' '.$class2title{$class} , '' ];
                my $cont;
                ($cont, $width, $height) = do_section($p, $r, $width, $height, %opts);
                $did_continue += $cont;
                return undef if ($width == 0);
                @output = ();
                next;
            }

            # Go through the langs and print the ones that match.
            foreach my $lang (sort ::bylang keys %langstodo) {
                last if $class eq 'portability'; # Portability is by benchmark
                my $printed_lang = 0;

                # Completely merged sections are only output for 0ld sk00l order
                if ($section_order == 1) {
                    # First dump all class flags that are common across all tuning levels
                    if ($rf->{'allmatch'}->{$class} == 1 &&
                        ::check_elem('HASH', $rf, 'langmatch', $class, 'alltune') &&
                        ::check_elem('HASH', $rf, 'bylang', 'flaglist', $class, $onetune)) {
                        if (exists($rf->{'langmatch'}->{$class}->{'alltune'}->{$lang}) &&
                            $rf->{'langmatch'}->{$class}->{'alltune'}->{$lang} &&
                            # There might _not_ be an entry for a particular language if, for
                            # the same flag (like -DSPEC_WINDOWS) one benchmark calls
                            # it portability and another calls it mandatory.  This is
                            # incorrect, but it's no fault of the user.
                            ::check_elem('ARRAY', $rf, 'bylang', 'flaglist', $class, $onetune, $lang) &&
                            @{$rf->{'bylang'}->{'flaglist'}->{$class}->{$onetune}->{$lang}}) {
                            my @flags = ();
                            for(my $i = 0; $i < @{$rf->{'bylang'}->{'flaglist'}->{$class}->{$onetune}->{$lang}}; $i++) {
                                my $flag = $rf->{'bylang'}->{'flaglist'}->{$class}->{$onetune}->{$lang}->[$i];
                                next unless (::istrue($flag->[2]->{'display'}) || $r->review);
                                my $markup = $rf->{'bylang'}->{'markup'}->{$class}->{$onetune}->{$lang}->[$i];
                                # In order to get the pre-formatted string to be used, make a
                                # new copy of the flag, with just the second element replaced.
                                my @newflag = @{$flag};
                                $newflag[1] = [ $flag->[1], $markup ];
                                push @flags, \@newflag;
                            }
                            my $langname = $lang;
                            $langname =~ s/ /_/g;
                            my $langtitle = $rf->{'var2desc'}->{$lang};
                            if ($rf->{'langmatch'}->{$class}->{$onetune}->{$lang} == 2) {
                                $langtitle .= ' (except as noted below)';
                            }
                            push @output, dump_lines($langtitle,
                                                     5,
                                                     $langname,
                                                     'ALL'.$lang,
                                                     { 'noaddbench' => 1, 'url' => $flagfile,
                                                         'title_alone' => 1, 'link_title' => 1 },
                                                     @flags), '';
                            $printed_lang = 1;
                            delete $langstodo{$lang};
                            if (::check_elem(undef, $rf, 'bylang', 'mismatch', $class, $onetune, $lang)) {
                                $mismatch += $rf->{'bylang'}->{'mismatch'}->{$class}->{$onetune}->{$lang};
                            }
                        }
                    }

                    # Do the benchmarks that matched across tuning levels
                    if ($rf->{'allmatch'}->{$class} == 1 &&
                        ::check_elem('HASH', $rf, 'stringlist', $class)) {
                        my $classref = $rf->{'flaglist'}->{$class};
                        foreach my $bench (sort keys %{$classref}) {
                            next unless # the following six conditions are true:
                            (
                                $rf->{'langs'}->{$bench}->{$onetune} eq $lang &&
                                ::check_elem(undef, $rf, 'benchmatch', $class, $bench, 'alltune') &&
                                $rf->{'benchmatch'}->{$class}->{$bench}->{'alltune'} &&
                                ::check_elem('ARRAY', $rf, 'flaglist', $class, $bench, $onetune) &&
                                (::ref_type($rf->{'flaglist'}->{$class}->{$bench}->{$onetune}) eq 'ARRAY') &&
                                @{$rf->{'flaglist'}->{$class}->{$bench}->{$onetune}}
                            );
                            my @flags = ();
                            my $flags = $rf->{'flaglist'}->{$class}->{$bench}->{$onetune};
                            for(my $i = 0; $i < @{$flags}; $i++) {
                                next unless (::istrue($flags->[$i]->[2]->{'display'}) || $r->review);
                                my $markup = $rf->{'markup'}->{$class}->{$bench}->{$onetune}->[$i];
                                # In order to get the pre-formatted string to be used, make a
                                # new copy of the flag, with just the second element replaced.
                                my @newflag = @{$flags->[$i]};
                                $newflag[1] = [ $flags->[$i]->[1], $markup ];
                                push @flags, \@newflag;
                            }
                            if (!$printed_lang) {
                                my $url = $::auto_docs_url_base."/result-fields.html#".::makeanchor($rf->{'var2desc'}->{$lang});
                                push @output, [ [ $url, $rf->{'var2desc'}->{$lang}, 'font' => $prop_font, 'subsection_title' => 1 ], [ undef, ': ', 'font' => $prop_font ] ], '';
                                $printed_lang = 1;
                            }
                            push @output, dump_lines(' '.$bench,
                                                     $rf->{'maxbench'} + 3,
                                                     $bench,
                                                     'ALL',
                                                     { 'noaddbench' => 1, 'url' => $flagfile },
                                                     @flags), '';
                            if (::check_elem(undef, $rf, 'mismatch', $class, $bench, $onetune)) {
                                $mismatch += $rf->{'mismatch'}->{$class}->{$bench}->{$onetune};
                            }
                            $donebench{$bench}++;
                        }
                    }
                }
            }
            if (@output) {
                # Some non-tune-specific flags are mentioned, so output them.
                if ($mismatch) {
                    if ($class eq 'optimization') {
                        push @output, '', [ [ undef, '(*) Indicates an optimization flag that was found in a portability variable.', 'font' => $prop_font ] ];
                    } elsif ($class eq 'portability') {
                        push @output, '', [ [ undef, '(*) Indicates a portability flag that was found in a non-portability variable.', 'font' => $prop_font ] ];
                    } elsif ($class eq 'compiler') {
                        push @output, '', [ [ undef, '(*) Indicates a compiler flag that was found in a non-compiler variable.', 'font' => $prop_font ] ];
                    }
                }
                $opts{'content'} = \@output;
                my $cont;
                ($cont, $width, $height) = do_section($p, $r, $width, $height, %opts);
                $did_continue += $cont;
                return undef if ($width == 0);
                @output = ();
                $mismatch = 0;
            }

            # Next dump class flags by tuning level, with the common per-language
            # set at the top, followed by benchmark-specific settings
            my $classref = undef;
            if (::check_elem('HASH', $rf, 'bylang', 'flaglist', $class, $tune)) {
                $classref = $rf->{'bylang'}->{'flaglist'}->{$class}->{$tune};
            }
            foreach my $lang (sort ::bylang keys %langstodo) {
                last if $class eq 'portability'; # Portability is by benchmark
                my $printed_lang = 0;
                if (defined($classref) &&
                    ::check_elem('ARRAY', $classref, $lang) &&
                    @{$classref->{$lang}}) {
                    my @flags = ();
                    for(my $i = 0; $i < @{$classref->{$lang}}; $i++) {
                        my $flag = $classref->{$lang}->[$i];
                        next unless (::istrue($flag->[2]->{'display'}) || $r->review);
                        my $markup = $rf->{'bylang'}->{'markup'}->{$class}->{$tune}->{$lang}->[$i];
                        my @newflag = @{$flag};
                        $newflag[1] = [ $flag->[1], $markup ];
                        push @flags, \@newflag;
                    }
                    my $langname = $lang;
                    $langname =~ s/ /_/g;
                    my $langtitle = $rf->{'var2desc'}->{$lang};
                    if ($rf->{'langmatch'}->{$class}->{$tune}->{$lang} == 2) {
                        $langtitle .= ' (except as noted below)';
                    }
                    push @output, dump_lines($langtitle,
                                             5,
                                             '',
                                             $langname.$tune,
                                             { 'url' => $flagfile,
                                               'title_alone' => 1,
                                               'link_title' => 1 },
                                             @flags), '';
                    $printed_lang = 1;
                    if (::check_elem(undef, $rf, 'bylang', 'mismatch', $class, $tune, $lang)) {
                        $mismatch += $rf->{'bylang'}->{'mismatch'}->{$class}->{$tune}->{$lang};
                    }
                }

                # Now do the benchmark-specific list (if any)
                if (::check_elem('HASH', $rf, 'flaglist', $class)) {
                    my $classref = $rf->{'flaglist'}->{$class};
                    foreach my $bench (sort keys %{$classref}) {
                        next if $donebench{$bench};
                        next if $rf->{'langs'}->{$bench}->{$tune} ne $lang;
                        next unless ::check_elem('ARRAY', $classref, $bench, $tune);
                        next unless @{$classref->{$bench}->{$tune}};
                        my @flags = ();
                        for(my $i = 0; $i < @{$classref->{$bench}->{$tune}}; $i++) {
                            my $flag = $rf->{'flaglist'}->{$class}->{$bench}->{$tune}->[$i];
                            next unless (::istrue($flag->[2]->{'display'}) || $r->review);
                            my $markup = $rf->{'markup'}->{$class}->{$bench}->{$tune}->[$i];
                            my @newflag = @{$flag};
                            $newflag[1] = [ $flag->[1], $markup ];
                            push @flags, \@newflag;
#                                         'from_bench' => $tune.join('', @{$flag->[0]}),
#                            $opts{'from_bench'} .= $bench if ($origin =~ /^(?:user|suite)/);
                        }
                        if (!$printed_lang) {
                            my $url = $::auto_docs_url_base."/result-fields.html#".::makeanchor($rf->{'var2desc'}->{$lang});
                            push @output, [ [ $url, $rf->{'var2desc'}->{$lang}, 'font' => $prop_font, 'subsection_title' => 1 ], [ undef, ': ', 'font' => $prop_font ] ], '';
                            $printed_lang = 1;
                        }
                        push @output, dump_lines(' '.$bench,
                                                 $rf->{'maxbench'} + 3,
                                                 $bench, $tune,
                                                 { 'addvar' => 1, 'url' => $flagfile },
                                                 @flags), '';
                        if (::check_elem(undef, $rf, 'mismatch', $class, $bench, $tune)) {
                            $mismatch += $rf->{'mismatch'}->{$class}->{$bench}->{$tune};
                        }
                    }
                }
            }

            if ($class eq 'portability') {
                # Do the portability flags on a per-benchmark basis; this is mostly
                # a copy of the code above.
                my @port_tunes = ($tune);
                my @titles = ( ucfirst($tune).' '.$class2title{$class} );
                if ($section_order == 1) {
                    # 0ld sk00l order means we have to do all tuning outputs
                    # here
                    if (!exists($rf->{'allmatch'}->{$class}) ||
                        $rf->{'allmatch'}->{$class} != 1) {
                        # ... but only if they shouldn't be merged.
                        @port_tunes = @tunes;
                        @titles = map { ucfirst($_).' '.$class2title{$class} } @port_tunes;
                    } else {
                        # Old order, but the section is merged (as it should
                        # always be, in the old order)
                        @titles = ( $class2title{$class} );
                    }
                }
                foreach my $port_tune (@port_tunes) {
                    $opts{'title'} = shift(@titles);
                    my $did_output = 0;
                    if (::check_elem('HASH', $rf, 'flaglist', $class)) {
                        my $classref = $rf->{'flaglist'}->{$class};
                        foreach my $bench (sort keys %{$classref}) {
                            next if $donebench{$bench};
                            next unless ::check_elem('ARRAY', $classref, $bench, $port_tune);
                            next unless @{$classref->{$bench}->{$port_tune}};
                            my @flags = ();
                            for(my $i = 0; $i < @{$classref->{$bench}->{$port_tune}}; $i++) {
                                my $flag = $rf->{'flaglist'}->{$class}->{$bench}->{$port_tune}->[$i];
                                next unless (::istrue($flag->[2]->{'display'}) || $r->review);
                                my $markup = $rf->{'markup'}->{$class}->{$bench}->{$port_tune}->[$i];
                                my @newflag = @{$flag};
                                $newflag[1] = [ $flag->[1], $markup ];
                                push @flags, \@newflag;
#                                            'from_bench' => $port_tune.join('', @{$flag->[0]}),
#                               $opts{'from_bench'} .= $bench if ($origin =~ /^(?:user|suite)/);
                            }
                            push @output, dump_lines(' '.$bench,
                                                     $rf->{'maxbench'} + 3,
                                                     $bench, $port_tune,
                                                     { 'addvar' => 1, 'url' => $flagfile },
                                                     @flags);
                            $did_output++ if @flags;
                            if (::check_elem(undef, $rf, 'mismatch', $class, $bench, $port_tune)) {
                                $mismatch += $rf->{'mismatch'}->{$class}->{$bench}->{$port_tune};
                            }
                        }
                    }
                    if ($mismatch) {
                        push @output, '', [ [ undef, '(*) Indicates a portability flag that was found in a non-portability variable.', 'font' => $prop_font ] ];
                        $mismatch = 0;
                    }
                    push @output, '' if $did_output;
                    if (@output) {
                        $opts{'content'} = \@output;
                        my $cont;
                        ($cont, $width, $height) = do_section($p, $r, $width, $height, %opts);
                        $did_continue += $cont;
                        return undef if ($width == 0);
                        @output = ();
                    }
                }
            } else {
                # Portability has its own special output section...

                if (@output) {
                    if ($mismatch) {
                        if ($class eq 'optimization') {
                            push @output, '', [ [ undef, '(*) Indicates an optimization flag that was found in a portability variable.', 'font' => $prop_font ] ];
                        } elsif ($class eq 'portability') {
                            push @output, '', [ [ undef, '(*) Indicates a portability flag that was found in a non-portability variable.', 'font' => $prop_font ] ];
                        } elsif ($class eq 'compiler') {
                            push @output, '', [ [ undef, '(*) Indicates a compiler flag that was found in a non-compiler variable.', 'font' => $prop_font ] ];
                        }
                    }
                    $opts{'title'} = ucfirst($tune).' '.$class2title{$class};
                    $opts{'content'} = \@output;
                    my $cont;
                    ($cont, $width, $height) = do_section($p, $r, $width, $height, %opts);
                    $did_continue += $cont;
                    return undef if ($width == 0);
                    @output = ();
                    $mismatch = 0;
                }
            }
        }
    }


    if (defined($::website_formatter) and $::website_formatter
            and defined($r->{'flagsurl'}) and $r->{'flagsurl'} ne '') {
        my $urls = $r->{'flagsurl'};
        if (::ref_type($urls) ne 'ARRAY') {
            # Shouldn't happen, but just in case...
            $urls = [ $urls ];
        }
        my (@html_contents, @xml_contents);
        my ($html_size, $xml_size) = (10, 7.5);
        foreach my $url (@{$urls}) {
            my $html_url = $url;
            $html_url =~ s/\.xml$/\.html/;
            # Calling do_section is a LOT easier than worrying about orphans
            # and other fun stuff like that.
            push @html_contents, [ [ $html_url, $html_url ] ];
            push @xml_contents,  [ [ $url,      $url      ] ];
        }
        my $cont = 0;
        my $title;
        if (@{$urls} > 1) {
            $title = 'The flags files that were used to format this result can be browsed at';
        } else {
            $title = 'The flags file that was used to format this result can be browsed at';
        }
        ($cont, $width, $height) = do_section($p, $r, $width, $height,
                                              'content' => \@html_contents,
                                              'title' => $title,
                                              'title_font' => $prop_font,
                                              'title_size' => 10,
                                              'content_size' => $html_size,
                                              'content_font' => $fixed_font,
                                              'no_link_title' => 1,
                                              'indent' => 10,
                                             );
        $did_continue += $cont;
        return undef if ($width == 0);
        if (@{$urls} > 1) {
            $title = 'You can also download the XML flags sources by saving the following links:';
        } else {
            $title = 'You can also download the XML flags source by saving the following link:';
        }
        ($cont, $width, $height) = do_section($p, $r, $width, $height,
                                              'content' => \@xml_contents,
                                              'title' => $title,
                                              'title_font' => $prop_font,
                                              'title_size' => 7.5,
                                              'content_size' => $xml_size,
                                              'content_font' => $fixed_font,
                                              'no_link_title' => 1,
                                              'indent' => 10,
                                             );
        $did_continue += $cont;
        return undef if ($width == 0);
    }

    return($did_continue, $width, $height);
}

sub dump_lines {
    my ($title, $len, $bench, $tune, $opts, @flags) = @_;
    my @output = ();
    my @line = ();
    my $line = '';      # Just for measuring...
    my $printed = 0;
    my $flagfile = $opts->{'url'};

    if ($opts->{'title_alone'}) {
        my $url = undef;
        if ($opts->{'link_title'}) {
            $url = $::auto_docs_url_base."/result-fields.html#".::makeanchor($title);
        }
        push @output, [ [ $url, $title, 'font' => $prop_font, 'subsection_title' => 1 ], [ undef, ': ', 'font' => $prop_font ] ];
        $printed = 1;
    }

    foreach my $flag (@flags) {
        my ($doul, $string, $url, $markup);
        if (::ref_type($flag) eq 'ARRAY') {
            # It could be a flag, or some text with attributes
            if (::ref_type($flag->[2]) eq 'HASH') {
                # It's a real flag
                # Strive for consistency -- the user flags are not underlined
                # in HTML.
                #$doul = ($flag->[2]->{'origin'}->[1] eq 'user') * 0.5;
                $doul = 0;
                my $from = $tune;
                if ($opts->{'addvar'}) {
                    $from .= join('', @{$flag->[0]});
                }
                if (!$opts->{'noaddbench'}) {
                    $from .= $bench if $flag->[2]->{'origin'}->[1] =~ /^(suite|user)$/;
                }
                if (exists $flag->[2]->{'nomap'}) {
                    # This is a pseudo-flag added by the tools, so just
                    # display the name.  (This should never happen here.)
                    $url = undef;
                    $doul = 0;
                } else {
                    $url = 1;
                }
                if (::ref_type($flag->[1]) eq 'ARRAY') {
                    ($string, $markup) = @{$flag->[1]};
                    $url = $flagfile.'#'.::make_flag_id($flag->[2], $from, $string, 1) if defined($url);
                    $string = [ [ $string, 'doul' => $doul, 'url' => $url, 'font' => $fixed_font ] ];
                    push @{$string}, [ $markup, 'font' => $prop_font ] if ($markup ne '');
                } else {
                    $string = $flag->[1];
                    $url = $flagfile.'#'.::make_flag_id($flag->[2], $from, $string, 1) if defined($url);
                    $markup = undef;
                }
                $printed += add_flag_to_line($string, $len, $title, \@output, \@line, \$line, 'doul' => $doul, 'url' => $url, 'printed' => $printed, 'link_title' => $opts->{'link_title'});
            } else {
                # Text with attributes
                $printed += add_flag_to_line($flag, $len, $title, \@output, \@line, \$line, 'doul' => $doul, 'url' => $url, 'printed' => $printed, 'link_title' => $opts->{'link_title'});
            }
        } else {
            # Just a string
            $doul = 0;
            $url = undef;
            $string = $flag;
            $printed += add_flag_to_line($string, $len, $title, \@output, \@line, \$line, 'doul' => $doul, 'url' => $url, 'printed' => $printed, 'link_title' => $opts->{'link_title'});
        }
    }
    if (@line) {
        if ($printed) {
            push @output, [ [ undef, '', 'width' => $len, 'font' => $prop_font ], @line ];
        } else {
            my $url = undef;
            if ($opts->{'link_title'}) {
                $url = $::auto_docs_url_base."/result-fields.html#".::makeanchor($title);
            }
            push @output, [ [ $url, $title, 'width' => $len - 1, 'font' => $prop_font, 'subsection_title' => 1 ], [ undef, ': ', 'font' => $prop_font ], @line ];
        }
    }

    return @output;
}

sub add_flag_to_line {
    my ($string, $len, $title, $output, $line, $curline, %opts) = @_;
    my $url      = $opts{'url'};
    my $doul     = $opts{'doul'};
    my $printed  = $opts{'printed'};
    my @strings  = ();
    my $titleurl = undef;
    if ($opts{'link_title'}) {
        $titleurl = $::auto_docs_url_base."/result-fields.html#".::makeanchor($title);
    }
    if (::ref_type($string) eq 'ARRAY') {
        # If the "string" is an array, it's a bunch of [ string, attr ] pairs
        @strings = @{$string};      # For later
        $string = join('', map { $_->[0] } @strings);       # For computing length
    }
    if (!@{$line}) {
        $$curline = $string;
        if (@strings) {
            @{$line} = ();
            foreach my $part (@strings) {
                my ($str, %opts) = @{$part};
                push @{$line}, [ $opts{'url'}, $str, %opts ];
            }
        } else {
            @{$line} = ( [ $url, $string, 'doul' => $doul, 'font' => $fixed_font ] );
        }
    } elsif (length($$curline.', '.$string) + $len > 78) {
        # If the last bit of the last line has 'mid_flag' set in its options,
        # don't append a comma.
        my (undef, undef, %tmpopts) = @{$line->[$#{$line}]};
        if ($tmpopts{'mid_flag'}) {
            # Same as below, just without the trailing comma
            if ($printed) {
                push @{$output}, [ [ undef, '', 'width' => $len, 'font' => $prop_font ], @{$line} ];
            } else {
                push @{$output}, [ [ $titleurl, $title, 'width' => $len - 1, 'font' => $prop_font, 'subsection_title' => 1 ], [ undef, ': ', 'font' => $prop_font ], @{$line} ];
            }
        } else {
            if ($printed) {
                push @{$output}, [ [ undef, '', 'width' => $len, 'font' => $prop_font ], @{$line}, ' ' ];
            } else {
                push @{$output}, [ [ $titleurl, $title, 'width' => $len - 1, 'font' => $prop_font, 'subsection_title' => 1 ], [ undef, ': ', 'font' => $prop_font ], @{$line}, ' ' ];
            }
        }
        $printed++;
        $$curline = $string;
        if (@strings) {
            @{$line} = ();
            foreach my $part (@strings) {
                my ($str, %opts) = @{$part};
                push @{$line}, [ $opts{'url'}, $str, %opts ];
            }
        } else {
            @{$line} = ( [ $url, $string, 'doul' => $doul, 'font' => $fixed_font ] );
        }
    } else {
        $$curline .= ", $string";
        if (@strings) {
            if (0) {
                # No commas -- too "confusing"
                push @{$line}, ', ';
            } else {
                push @{$line}, ' ';
            }
            foreach my $part (@strings) {
                my ($str, %opts) = @{$part};
                push @{$line}, [ $opts{'url'}, $str, %opts ];
            }
        } else {
            if (0) {
                # No commas -- too "confusing"
                push @{$line}, ', ', [ $url, $string, 'doul' => $doul, 'font' => $fixed_font ];
            } else {
                push @{$line}, ' ', [ $url, $string, 'doul' => $doul, 'font' => $fixed_font ];
            }
        }
    }
    return $printed;
}

sub do_section {
    # Dump a section (like errors, notes, flags, etc) with a nice title.
    # The content array can contain either strings or array refs.  Strings are
    # printed as-is.  Array refs are expected to contain pairs of text with
    # URLs that they should be linked to.  Text that should not be linked must
    # have an undef URL.
    my ($p, $config, $width, $height, %params) = @_;

    my ($rc, $x);
    my $did_continue = 0;
    my ($title_height, $line_height);
    my $line_pad_factor = 0.2;

    if (!exists($params{'title'})) {
        ::Log(0, "ERROR: No section title in call to do_section\n");
        return(0, $width, $height);
    }

    $params{'border'} = min($inch * 0.125, $width * 0.1, $height * 0.1) unless exists($params{'border'});
    $params{'indent'} = 0 unless exists($params{'indent'});

    $params{'title_color'} = 0 unless exists($params{'title_color'});
    $params{'title_font'} = $prop_bold_font unless exists($params{'title_font'});
    $params{'title_size'} = 20 unless exists($params{'title_size'});
    $title_height = $p->string_MaxHeight($params{'title_size'}, $params{'title_font'});
    # Title padding will be 1/4 of a full line height or room for descenders
    # plus wiggle, whichever is more (font descenders must never collide with
    # text below).
    $params{'title_pad'} = max($title_height / 4, abs($p->string_Descender($params{'title_size'}, $params{'title_font'}) * 2)) unless exists($params{'title_pad'});

    $params{'content_color'} = 0 unless exists($params{'content_color'});
    $params{'content_font'} = $prop_font unless exists($params{'content_font'});
    $params{'content_size'} = 10 unless exists($params{'content_size'});
    $line_height = $p->string_MaxHeight($params{'content_size'}, $params{'content_font'});
    $params{'content_pad'} = $line_height * $line_pad_factor unless exists($params{'content_pad'});
    $line_height += $params{'content_pad'} * 2;

    $params{'content'} = [] unless exists($params{'content'});
    my @lines = @{$params{'content'}};

    if ($height < $title_height + ($line_height * 4) + ($params{'title_pad'} * 2)) {
        # There's not enough room for the heading and one line of text.
        $p->grestore();
        end_page($p);
        ($width, $height) = SPEC_newpage($p, $config);
        $did_continue = 1;
    }
    $p->gsave();
    {
        $p->setcolor($params{'title_color'});
        $p->set_font($params{'title_font'}, $params{'title_size'});
        $height -= $title_height + ($params{'title_pad'} * 2);
        $p->set_text_pos($width / 2, $height + $params{'title_pad'});

        if ($params{'no_link_title'}) {
            $p->show_center($params{'title'}, undef, 'tmsearch' => 1);
        } else {
            $p->linkto_center($params{'title'}, undef, 'section' => $params{'section'}, 'tmsearch' => 1);
        }

        $p->setcolor($params{'content_color'});
        $p->set_font($params{'content_font'}, $params{'content_size'});
        $height -= $line_height;

        my $saved_subsection = undef;
        for(my $i = 0; $i < @lines; $i++) {
            my $line = $lines[$i];
            my ($urls, $text, $item_params, $tmpstr, $subsection_title) = decompose_line($line);

            # If the current line is marked as a subsection header, make sure that
            # there's room for _three_ lines (the header, some info, and a blank).
            my $required_height = $line_height;
            my $avoid_orphan = 0;
            if ($subsection_title) {
                $saved_subsection = undef;      # Will be set later, if necessary
                $required_height *= 2;
            } else {
                # Don't do it if the only line that would be spilled would be blank
                my $tmptext = '';
                if ($i == @lines-1) {
                    $tmptext = (::ref_type($text) eq 'ARRAY') ? join('', @$text) : $text;
                    $avoid_orphan = 1 if ($tmptext =~ /^\s*$/);
                }
            }

            # Do we need to spill onto a new page?
            if ($height < ($required_height + $line_height) and $avoid_orphan == 0) {
                $p->set_font($prop_bold_font);
                # Make the continuation message slightly smaller than the
                # surrounding text.
                $p->string_fit_center(
                    '(Continued on next page)',
                    0, $line_height * 0.25,
                    $width, $line_height * 0.75,
                    undef, undef, ());

                $p->grestore();
                $p->grestore();
                end_page($p);
                ($width, $height) = SPEC_newpage($p, $config);
                $p->gsave();

                $p->setcolor($params{'title_color'});
                $p->set_font($params{'title_font'}, $params{'title_size'});
                $height -= $title_height + ($params{'title_pad'} * 2);
                $p->set_text_pos($width / 2, $height + $params{'title_pad'});
                if ($params{'no_link_title'}) {
                    $p->show_center($params{'title'}.' (Continued)', undef,
                        'tmsearch' => 1);
                } else {
                    $p->linkto_center($params{'title'}.' (Continued)', undef,
                        'section' => $params{'section'}, 'tmsearch' => 1);
                }

                $p->setcolor($params{'content_color'});
                $p->set_font($params{'content_font'}, $params{'content_size'});
                $height -= $line_height;

                $did_continue = 1;

                if (defined($saved_subsection)) {
                    $i--; # Do the current line next time around
                    ($urls, $text, $item_params, $tmpstr) = decompose_line($saved_subsection);
                }
            }
            if ($subsection_title) {
                $saved_subsection = get_subsection($line);
            }
            $x = $params{'border'} + $params{'indent'};
            if (::ref_type($line) eq 'ARRAY') {
                # Figure out the font size to use.
                my $tmpsize = $p->string_calcsize(
                                $tmpstr,
                                $width - $params{'indent'} - ($params{'border'} * 2),
                                $line_height - ($params{'content_pad'} * 2),
                                $min_font_size,
                                "A line in your $params{'title'} section is too long!\n");
                return ($did_continue, 0, 0) if ($tmpsize <= 0);
                $p->set_font($params{'content_font'}, $tmpsize);
                for(my $i = 0; $i < @{$text}; $i++) {
                    if ($item_params->[$i]->{'font'} ne '') {
                        $p->set_font($item_params->[$i]->{'font'}, $item_params->[$i]->{'font_size'});
                    }
                    my $strwidth = $p->stringwidth($text->[$i]);
                    if ($item_params->[$i]->{'width'} > 0) {
                        # This happens when we are displaying lines with mixed
                        # fonts, as happens with the flag dumps.
                        # For a proportional font, average is as close as we
                        # can get without actually measuring all the bits and
                        # putting them together. (XXX why don't we do that? XXX)
                        # For a fixed-width font this is perfect.
                        $strwidth = min($strwidth, $p->string_AvgWidth() * $item_params->[$i]->{'width'});
                        $p->set_text_pos($x + $strwidth, $height + $p->baseline($params{'content_pad'}));
                        $p->show_right($text->[$i], $item_params->[$i]->{'doul'}, $urls->[$i]);
                    } else {
                        $p->set_text_pos($x, $height + $p->baseline($params{'content_pad'}));
                        $p->show($text->[$i], $item_params->[$i]->{'doul'}, $urls->[$i]);
                    }
                    $x += $strwidth;
                    $p->set_font($params{'content_font'}, $tmpsize);
                }
            } else {
                $rc = $p->string_fit(
                    $line,
                    $x, $height + $p->baseline($params{'content_pad'}),
                    $width - $params{'indent'} - ($params{'border'} * 2), $line_height - ($params{'content_pad'} * 2),
                    $min_font_size,
                    "A line in your $params{'title'} section is too long!\n");
                return ($did_continue, 0, 0) if $rc == 0;
            }
            $height -= $line_height;
        }
        if ($height > $title_height + ($line_height * 4) + ($params{'title_pad'} * 2)) {
            # Only draw the lower boundary if there's enough space left to start
            # another section.
            $p->moveto(0, $height);
            $p->lineto($width, $height);
            $p->stroke();
        }
    }
    $p->grestore();

    return($did_continue, $width, $height);

}

sub get_subsection {
    my ($line) = @_;
    # Get the part of the line marked as a subsection (if any)
    my $cont = [ undef, ' (continued):' ];

    if (::ref_type($line) eq 'ARRAY') {
        foreach my $pair (@{$line}) {
            if (::ref_type($pair) eq 'ARRAY') {
                my ($url, $tmptext, %item_params) = @{$pair};
                if ($item_params{'subsection_title'}) {
                    if (exists $item_params{'font'}) {
                        return [ $pair, [ @$cont, 'font' => $item_params{'font'} ] ];
                    } else {
                        return [ $pair, $cont ]
                    }
                }
            }
        }
    }

    return undef;
}

sub decompose_line {
    my ($line) = @_;
    # Break a line down into its constituent bits
    my ($urls, $text, $item_params) = ([], [], []);
    my $tmpstr = '';
    my $subsection_title = 0;

    if (::ref_type($line) eq 'ARRAY') {
        foreach my $pair (@{$line}) {
            if (::ref_type($pair) eq 'ARRAY') {
                my ($url, $tmptext, %item_params) = @{$pair};
                push @{$urls}, $url;
                push @{$text}, $tmptext;
                push @{$item_params}, \%item_params;
                $tmpstr .= $tmptext;
                $subsection_title += $item_params{'subsection_title'};
            } else {
                push @{$urls}, undef;
                push @{$text}, $pair;
                push @{$item_params}, {};
            }
        }
    }

    return ($urls, $text, $item_params, $tmpstr, $subsection_title);
}

sub significant { ::significant_base(@_, ($debug & 4)); }

# Figure out how much space (if any) needs to be added to the right in order
# to cause decimal place alignment to happen.
sub get_dp_align_width {
    my ($p, $max_dp, $val_dp) = @_;

    return 0 if $max_dp <= 0 or $max_dp == $val_dp or !defined($val_dp);

    my $s = $p->string_MaxDigitWidth() * ($max_dp - $val_dp);
    $s += $p->stringwidth('.') if $val_dp == 0;

    return $s;
}

#sub pluralize {
#    return main::pluralize(@_);
#}

sub dist {
    my ($x1, $y1, $x2, $y2) = @_;
    my $dx = $x2 - $x1;
    my $dy = $y2 - $y1;

    return sqrt(($dx * $dx) + ($dy * $dy));
}

sub joinup {
    my ($ref) = @_;

    return $ref unless ref($ref);
    if (ref($ref) eq 'ARRAY') {
        return join(' ', @{$ref});
    }
}

sub end_page {
    my ($p) = @_;

    my $width  = $p->{'width'};
    my $height = $p->{'height'};
    my ($tmpwidth, $rc);

    if ($invalid) {
        $p->gsave();
        {
            $p->setcolor($tunecolor{'error'});
            $p->set_font($prop_font);
            $p->rotate(50);
            $tmpwidth = dist(0,0, $width, $height) * 0.75;
            $rc = $p->string_fit('Invalid Run', $tmpwidth * 0.25, 0,
                $tmpwidth, 144, undef, undef, -render => 1);
        }
        $p->grestore();
    }
    if ($is_nc) {
        my $nc_str;
        if ($is_nc == 3) {
            $nc_str = 'Code Defect';
        } elsif ($is_nc == 2) {
            $nc_str = 'Not Available';
        } elsif ($is_nc) {
            $nc_str = 'Non-Compliant';
        }
        $p->gsave();
        {
            $p->setcolor($tunecolor{'error'});
            $p->set_font($prop_font);
            $p->rotate(50);
            $tmpwidth = dist(0,0, $width, $height) * 0.75;
            $rc = $p->string_fit($nc_str, $tmpwidth * 0.25, 0, $tmpwidth, 144);
        }
        $p->grestore();

        $p->gsave();
        {
            $p->set_font($prop_bold_font, $nc_info{'fontsize'});
            $p->translate($margin, ($margin * 2) + $nc_info{'height'} - $nc_info{'hsize'});
            my $currheight = $nc_info{'hsize'} - (0.25 * $inch) - ($p->string_MaxHeight() / 2);
            foreach my $line (@nc) {
                $p->set_text_pos(($width - ($margin * 2)) / 2, $currheight);
                $p->show_center($line, undef, 'tmsearch' => 1);
                $currheight -= $nc_info{'fonthsize'};
            }
        }
        $p->grestore();
    }
    $p->end_page();
}

sub SPEC_trademarks {
    my ($p, $result, $width, $height) = @_;
    my $max_str_len = 132;

    my $did_continue = 0;

    # The long length may cause the font to shrink a bit, but that's okay.
    # Also, if we mark anything in the footer that wasn't previously marked, it won't show up in this list.  The cost
    # to fix this isn't worth it until the lawyers say it is.  But they're not going to notice.
    my @tm_lines = ::trademark_lines('', $max_str_len, $p->trademarks_done());
    my @lines = (); # We don't need to re-mark the trademarks.

    # Add some version information
    push @lines, '' if @tm_lines;

    # Add the footer like other results...
    push @lines, (
        ::wrap_lines(
            [ 'For questions about this result, please contact the tester.  '.
                'For other inquiries, please contact info@spec.org.' ],
            $max_str_len, '', 0, 0),
        '',
    );
    # Time and date formats are from RFC3339.  See CPU2017 Trac #115
    push @lines, "Tested with SPEC $::suite v".$result->{'suitever'}.' on '.$result->datestr().'.';
    push @lines, 'Report generated on '.::timeformat('date-time', time)." by $::suite $p->{'mode'} formatter v$ps_version.";
    my @dates;
    if (defined($result->{'accepted_date'}) and $result->{'accepted_date'} > 0) {
        push @dates, 'Accepted for publication on '.::timeformat('full-date', $result->{'accepted_date'}).'.';
    }
    if (defined($result->{'published_date'}) and $result->{'published_date'} > 0) {
        push @dates, 'Originally published on '.::timeformat('full-date', $result->{'published_date'}).'.';
    }
    push @lines, ::wrap_lines([join('  ', @dates)], $max_str_len, '', 0, 0) if @dates;

    my $longest_line = (sort { length($b) <=> length($a) } (@tm_lines, @lines))[0];

    my $fontsize = $p->string_calcsize($longest_line, $width * 0.95, undef, undef, undef, $prop_font);
    # Don't need it to be too big, regardless of how much space is available.
    $fontsize = 10 if $fontsize > 10;
    my $line_height = $p->string_MaxHeight($fontsize, $prop_font) * 1.35;
    my $line_pad = ($line_height - $p->string_MaxHeight($fontsize, $prop_font)) / 2;
    if ($line_height * (@tm_lines + @lines) > $height) {
        # There's not enough room for the paragraph.
        $p->grestore();
        end_page($p);
        ($width, $height) = SPEC_newpage($p, $result);
        $did_continue = 1;
    }
    $p->set_font($prop_font, $fontsize);

    # Cause the text to be centered
    my $base_x = ($width - $p->stringwidth($longest_line)) / 2;
    $p->gsave();
    {
        # Print the lines one at a time, starting at the last and working up.
        my $y = $p->baseline($line_pad);
        foreach my $line (reverse @lines) {
            $p->set_text_pos($base_x, $y);
            $p->show($line, undef, undef, 'tmsearch' => 1);
            $y += $line_height;
        }
        foreach my $line (reverse @tm_lines) {
            $p->set_text_pos($base_x, $y);
            $p->show($line);
            $y += $line_height;
        }
        $p->moveto(0, $y);
        $p->rlineto($width, 0);
        $p->stroke();
    }
    $p->grestore();

    return($did_continue, $width, $height);

}

sub SPEC_notes {
    my ($p, $config, $width, $height, $did_continue, $notes, $systype) = @_;

    return (0, 0, 0) unless (::ref_type($notes) eq 'ARRAY');

    foreach my $sectionref (@{$notes}) {
        next unless ref($sectionref) eq 'ARRAY';
        my ($section, $notesref) = @{$sectionref};
        next unless @{$notesref};

        my @tmpnotes = munge_links(auto_link(@{$notesref}));

        # Using a fixed-width font will help preserve notes formatting.
        # Thanks to John Henning for the suggestion.
        ($did_continue, $width, $height) = do_section($p, $config,
                                                      $width, $height,
                                                      'title'        => $section,
                                                      'title_size'   => 16,
                                                      'content_font' => $fixed_font,
                                                      'content'      => \@tmpnotes,
                                                      'border'       => $inch * 0.125,
                                                      'section'      => $systype);
        last if ($width == 0);
    }

    return ($did_continue, $width, $height);
}

sub auto_link {
    my (@lines) = @_;
    my @newlines = ();

    foreach my $line (@lines) {
        my $lineref = [ [ undef, $line ] ];
        if ($line =~ m#(?:(?:https?|ftp)://|mailto:)#i) {
            # Break it up into linked and non-linked sections
            $lineref = [];
            foreach my $chunk (split(m#((?:(?:https?|ftp)://|mailto:)[^[:space:]<>()]+)#i, $line)) {
                next if $chunk eq '';
                # If the previous chunk ends with LINK or ATTACH, or ends
                # with AS preceeded by LINK or ATTACH, then append this chunk
                # to the previous text.
                if ($#{$lineref} >= 0) {
                    my $prev_text = $lineref->[$#{$lineref}]->[1];
                    if ($prev_text =~ /(?:ATTACH|LINK)\s+$/ ||
                        $prev_text =~ /(?:ATTACH|LINK)\s+\S+\s+AS\s+$/) {
                        $lineref->[$#{$lineref}]->[1] .= $chunk;
                        next;
                    }
                }

                if ($chunk =~ m#(?:https?|ftp)://#i) {
                    push @{$lineref}, [ $chunk, $chunk ];
                } elsif ($chunk =~ m#^mailto:#i) {
                    my $url = $chunk;
                    $chunk =~ s/^mailto://i;
                    push @{$lineref}, [ $url, $chunk ];
                } else {
                    # If the previous chunk doesn't have a URL, then it
                    # was an incorrectly split ATTACH or LINK, and this
                    # chunk should be added to it
                    if ($#{$lineref} >= 0 &&
                        !defined($lineref->[$#{$lineref}]->[0])) {
                        $lineref->[$#{$lineref}]->[1] .= $chunk;
                    } else {
                        push @{$lineref}, [ undef, $chunk ];
                    }
                }
            }
        }
        push @newlines, $lineref;
    }

    return @newlines;
}

# This expects each line to be formatted in the way that auto_links will do
sub munge_links {
    my (@lines) = @_;
    my @newlines = ();

    foreach my $lineref (@lines) {
        $lineref = [ $lineref ] unless (::ref_type($lineref) eq 'ARRAY');
        for(my $i = 0; $i < @{$lineref}; $i++) {
            my $chunk = $lineref->[$i];
            $chunk = [ undef, $chunk ] unless (::ref_type($chunk) eq 'ARRAY');
            my ($url, $txt) = @{$chunk};
            my @newchunks = ();
            my $count = 0;
            while ($count < 40 &&
                $txt =~ s#(.*?)((ATTACH|LINK)\s+(\S+)\s+AS\s+(?:\[([^]]+)\]|(\S+)))##) {
                my ($pre, $what, $section, $url, $text) = ($1, $2, $3, $4, $5.$6);
                $count++;
                push @newchunks, [ undef, $pre ];

                if ($what eq 'LINK') {
                    # Make sure the URL has a scheme.  No direct file linking
                    # allowed here!  (Results files move around.)
                    if ($url !~ /^[a-zA-Z]+:/) {
                        ::Log(0, "\nERROR: Relative links and bare file paths may not be used as the URL part\n");
                        ::Log(0, "     of a notes LINK statement.\n");
                        push @newchunks, [ undef, $section ];
                        next;
                    }
                    my $uri = new URI($url);
                    $url = $uri->canonical->as_string;
                }
                push @newchunks, [ $url, $text ];
            }
            if ($txt ne '') {
                $url = undef unless $url ne '';
                push @newchunks, [ $url, $txt ];
            }

            if (@newchunks) {
                splice @{$lineref}, $i, 1, @newchunks;
                $i += @newchunks - 1;
            }
        }

        push @newlines, $lineref;
    }

    return @newlines;
}

sub size_result_table_columns {
    my ($p, $table_width, $titles, $results, $font_by_weight) = @_;

    # Figure out font sizes and column widths.  Font sizes for headings are
    # separate from result font sizes.
    # Here's the process:
    # - For each column, using the initial font sizes and weights (8.5 bold
    #   for headings; 10 normal for results), find the widest string in the
    #   column by weight.  For results, this is the longest integer part in
    #   the column plus the longest fractional part (so the column can be
    #   sized to hold both the largest and smallest values).  These longest
    #   strings and their corresponding font weights are recorded in an array
    #   which we use to figure out the total table width.
    # Then, until the total width of all columns fits on the page,
    # - For each column, calculate the width of each longest string using the
    #   current size for the weight needed by that string.
    # - Sum the widths of the columns, using the maximum value recorded for the
    #   strings in the column.  Note the font weights that contribute to the
    #   measurement.
    # - If the total widths of all the columns exceeds the width of the page,
    #   then decrease the font size for all font weights that contributed to
    #   the measurement.
    # Note: In all cases the string widths are increased by two MaxWidth
    #       characters because we don't want the words to crowd the edges of
    #       the column.
    my @column_minimums = map { { 'bold' => ['', 0], 'normal' => ['', 0] } } @$titles;

    # Figure out the longest strings in the header
    $p->set_font(@{$font_by_weight->{'bold'}});
    for(my $i = 0; $i < @$titles; $i++) {
        my @min_col_width = $p->maxwidths($p->string_MaxCapWidth(), split(/\n/, $titles->[$i]->[3]->{'label'}));
        $column_minimums[$i]->{'bold'} = [ @min_col_width ] if $min_col_width[1] > $column_minimums[$i]->{'bold'}->[1];
    }

    # Now the result rows.
    # There is some potential for error here, as we only calculate widths
    # using the normal weight font, but selected (median) results are
    # displayed in bold font.  It's probably not worth worrying about.
    $p->set_font(@{$font_by_weight->{'normal'}});
    my $result_idx = 0;
    for(my $i = 0; $i < @$titles; $i++) {
        my @values;
        if ($titles->[$i]->[3]->{'val'} eq 'name') {
            # Benchmark name is a special case
            @values = keys %$results;
        } else {
            my @numeric;
            foreach my $val (map { ::get_display_value($results, $_, $result_idx) } keys %$results) {
                if ($val !~ /^-?\d+(?:\.\d+)?$/) {
                    push @values, $val;
                } else {
                    # Split out the integer and fractional parts
                    push @numeric, [ split(/(\.\d+)/, $val) ];
                }
            }
            if (@numeric) {
                # For the composite number which will represent this column,
                # choose the combination of the widest integer part and the
                # widest fractional part.  There's potential for some error,
                # for example if that composite number wouldn't result in the
                # actual widest width of all the combinations.  That could
                # happen, for example, if the numbers on either side of the
                # decimal point are zeros (so that with the proportional font
                # the decimal point's width effectively goes to zero), and
                # there are combinations nearly as long where the decimal
                # point's width would contribute.
                # Still, the error should be less that one full width of a
                # decimal point, so it's negligible.
                my $max_int_str  = $p->maxwidths(0, map { $_->[0] } @numeric);
                my $max_frac_str = $p->maxwidths(0, map { $_->[1] } @numeric);
                push @values, $max_int_str.$max_frac_str;
            }
            $result_idx++;
        }
        my @min_col_width = $p->maxwidths($p->string_MaxCapWidth(), @values);
        $column_minimums[$i]->{'normal'} = [ @min_col_width ] if $min_col_width[1] > $column_minimums[$i]->{'normal'}->[1];
    }

    my $current_table_width;
    my @column_start;
    do {
        $current_table_width = 0;
        @column_start = (0);
        my %weights_seen = ();
        for(my $i = 0; $i < @column_minimums; $i++) {
            my $col = $column_minimums[$i];
            my $col_weight = reduce { $col->{$a}->[1] > $col->{$b}->[1] ? $a : $b } keys %$col;
            $weights_seen{$col_weight}++;
            $current_table_width += $col->{$col_weight}->[1];
            $column_start[$i + 1] = $current_table_width;
        }
        if ($current_table_width > $table_width) {
            # Reduce font sizes for contributing weights
            foreach my $weight (keys %weights_seen) {
                $font_by_weight->{$weight}->[1] -= 0.1;
                # Recalculate widths for the columns
                $p->set_font(@{$font_by_weight->{$weight}});
                foreach my $col (@column_minimums) {
                    my $str = $col->{$weight}->[0];
                    $col->{$weight} = [ $str, $p->stringwidth($str) + $p->string_MaxCapWidth() ];
                }
            }
        }
    } while ($current_table_width > $table_width);

    # Distribute the leftover space equally among the columns
    my $column_adjust_step = ($table_width - $current_table_width) / (@column_start - 1);
    my $column_adjust = $column_adjust_step;
    $current_table_width = 0;
    for(my $i = 0; $i < @column_start - 1; $i++) {
        $column_start[$i+1] += $column_adjust;
        $column_adjust += $column_adjust_step;
        $current_table_width += ($column_start[$i+1] - $column_start[$i]);
    }

    return @column_start;
}

# Canonicalize a URL and return its filename (or username, for mailto:) part
# and the canonicalized form.
sub get_url_filename {
    my ($url, $txt) = @_;

    my $uri = URI->new($url);
    $url = $uri->canonical->as_string;
    my $tmptxt = '';
    eval { $tmptxt = (reverse $uri->path_segments)[0] };
    if ($@ ne '' or $tmptxt eq '') {
        $tmptxt = $txt;
    }
    $tmptxt =~ s/^mailto://;     # It's special

    return wantarray ? ($tmptxt, $url) : $tmptxt;
}

# Stolen from Math::Complex and Math::Trig, though they could've come
# from a textbook, too.
sub pi { 4 * atan2(1, 1) }
sub rad2deg { (360 / (2 * pi)) * $_[0] }

1;
# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab colorcolumn=120:
