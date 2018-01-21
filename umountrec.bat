@echo off
setlocal
set L_DEBUG=0
set Me=%~nxs0
set Me.StdOut=NUL
if "%L_DEBUG%"=="1" set Me.StdOut=CON
set Me.Path=%~dps0
set Me.Tempfile=%Temp%\~LR%random%.tmp
echo %0 | find ":" >nul && (set ShellType=GUI) || (set ShellType=CONSOLE)
chcp | find "936" >%Me.StdOut% && set langid=936 || set langid=437

rem Search for drive list
set drvlist=
wmic logicaldisk where drivetype=3 get deviceid | find ":" >%Me.Tempfile% && set drvlist=%Me.Tempfile%
if defined drvlist (
	for /f %%d in (%drvlist%) do (
		if exist %%d\WindowsImageBackup\%computername%\MediaId call umount %%d
	)
)
goto _end

:_end
if "%ShellType%"=="GUI" pause
if exist %Me.Tempfile% del /f /q %Me.Tempfile%
endlocal