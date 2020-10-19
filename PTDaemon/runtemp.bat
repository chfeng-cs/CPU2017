:: Windows batch file to run PTD in temperature mode

:: Copyright 2006-2019 Standard Performance Evaluation Corporation (SPEC)
:: $Revision: 1644 $

:: See the Hardware Setup Guide for advanced configurations including GPIB usage

@echo off
echo.

::
:: NOTE: make sure your sensor is located per Run and Reporting Rules
::  "temperature must be measured no more than 50mm in front of (upwind of)
::     the main airflow inlet of the SUT"
::

echo NOTE: make sure your sensor is located per Run and Reporting Rules
echo "temperature must be measured no more than 50mm in front of (upwind of)
echo  the main airflow inlet of the SUT"
echo.

:: Use a full path name for the ptd executable if it is not in the current directory
set PTD=binaries\ptd-windows-x86.exe

:: Set NETWORK_PORT if needed.  8889 is the default used for the temperature
:: sensor by CCS and SERT
set NETWORK_PORT=8889

:: Set DEVICE to the sensor device you will use (1000=dummy temp sensor)
::  use the numeric value found in the help output of the ptd executable
set DEVICE=1000

:: Set DEVICE_PORT to the serial port you will connect your sensor to
set DEVICE_PORT=COM1

:: To enable logging of measurement data, set the LOGFILE variable to the name
:: of the file in which you'd like the CSV data to be stored.  The default is to log
:: data to ptd-power.log and other information and exceptions to ptd-power.log.debug.
:: no log.
set LOGFILE=%SPEC%\ptd-power.log

:: To log measurement data and important events like range settings, warnings,
:: and errors to the LOGFILE set above, change the setting below to TRUE
set EXTLOG=TRUE

set LOGGING=
IF NOT "%LOGFILE%"=="" (
	IF /I "%EXTLOG%"=="TRUE" (
		set LOGGING=-l %LOGFILE% -d %LOGFILE%.debug -e
	) ELSE (
		set LOGGING=-l %LOGFILE% -d %LOGFILE%.debug
       )
)

:: Start PTDaemon
echo In another window, watch %LOGFILE% and %LOGFILE%.debug to see what PTD is doing
%PTD% -t %LOGGING% -p %NETWORK_PORT% %DEVICE% %DEVICE_PORT%
