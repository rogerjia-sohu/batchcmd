@echo off
setlocal
set L_DEBUG=0
set Me=%~nx0
set Me.Name=%~n0
set Me.Ext=%~x0
set Me.StdOut=NUL
if "%L_DEBUG%"=="1" set Me.StdOut=CON
set Me.Path=%~dps0
set Me.Tempfile=%Temp%\~%~ns0_t%random%.tmp
set Me.Scriptfile=%Temp%\~%~ns0_s%random%.tmp
echo %0 | find ":" >nul && (set ShellType=GUI) || (set ShellType=CONSOLE)
chcp | find "936" >%Me.StdOut% && set langid=936 || set langid=437

if "%1"=="" goto _usage
if "%1"=="/?" goto _usage
if "%1"=="-?" goto _usage
if /i "%1"=="/h" goto _usage
if /i "%1"=="-h" goto _usage
if /i "%1"=="/help" goto _usage
if /i "%1"=="-help" goto _usage
if /i "%1"=="--help" goto _usage


rem Search for drive list
rem set drvlist=
rem fsutil fsinfo drives>%Me.Tempfile%
rem for /f "tokens=1* delims=\ " %%d in (%Me.Tempfile%) do set drvlist=%%e
rem set drvlist=%drvlist:\=%
rem echo Drive List=[%drvlist%]

rem Test drive letter or volume pathname
set drv=%1
set drvpath=%drv\%
fsutil fsinfo volumeinfo %drvpath%>%Me.StdOut% && set drvready=true
if not defined drvready goto _drv_err

rem Build DiskPart Script
echo select volume=%drv%>%Me.Scriptfile%
echo remove all dismount>>%Me.Scriptfile%

rem Invoke DiskPart
diskpart /s %Me.Scriptfile% | find /v /i "microsoft"
goto _end

:_usage
goto _usage_%langid%
:_usage_936
set msg1=删除驱动器号或装入点分配。
set msg2=用法: %Me.Name% {驱动器号: ^^^| 装载点}
goto _show_usage
:_usage_437
set msg1=Remove a drive letter or mount point assignment.
set msg2=Usage: %Me% {drive_letter: ^^^| mount_point}
goto _show_usage
:_show_usage
if defined msg1 (echo %msg1% && set msg1=)
if defined msg2 (echo %msg2% && set msg2=)
goto _end

:_drv_err
goto _drv_err_%langid%
:_drv_err_936
set msg1=错误:  系统找不到指定的路径。[%drv%]
goto _show_drv_err
:_drv_err_437
set msg1=Error:  The system cannot find the path specified. [%drv%]
goto _show_drv_err
:_show_drv_err
if defined msg1 (echo %msg1% && set msg1=)
if defined msg2 (echo %msg2% && set msg2=)
goto _end


:_end
if "%ShellType%"=="GUI" pause
if exist %Me.Tempfile% del /f /q %Me.Tempfile%
if exist %Me.Scriptfile% del /f /q %Me.Scriptfile%
endlocal