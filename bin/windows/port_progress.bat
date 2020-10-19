@if not defined SPEC_BATCH_DEBUG echo off
rem
rem port_progress.bat
rem
rem Copyright 2008-2016 Standard Performance Evaluation Corporation
rem
rem $Id: port_progress.bat 4425 2016-06-14 21:18:52Z CloyceS $
rem

setlocal

set list_files=

FOR %%D IN (%*) DO call :GET_LIST %%D

specutil tools\port_progress %list_files%

:GET_LIST
   set list_files=%list_files% %1

rem Editor settings: (please leave this at the end of the file)
rem vim: set filetype=dosbatch syntax=dosbatch shiftwidth=4 tabstop=8 expandtab nosmarttab:
