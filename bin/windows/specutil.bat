rem
rem specutil.bat - run SPEC Perl tools from Microsoft Windows Command Prompt
rem
rem  Copyright 2008-2016 Standard Performance Evaluation Corporation
rem
rem  Author: Diego Esteves
rem
rem $Id: specutil.bat 4425 2016-06-14 21:18:52Z CloyceS $
rem
rem ======================================================================
rem
rem %1   - Short path (subdir+name) of utility to run
rem %2-* - arguments to specified utility
rem
rem ======================================================================

rem
rem Don't do anything if nothing specified
rem
if %1. == . goto :EOF

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

rem
rem Let's run program
rem - do not run copy in current directory; run the copy relative to the
rem   parent of this script's directory, which should be %SPEC%\bin
rem

rem This gets us to %SPEC%\bin\windows
call :dirname "%~f0" _CPUBINDIR
rem ...and this gets us to %SPEC%\bin
call :dirname "%_CPUBINDIR%" _CPUBINDIR

if not exist %_CPUBINDIR%\specperl.exe (
  echo.
  echo ***ERROR***
  echo "specperl.exe is not in %_CPUBINDIR%; has the benchmark tree been installed?"
  exit /B 1
)

if not exist %_CPUBINDIR%\%1 (
  echo.
  echo ***ERROR***
  echo Program '%_CPUBINDIR%\%1' does not exist.
  exit /B 1
  goto :EOF
)

call :dirname "%_CPUBINDIR%\%1" _TOOLLIBDIR
if %_TOOLLIBDIR:~-5% == tools set _TOOLLIBDIR="%_CPUBINDIR%\harness"

rem
rem Set SPEC if it isn't already set
rem
if not defined SPEC call :dirname "%_CPUBINDIR%" SPEC

rem
rem Put %_CPUBINDIR% in the PATH if it isn't already
rem
rem Check for match in the middle
if "%PATH:*%_CPUBINDIR%;*=yes%" == "yes" (
    rem In PATH; nothing to do
) else (
    rem Check for match at the beginning
    if "%PATH:%_CPUBINDIR%;*=yes%" == "yes" (
        rem In PATH; nothing to do
    ) else (
        rem Check for match at the end with a trailing semicolon
        if "%PATH:*%_CPUBINDIR%;=yes%" == "yes" (
            rem In PATH; nothing to do
        ) else (
            rem Check for match at the end
            if "%PATH:*%_CPUBINDIR%=yes%" == "yes" (
                rem In PATH; nothing to do
            ) else (
                call :stripquotes "%_CPUBINDIR%;%PATH%" PATH
            )
        )
    )
)

specperl -I%_CPUBINDIR%\common -I%_TOOLLIBDIR% -I%_CPUBINDIR% -I%_CPUBINDIR%\lib %_CPUBINDIR%\%*
exit /B %ERRORLEVEL%
goto :EOF

:dirname
  set _dir=%~dp1
  set _dir=%_dir:~0,-1%
  set %2=%_dir%
goto :EOF

:stripquotes
  set _tmp=%~1
  set %2=%_tmp%
goto :EOF

rem Editor settings: (please leave this at the end of the file)
rem vim: set filetype=dosbatch syntax=dosbatch shiftwidth=4 tabstop=8 expandtab nosmarttab:
