@echo off
setlocal
set DEBUG=0
if "%DEBUG%"=="1" (set TRACE=echo) else (set TRACE=rem)
set Me.Tempfile=%Temp%\~%~n0%random%.tmp

rem call :_BATCH_MAIN %1
rem goto _end

:_BATCH_MAIN
set ipv6supported=false
wmic os where primary=true get version /value | find "=" >%Me.Tempfile% && (
	for /f "tokens=2,3,4 delims=.=" %%a in (%Me.Tempfile%) do (
		if %%a geq 6 set ipv6supported=true
		if %%a equ 5 if %%b geq 2 set ipv6supported=true
	)
)
set ipv=%1
if not defined ipv set ipv=v4
call :_Get_IP_by_wmic_nicconifg ipaddr %ipv%
if defined ipaddr echo %ipaddr%
rem exit /b %errorlevel%
goto _end

:_Get_IP_by_wmic_nicconifg
wmic nicconfig where ipenabled=true get ipaddress /value | find "=">%Me.Tempfile% && (
	for /f "tokens=2,3 delims={,=} " %%a in (%Me.Tempfile%) do (
		if not "%1"=="" (
			if /i "%2"=="v4" (
				set %1=%%~a
			) else if /i "%2"=="v6" (
				if %ipv6supported%==true set %1=%%~b
			)
		)
	)
)

exit /b %errorlevel%

:_end
set exitCode=%errorlevel%
if exist %Me.Tempfile% del /f /q %Me.Tempfile%
exit /b %exitCode%