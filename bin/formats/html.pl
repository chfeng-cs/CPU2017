#
#  html.pl - produces HTML output
#  Copyright 1999-2019 Standard Performance Evaluation Corporation
#
#  Author:  Cloyce D. Spradling
#
# $Id: html.pl 6255 2019-06-11 15:37:45Z CloyceS $

use strict;
use File::Basename;
use File::Path;
use File::Spec;
use IO::File;
use Cwd;
use MIME::Base64;
use URI;
use URI::Escape;
use List::MoreUtils qw(first_index);
use List::Util qw(max);

use PSPDF;
use resultgraph;
require 'util.pl';
require 'flagutils.pl';

our ($name, $extension, $synonyms, $part_of_all, $non_default);
our ($sortdir, @image_data, %seen_anchors);

$name      = 'HTML';
$extension = 'html';
$synonyms  = { map { lc($_) => 1 } ($name, qw(xhtml web www)) };

my $prefix = $Spec::Format::raw::prefix;
$part_of_all = 1;   # Part of '-o all'
my $html_version = '$LastChangedRevision: 6255 $ '; # Make emacs happier
$html_version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'html.pl'} = $html_version;
my $image_url = (defined($::website_formatter) &&
    $::website_formatter) ? $::image_url_path : '';

my $logo_location = "logo037.gif";
my $basebar = "basebar.gif";
my $peakbar = "peakbar.gif";
my @logo_size = (37,55);        # We could use Image::Size,
# but it's not going to change.
my $table_width = 900;          # Table height will be figgerd out later
my $written = [];               # List of files written
$sortdir = 0;                   # Used in number_tick and byspot
my $debug = 0;
my %marked = ();
my %code2mark = (
    'r' => '&reg;',
    't' => '&trade;',
    's' => '<sup>SM</sup>',
);

sub format {
    my ($me, $r, $fn) = @_;
    $written = [];
    %seen_anchors = ();

    return HTML_report($me, $r, $fn);
}

sub HTML_report {
    my ($me, $r, $fn) = @_;
    my @output = ();
    my $tmpstr = '';
    my $invalid = $r->{'invalid'} ||
    ((::ref_type($r->{'errors'}) eq 'ARRAY') && @{$r->{'errors'}}+0 > 0);
    my @nc = ::allof($r->{'nc'});
    my $is_nc = 0;
    if (@nc) {
        if (::istrue($r->{'nc_is_cd'})) {
            $is_nc = 3; # CD
        } elsif (::istrue($r->{'nc_is_na'})) {
            $is_nc = 2; # NA
        } else {
            $is_nc = 1; # NC
        }
    }
    my ($barename, $outputpath);
    my $base_url;
    if (defined($::website_formatter) && $::website_formatter) {
        # Get a non-relative path.
        $fn = ::unrel_path($fn);
        $outputpath = dirname($fn);
        # Strip the base off of the path, leaving the filename and whatever
        # hierarchy it's in.
        ($barename = $fn) =~ s#^\Q$::report_base\E/*##;
        if (defined($::format_for_publication) && $::format_for_publication) {
            # Strip out the _second_ path component so that the URL will come
            # out right.
            my @pathcomp = split(m#/#, $barename);
            splice @pathcomp, 1, 1;
            $barename = ::jp(@pathcomp);
        }
        $barename =~ s/\.\Q${extension}\E$//i;
        $base_url = $::report_url_base.'/'.$barename;
        $barename = basename($fn, '.'.$extension);
    } else {
        if ($fn =~ /^\./) {
            $fn = File::Spec->abs2rel(::unrel_path($fn));
        }
        $base_url = $barename = basename($fn, '.'.${extension});
        $outputpath = dirname($fn).'/';
        $outputpath = '' if ($outputpath =~ /^\.[\/\\]$/o);
    }
    %marked = ();

    push @output, HTML_head($r, $invalid, $is_nc, $outputpath);
    # Start the body
    push @output, '<body>';
    if (::istrue($r->power)) {
        push @output, '<div class="resultpage resultpage_landscape">';
    } else {
        push @output, '<div class="resultpage">';
    }

    # Make the top title bar thing
    push @output, HTML_title($r, $invalid, $is_nc);

    # Make the result bar
    push @output, HTML_result($r, $invalid, $is_nc);

    # Make the info bar that shows the dates
    push @output, HTML_date($r);

    if ($is_nc) {
        # Make the NC/NA explanation section
        push @output, '<div class="ncsection">';
        push @output, break_lines(' <p>', [ map { ::fixup_trademarks($_, \%marked, \%code2mark) } @nc ], '</p>', 0);
        push @output, '</div>', '';
    }

    # Make the graph

    # No dimensions are specified as the default width/height for SVG is
    # "100%", so the graph will be scaled to fit in whatever size box we say
    # the <img> is.
    my $pspdf = PSPDF->new('SVG');
    $pspdf->open();
    $pspdf->begin_page('letter'); # Not really, but this matches PS/PDF
    my $height = ResultGraph::draw($pspdf, 0, 0, undef, undef, $r, $is_nc);
    return undef unless $height;

    # Add the viewbox and fix the initial transform so it's like PDF.
    # THIS IS NASTY AND FRAGILE.  But there's no other way to set attributes on
    # the top-level <svg> element after SVG->new().
    $pspdf->{'svg'}->{'-childs'}->[0]->attr('viewbox' => join(',', (0,0,$pspdf->{'width'},$height)));
    #$pspdf->{'svg'}->{'-childs'}->[0]->attr('viewbox' => join(',', (-$pspdf->{'width'},-$height,$pspdf->{'width'}*2,$height*2))); # XXX
    #$pspdf->{'transform_group'}->attr('transform' => "translate(0,$height) scale(1,-1)");

    # Now get the rendered XML
    $pspdf->close();
    my $svg = $pspdf->output();
    return undef unless defined($svg) and $svg ne '';
    $svg =~ s/[\r\n]/ /g;       # Convert to one line
    $svg =~ tr/ \t/  /s;        # Squash multiple whitespace
    $svg =~ s/([>"])\s+</$1</g; # Get rid of unnecessary whitespace
    push @output, ' <div class="graph">';
    if (!$ENV{'SPEC_SHOW_HTML_GRAPH'}) {
        my $pdf_name = $barename.'.'.$Spec::Format::PDF::extension;
        if (-e ::jp(dirname($fn), $pdf_name)) {
            push @output, qq|  <p style="text-align: center">Benchmark result graphs are available in the <a href="$pdf_name">PDF report</a>.</a>|;
        } else {
            push @output, qq|  <p style="text-align: center">Benchmark result graphs are not currently available.</a>|;
        }
    } else {
        # URL-encode the SVG so that it can be aggregated as a data URL
        push @output, '  <img src="data:image/svg+xml;charset=UTF-8,'.uri_escape_utf8($svg, '^A-Za-z0-9\-\._~ ').'"';
        push @output, '   alt="Benchmark result graph goes here" />';
    }
    push @output, ' </div>';

    if ($::lcsuite ne 'mpi2007') {
        # Make the hardware and software tables
        push @output, HTML_info($r,
                                { 'system' => 'the system under test' },
                                [ 'Hardware', $r->hardware ],
                                ($::lcsuite eq 'accel') ? [ 'Accelerator', $r->accelerator ] : (),
                                [ 'Software', $r->software ],
                                ::make_meter_sections($r, $r->power_info),
        );
    }

    # Do errors
    push @output, HTML_errors($r, $invalid, $is_nc);

    # Make the table of results
    push @output, HTML_table($r, $invalid, $is_nc);

    push @output, HTML_mpi_info($r) if $::lcsuite eq 'mpi2007';

    # Do notes
    push @output, HTML_notes($r->notes, undef, $invalid, $is_nc);

    # Do flags
    push @output, HTML_flags($r, $invalid, $is_nc,
                             $barename.'.flags.html', $base_url.'.flags.html');

    # These lines are collected so that trademarks can be marked, with the trademark listing still appearing above.
    my @datestrings = ();
    if (defined($r->{'accepted_date'}) and $r->{'accepted_date'} > 0) {
        push @datestrings, 'Accepted for publication on '.::timeformat('full-date', $r->{'accepted_date'}).'.';
    }
    if (defined($r->{'published_date'}) and $r->{'published_date'} > 0) {
        push @datestrings, 'Originally published on '.::timeformat('full-date', $r->{'published_date'}).'.';
    }
    my @real_footer;
    foreach my $line (
        '  <p>For questions about this result, please contact the tester.',
        '   For other inquiries, please contact <a href="mailto:info@spec.org">info@spec.org</a><br />',
        '   Copyright '.::copyright_dates().' Standard Performance Evaluation Corporation<br />',
        # Time and date formats are from RFC3339.  See CPU2017 Trac #115
        "   Tested with SPEC $::suite v".$r->{'suitever'}.' on '.$r->datestr().'.<br />',
        '   Report generated on '.::timeformat('date-time', time)." by SPEC $::suite HTML formatter v$html_version.<br />",
        join('  ', @datestrings).'</p>',
    ) {
        push @real_footer, ::fixup_trademarks($line, \%marked, \%code2mark);
    }

    push @output, ' <div class="notes footer">';
    push @output, footer();
    push @output, ' </div>';

    push @output, ' <div class="notes footer">';
    push @output, @real_footer;
    push @output, ' </div>';

    if (!defined($::format_for_publication) || !$::format_for_publication) {
        push @output, ' <div class="w3cbutton3">';
        push @output, '   <a href="http://validator.w3.org/check?uri=referer">';
        push @output, '     <span class="w3c">W3C</span>';
        push @output, '     <span class="spec">XHTML 1.0</span>';
        push @output, '   </a>';
        push @output, ' </div>';
        push @output, ' <div class="w3cbutton3">';
        push @output, '   <a href="http://jigsaw.w3.org/css-validator/check/referer">';
        push @output, '     <span class="w3c">W3C</span>';
        push @output, '     <span class="spec">CSS</span>';
        push @output, '   </a>';
        push @output, ' </div>';
    }
    push @output, '</div>';
    push @output, '</body>';
    push @output, '</html>';

    if ($is_nc == 0) {
        push @output, (
            '<!-- The following is an encoded version of the raw file that was used to',
            '     produce this result. Use the extract_raw script to retrieve it. -->'
        );
        if (defined($r->{'compraw'})) {
            my %whatcomp = ( '*' => 'BASE64', '&' => 'BZIP2', '@' => 'GZIP' );
            my $whatcomp = 'BASE64';
            if ($r->{'compraw'} =~ /^([\@\&\*])/) {
                $whatcomp = $whatcomp{$1};
            }
            push @output, "<!-- BEGIN $whatcomp $barename.rsf", split("\n", $r->{'compraw'});
        } elsif (defined($r->{'rawfile'})) {
            # The uncompressed raw file will be BASE64 encoded so that HTML
            # comments in the raw file (notes, for example) won't screw up the
            # page output.
            my $tmp = '*'.encode_base64($r->{'rawfile'});
            push @output, "<!-- BEGIN BASE64 $barename.rsf", split("\n", $tmp);
        } else {
            push @output,(
                '<!-- BEGIN',
                'There must have been a problem with the encoding.  This is not a raw file.'
            );
        }
        push @output, 'END -->';
    }

    foreach my $line (@output) {
        $line =~ tr/\015\012//d; # More reliable than the double chomp
    }

    return (\@output, $written);
}

sub HTML_table {
    # Make the table of results
    my ($r, $invalid, $nc) = @_;
    my @output = ();
    my ($rate, $what) = (($r->runmode =~ /rate$/) ? 1 : 0, 'copies');
    if ($::lcsuite eq 'mpi2007') {
        ($rate, $what) = (1, 'ranks');
    } elsif ($::lcsuite eq 'omp2012') {
        ($rate, $what) = (1, 'threads');
    } elsif (!$rate && $::lcsuite eq 'cpu2017') {
        ($rate, $what) = (2, 'threads');
    }
    my $nc_str = '';
    if ($nc == 3) {
        $nc_str = 'CD';
    } elsif ($nc == 2) {
        $nc_str = 'NA';
    } elsif ($nc) {
        $nc_str = 'NC';
    }

    my ($by_tune,
        $num_tune_fields, $num_result_fields,
        $tune_cols, $table_cols,
        @fields) = ::get_results_table_field_list($r, $rate, $what);

    push @output,   ' <div class="resultstable">';
    my %results = ();
    my %header = ();
    my @dp = (-10) x $table_cols;
    foreach my $tune (qw(base peak)) {
        my @header = ();
        if ($by_tune) {
            next unless grep { /^${tune}$/ } @{$r->tunelist};
            # Table headers for the per-tune table
            push @header,   '  <h2>'.linkto(ucfirst($tune).' Results Table').'</h2>';
            push @header, qq|  <table summary="Detailed per-benchmark $tune result data">|;
            push @header,   '   <colgroup>';
            push @header,   '    <col id="benchmark" />';
            push @header, qq|    <col id="$tune$what" />| if $rate;
            push @header, qq|    <col id="${tune}res" span="$tune_cols" />|;
            push @header,   '   </colgroup>';

            push @header,   '   <thead>';
            push @header,   '    <tr>';
            push @header,   '     <th>'.linkto('Benchmark').'</th>';
        } elsif ($tune eq 'base') {
            # Table headers for the single table
            push @header,   '  <h2>'.linkto('Results Table').'</h2>';
            push @header,   '  <table summary="Detailed per-benchmark result data">';
            push @header,   '   <colgroup>';
            push @header,   '    <col id="benchmark" />';
            push @header, qq|    <col id="base$what" />| if $rate;
            push @header, qq|    <col id="baseres" span="$tune_cols" />|;
            push @header, qq|    <col id="peak$what" />| if $rate;
            push @header, qq|    <col id="peakres" span="$tune_cols" />|;
            push @header,   '   </colgroup>';

            push @header,   '   <thead>';
            push @header,   '    <tr>';
            push @header,   '     <th rowspan="2">'.linkto('Benchmark').'</th>';
            push @header, qq|     <th class="basecol" colspan="$tune_cols">Base</th>|;
            push @header, qq|     <th class="peakcol" colspan="$tune_cols">Peak</th>|;
            push @header,   '    </tr>';
            push @header,   '    <tr>';
        }
        for(my $i = 0; $i < 3; $i++) {
            # Three sets of results per tune
            foreach my $fieldref (@fields) {
                # Skip non-result fields except at the beginning
                next unless ($fieldref->{'result'} or $i == 0);
                # Skip any whose headers are hard-coded
                next if $fieldref->{'noheader'};
                my $tune_class = "${tune}col ";
                if ($fieldref->{'notune'}) {
                    next unless $tune eq 'base';
                    $tune_class = '';
                }
                my ($name, $label, $edge) = ($fieldref->{'val'}, $fieldref->{'label'}, $fieldref->{'edge'} ? ' '.$fieldref->{'edge'}.'_edge' : '');
                $label =~ s#\n#<br />#g;
                push @header,   qq|     <th class="${tune_class}${name}${edge}">|.linkto($label, 0, '', 1).'</th>';
            }
        }
        if ($by_tune or $tune eq 'peak') {
            push @header,   '    </tr>';
            push @header,   '   </thead>';
            push @header,   '   <tfoot>';

            # Also put the overall means down there
            # First, figure out how many columns the metric name field may
            # span, as well as how many after that the values are.
            my %metric_cols = (
                'base'         => 0,
                'ratio'        => 0,
                'energy_ratio' => 0,
            );
            my %looking_for = %metric_cols;
            for(my $i = 0; $i < @fields; $i++) {
                foreach my $col (grep { $_ ne 'base' } keys %looking_for) {
                    if ($fields[$i]->{'val'} eq $col) {
                        $metric_cols{'base'} = $i if exists($looking_for{'base'});
                        $metric_cols{$col} = $i - $metric_cols{'base'} + 1;
                        delete $looking_for{'base'};
                        delete $looking_for{$col};
                    }
                }
                last unless %looking_for;
            }

            my %means = get_html_means($r, $nc, 1);
            foreach my $meanitem (sort keys %means) {
                next if $by_tune and $meanitem !~ /$tune/;
                next if $means{$meanitem}->{'ispower'} and !::istrue($r->power);
                my $mean  = $means{$meanitem}->{'formatted'};
                my $units = $means{$meanitem}->{'units'};
                my $colname = ($meanitem =~ /energy/) ? 'energy_ratio' : 'ratio';
                my $colspan = $metric_cols{'base'} > 1 ? qq| colspan="$metric_cols{'base'}"| : '';
                push @header,   '    <tr class="table_metrics">';
                push @header, qq|     <td${colspan}>|.linkto($units).qq|</td>|;
                $colspan = $metric_cols{$colname} > 1 ? qq| colspan="$metric_cols{$colname}"| : '';
                push @header, qq|     <td${colspan}>$mean</td>|;
                $colspan = $table_cols - $metric_cols{$colname} - $metric_cols{'base'};
                $colspan = $colspan > 1 ? qq| colspan="$colspan"| : '';
                push @header, qq|     <td${colspan}></td>|;
                push @header,   '    </tr>';
            }
            push @header,   '    <tr>';
            push @header, qq|     <td colspan="$table_cols">Results appear in the <a href="${main::auto_docs_url_base}/result-fields.html#RunOrder">order in which they were run</a>. Bold underlined text <a href="${main::auto_docs_url_base}/result-fields.html#Median">indicates a median measurement</a>.</td>|;
            push @header,   '    </tr>';
            push @header,   '   </tfoot>';
            push @header,   '   <tbody>';
        }
        $header{$tune} = [ @header ];
    }

    my %residx = ();
    my %tune_active = map { $_ => 1 } @{$r->tunelist};
    foreach my $tune (qw(base peak)) {
        next unless !$by_tune or $tune_active{$tune};
        push @output, @{$header{$tune}} if exists($header{$tune});
        %results = () if $by_tune;
        ::marshall_results($r, $tune, \@fields, $nc_str, $by_tune, $tune_active{$tune}, \%results, \%residx, \@dp, $debug);
        if ($by_tune or $tune eq 'peak') {
            # Now just dump out the results
            foreach my $bench (sort keys %results) {
                push @output,   '    <tr>';
                push @output, qq|     <td class="bm">|.linkto($bench, 1).'</td>';
                for(my $i = 0; $i < @{$results{$bench}}; $i++) {
                    my $name         = $results{$bench}->[$i]->{'name'};
                    my $val          = $results{$bench}->[$i]->{'value'};
                    my $selected     = $results{$bench}->[$i]->{'selected'};
                    my $class        = $results{$bench}->[$i]->{'class'};
                    my $dp           = $results{$bench}->[$i]->{'dp'};
                    my $preformatted = $results{$bench}->[$i]->{'preformatted'};
                    my $hack         = $results{$bench}->[$i]->{'sig_hack'};
                    if (!$preformatted and $val ne 'NC' and $val ne 'NA' and $val ne 'CD') {
                        my $pad_class = 'selected' if $selected;
                        $val = pad_rear($val, $dp[$i], $pad_class, $hack) if defined($val) and $val ne '';
                    }
                    $val = qq|<a href="${main::auto_docs_url_base}/result-fields.html#Median">$val</a>| if ($selected and $val =~ /\d/);
                    $class = qq| class="$class"| if defined($class) && $class ne '';
                    push @output, "     <td$class>$val</td>";
                }
                push @output,   '    </tr>';
            }
            push @output, '   </tbody>';
            push @output, '  </table>';
        }
    }
    push @output, ' </div>';

    return @output;
}

sub HTML_info {
    # Make the hardware, software, and other tables
    my ($r, $config, @sections) = @_;
    my $system = $config->{'system'};
    my $summary = $config->{'summary'};
    my @output = ();

    push @output,     ' <div class="infobox">' unless $system eq 'XXstandaloneXX';

    for my $foo (@sections) {
        my ($heading, @refs) = @{$foo};
        if (@refs > 0) {
            push @output, qq|  <table id="|.::makeanchor($heading, \%seen_anchors).'"';
            if (!defined($summary) || $summary eq '') {
                push @output, qq|         summary="Details of |.lc($heading).' configuration for '.::escape_HTML($system).'">';
            } else {
                push @output, qq|         summary="|.::escape_HTML($summary).'">';
            }
            push @output,   '   <thead>';
            push @output, qq|    <tr><th colspan="2">|.linkto($heading, 0, $config->{'anchor_prefix'}).'</th></tr>';
            push @output,   '   </thead>';
            push @output,   '   <tbody>';
            foreach my $ref (@refs) {
                my ($name, @vals) = @$ref;
                push @output, '    <tr>';
                push @output, '     <th>'.linkto($name, 0, $config->{'anchor_prefix'}).':</th>';
                push @output, break_lines('     <td>', \@vals, '</td>', 1);
                push @output, '    </tr>';
            }
            push @output,   '   </tbody>';
            push @output,   '  </table>';
        }
    }
    push @output,     ' </div>' unless $system eq 'XXstandaloneXX';

    return @output;
}

sub HTML_mpi_info {
    my ($r) = @_;
    my @output = ();

    # First make a list of all the sections.  This is pre-done so that
    # anchor names can be uniquified if necessary.
    my @items = ();
    my %anchors = ();
    for my $item (qw(node interconnect)) {
        next unless exists($r->{$item}) && (::ref_type($r->{$item}) eq 'HASH');
        my $iref = $r->{$item};

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
            my $anchor = ::makeanchor($r->{$item}->{$system}->{'label'}, \%seen_anchors);
            if ($anchor eq '') {
                $anchor = ::makeanchor($item.'_'.$system, \%seen_anchors);
            }
            $anchors{$item.$system} = $anchor;
        }
    }


    # Do the benchmark description and the node/interconnect TOC

    # It's desired that the system TOC fit into the "hardware summary".  So
    # fake up the necessary fields and tweak up the list of fields to make
    # it happen.
    my @hw_fields = @{$::mpi_info{'hardware'}};
    # Find the splice position; it's right after "system_class"
    my $i = 1;
    for(; $i <= @hw_fields; $i++) {
        last if $hw_fields[$i-1]->[0] eq 'system_class';
    }

    my %tmp_sections = ();
    foreach my $item (qw(node interconnect)) {
        my @systems = map { $_->[1] } grep { $_->[0] eq $item } @items;
        my @itemnames = ($item);
        foreach my $system (@systems) {
            my $label = $r->{$item}->{$system}->{'label'} || $system;
            my @subsystems = ($item);
            if ($item eq 'node') {
                # Nodes additionally need to be differentiated by purpose
                @subsystems = map { lc($_)."_$item" } split(/(?:\s+(?!server)|,)+/i, $r->{$item}->{$system}->{'purpose'});
            }
            my $desc = '<a href="#'.$anchors{$item.$system}.'">'.::escape_HTML($label).'</a>';
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

            splice @hw_fields, $i, 0, [ "XXXadded_$sec", $title, 1 ];
            $i++;
            for(my $j = 0; $j < @{$tmp_sections{$sec}}; $j++) {
                my $newitem = sprintf "XXXadded_%s%03d", $sec, $j;
                $r->{$newitem} = $tmp_sections{$sec}->[$j];
                push @added, $newitem;
            }
            delete $tmp_sections{$sec};
        }
    }

    push @output, HTML_info($r,
                            { 'summary' => 'Benchmark configuration details for the run' },
                            [ 'Hardware Summary', $r->info_format(\@hw_fields) ],
                            [ 'Software Summary', $r->info_format($::mpi_info{'software'}) ],
                            ::make_meter_sections($r, $r->info_format($::mpi_info{'power'})),
    );

    # Now remove the added fields, so that they don't pollute other results
    foreach my $tmpitem (@added) {
        delete $r->{$tmpitem};
    }

    # Do the system descriptions and notes
    for my $iref (@items) {
        my ($item, $system) = @{$iref};
        my $inforef = $r->{$item}->{$system};

        my ($hw_info, $sw_info) = ::mpi_info_munge($r, $item, $system);

        push @output, qq| <div class="sysdesc" id="$anchors{$item.$system}">|;
        push @output, qq|  <h2>|.ucfirst($item).' Description: '.$inforef->{'label'}.'</h2>';

        push @output, HTML_info($r, {
                                        'system' => $item.': '.$inforef->{'label'},
                                        'summary' => "Configuration details for $item $inforef->{'label'}",
                                        'anchor_prefix' => ucfirst($item),
                                    },
                                    [ 'Hardware', $r->info_format($hw_info) ],
                                    [ 'Software', $r->info_format($sw_info) ]);
        #...

        # Do the notes for this thing...
        push @output, HTML_notes($r->notes("${item}_${system}_"), ucfirst($item));

        push @output, qq| </div>|;
    }

    return @output;
}

sub HTML_notes {
    # Print all the notes
    my ($notesref, $anchor_prefix, $invalid, $is_nc) = @_;
    my @output = ();

    return () unless (::ref_type($notesref) eq 'ARRAY');
    my @notes = @{$notesref};
    foreach my $sectionref (@notes) {
        next unless ref($sectionref) eq 'ARRAY';
        my ($section, $notesref) = @{$sectionref};
        next unless ref($notesref) eq 'ARRAY';

        push @output, ' <div class="notes">';
        push @output, '  <h2>'.linkto($section, 0, $anchor_prefix).'</h2>';
        push @output, '  <pre>';
        push @output, munge_links(map { auto_link($_, 0) } @{$notesref});
        push @output, '</pre>'; # Shouldn't be indented; causes extra line
        push @output, ' </div>';
    }

    return @output;
}

sub HTML_errors {
    # Print all the errors
    my ($r, $invalid, $nc) = @_;
    my @output = ();

    if ((::ref_type($r->{'errors'}) eq 'ARRAY') && @{$r->{'errors'}}) {
        push @output, ' <div class="errors notes">';
        push @output, '  <h2>'.linkto('Errors').'</h2>';
        push @output, '  <pre>';
        push @output, map { auto_link($_, 0) } @{$r->{'errors'}};
        push @output, '  </pre>';
        push @output, ' </div>';
    }

    return @output;
}

sub HTML_flags {
    # Print flag report
    my ($r, $invalid, $nc, $flagfile, $flagurl) = @_;
    my @output = ();

    if (defined($::website_formatter) && $::website_formatter) {
        $flagfile = $flagurl;
    }

    # These will be handy for the flags section
    my $rf = $r->{'reduced_flags'};
    return () unless (::ref_type($rf) eq 'HASH');
    my @benches = sort keys %{$rf->{'benchlist'}};
    my @tunes = sort keys %{$rf->{'tunelist'}};
    my @classes = sort keys %{$rf->{'classlist'}};

    # Do the unknown and forbidden flags.
    foreach my $class (qw(forbidden unknown)) {
        next unless ::check_elem(undef, $rf, 'flaglist', $class);
        # Flags of the class exist for at least one benchmark, so
        # output them.
        my $classref = $rf->{'flaglist'}->{$class};
        for my $tune (sort @tunes) {
            my $printed_title = 0;
            for my $bench (sort keys %{$classref}) {
                next unless ::check_elem('ARRAY', $classref, $bench, $tune);
                my @flags = @{$classref->{$bench}->{$tune}};
                next unless @flags;
                if (!$printed_title) {
                    my $title = ucfirst($tune).' '.ucfirst($class).' Flags';
                    my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($title);
                    push @output, qq| <div class="flags notes" id="$class">|;
                    push @output, qq|  <h2><a href="$url">|.::escape_HTML($title).'</a></h2>';
                    push @output, qq|  <table class="$class">|;
                    $printed_title = 1;
                }
                push @output, '   <tr>';
                push @output, dump_flags($r, {
                                                 'unknown' => $class eq 'unknown',
                                                 'title'   => $bench.':',
                                                 'bench'   => $bench,
                                                 'tune'    => $tune,
                                                 'url'     => $flagfile,
                                             },
                                             @flags);
                push @output, '   </tr>';
            }
            if ($printed_title) {
                push @output, '  </table>';
                push @output, ' </div>';
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

    my %class2title = ( 'compiler'     => 'Compiler Invocation',
                        'portability'  => 'Portability Flags',
                        'optimization' => 'Optimization Flags',
                        'runtime'      => 'Runtime Environment',
                        'other'        => 'Other Flags' );
    my $onetune = $tunes[0];
    foreach my $tune(@tunes) {
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
            my $mismatch = 0;
            my $printed_title = 0;
            my %langstodo = map { $_ => 1 } keys %{$rf->{'langlist'}};
            my %donebench = ();
            my $title = $class2title{$class};

            # Easy case first -- if we're doing new section order and allmatch
            # for this class is set and this isn't the base tuning, just
            # output the "Same as ..." message
            if ($section_order == 0 &&
                exists($rf->{'allmatch'}->{$class}) &&
                $rf->{'allmatch'}->{$class} == 1 &&
                $tune ne $onetune) {
                $title = ucfirst($tune).' '.$title;
                my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($title);
                push @output, qq| <div class="flags notes" id="${tune}_$class">|;
                push @output, qq|  <h2><a href="$url">|.::escape_HTML($title).'</a></h2>';
                push @output,   '  <p>Same as '.ucfirst($onetune).' '.$class2title{$class}.'</p>';
                push @output,   ' </div>';
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
                            if (!$printed_title) {
                                my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($class2title{$class});
                                push @output, qq| <div class="flags notes" id="$class">|;
                                push @output, qq|  <h2><a href="$url">|.::escape_HTML($class2title{$class}).'</a></h2>';
                                $printed_title = 1;
                            }
                            my $langname = $lang;
                            $langname =~ s/ /_/g;
                            my $langtitle = $rf->{'var2desc'}->{$lang};
                            if ($rf->{'langmatch'}->{$class}->{$onetune}->{$lang} == 2) {
                                $langtitle .= ' (except as noted below)';
                            }
                            my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($langtitle);
                            push @output, qq|  <h3><a href="$url">|.::escape_HTML($langtitle).'</a>:</h3>';
                            push @output,   qq|  <table class="$class">|;
                            $printed_lang = 1;
                            push @output, '   <tr>';
                            push @output, dump_flags($r, {
                                    'title' => '',
                                    'bench' => $langname,
                                    'tune'  => 'ALL'.$lang,
                                    'noaddbench' => 1,
                                    'url' => $flagfile,
                                }, @flags);
                            push @output, '   </tr>';
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
                            if (!$printed_title) {
                                my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($class2title{$class});
                                push @output, qq| <div class="flags notes" id="$class">|;
                                push @output, qq|  <h2><a href="$url">|.::escape_HTML($class2title{$class}).'</a></h2>';
                                $printed_title = 1;
                            }
                            if (!$printed_lang) {
                                my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($rf->{'var2desc'}->{$lang});
                                push @output, qq|  <h3><a href="$url">|.::escape_HTML($rf->{'var2desc'}->{$lang}).'</a>:</h3>';
                                push @output,   qq|  <table class="$class">|;
                                $printed_lang = 1;
                            }
                            push @output, '   <tr>';
                            push @output, dump_flags($r, {
                                    'title' => "$bench:",
                                    'bench' => $bench,
                                    'tune'  => 'ALL',
                                    'noaddbench' => 1,
                                    'url' => $flagfile
                                }, @flags);
                            push @output, '   </tr>';
                            if (::check_elem(undef, $rf, 'mismatch', $class, $bench, $onetune)) {
                                $mismatch += $rf->{'mismatch'}->{$class}->{$bench}->{$onetune};
                            }
                            $donebench{$bench}++;
                        }
                    }
                    if ($printed_lang) {
                        push @output, '  </table>';
                    }
                }
            }
            if ($printed_title) {
                # Some non-tune-specific flags are mentioned, so output them.
                if ($mismatch) {
                    if ($class eq 'optimization') {
                        push @output, '  <p>(*) Indicates an optimization flag that was found in a portability variable.</p>';
                    } elsif ($class eq 'portability') {
                        push @output, '  <p>(*) Indicates a portability flag that was found in a non-portability variable.</p>';
                    } elsif ($class eq 'compiler') {
                        push @output, '  <p>(*) Indicates a compiler flag that was found in a non-compiler variable.</p>';
                    }
                }
                push @output, ' </div>';
                $mismatch = 0;
            }

            # Next dump class flags by tuning level, with the common per-language
            # set at the top, followed by benchmark-specific settings
            my $classref = undef;
            $printed_title = 0;
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
                    if (!$printed_title) {
                        my $title = ucfirst($tune).' '.$class2title{$class};
                        my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($title);
                        push @output, qq| <div class="flags notes" id="${tune}_$class">|;
                        push @output, qq|  <h2><a href="$url">|.::escape_HTML($title).'</a></h2>';
                        $printed_title = 1;
                    }
                    my $langname = $lang;
                    $langname =~ s/ /_/g;
                    my $langtitle = $rf->{'var2desc'}->{$lang};
                    if ($rf->{'langmatch'}->{$class}->{$tune}->{$lang} == 2) {
                        $langtitle .= ' (except as noted below)';
                    }
                    if (!$printed_lang) {
                        my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($langtitle);
                        push @output, qq|  <h3><a href="$url">|.::escape_HTML($langtitle).'</a>:</h3>';
                        push @output,   qq|  <table class="$class">|;
                        $printed_lang = 1;
                    }
                    push @output, '   <tr>';
                    push @output, dump_flags($r, {
                            'title' => '',
                            'bench' => '',
                            'tune'  => $langname.$tune,
                            'url' => $flagfile,
                        }, @flags);
                    push @output, '   </tr>';
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
                        }
                        if (!$printed_title) {
                            my $title = ucfirst($tune).' '.$class2title{$class};
                            my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($title);
                            push @output, qq| <div class="flags notes" id="${tune}_$class">|;
                            push @output, qq|  <h2><a href="$url">|.::escape_HTML($title).'</a></h2>';
                            $printed_title = 1;
                        }
                        if (!$printed_lang) {
                            my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($rf->{'var2desc'}->{$lang});
                            push @output, qq|  <h3><a href="$url">|.::escape_HTML($rf->{'var2desc'}->{$lang}).'</a>:</h3>';
                            push @output,   qq|  <table class="$class">|;
                            $printed_lang = 1;
                        }
                        push @output, '   <tr>';
                        push @output, dump_flags($r, {
                                'title' => $bench.':',
                                'bench' => $bench,
                                'tune'  => $tune,
                                'addvar' => 1,
                                'url' => $flagfile
                            }, @flags);
                        push @output, '   </tr>';
                        if (::check_elem(undef, $rf, 'mismatch', $class, $bench, $tune)) {
                            $mismatch += $rf->{'mismatch'}->{$class}->{$bench}->{$tune};
                        }
                    }
                }
                if ($printed_lang) {
                    push @output, '  </table>';
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
                    my $title = shift(@titles);
                    $printed_title = 0;
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
                            }
                            if (!$printed_title) {
                                my $url = $::auto_docs_url_base.'/result-fields.html#'.::makeanchor($title);
                                push @output, qq| <div class="flags notes" id="${port_tune}_$class">|;
                                push @output, qq|  <h2><a href="$url">|.::escape_HTML($title).'</a></h2>';
                                push @output,   qq|  <table class="$class">|;
                                $printed_title = 1;
                            }
                            push @output, '   <tr>';
                            push @output, dump_flags($r, {
                                    'title' => $bench.':',
                                    'bench' => $bench,
                                    'tune'  => $port_tune,
                                    'addvar' => 1,
                                    'url' => $flagfile
                                }, @flags);
                            push @output, '   </tr>';
                            if (::check_elem(undef, $rf, 'mismatch', $class, $bench, $port_tune)) {
                                $mismatch += $rf->{'mismatch'}->{$class}->{$bench}->{$port_tune};
                            }
                        }
                    }
                    if ($printed_title) {
                        push @output, '  </table>';
                        if ($mismatch) {
                            push @output, '  <p>(*) Indicates a portability flag that was found in a non-portability variable.</p>';
                            $mismatch = 0;
                        }
                        push @output, ' </div>';
                    }
                }
            } else {
                # Portability flags are taken care of above...

                if ($printed_title) {
                    if ($mismatch) {
                        if ($class eq 'optimization') {
                            push @output, '  <p>(*) Indicates an optimization flag that was found in a portability variable.</p>';
                        } elsif ($class eq 'portability') {
                            push @output, '  <p>(*) Indicates a portability flag that was found in a non-portability variable.</p>';
                        } elsif ($class eq 'compiler') {
                            push @output, '  <p>(*) Indicates a compiler flag that was found in a non-compiler variable.</p>';
                        }
                    }
                    push @output, ' </div>';
                    $mismatch = 0;
                }
            }
        }
    }

    if (defined($::website_formatter) && $::website_formatter &&
        defined($r->{'flagsurl'}) && $r->{'flagsurl'} ne '') {
        my $urls = $r->{'flagsurl'};
        if (::ref_type($urls) ne 'ARRAY') {
            # Shouldn't happen, but just in case
            $urls = [ $urls ];
        }
        my $count = @{$urls};
        my $plural = ($count > 1) ? 's' : '';
        my (@html_output, @xml_output);
        foreach my $url (@{$urls}) {
            my $html_url = $url;
            $html_url =~ s/\.xml$/\.html/;
            my $br = ($count < @{$urls}) ? '<br />' : '';
            my $punct = ($count == 1) ? '.' : ',';
            push @html_output, qq|   $br<a href="$html_url">|.::escape_HTML($html_url)."</a>$punct";
            push @xml_output,  qq|   $br<a href="$url">|.::escape_HTML($url)."</a>$punct";
            $count--;
        }

        push @output, ' <div class="notes flagfooter">';
        push @output, '  <hr />';
        my $flag_link = ($::lcsuite =~ /^(cpu|mpi2007|omp)/) ? 'faq.html#flagsfile' : 'flag-description.html';
        if (@{$urls} > 1) {
            push @output, qq|  <p>The <a href="${main::auto_docs_url_base}/$flag_link">flags files</a> that were used to format this result can be browsed at<br />|;
        } else {
            push @output, qq|  <p>The <a href="${main::auto_docs_url_base}/$flag_link">flags file</a> that was used to format this result can be browsed at<br />|;
        }
        push @output, @html_output,
        qq|  </p>|;
        push @output, qq|  <p style="font-size: 75%">You can also download the XML flags source${plural} by saving the following link${plural}:<br />|;
        push @output, @xml_output,
        qq|  </p>|;
        push @output, ' </div>';
    }

    return @output;
}

sub dump_flags {
    my ($r, $opts, @flags) = @_;
    my $title = $opts->{'title'};
    my $link_title = $opts->{'link_title'};
    my @output = ();

    if ($opts->{'title_alone'}) {
        my $url = '';
        if ($link_title) {
            $url = qq|<a href="${main::auto_docs_url_base}/result-fields.html#|.::makeanchor($title).'>';
        }
        push @output, qq|   <tr><th colspan="2">$url|.::escape_HTML($title).($url ne '' ? '</a>' : '').'</th></tr>';
        $title = '';
        $link_title = 0;
    }

    if ($opts->{'unknown'}) {
        push @output, '   <td>'.::escape_HTML($title).'</td>';
        push @output, '   <td class="al">';
        foreach my $flagref (@flags) {
            push @output, '    "<span class="tt">'.::escape_HTML($flagref->[1]).'</span>" (in <span class="tt">'.::escape_HTML(join(', ', @{$flagref->[0]})).'</span>)';
        }
        push @output, '   </td>';
    } else {
        push @output, '   <td>'.::escape_HTML($title).'</td>';
        push @output, '   <td class="al">';
        foreach my $flag (@flags) {
            my ($doul, $string, $url, $markup);
            if (::ref_type($flag->[2]) eq 'HASH') {
                # It's a real flag
                $doul = $flag->[2]->{'origin'}->[1] eq 'user' ? 'userflag' : 'flagtext';
                my $from = $opts->{'tune'};
                if ($opts->{'addvar'}) {
                    $from .= join('', @{$flag->[0]});
                }
                if (!$opts->{'noaddbench'}) {
                    $from .= $opts->{'bench'} if $flag->[2]->{'origin'}->[1] =~ /^(suite|user)$/;
                }
                if (::ref_type($flag->[1]) eq 'ARRAY') {
                    ($string, $markup) = @{$flag->[1]};
                } else {
                    $string = $flag->[1];
                    $markup = '';
                }
                $url = $opts->{'url'}.'#'.::make_flag_id($flag->[2], $from, $string, 1);
                if (exists $flag->[2]->{'nomap'}) {
                    # This is a pseudo-flag added by the tools, so just
                    # display the name.  (This should never happen here.)
                    $url = '';
                    $doul = 'flagtext';
                }
                if ($url ne '') {
                    # Link up the flag text (only)
                    $string = qq|<span class="$doul"><a href="$url">|.::escape_HTML($string).'</a></span>'.::escape_HTML($markup);
                } else {
                    $string = qq|<span class="$doul">|.::escape_HTML($string).'</span>'.::escape_HTML($markup);
                }
                push @output, "    &nbsp;$string&nbsp;";
            } else {
                print "XXX Not a 'real' flag.  What do I do?\n";
            }
        }
        push @output, '   </td>';
    }

    return @output;
}

sub HTML_head {
    my ($r, $invalid, $nc, $path) = @_;
    my @output = ();

    my %html_style;
    my @common_style;
    if (!defined $::website_formatter || !$::website_formatter) {
        @common_style = map { tr/\012\015//d; $_ } ::read_file(::jp($ENV{'SPEC'}, 'Docs', 'css', "${main::lcsuite}result.css"));
    } else {
        @common_style = ( '  @import url(//www.spec.org/includes/css/'.${main::lcsuite}.'result.css);' );
    }
    foreach my $media (qw(screen print)) {
        @{$html_style{$media}} = ('<style type="text/css" id="internal'.ucfirst($media)."\" media=\"$media\">", '<!--', @common_style);
        my $done = 0;
        if (!defined $::website_formatter || !$::website_formatter) {
            # Try to read it in from a file
            my $path = ::jp($ENV{'SPEC'}, 'Docs', 'css', "${main::lcsuite}${media}.css");
            my @tmp_style = map { tr/\012\015//d; $_ } ::read_file($path);
            if (@tmp_style) {
                push @{$html_style{$media}}, @tmp_style;
                $done = 1;
            }
        }
        if (!$done) {
            push @{$html_style{$media}}, '  @import url(//www.spec.org/includes/css/'.${main::lcsuite}.${media}.'.css);';
        }
        push @{$html_style{$media}}, '-->', '</style>';
    }

    # It's too bad that Internet Explorer sucks SO hard... we could almost
    # enter the late '90s!
    if (0) {
        push @output, '<?xml version="1.0" encoding="utf-8"?>';
        push @output, '<?xml-stylesheet href="http://www.w3.org/StyleSheets/TR/W3C-REC.css" type="text/css"?>';
        push @output, '<?xml-stylesheet href="#internalScreen" type="text/css" media="screen"?>';
        push @output, '<?xml-stylesheet href="#internalPrint" type="text/css" media="print"?>';
    }
    push @output,   '<!DOCTYPE html',
                    '      PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"',
                    '      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">';
    push @output,   '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">';
    push @output,   '<head>';
    push @output, qq|<meta name="generator" content="SPEC ${main::suite} Tools $::version (HTML v$html_version)" />|;
    # Ensure that IE8 renders us in standards mode
    push @output, qq|<meta http-equiv="X-UA-Compatible" content="IE=8;FF=2" />|;
    push @output, qq|<meta http-equiv="Content-type" content="text/html;charset=utf-8" />|;
    my %things = ::get_tester_info($r);
    foreach my $thing (keys %things) {
        $things{$thing} = ::escape_HTML(join(' ', @{$things{$thing}}));
    }

    my @keywords = ($things{'hw_vendor'}, $things{'hw_model'});
    push @keywords, $things{'test_sponsor'} if ($things{'test_sponsor'} ne $things{'hw_vendor'});
    if ($things{'test_sponsor'} ne $things{'tester'}) {
        push @output, qq|<meta name="author" content="$things{'tester'} (test sponsored by $things{'test_sponsor'})" />|;
        push @keywords, $things{'tester'} if ($things{'tester'} ne $things{'hw_vendor'});
    } else {
        push @output, qq|<meta name="author" content="$things{'tester'}" />|;
    }
    my $what = '';
    if ($nc == 2) {
        $what = 'Non-available ';
    } elsif ($nc == 1) {
        $what = 'Non-compliant ';
    } elsif ($invalid) {
        $what = 'Invalid ';
    }
    my %means = get_html_means($r, $nc, 0);
    my @desc = ();
    foreach my $tune (sort keys %means) {
        if (::istrue($r->power) or !$means{$tune}->{'ispower'}) {
            push @desc, $means{$tune}->{'units'}.': '.$means{$tune}->{'formatted'};
            if ($means{$tune}->{'formatted'} ne 'Not Run') {
                push @keywords, ucfirst($tune).'='.$means{$tune}->{'formatted'};
            }
        }
    }

    push @output, qq|<meta name="description" content="${what}$r->{'metric'} result for $things{'hw_model'}; |.join('; ', @desc).qq|" />|;
    push @output, qq|<meta name="keywords" content="${what}$r->{'metric'} SPEC www.spec.org |.join(' ', @keywords).'" />';

    push @output, @{$html_style{'screen'}};
    push @output, @{$html_style{'print'}};
    if ($invalid || $nc) {
        push @output, '<style type="text/css">', '<!--';
        if ($nc == 3) {
            push @output, "body { background-image: url(${main::spec_image_base}cd.jpg) }";
        } elsif ($nc == 2) {
            push @output, "body { background-image: url(${main::spec_image_base}na.jpg) }";
        } elsif ($nc) {
            push @output, "body { background-image: url(${main::spec_image_base}nc.jpg) }";
        } elsif ($invalid) {
            my $fname = ::jp($path, 'invalid.gif');
            if ($image_url eq '' && ( !-f $fname || -s _ < 5000 ) ) {
                # Write out the image that is about to be referenced
                my $invalid_file = write_invalid_image($fname);
                if (!defined($invalid_file)) {
                    # An error writing our own, eh?  Never fear, SPEC is here.
                    push @output, "body { background-image: url(${main::spec_image_base}invalid.gif) }";
                } else {
                    push @{$written}, $invalid_file;
                    push @output, "body { background-image: url(invalid.gif) }";
                }
            } else {
                push @output, "body { background-image: url(${image_url}invalid.gif) }";
            }
        }
        push @output, '-->', '</style>';
    }

    my $title = $things{'hw_vendor'}.' '.$things{'hw_model'};
    if ($things{'test_sponsor'} ne $things{'hw_vendor'}) {
        $title .= ' (test sponsored by '.$things{'test_sponsor'};
        if ($things{'tester'} ne $things{'test_sponsor'}) {
            $title .= '; tested by '.$things{'tester'};
        }
        $title .= ')';
    }

    push @output, '',
                  "<title>${what}".::munge_metric($r->{'metric'}, $r->{'runmode'})." Result: $title</title>";
    push @output, '</head>', '';

    return @output;
}

sub HTML_title {
    my ($r, $invalid) = @_;
    my @output = ();
    my $tmpstr = '';

    # Make the top title bar thing
    push @output, ' <div class="titlebarcontainer">';
    push @output, '  <div class="logo">';
    if (!$invalid # Invalid results should never get the SPEC Seal of Reviewal
        and defined($::website_formatter) and $::website_formatter
        and defined($::format_for_publication) and $::format_for_publication) {
        # This must be a real result.  Put the cute little picture in
        push @output, qq|   <a href="/" style="border: none"><img src="${image_url}${logo_location}" alt="SPEC Seal of Reviewal" /></a>|;
    }
    push @output, '  </div>';
    push @output, '  <div class="titlebar">';
    $tmpstr = '   <h1>';
    if ($invalid) {
        $tmpstr .= '<span style="color: red">Invalid</span> ';
    }
    $tmpstr .= ::fixup_trademarks('SPEC '.::munge_metric($r->{'metric'}, $r->{'runmode'}).' Result', \%marked, \%code2mark);
    $tmpstr .= '</h1>';
    push @output, $tmpstr;
    push @output, '   <p style="font-size: smaller">Copyright '.::copyright_dates().' Standard Performance Evaluation Corporation</p>';
    push @output, '  </div>';
    push @output, ' </div>';

    return @output;
}


sub HTML_result {
    my ($r, $invalid, $nc) = @_;
    my @output = ();

    # Make the result bar
    push @output, ' <table class="titlebarcontainer">';
    push @output, '  <tr>';

    my %things = ::get_tester_info($r);
    my %means = get_html_means($r, $nc, 1);

    push @output, '   <td class="systembar" rowspan="2">';
    if (join(' ', @{$things{'test_sponsor'}}) ne join(' ', @{$things{'hw_vendor'}})) {
        push @output, break_lines('    <p>', $things{'hw_vendor'}, '', 0);
        $things{'test_sponsor'}->[0] = '(Test Sponsor: '.$things{'test_sponsor'}->[0];
        $things{'test_sponsor'}->[$#{$things{'test_sponsor'}}] .= ')';
        push @output, break_lines('     <span style="font-size: 75%">', $things{'test_sponsor'}, '</span>', 0);
        push @output, '    </p>';
    } else {
        push @output, break_lines('    <p>', $things{'hw_vendor'}, '    </p>', 0);
    }
    if ($::lcsuite eq 'accel') {
        push @output, break_lines('    <p>', $things{'hw_accel_name'}, '    </p>', 0);
    }
    push @output, break_lines('    <p>', $things{'hw_model'}, '    </p>', 0);
    push @output, '   </td>';

    for my $tune (qw(base peak)) {
        push @output, qq|   <td class="metricbar $tune">|;
        my @items = ($tune);
        push @items, $tune.'energy' if ::istrue($r->power);
        foreach my $mref (@items) {
            my @metric_lines = (
                '    <p><span class="item">'.linkto($means{$mref}->{'units'}).' = </span>',
                qq|       <span class="value">$means{$mref}->{'formatted'}</span></p>|,
            );
            if (!$means{$mref}->{'ispower'}
                    or (::istrue($r->power) and $r->power_is_official())) {
                push @output, @metric_lines;
            } else {
                push @output, '<!--', @metric_lines, '-->';
            }
        }
        push @output, '   </td>';
        push @output, '  </tr>';
        push @output, '  <tr>' if $tune eq 'base'; # base's opening <tr> supplied by systembar
    }

    push @output, ' </table>';

    return @output;
}


sub HTML_date {
    my ($r) = @_;
    my @output = ();
    my @tester;

    # Gather up the things that we'll be printing
    my %things = ::get_result_fields_hash($r, qw( license_num test_sponsor test_date hw_avail sw_avail tester ));

    push @output, ' <table class="datebar">';
    push @output, '  <tbody>';
    for my $lineref (
        [
            [ $::suite.' License:'     , 'license_num'  ],
            [ 'Test Date:'             , 'test_date'    ],
        ],
        [
            [ 'Test Sponsor:'          , 'test_sponsor' ],
            [ 'Hardware Availability:' , 'hw_avail'     ],
        ],
        [
            [ 'Tested by:'             , 'tester'       ],
            [ 'Software Availability:' , 'sw_avail'     ],
        ],
    ) {
        push @output, '   <tr>';
        for my $info (@{$lineref}) {
            my ($name, $key) = @$info;
            push @output, qq|    <th id="$key">|.linkto($name).'</th>';
            push @output, qq|    <td id="${key}_val">|.join("<br />\n", map { auto_link($_, 0) } @{$things{$key}}).'</td>';
        }
        push @output, '   </tr>';
    }
    push @output, '  </tbody>';
    push @output, ' </table>';

    return @output;
}

sub significant { ::significant_base(@_, ($debug & 4)); }

sub pad_rear {
    my ($val, $dp, $class, $hack) = @_;
    $val = ($val >= 0) ? significant($val, undef, undef, $hack) : $val;
    my $my_dp = significant(abs($val), undef, 2, $hack);
    if (defined($class) && $class ne '') {
        $val = qq|<span class="$class">$val</span>|;
    }
    return $val unless defined($dp);
    my $s = '0' x ($dp - $my_dp);
    $s = '<span style="visibility:hidden">'.$s.'</span>' if $s ne '';
    return $val.$s;
}

sub linkto {
    my ($name, $isbench, $section, $noescape) = @_;
    if ($isbench) {
        $name = ::escape_HTML($name) unless $noescape;
        my $fixed_name = ::fixup_trademarks($name, \%marked, \%code2mark);
        return qq|<a href="${main::bench_url_base}/${name}.html">${fixed_name}</a>|;
    } else {
        my $ws = '';
        # Save leading whitespace
        if ($name =~ s/^(\s+)//) {
            ($ws = $1) =~ s/\s/\&nbsp;/g;
        }
        my $anchor = ::makeanchor($section.$name);
        $anchor =~ s/(\S)continued$/$1/i; # Always goes to the same place anyway
        $name = ::escape_HTML($name) unless $noescape;
        my $fixed_name = ::fixup_trademarks($name, \%marked, \%code2mark);

        return qq|$ws<a href="${main::auto_docs_url_base}/result-fields.html#$anchor">${fixed_name}</a>|;
    }
}

# From ps.pl
sub label_ok {
    my ($xpos, $size, $spots) = @_;

    # Check to see if xpos occupies a position within +/- size of any position
    # in spots
    foreach my $spot (@{$spots}) {
        if (ref($spot) eq 'ARRAY') {
            next if $xpos > ($spot->[1] + $size / 2);
            next if $xpos < ($spot->[0] - $size / 2);
        } else {
            next if $xpos > ($spot + $size / 2);
            next if $xpos < ($spot - $size / 2);
        }
        return 0;
    }
    return 1;
}

sub write_invalid_image {
    my ($fn) = @_;

    my $ofh = new IO::File '>'.$fn;
    return undef unless defined($ofh);
    my $image_data = decode_base64(join('', @image_data));
    binmode $$ofh, ':raw';
    $ofh->print($image_data);
    $ofh->close();
    return $fn;
}

sub auto_link {
    # Look for URLs in strings, and make them links.  Escape everything.
    my ($str, $basename) = @_;
    my $out = '';

    # Skip everything if the text already contains a link
    return $str if $str =~ /<a href/;

    # Only auto-link HTTP, HTTPS, FTP, and mailto URLs
    while ($str =~ s/^(.*?)((?:https?|ftp|mailto):[^[:space:]<>()]+)//i) {
        my ($pre, $url) = ($1, $2);
        if ($pre =~ /(?:ATTACH|LINK )$/) {
            $out .= $pre.$url;    # munge_links will handle this one
            next;
        }
        my $uri = URI->new($url);
        $out .= ::escape_HTML($pre);
        $out .= qq|<a href="|.$uri->canonical->as_string.qq|">|;
        if ($basename) {
            my $fn = '';
            eval { $fn = (reverse $uri->path_segments)[0] };
            if ($@ ne '' || $fn eq '') {
                # This returns an escaped string
                $fn = $uri->as_string;
            } else {
                # The path segment is unescaped, so escape it
                $fn = ::escape_HTML($fn);
            }
            $fn =~ s/^mailto://;     # It's special
            $out .= $fn;
        } else {
            $url =~ s/^mailto://;     # It's special
            $out .= ::escape_HTML($url);
        }
        $out .= '</a>';
    }
    $out .= ::escape_HTML($str);

    return $out;
}

sub break_lines {
    my ($pre, $lines, $post, $basename) = @_;
    my @output = ();
    if (@{$lines} > 1) {
        push @output, $pre.auto_link(shift(@{$lines}), $basename).'<br />';
        push @output, map { auto_link($_, $basename).'<br />' } @{$lines};
        $output[$#output] .= $post;
        return @output;
    } else {
        return ($pre.auto_link($lines->[0], $basename).$post);
    }
}

sub munge_links {
    my (@lines) = @_;
    my @newlines = ();

    # These lines should've already been seen by auto_link, so all of the text
    # parts should already be escaped.
    foreach my $line (@lines) {
        my $count = 0;
        my $temp = $line;
        while ($count < 40 &&
            $line =~ m#((ATTACH|LINK)\s+(\S+)\s+AS\s+(?:\[([^]]+)\]|(\S+)))#g) {
            my ($section, $what, $url, $text) = ($1, $2, $3, $4.$5);
            $count++;

            if ($what eq 'LINK') {
                # Make sure the URL has a scheme.  No direct file linking
                # allowed here!  (Results files move around.)
                if ($url !~ /^[a-zA-Z]+:/) {
                    ::Log(0, "\nERROR: Relative links and bare file paths may not be used as the URL part\n");
                    ::Log(0, "     of a notes LINK statement.\n");
                    next;
                }
                my $uri = new URI($url);
                $url = $uri->canonical->as_string;
            }

            # Do the replacement
            $temp =~ s#\Q$section\E#<a href="$url">$text</a>#g;
        }
        push @newlines, $temp;
    }
    return @newlines;
}

sub get_html_means {
    my ($r, $nc, $do_pad) = @_;

    my ($meandp, %means) = ::get_means($r, $nc);

    if ($do_pad) {
        foreach my $mean (grep { $means{$_}->{'mean'} =~ /\d/ } keys %means) {
            $means{$mean}->{'formatted'} = pad_rear($means{$mean}->{'mean'}, $meandp, undef, 0);
        }
    }

    return %means;
}

sub footer {
    return ('<p>', ::trademark_lines('  ', undef, %marked), '</p>');
}


BEGIN {
    # Prepare for FUN!
    @image_data = qw(
    R0lGODlhSgH3AOepAPAAAPIAAPIACPMACfQACu4QBu8TB+8TEvEWFPAXHPIZFfIZHfMbHvMcJfQe
    H/QeJfUgJvApJfIqJvEqLPMsLfQuLvQuNPUvNfYxNvE3NfM4NvI4O/Q6NvM6PPU7PfY8PvJCPvNE
    RPRFRfZGRvdHR/ZITfNNTfROTvVPTvZQT/dSVvNWVvVXV/ZYWPdZWfZZXvhbX/NdXvRfX/VgYPZh
    YfdiYvljY/RnaPVoafZpavhqa/lrbPRta/VubPZwbfZxc/hydPV2dfZ3dvd4d/l5ePp6efl7f/V+
    f/Z/gPeAgfiBgvmCg/aGg/iHhPmIhfiIi/qJhvmJjPqKjfaNjfeOjviPj/mQkPuRkfeVkvmWk/qX
    lPiXmvmYm/uZnPacnPednfmenvqfn/ugoPyhofijofmkovqlo/umpPmnqvuoq/yprPerrPisrfmt
    rvuur/yvsPizsfm0svu1s/y2tP23tf64tve6vPi8vfq9vvu+v/y/wP3AwfnDwvrEw/zFxf3Gxv7H
    x/rLyPvMyfzNyv3Oy/vO0fzP0v3Q0/nT1PrU1fzW1v3X1/7Y2frb2vvc2/zd3P3e3f7f3v/g3/vj
    4P/i4Pzl4f3m4vzn6v3o6/7p7P/q7fvt7vzu7/3w8P7x8f/y8v/z9Pz29f339v749//5+P/6+f/8
    +vz/+/7//P//////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////yH5BAEKAP8ALAAAAABKAfcA
    AAj+AFEJHEiwoMGDCBMqXMiwocOHECNKnEixosWLGDNq3Mixo8ePIEOKHEmypMmTKFOqXMmypcuX
    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
    xVZ0xVecrIAAADs=
    );
}

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab colorcolumn=120:
