#
# PSPDF.pm
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: PSPDF.pm 6255 2019-06-11 15:37:45Z CloyceS $
#

require 'util.pl';
require 'flagutils.pl';

package PSPDF;
use Font::AFM;
use IO::File;
use List::Util qw(min reduce);
use List::MoreUtils qw(pairwise);
use File::Basename qw(basename);
use SVG;
use strict;

use vars qw($indent %afms);
my $version = '$LastChangedRevision: 6255 $ '; # Make emacs happier
$version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'PSPDF.pm'} = $version;

our $inch = 72;
our $fixed_font     = 'Courier';
our $prop_font      = 'Times-Roman';
our $prop_bold_font = 'Times-Bold';
our %tunecolor = (
    'peak'  => [ 0.15, 0.15, 0.70 ],
    'base'  => [ 0   , 0   , 0    ],
    'error' => [ 0.87, 0   , 0    ],
);
our %default_style = (
    'stroke-dasharray' => 'none',
    'stroke-width'     => '1px',
    'stroke'           => 'black',
    'fill'             => 'none',
    'fill-opacity'     => 0,
);

$indent = '';

sub new {
    my ($class, $mode, $landscape) = @_;
    if ($mode ne 'SVG' and $mode ne 'PDF' and $mode ne 'PS') {
        main::Log(0, "PSPDF::new: mode of '$mode' not supported, using 'PDF'\n");
        $mode = 'PDF';

    } elsif ($mode eq 'PDF' and !$::PDF_ok) {
        main::Log(0, "NOTICE: PDF output is disabled\n");
        return bless { 'error' => 1 }, $class;

    } elsif ($mode eq 'PS' and eval { ::PostScript_ok() } != 1) {
        main::Log(0, "NOTICE: PostScript output is disabled\n");
        return bless { 'error' => 1 }, $class;
    }

    my $me = bless {
        'mode'    => $mode,   # This should be PDF, PS, or SVG
        'output'  => '',
        'isopen'  => 0,
        'CreationDate' => '',
        'Creator' => '',
        'Producer'=> '',
        'Author'  => '',
        'Title'   => '',
        'Subject' => '',
        'changedfont' => 0,
        'states'  => [],
        'saves'   => [],
        'possave' => [],
        'tm_done' => {},
    }, $class;
    return $me;
}

sub output {
    my ($me) = @_;
    if ($me->{'isopen'}) {
        main::Log(0, "PSPDF::output: called when object still open!\n");
        return '';
    }
    # Fix up the number of pages
    if ($me->{'mode'} eq 'PS' or $me->{'mode'} eq 'SVG') {
        my $pages = $me->{'pagenum'} || 0;
        $me->{'output'} =~ s/%%PUTPAGESHERE%%/$pages/;
    }
    return $me->{'output'};
}

sub DESTROY {
    my ($me) = @_;
    unlink ($me->{'outputname'}) if $me->{'outputname'} ne '';
}

sub anon_var {
    my ($me, $name, $val) = @_;
    my $old = $me->{$name};
    $me->{$name} = $val if defined $val;
    return $old;
}
sub CreationDate { my $me = shift; return $me->anon_var('CreationDate', @_); }
sub Creator { my $me = shift; return $me->anon_var('Creator', @_); }
sub Producer{ my $me = shift; return $me->anon_var('Producer', @_); }
sub Author  { my $me = shift; return $me->anon_var('Author' , @_); }
sub Title   { my $me = shift; return $me->anon_var('Title'  , @_); }
sub Subject { my $me = shift; return $me->anon_var('Subject', @_); }

sub open {
    my ($me) = @_;
    if ($me->{'mode'} eq 'PS') {
        $me->{'output'}="%!PS-Adobe-3.0\n";
        $me->{'output'}.="%%Pages: %%PUTPAGESHERE%%\n";
    } elsif ($me->{'mode'} eq 'PDF') {
        $me->{'pdf'} = PDF::API2->new();
        #$me->{'pdf'}->{'forcecompress'} = 0;
        $me->{'ip'} = {};
        for my $foo (qw(CreationDate Creator Author Title Subject Producer)) {
            $me->{'ip'}->{$foo} = $me->{$foo};
        }
        $me->{'pdf'}->info(%{$me->{'ip'}});
        $me->{'pdf'}->preferences('-onecolumn' => 1);
    } elsif ($me->{'mode'} eq 'SVG') {
        $me->{'svg'} = undef;
        # The object and everything else will be created in begin_page()
    }
    $me->{'isopen'}=1;
}

sub close {
    my ($me) = @_;
    if ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "%%EOF\n";
    } elsif ($me->{'mode'} eq 'PDF' and $me->{'isopen'}) {
        $me->{'output'} = $me->{'pdf'}->stringify;
        $me->{'pdf'}->end;
    } elsif ($me->{'mode'} eq 'SVG' and $me->{'isopen'}) {
        $me->{'output'} = $me->{'svg'}->xmlify();
    }
    $me->{'isopen'}=0;
}

use vars qw(@pagenumtxt);
@pagenumtxt = qw(zero one two three four five six seven eight nine ten);

sub begin_page {
    my ($me, $size) = @_;

    if ($size =~ /letter/) {
        $me->{'width'}  = 612;
        $me->{'height'} = 792;
    } elsif ($size =~ /a4/) {
        $me->{'width'}  = 595;
        $me->{'height'} = 842;
    }
    if ($size =~ /landscape/) {
        my $t = $me->{'width'};
        $me->{'width'} = $me->{'height'};
        $me->{'height'} = $t;
    }
    if ($me->{'mode'} eq 'PDF') {
        $me->{'page'} = $me->{'pdf'}->page;
        $me->{'page'}->mediabox($me->{'width'}, $me->{'height'});
        $me->{'content'} = $me->{'page'}->gfx;
        $me->{'pagenum'}++;
    } elsif ($me->{'mode'} eq 'PS') {
        my $num = ++$me->{'pagenum'};
        $me->{'output'} .= "%%Page: $pagenumtxt[$num] $num\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        $me->{'pagenum'}++;
        # Actually make the SVG object.  This implicitly means that the last
        # page wins.  For SVG, there should be only one.
        $me->{'svg'} = SVG->new(
            '-version'     => 1.1,
            '-baseProfile' => 'full',
            '-pubid'       => "-//W3C//DTD SVG 1.1//EN",
#            '-standalone'  => 'yes',
            '-inline'      => 'yes',
            '-nocredits'   => 1,  # To keep it small
            'id'           => 'resultgraph',
            '-indent'      => 1 ? '  ' : '',     # Change 0 => 1 for debug
            'width'        => $me->{'width'}.'px',
            'height'       => $me->{'height'}.'px',
        );
        $me->{'tag'} = $me->{'transform_group'} = $me->{'svg'}->group(transform => 'scale(1,-1)');
        $me->{'groups'} = [
            {
                'tag'  => $me->{'transform_group'},
                'save' => 1,
            },
        ];
        $me->{'pending_style'} = \%default_style;
        $me->gsave();
        $me->{'texts'} = [];
    }
}

sub end_page {
    my ($me) = @_;
    if ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "showpage\n";
    }
}

sub get_font {
    my ($me) = @_;
    # If the font has not been set, return reasonable values such that
    # things expecting to be able to generate measurements will be able
    # to generate measurements that are non-zero.
    $me->{'fontname'} = 'Symbol' unless defined($me->{'fontname'});
    $me->{'fontsize'} = 1 unless defined($me->{'fontsize'});
    return($me->{'fontname'}, $me->{'fontsize'});
}

sub find_font {
    my($me, $font) = @_;

    if (!exists($afms{$font}) or ref($afms{$font}) ne 'Font::AFM') {
        $afms{$font} = new Font::AFM "$ENV{'SPEC'}/bin/fonts/$font";
    }
    return $afms{$font};
}

sub set_font {
    my ($me, $font, $size, $force) = @_;
    $size = $me->{'fontsize'} unless defined($size);

    return if (!(defined($force) and $force)
            and $me->{'fontsize'} == $size
            and $me->{'fontname'} eq $font);
    $me->{'afm'} = $me->find_font($font);
    $me->{'fontsize'} = $size;
    $me->{'fontname'} = $font;
    $me->{'changedfont'} = 1;
    if ($me->{'mode'} eq 'PDF') {
        my $encoding = 'winansi';
        $encoding = 'builtin' if ($me->{'fontname'} eq 'Symbol');
        # It's hard to believe that PDF::API2 doesn't do this internally!
        if (exists $me->{'pdffonts'}->{$me->{'fontname'}.$encoding}) {
            $me->{'currfont'} = $me->{'pdffonts'}->{$me->{'fontname'}.$encoding};
        } else {
            $me->{'currfont'} = $me->{'pdffonts'}->{$me->{'fontname'}.$encoding} =
            $me->{'pdf'}->corefont($me->{'fontname'},
                '-encoding' => $encoding);
        }
    }
}

sub set_font_really {
    my ($me) = @_;
    if ($me->{'mode'} eq 'PDF') {
        $me->set_font($me->{'fontname'}, $me->{'fontsize'});
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "/$me->{'fontname'} findfont $me->{'fontsize'} scalefont setfont\n";
    }
}

sub set_text_pos {
    my ($me, $x, $y) = @_;
    $me->{'text_x'} = $x;
    $me->{'text_y'} = $y;

    if ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$x $y moveto\n";
    }
}

sub stringwidth {
    my ($me, $str, $size, $font) = @_;
    my $rc = 0;
    if (!defined($size) or !defined($font)) {
        my @curr = $me->get_font();
        $size = $curr[1] if !defined($size);
        $font = $curr[0] if !defined($font);
    }
    return 0 if abs($size) < 0.0005;
    return 0 if $str eq '';

    # Always use the AFM metrics as this prevents us from inadvertantly growing
    # the PDF file by changing the fonts all the time.
    my $afm = $me->find_font($font);
    $rc = $afm->stringwidth($str, $size);

    # Here's a hack...
    if ($rc == 0 and $font eq 'Symbol') {
        # It seems unlikely that any symbol would have absolutely zero width...
        $rc = $afm->stringwidth(' ' x (length($str) + 2), $size);
    }
    return $rc;
}

sub string_fit {
    my ($me, $str, $x, $y, $width, $height, $minsize, $errtext, %opts) = @_;
    $opts{'fit_xbump'} = 0 unless defined($opts{'fit_xbump'});

    # Figure out the size
    my $size = $me->string_calcsize($str, $width, $height, $minsize, $errtext);
    return 0 if ($size <= 0);
    $me->set_font(($me->get_font())[0], $size);
    my $baseline = $me->baseline(($height - $me->string_MaxHeight()) / 2);
    $me->set_text_pos($x + $opts{'fit_xbump'}, $y + $baseline);
    if ($opts{'fit_align'} eq 'center') {
        $me->show_center($str, undef, undef, %opts);
    } elsif ($opts{'fit_align'} eq 'right') {
        $me->show_right($str);
    } else {
        # Assume left
        $me->show($str, undef, undef, %opts);
    }
    return $size;
}

sub string_fit_right {
    my ($me, $str, $x, $y, $width, $height, $minsize, $errtext, %opts) = @_;
    return $me->string_fit($str, $x, $y, $width, $height, $minsize, $errtext,
                           %opts, 'fit_align' => 'right');
}

sub string_fit_center {
    my ($me, $str, $x, $y, $width, $height, $minsize, $errtext, %opts) = @_;
    return $me->string_fit($str, $x, $y, $width, $height, $minsize, $errtext,
                           %opts, 'fit_align' => 'center',
                                  'fit_xbump' => $width / 2);
}

sub strings_fit {
    my ($me, $x, $y, $width, $height, $minsize, $maxsize, $erritem, @lines) = @_;
    # Do the right thing for array refs
    for(my $i = 0; $i < @lines; $i++) {
        if (ref($lines[$i]) eq 'ARRAY') {
            splice(@lines, $i, 1, @{$lines[$i]});
        }
    }
    return 1 unless @lines;

    my $line_pad_factor = 0.1; # Allow 5% above and below
    my $line_height = $height / @lines / ($line_pad_factor + 1);

    # Figure out the font size, starting at the largest.
    my $size = $maxsize;
    if ($me->string_MaxHeight($size) > $line_height) {
        $size = binary_solution_search(
                    $maxsize, $line_height, 0.05,
                    sub { $me->string_MaxHeight($_[0]) }
                );
    }
    if ($size == 0 or $size < $minsize) {
        main::Log(0, "\nThere are too many $erritem lines to fit within the available space!\n");
        return 0;
    }

    $size = min(
        $size,
        map { $me->string_calcsize($_, $width, $line_height, $minsize, "Your $erritem line is too long!\n") } @lines
    );
    return 0 if ($size <= 0);

    $me->set_font(($me->get_font())[0], $size, 1);

    # Text baseline is half the pad factor plus the size of the descender
    # (which is figured into $size)
    my $baseline = $me->baseline($line_height * $line_pad_factor / 2);

    # Actually show the strings
    foreach my $line (reverse @lines) {
        $me->set_text_pos($x, $y + $baseline);
        $me->show($line);
        $y += $line_height;
    }

    return $size;
}

sub baseline {
    my ($me, $pad, $size, $font) = @_;
    $pad = 0 unless defined($pad);
    if (!defined($size) or !defined($font)) {
        my @curr = $me->get_font();
        $size = $curr[1] if !defined($size);
        $font = $curr[0] if !defined($font);
    }
    $pad = -1 * $me->string_MaxHeight($size, $font) / 2 if $pad eq 'vcenter';
    return abs($me->string_Descender($size, $font)) + $pad;
}

# Do a sort of binary search until &${func}($initial) is within $error of
# $target and does not exceed it.
sub binary_solution_search {
    my ($initial, $target, $error, $func) = @_;

    return $initial unless ref($func) eq 'CODE';

    my $current = $initial;
    my $value = my $previous = &{$func}($initial);

    return $initial unless ($value > $target or ($target - $value) / $target > $error);

    # Find initial bounds of the interval
    my $lower = my $upper = $initial;
    my $adj = $initial / 2;     # Keep from adjusting lower to 0 initially
    if ($value > $target) {
        while($value > $target) {
            $upper = $lower;
            $lower -= abs($adj);
            $adj *= 2;
            $value = &{$func}($lower);
        }
        $current = $lower;
    } else {
        while($value < $target) {
            $lower = $upper;
            $upper += abs($adj);
            $adj *= 2;
            $value = &{$func}($upper);
        }
        $current = $upper;
    }

    # Now bounce around the solution until $current is close enough
    my $direction = 0;
    while($value > $target or ($target - $value) / $target > $error) {
        if ($value > $target) {
            $direction = -1;
            $upper = $current;
            $lower -= $current if $lower == 0 or abs(($lower - $upper) / $lower) < 0.01;
        } else {
            $direction = 1;
            $lower = $current;
            $upper += $current if $lower == 0 or abs(($lower - $upper) / $lower) < 0.01;
        }
        $current += ($upper - $lower) / 2 * $direction;
        $value = &{$func}($current);
        last if abs($value - $previous) < 0.00001;    # Not making any progress
        $previous = $value;
    }
    return $current;
}

sub string_calcsize {
    my ($me, $str, $width, $height, $minsize, $errtext, $font) = @_;

    my ($curfont, $size) = $me->get_font();
    $font = $curfont unless defined($font);

    return $size if $str eq '' or (!defined($width) and !defined($height));

    my ($vsize, $hsize) = (999999, 999999);
    if (defined($height) and $height > 0) {
        # Figure out the font size that will allow the string to fill at least 99%
        # of the height.
        my $heightfunc = sub { $me->string_MaxHeight(shift, $font) };
        $vsize = binary_solution_search($size, $height, 0.01, $heightfunc);
    }

    if (defined($width) and $width > 0) {
        # Figure out the font size that will allow the string to fill at least 99%
        # of the width.
        my $widthfunc = sub { $me->stringwidth($str, shift, $font) };
        $hsize = binary_solution_search($size, $width, 0.01, $widthfunc);
    }

    # Resulting size to use is the minimum of the two
    $size = min($vsize, $hsize);

    if (defined($minsize) and $size < $minsize and $errtext ne '') {
        my $txt = $errtext;
        $txt =~ s/%s/sprintf "%.2f", $size/eg;
        main::Log(0, "\n$txt\n");
    }
    return $size;
}

# Construct the font metric functions string_XHeight, string_CapHeight,
# string_Descender, and string_Ascender for data that comes directly
# from the font metrics.
foreach my $metric (qw(XHeight CapHeight Descender Ascender)) {
    eval 'sub string_'.$metric.' {
            my ($me, $size, $font) = @_;
            if (!defined($size) or !defined($font)) {
                my @curr = $me->get_font();
                $font = $curr[0] unless defined($font);
                $size = $curr[1] unless defined($size);
            }
            my $afm = $me->find_font($font);
            return $afm->'.$metric.'() * $size / 1000;
        }';
    die $@ if $@;
}

sub string_MaxHeight {
    my ($me, $size, $font) = @_;
    if (!defined($size) or !defined($font)) {
        my @curr = $me->get_font();
        $font = $curr[0] unless defined($font);
        $size = $curr[1] unless defined($size);
    }
    my $afm = $me->find_font($font);
    my ($llx, $lly, $urx, $ury) = $afm->FontBBox();
    my $val;
    if (defined($lly) and defined($ury) and ($ury - $lly) > 0) {
        $val = ($ury - $lly) * $size / 1000;
    } else {
        # No bounding box info; fake it up using ascender and descender
        $val = $me->string_Ascender($size, $font) + abs($me->string_Descender($size, $font));
    }
    return $val;
}

# Construct the font width functions string_MaxWidth, string_MaxCapWidth,
# string_MaxLCWidth, and string_MaxDigitWidth for data that is derived from
# the font metrics.
my %font_width_classes = (
    ''      => undef,   # All symbols for which there's width data
    'Cap'   => [ 'A' .. 'Z' ],
    'LC'    => [ 'a' .. 'z' ],
    'Digit' => [qw( zero one two three four five six seven eight nine )],
);
foreach my $metric (map { ("Avg${_}Width", "Max${_}Width") } keys %font_width_classes) {
    eval 'sub string_'.$metric.' {
            my ($me, $size, $font) = @_;
            if (!defined($size) or !defined($font)) {
                my @curr = $me->get_font();
                $font = $curr[0] unless defined($font);
                $size = $curr[1] unless defined($size);
            }
            $me->get_font_widths($font) unless exists($me->{'.$metric.'}->{$font});
            my ($width, $char) = @{$me->{'.$metric.'}->{$font}};
            $width *= $size / 1000;
            return wantarray ? ($width, $char) : $width;
        }';
    die $@ if $@;
}

sub get_font_widths {
    my ($me, $font) = @_;
    my $afm = $me->find_font($font);
    my $wx = $afm->Wx();
    if ((::ref_type($wx) ne 'HASH')) {
        main::Log(0, "ERROR: Found no character width data for $font!\n");
        $wx = {};
    }
    foreach my $class (keys %font_width_classes) {
        my @chars = defined($font_width_classes{$class}) ? @{$font_width_classes{$class}} : sort keys %$wx;
        my @width = (0, '');
        my ($total, $count) = (0, 0);
        foreach my $char (@chars) {
            @width = ( $wx->{$char}, $char ) if ($wx->{$char} > $width[0]);
            $total += $wx->{$char};
            $count++;
        }
        $count++ unless $count; # Avoid divide-by-zero when WX data unavailable

        $me->{'Max'.$class.'Width'}->{$font} = [ @width ];
        $me->{'Avg'.$class.'Width'}->{$font} = [ $total / $count, '' ];
    }
}

sub fontsize {
    my ($me) = @_;

    return $me->{'fontsize'};
}

sub fit_link_center {
    my ($me, $str, $x, $y, $width, $height, $minsize, $errtext, %opts) = @_;

    if (::ref_type($str) eq 'ARRAY') {
        # Assemble the text of the string
        my $tmpstr = join('', map { (::ref_type($_) eq 'ARRAY') ? $_->[1] : $_ } @{$str});
        # Get the font size to use
        my $size = $me->string_calcsize($tmpstr, $width, $height, $minsize, $errtext);
        return 0 if ($size <= 0);
        $me->set_font($me->{'fontname'}, $size);
        # Get some relevant dimensions
        my $strwidth = $me->stringwidth($tmpstr);
        my $xpos = $x + ( $width / 2) - ( $strwidth / 2);
        my $ypad = ($height - $me->string_MaxHeight()) / 2;
        my $ypos = $y + $me->baseline($ypad);
        foreach my $fragment (@{$str}) {
            $me->set_text_pos($xpos, $ypos);
            my ($url, $string) = (undef, undef);
            if (::ref_type($fragment) eq 'ARRAY') {
                ($url, $string) = @{$fragment};
            } else {
                $url = undef;
                $string = $fragment;
            }
            $me->show($string, undef, $url, %opts);
            $xpos += $me->stringwidth($string);
        }
        return $size;
    } else {
        return $me->string_fit_center($str, $x, $y, $width, $height, $minsize, $errtext, %opts);
    }
}

sub linkto {
    my ($me, $str, $ul, %opts) = @_;
    my $url;

    if (exists($opts{'isbench'}) and $opts{'isbench'}) {
        $url = $::bench_url_base."/${str}.html";
    } else {
        my $anchor = ::makeanchor($opts{'section'}.$str);
        $anchor =~ s/(\S)continued$/$1/i; # Always goes to the same place anyway

        # Relative file links do not "just work".  In fact, they don't work.  So
        # everyone will get to visit SPEC for the answers!
        $url = $::auto_docs_url_base."/result-fields.html#$anchor";
    }

    if ($opts{'linkalign'} eq 'right') {
        return $me->show_right($str, $ul, $url, %opts);
    } elsif ($opts{'linkalign'} eq 'center') {
        return $me->show_center($str, $ul, $url, %opts);
    } else {
        return $me->show($str, $ul, $url, %opts);
    }
}

sub linkto_center {
    my ($me, $str, $ul, %opts) = @_;
    return $me->linkto($str, $ul, %opts, 'linkalign' => 'center');
}

sub linkto_right {
    my ($me, $str, $ul, %opts) = @_;
    return $me->linkto($str, $ul, %opts, 'linkalign' => 'right');
}

sub show {
    my ($me, $str, $ul, $url, %opts) = @_;
#print "show($me, str=\"$str\", ul=$ul, url=\"$url\",opts=(\n    ".join(",\n    ", map { "$_ => $opts{$_}" } sort keys %opts)."\n   ))\n";

    if ($opts{'tmsearch'}) {
        # Looking at strings that might contain SPEC trademarks, so hand the
        # whole mess off to fixup_trademarks, which will call us back to
        # actually show the parts of the strings
        $me->fixup_trademarks($str, $ul, $url, %opts);
        return;
    }
    if ($me->{'changedfont'}) {
        $me->set_font_really();
        $me->{'changedfont'} = 0;
    }
    if ($me->{'mode'} eq 'PDF') {
        $str =~ s/\\(\d{3})/chr(oct($1))/ego if $opts{'doencode'};
        $me->{'content'}->textlabel($me->{'text_x'}, $me->{'text_y'},
            $me->{'currfont'}, $me->{'fontsize'},
            $str, $ul ? (-underline => [ 'auto', $ul]) : (), %opts);
        if (defined($url) && $url ne '') {
            my $ant = $me->{'page'}->annotation;
            if ((::ref_type($url) eq 'PDF::API2::NamedDestination')) {
                $ant->dest($url);
            } else {
                ::Log(99, "\nPDF EMBEDDED LINK: {$url}\n");
                $ant->url($url);
            }
            # Adding mx and my (current total translation) is necessary
            # because the annotation rectangles are rendered _after_ all the
            # graphics states are un-done.
            my @rect = (
                $me->{'mx'} + $me->{'text_x'},  # llx
                $me->{'my'} + $me->{'text_y'} + $me->string_Descender,  # lly
                $me->{'mx'} + $me->{'text_x'} + $me->stringwidth($str), # urx
                $me->{'my'} + $me->{'text_y'} + $me->string_CapHeight);# + $me->string_Descender); # ury
            $ant->rect(@rect);
            #$ant->border(0.1, 0.1, 0.5); # YYY Only for debugging!
            $ant->content($str);
        }
        $me->{'text_x'} += $me->stringwidth($str);
    } elsif ($me->{'mode'} eq 'PS') {
        $str =~ s/([(\\%)])/\\$1/g unless $opts{'noescape'};
#       $me->{'output'} .= "($str \(".sprintf("%.2f", $me->{'fontsize'})."\)) show\n";
        if (exists($opts{-render}) && $opts{-render} == 1) {
            $me->{'output'} .= "($str) false charpath stroke\n";
        } else {
            $me->{'output'} .= "($str) show\n";
        }
        if ($ul) {
            # Do an underline
            $me->gsave();
            $me->{'output'} .= "$ul setlinewidth\n";
            $me->{'output'} .= "0 -1 rmoveto\n";
            $me->{'output'} .= "($str) stringwidth\n";
            $me->{'output'} .= "exch neg exch rlineto stroke\n";
            $me->grestore();
        }
    } elsif ($me->{'mode'} eq 'SVG') {
        # XXX
    }
}

sub continue_text {
    my ($me, $str, $ul, $url, %opts) = @_;
    #print "continue_text(\$me, str='$str', ul=$ul, url='$url', \%opts)\n";

    $me->{'text_y'} -= $me->string_MaxHeight();

    if ($me->{'mode'} eq 'PS') {
        $me->set_text_pos($me->{'text_x'}, $me->{'text_y'});
    }
    $me->show($str, $ul, $url, %opts);
}

sub show_center {
    my ($me, $str, $ul, $url, %opts) = @_;
    $opts{'direction'} = 1 unless $opts{'direction'};

    my $x = $me->{'text_x'};
    my $y = $me->{'text_y'};
    my ($save_x, $save_y) = ($x, $y);

    foreach my $tmpstr (reverse split(/\n/, $str)) {
        $x -= $me->stringwidth($tmpstr)/2;
        $me->set_text_pos($x, $y);
        $me->show($tmpstr, $ul, $url, %opts);
        $x = $save_x;
        $y += $opts{'direction'} * $me->string_MaxHeight() * 1.05;
    }
    $me->{'text_x'} = $save_x;
    $me->{'text_y'} = $save_y;
}

sub continue_text_center {
    my ($me, $str, $ul, $url, %opts) = @_;
    $me->{'text_y'} -= $me->{'fontsize'};
    $me->show_center($str, $ul, $url, %opts);
}

sub show_right {
    my ($me, $str, $ul, $url, %opts) = @_;

    my $x = $me->{'text_x'};
    my $y = $me->{'text_y'};
    my $oldx = $x;


    $x -= $me->stringwidth($str);

    $me->set_text_pos($x, $y);
    $me->show($str, $ul, $url, %opts);
    $me->{'text_x'} = $oldx;
}

sub continue_text_right {
    my ($me, $str, $ul, $url, %opts) = @_;
    $me->{'text_y'} -= $me->{'fontsize'};
    $me->show_right($str, $ul, $url, %opts);
}

sub moveto {
    my ($me, $x, $y) = @_;

    $me->{'x'} = $x;
    $me->{'y'} = $y;

    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->move($x, $y);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$x $y moveto\n";
    }
}

sub lineto {
    my ($me, $x, $y) = @_;

    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->line($x, $y);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$x $y lineto\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        $me->{'tag'}->line(
            x1 => $me->{'x'},
            y1 => $me->{'y'},
            x2 => $x,
            y2 => $y,
        );
    }

    $me->{'x'} = $x;
    $me->{'y'} = $y;

}

sub rlineto {
    my ($me, $x, $y) = @_;

    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->line($me->{'x'} + $x, $me->{'y'} + $y);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$x $y rlineto\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        my @save = ($me->{'x'}, $me->{'y'});
        $me->lineto($me->{'x'} + $x, $me->{'y'} + $y);
        ($me->{'x'}, $me->{'y'}) = @save;
    }

    $me->{'x'} += $x;
    $me->{'y'} += $y;
}

sub setdash {
    my ($me, $spacing) = @_;

    if (ref($spacing) ne 'ARRAY') {
        if ($spacing+0) {
            $spacing = [ $spacing ];
        } else {
            $spacing = [ ];
        }
    }
    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->linedash(@{$spacing});
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "[ ".join(' ', @{$spacing})." ] 0 setdash\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        if (@{$spacing} == 0 or $spacing->[0] == 0) {
            $me->{'pending_style'}->{'stroke-dasharray'} = 'none';
        } else {
            $me->{'pending_style'}->{'stroke-dasharray'} = join(',', @$spacing);
        }
    }
}

sub curveto {
    my ($me, $x1, $y1, $x2, $y2, $x3, $y3) = @_;

    $me->{'x'} = $x3;
    $me->{'y'} = $y3;

    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->curve($x1, $y1, $x2, $y2, $x3, $y3);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$x1 $y1 $x2 $y2 $x3 $y3 curveto\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        # XXX
    }
}

sub circle {
    my ($me, $x, $y, $r) = @_;

    $me->{'x'} = $x;
    $me->{'y'} = $y;
    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->circle($x, $y, $r);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "newpath $x $y $r 0 360 arc closepath\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        # XXX
    }
}

sub circle_fill {
    my ($me, $x, $y, $r, $gray, $width, $do_line) = @_;

    $me->{'x'} = $x;
    $me->{'y'} = $y;
    $me->gsave();
    $me->setgray($gray)       if defined $gray;
    $me->circle($x, $y, $r);
    $me->fill();
    $me->grestore();
    if ((defined($do_line) && $do_line) || defined($width)) {
        $me->gsave();
        $me->setlinewidth($width) if defined $width;
        $me->circle($x, $y, $r);
        $me->stroke();
        $me->grestore();
    }
}

sub translate {
    my ($me, $x, $y) = @_;

    return if ($x == 0 and $y == 0);

#print "${indent}$x $y translate at line ".(caller)[2]."\n";
    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->transform(-translate => [ $x, $y ]);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$x $y translate\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        my %current_style = %{$me->{'groups'}->[0]};
        $current_style{'tag'} = $me->{'tag'} = $me->{'tag'}->g(transform=>"translate($x,$y)");
        $current_style{'save'} = 0;
        unshift @{$me->{'groups'}}, { %current_style };
    }
    $me->{'mx'} += $x;
    $me->{'my'} += $y;
}

sub rect {
    my ($me, $x, $y, $w, $h) = @_;

    $me->{'x'} = $x;
    $me->{'y'} = $y;

    my $nh = -$h;

    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->rect($x, $y, $w, $h);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$x $y moveto 0 $h rlineto $w 0 rlineto 0 $nh rlineto closepath\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        if ($h < 0) {
            $h = abs($h);
            $y -= $h;
        }
        if ($w < 0) {
            $w = abs($w);
            $x -= $w;
        }
        $me->{'tag'}->rectangle(
            x => $x, y => $y,
            width => $w, height => $h,
        );
    }
}

sub rectxy {
    my ($me, $x1, $y1, $x2, $y2) = @_;

    # Draw a rectange with opposite corners at (x1,y1) and (x2,y2)
    $me->rect($x1, $y1, ($x2 - $x1), ($y2 - $y1));
}

sub rect_fill {
    my ($me, $x, $y, $w, $h, $gray, $width, $do_line) = @_;
#print "rect_fill($me, $x, $y, $w, $h, $gray, $width, $do_line)\n";
    $me->{'x'} = $x;
    $me->{'y'} = $y;
    $me->gsave();
    $me->setgray($gray)       if defined $gray;
    $me->rect($x, $y, $w, $h);
    $me->fill();
    $me->grestore();
    if ((defined($do_line) && $do_line) || defined($width)) {
        $me->gsave();
        $me->setlinewidth($width) if defined $width;
        $me->rect($x, $y, $w, $h);
        $me->stroke();
        $me->grestore();
    }
}

sub rectxy_fill {
    my ($me, $x1, $y1, $x2, $y2, $gray, $width, $do_line) = @_;

    # Draw & fill a rectange with opposite corners at (x1,y1) and (x2,y2)
    $me->rect_fill($x1, $y1, ($x2 - $x1), ($y2 - $y1), $gray, $width);
}

sub poly {
    my ($me, @coords) = @_;

    my ($x, $y) = @coords[0,1];
    return unless defined($x) && defined($y);

    # Snip dangling ordinate, if any
    if ($#coords % 2 == 0) {
        splice(@coords,-1);
    }

    my ($lastx, $lasty) = @coords[$#coords-1, $#coords];

    $me->{'x'} = $x;
    $me->{'y'} = $y;
    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->poly(@coords);
    } else {
        ($x, $y) = splice(@coords, 0, 2);
        return unless defined($x) && defined($y);
        $me->moveto($x, $y);
        while (@coords) {
            ($x, $y) = splice(@coords, 0, 2);
            last if (!defined($x) || !defined($y));
            $me->lineto($x, $y);
        }
    }
    $me->closepath if (($lastx != $me->{'x'}) || ($lasty != $me->{'y'}));
}

sub poly_fill {
    my ($me, $coords, $gray, $width, $do_line) = @_;
    return unless ref($coords) eq 'ARRAY';

    my ($x, $y) = @{$coords}[0,1];
    return unless defined($x) && defined($y);

    $me->{'x'} = $x;
    $me->{'y'} = $y;
    $me->gsave();
    $me->setgray($gray)       if defined $gray;
    $me->poly(@{$coords});
    $me->fill();
    $me->grestore();
    if ((defined($do_line) && $do_line) || defined($width)) {
        $me->gsave();
        $me->setlinewidth($width) if defined $width;
        $me->poly(@{$coords});
        $me->stroke();
        $me->grestore();
    }
}

sub setcolor {
    my ($me, $color, $force) = @_;
    if (ref($color) eq 'ARRAY') {
        # Colors
        if ($force
                or ref($me->{'color'}) ne 'ARRAY'
                or min(pairwise { $a == $b } @$color, @{$me->{'color'}}) == 0) {
            return $me->setrgbcolor(@$color);
        }
    } else {
        # Gray value
        if ($force
                or ref($me->{'color'}) eq 'ARRAY'
                or $color != $me->{'color'}) {
            return $me->setgray($color+0);
        }
    }
    return;
}

sub setgray {
    my ($me, $gray) = @_;

    if ($me->{'mode'} eq 'PDF') {
        $me->setrgbcolor($gray, $gray, $gray);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$gray setgray\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        $me->{'pending_style'}->{'fill'} =
        $me->{'pending_style'}->{'stroke'} =
        sprintf("rgb(%d,%d,%d)", $gray * 255, $gray * 255, $gray * 255);
    }

    $me->{'color'} = $gray;
}

sub setrgbcolor {
    my ($me, $red, $green, $blue) = @_;

    $me->{'color'} = [ $red, $green, $blue ];

    if ($me->{'mode'} eq 'PDF') {
        my $colorstr = sprintf("#%02x%02x%02x",
            $red * 255, $green * 255, $blue * 255);
        $me->{'content'}->fillcolor($colorstr);
        $me->{'content'}->strokecolor($colorstr);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$red $green $blue setrgbcolor\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        $me->{'pending_style'}->{'fill'} =
        $me->{'pending_style'}->{'stroke'} =
        sprintf("rgb(%d,%d,%d)", $red * 255, $green * 255, $blue * 255);
    }
}

sub setlinewidth {
    my ($me, $w) = @_;

    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->linewidth($w);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$w setlinewidth\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        $me->{'pending_style'}->{'stroke-width'} = $w.'px';
    }
}

sub rotate {
    my ($me, $w) = @_;

    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->transform(-rotate => $w);
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "$w rotate\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        # XXX
    }
}

sub fill {
    my ($me) = @_;

    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->fill;
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "fill\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        # XXX set the fill-opacity on the current tag to 1
    }
}

sub stroke {
    my ($me) = @_;

    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->stroke;
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "stroke\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        # XXX (probably nothing)
    }
}

sub closepath {
    my ($me) = @_;

    if ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "closepath\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        # XXX
    }
}

my @state_vars = qw(color x y text_x text_y fontsize fontname);
sub gsave {
    my ($me) = @_;
#print "${indent}gsave at line ".(caller)[2]."\n"; $indent .= '  ';
    my $state = {};
    for (@state_vars) {
        $state->{$_} = $me->{$_};
    }
    push (@{$me->{'states'}}, $state);
    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->save;
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "gsave\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        my %current_style = %{$me->{'groups'}->[0]};
        delete $current_style{'save'};
        delete $current_style{'tag'};
        # If there are pending style changes, make a new group to hold them;
        # otherwise, if they are put with the group doing the gsave() they
        # will be lost after grestore()
        if (%{$me->{'pending_style'}}) {
            my $changed = 0;
            foreach my $attr (keys %{$me->{'pending_style'}}) {
                if ($current_style{$attr} ne $me->{'pending_style'}->{$attr}) {
                    $changed++;
                    $current_style{$attr} = $me->{'pending_style'}->{$attr};
                }
            }
            if ($changed) {
                $me->{'tag'} = $me->{'tag'}->group(
                    'id'     => 'style'.$::cnt++.basename((caller)[1]).'_'.(caller)[2],
                    map { $_ => $current_style{$_} } sort keys %current_style,
                );
                unshift @{$me->{'groups'}}, {
                    'tag'  => $me->{'tag'},
                    'save' => 0,
                    %current_style,
                };
            }
        }
        $me->{'pending_style'} = {};
        $me->{'tag'} = $me->{'tag'}->group(
            'id' => 'gsave'.$::cnt++.basename((caller)[1]).'_'.(caller)[2],
        );
        unshift @{$me->{'groups'}}, {
            'tag'  => $me->{'tag'},
            'save' => 1,
            %current_style,
        };
    }
    push @{$me->{'saves'}}, [ caller() ];
    push @{$me->{'possaves'}}, [ $me->{'mx'}, $me->{'my'} ];
}

sub grestore {
    my ($me) = @_;
#substr($indent, 0, 2) = ''; print "${indent}grestore at line ".(caller)[2]."\n";
    my $state = pop(@{$me->{'states'}});
    for (keys %$state) {
        $me->{$_} = $state->{$_};
    }
    if ($me->{'mode'} eq 'PDF') {
        $me->{'content'}->restore;
    } elsif ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= "grestore\n";
    } elsif ($me->{'mode'} eq 'SVG') {
        # Pop off groups until we find one that was from gsave()
        while($me->{'groups'}->[0]->{'save'} != 1) {
            shift @{$me->{'groups'}};
        }
        shift @{$me->{'groups'}};
        $me->{'tag'} = $me->{'groups'}->[0]->{'tag'};
    }

    # Reset the font, as it looks like PDF doesn't handle this as part of
    # restore, and it doesn't hurt PostScript either...
    $me->set_font($me->{'fontname'}, $me->{'fontsize'}, 1);

    pop @{$me->{'saves'}};
    my $posref = pop @{$me->{'possaves'}};
    $me->{'mx'} = $posref->[0];
    $me->{'my'} = $posref->[1];
}

sub get_saves {
    my ($me) = @_;

    if (@{$me->{'saves'}}) {
        return @{$me->{'saves'}};
    } else {
        return ();
    }
}

sub add_raw {
    my ($me, $filename, $compression, $rawlines) = @_;

    # Add the raw file in.  This must happen before everything is closed out,
    # because when the PDFs are compressed, text after the %%EOF chokes
    # some interpreters.
    my $rawfilestring = "% The following is an encoded version of the raw file that was used to produce\n% this result.  Use the extract_raw script to retrieve it.\n% BEGIN";
    $rawfilestring .= "$compression $filename\n";
    $rawfilestring .= '% '.join("\n% ", split("\n", $rawlines))."\n";
    $rawfilestring .= "% END\n";
    if ($me->{'mode'} eq 'PS') {
        $me->{'output'} .= $rawfilestring;
    } elsif ($me->{'mode'} eq 'PDF') {
        # Fake up an XML container for data that the tools will still be able
        # to decode.
        my $xml = "<rawfile name=\"$filename\">\n";
        $xml .= "<content>\n<![CDATA[\n$rawfilestring\n]]>\n</content>\n</rawfile>\n";
        $me->{'pdf'}->xmpMetadata($xml);
    } elsif ($me->{'mode'} eq 'SVG') {
        # Do nothing; should never be called for SVG
    } else {
        # Do nothing; this shouldn't happen!
    }
}

sub trademarks_done {
    my ($me) = @_;
    return %{$me->{'tm_done'}};
}

# Since PS/PDF strings are more complicated than strings, and because inserting symbols means an explicit font change,
# we use the global ::fixup_trademarks() to insert placeholder symbols, then use those placeholders to split the
# string and insert the structures to do the font change and write the correct symbol.
my %code2intermediate = (
    'r' => "\xFE",
    't' => "\xFD",
    's' => "\xFC",
);
my $intermediate_regexp = eval 'qr/\Q'.join('\E|\Q', values %code2intermediate).'\E/';
my %intermediate2mark = (
    "\xFE" => '\322',
    "\xFD" => '\324',
    "\xFC" => 'SM',
);

sub fixup_trademarks {
    my ($me, $str, $ul, $url, %opts) = @_;
#print "fixup_trademarks($me, str=\"$str\", ul=$ul, url=\"$url\",opts=(\n    ".join(",\n    ", map { "$_ => $opts{$_}" } sort keys %opts)."\n   ))\n";

    $opts{'tmsearch'} = 0;

    my $marked_str = ::fixup_trademarks($str, $me->{'tm_done'}, \%code2intermediate);

    if ($marked_str eq $str) {
        # No need to do extra work if there's nothing to change.
        $me->show($str, $ul, $url, %opts);
        return;
    }

    foreach my $piece (split(/($intermediate_regexp)/, $marked_str)) {
        if (exists($intermediate2mark{$piece})) {
            # It's a mark; show it.
            my $tmstring = $intermediate2mark{$piece};
            my @curfont = $me->get_font();
            my $y = $me->{'text_y'};
            my $delta = $me->string_XHeight() / 3 * 2;
            if ($tmstring =~ /^\\/) {
                $me->set_font('Symbol', $curfont[1]/2);
            } else {
                $me->set_font($curfont[0], $curfont[1]/2);
            }
            $me->set_text_pos($me->{'text_x'}, $y + $delta);
            $me->show($tmstring, $ul, undef, (%opts, 'noescape' => 1, 'doencode' => 1));
            if ($me->{'mode'} eq 'PS') {
                # In PostScript, the stringwidth() sub is just a guess for the
                # Symbol font, and it's wrong. :)  So we'll let the interpreter
                # handle it...
                $me->{'output'} .= "($tmstring) stringwidth $delta neg rmoveto\n";
            } else {
                $me->set_text_pos($me->{'text_x'}, $y);
            }
            $me->set_font(@curfont);
        }
        else {
            # It's just text; show it
            $me->show($piece, $ul, $url, (%opts, 'tmsearch' => 0));
            $me->{'text_x'} += $me->stringwidth($piece) unless $me->{'mode'} eq 'PDF';
        }
    }
}

# Return the widest string and its length based on the current font
sub maxwidths {
    my ($me, $pad, @words) = @_;
    $pad = 0 unless defined($pad);

    my @widths = map { [ $_, $me->stringwidth($_) + $pad ] } grep { defined } @words;
    my $max_width = reduce { $a->[1] > $b->[1] ? $a : $b } ([ '', 0 ], @widths);

    return wantarray ? @$max_width : $max_width->[0];
}

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab colorcolumn=120:
