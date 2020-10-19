@echo off

rem Tests for xz.exe on Windows
rem Adapted from tests/test_files.sh and tests/test_command.sh

for %%I in (tests\files\good-*.xz) do call :expect_success %%I -dc

for %%I in (tests\files\bad-*.xz) do call :expect_failure %%I -dc

set XZARGS="--memlimit-compress=128MiB" "--memlimit-decompress=5MiB" --no-adjust "--threads=1" "--check=crc64"

tests\create_compress_files
if errorlevel 1 (
	del /q /f compress_*
	echo "Failed to create files to test compression."
	exit \b 1
)

rem Remove temporary now (in case they are something weird)
del /q /f tmp_compressed tmp_uncompressed

rem Compress and decompress each file with various filter configurations.
rem This takes quite a bit of time.
for %%I in (compress_generated_* tests\compress_prepared_*) do (
	call :test_xz %%I %XZARGS%
	call :test_xz %%I %XZARGS% -1
	call :test_xz %%I %XZARGS% -2
	call :test_xz %%I %XZARGS% -3
	call :test_xz %%I %XZARGS% -4

	for %%A in ("--delta=dist=1" "--delta=dist=4" "--delta=dist=256" --x86 --powerpc --ia64 --arm --armthumb --sparc) do (
		call :test_xz %%I %%A "--lzma2=dict=64KiB,nice=32,mode=fast"
	)
)

rem Remove temporaries again
del /q /f tmp_compressed tmp_uncompressed

goto :EOF

:expect_success
	set _srcfile=%1
	shift
	rem Repetition because shift doesn't affect %*
	.\xz %0 %1 %2 %3 %4 %5 %6 %7 %8 %9 %_srcfile% >NUL:
	if errorlevel 1 (
		echo FAIL: %_srcfile%
		exit \b 1
	) else (
		echo PASS: %_srcfile%
	)
goto :EOF

:expect_failure
	set _srcfile=%1
	shift
	rem Repetition because shift doesn't affect %*
	.\xz %0 %1 %2 %3 %4 %5 %6 %7 %8 %9 %_srcfile% >NUL: 2>&1
	if not errorlevel 1 (
		echo FAIL: %_srcfile%
		exit \b 1
	) else (
		echo PASS: %_srcfile%
	)
goto :EOF

:test_xz
	set _FILE=%1
	shift
	rem Repetition because shift doesn't affect %*
	.\xz -c %1 %2 %3 %4 %5 %6 %7 %8 %9 %_FILE% > tmp_compressed
	if errorlevel 1 (
		echo Compressing failed: %*
		goto :bad_exit
	)

	.\xz -dc tmp_compressed > tmp_uncompressed
	if errorlevel 1 (
		echo Decompressing failed: %*
		goto :bad_exit
	)

	fc /B tmp_uncompressed %_FILE% >NUL: 2>&1
	if errorlevel 1 (
		echo Decompressed file does not match the original: %*
		goto :bad_exit
	)

	echo PASS: %1 %2 %3 %4 %5 %6 %7 %8 %9 %_FILE%
goto :EOF

:bad_exit
rem Remove temporaries again
del /q /f tmp_compressed tmp_uncompressed
exit /b 1
goto :EOF

