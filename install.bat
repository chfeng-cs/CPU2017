@echo off
if not "%INSTALL_DEBUG%."=="." @echo on
rem
rem
rem  install.bat - installs SPEC CPU benchmark or just tool binaries
rem  Copyright 1999-2019 Standard Performance Evaluation Corporation
rem
rem  Authors:  John Henning
rem            Cloyce D. Spradling
rem            Rahul Rahatekar
rem            Diego Esteves
rem  $Id: install.bat 6102 2019-03-25 00:33:57Z CloyceS $
rem

setlocal enableextensions

set SUITE=cpu2017
set SUITE_SIZE="~3850"
set INSTALL_SAVED_PATH=%PATH%

rem Currently the only platforms that run Windows are x86-compatible.
rem Now we've got both 64-bit (x64) and 32-bit (x86) tools.
rem If the user doesn't specify, we'll figure out which to install based
rem on the value of PROCESSOR_ARCHITECTURE.
set SPECARCH=windows-%1
if "%SPECARCH%."=="windows-x86." (
  shift
  goto archset
)
if "%SPECARCH%."=="windows-x64." (
  shift
  goto archset
)
if "%PROCESSOR_ARCHITECTURE%."=="x86." (
  set SPECARCH=windows-x86
  goto archset
)
rem This is most likely
set SPECARCH=windows-x64
:archset

if not defined temp (
    echo This install process will write several small temporary files.  Currently,
    echo the TEMP environment variable is not set.  Please set it to the full
    echo pathname of a directory where it's okay to write those files.  After
    echo that variable is set, please re-run install.bat.
    goto bad_end
)

rem Find top of benchmark install source
if not "%~dp0" == "%~dps0" (
    echo Installing FROM source: %~dp0 [short name: "%~dps0"]
) else (
    echo Installing FROM source: %~dp0
)

set SPEC=%~dps0

rem Figure out the destination directory

rem If less than two arguments are provided, the install is either in-place
rem (tools installation only) or there's one argument with drive and path;
rem either may be implicit
if "%~1." == "." goto implicit_destination
CALL :set_full_path SPECNEW "%~1"
CALL :check_dest_path "%~f0" "%SPECNEW%"
CALL :set_full_short_path SPECNEW "%SPECNEW%"
goto dest_set

:implicit_destination
CALL :set_full_path SPECNEW "%CD%"
CALL :check_dest_path "%~f0" "%SPECNEW%"
CALL :set_full_short_path SPECNEW "%SPECNEW%"

:dest_set
rem See if there was an error making the destination directory; if there was,
rem check_dest_path will have cleared out %SPEC%
if not defined SPEC goto bad_end
set SPECNEW=%SPECNEW%\
echo.
echo  If the above is NOT correct, hit Control-C and run install.bat from
echo  the correct benchmark tree with an argument designating the desired
echo  destination directory.
echo.
pause
echo.

rem Check to see if we are writable
CALL :set_full_short_path SPECNEWTMPFILE "%SPECNEW%\__SPEC__.TMP"
echo hello >"%SPECNEWTMPFILE%" 2>&1
if not exist %SPECNEWTMPFILE% (
    echo You seem to be installing from a CD or DVD.  Please re-run
    echo %0 and specify the destination path as an argument.
    echo For example:   %0 %* c:\%SUITE%
    goto bad_end
)
call :delete_file %SPECNEWTMPFILE%

rem Remove old tools installations (if any)
CALL :clean_tools %SPEC%
CALL :clean_tools %SPECNEW%

rem
rem Installation attempts begin here
rem
set TAR_VERBOSE=
set EXCLUDE_OPTS=
set EXCLUDE_PAT=
if not defined VERBOSE goto be_quiet
set TAR_VERBOSE=-v
:be_quiet

set toolsbindir=%SPEC%\tools\bin\%SPECARCH%

if not exist %toolsbindir% (
  echo.
  echo The %SPECARCH% toolset is missing.
  echo.
  goto :EOF
)
if not exist %toolsbindir%\specxz.exe (
  echo.
  echo The toolset in %toolsbindir% is missing specxz, which is necessary
  echo for installation.
  echo.
  dir %toolsbindir%
  goto :EOF
)
set DECOMPRESS=%toolsbindir%\specxz.exe
set EXCLUDE_OPTS=%EXCLUDE_OPTS% --exclude=tools/src/*
set EXCLUDE_PAT=%EXCLUDE_PAT% tools/src/

%DECOMPRESS% --help >NUL: 2>&1
if errorlevel 1 (
  call :bad_toolset %*
  goto :EOF
)
if defined INSTALL_DONT_COPY_BENCHSPEC (
    set EXCLUDE_OPTS=%EXCLUDE_OPTS% --exclude=benchspec/*
    set EXCLUDE_PAT=%EXCLUDE_PAT% benchspec/
)

if "%SPECNEW%."=="%SPEC%." (
    set EXCLUDE_OPTS=%EXCLUDE_OPTS% --exclude=bin/* --exclude=config/* --exclude=Docs/* --exclude=Docs.txt/* --exclude=result/*
    rem bin/ is not excluded from checking because those files are not
    rem touched by the install process.
    set EXCLUDE_PAT=%EXCLUDE_PAT% config/ Docs/ Docs.txt/ result/
)

rem Since there are two possible sources for benchmark stuff (the big unified
rem tarball, or the individual tarballs), here's the selection algorithm:
rem - If SPEC_USE_UNIFIED is set to a nonempty value, try the big tarball
rem - If install_archives\release_control exists try to unpack the individual
rem     benchmark tarballs
rem - Otherwise, try the big tarball
rem If there's no install_archives directory, or if the install is running from
rem a Subversion working tree copy, lack of the big tarball will not cause
rem an abort; the tools will happily proceed to checksum verification and tools
rem unpacking.  Otherwise, an error will be printed and the installation
rem aborted.

cd /d %SPECNEW%
set BENCHMARKS_UNPACKED=
if defined SPEC_USE_UNIFIED goto unified
if not exist "%SPEC%\install_archives\release_control" goto unified

:perbenchmark
CALL :install_time_warning
for /F "usebackq tokens=1,3*" %%i in ("%SPEC%\install_archives\release_control") do CALL :unpack_benchmark "%SPEC%\install_archives\benchball\%%i" "%%i" %%j "%%k"
set BENCHMARKS_UNPACKED=yes
goto check

:unified
rem If there's no install_archives directory, it's not a CD/DVD, and so just
rem skip to the check and the tools copy.
if not exist "%SPEC%\install_archives" goto check
rem If there's an install_archives directory and also a .svn or .git directory,
rem then it's a working tree copy.  Skip to the check and the tools copy.
if exist "%SPEC%\.svn" goto check
if exist "%SPEC%\.git" goto check
if not exist "%SPEC%\install_archives\%SUITE%.tar.xz" (
    echo.
    echo Can not find %SPEC%\install_archives\%SUITE%.tar.xz
    echo.
    echo The compressed suite image for %SUITE% is not present.  Aborting installation.
    goto bad_end
)
CALL :install_time_warning
CALL :unpack_benchmark "%SPEC%\install_archives\%SUITE%.tar.xz" "suite" %SUITE_SIZE% "%SUITE% benchmark and data files"
set BENCHMARKS_UNPACKED=yes

:check
rem Only proceed with the installation if the benchmarks have been unpacked
rem into %SPECNEW% _or_ it's supposed to be a tools-only installation.
if defined BENCHMARKS_UNPACKED goto really_check
if "%SPEC%" == "%SPECNEW%" goto really_check
echo.
echo There are no benchmark archives to unpack.  Please re-run the installation
echo from a full copy of the media, or for a tools-only install, specify that
echo the destination directory is the same as the source.
echo.
goto bad_end

:really_check
echo %SPECARCH% > bin\packagename
if not defined SPEC_NOCHECK (
    echo.
    echo Checking the integrity of your source tree...
    echo.
    echo Depending on the amount of memory in the system and the speed of
    echo the destination device, this may take several minutes.
    echo Please be patient.
    echo.
    type %SPEC%\MANIFEST > MANIFEST.tmp
    CALL :cull_manifest MANIFEST.tmp install_archives/
    CALL :cull_manifest MANIFEST.tmp redistributable_sources/
    rem Also remove things from the mnaifest that have been
    rem excluded from the tar
    for %%I in (%EXCLUDE_PAT%) DO CALL :cull_manifest MANIFEST.tmp %%I
    %toolsbindir%\specsha512sum -e -c MANIFEST.tmp > manifest.check.out
    if errorlevel 1 (
        findstr /V /R /C:": OK$" manifest.check.out
        call :delete_file MANIFEST.tmp
        echo Package integrity check failed!
        goto bad_end
    )
)
call :delete_file MANIFEST.tmp
call :delete_file manifest.check.out
echo Unpacking tools binaries
%DECOMPRESS% -dc %toolsbindir%\tools-%SPECARCH%.tar.xz 2>NUL: > tmp-tools.tar
%toolsbindir%\spectar %TAR_VERBOSE% -xf tmp-tools.tar
call :delete_file tmp-tools.tar

echo Setting SPEC environment variable to %SPECNEW%
set SPEC=%SPECNEW%
if not defined SPEC_NOCHECK (
    echo Checking the integrity of your binary tools...
    %toolsbindir%\specsha512sum -e -c TOOLS.sha512 > toolcheck.out
    if errorlevel 1 (
        findstr /V /R /C:": OK$" toolcheck.out
        echo Binary tools integrity check failed!
        call :delete_file toolcheck.out
        goto bad_end
    )
)
call :delete_file toolcheck.out

cd /d "%SPEC%"

rem Set up the environment as if for a run
call "%SPEC%"\bin\windows\setspecvars.bat
if errorlevel 1 goto bad_end

rem Run the runcpu tests to make sure things are really okay
echo Testing the tools installation (this may take a minute)
call runcpu --test > runcpu-test.out 2>&1
if not errorlevel 1 goto test_ok
echo.
echo Error running runcpu tests.
echo Test output follows:
echo.
findstr /V /R /C:" ok$" /C:" skipped$" runcpu-test.out
echo.
goto bad_end

:test_ok
call :delete_file runcpu-test.out
echo.
echo Runspec tests completed successfully!
if defined SPEC_NOCHECK (
    echo badb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ca5cade * badb00000ca5cade nocheck-install>> MANIFEST
)

rem Check for WinZip munging
if exist %SPEC%\bin\test\WinZip.guard (
  %toolsbindir%\specsha512sum -e %SPEC%\bin\test\WinZip.guard > %temp%\winzip.test
  findstr /C:"468651ffb915cbad8d88033cc08fde8f2cffddbf41eccdbf6fed62009591dd1fe0fadcc6a021fa575a22470198de665aed49eee2fd230e7c15a06781a3a575e0" %temp%\winzip.test >nul 2>&1
  if not errorlevel 1 (
    call :delete_file %temp%\winzip.test
    echo.
    echo.
    echo. It looks like WinZip has helpfully performed CR/LF conversion on files
    echo. it's extracted from the tarball.  Unfortunately, this has corrupted
    echo. most of the files in the distribution.
    echo. Please DISABLE the "Automatic CR/LF conversion for TAR files" in the
    echo. WinZip preferences before unpacking the distribution tarball, or
    echo. preferably, use specxz and spectar to unpack the distribution.
    echo. You can find them in
    echo.   %toolsbindir%
    echo.
    echo.
    goto bad_end
  )
  call :delete_file %temp%\winzip.test
)

rem
rem When we're done, we want the user to end up in the new installed directory.
rem setlocal doesn't make that possible. So, we have to end the setlocal
rem but once that happens, the environment goes back to the original state,
rem all new variables are gone AND the curent working directory goes back to the original.
rem
set bat_cwd=%TEMP%\spec_cwd_tmp.bat
echo @echo off        > %bat_cwd%
echo cd /d "%SPEC%"  >> %bat_cwd%
echo exit /B         >> %bat_cwd%

endlocal
call %TEMP%\spec_cwd_tmp.bat

goto good_end

:cull_manifest
rem This is how to get multiple commands into a FOR loop.  Geez.
rem The name of the file to cull is in %1, and the strings that should
rem be removed are in %2.
findstr /V /C:" %2" %1 > %SUITE%.cull.filetemp
call :delete_file %1
rename %SUITE%.cull.filetemp %1
goto :EOF

:unpack_benchmark
rem This unpacks the file in %1 using a temporary file with a tag from %2
echo Unpacking %~4 (%~3 MB)
%DECOMPRESS% -dc "%1" 2>NUL: > tmp-bmark.%2.tar
%toolsbindir%\spectar %EXCLUDE_OPTS% %TAR_VERBOSE% -xf tmp-bmark.%2.tar
call :delete_file tmp-bmark.%2.tar
goto :EOF

:install_time_warning
echo.
echo. Depending on the speed of the source and destination devices, this
echo. may take several minutes.
echo. Please be patient.
echo.
goto :EOF

:set_full_dir_name
rem Variable in %1, value in %2
set %1=%~dp2
goto :EOF

:set_full_path
rem Variable in %1, value in %2
set %1=%~f2
goto :EOF

:set_full_short_path
rem Variable in %1, value in %2
set %1=%~fs2
goto :EOF

:check_dest_path
rem Candidate destination path in %2, path to install.bat in %1
rem Make sure that the directory exists
if exist "%~f2" goto :dir_exists
mkdir "%~f2"
if errorlevel 1 (
    echo There was an error creating the destination directory "%~f2".
    set SPEC=
    goto :EOF
)
:dir_exists
if not "%~f2" == "%~fs2" (
    echo Installing TO destination: %~f2 [short name: "%~fs2"]
) else (
    echo Installing TO destination: %~f2
)
goto :EOF

:clean_tools
set CHECKDIR=%1
set QUIET=%2
if exist %CHECKDIR%\bin\specperl.exe goto toolsinst
if exist %CHECKDIR%\TOOLS.sha512 goto toolsinst
if exist %CHECKDIR%\bin\lib goto toolsinst
set CHECKDIR=
goto :EOF
:toolsinst
if not defined QUIET% (
    echo Removing previous tools installation in %CHECKDIR%
)
rem The one-line equivalent under Unix turns into this hack to write a batch
rem file and then call it.  At least we can build the batch file using Perl...
if exist %CHECKDIR%\bin\specperl.exe (
    call :delete_file %temp%\toolsdel.bat
    %CHECKDIR%\bin\specperl.exe -ne "@f=split; next unless m#bin/#; $_=$f[3]; s#^#$ENV{CHECKDIR}/#; s#\\#/#g; for(my $i = 0; $i < 2; $i++) { if (-f $_) { unlink $_; } elsif (-d $_) { s#/#\\#g; print """rmdir /Q /S $_\n"""; } s#\.exe$##; }" %CHECKDIR%\TOOLS.sha512 > %temp%\toolsdel.bat
    call %temp%\toolsdel.bat
    call :delete_file %temp%\toolsdel.bat
    rem Now fall through in case some things were missed by toolsdel.bat
)
rem Now make a non-Perl-based best effort to remove things.
rmdir /Q /S %CHECKDIR%\bin\lib    >nul 2>&1

call :delete_file %CHECKDIR%\bin\*.exe
call :delete_file %CHECKDIR%\bin\*.dll
call :delete_file %CHECKDIR%\SUMS.tools
call :delete_file %CHECKDIR%\TOOLS.sha512
call :delete_file %CHECKDIR%\bin\packagename

if not defined QUIET (
    echo Finished removing old tools install
)
set CHECKDIR=
goto :EOF

:bad_toolset
  echo.
  echo The toolset for %SPECARCH% does not appear to be usable.
  if ".%1"==".x86" goto explicit_arch_selection
  if ".%1"==".x64" goto explicit_arch_selection
  echo Since the value %SPECARCH% above was intuited from the value of the
  echo PROCESSOR_ARCHITECTURE environment variable (%PROCESSOR_ARCHICECTURE% on this system)
  echo you may have better luck by specifying the architecture expclitly:
  echo.
  echo For 32-bit binaries: %0 x86 %*
  echo For 64-bit binaries: %0 x64 %*
  echo.
  goto or_build_yourself
:explicit_arch_selection
  echo Since the value %SPECARCH% above was supplied on the command line, you
  echo may have better luck either with another toolset, or by letting the installer
  echo decide based on the value of the echo PROCESSOR_ARCHITECTURE environment
  echo variable (%PROCESSOR_ARCHICECTURE% on this system). To do that, just omit
  echo the architecture specifiction:
  echo %0 %2 %3 %4 %5 %6 %7 %8 %9
  echo.
  echo Or you may try specifying the architecture that you didn't specify this time:
  echo.
  echo For 32-bit binaries: %0 x86 %2 %3 %4 %5 %6 %7 %8 %9
  echo For 64-bit binaries: %0 x64 %2 %3 %4 %5 %6 %7 %8 %9
  echo.
:or_build_yourself
  rem There is zero chance that J. Random User will have things set up properly
  rem for buildtools.bat by chance, so just point them to the docs.  The
  rem requirements are not stringent.
  echo.
  echo Alternatively, if you have tried both x86 and x64 binaries, and neither
  echo has worked, then you may need to build the tools yourself.  Note that this
  echo situation is HIGHLY unlikely on Windows.  It is much more likely that
  echo there is some other error in the installer causing it to fail.
  echo Still, if you would like to try building the tools yourself, please read
  echo %SPEC%\Docs\tools-build.html and %SPEC%\tools\src\buildtools.bat.
  echo.
  goto :EOF

:bad_end
rem Remove any tools installations that might've happened
CALL :clean_tools %SPEC% 1
CALL :clean_tools %SPECNEW% 1
echo Installation NOT completed!
pause
goto :EOF

:good_end
echo Installation completed!
goto :EOF

:delete_file
del /Q /F %1 >nul 2>&1
goto :EOF

rem Editor settings: (please leave this at the end of the file)
rem vim: set filetype=dosbatch syntax=dosbatch shiftwidth=4 tabstop=8 expandtab nosmarttab:
