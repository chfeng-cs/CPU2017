#
#  resultgraph.pl - Common code for vector-based results graph (using the PSPDF API)
#  Copyright 2017-2019 Standard Performance Evaluation Corporation
#
#  Authors:  Cloyce D. Spradling
#
# $Id: resultgraph.pm 6255 2019-06-11 15:37:45Z CloyceS $

package ResultGraph;

use strict;
use PSPDF;
use List::Util qw(min max sum);
use List::MoreUtils qw(uniq);

my $debug = 0;

my $inch = $PSPDF::inch;
my $fixed_font = $PSPDF::fixed_font;
my $prop_font = $PSPDF::prop_font;
my $prop_bold_font = $PSPDF::prop_bold_font;
my %tunecolor = %PSPDF::tunecolor;
my $sortdir = 0;                   # Used in number_tick and byspot

my %styles = (
    'base'       => { 'color' => 0,                    'dash' => 0 },
    'baseenergy' => { 'color' => [ 0,    0.41, 0 ],    'dash' => [ 1, 2 ] },
    'peak'       => { 'color' => $tunecolor{'peak'},   'dash' => 1.5 },
    'peakenergy' => { 'color' => [ 0.41, 0,    0.41 ], 'dash' => [ 2, 1 ] },
);
# Arrays of spacing information indexed by number of tuning levels being
# plotted per benchmark, and number of metrics being plotted per tuning level.
# Populated by the calculate_bar_spacing() called from draw() after bar
# height is set.
my @bar_spacing;

sub _get_min_max {
    my ($r, $min, $max) = @_;

    my %fields = (
        'ratio'        => sub { return shift->accessor_nowarn('ratio') },
        'time'         => sub { return shift->accessor_nowarn('reported_time') },
        'avg_power'    => sub { return shift->accessor_nowarn('avg_power') },
        'energy_ratio' => sub { return shift->accessor_nowarn('energy_ratio') },
        'copies'       => sub { return shift->accessor_nowarn('copies') },
        'threads'      => sub { return shift->accessor_nowarn('threads') },
        'ranks'        => sub { return shift->accessor_nowarn('ranks') },
    );

    %$min = (map { $_ => { 'base' => undef, 'peak' => undef, 'any' => undef } } keys %fields);
    %$max = (map { $_ => { 'base' => undef, 'peak' => undef, 'any' => undef } } keys %fields);

    # Fill in mins and maxes for ALL results.  The mean will always be <= max
    # result, so no need to worry about that here.
    foreach my $res ($r->results_list) {
        my $tune = $res->tune;
        my $tmp;

        foreach my $field (keys %fields) {
            my $val = &{$fields{$field}}($res);
            next unless defined($val);
            if ($val =~ /\d/) {
                $min->{$field}->{$tune} = $val if !defined($min->{$field}->{$tune}) or $min->{$field}->{$tune} > $val;
                $min->{$field}->{'any'} = $val if !defined($min->{$field}->{'any'}) or $min->{$field}->{'any'} > $val;
                $max->{$field}->{$tune} = $val if !defined($max->{$field}->{$tune}) or $max->{$field}->{$tune} < $val;
                $max->{$field}->{'any'} = $val if !defined($max->{$field}->{'any'}) or $max->{$field}->{'any'} < $val;
            }
        }
    }
}

sub draw {
    my ($p, $x, $y, $width, $height, $r, $is_nc) = @_;

    # Assume the whole page unless told otherwise
    $width  = $p->{'width'} unless defined($width);
    $height = $p->{'height'} unless defined($height);
    #print "draw(p=$p, x=$x, y=$y, width=$width, height=$height, r=$r, is_nc=$is_nc)\n";

    my %max;
    my %min;
    (undef, my %means) = ::get_means($r, $is_nc);

    _get_min_max($r, \%min, \%max); # Get extreme values

    # Map of what we want to the key in the result data that provides the
    # information.
    my %what_key = (
        'time'         => 'reported_sec',
        'ratio'        => 'ratio',
        'energy_ratio' => 'energy_ratio',
        'power'        => 'avg_power',
    );

    my @titles;
    my @what = ('ratio');       # What's on the graph?
    my $power = ::istrue($r->power) ? 1 : 0;
    push @what, 'energy_ratio' if $power;

    # Figure out how many things will be appearing in a given benchmark's
    # graph bar: 1 (base or peak or basepeak perf), 2 (base or basepeak power
    # perf; base and peak perf), or 4 (everything)
    my $metrics = @{$r->tunelist} * ($power + 1);
    my %results = %{$r->results};
    my %tmp_bp;
    foreach my $bench (sort keys %{$r->results}) {
        (undef, my $basepeak) = ::get_basepeak_parallel_info($results{$bench}, $r,
                                                              [ map { $what_key{$_} } @what ]);
        $tmp_bp{$basepeak}++;
    }
    if (@{$r->tunelist} > 1 and ($tmp_bp{'1'}+$tmp_bp{'2'}) == keys %{$r->results}) {
        # All the results are basepeak, and both tunes are present, so the
        # number of metrics is halved
        $metrics /= 2;
    }

    my $bar_height = $inch;
    if ($metrics == 1) {
        $bar_height *= 0.13; # Don't need much space for one item
    } elsif ($metrics == 2) {
        $bar_height *= 0.18;
    } else {
        # Worst case
        $bar_height *= 0.23;
    }
    my $bar_pad = $bar_height * 0.2;
    my $border = $inch / 32;
    my $label_height = $bar_height * 2;  # Enough for two bars
    my $label_width  = 0;       # Figured later (space for benchmark name)
    my $graph_x     = $x + $label_width;
    my $graph_y     = 0;
    my $graph_width = $width - $graph_x - $border;
    my $scale_height      = $inch * 0.15;
    my $scale_tick_height = $scale_height * 0.3;
    my $scale_tick_pad    = $scale_tick_height / 4;

    calculate_bar_spacing($p, $bar_height);

    my %benchmarks = map { $_ => {} } keys %{$r->benchmarks};
    my $num_benchmarks = keys %benchmarks;
    return 0 unless $num_benchmarks;
                      # Scale          Benchmarks                            Legend
    my $graph_height = $scale_height + ($bar_height * 2 * $num_benchmarks) + $bar_height;
    $height = $graph_height unless defined($height);

    my ($rate, $parallel) = (0, '');
    if ($::lcsuite eq 'mpi2007') {
        ($rate, $parallel) = (1, 'ranks');
    } elsif ($::lcsuite eq 'omp2012') {
        ($rate, $parallel) = (1, 'threads');
    } elsif ($::lcsuite eq 'cpu2017') {
        ($rate, $parallel) = ($r->runmode =~ /rate$/) ? (1, 'copies') : (2, 'threads');
    }

    # Include all of the means in all of the results because they'll be
    # on the graph no matter what.
    %results = (
        map { $_ => {
                     map { $_ => [ 'overall', 0, $means{$_}->{'formatted'} ] } keys %means
                    }
            } keys %what_key
    );

    # TODO: Figure out what, if anything, this is used for
    foreach my $res ($r->results_list) {
        my ($name, $tune, $iter) = ($res->benchmark, $res->tune, $res->iteration);
        foreach my $what (keys %what_key) {
            $results{$what}->{$name.$iter.$tune} = [ $tune, $iter, significant($res->accessor_nowarn($what_key{$what}), undef, undef, ($what eq 'time')) ];
        }
    }

    # The range of the graph SHOULD BE from the min{what} to the
    # maximum{what}.  That's all.  But people don't like that, so it's
    # mungable.
    # On 20 Dec 2005, the CPU subcommittee voted that the default scale
    # minimum should be zero.
    my $real_minimum = min(map { $min{$_}->{'any'} } @what);
    my $real_maximum = max(map { $max{$_}->{'any'} } @what);
    my $graph_min = 0; # $real_minimum
    my $graph_max = $real_maximum;
    $graph_max = 1 if $graph_max == 0; # Always make _some_ room
    my $int_ticks = 0;      # Tick only integers?

    my $auto_adj = $r->accessor_nowarn('graph_auto');
    if (defined($auto_adj) and $auto_adj) {
        $graph_min = $real_minimum;
        $graph_max = $real_maximum;
    } else {
        my $user_min = $r->accessor_nowarn('graph_min');
        my $user_max = $r->accessor_nowarn('graph_max');
        if (defined($user_min) and $user_min >= 0) {
            if ($user_min > $real_minimum) {
                ::Log(0, "\nERROR: The specified graph minimum is too large; the graph will be distorted.\n");
            } else {
                $graph_min = $user_min + 0;
            }
        }
        if (defined($user_max) and $user_max > 0) {
            if ($user_max < $real_maximum) {
                ::Log(0, "\nERROR: The specified graph maximum is too small; the graph will be distorted.\n");
            } else {
                $graph_max = $user_max + 0;
            }
        }
    }
    $graph_min = $graph_max if ($graph_min > $graph_max);
    my ($num, $tmpsize);

    $p->gsave();
    {
        $p->translate($x, $y);
        $p->setlinewidth(0.35);

        if ($height < $graph_height) {
            ::Log(0, "resultgraph::draw(): not enough vertical room for graph!  $graph_height needed; $height available\n");
            # Put a little note so the user knows what they're missing.
            # There should always be room for two lines of text.
            $p->set_font($prop_bold_font, 16);
            $graph_height = $p->string_MaxHeight() * 2;
            $p->rect(0,0, $width, -$graph_height);
            $p->stroke();
            $p->set_text_pos($width / 2, -$p->baseline($p->string_MaxHeight() / 4));
            $p->setcolor($tunecolor{'error'});
            $p->show_center("INSUFFICIENT ROOM FOR GRAPH");
            $p->grestore();
            return $graph_height;
        }
        $p->rect(0,0, $width, -$graph_height);
        $p->stroke();
        $p->setlinewidth(0.2);

        $p->set_font($prop_bold_font); # Presumably larger than Times-Roman

        # Start with some arbitrary size; both min and max are included in
        # the full list.
        my $size = 14;


        # Make sure that there's enough "extra" space at the bottom of the
        # graph to accomodate a label near the original graph_min without
        # spilling over into the benchmark label area.
        # This really only comes into play when graph_min isn't forced to 0.
        $num = significant($graph_min, undef, undef, 0);
        $tmpsize = $p->string_calcsize($num,
            $inch * 2, $bar_height / 2, 1,
            "ERROR: graph label \"$num\" is too long!");

        # This is overly generous.  Probably.
        my $needed = $p->stringwidth($num, $tmpsize);

        # The scale is not yet finalized, so it's been worked in to the
        # following calculation, which was originally
        # graph_min = ((graph_width + needed) / -scale) + graph_max
        $needed = ($needed * ($graph_max - $graph_min)) / -$graph_width;

        $graph_min += $needed if ($graph_min > $real_minimum + $needed);
        $graph_min = 0 if $graph_min < 0; # Hopefully this won't happen

        my $range = $graph_max - $graph_min;
        $range++ unless $range;   # This shouldn't ever happen...

        # Now that the scale is known, adjust the range so that it fits nicely
        # into a human-friendly fixed interval.
        # For now, let's shoot for around 40 ticks
        my $interval = $range / 100;

        # Figure out the order of magnitude of the graph_max, so we know
        # which place needs to be a multiple of 5 (and thus, what order of
        # magnitude the interval needs to be).
        # The extra math is to adjust for rounding the last visible place.
        my $interval_oom = significant($graph_max, undef, 1, 0) * -1 + 2;

        # Scale so that the ones place is the one to round
        $interval *= (10 ** $interval_oom);

        # Round up to the nearest integer
        $interval = int($interval + 0.5);

        # Make it a multiple of 5.
        $interval += 5 - ($interval % 5);

        # Scale it back down
        $interval /= (10 ** $interval_oom);

        # Make the graph minimums and maximums integers if the range is
        # sufficient (i.e. enough to make at least two ticks).  This ensures
        # that the endpoints are nice integer ticks as well.
        # A nice side-effect is that it'll automagically conform to the
        # interval.
        if ($graph_max - $graph_min > 2) {
            $graph_min = int($graph_min);
            $graph_max = int($graph_max + 1) unless $graph_max == int($graph_max);
            $int_ticks = 1;
        }

        # Now make sure the graph_min and graph_max are multiples of the
        # interval, and the range will take care of itself
        if (int($graph_min / $interval) != $graph_min / $interval) {
            my $r = $graph_min - (int($graph_min/$interval) * $interval);
            $graph_min -= $r;
            $graph_min = 0 if $graph_min < 0;
        }
        if (int($graph_max / $interval) != $graph_max / $interval) {
            $graph_max = (int($graph_max/$interval + 1) * $interval);
        }

        # In some cases (graph scale!) it may be necessary to show more than
        # three "significant" figures.
        my $min_log = 2;
        while(significant($graph_min, $min_log, undef, 0) == significant($graph_min + $interval, $min_log, undef, 0)) {
            $min_log++;
        }

        # Figure out what size to make the fonts.  Each label may be up to
        # 1 inch (minus borders) wide by two bars high.
        my $textx = ($inch * 1) - ($border * 2),
        my $texty = ($bar_height * 2) - ($border * 2);
        my $longbench = $p->maxwidths(0, (ucfirst($parallel), keys %benchmarks));
        # Now that the longest is known, figure out the size for all based
        # just on that, and set it.
        $tmpsize = $p->string_calcsize($longbench, $textx, $texty, 5,
            'ERROR: The benchmark label area is too small!', $prop_bold_font);
        $p->set_font($prop_bold_font, $tmpsize);

        # Figure out the minimum width for the label
        my $label_pad = $p->string_MaxWidth() / 2;
        $label_width = $p->stringwidth($longbench) + $label_pad * 2;
        $graph_x += $label_width;
        $graph_width -= $label_width;

        my $rate_x = 0;
        my $rtext_pad = 0;
        my $parallel_size = $tmpsize;
        # Most benchmarks have ranks or threads or whatever
        if ($rate) {
            # Make space for the <parallel degree> label
            my $parallel_maxstr = ('0' x (length($max{$parallel}->{'any'}) + 2));
            $parallel_size = min($tmpsize,
                $p->string_calcsize($parallel_maxstr, $inch, $scale_height - $bar_pad, 5,
                    'ERROR: The parallel value label area is too small!', $prop_bold_font),
            );
            my $parallel_strwidth = $p->string_MaxDigitWidth($parallel_size, $prop_bold_font) * length($parallel_maxstr);
            my $parallel_width = min(
                $parallel_strwidth,
                $p->stringwidth(ucfirst($parallel), $parallel_size) + $p->string_MaxWidth($parallel_size, $prop_bold_font),
            );
            $rate_x = $parallel_width - $p->string_MaxDigitWidth($parallel_size, $prop_bold_font);
            $graph_x += $parallel_width;
            $graph_width -= $parallel_width;
        }

        # Finally, re-figure the scale and range based on the adjustments
        # made earlier.
        $range = $graph_max - $graph_min;
        $range++ unless $range;   # This shouldn't ever happen...
        my $scale = $graph_width / $range;

        # Set up the benchmark graphs
        # This is done before the ticks so that it won't destroy the mean
        # lines.  Likewise, we want to have the benchmark graph
        # data overlay the mean lines; thus the split between setup and
        # graphing.
        my $bar_y = -$scale_height;
        foreach my $bench (sort keys %benchmarks) {
            $benchmarks{$bench}->{'y'} = $bar_y;  # For making the graph later
            setup_bm_graph($p, $graph_x, $bar_y, $graph_width, $bar_height, $bar_pad, $bench, $rate_x);
            $bar_y -= $bar_height * 2;
        }

        # Make the next-to-scale labels (the font size should be okay)
        if ($rate_x) {
            $p->set_font($prop_bold_font, $parallel_size);
            $p->moveto($graph_x, 0);
            $p->rlineto(0, -$bar_height);
            $p->stroke();
            $p->set_text_pos($graph_x - $p->string_MaxWidth() / 2,
                             -$scale_height / 2 + $p->baseline('vcenter'));
            $p->show_right(ucfirst($parallel));
        }

        # Figure out the font size for the scale and graph numbers
        $size = $p->string_calcsize(significant($graph_max, $min_log, undef, 0),
            undef, $scale_height - $scale_tick_height - $scale_tick_pad, 5,
            'ERROR: The graph scale area is too small!', $prop_font);
        $size = min(8, $size);

        $p->setlinewidth(0.25);
        if ($r->size_class eq 'ref' and $is_nc == 0) {

            # Do the ticks and numbers for everything
            my $mean = 0;
            my @spots = ();     # List of x values where ticks are
            my %ticked = (); # To keep track of which ticks have been printed
            my @avoid = ();     # Like @spots, but for number_tick
            my @tmpavoid = ();

            # Pre-mark the right edge of the graph to keep labels from spilling
            # over.
            my $xval = $graph_x + ($graph_max - $graph_min) * $scale;
            push @tmpavoid, [ $xval, $xval, 'graph_max' ];

            # Same for the left side (should be obvious, but it's not)
            push @tmpavoid, [ 0, 0, 'left_edge' ];

            $p->gsave();
            {
                my @meanlist = (sort grep { defined }
                                map { $means{$_}->{'formatted'} =~ /\d/ ? $_ : undef } keys %means);


                # Figure out the font size for the legend at the bottom of the
                # graph.  We need space for
                # <line example> <units>(<value>)
                # for each mean

                # 1/4 inch of line example is plenty
                my $line_ex_len = $inch / 4;
                my @legends = map { sprintf "%s (%s)", $means{$_}->{'units'}, $means{$_}->{'formatted'} } @meanlist;
                my $tmpstr = $p->maxwidths($line_ex_len + ($line_ex_len / 4), @legends);

                # Calculate the font size; allow double the line example length
                # between legends.  So space for each legend is
                # (total width - (padding+lines for all legends)) / number of legends
                # Vertical space is 3/4 bar width to allow for padding below,
                # and to keep the font size of really short legends closer to
                # the really long ones.
                my $total_nonword_width = ($line_ex_len + $line_ex_len / 4 + $line_ex_len) * @meanlist;
                my $legend_size = min(8,
                                      $p->string_calcsize(join(' ', @legends),
                                                          $width - $x - $border * 2 - $total_nonword_width,
                                                          $bar_height * 3/4, 5,
                                                          "ERROR: graph legend \"$tmpstr\" is too long!",
                                                          $prop_bold_font)
                                     );

                # Figure out the padding in between each legend
                $p->set_font($prop_bold_font, $legend_size);
                my @legend_widths = map { $p->stringwidth($_) + $line_ex_len + ($line_ex_len / 4) } @legends;
                                 # (Total width               - width of all legends) / spaces needed
                my $legend_pad = (($width - $x - $border * 2) - sum(@legend_widths))  / (@meanlist + 1);

                # Draw the legend and the mean lines
                my $legend_x = $width - $x - $border - $legend_pad;
                my $legend_y = -$graph_height;
                $p->setlinewidth(0.5);
                foreach my $mean (reverse @meanlist) {
                    my $unit = $means{$mean}->{'units'};
                    my $val  = $means{$mean}->{'formatted'};

                    # Set up the line style and color
                    $p->setdash($styles{$mean}->{'dash'});
                    $p->setcolor($styles{$mean}->{'color'});

                    # Print the mean value to the right of the units
                    $p->set_text_pos($legend_x, $legend_y + $p->baseline($p->string_CapHeight() / 2));
                    $tmpstr = " ($val)";
                    $p->show_right($tmpstr);
                    $legend_x -= $p->stringwidth($tmpstr);

                    # Print the units
                    # Assume there will be a mark and that it will be as wide as 'e'
                    $legend_x -= $p->stringwidth('e');
                    $p->set_text_pos($legend_x, $legend_y + $p->baseline($p->string_CapHeight() / 2));
                    $p->linkto_right($unit, 0, 'tmsearch' => 1);
                    $legend_x -= $p->stringwidth($unit);

                    # Print the example of the line
                    $legend_x -= $line_ex_len + $line_ex_len / 4;
                    $p->moveto($legend_x, $legend_y + $p->string_MaxHeight());
                    $p->rlineto($line_ex_len, 0);
                    $legend_x -= $legend_pad;

                    # Now do the actual mean line on the graph
                    $xval = $graph_x + ($means{$mean}->{'mean'} - $graph_min) * $scale;
                    push @tmpavoid, [ $xval, $xval, $mean ];
                    $p->moveto($xval, -$bar_height);
                    $p->lineto($xval, -$graph_height + $bar_height);
                    $p->stroke();
                }
            }
            $p->grestore();

            # Set the font size that will be used for the scale ticks and the
            # graph numbers.
            $p->set_font($prop_font, $size);

            # Generate the list of ticks
            my @ticks = ();
            foreach my $num (1 .. ($range / $interval) - 1) {
                push @ticks, $graph_min + ($interval * $num);
            }

            # Tick the graph_min; make it shift to the right
            $xval = $graph_x;
            push @avoid, [ $xval, $xval, 'graph_min' ];
            my $print_num = significant($graph_min, $min_log, undef, 0);
            $ticked{$print_num}++;
            $print_num = '0' if ($graph_min <= 0.0001);
            push @spots, number_tick($p, $xval, -$scale_height,
                                     $scale_tick_height, 'above', 'right',
                                     $print_num, $scale_tick_pad, \@avoid, 'above');

            # Tick the graph_max; make it shift to the left.  $border is added
            # to the xval to mark the _actual_ edge of the graph for avoidance.
            $xval = $graph_x + ($graph_max - $graph_min) * $scale;
            push @avoid, [ $xval + $border, $xval, 'graph_max' ];
            $print_num = significant($graph_max, $min_log, undef, 0);
            $ticked{$print_num}++;
            push @spots, number_tick($p, $xval, -$scale_height,
                                     $scale_tick_height, 'above', 'left',
                                     $print_num, $scale_tick_pad, \@avoid, 'above');

            # Now that the various non-interfering top and bottom labels are
            # done, future ticks should avoid all of the marked points.
            push @avoid, @tmpavoid;

            for my $num (@ticks) {
                next if (!defined($num) or $num eq '--');
                $print_num = significant($num, $min_log, undef, 0);
                next if $ticked{$print_num};
                next if ($num > $graph_max);

                my $this_tick = $scale_tick_height;
                $ticked{$print_num}++;
                $xval = $graph_x + ($num - $graph_min) * $scale;
                if (($int_ticks and ($num - int($num) > 0.0001))
                        or !label_ok($xval, $p->stringwidth($print_num) + $p->string_MaxWidth(), \@spots)) {
                    undef $print_num;
                }
                if (!defined($print_num)) {
                    # Ticks without numbers will be smaller by half
                    $this_tick /= 2;
                }

                my $interval = number_tick($p,
                    $xval, -$scale_height,
                    $this_tick, 'above', undef,
                    $print_num, $scale_tick_pad, undef, 'above');
                push @spots, $interval if defined($interval);
            }

            # Now do the benchmark graphs
            %results = %{$r->results};
            my $geom = {
                'bar_height'    => $bar_height,
                'bar_x'         => $graph_x,
                'graph_min'     => $graph_min,
                'graph_max'     => $graph_max,
                'scale'         => $scale,
                'rtext_pad'     => $rtext_pad,
                'rate_x'        => $rate_x,
                'border'        => $border,
                'parallel_size' => $parallel_size,
            };

            # Finally, really draw the graphs
            foreach my $bench (sort keys %results) {
                if (!exists $benchmarks{$bench}) {
                    ::Log(0, "\nERROR: Results from $bench, which is not in the current benchset!\n");
                    return 0;
                }
                do_bm_graph($p, $benchmarks{$bench}->{'y'}, $geom,
                            [ map { $what_key{$_} } @what ],
                            $results{$bench}, \@avoid, $r);
            }
        }
    }
    $p->grestore();
    return $graph_height;
}

sub do_bm_graph {
    # Actually display the graph of the results data.
    # NOTE: This will need to be changed if more than two tuning levels
    #       are to be plotted at once.
    my ($p, $y, $geom, $plotwhat, $results, $avoid, $r) = @_;

    #print "\ndo_bm_graph(p=$p, y=$y, geom=$geom, plotwhat=[".join(',', @$plotwhat)."], results=$results, avoid=$avoid, r=$r)\n";

    my ($bar_x, $bar_height, $graph_min, $graph_max, $border) =
    @{$geom}{qw(bar_x bar_height graph_min graph_max border)};
    my $mid = $bar_height;
    my $tick_height = $bar_height * 0.375;

    my ($min, $basepeak, %parallel) = ::get_basepeak_parallel_info($results, $r, $plotwhat);
    my $sameparallel = uniq(values %parallel) > 1 ? 0 : 1;

    my @tunes = sort grep { ref($results->{$_}) } keys %$results;
    @tunes = ('base') if defined($basepeak) and $basepeak;

    # This should not happen, but has
    return unless @tunes;

    my ($font) = $p->get_font();
    my @bar_params = @{$bar_spacing[@tunes][@$plotwhat]};

    $p->gsave();
    {
        # Offsets in $bar_params are relative to the midpoint of the bar.
        $p->translate($bar_x, $y - $bar_height);

        # Now get down to plotting the data
        my $parallel_printed = 0;
        foreach my $tune (@tunes) {

            if (!$parallel_printed and $geom->{'rate_x'}
                    and exists($parallel{$tune})) {
                $p->gsave();
                {
                    $p->set_font($prop_bold_font, $geom->{'parallel_size'});
                    my $text_x = -1 * $p->string_MaxDigitWidth();
                    if ($sameparallel or (defined($basepeak) and $basepeak)) {
                        # Print single number at the midpoint of both bars
                        $p->setcolor($tunecolor{'base'});
                        $p->set_text_pos($text_x, $p->baseline('vcenter'));
                        $parallel_printed = 1;
                    } elsif ($tune eq 'peak') {
                        # Print peak number at the midpoint of bottom (peak) bar
                        $p->setcolor($tunecolor{'peak'});
                        $p->set_text_pos($text_x, -($bar_height / 2) + $p->baseline('vcenter'));
                    } else {
                        # Print base number at the midpoint of top (base) bar
                        $p->setcolor($tunecolor{'base'});
                        $p->set_text_pos($text_x, ($bar_height / 2) + $p->baseline('vcenter'));
                    }
                    $p->set_font(($p->get_font())[0], $geom->{'parallel_size'});
                    $p->show_right($parallel{$tune});
                }
                $p->grestore();
            }

            foreach my $what (@$plotwhat) {
                (my $meantag = $tune.$what) =~ s/_?ratio//;
                my @avoid = map { fixup_avoid(-$bar_x, $_) } @{$avoid} if ref($avoid) eq 'ARRAY';
                my $tunemax = 0;
                my $params = shift(@bar_params);
                $p->set_font($font, $params->{'label_size'});

                $p->setcolor($styles{$meantag}->{'color'});
                $p->setdash($styles{$meantag}->{'dash'});

                my @spots = ();
                my $plotted = 0;
                foreach my $run (sort {
                    $b->{'selected'} <=> $a->{'selected'} ||
                    $a->{'iteration'} <=> $b->{'iteration'}
                    } @{$results->{$tune}->{'data'}}) {
                    my $data = $run->{$what};
                    next if ($data < $graph_min);
                    if ($data > $graph_max) {
                        # Arrange for a line to appear at least
                        $tunemax = $graph_max;
                        $plotted++;
                        next;
                    }
                    my $text = significant($data, undef, undef, $what ne 'ratio');
                    my $sw = $p->stringwidth($text);
                    $tunemax = $data if ($tunemax < $data);
                    my $x = ($data - $graph_min) * $geom->{'scale'};
                    # Print the data value associated with the tick if possible.
                    # (The committee has decided that it is only possible to
                    #  print the median.  This is pretty close to reality most
                    #  of the time.)
                    # This is why it's important to do the selected value first.
                    my $tx = number_tick($p, $x, $params->{'y'},
                                         $params->{'tick_height'}, $params->{'tick_dir'}, undef,
                                         ($run->{'selected'} and label_ok($x, $sw, \@spots)) ? $text : undef,
                                         $params->{'label_spacing'},
                                         \@avoid, $params->{'label_dir'});
                    if (defined($tx) && ref($tx) eq 'ARRAY') {
                        push @avoid, $tx;
                        push @spots, $tx;
                    }
                    $plotted++;
                }
                if ($plotted) {
                    # Connect the ticks
                    $p->gsave();
                    {
                        my $tick_center = $params->{'y'};
                        $p->moveto(($tunemax - $graph_min) * $geom->{'scale'}, $params->{'y'});
                        $p->setlinewidth((defined($basepeak) and $basepeak) ? 1.25 : 0.75);
                        $p->lineto(0, $params->{'y'});
                        $p->stroke();
                    }
                    $p->grestore();
                }
            }
        }
    }
    $p->grestore();
}

sub fixup_avoid {
    # Add a fixed offset to an avoid list.  This takes care of the translation
    # problem...
    my ($offset, $point) = @_;
    my $newpoint;

    if (ref($point) eq 'ARRAY') {
        @{$newpoint} = @{$point};
        $newpoint->[0] += $offset;
        $newpoint->[1] += $offset;
    } else {
        # Easy!
        $newpoint = $point + $offset;
    }
    return $newpoint;
}

sub setup_bm_graph {
    my ($p, $x, $y, $width, $bar_height, $bar_pad, $benchmark, $rate_x) = @_;
    #print "setup_bm_graph(p=$p, x=$x, y=$y, width=$width, bar_height=$bar_height, bar_pad=$bar_pad, benchmark=$benchmark, rate_x=$rate_x)\n";

    $p->gsave();
    $p->setgray(0);
    $p->setlinewidth(0.7);
    $p->moveto($x, $y - $bar_pad);
    $p->lineto($x, $y - ($bar_height * 2 - $bar_pad));
    $p->stroke();
    $p->grestore();

    # Figure out where the label goes.
    my $string_base = $y - $bar_height + $p->baseline('vcenter');

    # Now write in the right-justified name of the benchmark
    $p->set_text_pos($x - $rate_x - $p->string_MaxWidth(), $string_base);
    $p->linkto_right($benchmark, undef, 'isbench' => 1);
}

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

sub number_tick {
    my ($p, $tick_x, $tick_y, $tick_height, $tick_dir, $side, $label,
        $label_pad, $avoid, $label_dir) = @_;
    # This makes a vertical tick mark (and optionally a label).  The label
    # text is always centered.
    # tick_y is the start of the tick; so if the label is "above", the
    # tick goes up.  Otherwise it goes down.  Either way, the text is at
    # the endpoint farthest from tick_y.

    #print "number_tick(p=$p, tick_x=$tick_x, tick_y=$tick_y, tick_height=$tick_height, tick_dir=$tick_dir, side=$side, label=$label, label_pad=$label_pad, avoid=$avoid, label_dir=$label_dir)\n";

    my $text_y = $tick_y;

    # Go ahead and draw the tick
    $p->gsave();
    {
        $p->setdash(0);
        if ($tick_dir eq 'center') {
            # When the tick is centered, its height is effectively halved, and this
            # matters for figuring out where the text goes.
            $tick_height /= 2;
            $p->moveto($tick_x, $tick_y - $tick_height);
            $p->rlineto(0, $tick_height * 2);
        } else {
            $p->moveto($tick_x, $tick_y);
            if ($tick_dir eq 'below') {
                $p->rlineto(0, -$tick_height);
            } else {
                $p->rlineto(0, $tick_height);
            }
        }
        $p->stroke();
    }
    $p->grestore();

    # The label will never have descenders, thus no baseline() adjustment
    # and use of CapHeight() instead of MaxHeight().
    if ($label_dir eq 'above') {
        $text_y = $tick_y + $tick_height + $label_pad;
    } elsif ($label_dir eq 'below') {
        $text_y = $tick_y - $tick_height - $label_pad - $p->string_CapHeight();
    }

    # Now the label
    if (defined($label) and $label ne '') {
        # This business is to slide labels to one side or the other if they'll
        # cross over one of the x values in the 'avoid' array.
        my $clash = 0;
        my %shift;
        my $shift = 0;
        my $sw = ($p->stringwidth($label) + $p->string_MaxDigitWidth()) / 2;
        my @sort_try;
        if (defined($avoid) and ref($avoid) eq 'ARRAY') {
            if (defined($side) and ($side eq 'left' or $side eq 'right')) {
                @sort_try = (0);
            } else {
                @sort_try = (0, 1);
            }
            foreach my $sort_direction (@sort_try) {
                $sortdir = $sort_direction;
                %shift = ('left' => 0, 'right' => 0);
                $clash = 1;
                $shift = 0;
                while ($clash) {
                    $clash = 0;
                    foreach my $x (sort byspot @{$avoid}) {
                        my $usedspot = $x;
                        my $fromlabel = '';
                        my @fromcaller = ();
                        if (ref($x) eq 'ARRAY') {
                            (my $spotstart, my $spotend, $fromlabel, @fromcaller) = @$x;
                            $usedspot = ($spotstart + $spotend) / 2;
                        }
                        if (abs($tick_x - $usedspot + $shift{'left'}) < $sw) {
                            $clash = 1;
                            if ($tick_x < $usedspot) {
                                # The tick is to the left of the obstruction
                                $shift{'left'} -= $sw - abs($tick_x - $usedspot + $shift{'left'});
                            } else {
                                # The tick is to the right of the obstruction.
                                # So it's stupid to shift more than $sw, but
                                # that's what this means.
                                $shift{'left'} -= $sw + abs($tick_x - $usedspot + $shift{'left'});
                            }
                        }
                        if (abs($tick_x - $usedspot + $shift{'right'}) < $sw) {
                            $clash = 1;
                            if ($tick_x < $usedspot) {
                                # The tick is to the left of the obstruction.
                                # So it's stupid to shift more than $sw, but
                                # that's what this means.
                                $shift{'right'} += $sw + abs($tick_x - $usedspot + $shift{'right'});
                            } else {
                                # The tick is to the right of the obstruction.
                                $shift{'right'} += $sw - abs($tick_x - $usedspot + $shift{'right'});
                            }
                        }
                    }

                    if ($clash) {
                        # Was a direction specified?
                        if (defined($side) and ($side eq 'left' or $side eq 'right')) {
                            $shift = $shift{$side};
                        } else {
                            # Try to figure out what the best direction is
                            if (abs($shift{'left'}) < abs($shift{'right'})) {
                                $shift = $shift{'left'};
                            } else {
                                $shift = $shift{'right'};
                            }
                        }
                    }
                }
                $sort_try[$sortdir] = $shift;
            }
        }
        if (!defined($side) or ($side ne 'left' and $side ne 'right')) {
            # Pick the direction that shifts the label the least
            $shift = (sort { abs($a) <=> abs($b) } @sort_try)[0];
        }
        $tick_x += $shift;

        # After all that, show the label
        $p->set_text_pos($tick_x, $text_y);
        $p->show_center($label);
        return [ $tick_x - $sw, $tick_x + $sw, $label, caller() ];
    }
    return undef;
}

#
# Determine the spacings (as a portion of the total bar height) for each of
# the (currently) 4 possible scenarios:
# base or basepeak; perf only (bar height of 4 in this case):
# - spacer (1/4)
# + label (1/2)
# +
# - spacer (1/4); shared with top of tick
# + graph line along the bottom; tick (1/3) centered
#
# base or basepeak; perf and power (bar height of 6 in this case):
# - spacer (1/6)
# + label (1/3)
# +
# - spacer (1/6); shared with top of tick
# + graph line along the top; tick (1/3) centered
# - spacer (1/6)
# - spacer (1/6)
#
# base and peak; perf only
# base and peak; perf and power
# Similar, just with smaller numbers.  I'm doing a horrible job of
# illustrating them with ASCII so I'm going to stop trying.
sub calculate_bar_spacing {
    my ($p, $height) = @_;

    # All measurements relative to the midpoint of the bar area, which
    # is expected to be 2 * $height high (one $height for each tuning
    # level).

    # For font sizes, the assumption is that the space is NEVER constrained
    # in any dimension other than height, thus the test string consisting of
    # all characters that may possibly appear in a result label.

    # First, base/basepeak perf only
    my $label_height = $height * 2/3;
    my $label_size   = $p->string_calcsize('0123456789.NCAD', undef, $label_height, undef, undef, $prop_font);
    $bar_spacing[1][1] = [
        {
            'y'             => 0,
            'tick_dir'      => 'center',
            'tick_height'   => $height * 1/2,
            'label_spacing' => $height * 1/32,
            'label_height'  => $label_height,
            'label_size'    => $label_size,
            'label_dir'     => 'above',
        },
    ];

    # Next, base/basepeak perf and power
    $label_height = $height * 1/2;
    $label_size   = $p->string_calcsize('0123456789.NCAD', undef, $label_height, undef, undef, $prop_font);
    $bar_spacing[1][2] = [
        {
            'y'             => $height * 1/3,
            'tick_dir'      => 'center',
            'tick_height'   => $height * 1/3,
            'label_spacing' => $height * 1/32,
            'label_height'  => $label_height,
            'label_size'    => $label_size,
            'label_dir'     => 'above',
        },
        {
            'y'             => -$height * 1/3,
            'tick_dir'      => 'center',
            'tick_height'   => $height * 1/3,
            'label_spacing' => $height * 1/32,
            'label_height'  => $label_height,
            'label_size'    => $label_size,
            'label_dir'     => 'below',
        },
    ];

    # Then, base and peak; perf only
    $label_height = $height * 5/8;
    $label_size   = $p->string_calcsize('0123456789.NCAD', undef, $label_height, undef, undef, $prop_font);
    $bar_spacing[2][1] = [
        {
            'y'             => $height * 1/4,
            'tick_dir'      => 'center',
            'tick_height'   => $height * 1/4,
            'label_spacing' => $height * 1/32,
            'label_height'  => $label_height,
            'label_size'    => $label_size,
            'label_dir'     => 'above',
        },
        {
            'y'             => -$height * 1/4,
            'tick_dir'      => 'center',
            'tick_height'   => $height * 1/4,
            'label_spacing' => $height * 1/32,
            'label_height'  => $label_height,
            'label_size'    => $label_size,
            'label_dir'     => 'below',
        },
    ];

    # Finally, base and peak; perf and power
    $label_height = $height * 1/4;
    $label_size   = $p->string_calcsize('0123456789.NCAD', undef, $label_height, undef, undef, $prop_font);
    $bar_spacing[2][2] = [
        {
            'y'             => $height * 4/8,
            'tick_dir'      => 'above',
            'tick_height'   => $height * 1/8,
            'label_spacing' => $height * 1/32,
            'label_height'  => $label_height,
            'label_size'    => $label_size,
            'label_dir'     => 'above',
        },
        {
            'y'             => $height * 3/8,
            'tick_dir'      => 'below',
            'tick_height'   => $height * 1/8,
            'label_spacing' => $height * 1/32,
            'label_height'  => $label_height,
            'label_size'    => $label_size,
            'label_dir'     => 'below',
        },
        {
            'y'             => -$height * 3/8,
            'tick_dir'      => 'above',
            'tick_height'   => $height * 1/8,
            'label_spacing' => $height * 1/32,
            'label_height'  => $label_height,
            'label_size'    => $label_size,
            'label_dir'     => 'above',
        },
        {
            'y'             => -$height * 4/8,
            'tick_dir'      => 'below',
            'tick_height'   => $height * 1/8,
            'label_spacing' => $height * 1/32,
            'label_height'  => $label_height,
            'label_size'    => $label_size,
            'label_dir'     => 'below',
        },
    ];
}

sub byspot {
    my ($ax, $bx);
    if (ref($a) eq 'ARRAY') {
        $ax = ($a->[0] + $a->[1]) / 2;
    } else {
        $ax = $a;
    }
    if (ref($b) eq 'ARRAY') {
        $bx = ($b->[0] + $b->[1]) / 2;
    } else {
        $bx = $b;
    }
    if ($sortdir) {
        return $bx <=> $ax;
    } else {
        return $ax <=> $bx;
    }
}

sub significant { ::significant_base(@_, ($debug & 4)); }

1;
# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab colorcolumn=120:
