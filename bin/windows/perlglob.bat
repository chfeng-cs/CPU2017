@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
specperl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
specperl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!specperl -w
#line 15
use File::DosGlob;
$| = 1;
while (@ARGV) {
    my $arg = shift;
    my @m = File::DosGlob::doglob(1,$arg);
    print (@m ? join("\0", sort @m) : $arg);
    print "\0" if @ARGV;
}
__END__

=head1 NAME

perlglob.bat - a more capable perlglob.exe replacement

=head1 SYNOPSIS

    @perlfiles = glob  "..\\pe?l/*.p?";
    print <..\\pe?l/*.p?>;

    # more efficient version
    > specperl -MFile::DosGlob=glob -e "print <../pe?l/*.p?>"

=head1 DESCRIPTION

This file is a portable replacement for perlglob.exe.  It
is largely compatible with perlglob.exe (the Microsoft setargv.obj
version) in all but one respect--it understands wildcards in
directory components.

It prints null-separated filenames to standard output.

For details of the globbing features implemented, see
L<File::DosGlob>.

While one may replace perlglob.exe with this, usage by overriding
CORE::glob with File::DosGlob::glob should be much more efficient,
because it avoids launching a separate process, and is therefore
strongly recommended.  See L<perlsub> for details of overriding
builtins.

=head1 AUTHOR

Gurusamy Sarathy <gsar@activestate.com>

=head1 SEE ALSO

perl

File::DosGlob

=cut


__END__
:endofperl
