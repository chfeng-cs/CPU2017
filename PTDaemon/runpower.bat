:: Windows batch file to run PTD in power mode

:: Copyright 2006-2019 Standard Performance Evaluation Corporation (SPEC)
:: $Revision: 1644 $

:: See the Hardware Setup Guide for advanced configurations including GPIB usage

@echo off
echo.

:: Use a full path name for the ptd executable if it is not in the current directory
set PTD=binaries\ptd-windows-x86.exe

:: Set NETWORK_PORT if needed.  8888 is the default used for the power device
:: by CCS and SERT
set NETWORK_PORT=8888

:: Set DEVICE to the power analyzer device you will use (0=dummy device)
::  use the numeric value found in the help output of the ptd executable
set DEVICE=0

:: Set channel number for multichannel analyzers operating in single channel mode
::  Default = 0
set CHANNELNO=

:: DEVICE_PORT describes the physical address of the connection to the analyzer
:: If using an RS-232 interface, set to the serial port you will connect your power analyzer to
:: If using Yokogawa TMCTL, set to the IP address or device serial number
:: If using a GPIB adapter, set to the GPIB device number
:: If using a TCP/IP interface, set this to the IP address of the analyzer
set DEVICE_PORT=COM1

:: To enable logging of measurement data, set the LOGFILE variable to the name
:: of the file in which you'd like the CSV data to be stored.  The default is to log
:: data to ptd-power.log and other information and exceptions to ptd-power.log.debug.
:: no log.
set LOGFILE=%SPEC%\ptd-power.log

:: To log measurement data and important events like range settings, warnings,
:: and errors to the LOGFILE set above, change the setting below to TRUE
set EXTLOG=TRUE

:: set to TRUE if you are using a Yokogawa analyzer with USB or network 
:: interface with Yokogawa's TMCTL library. Device port above will
:: be used as device serial number (USB) or network address
set IS_YOKO_DEVICE=FALSE

:: set to TRUE if you are using a GPIB interface. Device port above will
:: be used as GPIB device #
set IS_GPIB_DEVICE=FALSE

:: set to TRUE if you are using a TCP/IP interface. Device port above will
:: be used as the network (IP) address
set IS_TCPIP_DEVICE=FALSE

:: Code below this line normally should not be changed

set INTERFACE_FLAG=
IF /I "%IS_GPIB_DEVICE%"=="TRUE" set INTERFACE_FLAG=-g
IF /I "%IS_YOKO_DEVICE%"=="TRUE" set INTERFACE_FLAG=-y
IF /I "%IS_TCPIP_DEVICE%"=="TRUE" set INTERFACE_FLAG=-n

set LOGGING=
IF NOT "%LOGFILE%"=="" (
	IF /I "%EXTLOG%"=="TRUE" (
		set LOGGING=-l %LOGFILE% -d %LOGFILE%.debug -e
	) ELSE (
		set LOGGING=-l %LOGFILE% -d %LOGFILE%.debug
       )
)

set CHANNEL=
IF NOT "%CHANNELNO%"=="" (
		set CHANNEL=-c %CHANNELNO%
)

:: Start PTDaemon
echo In another window, watch %LOGFILE% and %LOGFILE%.debug to see what PTD is doing
%PTD% %LOGGING% %CHANNEL% -p %NETWORK_PORT% %INTERFACE_FLAG% %DEVICE% %DEVICE_PORT%
