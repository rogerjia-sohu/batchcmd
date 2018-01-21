@echo off
setlocal
if "%1"=="" call :_usage && goto :EOF
set /a s=%~1+1
if %s% leq 1 echo Invalid parameter "%1".&& goto :EOF
echo Wait %1 seconds to contine . . .
ping -n %s% 127.0.0.1>nul
goto :EOF

:_usage
echo Usage: %~n0 n
echo     n		Number of seconds to wait.