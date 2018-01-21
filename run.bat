@echo off
setlocal
set Me.Path=%~dps0
echo %0 | find ":" >nul && (set ShellType=GUI) || (set ShellType=CONSOLE)

if "%1"=="" goto _end
set target.bin=%~n1.vbs;%~n1.cmd;%~n1.bat;%~n1.exe;%~n1.com;%~n1
for /r %Me.Path%..\ %%f in (%target.bin%) do if exist %%f set target.app=%%f
if not defined target.app goto _no_target

set paramlist=
:_next_arg
if "%~2"=="" goto _run_cmd
if /i not "%~2"=="/run-pause" goto _make_paramlist
set ShellType=GUI
goto _do_shift
:_make_paramlist
set paramlist=%paramlist% %2
:_do_shift
shift /2
goto _next_arg

:_run_cmd
set cmdline=%target.app%%paramlist%
echo ------Invoking [%cmdline%]...
%cmdline%
goto _end

:_no_target
echo None of %target.bin% was found
echo in %Me.Path%..\ and its subdirectories.
goto _end

:_end
echo ******&& echo   Returned [%errorlevel%]
echo ------Done.
if "%ShellType%"=="GUI" pause
endlocal