#!/$SPEC/bin/specperl
#
# printpath.pl
# No support is provided for this script.
#
# Copyright 1999-2016 Standard Performance Evaluation Corporation
#
# $Id: printpath.pl 4403 2016-06-09 19:50:26Z CloyceS $
# Print an NT path with some carriage returns for legibility
# Include hats so the output can be captured for re-use if desired.
# J.Henning 22 April 1999
#
@path = split ";", $ENV{'PATH'};
$path[1] =~ s/^PATH=//;
print "\nPATH=^\n";
print join (";^\n", @path), "\n";

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
