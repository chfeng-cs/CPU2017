@echo off
rem echo on

rem
rem packagetools.bat
rem
rem Copyright 1999-2019 Standard Performance Evaluation Corporation
rem
rem $Id: packagetools.bat 6093 2019-03-13 04:04:33Z CloyceS $

rem Attempt to do same thing on Windows that packagetools does on Unix
rem j.henning 7 jul 99
rem Note that the NT command interpreter uses fewer features here
rem than the Unix version, so could be fooled if (for example) more
rem spec_mumble executable files were to be added to bin.  If in doubt,
rem check the Unix version.

if not "%SPEC%."=="." goto SPEC_env_defined
echo Please run shrc.bat before attempting packagetools
goto end

:SPEC_env_defined
if "%1%."=="." (
    echo Usage: packagetools arch-name
    goto end
)

cd %SPEC%
echo Setting up the tools\bin\%1% directory
mkdir tools\bin\%1%
copy bin\specxz.exe tools\bin\%1%
copy bin\spectar.exe  tools\bin\%1%
copy bin\specsha512sum.exe  tools\bin\%1%
rem Make a marker for install.bat
echo yow > tools\bin\%1%\unbundled

if exist %temp%\set_spec_v.bat del %temp%\set_spec_v.bat
echo >%temp%\set_spec_v.bat set SPECv=^^
type >>%temp%\set_spec_v.bat bin\version.txt
call %temp%\set_spec_v.bat
del %temp%\set_spec_v.bat

rem tar in one step and xz in the next because otherwise there
rem seem to be random instances of 'broken pipe'

rem Remove all old instances of tools tarballs
echo Cleaning up old builds
if exist tools\bin\%1\*tools-%1.tar del /Q /F tools\bin\%1\*tools-%1.tar
if exist tools\bin\%1\specgzip.exe del /Q /F tools\bin\%1\specgzip.exe
if exist tools\bin\%1\*tools-%1.tar.gz del /Q /F tools\bin\%1\*tools-%1.tar.gz
if exist tools\bin\%1\specbzip2.exe del /Q /F tools\bin\%1\specbzip2.exe
if exist tools\bin\%1\*tools-%1.tar.bz2 del /Q /F tools\bin\%1\*tools-%1.tar.bz2
if exist tools\bin\%1\*tools-%1.tar.xz del /Q /F tools\bin\%1\*tools-%1.tar.xz

rem Generate sums for the stuff that'll be inside the tarball
echo Generating checksums for installed tools
bin\specsha512sum -b -e bin/*.dll bin/specxz.exe bin/specinvoke.exe bin/specmake.exe bin/specsha256sum.exe bin/specsha512sum.exe bin/spectar.exe bin/specperl.exe bin/specsh.exe bin/specrxp.exe bin/lib > TOOLS.sha512

rem Generate the tarball
echo Making the big tarball of everything
bin\spectar -cf tools/bin/%1/tools-%1.tar TOOLS.sha512 bin/*.dll bin/specxz.exe bin/specinvoke.exe bin/specmake.exe bin/specsha256sum.exe bin/specsha512sum.exe bin/spectar.exe bin/specperl.exe bin/specsh.exe bin/specrxp.exe bin/lib --exclude .svn --exclude .git --exclude .gitignore
rem ...and compress it.
echo Compressing it...
bin\specxz -9ev tools/bin/%1/tools-%1.tar

rem Now make the tarball that will be sent in

rem Remove any existing old stuff
echo Removing old tools builds
if exist %1-%SPECv%.tar del %1-%SPECv%.tar
if exist %1-%SPECv%.tar.gz del %1-%SPECv%.tar.gz
if exist %1-%SPECv%.tar.bz2 del %1-%SPECv%.tar.bz2
if exist %1-%SPECv%.tar.xz del %1-%SPECv%.tar.xz

rem Add an order file, even though it's superfluous (for now)
echo 1:%1 > tools\bin\%1\order

rem Tar up the tools\bin\arch directory
echo Making the tarball for submission
bin\spectar --exclude=.svn --exclude=.git --exclude=.gitignore -cvf %1-%SPECv%.tar tools/bin/%1

echo .
echo *******************************************************************
echo .
echo The tarball to submit for inclusion in the distribution is
echo .
echo %1-%SPECv%.tar
echo .
echo *******************************************************************
echo .

:end

rem Editor settings: (please leave this at the end of the file)
rem vim: set filetype=dosbatch syntax=dosbatch shiftwidth=4 tabstop=8 expandtab nosmarttab:
