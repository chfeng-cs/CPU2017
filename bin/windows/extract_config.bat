@if not defined SPEC_BATCH_DEBUG echo off
rem
rem extract_config.bat
rem
rem Copyright 2007-2016 Standard Performance Evaluation Corporation
rem
rem $Id: extract_config.bat 4425 2016-06-14 21:18:52Z CloyceS $
rem

specutil tools\extract_config %*

rem Editor settings: (please leave this at the end of the file)
rem vim: set filetype=dosbatch syntax=dosbatch shiftwidth=4 tabstop=8 expandtab nosmarttab:
