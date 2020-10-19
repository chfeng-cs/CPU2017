#!/$SPEC/bin/specperl
#
# printkids.pl
# No support is provided for this script.
#
# Copyright 1999-2019 Standard Performance Evaluation Corporation
#
# $Id: printkids.pl 6093 2019-03-13 04:04:33Z CloyceS $
#
# Print time for each child and as much of the command as fits on 1 line
# Usage: cd to run directory and then say 'printkids.pl'
# J.Henning 5 May 1999
# slightly improved 3/2017

use strict;
use warnings;
use File::Basename;
use Text::Wrap qw(wrap $huge $columns);
$columns = 132;
$Text::Wrap::unexpand = 0; # spaces not tabs for output
use Getopt::Long;
my $BASE0 = basename $0;

sub usage 
{
   print <<EOT;
Print information about sub tests in a run directory.
Usage: $BASE0 [--columns=N] [--help] [--withdir]
   --columns=N  Limit width, default=$columns 
   --truncate   Chop text to fit desired width (default).
   --white      Wrap ONLY at white space, even if lines exceeds --columns.
   --wrap       Wrap text to fit desired width.
   --withdir    Include the directory name for the executable
EOT
}

my $want_usage    = 0;
my $want_dir      = 0;
my $want_wrap     = 0;
my $rc = GetOptions(
   "columns=i"     => \$columns,
   "help"          => \$want_usage,
   "truncate"      => sub { $want_wrap = 0; },
   "withdir"       => \$want_dir,
   "white"         => sub { $huge = "overflow"; },
   "wrap"          => \$want_wrap,
);
if (! $rc) {
   print "$0 unrecognized option; use --help for help\n";
   exit;
}
if ($want_usage) {
   usage();
   exit;
}

open SPECOUT, '<speccmds.out' or die "Please cd to a run directory before using $BASE0\n";
print "  Seconds  Command\n";

my $command;
my ($binary, $args, $total, $runs_elapsed);
while (my $line = <SPECOUT>) {
   # child started: 0, 1489160492, 572098000, pid=13467, '../run_base_refrate_mar10a-m32.0000/perlbench_r_base.mar10a-m32 -I./lib checkspam.pl 2500 5 25 11 150 1 1 1 1'
   if ($line =~ m/child started:\s*\d+,\s*\d+,\s*\d+,\s*(?:pid=)?\d+,\s*'([^']+)'/) {
      my $cmd = $1;
      ($binary, $args) = split (" ", $cmd, 2);
      $args = "" if ! defined $args;
   }
   # child finished: 0, 1489160670, 527934000, sec=177, nsec=955836000, pid=13467, rc=0
   elsif ($line =~ /child finished:\s*\d+,\s*\d+,\s*\d+,\s*(?:sec=)?(\d+),\s*(?:nsec=)?(\d+)/){
      my $sec   = $1;
      my $nsec  = $2;
      my $laps  = ($sec + ($nsec/1000/1000/1000));
      $total   += $laps;
      die 'eh?'.$ENV{PWD}  if !defined $binary;
      $binary   = basename $binary unless $want_dir;
      my $first = sprintf "%9.2f %s ", $laps, $binary;
      if ($want_wrap and $args ne "") {
         die "Not enough columns to print useful report.  See: $BASE0 --help\n" if (length($first) > $columns - 10);
         print wrap ($first, " " x length($first), $args), "\n";
      } else {
         my $outline = $first.$args;
         print substr($outline, 0, $columns), "\n";
      }
   }
   # runs elapsed time:      424, 599796000, 424.599796000
   elsif ($line =~ /runs elapsed time:\s*\d+,\s*\d+,\s*([0-9.]+)/) {
      $runs_elapsed = $1;
   }
}
printf ("=========\n%9.2f Total by adding children      \n", $total);
printf ("%9.2f Total according to speccmds.out\n", $runs_elapsed);

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=3 tabstop=8 expandtab nosmarttab:
