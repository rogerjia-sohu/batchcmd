@echo off
setlocal ENABLEDELAYEDEXPANSION
set L_DEBUG=0
if %L_DEBUG% equ 0 (set TRACE=rem) else (set TRACE=echo)
set Me=%~nx0
set Me.Name=%~n0
set Me.Ext=%~x0
set Me.StdOut=NUL
if "%L_DEBUG%"=="1" set Me.StdOut=CON
set Me.Path=%~dps0
set Me.Scriptfile=%Temp%\~%~n0.script%random%.tmp
set Me.Tempfile=%Temp%\~%~n0.temp%random%.tmp

echo %0 | find ":" >nul && (set ShellType=GUI) || (set ShellType=CONSOLE)
chcp | find "936" >%Me.StdOut% && set langid=936 || set langid=437

if "%1"=="" goto _show_all
if "%1"=="/?" goto _usage
if "%1"=="-?" goto _usage
if "%1"=="?" goto _usage
if /i "%1"=="/h" goto _usage
if /i "%1"=="-h" goto _usage
if /i "%1"=="/help" goto _usage
if /i "%1"=="-help" goto _usage
if /i "%1"=="--help" goto _usage

rem Search for drive list
rem set drvlist=
rem fsutil fsinfo drives>%Me.Tempfile%
rem for /f "tokens=1* delims=\ " %%d in (%Me.Tempfile%) do set drvlist=%%e
rem echo Drive List=[%drvlist%]

rem Test drive letter or volume pathname
rem set drv=%1
rem set drvpath=%drv\%
rem fsutil fsinfo volumeinfo %drvpath%>%Me.StdOut% && set drvready=true
rem if not defined drvready goto _drv_err


rem Build DiskPart Script
rem echo select volume=%drv%>%Me.Tempfile%
rem echo remove all dismount>>%Me.Tempfile%

rem Invoke DiskPart
rem diskpart /s %Me.Tempfile%

set vol=%~1
set vol=%vol:volume=%
if not defined vol goto _no_vol
set vol=%vol:"=%
for /f "delims=0123456789" %%i in ("%vol%") do (
	set volnum=%%i
	if defined volnum goto _volnum_err
)
%TRACE% vol=%vol%
set mnt=%~2
%TRACE% mnt=%mnt%
if defined mnt fsutil fsinfo volumeinfo "%mnt%">nul && goto _mnt_point_exist
%TRACE% echo select volume=%vol%
echo select volume=%vol% >%Me.Scriptfile%
if defined mnt (
	%TRACE% assign mount=%mnt%
	echo assign mount=%mnt% >>%Me.Scriptfile%
) else (
	%TRACE% assign
	echo assign >>%Me.Scriptfile%
)
diskpart /s %Me.Scriptfile% | find /v /i "microsoft"
set ret=%errorlevel%
goto _end

:_show_all
:_show_all_stage1
goto _disk_%langid%
:_disk_936
set disk=磁盘
goto _show_all_stage2
:_disk_437
set disk=Disk
goto _show_all_stage2

:_show_all_stage2
wmic diskdrive where "partitions<>0" get deviceid | find /i "physicaldrive" | sort >%Me.Tempfile%
for /f "delims=.\PHYSICALDRIVE" %%i in (%Me.Tempfile%) do (
	echo BEGIN %disk% %%i
	echo select disk %%i>%Me.Scriptfile%
	echo detail disk>>%Me.Scriptfile%
	diskpart /s %Me.Scriptfile%  | find /v /i "microsoft">%Me.Tempfile%
	for /f "skip=5 tokens=*" %%s in (%Me.Tempfile%) do echo   %%s
	echo END
	echo.
)
goto _end

:_usage
goto _usage_%langid%
:_usage_936
set msg1=为指定的卷分配一个驱动器号或装入点。
set msg2=用法：%Me.Name% volume# [驱动器号: ^^^| 装入点]
set msg3=	使用例：%Me.Name% volume5 x:
goto _show_usage
:_usage_437
set msg1=Assigns a drive letter or mount point to the specified volume.
set msg2=Usage: %Me% drive: volume# [^^^| mount_point]
set msg3=	e.g.: %Me.Name% volume5 x:
goto _show_usage
:_show_usage
call :_show_msg_all
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
call :_show_msg_all
goto _end

:_no_vol
goto _no_vol_%langid%
:_no_vol_936
set msg1=没有指定卷号
goto _show_no_vol
:_no_vol_437
set msg1=Volume# not specified!
goto _show_no_vol
:_show_no_vol
call :_show_msg_all
goto _end

:_volnum_err
goto _volnum_err_%langid%
:_volnum_err_936
set msg1=卷号错误
goto _show_volnum_err
:_volnum_err_437
set msg1=Volume number error!
goto _show_volnum_err
:_show_volnum_err
call :_show_msg_all
goto _end


:_mnt_point_exist
goto _mnt_point_exist_%langid%
:_mnt_point_exist_936
set msg1=驱动器号或装入点已经存在
goto _show_mnt_point_exist
:_mnt_point_exist_437
set msg1=Drive letter or mount point already exist
goto _show_mnt_point_exist
:_show_mnt_point_exist
call :_show_msg_all
goto _end
:_show_msg_all
if defined msg1 (echo %msg1% && set msg1=)
if defined msg2 (echo %msg2% && set msg2=)
if defined msg3 (echo %msg3% && set msg3=)
exit /b


:_end
if "%ShellType%"=="GUI" pause
if exist %Me.Tempfile% del /f /q %Me.Tempfile%
if exist %Me.Scriptfile% del /f /q %Me.Scriptfile%
exit /b %ret%
endlocal