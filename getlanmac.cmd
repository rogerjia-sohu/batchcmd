@echo off
setlocal
set Me=%~n0
if "%1"=="" call :_usage&& goto :EOF
set targetname=%~1
for /f "tokens=2 delims=[]" %%a in ('ping -n 1 -4 %targetname% ^| find /i "%targetname%"') do (
	for /f "tokens=2 delims=	 " %%m in ('arp -a ^| find "%%a" ^| find /v /i "---"') do echo %targetname%: %%m
)
goto :EOF
:_usage
echo Usage:	%Me% targetname