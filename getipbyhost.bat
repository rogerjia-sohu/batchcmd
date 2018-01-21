@echo off
setlocal enabledelayedexpansion
set DEBUG=0
if "%DEBUG%"=="1" (set TRACE=echo) else (set TRACE=rem)
set Me.Tempfile=%Temp%\~%~n0%random%.tmp
set Me.Tempfile2=%Temp%\~%~n0%random%.tmp

set hostname=%~1
if /i "%hostname%"=="" set hostname=%LOGONSERVER%
if /i "%hostname%"=="localhost" set hostname=%LOGONSERVER%

call :_BATCH_MAIN "%hostname%"
goto _end 

:_BATCH_MAIN
call :_get_host_names %1
exit /b %errorlevel%

:_get_host_names
set hostname=%~1
if /i "%hostname%"=="all" (
	net view | find "\\" >%Me.Tempfile%
	echo IPAddress	Server ^(Remark^)
	echo ---------------------------------------
) else (
	net view | find /i "%~1">%Me.Tempfile%
)


set cnt=0
for /f "tokens=1,2,3 delims=\ " %%a in (%Me.Tempfile%) do (
	ping -n 1 -w 200 %%~a -4| find /i "[" > %Me.Tempfile2% && (
		for /f "tokens=2 delims=[]" %%x in (%Me.Tempfile2%) do (
			if /i "%hostname%"=="all" (
				if "%%b"=="" (
					echo %%~x	\\%%a
				) else (
					echo %%~x	\\%%a ^(%%b%%c^)
				)
				set /a cnt+=1
			) else (
				echo %%~x
			)
		)
	)
)
if /i "%hostname%"=="all" (
	echo ---------------------------------------
	if defined cnt echo Total ^(%cnt%^) addresses retrieved.
)
exit /b %errorlevel%

:_end
set exitCode=%errorlevel%
if exist %Me.Tempfile% del /f /q %Me.Tempfile%
if exist %Me.Tempfile2% del /f /q %Me.Tempfile2%
exit /b %exitCode%