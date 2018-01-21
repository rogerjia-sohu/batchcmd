@echo off
setlocal EnableDelayedExpansion
:CmArg.Init
set argc=0
:_nextarg
if "%~1"=="" goto CmArgInit_End
set /a argc=!argc!+1
set argv%argc%=%1&&rem %
shift /1
goto _nextarg
:CmArgInit_End

goto :_BATCH_MAIN

:CmArg.Print
echo --- argc : %argc%
for /l %%a in (1,1,%argc%) do (
	echo [%%a] = ^(!argv%%a!^)
)
echo ---
exit /b 0

:CmArg.GetValue
set _getvalue=1
:CmArg.IsInput
rem call :CmArg.IsInput -file && echo OK || echo NG
set _unmatch=1
for /l %%a in (1,1,%argc%) do (
	if "!_getnextval!" equ 1 echo !argv%%a!
	if "!argv%%a!"=="%~1" set _unmatch=0&& if "!_getval!" equ 1 set _getnextval=1 
)
exit /b %_unmatch%

:_BATCH_MAIN
call :CmArg.Print
call :CmArg.GetValue -a
goto :EOF
