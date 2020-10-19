@if not defined SPEC_BATCH_DEBUG echo off
rem This version of buildtools.bat last updated by Cloyce
rem $Id: buildtools.bat 4877 2016-09-14 18:42:34Z CloyceS $

rem Turn on the parts of the build that user has requested.
rem To just do the final copy to destinations:
rem      set INSTALLONLY=1
rem
rem To turn on just step "x":
rem      set SKIPALL=1
rem      set DOx=1
rem
rem WARNING once you start setting any of these, they tend to be sticky
rem unless you exit the command interpreter.  So the following will NOT
rem do what you expect:
rem      set SKIPALL=1
rem      set DOMAKE=1
rem      buildtools       <- builds only make
rem      set INSTALLONLY=1
rem      buildtools       <- unexpectedly does nothing
rem
rem The above fails to do what you expect because SKIPCOPY is still set 
rem as a result of the first buildtools.  But the following will work
rem just fine:
rem      cmd/q
rem      set SKIPALL=1
rem      set DOMAKE=1
rem      buildtools       <- builds only make
rem      exit
rem      cmd/q
rem      set INSTALLONLY=1
rem      buildtools       <- just does the final copy

setlocal
setlocal enableextensions
setlocal enabledelayedexpansion
set BUILDSYSTYPE=%1
set ORIGPATH=%PATH%
set ERRORLEVEL=
set CMDEXTVERSION=

rem if the SPEC variable is set, and it points to something that looks
rem reasonable, then use that, otherwise fall through
if "%SPEC%."=="." goto SPEC_env_not_defined
if not defined SPEC goto SPEC_env_not_defined
if exist %SPEC%\bin\harness\runcpu goto SPEC_env_defined
:SPEC_env_not_defined

rem Change to tools\src and set SPEC appropriately
cd %~dp0
pushd ..\..
set SPEC=%CD%
popd
echo SPEC set to %SPEC%
:SPEC_env_defined

set /P SUITEVER=<%~dp0..\..\bin\version.txt

if defined CLEANONLY (
  set SKIPALL=1
  set DOCLEAN=1
  goto doitanyway
)

if "%BUILDSYSTYPE%." == "x86." (
  set BUILDBITS=32
  set MINGW=%MINGW32%
  goto systypeok
)
if "%BUILDSYSTYPE%." == "x64." (
  set BUILDBITS=64
  set MINGW=%MINGW64%
  goto systypeok
)
echo Usage:
echo %0 x86 (for 32-bit)
echo or
echo %0 x64 (for 64-bit)
goto :EOF
:systypeok

if not defined MINGW (
  echo.
  echo The location of the MinGW-W64 %BUILDBITS%-bit GCC compiler is not set.  Please
  echo set MINGW%BUILDBITS% to the base install location of the compiler.
  echo.
  goto :EOF
)

if not exist %MINGW%\bin\gcc.exe (
  echo.
  echo The location of the MinGW-W64 %BUILDBITS%-bit GCC compiler is set, but there
  echo is no gcc executable in %MINGW%\bin.  Please set MINGW%BUILDBITS% to
  echo the base install location of the compiler.
  echo.
  goto :EOF
)

if not "%2." == "doit." (
  set LOGFILE=%~dp0windows-!BUILDSYSTYPE!-!SUITEVER!.buildlog.txt
  if exist !LOGFILE!.cur del /f /q !LOGFILE!
  echo Starting build of Windows !BUILDSYSTYPE! tools
  echo.
  echo Build log is in !LOGFILE!
  echo.
  echo A powershell window has been opened to monitor progress, but it
  echo does not do a good job of keeping up.  Output comes only in large
  echo chunks.  If you have MSYS installed, you will get more satisfaction
  echo from running something like
  echo tail -f !LOGFILE!
  echo.
  echo You may close the powershell window at any time without affecting
  echo the tools build.  The window will NOT be automatically closed when
  echo the build has finished.
  echo.
  echo Starting build of Windows !BUILDSYSTYPE! tools > !LOGFILE!
  start /max powershell -Sta -Command "& {Get-Content !LOGFILE! -wait}"
  cmd /c "%0" %BUILDSYSTYPE% doit >> !LOGFILE! 2>&1 <NUL:
  echo Build of Windows !BUILDSYSTYPE! tools completed.
  echo.
  echo Please examine the build log to look for Perl test errors.  If any
  echo are found that should not preclude usage of the toolset to run the
  echo benchmark harness, make a note at the top of the build log explaining
  echo the failures.
  echo.
  findstr /C:Failed: !LOGFILE!
  copy !LOGFILE! %SPEC%
  goto :EOF
)
:doitanyway

if defined MINGW set PATH=%MINGW%\bin;%PATH%

if defined INSTALLONLY (
  set SKIPCLEAN=1
  set SKIPNONPERL=1
  set SKIPPERL=1
  set SKIPPERL2=1
  set SKIPPACKAGE=1
)
if defined SKIPALL (
  set SKIPTOOLSRM=1
  set SKIPCLEAN=1
  set SKIPNONPERL=1
  set SKIPPERL=1
  set SKIPPERL2=1
  set SKIPCOPY=1
  set SKIPPACKAGE=1
)

set perlroot=c:\specperl-%SUITEVER%

set PATH=%PATH%;%perlroot%\bin

rem Clear out the Perl library path hints
set SPECPERLLIB=
set PERLLIB=

rem There's no need for a bunch of warnings if all that's going to happen
rem is a good cleaning.
if defined CLEANONLY goto nobuildbanner
if defined DOMAKE goto buildbanner
if defined DOXZ goto buildbanner
if defined DOTAR goto buildbanner
if defined DOSUM goto buildbanner
if defined DOSPECINVOKE goto buildbanner
if defined DORXP goto buildbanner
if defined DOZSH goto buildbanner
if defined DOEXPAT goto buildbanner
if defined DOPERL goto buildbanner
if defined DOPERL2 goto buildbanner
if defined DOCOPY goto buildbanner
if defined DOPACKAGE goto buildbanner
if defined DOCLEAN goto nobuildbanner

if defined SKIPMAKE goto nobuildbanner
if defined SKIPXZ goto nobuildbanner
if defined SKIPTAR goto nobuildbanner
if defined SKIPSUM goto nobuildbanner
if defined SKIPSPECINVOKE goto nobuildbanner
if defined SKIPRXP goto nobuildbanner
if defined SKIPZSH goto nobuildbanner
if defined SKIPEXPAT goto nobuildbanner
if defined SKIPNONPERL goto nobuildbanner
if defined SKIPPERL goto nobuildbanner
if defined SKIPCOPY goto nobuildbanner
if defined SKIPPACKAGE goto nobuildbanner
if defined SKIPCLEAN goto buildbanner

:buildbanner
echo Tools build started on
hostname
echo at
date /t
echo by
whoami
echo Building on
ver
vol

echo.
echo ============================================================
echo buildtools.bat
echo.
echo This procedure will attempt to build the SPEC CPU2017 tools
echo for Windows.  Notably, it will remove the contents of the
echo directory %perlroot%.
echo ============================================================
echo.

echo .
echo Using MinGW compilers in %MINGW%\bin:
gcc --version
if errorlevel 1 (
  echo .
  echo Sorry, MinGW-W64 GCC is necessary to build the tools.  Get it from
  echo http://sourceforge.net/projects/mingw-w64/
  echo .
  goto end
)
echo MinGW-W64 binutils:
ld --version
if errorlevel 1 (
  echo .
  echo Sorry, MinGW-W64 binutils is necessary to build the tools.  Get them from
  echo http://sourceforge.net/projects/mingw-w64/
  echo .
  goto end
)
echo .
:nobuildbanner

rem Being able to debug is more important that prettiness
rem echo on
rem ...but only sometimes (the informationals get harder to read)
@if not defined SPEC_BATCH_DEBUG echo off

if defined DOTOOLSRM goto toolsrm
if defined SKIPTOOLSRM goto notoolsinst
:toolsrm
if exist %SPEC%\bin\specperl.exe goto toolsinst
if exist %SPEC%\SUMS.tools goto toolsinst
if exist %SPEC%\bin\lib goto toolsinst
goto notoolsinst
:toolsinst
echo Removing previous tools installation...
rem The one-line equivalent under Unix turns into this hack to write a batch
rem file and then call it.  At least we can build the batch file using Perl...
if not exist %SPEC%\bin\specperl.exe goto noperl
if not exist %temp%\toolsdel.bat goto no_del_toolsdel
del /F /Q %temp%\toolsdel.bat
:no_del_toolsdel
%SPEC%\bin\specperl -ne "@f=split; next unless m#bin/#; $_=$f[3]; s#^#$ENV{SPEC}/#; s#\\#/#g; if (-f $_) { unlink $_; } elsif (-d $_) { s#/#\\#g; print """rmdir /Q /S $_\n"""; }" %SPEC%\SUMS.tools > %temp%\toolsdel.bat
call %temp%\toolsdel.bat
del /F /Q %temp%\toolsdel.bat
rem Now fall through in case some things were missed by toolsdel.bat
rem goto tools_rm_done
:noperl
rem Okay, _some_ of the tools files are present, but evidently specperl is
rem missing.  So make a best effort (it'll probably be good enough) and go
rem on.
rmdir /Q /S %SPEC%\bin\lib
del   /Q /F %SPEC%\bin\*.exe
del   /Q /F %SPEC%\bin\*.dll
del   /Q /F %SPEC%\bin\MANIFEST.pl
del   /Q /F %SPEC%\SUMS.tools
del   /Q /F %SPEC%\packagename
:tools_rm_done
echo Finished removing old tools install
:notoolsinst

rem We need GNU make (probably mingw32-make)
if defined BT_MAKE (
    where %BT_MAKE% 2>NUL:
    if not errorlevel 1 (
      goto found_a_make
    )
)
where mingw32-make 2>NUL:
if not errorlevel 1 (
  set BT_MAKE=mingw32-make
  goto found_a_make
)
echo.
echo Could not find GNU make.  Set BT_MAKE to the path of a copy.
echo.
goto :EOF

:found_a_make

if defined DOCLEAN goto clean
if defined SKIPCLEAN goto skipclean
:clean
setlocal
echo ================================================================
echo === Removing remnants of previous builds                     ===
echo ================================================================
echo === This will cause a lot of errors, don't worry about them! ===
echo ================================================================
rem SPECPERLLIB needs to be set because all of the Perl module makefiles
rem use Perl versions of Unix commands to do cleaning.  Sheesh.
set SPECPERLLIB=%perlroot%;%perlroot%\lib;%perlroot%\site\lib

rem Clean Perl modules
FOR /D %%M in (IO-string* TimeDate-* MailTools-* MIME-tools* PDF-API2-* URI-* Text-CSV_XS* HTML-Tagset-* HTML-Parser-* Font-AFM-* File-NFSLock-* Algorithm-Diff-* XML-NamespaceSupport-* XML-SAX-0*\XML-SAX-Base XML-SAX-0* String-ShellQuote-*) DO CALL :gnu_clean_tree %%M makefile.mk

pushd perl-*
if exist perl.exe CALL win32\distclean.bat
pushd win32
%BT_MAKE% distclean 2>NUL:
popd
rem Get rid of leftover dirs that distclean won't touch
FOR /R %%I in (.) DO RMDIR /S /Q %%I\blib 2>NUL:
rmdir /S /Q ext\B\lib
rmdir /S /Q lib\App
rmdir /S /Q lib\Archive
rmdir /S /Q lib\Attribute
rmdir /S /Q lib\CORE
rmdir /S /Q lib\CPAN
rmdir /S /Q lib\Carp
rmdir /S /Q lib\Compress
rmdir /S /Q lib\Config\Perl
rmdir /S /Q lib\Data
rmdir /S /Q lib\Devel
rmdir /S /Q lib\Digest
rmdir /S /Q lib\Encode
rmdir /S /Q lib\Exporter
rmdir /S /Q lib\ExtUtils\CBuilder
rmdir /S /Q lib\ExtUtils\Command
rmdir /S /Q lib\ExtUtils\Constant
rmdir /S /Q lib\ExtUtils\Liblist
rmdir /S /Q lib\ExtUtils\MakeMaker
rmdir /S /Q lib\ExtUtils\ParseXS
rmdir /S /Q lib\ExtUtils\Typemaps
rmdir /S /Q lib\File\Spec
rmdir /S /Q lib\Filter
rmdir /S /Q lib\HTTP
rmdir /S /Q lib\Hash
rmdir /S /Q lib\I18N
rmdir /S /Q lib\IO
rmdir /S /Q lib\IPC
rmdir /S /Q lib\JSON
rmdir /S /Q lib\List
rmdir /S /Q lib\Locale
rmdir /S /Q lib\MIME
rmdir /S /Q lib\Math
rmdir /S /Q lib\Memoize
rmdir /S /Q lib\Module
rmdir /S /Q lib\Net\FTP
rmdir /S /Q lib\Params
rmdir /S /Q lib\Parse
rmdir /S /Q lib\Perl
rmdir /S /Q lib\PerlIO
rmdir /S /Q lib\Pod\Perldoc
rmdir /S /Q lib\Pod\Simple
rmdir /S /Q lib\Pod\Text
rmdir /S /Q lib\Scalar
rmdir /S /Q lib\Search
rmdir /S /Q lib\Sub
rmdir /S /Q lib\Sys
rmdir /S /Q lib\TAP
rmdir /S /Q lib\Term
rmdir /S /Q lib\Test
rmdir /S /Q lib\Text
rmdir /S /Q lib\Thread
rmdir /S /Q lib\Tie\Hash
rmdir /S /Q lib\Unicode\Collate
rmdir /S /Q lib\Win32API
rmdir /S /Q lib\XS
rmdir /S /Q lib\auto
rmdir /S /Q lib\autodie
rmdir /S /Q lib\encoding
rmdir /S /Q lib\threads
rmdir /S /Q lib\unicore\To
rmdir /S /Q lib\unicore\lib
rmdir /S /Q lib\version
rmdir /S /Q win32\html
rmdir /S /Q win32\mini
del /F /Q win32\specbuildconf.mk
popd

pushd IO-stringy*
del /q /f t\dummy-test-file 2>NUL:
popd

pushd XML-SAX-0*
rmdir /S /Q t\lib 2>NUL:
del /q /f XML-SAX-Base\pm_to_blib 2>NUL:
del /q /f XML-SAX-Base\Makefile 2>NUL:
popd

pushd XML-SAX-E*
rmdir /S /Q t\lib 2>NUL:
del /q /f lib\XML\SAX\ExpatXS\Preload.pm 2>NUL:
popd

pushd MIME-tools-*
del /q /f msg* 2>NUL:
popd

pushd List-MoreUtils-*
del /q /f config.log 2>NUL:
popd

pushd XSLoader-*
rmdir /S /Q lib 2>NUL:
popd

pushd MailTools-*
del /q /f *.ppd 2>NUL:
popd

pushd Text-CSV_XS-*
del /q /f *.csv 2>NUL:
popd

pushd libwww-perl*
del /Q /F t\CAN_TALK_TO_OURSELF 2>NUL:
del /Q /F t\test*html 2>NUL:
popd

pushd HTML-Parser*
del /q /f test*html 2>NUL:
popd

pushd File-NFSLock-*
del /q /f /s testfile* 2>NUL:
del *NFSLock.tmp* 2>NUL:
del File-NFSLock.spec 2>NUL:
popd

rem Get rid of previous specperl temp installation (if any)
if exist %perlroot% rmdir /S /Q %perlroot% 2>NUL:

rem Some of this stuff will only be around if the tree was used for a
rem non-Windows build
FOR /D %%P in (perl-* xz-* make-* tar-*) DO (
  pushd %%P
  FOR /R %%I in (.) DO RMDIR /S /Q %%I\WinRel %%I\WinDebug %%I\.deps 2>NUL:
  popd
)
del /Q /F windows*buildlog.txt
rmdir /S /Q *
del /S /Q /F config.cache Makefile.old autom4te.cache config.log config.status stamp-h1 POTFILES atconfig atlocal 2>NUL:
FOR /D %%D in (IO-string* MIME-tools*) DO (
  pushd %%D
  rmdir /S /Q testout 2>NUL:
  popd
)

FOR /D %%D in (*) DO CALL :clean_tree %%D
CALL :do_clean_tree ntzsh\Src Makefile
CALL :gnu_clean_tree tar-*\mingw Makefile
CALL :gnu_clean_tree expat-*\lib Makefile.MinGW
CALL :gnu_clean_tree expat-*\win32 Makefile
CALL :gnu_clean_tree xz* windows\GNUmakefile
CALL :gnu_clean_tree specinvoke*\win32 Makefile
CALL :gnu_clean_tree specsum*\win32 Makefile

pushd expat*
del /S /Q /F tests\*.o* 2>NUL:
del    /Q /F lib\expat_config.h 2>NUL:
popd

pushd make-*
CALL build_w32.bat clean
rmdir /S /Q tests\work 2>NUL:
del /S /Q /F build.sh 2>NUL:
popd

pushd tar*
cd rmt
del /F /Q rmt 2>NUL:
del /F /Q Makefile 2>NUL:
popd

pushd rxp*
del /F /Q stamp-h.in 2>NUL:
del /F /Q config.h 2>NUL:
popd

pushd xz*
del /F /Q compress_generated* 2>NUL:
del /F /Q tests\compress_generated* 2>NUL:
del /F /Q config.h 2>NUL:
popd

rem remove any tar_copy leftovers (should not be any)
del /F /Q %SPEC%\foo.tar

del /S /Q /F .gdb* 2>NUL:
rmdir /S /Q %perlroot% 2>NUL:
rem Remove the libs and include files in the output directory
rmdir /S /Q ..\output 2>NUL:

rem Just in case
cd %SPEC%\tools\src

rem Finally, anything else that might've been missed by poorly-written Makefiles
del /S /F /Q *.pdb 2>NUL:
del /S /F /Q *.exe 2>NUL:
del /S /F /Q *.ilk 2>NUL:
del /S /F /Q *.obj 2>NUL:
rem Can't do this because the filesystem isn't case-sensitive...
rem del /S /F /Q *.lib
del /S /F /Q *.idb 2>NUL:
del /S /F /Q *~ 2>NUL:
endlocal
if defined CLEANONLY goto end
:skipclean

mkdir ..\output
mkdir ..\output\bin
mkdir ..\output\lib
mkdir ..\output\include
pushd ..\output\bin
set PATH=%CD%;%PATH%
popd

if defined DOMAKE goto make
if defined SKIPNONPERL goto skipmake
if defined SKIPMAKE goto skipmake
:make
echo ============================================================
echo Building make
echo ============================================================
pushd make-*
CALL build_w32.bat gcc %BUILDSYSTYPE%
if exist GccRel\gnumake.exe goto makemakeok
echo make seems to have not been built.  Please examine the output to
echo this point and fix the problem.
goto end
:makemakeok
copy GccRel\gnumake.exe make.exe
strip make.exe
dir GccRel\gnumake.exe make.exe
copy make.exe ..\..\output\bin
popd
:skipmake

if defined DOXZ goto xz
if defined SKIPNONPERL goto skipxz
if defined SKIPXZ goto skipxz
:xz
echo ============================================================
echo Building xz
echo ============================================================
pushd xz*
..\..\output\bin\make -f windows\GNUmakefile clean BITS=%BUILDBITS%
..\..\output\bin\make -f windows\GNUmakefile BITS=%BUILDBITS%
if not exist xz.exe (
  echo .
  echo xz seems to have not been built.  Please examine the output to
  echo this point and fix the problem.
  goto end
)
strip xz.exe
..\..\output\bin\make -f windows\GNUmakefile check BITS=%BUILDBITS%
if errorlevel 1 (
  echo.
  echo There was an error running the XZ tests.  Please examine the
  echo output to this point and fix the problem.
  goto end
)
dir xz.exe
popd
:skipxz

if defined DOTAR goto tar
if defined SKIPNONPERL goto skiptar
if defined SKIPTAR goto skiptar
:tar
echo ============================================================
echo Building TAR
echo ============================================================
pushd tar*\windows
..\..\..\output\bin\make clean BITS=%BUILDBITS%
..\..\..\output\bin\make BITS=%BUILDBITS%
if exist tar.exe goto tarmakeok
echo tar seems to have not been built.  Please examine the output to
echo this point and fix the problem.
goto end
:tarmakeok
dir tar.exe
popd
:skiptar

if defined DOSUM goto sum
if defined SKIPNONPERL goto skipsum
if defined SKIPSUM goto skipsum
:sum
echo ============================================================
echo Building spec*sum
echo ============================================================
pushd specsum*\win32
..\..\..\output\bin\make clean BITS=%BUILDBITS%
..\..\..\output\bin\make BITS=%BUILDBITS%
if not exist specmd5sum.exe (
echo specmd5sum seems to have not been built.  Please examine the output to
echo this point and fix the problem.
goto end
)
if not exist specsha256sum.exe (
echo specsha256sum seems to have not been built.  Please examine the output to
echo this point and fix the problem.
goto end
)
if not exist specsha512sum.exe (
echo specsha512sum seems to have not been built.  Please examine the output to
echo this point and fix the problem.
goto end
)
dir spec*sum.exe
popd
:skipsum

if defined DOSPECINVOKE goto specinvoke
if defined SKIPNONPERL goto skipinvoke
if defined SKIPSPECINVOKE goto skipinvoke
:specinvoke
echo ============================================================
echo Building specinvoke
echo ============================================================
pushd specinvoke*\win32
..\..\..\output\bin\make clean BITS=%BUILDBITS%
..\..\..\output\bin\make BITS=%BUILDBITS%
if exist specinvoke.exe goto invokemakeok
echo specinvoke seems to have not been built.  Please examine the output to
echo this point and fix the problem.
goto end
:invokemakeok
dir specinvoke.exe
popd
:skipinvoke

if defined DORXP goto rxp
if defined SKIPNONPERL goto skiprxp
if defined SKIPRXP goto skiprxp
:rxp
echo ============================================================
echo Building rxp
echo ============================================================
pushd rxp*
..\..\output\bin\make -f Makefile.MinGW clean BITS=%BUILDBITS%
..\..\output\bin\make -f Makefile.MinGW BITS=%BUILDBITS%
if exist specrxp.exe goto rxpemakeok
echo rxp seems to have not been built.  Please examine the output to
echo this point and fix the problem.
goto end
:rxpemakeok
dir specrxp.exe
popd
:skiprxp

if defined DOZSH goto zsh
if defined SKIPNONPERL goto skipzsh
if defined SKIPZSH goto skipzsh
:zsh
echo ============================================================
echo Building zsh
echo ============================================================
pushd ntzsh\Src
if exist zsh.ex (
  echo Binary for ZSH already exists... skipping
  copy zsh.ex zsh.exe
  goto zshmakeok
)
rem Touch up the timestamps on all the *.pro files
for %%i in (*.pro) do CALL :touch_file %%i
nmake -nologo /f Makefile clean
nmake -nologo /f Makefile
if exist zsh.exe goto zshmakeok
echo zsh seems to have not been built.  At this time, it can only be built
echo with Visual C++.  If you have Visual C++ installed, please examine the
echo output to echo this point and fix the problem.
goto end
:zshmakeok
dir zsh.exe
popd
:skipzsh

if defined DOEXPAT goto expat
if defined SKIPNONPERL goto skipexpat
if defined SKIPEXPAT goto skipexpat
:expat
echo ============================================================
echo Building EXPAT
echo ============================================================
pushd expat*\win32
..\..\..\output\bin\make clean BITS=%BUILDBITS%
..\..\..\output\bin\make BITS=%BUILDBITS%
if exist libexpat.a goto expatmakeok
echo.
echo expat seems to have not been built.  Please examine the output to
echo this point and fix the problem.
goto end
:expatmakeok
copy libexpat.a ..\..\..\output\lib
copy ..\lib\expat*.h ..\..\..\output\include
popd
dir ..\output\lib\libexpat.a
:skipexpat

set SPECPERLLIB=%perlroot%;%perlroot%\lib;%perlroot%\site\lib;..\lib;lib
echo.
echo Set PATH to %PATH%
echo Set SPECPERLLIB to %SPECPERLLIB%
echo.

if defined DOPERL goto perl
if defined SKIPPERL goto skipperl
:perl
echo ============================================================
echo Building Perl
echo ============================================================
if not exist ..\output\bin\make.exe (
  echo .
  echo Building Perl requires specmake to already be built.
  echo .
  goto end
)
copy ..\output\bin\make.exe ..\output\bin\gmake.exe
pushd perl*\win32
rem Write the build config
if exist specbuildconf.mk del /f /q specbuildconf.mk
echo INST_TOP := %perlroot%> specbuildconf.mk
call :specbuildconf_d specbuildconf.mk INST_DRV %perlroot%
if %BUILDBITS% == 32 echo WIN64 := undef>> specbuildconf.mk
echo CCHOME := %MINGW%>> specbuildconf.mk
gmake clean
gmake
if errorlevel 1 (
  echo.
  echo There was an error building Perl.  Please examine the output to
  echo this point and fix the problem.
  goto end
)
gmake test
echo.
echo Installing Perl...
echo.
gmake install
if not exist %perlroot%\bin\perl.exe (
  echo.
  echo Perl seems to have been built but not successfully installed in
  echo %perlroot%
  echo Please examine the output to this point and fix the problem.
  goto end
)
popd
:skipperl

if defined DOPERL2 goto perl2
if defined SKIPPERL2 goto skipperl2
:perl2
set modbuilderror=
:skipperl2

if defined DOPERL2 goto modbuild
if defined SKIPPERL2 goto skipmod
:modbuild
set METRICS=%SPEC%\bin\fonts
FOR /D %%M in (SVG-* IO-stringy* TimeDate-* MailTools-* Test-Deep-* MIME-tools* IO-String-* Font-TTF-* PDF-API2-* Text-CSV_XS* URI-* XML-SAX-Base-* XML-NamespaceSupport-* XML-SAX-0* Algorithm-Diff-* Font-AFM-* File-NFSLock-* String-ShellQuote-* XSLoader-* Exporter-Tiny-* List-MoreUtils-*) DO (
  CALL :perlmod_build %%M
  if not "%modbuilderror%."=="." goto :EOF
)
if not "%modbuilderror%."=="." goto end

rem Do modules that take special parameters to Makefile.PL
CALL :perlmod_build XML-SAX-ExpatXS* "DEFINE=-DXML_STATIC" "EXPATINCPATH=..\..\output\include" "EXPATLIBPATH=..\..\output\lib"
if not "%modbuilderror%."=="." goto end
:skipmod

if defined DOCOPY goto docopy
if defined SKIPCOPY goto skipcopy
:docopy
echo.
echo ============================================================
echo Copying tools to specroot\bin
echo Please watch this section carefully, as errors here indicate
echo something that needs to be reviewed further back.
echo ============================================================
echo.

if defined SPEC goto sanitycd
goto setbin
:sanitycd
cd %SPEC%\tools\src

:setbin
set specbin=%SPEC%\bin
mkdir %specbin%
mkdir %specbin%\lib

pushd make-*
echo Copying make.exe to %specbin%\specmake.exe
copy make.exe %specbin%\specmake.exe
dir %specbin%\specmake.exe
popd

pushd tar*\windows
echo Copying tar.exe to %specbin%\spectar.exe
copy tar.exe %specbin%\spectar.exe
dir %specbin%\spectar.exe
popd

pushd ntzsh\Src
echo Copying zsh.exe to %specbin%\specsh.exe
copy zsh.exe %specbin%\specsh.exe
dir %specbin%\specsh.exe
popd

pushd specinvoke*\win32
echo Copying specinvoke.exe to %specbin%\specinvoke.exe
copy specinvoke.exe %specbin%\specinvoke.exe
dir %specbin%\specinvoke.exe
popd

pushd rxp*
echo Copying specrxp.exe to %specbin%\specrxp.exe
copy specrxp.exe %specbin%\specrxp.exe
dir %specbin%\specrxp.exe
popd

pushd specsum*\win32
echo Copying specmd5sum.exe to %specbin%\specmd5sum.exe
copy specmd5sum.exe %specbin%\specmd5sum.exe
dir %specbin%\specmd5sum.exe
echo Copying specsha256sum.exe to %specbin%\specsha256sum.exe
copy specsha256sum.exe %specbin%\specsha256sum.exe
dir %specbin%\specsha256sum.exe
echo Copying specsha512sum.exe to %specbin%\specsha512sum.exe
copy specsha512sum.exe %specbin%\specsha512sum.exe
dir %specbin%\specsha512sum.exe
popd

pushd xz*
echo Copying xz.exe to %specbin%\specxz.exe
copy xz.exe %specbin%\specxz.exe
dir %specbin%\specxz.exe
popd

echo Copying perl.exe and perl*.dll
copy %perlroot%\bin\perl.exe %specbin%\specperl.exe
copy %perlroot%\bin\*.dll %specbin%

dir %specbin%\specperl.exe %specbin%\*.dll

echo Copying perl libraries

CALL :tar_copy %perlroot%\lib %specbin%\lib
if not "%tarcopyerror%."=="." goto end
CALL :tar_copy %perlroot%\site\lib %specbin%\lib
if not "%tarcopyerror%."=="." goto end

if exist %specbin%\lib\XML\SAX\ParserDetails.ini goto xmlinipresent
echo Making XML parser config file
echo "# Nothing here" > %specbin%\lib\XML\SAX\ParserDetails.ini
dir %specbin%\lib\XML\SAX\*.ini
:xmlinipresent

echo Build complete and copied
:skipcopy

if defined DOPACKAGE goto dopackage
if defined SKIPPACKAGE goto skippackage
:dopackage
echo.
echo ============================================================
echo Packaging tools installation in %SPEC%\bin
echo ============================================================
echo.
if defined SPEC cd %SPEC%
set SHRC_PRECOMPILED=yes
set SPECPERLLIB=
set PATH=%ORIGPATH%
call shrc.bat
packagetools windows-%BUILDSYSTYPE%
:skippackage
goto end

rem --------------------------------------------------------------
rem Only functions below here
rem --------------------------------------------------------------

:tar_copy
call :tar_copy_impl %spec% %1 %2 %3 %4 %5 %6 %7 %8 %9
goto :EOF

:old_tar_copy
call :tar_copy_impl %temp% %1 %2 %3 %4 %5 %6 %7 %8 %9
goto :EOF

:tar_copy_impl
rem Copy a directory via intermediate tar file.  Ignores revision control dirs
set tarcopyerror=
set tardir=%1
if not exist %tardir% goto :EOF
shift
if not exist %1 goto :EOF
if exist %tardir%\foo.tar del /Q /F %tardir%\foo.tar
pushd %1
%specbin%\spectar -cf %tardir%\foo.tar --exclude .svn --exclude .git .
if errorlevel 1 (
  echo.
  echo Failed to make temporary tar file in %tardir%
  echo for copying %1 to %2
  echo.
  set tarcopyerror=1
  goto :EOF
)
if not exist %2 mkdir %2
cd %2
%specbin%\spectar -xvf %tardir%\foo.tar
if errorlevel 1 (
  echo.
  echo Failed to unpack temporary tar file in %tardir%
  echo for copying %1 to %2
  echo.
  set tarcopyerror=2
  goto :EOF
)
if exist %tardir%\foo.tar del /Q /F %tardir%\foo.tar
popd
set tarcopyerror=
goto :EOF

:clean_tree
rem Attempt to make clean, realclean, etc in the tree specified in %1
if not exist %1\win32\makefile.mk goto not_perl
rem This must be perl; it's special, and will be done later.
goto :EOF

:not_perl
FOR %%I in (NMakefile Makefile.nt makefile.msc Makefile) DO CALL :do_clean_tree %1 %%I
FOR %%I in (Makefile.MinGW Makefile GNUmakefile) DO CALL :gnu_clean_tree %1 %%I
cd %SPEC%\tools\src
goto :EOF

:do_clean_tree
rem echo on
rem This is what actually runs nmake
pushd %1
if not exist %2 goto nothing_to_clean
nmake -nologo /k /f %2 realclean
nmake -nologo /k /f %2 distclean
nmake -nologo /k /f %2 clean
:nothing_to_clean
popd
goto :EOF

:gnu_clean_tree
rem echo on
rem This is what actually runs %BT_MAKE% (GNU make)
pushd %1
if not exist %2 goto no_gnu_clean
%BT_MAKE% -k -f %2 realclean
%BT_MAKE% -k -f %2 distclean
%BT_MAKE% -k -f %2 clean
:no_gnu_clean
popd
goto :EOF

:touch_file
rem Fix up a file's timestamp
del /q /f foo_touch
type %1 > foo_touch
type foo_touch > %1
del /q /f foo_touch
goto :EOF

:perlmod_build
rem Clean, build, test, and install a Perl module in the specified directory
set modbuilderror=
set perlmoddir=%1
shift
pushd %perlmoddir%
echo ============================================================
echo Building Perl module in %CD%
echo ============================================================
%BT_MAKE% clean
rem The stupid enumeration is because %* still gives ALL args even after shift
echo perl Makefile.PL %1 %2 %3 %4 %5 %6 %7 %8 %9
perl Makefile.PL %1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 (
  echo .
  echo There was an error making Makefiles in %perlmoddir%.
  echo Please examine the output and correct the problem.
  echo .
  set modbuilderror=1
  goto :EOF
)
%BT_MAKE%
if errorlevel 1 (
  echo .
  echo There was an error building the Perl module in %perlmoddir%.
  echo Please examine the output and correct the problem.
  echo .
  set modbuilderror=2
  goto :EOF
)
if exist spec_do_no_tests goto skiptest
echo Testing Perl module in %CD%
%BT_MAKE% test
:skiptest
echo Installing Perl module from %CD%
%BT_MAKE% UNINST=1 install
if errorlevel 1 (
  echo .
  echo There was an error installing from %perlmoddir%.
  echo Please examine the output and correct the problem.
  echo .
  set modbuilderror=4
  goto :EOF
)
echo Build in %perlmoddir% was successful!
popd
goto :EOF

:specbuildconf_d
echo %2 := %~d3>> %1
goto :EOF

:end
if defined CLEANONLY goto :EOF
echo PATH was %PATH%
set PATH=%ORIGPATH%
set ORIGPATH=
echo PATH is now %PATH%
echo build log is in %LOGFILE%
echo buildtools %BUILDSYSTYPE% ended
