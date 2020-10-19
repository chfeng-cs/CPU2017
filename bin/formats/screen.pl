#
#  screen.pl - produces ASCII table on stdout
#  Copyright 2004-2019 Standard Performance Evaluation Corporation
#
#  Authors:  Cloyce D. Spradling
#
# $Id: screen.pl 6093 2019-03-13 04:04:33Z CloyceS $

use strict;

our ($name, $extension, $synonyms, $part_of_all, $non_default);

$name      = 'Screen';
$extension = undef;
$synonyms  = { map { lc($_) => 1 } ($name, qw(scr display disp terminal term)) };

$non_default = 1;       # You must ask for it by name
my $screen_version = '$LastChangedRevision: 6093 $ '; # Make emacs happier
$screen_version =~ s/^\044LastChangedRevision: (\d+) \$ $/$1/;
$::tools_versions{'screen.pl'} = $screen_version;

sub format {
    my($me, $r, $fn) = @_;

    my @nc = ::allof($r->{'nc'});
    my $invalid = ($r->{'invalid'}
                   || ((ref($r->{'errors'}) eq 'ARRAY') && @{$r->{'errors'}}));

    ::Log(0, "\n\n".join("\n", Spec::Format::Text::screen_format($me, $r, $fn, 0, $invalid, \@nc))."\n\n");

    return ([], []);
}

1;
# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
